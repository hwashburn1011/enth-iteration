extends "res://scenes/entities/npcs/npc_base.gd"
## Villager NPC. Loads dialogue based on iteration + affinity tier.
## Post-V1 B14: 3+ dialogue sets per NPC based on iteration + affinity.

## Dialogue resources keyed by condition. Falls back to greeting.
var _dialogue_by_tier: Dictionary = {}


func _ready() -> void:
	if dialogue_resource == null:
		dialogue_resource = load("res://data/dialogue/villager_greeting.tres") as Resource
	# Post-V1 B14: pre-load tier-specific dialogue if it exists
	var ally_path: String = "res://data/dialogue/villager_ally.tres"
	if ResourceLoader.exists(ally_path):
		_dialogue_by_tier["Ally"] = load(ally_path) as Resource
	var trusted_path: String = "res://data/dialogue/villager_trusted.tres"
	if ResourceLoader.exists(trusted_path):
		_dialogue_by_tier["Trusted"] = load(trusted_path) as Resource
	super._ready()


func _start_conversation() -> void:
	# Post-V1 B14: pick dialogue based on affinity tier
	var tier: String = GameManager.get_affinity_tier(npc_id)
	if _dialogue_by_tier.has(tier):
		dialogue_resource = _dialogue_by_tier[tier]
	super._start_conversation()
