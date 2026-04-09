class_name HubFastTravelDatabase
extends RefCounted

## Catalog of fast-travel points inside the town hub. Where the
## WildernessWaypointDatabase covers wilderness landmarks, this one
## covers the 13 new hub spaces from Epic 25 plus the existing town
## district anchors. Each entry can be discovered, displayed on the
## hub map, and warped to.
##
## Each entry:
##   - id, display_name, district / parent_space
##   - world_position (Vector3 in town scene local space)
##   - facing_yaw_degrees (where the player faces after warp)
##   - icon_id, description
##   - unlock_condition (auto / story_flag / always)
##   - hint when locked

const POINTS: Array[Dictionary] = [
	# === Always-unlocked town anchors ===
	{
		"id": &"hub_town_square",
		"display_name": "Town Square",
		"parent_space": &"town_center",
		"world_position": Vector3(0, 0, 0),
		"facing_yaw_degrees": 180.0,
		"icon_id": &"icon_town_square",
		"description": "The plaza in the center of town.",
		"unlock_condition": &"always",
	},
	{
		"id": &"hub_residential",
		"display_name": "Residential District",
		"parent_space": &"residential_district",
		"world_position": Vector3(-15, 0, 8),
		"facing_yaw_degrees": 0.0,
		"icon_id": &"icon_house",
		"description": "Where you sleep. Where most of the town lives.",
		"unlock_condition": &"always",
	},
	{
		"id": &"hub_workshop_district",
		"display_name": "Workshop District",
		"parent_space": &"workshop_district",
		"world_position": Vector3(15, 0, 8),
		"facing_yaw_degrees": 180.0,
		"icon_id": &"icon_workshop",
		"description": "Smiths, sparks, and the training arena out back.",
		"unlock_condition": &"always",
	},
	# === New hub expansion spaces ===
	{
		"id": &"hub_lounge",
		"display_name": "The Underground Lounge",
		"parent_space": &"hub_lounge",
		"world_position": Vector3(2, -3, 4),
		"facing_yaw_degrees": 180.0,
		"icon_id": &"icon_lounge",
		"description": "Cache's secret. Down the back stairs of the tavern.",
		"unlock_condition": &"sub_area_discovered",
		"unlock_sub_area_id": &"underground_lounge",
		"locked_hint": "Cache hasn't told you about it yet. Get to know her better.",
	},
	{
		"id": &"hub_tower_top",
		"display_name": "Tower Top",
		"parent_space": &"hub_tower_top",
		"world_position": Vector3(0, 18, -12),
		"facing_yaw_degrees": 180.0,
		"icon_id": &"icon_tower",
		"description": "The highest point in town. The telescope is up here.",
		"unlock_condition": &"sub_area_discovered",
		"unlock_sub_area_id": &"tower_top",
		"locked_hint": "Story-locked at iteration 5.",
	},
	{
		"id": &"hub_sage_study",
		"display_name": "Sage's Study",
		"parent_space": &"hub_sage_study",
		"world_position": Vector3(-2, 6, -12),
		"facing_yaw_degrees": 180.0,
		"icon_id": &"icon_study",
		"description": "Where Sage writes. Sit in the armchair to talk.",
		"unlock_condition": &"affinity_tier",
		"unlock_npc_id": &"sage",
		"unlock_min_tier": &"confidant",
		"locked_hint": "Sage will invite you when she trusts you.",
	},
	{
		"id": &"hub_sage_library",
		"display_name": "Sage's Library",
		"parent_space": &"hub_sage_library",
		"world_position": Vector3(0, 0, -10),
		"facing_yaw_degrees": 0.0,
		"icon_id": &"icon_library",
		"description": "Two-story library with the archive crystal at the back.",
		"unlock_condition": &"iteration_min",
		"unlock_iteration": 2,
		"locked_hint": "Sage opens the library at iteration 2.",
	},
	{
		"id": &"hub_training_arena",
		"display_name": "Training Arena",
		"parent_space": &"hub_training_arena",
		"world_position": Vector3(20, 0, 12),
		"facing_yaw_degrees": 270.0,
		"icon_id": &"icon_arena",
		"description": "Six dummies and a reset lever. The DPS plaque is on the wall.",
		"unlock_condition": &"always",
	},
	{
		"id": &"hub_farm",
		"display_name": "Farm Plot",
		"parent_space": &"hub_farm",
		"world_position": Vector3(-20, 0, 12),
		"facing_yaw_degrees": 90.0,
		"icon_id": &"icon_farm",
		"description": "16 plots, a tool shed, a watering well, and a compost bin.",
		"unlock_condition": &"always",
	},
	{
		"id": &"hub_fishing_dock",
		"display_name": "Fishing Dock",
		"parent_space": &"hub_fishing_dock",
		"world_position": Vector3(8, 0, 22),
		"facing_yaw_degrees": 0.0,
		"icon_id": &"icon_dock",
		"description": "L-shaped pier with three fishing spots.",
		"unlock_condition": &"always",
	},
	{
		"id": &"hub_cooking",
		"display_name": "Cache's Kitchen",
		"parent_space": &"hub_cooking",
		"world_position": Vector3(3, 0, 5),
		"facing_yaw_degrees": 180.0,
		"icon_id": &"icon_kitchen",
		"description": "Behind the tavern bar. Cache's recipe book is on the island.",
		"unlock_condition": &"affinity_tier",
		"unlock_npc_id": &"cache",
		"unlock_min_tier": &"friend",
		"locked_hint": "Cache won't let you in the kitchen until she trusts you.",
	},
	{
		"id": &"hub_workshop",
		"display_name": "Crafting Workshop",
		"parent_space": &"hub_workshop",
		"world_position": Vector3(18, 0, 6),
		"facing_yaw_degrees": 180.0,
		"icon_id": &"icon_workshop",
		"description": "Forge + bench + shaper, all in one room.",
		"unlock_condition": &"always",
	},
	{
		"id": &"hub_pet_hutch",
		"display_name": "Pet Hutch",
		"parent_space": &"hub_pet_hutch",
		"world_position": Vector3(-18, 0, 6),
		"facing_yaw_degrees": 90.0,
		"icon_id": &"icon_hutch",
		"description": "Four small huts and a feeding trough.",
		"unlock_condition": &"story_flag",
		"unlock_flag": &"first_pet_acquired",
		"locked_hint": "Get a pet first.",
	},
	{
		"id": &"hub_memorial_gallery",
		"display_name": "Memorial Gallery",
		"parent_space": &"hub_memorial_gallery",
		"world_position": Vector3(-4, 0, -16),
		"facing_yaw_degrees": 0.0,
		"icon_id": &"icon_memorial",
		"description": "Nine alcoves. One per iteration. Marn keeps the candles.",
		"unlock_condition": &"iteration_min",
		"unlock_iteration": 4,
		"locked_hint": "The hall is sealed until iteration 4.",
	},
	{
		"id": &"hub_trophy_hall",
		"display_name": "Trophy Display Hall",
		"parent_space": &"hub_trophy_hall",
		"world_position": Vector3(22, 0, 4),
		"facing_yaw_degrees": 270.0,
		"icon_id": &"icon_trophies",
		"description": "Twelve mounts. Most of them empty.",
		"unlock_condition": &"always",
	},
	{
		"id": &"hub_wardrobe",
		"display_name": "Wardrobe Room",
		"parent_space": &"hub_wardrobe",
		"world_position": Vector3(-16, 0, 4),
		"facing_yaw_degrees": 90.0,
		"icon_id": &"icon_wardrobe",
		"description": "Mirror, mannequins, dye station.",
		"unlock_condition": &"always",
	},
	{
		"id": &"hub_treasure_room",
		"display_name": "Hidden Treasure Room",
		"parent_space": &"hub_hidden_treasure",
		"world_position": Vector3(0, 0, -14),
		"facing_yaw_degrees": 0.0,
		"icon_id": &"icon_treasure",
		"description": "Behind the second bookshelf. Solve the books first.",
		"unlock_condition": &"story_flag",
		"unlock_flag": &"bookshelf_treasure_opened",
		"locked_hint": "There is no door here. Yet.",
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in POINTS:
		_index[entry["id"]] = entry


static func get_point(point_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(point_id, {})


static func get_all() -> Array[Dictionary]:
	return POINTS.duplicate()


static func is_unlocked(entry: Dictionary, query_state: Dictionary) -> bool:
	## query_state should provide:
	##   discovered_sub_areas: Array[StringName]
	##   set_flags: Array[StringName]
	##   current_iteration: int
	##   npc_tiers: Dictionary[StringName, StringName]
	var condition: StringName = entry.get("unlock_condition", &"always")
	match condition:
		&"always":
			return true
		&"sub_area_discovered":
			var sa: StringName = entry.get("unlock_sub_area_id", &"")
			return sa != &"" and (query_state.get("discovered_sub_areas", []) as Array).has(sa)
		&"story_flag":
			var f: StringName = entry.get("unlock_flag", &"")
			return f != &"" and (query_state.get("set_flags", []) as Array).has(f)
		&"iteration_min":
			var iter_min: int = int(entry.get("unlock_iteration", 99))
			return int(query_state.get("current_iteration", 0)) >= iter_min
		&"affinity_tier":
			var npc: StringName = entry.get("unlock_npc_id", &"")
			var min_tier: StringName = entry.get("unlock_min_tier", &"acquaintance")
			var tiers: Dictionary = query_state.get("npc_tiers", {})
			return _tier_at_least(tiers.get(npc, &"stranger"), min_tier)
	return false


static func _tier_at_least(actual: StringName, required: StringName) -> bool:
	const ORDER: Array[StringName] = [&"stranger", &"acquaintance", &"friend", &"confidant"]
	var actual_idx: int = ORDER.find(actual)
	var required_idx: int = ORDER.find(required)
	if actual_idx < 0:
		return false
	if required_idx < 0:
		return true
	return actual_idx >= required_idx


static func get_count() -> int:
	return POINTS.size()
