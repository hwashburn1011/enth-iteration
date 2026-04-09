class_name SubAreaDatabase
extends RefCounted

## Static catalog of all 8 town sub-areas. See
## `_bmad-output/town/sub_areas_bible.md` for the design rationale.
##
## A sub-area is a hidden/optional pocket of content tied to a parent
## district or wilderness zone. Discovering one grants a unique reward
## (recipe / outfit piece / NPC unlock / lore) and persists across
## iterations.

const SUB_AREAS: Array[Dictionary] = [
	{
		"id": &"outskirts",
		"display_name": "The Outskirts",
		"parent_region": &"workshop_district",
		"connects_from": &"workshop_district_east_edge",
		"hidden_behind": &"none",
		"hidden_hint": "Follow the path past the last workshop fence.",
		"discovery_reward": {
			"type": &"recipe",
			"id": &"recipe_hunters_mark_module",
		},
		"lore_plaque": "The line between town and wild was once clearer.",
		"npcs_found_here": [&"sentinel"],
		"ambient_sfx": [&"wind_outdoor", &"distant_wilderness_calls"],
		"music_track": &"wilderness_day",
		"discovery_iteration_gate": 0,
	},
	{
		"id": &"cliffs",
		"display_name": "Cliffside Overlook",
		"parent_region": &"wilderness_north",
		"connects_from": &"outskirts_north_climb",
		"hidden_behind": &"vine_ladder",
		"hidden_hint": "A vine-covered ladder hides against the cliff face.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"title", "id": &"cliffwalker"},
				{"type": &"pet_egg", "id": &"echo_bird_egg"},
			],
		},
		"lore_plaque": "From here, you can see the seams of the world.",
		"npcs_found_here": [&"legacy"],
		"ambient_sfx": [&"wind_strong_high", &"distant_birdsong"],
		"music_track": &"wilderness_night",
		"discovery_iteration_gate": 0,
	},
	{
		"id": &"hidden_cave",
		"display_name": "Hidden Cave",
		"parent_region": &"wilderness_north",
		"connects_from": &"cliffs_waterfall",
		"hidden_behind": &"walk_through_waterfall",
		"hidden_hint": "The waterfall isn't solid. Walk into it.",
		"discovery_reward": {
			"type": &"faction_unlock",
			"id": &"glitchers",
			"npc": &"null_glitcher_rep",
			"first_quest": &"quest_glitcher_initiation",
		},
		"lore_plaque": "Where the broken gather.",
		"npcs_found_here": [&"null_glitcher_rep"],
		"ambient_sfx": [&"cave_drip", &"glitch_crackle_distant"],
		"music_track": &"hidden_cave_dark",
		"discovery_iteration_gate": 0,
	},
	{
		"id": &"sages_garden",
		"display_name": "Sage's Garden",
		"parent_region": &"sage_sanctum",
		"connects_from": &"sage_sanctum_back_door",
		"hidden_behind": &"affinity_confidant_sage",
		"hidden_hint": "Sage will open the back door once they trust you completely.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"seeds", "id": &"sages_mint_seeds", "count": 5},
				{"type": &"lore_tablet", "id": &"lore_sage_origin"},
			],
		},
		"lore_plaque": "Where memories are gardened.",
		"npcs_found_here": [&"sage"],
		"ambient_sfx": [&"wind_chimes_soft", &"choir_hum_low"],
		"music_track": &"sages_garden_pad",
		"discovery_iteration_gate": 0,
	},
	{
		"id": &"iteration_memorial",
		"display_name": "Iteration Memorial",
		"parent_region": &"residential_district",
		"connects_from": &"residential_district_south_path",
		"hidden_behind": &"iteration_4_story",
		"hidden_hint": "After the events of Iteration 4, a path opens to the south.",
		"discovery_reward": {
			"type": &"outfit_piece",
			"set": &"the_architect",
			"slot": &"head",
		},
		"lore_plaque": "Names that fade. Names that remain.",
		"npcs_found_here": [&"legacy"],
		"ambient_sfx": [&"choral_hum_low", &"bell_toll_distant"],
		"music_track": &"memorial_piano_somber",
		"discovery_iteration_gate": 4,
	},
	{
		"id": &"underground_lounge",
		"display_name": "The Underground Lounge",
		"parent_region": &"market_district",
		"connects_from": &"cache_tavern_back_stairs",
		"hidden_behind": &"affinity_friend_cache",
		"hidden_hint": "Cache will mention the back stairs once you're a regular.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"outfit_piece", "set": &"cozy", "slot": &"top"},
				{"type": &"unlock", "id": &"jukebox"},
			],
		},
		"lore_plaque": "Where the off-duty AIs go to be off-duty.",
		"npcs_found_here": [&"sync_musician", &"cache"],
		"ambient_sfx": [&"jazz_murmur_low", &"bottle_clinks"],
		"music_track": &"tavern_music_smoky",
		"discovery_iteration_gate": 0,
	},
	{
		"id": &"tower_top",
		"display_name": "Tower Top",
		"parent_region": &"sage_sanctum",
		"connects_from": &"sage_sanctum_top_floor",
		"hidden_behind": &"iteration_5_story",
		"hidden_hint": "After Iteration 5, the upper stairs become walkable.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"decoration", "id": &"telescope"},
				{"type": &"daily_lore_unlock", "id": &"tower_top_journal"},
			],
		},
		"lore_plaque": "From here, the simulation is small.",
		"npcs_found_here": [&"sage"],
		"ambient_sfx": [&"wind_high_altitude", &"city_distant"],
		"music_track": &"tower_top_skybound",
		"discovery_iteration_gate": 5,
	},
	{
		"id": &"old_ruins",
		"display_name": "Old Ruins",
		"parent_region": &"wilderness_west",
		"connects_from": &"wilderness_clearings_west",
		"hidden_behind": &"none",
		"hidden_hint": "Easy to walk past. Look for a stone archway among the trees.",
		"discovery_reward": {
			"type": &"lore_set",
			"tablets": [
				&"lore_pre_iteration_1",
				&"lore_pre_iteration_2",
				&"lore_pre_iteration_3",
				&"lore_pre_iteration_4",
				&"lore_pre_iteration_5",
			],
		},
		"lore_plaque": "Older than memory. Older than the loop.",
		"npcs_found_here": [],
		"ambient_sfx": [&"wind_through_stones", &"chime_distant"],
		"music_track": &"old_ruins_ancient",
		"discovery_iteration_gate": 0,
	},
	{
		"id": &"hidden_grove",
		"display_name": "The Hidden Grove",
		"parent_region": &"wild_forest",
		"connects_from": &"forest_firefly_trail",
		"hidden_behind": &"firefly_trail_at_night",
		"hidden_hint": "After dark, fireflies in the forest gather in a line. Follow them.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"fishing_spot_unlock", "id": &"grove_pond"},
				{"type": &"recipe", "id": &"recipe_glow_lure"},
				{"type": &"lore_tablet", "id": &"lore_grove_caretaker"},
			],
		},
		"lore_plaque": "Where the fireflies remember the way.",
		"npcs_found_here": [],
		"ambient_sfx": [&"amb_grove_pond_lap", &"amb_fireflies_wing_hum", &"amb_choir_hum_low"],
		"music_track": &"wild_forest_night",
		"discovery_iteration_gate": 0,
	},
	{
		"id": &"hidden_lake",
		"display_name": "The Hidden Lake",
		"parent_region": &"wild_cliffs",
		"connects_from": &"cliffs_ne_vine_ladder",
		"hidden_behind": &"vine_ladder_past_waterfall",
		"hidden_hint": "Past the northeast waterfall, a vine ladder climbs to a still lake.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"outfit_piece", "set": &"drowned", "slot": &"top"},
				{"type": &"fishing_spot_unlock", "id": &"hidden_lake"},
				{"type": &"lore_tablet", "id": &"lore_drowned_set"},
			],
		},
		"lore_plaque": "Still water. Stiller than memory.",
		"npcs_found_here": [],
		"ambient_sfx": [&"amb_lake_still", &"amb_wind_high_altitude", &"amb_distant_waterfall"],
		"music_track": &"wild_cliffs",
		"discovery_iteration_gate": 0,
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in SUB_AREAS:
		_index[entry["id"]] = entry


static func get_sub_area(sub_area_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(sub_area_id, {})


static func get_all() -> Array[Dictionary]:
	return SUB_AREAS.duplicate()


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in SUB_AREAS:
		if entry["parent_region"] == region_id:
			result.append(entry)
	return result


static func get_count() -> int:
	return SUB_AREAS.size()
