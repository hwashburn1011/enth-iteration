class_name WildernessWaypointDatabase
extends RefCounted

## Static catalog of fast-travel waypoints inside the wilderness zone.
## Each waypoint is a sub-region anchor (more granular than the 6 region
## ids) so the player can fast-travel directly to a landmark instead of
## the whole region.
##
## Discovered by walking within `discovery_radius` of `world_position`,
## or by interacting with the landmark monument (the wilderness scene
## attaches a `WildernessWaypointTrigger` Area3D at each waypoint).
##
## See `_bmad-output/wilderness/wilderness_bible.md` "Landmarks reference"
## and "Path network" for the layout.

const WAYPOINTS: Array[Dictionary] = [
	{
		"id": &"wp_town_gate",
		"display_name": "Town Gate Archway",
		"parent_region": &"wild_plateau",
		"landmark_id": &"lm_arch",
		"world_position": Vector3(0.0, 6.0, 60.0),
		"facing_yaw_degrees": 180.0,  # face south toward cliffs
		"discovery_radius": 6.0,
		"unlocked_by_default": true,  # always available — it's the gate
		"icon_id": &"wp_gate",
		"description": "The wooden archway at the south gate of town.",
	},
	{
		"id": &"wp_three_cairns",
		"display_name": "Three Cairns",
		"parent_region": &"wild_plateau",
		"landmark_id": &"lm_three_cairns",
		"world_position": Vector3(0.0, 4.0, 0.0),
		"facing_yaw_degrees": 180.0,
		"discovery_radius": 8.0,
		"unlocked_by_default": false,
		"icon_id": &"wp_cairns",
		"description": "The trail-fork at the heart of the wilderness — old road south, river west, ruin field east.",
	},
	{
		"id": &"wp_half_bridge",
		"display_name": "Half-Built Bridge",
		"parent_region": &"wild_river",
		"landmark_id": &"lm_bridge",
		"world_position": Vector3(-12.0, 0.0, -10.0),
		"facing_yaw_degrees": 90.0,
		"discovery_radius": 6.0,
		"unlocked_by_default": false,
		"icon_id": &"wp_bridge",
		"description": "A scaffolded stone arch the previous Globbler never finished.",
	},
	{
		"id": &"wp_listening_tree",
		"display_name": "The Listening Tree",
		"parent_region": &"wild_forest",
		"landmark_id": &"lm_listening_tree",
		"world_position": Vector3(-30.0, 1.5, -20.0),
		"facing_yaw_degrees": 0.0,
		"discovery_radius": 7.0,
		"unlocked_by_default": false,
		"icon_id": &"wp_tree",
		"description": "Sage's oak with hundreds of wind chimes singing in three keys.",
	},
	{
		"id": &"wp_tilted_spire",
		"display_name": "The Tilted Spire",
		"parent_region": &"wild_ruins",
		"landmark_id": &"lm_spire",
		"world_position": Vector3(28.0, 0.0, -15.0),
		"facing_yaw_degrees": -90.0,
		"discovery_radius": 8.0,
		"unlocked_by_default": false,
		"icon_id": &"wp_spire",
		"description": "A 30m broken column leaning at 20 degrees, glyphs still glowing faintly.",
	},
	{
		"id": &"wp_campsite",
		"display_name": "The Campsite",
		"parent_region": &"wild_pasture",
		"landmark_id": &"lm_campsite",
		"world_position": Vector3(35.0, 1.0, 5.0),
		"facing_yaw_degrees": -180.0,
		"discovery_radius": 6.0,
		"unlocked_by_default": false,
		"icon_id": &"wp_campsite",
		"description": "Stone fire ring with two log benches. Sleep here to rest until dawn.",
		"can_rest": true,
	},
	{
		"id": &"wp_four_mouths",
		"display_name": "The Four Mouths",
		"parent_region": &"wild_cliffs",
		"landmark_id": &"lm_four_mouths",
		"world_position": Vector3(0.0, -4.0, -85.0),
		"facing_yaw_degrees": 0.0,
		"discovery_radius": 12.0,
		"unlocked_by_default": false,
		"icon_id": &"wp_four_mouths",
		"description": "The cliff line with all four dungeon portals carved into the stone.",
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in WAYPOINTS:
		_index[entry["id"]] = entry


static func get_waypoint(waypoint_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(waypoint_id, {})


static func get_all() -> Array[Dictionary]:
	return WAYPOINTS.duplicate()


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in WAYPOINTS:
		if entry.get("parent_region", &"") == region_id:
			result.append(entry)
	return result


static func get_default_unlocked() -> Array[StringName]:
	var result: Array[StringName] = []
	for entry: Dictionary in WAYPOINTS:
		if entry.get("unlocked_by_default", false):
			result.append(entry["id"])
	return result


static func get_count() -> int:
	return WAYPOINTS.size()
