class_name WildernessLandmarkDatabase
extends RefCounted

## The 9 silhouette landmarks from the wilderness bible. Each is a
## set-piece the player should be able to describe from memory after one
## visit. Discovery grants a unique reward (distinct from the waypoint
## fast-travel unlock that some landmarks also carry).
##
## See `_bmad-output/wilderness/wilderness_bible.md` "Landmarks reference"
## and "The 6 sub-regions" for design rationale.

const LANDMARKS: Array[Dictionary] = [
	{
		"id": &"lm_arch",
		"display_name": "Town Gate Archway",
		"region": &"wild_plateau",
		"world_position": Vector3(0, 6, 60),
		"silhouette": "Wooden trapezoid arch with the words 'Past here, the loop forgets you' carved into the lintel.",
		"discovery_reward": {
			"type": &"lore_tablet",
			"id": &"lore_arch_inscription",
		},
		"linked_waypoint_id": &"wp_town_gate",
		"first_discovery_dialogue": &"narrator_arch_first",
	},
	{
		"id": &"lm_three_cairns",
		"display_name": "Three Cairns",
		"region": &"wild_plateau",
		"world_position": Vector3(0, 4, 0),
		"silhouette": "Three stacked stone piles at the trail fork, each topped with a different colored ribbon.",
		"discovery_reward": {
			"type": &"map_reveal",
			"reveals": [&"wild_river", &"wild_forest", &"wild_ruins"],
		},
		"linked_waypoint_id": &"wp_three_cairns",
		"first_discovery_dialogue": &"narrator_cairns_first",
	},
	{
		"id": &"lm_bridge",
		"display_name": "Half-Built Bridge",
		"region": &"wild_river",
		"world_position": Vector3(-12, 0, -10),
		"silhouette": "A broken stone arch with the previous Globbler's scaffolding still in place.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"lore_tablet", "id": &"lore_previous_globbler_journal_1"},
				{"type": &"recipe", "id": &"recipe_repair_kit"},
			],
		},
		"linked_waypoint_id": &"wp_half_bridge",
		"first_discovery_dialogue": &"narrator_bridge_first",
	},
	{
		"id": &"lm_listening_tree",
		"display_name": "The Listening Tree",
		"region": &"wild_forest",
		"world_position": Vector3(-30, 1.5, -20),
		"silhouette": "A wide oak with hundreds of small wind chimes hanging in the branches.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"buff_unlock", "id": &"buff_listening_tree"},
				{"type": &"lore_tablet", "id": &"lore_sage_chimes"},
			],
		},
		"linked_waypoint_id": &"wp_listening_tree",
		"first_discovery_dialogue": &"narrator_listening_tree_first",
	},
	{
		"id": &"lm_spire",
		"display_name": "The Tilted Spire",
		"region": &"wild_ruins",
		"world_position": Vector3(28, 0, -15),
		"silhouette": "A 30-meter broken column leaning at 20 degrees, glyphs along its length glowing faintly.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"lore_tablet", "id": &"lore_spire_glyphs"},
				{"type": &"puzzle_unlock", "id": &"spire_glyph_puzzle"},
			],
		},
		"linked_waypoint_id": &"wp_tilted_spire",
		"first_discovery_dialogue": &"narrator_spire_first",
	},
	{
		"id": &"lm_four_mouths",
		"display_name": "The Four Mouths",
		"region": &"wild_cliffs",
		"world_position": Vector3(0, -4, -85),
		"silhouette": "Four glowing dungeon portals carved into the cliff face, each in a different biome color.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"lore_tablet", "id": &"lore_four_mouths"},
				{"type": &"map_reveal", "reveals": [&"server_room", &"memory_vaults", &"corrupted_wilds", &"final_vault"]},
			],
		},
		"linked_waypoint_id": &"wp_four_mouths",
		"first_discovery_dialogue": &"narrator_four_mouths_first",
	},
	{
		"id": &"lm_campsite",
		"display_name": "The Campsite",
		"region": &"wild_pasture",
		"world_position": Vector3(35, 1, 5),
		"silhouette": "A stone fire ring with two log benches, a sleeping bag, and a kettle on the coals.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"recipe", "id": &"recipe_camp_stew"},
				{"type": &"buff_unlock", "id": &"buff_well_rested"},
			],
		},
		"linked_waypoint_id": &"wp_campsite",
		"first_discovery_dialogue": &"narrator_campsite_first",
	},
	{
		"id": &"lm_signpost_main",
		"display_name": "Main Signpost",
		"region": &"wild_plateau",
		"world_position": Vector3(0, 4, 40),
		"silhouette": "Carved wooden post with four direction arms — Town / River / Cliffs / Ruins.",
		"discovery_reward": {
			"type": &"map_reveal",
			"reveals": [&"wild_plateau", &"wild_pasture"],
		},
		"linked_waypoint_id": &"",  # not a fast-travel point
		"first_discovery_dialogue": &"narrator_signpost_first",
	},
	{
		"id": &"lm_shrine",
		"display_name": "Shrine of the Loop",
		"region": &"wild_river",
		"world_position": Vector3(-25, 0, 5),
		"silhouette": "A small stone altar with a single wind chime and a worn offering bowl.",
		"discovery_reward": {
			"type": &"bundle",
			"items": [
				{"type": &"shrine_unlock", "id": &"shrine_of_the_loop"},
				{"type": &"buff_offering", "id": &"buff_shrine_blessing"},
				{"type": &"lore_tablet", "id": &"lore_shrine_loop"},
			],
		},
		"linked_waypoint_id": &"",
		"first_discovery_dialogue": &"narrator_shrine_first",
	},
]

static var _index: Dictionary = {}
static var _by_waypoint: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in LANDMARKS:
		_index[entry["id"]] = entry
		var wp: StringName = entry.get("linked_waypoint_id", &"")
		if wp != &"":
			_by_waypoint[wp] = entry["id"]


static func get_landmark(landmark_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(landmark_id, {})


static func get_landmark_id_for_waypoint(waypoint_id: StringName) -> StringName:
	_ensure_index()
	return _by_waypoint.get(waypoint_id, &"")


static func get_all() -> Array[Dictionary]:
	return LANDMARKS.duplicate()


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in LANDMARKS:
		if entry.get("region", &"") == region_id:
			result.append(entry)
	return result


static func get_count() -> int:
	return LANDMARKS.size()
