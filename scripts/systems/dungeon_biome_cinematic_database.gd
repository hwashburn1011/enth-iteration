class_name DungeonBiomeCinematicDatabase
extends RefCounted

## Dungeon Biome Cinematic Database (Epic 29 task 39).
##
## Hosts the keyframe data for the "first time entering a new biome"
## cinematics. Each plays exactly once per save (managed by
## CinematicRevealManager via played_reveals tracking).
##
## Triggered by FloorManager when the player loads into a biome they have
## never visited before. Wipe state on new save.
##
## Standard CinematicRevealManager timeline protocol.

const CINEMATICS: Dictionary = {
	&"first_enter_server_room": {
		"letterbox": true,
		"music_sting": &"music_sting_server_first",
		"sfx_id": &"sfx_server_room_hum_in",
		"keyframes": [
			# Doorway approach: low cool blue light leaking out
			{
				"position": Vector3(0, -10, 1.6),
				"look_at": Vector3(0, 8, 3.0),
				"duration": 1.6,
				"fov": 50.0,
			},
			# Push through the threshold, racks reveal
			{
				"position": Vector3(0, -4, 2.4),
				"look_at": Vector3(0, 6, 4.0),
				"duration": 1.4,
				"fov": 46.0,
			},
			# Orbit camera reveal of the central server tower
			{
				"position": Vector3(6, 4, 4),
				"look_at": Vector3(0, 4, 3.5),
				"duration": 2.0,
				"fov": 50.0,
			},
			# Pull back to wide showing the player + scale
			{
				"position": Vector3(-7, -8, 5),
				"look_at": Vector3(0, 0, 1.5),
				"duration": 2.0,
				"fov": 60.0,
			},
		],
	},
	&"first_enter_memory_vaults": {
		"letterbox": true,
		"music_sting": &"music_sting_memory_first",
		"sfx_id": &"sfx_dust_settle_long",
		"keyframes": [
			# Cobwebbed archway entry
			{
				"position": Vector3(0, -8, 1.8),
				"look_at": Vector3(0, 6, 3.5),
				"duration": 1.8,
				"fov": 48.0,
			},
			# Camera tilts up to reveal vaulted ceiling
			{
				"position": Vector3(0, -3, 2.2),
				"look_at": Vector3(0, 2, 8.0),
				"duration": 2.0,
				"fov": 52.0,
			},
			# Sweep across the rows of memory pillars
			{
				"position": Vector3(-5, 2, 3.5),
				"look_at": Vector3(5, 2, 2.5),
				"duration": 2.2,
				"fov": 56.0,
			},
			# Hero close as the player walks in
			{
				"position": Vector3(-3, -4, 2.0),
				"look_at": Vector3(0, 0, 1.4),
				"duration": 1.6,
				"fov": 44.0,
			},
		],
	},
	&"first_enter_corrupted_wilds": {
		"letterbox": true,
		"music_sting": &"music_sting_corrupted_first",
		"sfx_id": &"sfx_glitch_drone_low",
		"keyframes": [
			# Glitching tree silhouettes
			{
				"position": Vector3(-4, -6, 2.0),
				"look_at": Vector3(2, 6, 4.0),
				"duration": 1.8,
				"fov": 48.0,
			},
			# Camera glitches with hard cut to a corrupted growth
			{
				"position": Vector3(2, -2, 1.6),
				"look_at": Vector3(0, 4, 2.0),
				"duration": 0.9,
				"fov": 38.0,
			},
			# Slow circling reveal of the warped clearing
			{
				"position": Vector3(7, 4, 3.5),
				"look_at": Vector3(0, 2, 2.0),
				"duration": 2.2,
				"fov": 54.0,
			},
			# Wide hero pull-back
			{
				"position": Vector3(-8, -8, 5.5),
				"look_at": Vector3(0, 0, 2.0),
				"duration": 2.0,
				"fov": 60.0,
			},
		],
	},
	&"first_enter_boss_sanctum": {
		"letterbox": true,
		"music_sting": &"music_sting_sanctum_first",
		"sfx_id": &"sfx_void_breath_in",
		"keyframes": [
			# Wide low: vast violet hall stretches into the dark
			{
				"position": Vector3(0, -14, 1.4),
				"look_at": Vector3(0, 12, 6.0),
				"duration": 2.4,
				"fov": 58.0,
			},
			# Crane up alongside the central rift
			{
				"position": Vector3(0, -6, 6.0),
				"look_at": Vector3(0, 4, 4.0),
				"duration": 2.2,
				"fov": 52.0,
			},
			# Slow spin showing scale of the room
			{
				"position": Vector3(8, 0, 4.5),
				"look_at": Vector3(0, 0, 3.5),
				"duration": 2.4,
				"fov": 50.0,
			},
			# Final ominous hero close
			{
				"position": Vector3(-2, -4, 2.0),
				"look_at": Vector3(0, 0, 1.4),
				"duration": 2.0,
				"fov": 42.0,
			},
		],
	},
}


static func get_cinematic(biome: StringName) -> Dictionary:
	var key := StringName("first_enter_%s" % biome)
	return CINEMATICS.get(key, {}).duplicate(true)


static func get_cinematic_id_for_biome(biome: StringName) -> StringName:
	return StringName("first_enter_%s" % biome)


static func get_duration(biome: StringName) -> float:
	var entry: Dictionary = get_cinematic(biome)
	if entry.is_empty():
		return 0.0
	var total: float = 0.5
	for kf in entry.get("keyframes", []):
		total += float(kf.get("duration", 0.0))
	return total
