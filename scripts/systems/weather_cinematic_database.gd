class_name WeatherCinematicDatabase
extends RefCounted

## Weather Cinematic Database (Epic 27 task 45).
##
## Hosts the keyframe data for the storm rolling-in cinematic, plus any
## future weather cinematics (glitch storm collapse, rainbow reveal, etc).
##
## Consumed by CinematicRevealManager.try_play(id) via the standard timeline
## protocol ({event, target, look_at, duration, fov} keyframe rows).
##
## The storm cinematic is triggered by WeatherController when transitioning
## from clear/cloudy to storm on any outdoor scene. It plays at most once
## per storm event; subsequent storms that day skip it. The data lives here
## so WeatherController stays a pure state machine and the camera choreography
## is a single data blob that can be tuned without touching logic.

const CINEMATICS: Dictionary = {
	&"storm_rolling_in": {
		"letterbox": true,
		"fog_push": 0.022,
		"music_sting": &"music_sting_storm_approach",
		"sfx_id": &"sfx_thunder_distant_build",
		"keyframes": [
			# Wide low-angle establishing: clouds rolling in from horizon
			{
				"position": Vector3(0, -22, 3.5),
				"look_at": Vector3(0, 25, 18),
				"duration": 2.2,
				"fov": 62.0,
			},
			# Camera climbs, sky darkening as front approaches
			{
				"position": Vector3(-4, -16, 6.0),
				"look_at": Vector3(0, 18, 14),
				"duration": 2.0,
				"fov": 56.0,
			},
			# Lightning flash framing — wide for the bolt reveal
			{
				"position": Vector3(6, -12, 4.5),
				"look_at": Vector3(-2, 10, 12),
				"duration": 1.6,
				"fov": 54.0,
			},
			# Whip-pan down to ground level as first rain hits
			{
				"position": Vector3(3, -6, 2.0),
				"look_at": Vector3(0, 0, 1.5),
				"duration": 1.4,
				"fov": 48.0,
			},
			# Close hero push-in with rain streaking past
			{
				"position": Vector3(-2, -3, 1.8),
				"look_at": Vector3(0, 0, 1.3),
				"duration": 1.8,
				"fov": 42.0,
			},
			# Final pullback — storm fully engulfs scene
			{
				"position": Vector3(-8, -10, 5.5),
				"look_at": Vector3(0, 2, 2),
				"duration": 2.4,
				"fov": 64.0,
			},
		],
	},
	&"glitch_storm_corruption": {
		"letterbox": true,
		"fog_push": 0.025,
		"music_sting": &"music_sting_glitch_corruption",
		"sfx_id": &"sfx_glitch_static_wash",
		"keyframes": [
			# Close violet clouds swirling
			{
				"position": Vector3(0, -10, 8),
				"look_at": Vector3(0, 15, 20),
				"duration": 1.8,
				"fov": 52.0,
			},
			# Hard cut: camera jitters, digital artifact moment
			{
				"position": Vector3(2, -5, 3),
				"look_at": Vector3(-1, 5, 6),
				"duration": 0.8,
				"fov": 40.0,
			},
			# Corruption wave passes over hero
			{
				"position": Vector3(-3, -4, 2),
				"look_at": Vector3(0, 0, 1.4),
				"duration": 1.6,
				"fov": 44.0,
			},
			# Pull back with violet rain hammering down
			{
				"position": Vector3(-6, -12, 5),
				"look_at": Vector3(0, 0, 2),
				"duration": 2.2,
				"fov": 60.0,
			},
		],
	},
	&"rainbow_reveal": {
		"letterbox": false,  # soft reveal, no letterbox
		"fog_push": -0.01,   # clearing
		"music_sting": &"music_sting_rainbow_gentle",
		"sfx_id": &"sfx_bird_chorus_soft",
		"keyframes": [
			# Ground level wide, rain receding
			{
				"position": Vector3(0, -15, 2.0),
				"look_at": Vector3(2, 10, 8),
				"duration": 2.0,
				"fov": 58.0,
			},
			# Tilt up to reveal rainbow arc forming
			{
				"position": Vector3(0, -12, 3.5),
				"look_at": Vector3(3, 8, 14),
				"duration": 2.4,
				"fov": 54.0,
			},
			# Gentle circle around the arc
			{
				"position": Vector3(-6, -8, 4.0),
				"look_at": Vector3(2, 5, 12),
				"duration": 2.0,
				"fov": 56.0,
			},
			# Final framing: hero silhouetted under the arc
			{
				"position": Vector3(-4, -5, 2.2),
				"look_at": Vector3(0, 0, 1.4),
				"duration": 1.8,
				"fov": 50.0,
			},
		],
	},
}


## Returns the keyframe dict for a cinematic id, or empty if unknown.
static func get_cinematic(cinematic_id: StringName) -> Dictionary:
	return CINEMATICS.get(cinematic_id, {}).duplicate(true)


## Returns the total duration in seconds (sum of keyframe durations + 0.5 pad).
static func get_duration(cinematic_id: StringName) -> float:
	var entry: Dictionary = CINEMATICS.get(cinematic_id, {})
	if entry.is_empty():
		return 0.0
	var total: float = 0.5
	for kf in entry.get("keyframes", []):
		total += float(kf.get("duration", 0.0))
	return total


## Returns all registered cinematic ids (for hookup validators).
static func get_all_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for key in CINEMATICS.keys():
		ids.append(key)
	return ids
