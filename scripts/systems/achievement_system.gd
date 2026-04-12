class_name AchievementSystem
extends RefCounted
## R7 Epic AF — Achievement system with 20 achievements, tracking, persistence.

const ACHIEVEMENTS: Array[Dictionary] = [
	# AF16: Boss kill achievements
	{"id": "boss_memory_warden", "name": "Memory Unlocked", "desc": "Defeat the Memory Warden", "type": "boss_kill", "target": "memory_warden"},
	{"id": "boss_root_heart", "name": "Heartbreaker", "desc": "Defeat the Root Heart", "type": "boss_kill", "target": "root_heart"},
	{"id": "boss_sentinel_prime", "name": "Override Complete", "desc": "Defeat Sentinel Prime", "type": "boss_kill", "target": "sentinel_prime"},
	{"id": "boss_iteration_phantom", "name": "Self Defeated", "desc": "Defeat the Iteration Phantom", "type": "boss_kill", "target": "iteration_phantom"},
	{"id": "boss_void_architect", "name": "Void Erased", "desc": "Defeat the Void Architect", "type": "boss_kill", "target": "void_architect"},
	{"id": "boss_mosaic_hydra", "name": "Defragmented", "desc": "Defeat the Mosaic Hydra", "type": "boss_kill", "target": "mosaic_hydra"},
	{"id": "boss_compiler_reborn", "name": "Recompiled", "desc": "Defeat The Compiler Reborn", "type": "boss_kill", "target": "compiler_reborn"},
	{"id": "boss_origin", "name": "Origin Found", "desc": "Defeat The Origin Singularity", "type": "boss_kill", "target": "origin_singularity"},
	# AF17: Iteration milestones
	{"id": "iter_3", "name": "Third Loop", "desc": "Reach Iteration 3", "type": "iteration", "target": 3},
	{"id": "iter_6", "name": "Deep Diver", "desc": "Reach Iteration 6", "type": "iteration", "target": 6},
	{"id": "iter_9", "name": "Origin Seeker", "desc": "Reach Iteration 9", "type": "iteration", "target": 9},
	# AF18: Kill counts
	{"id": "kills_100", "name": "Centurion", "desc": "Defeat 100 enemies", "type": "kill_count", "target": 100},
	{"id": "kills_500", "name": "Exterminator", "desc": "Defeat 500 enemies", "type": "kill_count", "target": 500},
	{"id": "kills_1000", "name": "Annihilator", "desc": "Defeat 1000 enemies", "type": "kill_count", "target": 1000},
	# AF19: Gold milestones
	{"id": "gold_100", "name": "Pocket Change", "desc": "Accumulate 100 gold", "type": "gold", "target": 100},
	{"id": "gold_500", "name": "Wealthy", "desc": "Accumulate 500 gold", "type": "gold", "target": 500},
	{"id": "gold_1000", "name": "Tycoon", "desc": "Accumulate 1000 gold", "type": "gold", "target": 1000},
	# Misc
	{"id": "first_death", "name": "Learning Experience", "desc": "Die for the first time", "type": "death_count", "target": 1},
	{"id": "max_level", "name": "Fully Optimized", "desc": "Reach level 60", "type": "level", "target": 60},
	# AF20: Completionist
	{"id": "completionist", "name": "Completionist", "desc": "Unlock all other achievements", "type": "completionist", "target": 19},
]

## Returns unlocked achievement IDs from GameManager metas.
static func get_unlocked() -> Array[String]:
	var unlocked: Array[String] = []
	if GameManager.has_meta(&"unlocked_achievements"):
		var raw: Variant = GameManager.get_meta(&"unlocked_achievements")
		if raw is Array:
			for id: Variant in raw as Array:
				unlocked.append(str(id))
	return unlocked


## Check and unlock any newly-met achievements. Returns newly unlocked IDs.
static func check_all() -> Array[String]:
	var unlocked: Array[String] = get_unlocked()
	var newly: Array[String] = []
	for ach: Dictionary in ACHIEVEMENTS:
		var id: String = str(ach.get("id", ""))
		if id in unlocked:
			continue
		if _check_condition(ach):
			unlocked.append(id)
			newly.append(id)
	if not newly.is_empty():
		GameManager.set_meta(&"unlocked_achievements", unlocked)
	return newly


static func _check_condition(ach: Dictionary) -> bool:
	var ach_type: String = str(ach.get("type", ""))
	var target: Variant = ach.get("target", 0)
	match ach_type:
		"boss_kill":
			return GameManager.has_meta(StringName("boss_defeated_%s" % str(target)))
		"iteration":
			if GameManager.has_node("/root/IterationManager"):
				return int(GameManager.get_node("/root/IterationManager").current_iteration) >= int(target)
			return false
		"kill_count":
			return GameManager.total_enemies_defeated >= int(target)
		"gold":
			return GameManager.player_gold >= int(target)
		"death_count":
			return GameManager.total_deaths >= int(target)
		"level":
			var players: Array[Node] = GameManager.get_tree().get_nodes_in_group(&"player")
			if players.size() > 0 and "level_component" in players[0]:
				return players[0].level_component.current_level >= int(target)
			return false
		"completionist":
			return get_unlocked().size() >= int(target)
	return false


## AF14: Save/load unlocked achievements.
static func to_save_data() -> Dictionary:
	return {"unlocked": get_unlocked()}

static func from_save_data(data: Dictionary) -> void:
	if data.has("unlocked"):
		GameManager.set_meta(&"unlocked_achievements", data["unlocked"])
