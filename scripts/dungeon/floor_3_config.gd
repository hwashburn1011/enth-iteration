class_name Floor3Config
extends RefCounted
## Configures room spawners for Floor 3 — Archive Subnet.

static func configure_room(room: Node3D, room_index: int) -> void:
	var spawner: Node = room.get_node_or_null("EnemySpawner") as Node

	match room_index:
		0:  # Open Arena — Phase 3 #21: 2 Memory Leaks + 1 Glitch Bug.
			# Pre-T21 this room was 3x memory leak — pure ranged kite,
			# trivially handled by walking sideways. Adding the bug
			# forces the player to commit to a direction (close the
			# bug, expose to leak fire) on the floor-3 opener.
			if spawner:
				spawner.enemy_types = ["memory_leak", "memory_leak", "glitch_bug"]
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
		5:  # Mid-floor mini-boss room (Phase 2 #15) — single beefed
			# Memory Leak as the floor 3 set piece. Distinct from the
			# floor 2 violet rogue elite (cyan-amber here) and from
			# the final-floor Corrupted Compiler (different host enemy
			# entirely). Spawn count is 2: the mini-boss + one regular
			# memory_leak so the player can't just kite forever.
			if spawner:
				spawner.enemy_types = ["memory_leak", "memory_leak"]
				spawner.spawn_count = 2
				_setup_miniboss_after_spawn(spawner)
		6:  # Elevated — 2 Rogue Processes + 2 Memory Leaks
			if spawner:
				spawner.enemy_types = ["rogue_process", "memory_leak"]
				spawner.spawn_count = 4


## Phase 2 #15 — mid-floor mini-boss helpers. Defers a buff pass
## one frame after the spawner runs so the regular spawn flow
## stays untouched. Modeled on floor_2_config's elite system but
## with a different host enemy and a distinct visual tint so it
## doesn't read like a recolor of the floor 2 elite.
static func _setup_miniboss_after_spawn(spawner: Node) -> void:
	if spawner.is_inside_tree():
		spawner.get_tree().process_frame.connect(
			func() -> void: _buff_miniboss(spawner), CONNECT_ONE_SHOT
		)


static func _buff_miniboss(_spawner: Node) -> void:
	## Find an unbuffed memory leak in the scene and promote it to
	## mini-boss status: 3.5x HP, 1.6x scale, cyan-amber emission tint.
	## The capture_pre_variant_baseline() + absolute scale assignment
	## pattern is the same idempotency safety net floor_2_config uses
	## (gameplay/T46 fixed compounding buff bugs there).
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	for node: Node in tree.get_nodes_in_group(&"enemies"):
		var script: Script = node.get_script() as Script
		if script == null or script.get_global_name() != "MemoryLeak":
			continue
		var miniboss: CharacterBody3D = node
		if miniboss.has_meta(&"_floor3_miniboss"):
			continue
		miniboss.capture_pre_variant_baseline()
		miniboss.set_meta(&"_floor3_miniboss", true)
		var base_hp: float = miniboss._pre_variant_max_health
		miniboss.health_component.base_max_health = base_hp * 3.5
		miniboss.health_component.max_health = base_hp * 3.5
		miniboss.health_component.current_health = miniboss.health_component.max_health
		miniboss.model.scale = miniboss._pre_variant_model_scale * 1.6
		# Cyan-amber tint reads as "leaking heat" — distinct from the
		# floor 2 violet elite and from the boss arena's deep red.
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.20, 0.55, 0.85)
		mat.emission_enabled = true
		mat.emission = Color(0.95, 0.65, 0.15)
		mat.emission_energy_multiplier = 1.4
		mat.metallic = 0.40
		mat.roughness = 0.35
		for mesh: MeshInstance3D in miniboss.get_mesh_instances():
			mesh.material_override = mat
		return
