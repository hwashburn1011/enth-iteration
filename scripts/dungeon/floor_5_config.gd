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
		3:  # Boss Arena — configure boss spawner as placeholder boss
			var spawner: Node = room.get_node_or_null("EnemySpawner") as Node
			if spawner:
				# Placeholder: use a heavily buffed Rogue Process until Story 9.1 creates the real boss
				spawner.enemy_types = ["rogue_process"]
				spawner.spawn_count = 1
			# Buff the boss after spawn
			if room.is_inside_tree():
				room.get_tree().process_frame.connect(
					func() -> void: _buff_boss(), CONNECT_ONE_SHOT
				)


static func _buff_boss() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	for node: Node in tree.get_nodes_in_group(&"enemies"):
		if node.is_in_group(&"enemies"):
			var boss: CharacterBody3D = node as CharacterBody3D
			boss.health_component.max_health = 200.0
			boss.health_component.current_health = 200.0
			boss.stats_component.base_processing = 15.0
			boss.stats_component.base_integrity = 8.0
			boss.model.scale = Vector3(2.0, 2.0, 2.0)
			var mesh: MeshInstance3D = boss.model.get_child(0) as MeshInstance3D
			if mesh:
				var mat: StandardMaterial3D = StandardMaterial3D.new()
				mat.albedo_color = Color(0.8, 0.2, 0.1)
				mat.emission_enabled = true
				mat.emission = Color(0.9, 0.1, 0.0)
				mat.emission_energy_multiplier = 1.5
				mesh.material_override = mat
			return
