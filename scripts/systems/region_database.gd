class_name RegionDatabase
extends RefCounted

## Static catalog of all 18 world map regions with positions, layers,
## connections, and unlock conditions.

const REGIONS: Array = [
	# === TOWN (5 districts) ===
	{
		"id": &"town_residential",
		"name": "Residential District",
		"layer": &"town",
		"map_position": Vector2(-200, -100),
		"discovered_by_default": true,
		"connections": [&"town_market", &"town_commons"],
		"description": "Quiet streets where most of the town's residents live.",
	},
	{
		"id": &"town_market",
		"name": "Market District",
		"layer": &"town",
		"map_position": Vector2(0, -150),
		"discovered_by_default": true,
		"connections": [&"town_residential", &"town_commons", &"town_workshop"],
		"description": "Stalls, shops, and busy traders.",
	},
	{
		"id": &"town_commons",
		"name": "Commons District",
		"layer": &"town",
		"map_position": Vector2(0, 0),
		"discovered_by_default": true,
		"connections": [&"town_residential", &"town_market", &"town_workshop", &"town_docks"],
		"description": "The heart of town. Tavern, library, town square.",
	},
	{
		"id": &"town_workshop",
		"name": "Workshop District",
		"layer": &"town",
		"map_position": Vector2(200, -50),
		"discovered_by_default": true,
		"connections": [&"town_market", &"town_commons", &"wilderness_outskirts"],
		"description": "Forges, labs, the Reflection NPC.",
	},
	{
		"id": &"town_docks",
		"name": "Docks District",
		"layer": &"town",
		"map_position": Vector2(0, 200),
		"discovered_by_default": true,
		"connections": [&"town_commons", &"wilderness_river"],
		"description": "Water edge, fishing spots, exotic goods.",
	},

	# === WILDERNESS (8 sub-areas) ===
	{
		"id": &"wilderness_outskirts",
		"name": "Outskirts",
		"layer": &"wilderness",
		"map_position": Vector2(400, -50),
		"discovered_by_default": false,
		"connections": [&"town_workshop", &"wilderness_clearings", &"wilderness_cliffs"],
		"description": "Where town ends and the wilds begin.",
	},
	{
		"id": &"wilderness_clearings",
		"name": "Sunlit Clearings",
		"layer": &"wilderness",
		"map_position": Vector2(550, -150),
		"discovered_by_default": false,
		"connections": [&"wilderness_outskirts", &"wilderness_grove", &"dungeon_server_room_entrance"],
		"description": "Open glades with strange flora.",
	},
	{
		"id": &"wilderness_cliffs",
		"name": "Echoing Cliffs",
		"layer": &"wilderness",
		"map_position": Vector2(450, 50),
		"discovered_by_default": false,
		"connections": [&"wilderness_outskirts", &"wilderness_cave"],
		"description": "Stone faces overlooking the world.",
	},
	{
		"id": &"wilderness_grove",
		"name": "Forgotten Grove",
		"layer": &"wilderness",
		"map_position": Vector2(700, -200),
		"discovered_by_default": false,
		"connections": [&"wilderness_clearings"],
		"description": "Dense, old, secretive.",
	},
	{
		"id": &"wilderness_cave",
		"name": "Hidden Cave",
		"layer": &"wilderness",
		"map_position": Vector2(550, 150),
		"discovered_by_default": false,
		"connections": [&"wilderness_cliffs"],
		"description": "Where the Glitchers gather.",
	},
	{
		"id": &"wilderness_river",
		"name": "Slow River",
		"layer": &"wilderness",
		"map_position": Vector2(150, 350),
		"discovered_by_default": false,
		"connections": [&"town_docks", &"wilderness_lake"],
		"description": "Water flows from somewhere upstream.",
	},
	{
		"id": &"wilderness_lake",
		"name": "Mirror Lake",
		"layer": &"wilderness",
		"map_position": Vector2(350, 400),
		"discovered_by_default": false,
		"connections": [&"wilderness_river", &"dungeon_memory_vaults_entrance"],
		"description": "The water reflects more than it should.",
	},
	{
		"id": &"wilderness_memorial",
		"name": "Iteration Memorial",
		"layer": &"wilderness",
		"map_position": Vector2(-150, 250),
		"discovered_by_default": false,
		"connections": [&"town_residential"],
		"description": "Names of the iterations that came before.",
	},

	# === DUNGEONS (5 biomes) ===
	{
		"id": &"dungeon_server_room_entrance",
		"name": "Server Room Entrance",
		"layer": &"dungeon",
		"map_position": Vector2(800, -250),
		"discovered_by_default": false,
		"connections": [&"wilderness_clearings"],
		"description": "Cold, blue-lit servers stretch downward.",
	},
	{
		"id": &"dungeon_memory_vaults_entrance",
		"name": "Memory Vaults Entrance",
		"layer": &"dungeon",
		"map_position": Vector2(500, 500),
		"discovered_by_default": false,
		"connections": [&"wilderness_lake"],
		"description": "Sealed doors with ancient inscriptions.",
	},
	{
		"id": &"dungeon_corrupted_wilds_entrance",
		"name": "Corrupted Wilds Entrance",
		"layer": &"dungeon",
		"map_position": Vector2(700, 250),
		"discovered_by_default": false,
		"connections": [&"wilderness_cave"],
		"description": "Where the digital meets the rot.",
	},
	{
		"id": &"dungeon_final_vault_entrance",
		"name": "Final Vault Entrance",
		"layer": &"dungeon",
		"map_position": Vector2(0, 600),
		"discovered_by_default": false,
		"connections": [],  # story-locked
		"description": "It opens only when the time is right.",
	},
]

static var _index: Dictionary = {}


static func get_region(id: StringName) -> Dictionary:
	if _index.is_empty():
		for r in REGIONS:
			_index[r["id"]] = r
	return _index.get(id, {})


static func get_all_regions() -> Array:
	return REGIONS


static func get_regions_by_layer(layer: StringName) -> Array:
	var result: Array = []
	for r in REGIONS:
		if r["layer"] == layer:
			result.append(r)
	return result


static func get_default_discovered() -> Array[StringName]:
	var result: Array[StringName] = []
	for r in REGIONS:
		if r.get("discovered_by_default", false):
			result.append(r["id"])
	return result


static func get_connections(region_id: StringName) -> Array:
	var r: Dictionary = get_region(region_id)
	return r.get("connections", [])


static func count() -> int:
	return REGIONS.size()
