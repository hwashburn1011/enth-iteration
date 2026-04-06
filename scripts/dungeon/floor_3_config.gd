class_name Floor3Config
extends RefCounted
## Configures room spawners for Floor 3 — Archive Subnet.

static func configure_room(room: Node3D, room_index: int) -> void:
	var spawner: EnemySpawner = room.get_node_or_null("EnemySpawner") as EnemySpawner

	match room_index:
		0:  # Open Arena — 3 Memory Leaks
			if spawner:
				spawner.enemy_types = ["memory_leak"]
				spawner.spawn_count = 3
		2:  # Pillars — 4 Glitch Bugs + 1 Memory Leak
			if spawner:
				spawner.enemy_types = ["glitch_bug", "glitch_bug", "glitch_bug", "glitch_bug", "memory_leak"]
				spawner.spawn_count = 5
		3:  # Story Room — set NPC id for Cache Sprite
			if room is StoryRoom:
				(room as StoryRoom).npc_id = &"cache_sprite"
		5:  # Elevated — 2 Rogue Processes + 2 Memory Leaks
			if spawner:
				spawner.enemy_types = ["rogue_process", "memory_leak"]
				spawner.spawn_count = 4
