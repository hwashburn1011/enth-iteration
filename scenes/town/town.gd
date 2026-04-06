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
		var player: Player = player_scene.instantiate() as Player
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
				var npc_base: NPCBase = npc as NPCBase
				var arrival_data: DialogueData = _get_arrival_dialogue(npc_id)
				if arrival_data:
					npc_base.dialogue_resource = arrival_data
				GameManager.acknowledge_npc_arrival(npc_id)


func _get_arrival_dialogue(npc_id: String) -> DialogueData:
	var path: String = "res://data/dialogue/%s_arrival.tres" % npc_id
	if ResourceLoader.exists(path):
		return load(path) as DialogueData
	return null


func _get_npc_slot(npc_id: String) -> Marker3D:
	match npc_id:
		"ai_sage":
			return npc_slots.get_node_or_null("AISageSlot") as Marker3D
		"cache_sprite":
			return npc_slots.get_node_or_null("CacheSpriteSlot") as Marker3D
		_:
			return npc_slots.get_node_or_null(npc_id + "_slot") as Marker3D
