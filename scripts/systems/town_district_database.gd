class_name TownDistrictDatabase
extends RefCounted

## Static catalog of all 5 town districts with identity, music, lighting,
## NPC residence assignments, and quest hub references.

const DISTRICTS: Array = [
	{
		"id": &"residential",
		"display_name": "Residential District",
		"region_id": &"town_residential",  # links to RegionDatabase
		"music_track": &"district_residential",
		"environment_preset": &"town_day",
		"theme_color": Color(0.55, 0.45, 0.30),
		"lore": "Where lives are stored. Where iterations rest between.",
		"home_npcs": [&"pixel", &"cache", &"bit", &"legacy", &"render"],
		"work_npcs": [],
		"hero_buildings": [&"sage_sanctum"],
		"connecting_districts": [&"market", &"commons"],
		"ambient_sfx": [&"birdsong_loop"],
		"quest_hub_position": Vector2(-180, -100),
	},
	{
		"id": &"market",
		"display_name": "Market District",
		"region_id": &"town_market",
		"music_track": &"district_market",
		"environment_preset": &"town_day",
		"theme_color": Color(0.85, 0.55, 0.20),
		"lore": "Where things become other things.",
		"home_npcs": [&"trade"],
		"work_npcs": [&"pixel", &"trade"],
		"hero_buildings": [&"cache_tavern"],
		"connecting_districts": [&"residential", &"commons", &"workshop"],
		"ambient_sfx": [],  # vendors handled by NPC schedules
		"quest_hub_position": Vector2(0, -150),
	},
	{
		"id": &"commons",
		"display_name": "Commons District",
		"region_id": &"town_commons",
		"music_track": &"district_commons",
		"environment_preset": &"town_day",
		"theme_color": Color(0.75, 0.55, 0.30),
		"lore": "Where stories begin and end.",
		"home_npcs": [&"cache", &"index", &"sync"],
		"work_npcs": [&"cache", &"index", &"sync", &"legacy"],
		"hero_buildings": [&"index_archive", &"cache_tavern"],
		"connecting_districts": [&"residential", &"market", &"workshop", &"docks"],
		"ambient_sfx": [],
		"quest_hub_position": Vector2(0, 0),
	},
	{
		"id": &"workshop",
		"display_name": "Workshop District",
		"region_id": &"town_workshop",
		"music_track": &"district_workshop",
		"environment_preset": &"town_day",
		"theme_color": Color(0.65, 0.30, 0.15),
		"lore": "Where ideas take form.",
		"home_npcs": [&"forge", &"lab", &"sentinel"],
		"work_npcs": [&"forge", &"lab", &"render", &"sentinel", &"reflection"],
		"hero_buildings": [&"forge_foundry", &"render_studio"],
		"connecting_districts": [&"market", &"commons"],
		"ambient_sfx": [&"fire_crackle_loop"],
		"quest_hub_position": Vector2(200, -50),
	},
	{
		"id": &"docks",
		"display_name": "Docks District",
		"region_id": &"town_docks",
		"music_track": &"district_docks",
		"environment_preset": &"town_day",
		"theme_color": Color(0.30, 0.55, 0.85),
		"lore": "Where the world reaches us.",
		"home_npcs": [],
		"work_npcs": [&"harvest"],
		"hero_buildings": [],
		"connecting_districts": [&"commons"],
		"ambient_sfx": [&"water_splash"],
		"quest_hub_position": Vector2(0, 200),
	},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return DISTRICTS


static func get_district(id: StringName) -> Dictionary:
	if _index.is_empty():
		for d in DISTRICTS:
			_index[d["id"]] = d
	return _index.get(id, {})


static func get_district_for_region(region_id: StringName) -> Dictionary:
	for d in DISTRICTS:
		if d["region_id"] == region_id:
			return d
	return {}


static func get_home_district_for_npc(npc_id: StringName) -> StringName:
	for d in DISTRICTS:
		if d["home_npcs"].has(npc_id):
			return d["id"]
	return &""


static func get_work_district_for_npc(npc_id: StringName) -> StringName:
	for d in DISTRICTS:
		if d["work_npcs"].has(npc_id):
			return d["id"]
	return &""


static func count() -> int:
	return DISTRICTS.size()
