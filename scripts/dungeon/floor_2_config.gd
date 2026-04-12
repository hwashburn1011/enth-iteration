class_name Floor2Config
extends RefCounted
## Configures room spawners for Floor 2 — Data Sector Alpha.
## Called by FloorManager after room instantiation.

static func configure_room(room: Node3D, room_index: int) -> void:
	var spawner: Node = room.get_node_or_null("EnemySpawner") as Node
	if spawner == null:
		return

	match room_index:
		0:  # Open Arena — 3 Glitch Bugs
			spawner.enemy_types = ["glitch_bug"]
			spawner.spawn_count = 3
		2:  # Pillars — 2 Glitch Bugs + 2 Memory Leaks
			spawner.enemy_types = ["glitch_bug", "memory_leak"]
			spawner.spawn_count = 4
		3:  # Corridor Ambush — 2 Rogue Processes
			spawner.enemy_types = ["rogue_process"]
			spawner.spawn_count = 2
		4:  # Pillars (encore) — mixed swarm before the floor finale
			spawner.enemy_types = ["glitch_bug", "rogue_process", "memory_leak"]
			spawner.spawn_count = 5
		5:  # Elevated — Elite encounter (floor finale)
			spawner.enemy_types = ["rogue_process", "memory_leak"]
			spawner.spawn_count = 2
			# Post-spawn: buff the first enemy as elite
			spawner.all_enemies_defeated.connect(func() -> void: pass)  # placeholder
			_setup_elite_after_spawn(spawner)


static func _setup_elite_after_spawn(spawner: Node) -> void:
	# We need to buff the elite after spawn_wave is called.
	# Connect to the spawner's tree to do this after spawn.
	# Since spawn_wave is called by FloorManager/CombatRoomBase,
	# we use call_deferred to run after the current frame.
	if spawner.is_inside_tree():
		spawner.get_tree().process_frame.connect(
			func() -> void: _buff_elite(spawner), CONNECT_ONE_SHOT
		)


static func _buff_elite(_spawner: Node) -> void:
	# Find an unbuffed rogue process in the scene and buff it as elite.
	# Skip any pool-reused instance that's still flagged as elite from a
	# previous iteration — the meta is cleared on reset() but as a safety
	# net we also use capture_pre_variant_baseline + absolute scale assignment
	# so the buff is idempotent even if it does fire on a buffed instance.
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	for node: Node in tree.get_nodes_in_group(&"enemies"):
		if node.get_script().get_global_name() != "RogueProcess":
			continue
		var elite: CharacterBody3D = node
		if elite.has_meta(&"_floor2_elite"):
			continue  # Already an elite from this round — try the next candidate
		# Snapshot the un-buffed baseline FIRST so reset() can restore it on
		# pool return; without this the buff compounds across iterations.
		elite.capture_pre_variant_baseline()
		elite.set_meta(&"_floor2_elite", true)
		# Compute from the captured baseline rather than current values so
		# this works even if the snapshot was already stale.
		var base_hp: float = elite._pre_variant_max_health
		elite.health_component.base_max_health = base_hp * 3.0
		elite.health_component.max_health = base_hp * 3.0
		elite.health_component.current_health = elite.health_component.max_health
		elite.model.scale = elite._pre_variant_model_scale * 1.5
		# Visual tint — walk every mesh in the model rather than casting
		# get_child(0), which fails silently for GLB-wrapped enemies (the
		# first child is a Node3D wrapper, not a MeshInstance3D).
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.6, 0.2, 0.9)
		mat.emission_enabled = true
		mat.emission = Color(0.5, 0.1, 0.8)
		mat.emission_energy_multiplier = 1.0
		for mesh: MeshInstance3D in elite.get_mesh_instances():
			mesh.material_override = mat
		return
