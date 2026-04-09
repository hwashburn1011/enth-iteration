class_name CinematicRevealDatabase
extends RefCounted

## Catalog of one-shot cinematic reveal shots — the camera flourishes
## that play the *first time* the player crosses near a wilderness
## landmark or vista. Distinct from `WildernessStoryTriggerDatabase`
## (which carries dialogue + story flags); reveals are pure visual
## moments designed to make the player stop and say "oh."
##
## Each reveal defines:
##   - trigger position + radius
##   - camera path: an array of {position, look_at, duration} keyframes
##   - optional FOV pull-in for emphasis
##   - SFX sting + music sting
##   - one-shot per save file (state in CinematicRevealManager)

const REVEALS: Array[Dictionary] = [
	{
		"id": &"reveal_first_horizon",
		"display_name": "First Horizon",
		"region": &"wild_plateau",
		"trigger_position": Vector3(0, 6, 50),
		"trigger_radius": 4.0,
		"description": "The first time the player passes the gate, the camera pulls back to show the wilderness sweep.",
		"keyframes": [
			{"position": Vector3(0, 12, 56),  "look_at": Vector3(0, 0, -10), "duration": 1.5, "fov": 70.0},
			{"position": Vector3(0, 22, 70),  "look_at": Vector3(0, 0, -40), "duration": 2.5, "fov": 60.0},
			{"position": Vector3(0, 16, 60),  "look_at": Vector3(0, 0, -20), "duration": 2.0, "fov": 65.0},
		],
		"sfx_id": &"sfx_camera_flourish_soft",
		"music_sting": &"sting_first_horizon",
		"letterbox": true,
	},
	{
		"id": &"reveal_listening_tree",
		"display_name": "The Listening Tree Reveal",
		"region": &"wild_forest",
		"trigger_position": Vector3(-30, 1.5, -10),
		"trigger_radius": 6.0,
		"description": "Slow upward arc on the chimes hanging from the canopy.",
		"keyframes": [
			{"position": Vector3(-26, 2, -16), "look_at": Vector3(-30, 4, -20), "duration": 1.5, "fov": 55.0},
			{"position": Vector3(-26, 6, -22), "look_at": Vector3(-30, 6, -20), "duration": 2.5, "fov": 45.0},
			{"position": Vector3(-26, 4, -18), "look_at": Vector3(-30, 3, -20), "duration": 1.5, "fov": 60.0},
		],
		"sfx_id": &"sfx_chimes_close",
		"music_sting": &"sting_listening_tree_reveal",
		"letterbox": true,
	},
	{
		"id": &"reveal_tilted_spire",
		"display_name": "Tilted Spire Reveal",
		"region": &"wild_ruins",
		"trigger_position": Vector3(20, 0, -10),
		"trigger_radius": 7.0,
		"description": "Camera tilts up the leaning spire from base to broken top.",
		"keyframes": [
			{"position": Vector3(22, 1, -8),  "look_at": Vector3(28, 0, -15),  "duration": 1.5, "fov": 70.0},
			{"position": Vector3(22, 8, -8),  "look_at": Vector3(28, 12, -15), "duration": 2.5, "fov": 55.0},
			{"position": Vector3(22, 18, -8), "look_at": Vector3(28, 25, -15), "duration": 2.5, "fov": 50.0},
			{"position": Vector3(22, 8, -8),  "look_at": Vector3(28, 8, -15),  "duration": 2.0, "fov": 60.0},
		],
		"sfx_id": &"sfx_camera_flourish_low",
		"music_sting": &"sting_spire_reveal",
		"letterbox": true,
	},
	{
		"id": &"reveal_four_mouths",
		"display_name": "The Four Mouths Reveal",
		"region": &"wild_cliffs",
		"trigger_position": Vector3(0, -3, -75),
		"trigger_radius": 12.0,
		"description": "Slow lateral pan across all four glowing portals.",
		"keyframes": [
			{"position": Vector3(-50, 4, -70), "look_at": Vector3(-45, -2, -85), "duration": 2.0, "fov": 65.0},
			{"position": Vector3(-15, 4, -70), "look_at": Vector3(-15, -2, -85), "duration": 2.0, "fov": 65.0},
			{"position": Vector3( 15, 4, -70), "look_at": Vector3( 15, -2, -85), "duration": 2.0, "fov": 65.0},
			{"position": Vector3( 50, 4, -70), "look_at": Vector3( 45, -2, -85), "duration": 2.5, "fov": 55.0},
		],
		"sfx_id": &"sfx_camera_flourish_grand",
		"music_sting": &"sting_four_mouths_reveal",
		"letterbox": true,
	},
	{
		"id": &"reveal_half_bridge",
		"display_name": "Half-Built Bridge Reveal",
		"region": &"wild_river",
		"trigger_position": Vector3(-12, 0, -2),
		"trigger_radius": 6.0,
		"description": "Low orbit around the abandoned scaffolding.",
		"keyframes": [
			{"position": Vector3(-6, 3, -8),  "look_at": Vector3(-12, 1, -10), "duration": 2.0, "fov": 60.0},
			{"position": Vector3(-12, 4, -16),"look_at": Vector3(-12, 1, -10), "duration": 2.5, "fov": 55.0},
			{"position": Vector3(-18, 3, -8), "look_at": Vector3(-12, 1, -10), "duration": 2.5, "fov": 55.0},
		],
		"sfx_id": &"sfx_camera_flourish_soft",
		"music_sting": &"sting_bridge_reveal",
		"letterbox": true,
	},
	{
		"id": &"reveal_hidden_grove",
		"display_name": "Hidden Grove Reveal",
		"region": &"wild_forest",
		"trigger_position": Vector3(-55, 0, -45),
		"trigger_radius": 5.0,
		"description": "First entry into the firefly grove — slow pull-up to reveal the pond.",
		"keyframes": [
			{"position": Vector3(-55, 2, -40), "look_at": Vector3(-55, 0, -50), "duration": 2.0, "fov": 70.0},
			{"position": Vector3(-55, 6, -35), "look_at": Vector3(-55, 0, -50), "duration": 3.0, "fov": 55.0},
			{"position": Vector3(-55, 3, -38), "look_at": Vector3(-55, 0, -50), "duration": 2.0, "fov": 65.0},
		],
		"sfx_id": &"sfx_grove_chime_soft",
		"music_sting": &"sting_grove_reveal",
		"letterbox": true,
	},
	{
		"id": &"reveal_hidden_lake",
		"display_name": "Hidden Lake Reveal",
		"region": &"wild_cliffs",
		"trigger_position": Vector3(85, 5, -75),
		"trigger_radius": 5.0,
		"description": "After the vine ladder climb, the camera pulls back to show the still water.",
		"keyframes": [
			{"position": Vector3(85, 7, -73), "look_at": Vector3(90, 4, -85), "duration": 1.5, "fov": 70.0},
			{"position": Vector3(85, 12, -68),"look_at": Vector3(90, 4, -85), "duration": 3.0, "fov": 55.0},
			{"position": Vector3(85, 8, -72), "look_at": Vector3(90, 4, -85), "duration": 2.0, "fov": 65.0},
		],
		"sfx_id": &"sfx_lake_still_swell",
		"music_sting": &"sting_lake_reveal",
		"letterbox": true,
	},
]


static func get_reveal(reveal_id: StringName) -> Dictionary:
	for entry in REVEALS:
		if entry["id"] == reveal_id:
			return entry
	return {}


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in REVEALS:
		if entry.get("region", &"") == region_id:
			result.append(entry)
	return result


static func get_count() -> int:
	return REVEALS.size()
