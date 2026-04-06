class_name QuestData
extends Resource
## Definition of a quest with objectives and category.

@export var quest_id: String = ""
@export var quest_name: String = ""
@export var description: String = ""
@export var category: String = "story"  # "story", "character", "discovery"
@export var objectives: Array[Resource] = []
var is_completed: bool = false
