class_name QuestManagerClass
extends Node
## Tracks active and completed quests. Registered as autoload.
##
## Auto-progresses objectives by listening to EventBus signals. Each
## QuestObjective declares an event_name + optional event_filter; the
## dispatcher walks active quests on every relevant signal and bumps
## any matching objectives by 1.

var active_quests: Array[Resource] = []
var completed_quests: Array[String] = []


func _ready() -> void:
	# Subscribe once to every signal we know how to map onto an objective.
	# Keep this list curated — adding a new objective type means adding both
	# a signal connection here and an event_name on the QuestObjective.
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.floor_completed.connect(_on_floor_completed)
	EventBus.dungeon_entered.connect(_on_dungeon_entered)
	EventBus.returned_to_town.connect(_on_returned_to_town)
	EventBus.npc_talked.connect(_on_npc_talked)
	EventBus.npc_recruited.connect(_on_npc_recruited)
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.item_collected.connect(_on_item_collected)


func add_quest(quest: Resource) -> void:
	if _find_quest(quest.quest_id) != null:
		return
	if quest.quest_id in completed_quests:
		return
	active_quests.append(quest)
	EventBus.quest_updated.emit(StringName(quest.quest_id), &"added")


func update_objective(quest_id: String, objective_index: int, amount: int = 1) -> void:
	var quest: Resource = _find_quest(quest_id)
	if quest == null or quest.is_completed:
		return
	if objective_index >= quest.objectives.size():
		return
	var obj: Resource = quest.objectives[objective_index]
	obj.current_count = mini(obj.current_count + amount, obj.target_count)
	EventBus.quest_updated.emit(StringName(quest_id), &"progress")
	_check_completion(quest)


func _check_completion(quest: Resource) -> void:
	for obj: Variant in quest.objectives:
		if obj.current_count < obj.target_count:
			return
	quest.is_completed = true
	completed_quests.append(quest.quest_id)
	EventBus.quest_updated.emit(StringName(quest.quest_id), &"completed")


func _find_quest(quest_id: String) -> Resource:
	for q: Resource in active_quests:
		if q.quest_id == quest_id:
			return q
	return null


func get_quests_by_category(category: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for q: Resource in active_quests:
		if q.category == category:
			result.append(q)
	return result


## Generic dispatcher: walk active quests, bump any objective whose
## event_name matches and whose event_filter matches (or is empty).
func _progress_event(event_name: StringName, filter_value: String) -> void:
	for q: Resource in active_quests:
		if q.is_completed:
			continue
		for i: int in range(q.objectives.size()):
			var obj: Resource = q.objectives[i]
			if obj.event_name != event_name:
				continue
			if obj.event_filter != "" and obj.event_filter != filter_value:
				continue
			update_objective(q.quest_id, i, 1)


# --- Signal handlers (thin adapters to _progress_event) ---

func _on_enemy_defeated(enemy_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	_progress_event(&"enemy_defeated", String(enemy_type))


func _on_boss_defeated(boss_id: StringName, _pos: Vector3, _loot: Resource) -> void:
	_progress_event(&"boss_defeated", String(boss_id))


func _on_floor_completed(floor_number: int) -> void:
	_progress_event(&"floor_completed", str(floor_number))


func _on_dungeon_entered() -> void:
	_progress_event(&"dungeon_entered", "")


func _on_returned_to_town() -> void:
	_progress_event(&"returned_to_town", "")


func _on_npc_talked(npc_id: StringName) -> void:
	_progress_event(&"npc_talked", String(npc_id))


func _on_npc_recruited(npc_id: StringName) -> void:
	_progress_event(&"npc_recruited", String(npc_id))


func _on_dialogue_started(npc_id: StringName) -> void:
	_progress_event(&"dialogue_started", String(npc_id))


func _on_item_collected(item: Resource) -> void:
	var item_id: String = ""
	if item != null and "item_id" in item:
		item_id = String(item.item_id)
	_progress_event(&"item_collected", item_id)
