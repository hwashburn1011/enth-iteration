class_name QuestComponent
extends Node

## Player-side quest tracker. Owns: active quests, completed quests,
## failed quests, daily quest assignment, pinned quests for HUD.
## Drives objective progress via EventBus signals from gameplay.

signal quest_accepted(quest_id: StringName)
signal quest_completed(quest_id: StringName)
signal quest_failed(quest_id: StringName)
signal quest_progress_updated(quest_id: StringName, objective_index: int, current: int, target: int)
signal quest_pinned(quest_id: StringName)
signal quest_unpinned(quest_id: StringName)

const MAX_PINNED: int = 3

## active_quests: { quest_id -> { progress: { obj_index -> count }, accepted_day: int } }
var active_quests: Dictionary = {}
var completed_quests: Array[StringName] = []
var failed_quests: Array[StringName] = []
var pinned_quests: Array[StringName] = []
var daily_quests_today: Array[Dictionary] = []
var daily_streak: int = 0
var last_daily_reset_day: int = -1


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("enemy_killed"):
			bus.enemy_killed.connect(_on_enemy_killed)
		if bus.has_signal("item_picked_up"):
			bus.item_picked_up.connect(_on_item_picked_up)
		if bus.has_signal("npc_talked_to"):
			bus.npc_talked_to.connect(_on_npc_talked_to)
		if bus.has_signal("location_entered"):
			bus.location_entered.connect(_on_location_entered)
		if bus.has_signal("boss_defeated"):
			bus.boss_defeated.connect(_on_boss_defeated)
		if bus.has_signal("day_advanced"):
			bus.day_advanced.connect(_on_day_advanced)
		if bus.has_signal("fish_caught"):
			bus.fish_caught.connect(_on_fish_caught)


# === ACCEPT / COMPLETE / FAIL ===

func can_accept(quest_id: StringName) -> bool:
	if active_quests.has(quest_id) or completed_quests.has(quest_id):
		return false
	var q: Dictionary = QuestDatabase.get_quest(quest_id)
	if q.is_empty():
		return false
	# Iteration lock check
	var current_iter: int = _get_current_iteration()
	if q.get("iter", 1) > current_iter:
		return false
	# Prerequisites
	for prereq in q.get("prereq", []):
		if not completed_quests.has(prereq):
			return false
	return true


func accept(quest_id: StringName) -> bool:
	if not can_accept(quest_id):
		return false
	active_quests[quest_id] = {
		"progress": {},
		"accepted_day": _get_current_day(),
	}
	quest_accepted.emit(quest_id)
	return true


func _check_complete(quest_id: StringName) -> void:
	var entry: Dictionary = active_quests.get(quest_id)
	if entry == null:
		return
	var q: Dictionary = QuestDatabase.get_quest(quest_id)
	if q.is_empty():
		return
	var objectives: Array = q.get("objectives", [])
	var progress: Dictionary = entry["progress"]
	for i in objectives.size():
		var obj: Dictionary = objectives[i]
		var current: int = progress.get(i, 0)
		var target: int = obj.get("count", 1)
		if current < target:
			return
	# All objectives complete
	complete(quest_id)


func complete(quest_id: StringName) -> void:
	if not active_quests.has(quest_id):
		return
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	if pinned_quests.has(quest_id):
		pinned_quests.erase(quest_id)
	_grant_rewards(quest_id)
	quest_completed.emit(quest_id)


func fail(quest_id: StringName) -> void:
	if not active_quests.has(quest_id):
		return
	active_quests.erase(quest_id)
	failed_quests.append(quest_id)
	if pinned_quests.has(quest_id):
		pinned_quests.erase(quest_id)
	quest_failed.emit(quest_id)


func abandon(quest_id: StringName) -> void:
	if not active_quests.has(quest_id):
		return
	active_quests.erase(quest_id)
	if pinned_quests.has(quest_id):
		pinned_quests.erase(quest_id)


# === REWARDS ===

func _grant_rewards(quest_id: StringName) -> void:
	var q: Dictionary = QuestDatabase.get_quest(quest_id)
	var rewards: Dictionary = q.get("rewards", {})
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("quest_rewards_granted"):
			bus.quest_rewards_granted.emit(quest_id, rewards)


# === PROGRESS HOOKS ===

func _bump_objective_for_active(obj_type: StringName, target: StringName, amount: int = 1) -> void:
	for quest_id: StringName in active_quests.keys():
		var entry: Dictionary = active_quests[quest_id]
		var q: Dictionary = QuestDatabase.get_quest(quest_id)
		if q.is_empty():
			continue
		var objectives: Array = q.get("objectives", [])
		for i in objectives.size():
			var obj: Dictionary = objectives[i]
			if obj.get("type", &"") != obj_type:
				continue
			var obj_target: StringName = obj.get("target", &"")
			if obj_target != target and obj_target != &"any":
				continue
			var progress: Dictionary = entry["progress"]
			var current: int = progress.get(i, 0) + amount
			progress[i] = current
			var target_count: int = obj.get("count", 1)
			quest_progress_updated.emit(quest_id, i, current, target_count)
		_check_complete(quest_id)


func _on_enemy_killed(enemy: Node) -> void:
	if enemy == null:
		return
	var enemy_tag: StringName = enemy.get("enemy_tag") if enemy.has_method("get") and enemy.get("enemy_tag") != null else &""
	if enemy_tag != &"":
		_bump_objective_for_active(&"kill", enemy_tag)


func _on_item_picked_up(item: Resource) -> void:
	if item == null:
		return
	var item_id: StringName = StringName(item.get("item_id"))
	_bump_objective_for_active(&"gather", item_id)


func _on_npc_talked_to(npc_id: StringName) -> void:
	_bump_objective_for_active(&"talk", npc_id)


func _on_location_entered(location_id: StringName) -> void:
	_bump_objective_for_active(&"explore", location_id)


func _on_boss_defeated(boss_id: StringName) -> void:
	_bump_objective_for_active(&"defeat_boss", boss_id)


func _on_fish_caught(fish_id: StringName) -> void:
	_bump_objective_for_active(&"fish", fish_id)
	_bump_objective_for_active(&"fish", &"any")


# === PINNING ===

func pin(quest_id: StringName) -> bool:
	if pinned_quests.size() >= MAX_PINNED:
		return false
	if pinned_quests.has(quest_id):
		return false
	if not active_quests.has(quest_id):
		return false
	pinned_quests.append(quest_id)
	quest_pinned.emit(quest_id)
	return true


func unpin(quest_id: StringName) -> void:
	if pinned_quests.has(quest_id):
		pinned_quests.erase(quest_id)
		quest_unpinned.emit(quest_id)


# === DAILY ===

func _on_day_advanced(new_day: int) -> void:
	# Reset daily quests
	if last_daily_reset_day != new_day:
		_generate_daily_quests()
		last_daily_reset_day = new_day
	# Check for time-limited quest failures
	for quest_id: StringName in active_quests.keys():
		var q: Dictionary = QuestDatabase.get_quest(quest_id)
		var time_limit: int = q.get("time_limit_days", -1)
		if time_limit > 0:
			var entry: Dictionary = active_quests[quest_id]
			var elapsed: int = new_day - entry.get("accepted_day", new_day)
			if elapsed > time_limit:
				fail(quest_id)


func _generate_daily_quests() -> void:
	daily_quests_today.clear()
	var templates: Array = QuestDatabase.get_daily_templates()
	templates.shuffle()
	for i in range(min(3, templates.size())):
		daily_quests_today.append(templates[i].duplicate())


# === HELPERS ===

func _get_current_day() -> int:
	if Engine.has_singleton("IterationManager") or has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method("get_current_day"):
			return im.get_current_day()
	return 0


func _get_current_iteration() -> int:
	if Engine.has_singleton("IterationManager") or has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method("get_current_iteration"):
			return im.get_current_iteration()
	return 1


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var active_str: Dictionary = {}
	for k: StringName in active_quests.keys():
		active_str[String(k)] = active_quests[k]
	return {
		"active_quests": active_str,
		"completed_quests": completed_quests.map(func(s: StringName) -> String: return String(s)),
		"failed_quests": failed_quests.map(func(s: StringName) -> String: return String(s)),
		"pinned_quests": pinned_quests.map(func(s: StringName) -> String: return String(s)),
		"daily_quests_today": daily_quests_today,
		"daily_streak": daily_streak,
		"last_daily_reset_day": last_daily_reset_day,
	}


func from_save_data(data: Dictionary) -> void:
	active_quests.clear()
	for k in data.get("active_quests", {}).keys():
		active_quests[StringName(k)] = data["active_quests"][k]
	completed_quests.clear()
	for s in data.get("completed_quests", []):
		completed_quests.append(StringName(s))
	failed_quests.clear()
	for s in data.get("failed_quests", []):
		failed_quests.append(StringName(s))
	pinned_quests.clear()
	for s in data.get("pinned_quests", []):
		pinned_quests.append(StringName(s))
	daily_quests_today = data.get("daily_quests_today", [])
	daily_streak = data.get("daily_streak", 0)
	last_daily_reset_day = data.get("last_daily_reset_day", -1)
