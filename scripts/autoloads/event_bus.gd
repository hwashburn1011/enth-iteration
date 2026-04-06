class_name EventBusClass
extends Node
## Global signal hub — all cross-system events route through here.

# Game state
signal game_state_changed(old_state: int, new_state: int)
signal game_paused()
signal game_unpaused()

# Scene management
signal scene_changing()
signal scene_changed(path: String)

# Player
signal player_dashed(from_position: Vector3, to_position: Vector3)

# Combat
signal enemy_defeated(enemy_type: StringName, position: Vector3, loot_table: Resource)
signal damage_dealt(amount: int, source: Node, target: Node, damage_type: StringName)
signal player_died(position: Vector3)

# Death & Respawn
signal item_degradation_triggered()

# Items
signal item_collected(item: Resource)

# Dungeon
signal portal_reached(portal_id: StringName)
signal floor_completed(floor_number: int)
signal portal_used()
signal returned_to_town()

# Iteration
signal iteration_started(iteration_number: int)
signal iteration_reset()

# NPCs
signal npc_recruited(npc_id: StringName)
signal dialogue_started(npc_id: StringName)
signal dialogue_ended()

# Quests
signal quest_updated(quest_id: StringName, status: StringName)
