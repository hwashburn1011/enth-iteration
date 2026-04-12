class_name QuestObjective
extends Resource
## A single trackable objective within a quest.
##
## event_name + event_filter let QuestManager auto-progress objectives off
## EventBus signals. Leave event_name empty for manual-only objectives.

@export var objective_text: String = ""
@export var target_count: int = 1
## EventBus signal name that progresses this objective (e.g. &"enemy_defeated").
@export var event_name: StringName = &""
## Optional filter against the first signal arg as a string. Empty matches any.
@export var event_filter: String = ""
var current_count: int = 0
