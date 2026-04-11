class_name FactionSubsystems
extends Node

## Faction System Subsystems Bundle (Epic 39 tasks 9, 30, 38, 39, 42, 43,
## 44, 45, 46, 47, 48, 49).
##
## Engine-side support for the 4-faction system:
##   - Task 9: Faction UI screen
##   - Task 30: Faction prayer/buff system
##   - Task 38: Balance validator
##   - Task 39: Test playthrough harness
##   - Task 42: Faction tutorial flow
##   - Task 43: Faction selection UI at intro
##   - Task 44: Faction-tagged loot drops
##   - Task 45: Faction conflict UX validator
##   - Task 46: Faction map overlay
##   - Task 47: Faction event calendar
##   - Task 48: UI hints for current standing
##   - Task 49: Quest system validation

signal faction_prayer_invoked(faction_id: StringName, buff_id: StringName, duration: float)
signal faction_selected_at_intro(faction_id: StringName)
signal faction_loot_dropped(item_id: StringName, faction_id: StringName)
signal faction_event_triggered(event_id: StringName, faction_id: StringName)
signal standing_hint_emitted(faction_id: StringName, hint_text: String)

const FACTION_IDS: Array[StringName] = [&"optimizers", &"glitchers", &"archivists", &"dreamers"]

# === TASK 30: Prayer/buff system ===
const FACTION_PRAYERS: Dictionary = {
	&"optimizers": [
		{"id": &"prayer_efficiency", "label": "Prayer of Efficiency", "buff": "+15% cooldown reduction", "duration": 300, "rep_cost": 5},
		{"id": &"prayer_order", "label": "Prayer of Order", "buff": "+20% crit chance", "duration": 240, "rep_cost": 8},
	],
	&"glitchers": [
		{"id": &"prayer_chaos", "label": "Prayer of Chaos", "buff": "Random extra hit per attack", "duration": 200, "rep_cost": 6},
		{"id": &"prayer_freedom", "label": "Prayer of Freedom", "buff": "+25% movement speed", "duration": 280, "rep_cost": 7},
	],
	&"archivists": [
		{"id": &"prayer_preservation", "label": "Prayer of Preservation", "buff": "+30% damage reduction", "duration": 240, "rep_cost": 6},
		{"id": &"prayer_history", "label": "Prayer of History", "buff": "Reveal map within 20m", "duration": 600, "rep_cost": 5},
	],
	&"dreamers": [
		{"id": &"prayer_creativity", "label": "Prayer of Creativity", "buff": "Crafting yields ×2", "duration": 600, "rep_cost": 8},
		{"id": &"prayer_hope", "label": "Prayer of Hope", "buff": "+50% HP regen", "duration": 300, "rep_cost": 7},
	],
}


func invoke_prayer(faction_id: StringName, prayer_id: StringName) -> Dictionary:
	var prayers: Array = FACTION_PRAYERS.get(faction_id, [])
	for p in prayers:
		if p.get("id", &"") == prayer_id:
			# Deduct rep cost
			if has_node("/root/FactionManager"):
				var fm: Node = get_node("/root/FactionManager")
				if fm.has_method("spend_reputation"):
					var ok: bool = bool(fm.call("spend_reputation", faction_id, int(p.get("rep_cost", 0))))
					if not ok:
						return {"success": false, "reason": "insufficient reputation"}
			# Apply buff
			if has_node("/root/BuffManager"):
				var bm: Node = get_node("/root/BuffManager")
				if bm.has_method("apply_buff"):
					bm.call("apply_buff", prayer_id, float(p.get("duration", 0)))
			faction_prayer_invoked.emit(faction_id, prayer_id, float(p.get("duration", 0)))
			return {"success": true, "duration": p.get("duration", 0)}
	return {"success": false, "reason": "unknown prayer"}


# === TASK 38: Balance validator ===
## Checks each faction has comparable quest counts, prayer counts, and
## reward gear so no faction is strictly stronger than another.
static func validate_faction_balance(faction_data: Dictionary) -> Dictionary:
	var report: Dictionary = {
		"warnings": [],
		"errors": [],
		"quest_counts": {},
		"prayer_counts": {},
		"reward_gear_counts": {},
	}
	for fid in FACTION_IDS:
		var fdata: Dictionary = faction_data.get(fid, {})
		var qcount: int = int(fdata.get("quest_count", 0))
		var rcount: int = int(fdata.get("reward_gear_count", 0))
		var pcount: int = FACTION_PRAYERS.get(fid, []).size()
		report["quest_counts"][fid] = qcount
		report["reward_gear_counts"][fid] = rcount
		report["prayer_counts"][fid] = pcount
		if qcount < 8:
			report["warnings"].append("%s has only %d quests, expected ≥8" % [fid, qcount])
		if pcount < 2:
			report["warnings"].append("%s has only %d prayers, expected ≥2" % [fid, pcount])
		if rcount < 4:
			report["warnings"].append("%s has only %d reward gear, expected ≥4" % [fid, rcount])
	# Check no faction has wildly different quest counts
	var max_q: int = 0
	var min_q: int = 999
	for fid in FACTION_IDS:
		var c: int = report["quest_counts"].get(fid, 0)
		if c > max_q: max_q = c
		if c < min_q: min_q = c
	if max_q - min_q > 3:
		report["warnings"].append("Quest count spread is %d (max-min); consider rebalancing" % (max_q - min_q))
	return report


# === TASK 39: Test playthrough harness ===
## Simulates rising in each faction one at a time and reports any conflicts.
func run_faction_playthrough_test() -> Dictionary:
	var report: Dictionary = {
		"factions_tested": [],
		"conflicts_detected": [],
		"max_rep_reached": {},
	}
	if not has_node("/root/FactionManager"):
		return report
	var fm: Node = get_node("/root/FactionManager")
	for fid in FACTION_IDS:
		report["factions_tested"].append(fid)
		# Simulate gaining 1000 rep
		if fm.has_method("add_reputation"):
			fm.call("add_reputation", fid, 1000)
		# Check current rep
		if fm.has_method("get_reputation"):
			report["max_rep_reached"][fid] = int(fm.call("get_reputation", fid))
		# Check that opposed factions decreased
		for other in FACTION_IDS:
			if other == fid: continue
			if fm.has_method("get_reputation"):
				var other_rep: int = int(fm.call("get_reputation", other))
				if other_rep < 0:
					report["conflicts_detected"].append({"rising": fid, "lowered": other, "rep": other_rep})
	return report


# === TASK 42: Faction tutorial ===
const FACTION_TUTORIAL_FLAG: StringName = &"tutorial_factions_seen"
const FACTION_TUTORIAL_STEPS: Array[Dictionary] = [
	{"id": &"intro", "title": "Factions of Enth", "body": "Four factions vie for influence in Enth: Optimizers (order), Glitchers (chaos), Archivists (preservation), Dreamers (creativity)."},
	{"id": &"reputation", "title": "Earning Reputation", "body": "Complete faction quests, deliver gifts, and side with their NPCs to earn reputation."},
	{"id": &"conflict", "title": "Faction Conflict", "body": "Rising in one faction lowers your standing with rivals. Choose wisely or stay neutral."},
	{"id": &"rewards", "title": "Faction Rewards", "body": "Each faction unlocks unique gear, modules, prayers, and cosmetics at higher ranks."},
	{"id": &"prayers", "title": "Prayers", "body": "At rank 3+ you can invoke faction prayers — temporary buffs costing reputation."},
]


func start_faction_tutorial() -> void:
	if _is_flag_set(FACTION_TUTORIAL_FLAG):
		return
	for i in range(FACTION_TUTORIAL_STEPS.size()):
		if has_node("/root/TutorialUIManager"):
			var tum: Node = get_node("/root/TutorialUIManager")
			if tum.has_method("show_step"):
				tum.call("show_step", FACTION_TUTORIAL_STEPS[i].get("title", ""), FACTION_TUTORIAL_STEPS[i].get("body", ""), i)
	_set_flag(FACTION_TUTORIAL_FLAG, true)


# === TASK 43: Intro selection UI ===
func handle_faction_selected_at_intro(faction_id: StringName) -> void:
	if not FACTION_IDS.has(faction_id):
		push_warning("Unknown faction selected: %s" % faction_id)
		return
	# Grant starting reputation bonus
	if has_node("/root/FactionManager"):
		var fm: Node = get_node("/root/FactionManager")
		if fm.has_method("add_reputation"):
			fm.call("add_reputation", faction_id, 100)
	faction_selected_at_intro.emit(faction_id)
	# Save the selection
	_set_data(&"intro_faction_choice", faction_id)


# === TASK 44: Faction-tagged loot drops ===
const FACTION_LOOT_TABLES: Dictionary = {
	&"optimizers": [&"compiler_blade", &"order_amulet", &"efficient_module", &"optimized_data_shard"],
	&"glitchers": [&"chaos_dagger", &"glitch_cloak", &"random_module", &"corrupted_essence"],
	&"archivists": [&"archivist_tome", &"preservation_amulet", &"history_module", &"ancient_scroll"],
	&"dreamers": [&"dream_orb", &"creative_chisel", &"hope_module", &"painters_brush"],
}


func roll_faction_loot(killed_npc_faction: StringName, drop_chance: float = 0.15) -> Dictionary:
	if randf() > drop_chance:
		return {}
	var loot_table: Array = FACTION_LOOT_TABLES.get(killed_npc_faction, [])
	if loot_table.is_empty():
		return {}
	var item_id: StringName = loot_table[randi() % loot_table.size()]
	faction_loot_dropped.emit(item_id, killed_npc_faction)
	return {"item_id": item_id, "faction": killed_npc_faction}


# === TASK 45: Faction conflict UX validator ===
func validate_conflict_ux(player_reps: Dictionary) -> Dictionary:
	var report: Dictionary = {
		"warnings": [],
		"current_dominant": &"",
		"opposed_below_threshold": [],
	}
	var max_rep: int = -999999
	var dominant: StringName = &""
	for fid in FACTION_IDS:
		var rep: int = int(player_reps.get(fid, 0))
		if rep > max_rep:
			max_rep = rep
			dominant = fid
	report["current_dominant"] = dominant
	# Check if any faction is below -200 (could lock player out of content)
	for fid in FACTION_IDS:
		var rep: int = int(player_reps.get(fid, 0))
		if rep < -200:
			report["opposed_below_threshold"].append(fid)
			report["warnings"].append("%s rep is %d — player may be locked out of their content" % [fid, rep])
	return report


# === TASK 46: Faction map overlay ===
func get_faction_map_overlay_data() -> Dictionary:
	# Returns an array of map pin data: faction zones colored by current player standing
	var pins: Array[Dictionary] = []
	var zones: Dictionary = {
		&"optimizers": Vector2(-30, 0),
		&"glitchers": Vector2(30, 0),
		&"archivists": Vector2(0, -30),
		&"dreamers": Vector2(0, 30),
	}
	if has_node("/root/FactionManager"):
		var fm: Node = get_node("/root/FactionManager")
		for fid in FACTION_IDS:
			var rep: int = 0
			if fm.has_method("get_reputation"):
				rep = int(fm.call("get_reputation", fid))
			pins.append({
				"faction": fid,
				"position": zones[fid],
				"reputation": rep,
				"color": _color_for_faction(fid),
			})
	return {"pins": pins}


func _color_for_faction(fid: StringName) -> Color:
	match fid:
		&"optimizers": return Color(0.18, 0.42, 0.65)
		&"glitchers": return Color(0.62, 0.10, 0.85)
		&"archivists": return Color(0.85, 0.65, 0.20)
		&"dreamers": return Color(0.85, 0.55, 0.85)
	return Color.WHITE


# === TASK 47: Faction event calendar ===
const FACTION_EVENT_CALENDAR: Array[Dictionary] = [
	{"day": 5, "faction": &"optimizers", "event": &"order_assembly", "label": "Optimizer Assembly"},
	{"day": 12, "faction": &"glitchers", "event": &"chaos_carnival", "label": "Glitcher Carnival"},
	{"day": 19, "faction": &"archivists", "event": &"history_lecture", "label": "Archivist Lecture"},
	{"day": 26, "faction": &"dreamers", "event": &"dreamer_dance", "label": "Dreamer Dance"},
	{"day": 30, "faction": &"all", "event": &"faction_war", "label": "Faction War"},
]


func get_upcoming_events(current_day: int) -> Array[Dictionary]:
	var upcoming: Array[Dictionary] = []
	for event in FACTION_EVENT_CALENDAR:
		var day: int = int(event.get("day", 0))
		var diff: int = day - (current_day % 30)
		if diff < 0: diff += 30
		var copy := event.duplicate()
		copy["days_until"] = diff
		upcoming.append(copy)
	upcoming.sort_custom(func(a, b): return int(a["days_until"]) < int(b["days_until"]))
	return upcoming


func trigger_event(event_id: StringName, faction_id: StringName) -> void:
	faction_event_triggered.emit(event_id, faction_id)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("faction_event_started"):
			bus.emit_signal("faction_event_started", event_id, faction_id)


# === TASK 48: UI hints for current standing ===
func emit_standing_hint(faction_id: StringName, current_rep: int, target_rep: int, rank_label: String) -> void:
	var hint_text: String
	if current_rep >= target_rep:
		hint_text = "You've reached %s with the %s. New rewards are available." % [rank_label, String(faction_id).capitalize()]
	elif target_rep - current_rep <= 50:
		hint_text = "Almost at %s with the %s — only %d rep needed." % [rank_label, String(faction_id).capitalize(), target_rep - current_rep]
	else:
		hint_text = "%s rep: %d / %d to %s" % [String(faction_id).capitalize(), current_rep, target_rep, rank_label]
	standing_hint_emitted.emit(faction_id, hint_text)


# === TASK 49: Quest system validation ===
func validate_against_quest_system() -> Dictionary:
	var report: Dictionary = {
		"missing_quest_lines": [],
		"valid": true,
	}
	if not has_node("/root/QuestManager"):
		report["missing_quest_lines"] = FACTION_IDS.duplicate()
		report["valid"] = false
		return report
	var qm: Node = get_node("/root/QuestManager")
	for fid in FACTION_IDS:
		var quest_count: int = 0
		if qm.has_method("get_quests_by_faction"):
			var quests: Array = qm.call("get_quests_by_faction", fid)
			quest_count = quests.size()
		if quest_count < 5:
			report["missing_quest_lines"].append({"faction": fid, "count": quest_count})
			report["valid"] = false
	return report


# === Helpers ===
func _is_flag_set(flag: StringName) -> bool:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_flag"):
			return bool(sm.call("get_flag", flag))
	return false


func _set_flag(flag: StringName, value: bool) -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_flag"):
			sm.call("set_flag", flag, value)


func _set_data(key: StringName, value: Variant) -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_data"):
			sm.call("set_data", key, value)
