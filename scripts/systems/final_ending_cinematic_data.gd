class_name FinalEndingCinematicData
extends RefCounted

## Final Ending + Closing Polish Cinematic Data (Epic 49 tasks 27, 35, 47).
##
## Hosts the keyframe-level data for the final ending cinematic and the
## polished closing cinematic. Companion to CinematicDatabase (which has
## the metadata) — this file holds the actual playable timelines.

const FINAL_ENDING_CINEMATIC: Dictionary = {
	"id": &"final_ending",
	"letterbox": true,
	"music_track": &"music_credits_theme",
	"music_sting": &"music_sting_iteration_complete",
	"sfx_id": &"sfx_iteration_seal",
	"keyframes": [
		# Slow zoom on the Compiler Reborn collapsing
		{
			"position": Vector3(0, -10, 4),
			"look_at": Vector3(0, 2, 3),
			"duration": 3.0,
			"fov": 50.0,
			"dof_focus": 5.0, "dof_amount": 0.4,
		},
		# Crane down to the central altar
		{
			"position": Vector3(0, -3, 2),
			"look_at": Vector3(0, 0, 1),
			"duration": 2.6,
			"fov": 42.0,
			"dof_focus": 1.5, "dof_amount": 0.6,
		},
		# Globbler's silhouette walking forward
		{
			"position": Vector3(-4, -5, 1.6),
			"look_at": Vector3(0, 0, 1.4),
			"duration": 2.4,
			"fov": 48.0,
			"dof_focus": 4.0, "dof_amount": 0.5,
		},
		# Wide reveal of empty arena
		{
			"position": Vector3(0, -16, 8),
			"look_at": Vector3(0, 0, 2),
			"duration": 3.0,
			"fov": 65.0,
			"dof_focus": 12.0, "dof_amount": 0.3,
		},
		# Sky tilt — light pouring down from above
		{
			"position": Vector3(0, -2, 3),
			"look_at": Vector3(0, 0, 14),
			"duration": 2.8,
			"fov": 70.0,
			"dof_focus": 8.0, "dof_amount": 0.2,
		},
		# White-out fade
		{
			"position": Vector3(0, -2, 3),
			"look_at": Vector3(0, 0, 14),
			"duration": 1.8,
			"fov": 70.0,
			"dof_focus": 8.0, "dof_amount": 0.0,
		},
	],
	"subtitles": [
		{"time": 0.0, "duration": 3.0, "text": "The Compiler falls. The cycle ends."},
		{"time": 3.0, "duration": 2.6, "text": "And yet, the iteration is not over."},
		{"time": 5.6, "duration": 2.4, "text": "Globbler walks forward into the silence."},
		{"time": 8.0, "duration": 3.0, "text": "Enth waits for the next iteration."},
		{"time": 11.0, "duration": 4.6, "text": "...You were never alone."},
	],
}

const CLOSING_CINEMATIC_POLISH: Dictionary = {
	"id": &"closing_polished",
	"letterbox": true,
	"music_track": &"music_credits_theme",
	"sfx_id": &"sfx_credits_pad",
	"keyframes": [
		# Soft fade-in
		{
			"position": Vector3(0, -8, 3),
			"look_at": Vector3(0, 0, 2),
			"duration": 2.0,
			"fov": 55.0,
			"dof_focus": 6.0, "dof_amount": 0.5,
		},
		# Gentle crane around the empty town square
		{
			"position": Vector3(-6, -6, 4),
			"look_at": Vector3(0, 0, 1.5),
			"duration": 3.0,
			"fov": 50.0,
			"dof_focus": 5.0, "dof_amount": 0.45,
		},
		# Push toward the iteration memorial
		{
			"position": Vector3(0, -5, 2.5),
			"look_at": Vector3(0, 4, 2),
			"duration": 2.6,
			"fov": 46.0,
			"dof_focus": 4.0, "dof_amount": 0.5,
		},
		# Final hold: 9 candles burning
		{
			"position": Vector3(0, -2, 1.5),
			"look_at": Vector3(0, 2, 1.2),
			"duration": 4.0,
			"fov": 38.0,
			"dof_focus": 3.0, "dof_amount": 0.6,
		},
	],
	"subtitles": [
		{"time": 0.0, "duration": 5.0, "text": "Each iteration leaves a candle."},
		{"time": 5.0, "duration": 3.0, "text": "Each candle is remembered."},
		{"time": 8.0, "duration": 3.6, "text": "And so the loop continues — for now."},
	],
}


static func get_final_ending() -> Dictionary:
	return FINAL_ENDING_CINEMATIC.duplicate(true)


static func get_closing_polish() -> Dictionary:
	return CLOSING_CINEMATIC_POLISH.duplicate(true)


static func get_total_duration(cinematic: Dictionary) -> float:
	var total: float = 0.0
	for kf in cinematic.get("keyframes", []):
		total += float(kf.get("duration", 0.0))
	return total


# === TASK 47: Full cinematic playback test harness ===
## Walks every cinematic and reports keyframe count, duration, subtitle
## count, and broken-keyframe flags. Used in test scenes only.
static func run_full_playback_test(extra_cinematics: Array[Dictionary] = []) -> Dictionary:
	var report: Dictionary = {
		"cinematics_tested": [],
		"failures": [],
		"all_pass": true,
	}
	var to_test: Array[Dictionary] = [FINAL_ENDING_CINEMATIC, CLOSING_CINEMATIC_POLISH]
	to_test.append_array(extra_cinematics)
	for cine in to_test:
		var entry: Dictionary = {
			"id": cine.get("id", &"unknown"),
			"keyframe_count": cine.get("keyframes", []).size(),
			"subtitle_count": cine.get("subtitles", []).size(),
			"duration": get_total_duration(cine),
			"has_music": cine.get("music_track", &"") != &"",
			"has_letterbox": cine.get("letterbox", false),
		}
		var broken: int = 0
		for kf in cine.get("keyframes", []):
			for required in ["position", "look_at", "duration", "fov"]:
				if not kf.has(required):
					broken += 1
					break
		entry["broken_keyframes"] = broken
		entry["passed"] = broken == 0 and entry["keyframe_count"] > 0
		if not bool(entry["passed"]):
			report["failures"].append(entry["id"])
			report["all_pass"] = false
		report["cinematics_tested"].append(entry)
	return report
