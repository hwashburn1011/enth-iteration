class_name Floor3Config
extends RefCounted
## Configures room spawners for Floor 3 — Archive Subnet.

static func configure_room(room: Node3D, room_index: int) -> void:
	var spawner: Node = room.get_node_or_null("EnemySpawner") as Node

	match room_index:
		0:  # Open Arena — 3 Memory Leaks
			if spawner:
				spawner.enemy_types = ["memory_leak"]
				spawner.spawn_count = 3
		2:  # Pillars — 4 Glitch Bugs + 1 Memory Leak
			if spawner:
				spawner.enemy_types = ["glitch_bug", "glitch_bug", "glitch_bug", "glitch_bug", "memory_leak"]
				spawner.spawn_count = 5
		3:  # Corridor Ambush (NEW) — 4 Glitch Bugs + 2 Rogue Processes
			if spawner:
				spawner.enemy_types = ["glitch_bug", "rogue_process"]
				spawner.spawn_count = 6
		4:  # Story Room — set NPC id for Cache Sprite
			if (room.has_method(&"get_entry_point") and room.get(&"npc_id") != null):
				(room as Node3D).npc_id = &"cache_sprite"
		6:  # Elevated — 2 Rogue Processes + 2 Memory Leaks
			if spawner:
				spawner.enemy_types = ["rogue_process", "memory_leak"]
				spawner.spawn_count = 4
