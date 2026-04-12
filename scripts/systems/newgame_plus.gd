class_name NewGamePlus
extends RefCounted
## Post-V1 Epic B #17 — New Game+ mode.
##
## After V1 demo end, the player can restart with passive bonuses carried
## over. NG+ flag is set on GameManager, and the passive node list from
## the previous run is preserved.

## Start NG+ by resetting progress but keeping passive bonuses.
static func start_ng_plus() -> void:
	# Preserve passive bonuses
	var players: Array[Node] = Engine.get_main_loop().root.get_tree().get_nodes_in_group(&"player")
	var passives: Array[String] = []
	if players.size() > 0 and &"unlocked_passives" in players[0]:
		passives = players[0].unlocked_passives.duplicate()

	# Reset game state
	GameManager.first_run = true
	GameManager.first_sage_dialogue_complete = false
	GameManager.returned_from_first_run = false
	GameManager.demo_ended = false
	GameManager.player_gold = int(GameManager.player_gold * 0.5)  # Keep half gold

	# Reset iteration
	if Engine.get_main_loop().root.has_node("/root/IterationManager"):
		var im: Node = Engine.get_main_loop().root.get_node("/root/IterationManager")
		if im.has_method(&"reset"):
			im.reset()

	# Tag NG+ and preserved passives
	GameManager.set_meta(&"ng_plus", true)
	GameManager.set_meta(&"ng_plus_passives", passives)

	# Load town
	GameManager.change_scene_to("res://scenes/town/Town.tscn")
