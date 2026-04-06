extends Node3D
## Town hub — persistent home base with NPC slots and spawn points.

const NPC_SCENES: Dictionary = {
	"ai_sage": "res://scenes/entities/npcs/AISageTown.tscn",
	"cache_sprite": "res://scenes/entities/npcs/CacheSprite.tscn",
}

## NPCs that are always present in town (no recruitment needed)
const ALWAYS_PRESENT: Array[String] = ["ai_sage"]

@onready var player_spawn_point: Marker3D = %PlayerSpawnPoint
@onready var portal_return_point: Marker3D = %PortalReturnPoint
@onready var npc_slots: Node3D = %NPCSlots


func _ready() -> void:
	portal_return_point.add_to_group(&"portal_return_point")
	player_spawn_point.add_to_group(&"respawn_point")

	# Spawn player
	var player_scene: PackedScene = load("res://scenes/entities/player/Player.tscn") as PackedScene
	if player_scene:
		var player: CharacterBody3D = player_scene.instantiate() as CharacterBody3D
		add_child(player)

		# Determine spawn position based on entry type
		if GameManager.has_meta(&"town_entry_type") and GameManager.get_meta(&"town_entry_type") == "portal_return":
			player.global_position = portal_return_point.global_position
			GameManager.remove_meta(&"town_entry_type")
		else:
			player.global_position = player_spawn_point.global_position

	# Spawn camera
	var cam_script: GDScript = load("res://scripts/components/isometric_camera.gd") as GDScript
	var camera: Camera3D = Camera3D.new()
	camera.set_script(cam_script)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 10.0
	camera.rotation_degrees = Vector3(-60.0, -45.0, 0.0)
	add_child(camera)
	# Set target after player is in tree
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if players.size() > 0:
		camera.set(&"target", players[0])

	GameManager.set_state(GameManager.GameState.PLAYING)
	_populate_npcs()
	_update_town_state()
	# Narrative: demo end check after returning from boss
	if GameManager.should_trigger_demo_end():
		# Give player a moment to look around, then trigger
		_setup_demo_end_trigger()
	# Narrative: auto-trigger AI Sage on first visit
	elif GameManager.first_run and not GameManager.first_sage_dialogue_complete:
		_auto_trigger_sage_dialogue.call_deferred()


func _populate_npcs() -> void:
	for npc_id: String in NPC_SCENES:
		var should_spawn: bool = npc_id in ALWAYS_PRESENT
		if not should_spawn and GameManager.is_npc_recruited(npc_id):
			should_spawn = true
		if not should_spawn:
			continue
		var slot: Marker3D = _get_npc_slot(npc_id)
		if slot == null:
			continue
		var scene: PackedScene = load(NPC_SCENES[npc_id]) as PackedScene
		if scene:
			var npc: Node3D = scene.instantiate() as Node3D
			npc.global_position = slot.global_position
			add_child(npc)
			# Trigger arrival dialogue for newly recruited NPCs
			if GameManager.is_npc_newly_arrived(npc_id) and npc is NPCBase:
				var npc_base: CharacterBody3D = npc as CharacterBody3D
				var arrival_data: Resource = _get_arrival_dialogue(npc_id)
				if arrival_data:
					npc_base.dialogue_resource = arrival_data
				GameManager.acknowledge_npc_arrival(npc_id)


func _get_arrival_dialogue(npc_id: String) -> Resource:
	var path: String = "res://data/dialogue/%s_arrival.tres" % npc_id
	if ResourceLoader.exists(path):
		return load(path) as Resource
	return null


func _get_npc_slot(npc_id: String) -> Marker3D:
	match npc_id:
		"ai_sage":
			return npc_slots.get_node_or_null("AISageSlot") as Marker3D
		"cache_sprite":
			return npc_slots.get_node_or_null("CacheSpriteSlot") as Marker3D
		_:
			return npc_slots.get_node_or_null(npc_id + "_slot") as Marker3D


func _update_town_state() -> void:
	var npc_count: int = GameManager.recruited_npcs.size()
	var expansion1: Node3D = get_node_or_null("TownExpansion1") as Node3D
	var expansion2: Node3D = get_node_or_null("TownExpansion2") as Node3D
	var expansion3: Node3D = get_node_or_null("TownExpansion3") as Node3D
	if expansion1:
		expansion1.visible = npc_count >= 1
	if expansion2:
		expansion2.visible = npc_count >= 2
	if expansion3:
		expansion3.visible = npc_count >= 3


func _auto_trigger_sage_dialogue() -> void:
	# Wait a moment for the scene to settle
	await get_tree().create_timer(2.0).timeout
	# Find the AI Sage NPC and start conversation
	for child: Node in get_children():
		if child is NPCBase and (child as CharacterBody3D).npc_id == "ai_sage":
			(child as CharacterBody3D)._start_conversation()
			return


func _setup_demo_end_trigger() -> void:
	# Create a trigger zone in town center — when player enters after boss, triggers demo end
	var trigger: Area3D = Area3D.new()
	trigger.collision_layer = 0
	trigger.collision_mask = 1
	var shape: CollisionShape3D = CollisionShape3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = 5.0
	shape.shape = sphere
	trigger.add_child(shape)
	trigger.global_position = Vector3.ZERO
	add_child(trigger)

	# Wait for player to talk to an NPC or enter the trigger after a delay
	await get_tree().create_timer(5.0).timeout
	if GameManager.should_trigger_demo_end():
		GameManager.trigger_demo_end()
