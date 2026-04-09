class_name BossDatabase
extends RefCounted

## Static catalog of all 5 new bosses with phase data, attack patterns,
## arena hooks, and rewards.

const BOSSES: Array = [
	{
		"id": &"memory_warden",
		"name": "Memory Warden",
		"biome": &"memory_vaults",
		"iteration_unlock": 2,
		"arena": &"memory_warden_arena",
		"music": &"boss_memory_warden",
		"reward_chest": &"vault_keeper_chest",
		"phases": [
			{
				"name": "Vigil",
				"hp": 1500,
				"speed": 2.5,
				"attacks": [
					{"id": &"slam",   "telegraph": 1.2, "damage": 30, "range": 4.0, "cooldown": 4.0},
					{"id": &"charge", "telegraph": 0.6, "damage": 25, "range": 8.0, "cooldown": 6.0},
					{"id": &"sweep",  "telegraph": 0.8, "damage": 20, "range": 5.0, "cooldown": 5.0},
				],
			},
			{
				"name": "Awakened",
				"hp": 2200,
				"speed": 3.0,
				"attacks": [
					{"id": &"slam",          "telegraph": 1.0, "damage": 38, "range": 4.0, "cooldown": 3.5},
					{"id": &"crystal_volley","telegraph": 1.5, "damage": 12, "range": 12.0, "cooldown": 7.0},
					{"id": &"crystal_wall",  "telegraph": 1.5, "damage": 0,  "range": 0.0, "cooldown": 12.0},
				],
			},
			{
				"name": "Eternal",
				"hp": 3000,
				"speed": 3.5,
				"aura_dps": 5.0,
				"attacks": [
					{"id": &"memory_storm","telegraph": 2.5, "damage": 80, "range": 999.0, "cooldown": 18.0},
					{"id": &"slam",        "telegraph": 0.8, "damage": 45, "range": 4.0, "cooldown": 3.0},
					{"id": &"last_stand",  "telegraph": 0.0, "damage": 0,  "range": 0.0, "cooldown": 999.0, "trigger_hp_pct": 0.10},
				],
			},
		],
	},
	{
		"id": &"root_heart",
		"name": "Root Heart",
		"biome": &"corrupted_wilds",
		"iteration_unlock": 3,
		"arena": &"root_heart_arena",
		"music": &"boss_root_heart",
		"reward_chest": &"heartbreaker_chest",
		"phases": [
			{
				"name": "Awakening",
				"hp": 1200,
				"limbs": 4,
				"limb_hp": 400,
				"heart_shielded": true,
				"attacks": [
					{"id": &"limb_slam",  "telegraph": 1.0, "damage": 25, "range": 5.0, "cooldown": 3.0},
					{"id": &"root_spike", "telegraph": 1.2, "damage": 28, "range": 8.0, "cooldown": 5.0},
					{"id": &"sap_spray",  "telegraph": 0.8, "damage": 15, "range": 6.0, "cooldown": 4.0},
				],
			},
			{
				"name": "Bleeding",
				"hp": 1200,  # heart only
				"limbs": 4,
				"limb_hp": 350,
				"heart_shielded": false,
				"attacks": [
					{"id": &"spore_cloud","telegraph": 1.5, "damage": 8, "range": 6.0, "cooldown": 5.0},
					{"id": &"healing_pulse","telegraph": 0.0, "damage": -60, "range": 0.0, "cooldown": 4.0, "self_heal": true},
				],
			},
			{
				"name": "Rage",
				"hp": 1200,
				"limbs_independent": true,
				"attacks": [
					{"id": &"final_bloom","telegraph": 5.0, "damage": 150, "range": 999.0, "cooldown": 25.0, "interruptible": true},
				],
			},
		],
	},
	{
		"id": &"sentinel_prime",
		"name": "Sentinel Prime",
		"biome": &"server_room",
		"iteration_unlock": 4,
		"arena": &"sentinel_prime_arena",
		"music": &"boss_sentinel_prime",
		"reward_chest": &"outflanked_chest",
		"phases": [
			{
				"name": "Standard Patrol",
				"hp": 1800,
				"speed": 5.5,
				"attacks": [
					{"id": &"tracking_shot","telegraph": 0.8, "damage": 22, "range": 14.0, "cooldown": 2.5},
					{"id": &"strafe_burst","telegraph": 0.5, "damage": 12, "range": 10.0, "cooldown": 3.5},
					{"id": &"tactical_dash","telegraph": 0.3, "damage": 0, "range": 6.0, "cooldown": 5.0},
				],
			},
			{
				"name": "Combat Mode",
				"hp": 2500,
				"speed": 5.5,
				"attacks": [
					{"id": &"beam_weapon","telegraph": 2.0, "damage": 50, "range": 16.0, "cooldown": 8.0},
					{"id": &"drone_deploy","telegraph": 1.0, "damage": 0, "range": 0.0, "cooldown": 15.0},
					{"id": &"shield_generator","telegraph": 0.5, "damage": 0, "range": 0.0, "cooldown": 20.0, "self_buff": "damage_resist_50"},
				],
			},
			{
				"name": "Override",
				"hp": 3200,
				"speed": 7.0,
				"attacks": [
					{"id": &"massacre_protocol","telegraph": 1.5, "damage": 35, "range": 12.0, "cooldown": 6.0},
					{"id": &"overcharge","telegraph": 0.0, "damage": 0, "range": 0.0, "cooldown": 999.0, "self_buff": "damage_taken_150_dealt_200"},
				],
			},
		],
	},
	{
		"id": &"iteration_phantom",
		"name": "Iteration Phantom",
		"biome": &"sage_sanctum",
		"iteration_unlock": 5,
		"arena": &"phantom_mirror_room",
		"music": &"boss_iteration_phantom",
		"reward_chest": &"self_defeat_chest",
		"phases": [
			{
				"name": "Echo",
				"hp_scale_to_player": 6.0,
				"damage_scale_to_player": 1.2,
				"speed_scale_to_player": 1.0,
				"mirror_player_modules": true,
				"mirror_delay": 1.5,
			},
			{
				"name": "Reflection",
				"hp_scale_to_player": 6.0,
				"damage_scale_to_player": 1.4,
				"opposite_class_abilities": true,
			},
			{
				"name": "Convergence",
				"hp_scale_to_player": 6.0,
				"damage_scale_to_player": 1.6,
				"max_class_loadout": true,
			},
		],
	},
	{
		"id": &"compiler_reborn",
		"name": "The Compiler Reborn",
		"biome": &"final_vault",
		"iteration_unlock": 8,
		"arena": &"final_vault_arena",
		"music": &"boss_compiler_reborn",
		"reward_chest": &"the_end_chest",
		"phases": [
			{
				"name": "Awakening",
				"hp": 8000,
				"attacks": [
					{"id": &"slam_v1",     "telegraph": 1.0, "damage": 40, "range": 5.0, "cooldown": 4.0},
					{"id": &"sweep_beam",  "telegraph": 1.5, "damage": 35, "range": 12.0, "cooldown": 6.0},
					{"id": &"summon_adds", "telegraph": 1.0, "damage": 0,  "range": 0.0, "cooldown": 15.0},
				],
			},
			{
				"name": "Compilation Error",
				"hp": 6000,
				"attacks": [
					{"id": &"code_cascade","telegraph": 1.5, "damage": 25, "range": 999.0, "cooldown": 8.0},
					{"id": &"phase_shift", "telegraph": 0.0, "damage": 0,  "range": 0.0, "cooldown": 5.0, "self_buff": "invuln_1s"},
				],
			},
			{
				"name": "Stack Overflow",
				"hp": 5000,
				"attacks": [
					{"id": &"falling_blocks","telegraph": 0.0, "damage": 30, "range": 999.0, "cooldown": 0.5, "passive": true},
					{"id": &"memory_leak",   "telegraph": 1.0, "damage": 8,  "range": 4.0, "cooldown": 5.0, "leaves_hazard": true},
				],
			},
			{
				"name": "Recursion",
				"hp": 4000,
				"spawns_clones": 3,
				"clone_share_hp": true,
			},
			{
				"name": "Final Loop",
				"hp": 3000,
				"attacks": [
					{"id": &"users_verdict",  "telegraph": 3.0, "damage": 100, "range": 999.0, "cooldown": 20.0},
					{"id": &"avatar_strike",  "telegraph": 1.5, "damage": 60,  "range": 999.0, "cooldown": 8.0},
					{"id": &"iteration_reset","telegraph": 5.0, "damage": 999, "range": 999.0, "cooldown": 999.0, "trigger_hp_pct": 0.10, "interruptible": true},
				],
			},
		],
	},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return BOSSES


static func get_boss(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for b in BOSSES:
		_index[b["id"]] = b


static func get_phase(boss_id: StringName, phase_index: int) -> Dictionary:
	var b: Dictionary = get_boss(boss_id)
	var phases: Array = b.get("phases", [])
	if phase_index < 0 or phase_index >= phases.size():
		return {}
	return phases[phase_index]


static func get_phase_count(boss_id: StringName) -> int:
	return get_boss(boss_id).get("phases", []).size()


static func get_total_hp(boss_id: StringName) -> int:
	var total: int = 0
	for phase in get_boss(boss_id).get("phases", []):
		total += int(phase.get("hp", 0))
	return total


static func count() -> int:
	return BOSSES.size()
