class_name Floor5Config
extends RefCounted
## Configures rooms for Floor 5 — Core Process Chamber (Boss Floor).

static func configure_room(room: Node3D, room_index: int) -> void:
	match room_index:
		1:  # Story Room — set AI Sage NPC
			if (room.has_method(&"get_entry_point") and room.get(&"npc_id") != null):
				var sage_scene: PackedScene = load("res://scenes/entities/npcs/AISage.tscn") as PackedScene
				(room as Node3D).npc_scene = sage_scene
				(room as Node3D).npc_id = &"ai_sage"
		3:  # Boss Arena — spawn the Corrupted Compiler boss
			var spawner: Node = room.get_node_or_null("EnemySpawner") as Node
			if spawner:
				spawner.enemy_types = ["corrupted_compiler"]
				spawner.spawn_count = 1
