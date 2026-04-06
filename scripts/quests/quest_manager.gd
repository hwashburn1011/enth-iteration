class_name QuestManagerClass
extends Node
## Tracks active and completed quests. Registered as autoload.

var active_quests: Array[Resource] = []
var completed_quests: Array[String] = []


func add_quest(quest: Resource) -> void:
	if _find_quest(quest.quest_id) != null:
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
