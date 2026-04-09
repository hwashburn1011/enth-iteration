class_name EntranceApproachPathDatabase
extends RefCounted

## Per-entrance approach path waypoints. Each entrance has a 5-7 point
## descent path from the cliff top edge down to the portal mouth at -4m.
## Coordinates are in wilderness world space (matches the
## DungeonEntranceDatabase wilderness_position field).
##
## A `DungeonEntranceApproachPath` component reads these at scene attach
## time and builds:
##   1. A Path3D with the points, used for guide-light placement and
##      the approach decal scatter
##   2. A small flock of guide markers (lanterns / glyphs / glowing
##      stones / silver chains depending on biome) along the path
##
## Each entry also defines:
##   - guide_marker_count       — total markers along the path
##   - guide_marker_scene_id    — which prop set to use
##   - guide_marker_glow_color  — biome accent color
##   - sign_at_top              — whether to spawn an entrance signpost

const PATHS: Dictionary = {
	&"server_room": {
		"points": [
			Vector3(-45, 4,  -55),  # cliff top
			Vector3(-45, 2,  -65),
			Vector3(-45, 0,  -72),
			Vector3(-45, -2, -80),
			Vector3(-45, -4, -88),  # at the portal mouth
		],
		"guide_marker_count": 6,
		"guide_marker_scene_id": &"approach_marker_data_pylon",
		"guide_marker_glow_color": Color(0.55, 0.85, 1.00),
		"sign_at_top": true,
		"sign_text": "→ SERVER ROOM",
	},
	&"memory_vaults": {
		"points": [
			Vector3(-15, 4,  -55),
			Vector3(-15, 2,  -65),
			Vector3(-15, 0,  -72),
			Vector3(-15, -2, -80),
			Vector3(-15, -4, -88),
		],
		"guide_marker_count": 5,
		"guide_marker_scene_id": &"approach_marker_archive_lantern",
		"guide_marker_glow_color": Color(1.00, 0.85, 0.45),
		"sign_at_top": true,
		"sign_text": "→ MEMORY VAULTS",
	},
	&"corrupted_wilds": {
		"points": [
			Vector3( 15, 4,  -55),
			Vector3( 14, 2,  -64),
			Vector3( 16, 0,  -72),
			Vector3( 14, -2, -80),
			Vector3( 15, -4, -88),
		],
		"guide_marker_count": 7,  # more, organic-feeling clusters
		"guide_marker_scene_id": &"approach_marker_glowmoss_stone",
		"guide_marker_glow_color": Color(0.55, 1.00, 0.55),
		"sign_at_top": false,  # the Wilds doesn't sign itself
	},
	&"final_vault": {
		"points": [
			Vector3( 45, 4,  -55),
			Vector3( 45, 2,  -65),
			Vector3( 45, 0,  -72),
			Vector3( 45, -2, -80),
			Vector3( 45, -4, -88),
		],
		"guide_marker_count": 7,  # one for each seal
		"guide_marker_scene_id": &"approach_marker_silver_chain",
		"guide_marker_glow_color": Color(0.95, 0.90, 1.00),
		"sign_at_top": true,
		"sign_text": "← THE FINAL VAULT",
	},
}


static func get_path(entrance_id: StringName) -> Dictionary:
	return PATHS.get(entrance_id, {})


static func get_count() -> int:
	return PATHS.size()
