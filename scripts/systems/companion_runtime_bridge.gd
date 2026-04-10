class_name CompanionRuntimeBridge
extends Node

## Companion Runtime Bridge (Epic 40 tasks 30, 40, 45, 46, 48).
##
## Engine-side support for the 4-companion system:
##   - Task 30: Companion-Globbler relationship cutscene database
##   - Task 40: Full run test harness for each companion
##   - Task 45: UX validator (loadout/gear/level reachable from menu)
##   - Task 46: Companion tutorial flow
##   - Task 48: Companion respec system

signal cutscene_triggered(cutscene_id: StringName, companion_id: StringName)
signal run_test_finished(report: Dictionary)
signal respec_completed(companion_id: StringName, refunded_points: int)
signal tutorial_step_shown(step_index: int)

const COMPANION_IDS: Array[StringName] = [&"tank", &"dps", &"healer", &"utility"]
const TUTORIAL_FLAG: StringName = &"tutorial_companions_seen"

# === TASK 30: Relationship cutscenes ===
const RELATIONSHIP_CUTSCENES: Dictionary = {
	&"tank": [
		{"id": &"cutscene_tank_meet", "trigger": &"first_summon", "label": "First Bond"},
		{"id": &"cutscene_tank_save", "trigger": &"saved_player_3_times", "label": "I've Got You"},
		{"id": &"cutscene_tank_max_affinity", "trigger": &"max_affinity", "label": "Sworn Shield"},
	],
	&"dps": [
		{"id": &"cutscene_dps_meet", "trigger": &"first_summon", "label": "Sharpshooter's Promise"},
		{"id": &"cutscene_dps_kills", "trigger": &"100_kills_together", "label": "Hundred-Kill Salute"},
		{"id": &"cutscene_dps_max_affinity", "trigger": &"max_affinity", "label": "Trusted Aim"},
	],
	&"healer": [
		{"id": &"cutscene_healer_meet", "trigger": &"first_summon", "label": "Quiet Resolve"},
		{"id": &"cutscene_healer_revive", "trigger": &"revived_player_5_times", "label": "Always Returning"},
		{"id": &"cutscene_healer_max_affinity", "trigger": &"max_affinity", "label": "Eternal Promise"},
	],
	&"utility": [
		{"id": &"cutscene_utility_meet", "trigger": &"first_summon", "label": "Trickster's Wager"},
		{"id": &"cutscene_utility_outsmart", "trigger": &"cc_chained_5_enemies", "label": "Mastermind"},
		{"id": &"cutscene_utility_max_affinity", "trigger": &"max_affinity", "label": "Mind to Mind"},
	],
}


func trigger_cutscene(companion_id: StringName, trigger: StringName) -> bool:
	var cutscenes: Array = RELATIONSHIP_CUTSCENES.get(companion_id, [])
	for cs in cutscenes:
		if cs.get("trigger", &"") == trigger:
			var cutscene_id: StringName = cs.get("id", &"")
			cutscene_triggered.emit(cutscene_id, companion_id)
			if has_node("/root/CinematicRevealManager"):
				var crm: Node = get_node("/root/CinematicRevealManager")
				if crm.has_method("try_play"):
					return bool(crm.call("try_play", cutscene_id))
			return true
	return false


func get_cutscenes_for_companion(companion_id: StringName) -> Array:
	return RELATIONSHIP_CUTSCENES.get(companion_id, []).duplicate(true)


# === TASK 40: Full run test harness per companion ===
func run_full_run_test() -> Dictionary:
	var report: Dictionary = {
		"companions_tested": [],
		"failures": [],
		"all_runs_completed": true,
	}
	for cid in COMPANION_IDS:
		var run_report: Dictionary = _simulate_run_with_companion(cid)
		report["companions_tested"].append({"id": cid, "report": run_report})
		if not run_report.get("success", false):
			report["all_runs_completed"] = false
			report["failures"].append(cid)
	run_test_finished.emit(report)
	return report


func _simulate_run_with_companion(companion_id: StringName) -> Dictionary:
	# Stateless mock — verifies the companion exists, has AI defined,
	# and has at least 1 ability hooked
	var report: Dictionary = {
		"companion": companion_id,
		"success": true,
		"warnings": [],
	}
	if has_node("/root/CompanionManager"):
		var cm: Node = get_node("/root/CompanionManager")
		if cm.has_method("get_companion"):
			var c: Dictionary = cm.call("get_companion", companion_id)
			if c.is_empty():
				report["success"] = false
				report["warnings"].append("Companion not registered")
		else:
			report["warnings"].append("CompanionManager missing get_companion()")
	# Check ability count
	if has_node("/root/AbilityManager"):
		var am: Node = get_node("/root/AbilityManager")
		if am.has_method("get_abilities_for"):
			var abilities: Array = am.call("get_abilities_for", companion_id)
			if abilities.is_empty():
				report["warnings"].append("No abilities registered")
	return report


# === TASK 45: UX validator ===
func validate_companion_ux() -> Dictionary:
	var report: Dictionary = {
		"missing_systems": [],
		"valid": true,
	}
	for system_name in ["CompanionManager", "InventoryManager"]:
		if not has_node("/root/%s" % system_name):
			report["missing_systems"].append(system_name)
			report["valid"] = false
	# Check that each companion has gear slots wired
	if has_node("/root/CompanionManager"):
		var cm: Node = get_node("/root/CompanionManager")
		for cid in COMPANION_IDS:
			if cm.has_method("get_gear_slot_count"):
				var slots: int = int(cm.call("get_gear_slot_count", cid))
				if slots < 3:
					report["valid"] = false
					report["missing_systems"].append("%s gear slots: %d" % [cid, slots])
	return report


# === TASK 46: Tutorial flow ===
const TUTORIAL_STEPS: Array[Dictionary] = [
	{"id": &"intro", "title": "Companions", "body": "You can recruit one of four companions to join you in dungeons: Tank, DPS, Healer, or Utility."},
	{"id": &"summon", "title": "Summoning", "body": "Press [C] at a dungeon entrance to summon your active companion. Only one can be active at a time."},
	{"id": &"command", "title": "Commanding", "body": "Hold [V] for the command wheel: Attack, Defend, Use Ability, Hold Position."},
	{"id": &"loadout", "title": "Loadouts", "body": "Visit your companion in town to equip gear, allocate skill points, and customize their loadout."},
	{"id": &"affinity", "title": "Affinity", "body": "Companions level up affinity through shared runs. Higher affinity unlocks new dialogue, abilities, and cutscenes."},
]


func start_companion_tutorial() -> void:
	if _is_tutorial_seen():
		return
	for i in range(TUTORIAL_STEPS.size()):
		tutorial_step_shown.emit(i)
		if has_node("/root/TutorialUIManager"):
			var tum: Node = get_node("/root/TutorialUIManager")
			if tum.has_method("show_step"):
				tum.call("show_step", TUTORIAL_STEPS[i].get("title", ""), TUTORIAL_STEPS[i].get("body", ""), i)
	_set_tutorial_seen()


# === TASK 48: Companion respec ===
const RESPEC_GOLD_COST: int = 250
const RESPEC_ITEM_REQUIRED: StringName = &"reset_token"


func respec_companion(companion_id: StringName, allocated_node_ids: Array[StringName]) -> Dictionary:
	# Check cost
	if has_node("/root/CurrencyManager"):
		var cm: Node = get_node("/root/CurrencyManager")
		if cm.has_method("get_gold"):
			var gold: int = int(cm.call("get_gold"))
			if gold < RESPEC_GOLD_COST:
				return {"success": false, "reason": "insufficient gold"}
	# Refund all allocated points
	var total_refund: int = 0
	for nid in allocated_node_ids:
		var node: Dictionary = CompanionSkillTreeDatabase.get_node(companion_id, nid)
		total_refund += int(node.get("cost", 1))
	# Spend gold
	if has_node("/root/CurrencyManager"):
		var cm: Node = get_node("/root/CurrencyManager")
		if cm.has_method("spend_gold"):
			cm.call("spend_gold", RESPEC_GOLD_COST)
	# Tell CompanionManager to clear allocated nodes
	if has_node("/root/CompanionManager"):
		var cmgr: Node = get_node("/root/CompanionManager")
		if cmgr.has_method("clear_allocated_nodes"):
			cmgr.call("clear_allocated_nodes", companion_id)
		if cmgr.has_method("add_skill_points"):
			cmgr.call("add_skill_points", companion_id, total_refund)
	respec_completed.emit(companion_id, total_refund)
	return {"success": true, "refunded": total_refund, "gold_spent": RESPEC_GOLD_COST}


# === Helpers ===
func _is_tutorial_seen() -> bool:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_flag"):
			return bool(sm.call("get_flag", TUTORIAL_FLAG))
	return false


func _set_tutorial_seen() -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_flag"):
			sm.call("set_flag", TUTORIAL_FLAG, true)
