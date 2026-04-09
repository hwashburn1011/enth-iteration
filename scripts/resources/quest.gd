class_name Quest
extends Resource

## Single quest definition. Loaded from data/quests/.

@export var quest_id: StringName = &""
@export var title: String = ""
@export var description: String = ""

## Type: main / side / daily / hidden / faction
@export var quest_type: StringName = &"side"

## Iteration restriction (player must be at this iteration or higher)
@export var iteration_lock: int = 1

## NPC who gives this quest (empty for hidden/explore-triggered)
@export var giver_npc_id: StringName = &""

## Prerequisite quest IDs (all must be completed)
@export var prerequisites: Array[StringName] = []

## Objectives — array of dictionaries
## { type: StringName, target: StringName, count: int, location: StringName }
@export var objectives: Array[Dictionary] = []

## Rewards
@export var reward_xp: int = 0
@export var reward_gold: int = 0
@export var reward_items: Dictionary = {}      ## item_id -> count
@export var reward_faction_rep: Dictionary = {}  ## faction_id -> amount
@export var reward_story_flags: Array[StringName] = []
@export var reward_module_unlocks: Array[StringName] = []
@export var reward_recipe_unlocks: Array[StringName] = []
@export var reward_affinity: Dictionary = {}   ## npc_id -> affinity gained

## Failure conditions
@export var time_limit_days: int = -1   ## -1 = no time limit
@export var fail_on_npc_damaged: StringName = &""

## Lore flavor for the journal
@export var journal_lore: String = ""


func get_objective_count() -> int:
	return objectives.size()


func get_total_progress(progress_dict: Dictionary) -> float:
	## Returns 0.0 - 1.0 progress across all objectives
	if objectives.is_empty():
		return 0.0
	var total: float = 0.0
	for i in objectives.size():
		var obj: Dictionary = objectives[i]
		var current: int = progress_dict.get(i, 0)
		var target: int = obj.get("count", 1)
		total += min(1.0, float(current) / float(target))
	return total / float(objectives.size())


func is_complete(progress_dict: Dictionary) -> bool:
	for i in objectives.size():
		var obj: Dictionary = objectives[i]
		var current: int = progress_dict.get(i, 0)
		var target: int = obj.get("count", 1)
		if current < target:
			return false
	return true
