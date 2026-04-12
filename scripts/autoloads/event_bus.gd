class_name EventBusClass
extends Node
## Global signal hub — all cross-system events route through here.
## All signals are emitted by external modules via the EventBus autoload, so the
## parser cannot detect their usage. Each signal is annotated to suppress the
## UNUSED_SIGNAL warning.

# Game state
@warning_ignore("unused_signal")
signal game_state_changed(old_state: int, new_state: int)
@warning_ignore("unused_signal")
signal game_paused()
@warning_ignore("unused_signal")
signal game_unpaused()
@warning_ignore("unused_signal")
signal demo_completed()

# Save
@warning_ignore("unused_signal")
signal game_saved()
@warning_ignore("unused_signal")
signal game_loaded()

# Scene management
@warning_ignore("unused_signal")
signal scene_changing()
@warning_ignore("unused_signal")
signal scene_changed(path: String)

# Player
@warning_ignore("unused_signal")
signal player_dashed(from_position: Vector3, to_position: Vector3)
@warning_ignore("unused_signal")
signal player_leveled_up(new_level: int)

# Combat
@warning_ignore("unused_signal")
signal enemy_defeated(enemy_type: StringName, position: Vector3, loot_table: Resource)
@warning_ignore("unused_signal")
signal boss_defeated(boss_id: StringName, position: Vector3, loot_table: Resource)
@warning_ignore("unused_signal")
signal damage_dealt(amount: int, source: Node, target: Node, damage_type: StringName)
@warning_ignore("unused_signal")
signal player_died(position: Vector3)

# Death & Respawn
@warning_ignore("unused_signal")
signal item_degradation_triggered()

# Items
@warning_ignore("unused_signal")
signal item_collected(item: Resource)

# Dungeon
@warning_ignore("unused_signal")
signal portal_reached(portal_id: StringName)
@warning_ignore("unused_signal")
signal floor_completed(floor_number: int)
@warning_ignore("unused_signal")
signal portal_used()
@warning_ignore("unused_signal")
signal returned_to_town()
@warning_ignore("unused_signal")
signal dungeon_entered()

# Iteration
@warning_ignore("unused_signal")
signal iteration_started(iteration_number: int)
@warning_ignore("unused_signal")
signal iteration_reset()

# NPCs
@warning_ignore("unused_signal")
signal npc_recruited(npc_id: StringName)
@warning_ignore("unused_signal")
signal npc_talked(npc_id: StringName)
@warning_ignore("unused_signal")
signal affinity_changed(npc_id: StringName, new_value: int)
@warning_ignore("unused_signal")
signal dialogue_started(npc_id: StringName)
@warning_ignore("unused_signal")
signal dialogue_ended()

# Quests
@warning_ignore("unused_signal")
signal quest_updated(quest_id: StringName, status: StringName)
