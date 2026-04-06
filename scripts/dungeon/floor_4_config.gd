class_name Floor4Config
extends RefCounted
## Configures rooms for Floor 4 — Corrupted Cache. Status effects on enemies.

static func configure_room(room: Node3D, room_index: int) -> void:
	var spawner: Node = room.get_node_or_null("EnemySpawner") as Node

	match room_index:
		0:  # Corridor Ambush — 3 Glitch Bugs + 2 Rogue Processes
			if spawner:
				spawner.enemy_types = ["glitch_bug", "glitch_bug", "glitch_bug", "rogue_process", "rogue_process"]
				spawner.spawn_count = 5
		1:  # Pillars — 3 Memory Leaks + 2 Glitch Bugs (Memory Leaks apply Corrupted)
			if spawner:
				spawner.enemy_types = ["memory_leak", "memory_leak", "memory_leak", "glitch_bug", "glitch_bug"]
				spawner.spawn_count = 5
		3:  # Open Arena — Wave encounter
			if spawner:
				var wave1: Resource = load("res://scripts/systems/spawn_wave.gd").new()
				wave1.enemy_types = ["glitch_bug"]
				wave1.spawn_count = 3
				var wave2: Resource = load("res://scripts/systems/spawn_wave.gd").new()
				wave2.enemy_types = ["rogue_process", "rogue_process", "memory_leak"]
				wave2.spawn_count = 3
				spawner.waves = [wave1, wave2]
		4:  # Elevated — 2 of each (6 total)
			if spawner:
				spawner.enemy_types = ["glitch_bug", "glitch_bug", "memory_leak", "memory_leak", "rogue_process", "rogue_process"]
				spawner.spawn_count = 6
