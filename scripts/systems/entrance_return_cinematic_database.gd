class_name EntranceReturnCinematicDatabase
extends RefCounted

## Per-entrance "return idle" cinematic — the brief, no-letterbox camera
## flourish that plays the SECOND-or-later time the player approaches a
## dungeon entrance. Where the first-time cinematic is a story beat
## (held shots, dialogue, sealed reveal), the return idle is a 2-3
## second moment that says "you've been here before, here's the mood
## right now."
##
## Unlike the cinematic reveal database, return idles can play multiple
## times — they're throttled to once per in-game day per entrance so
## the player isn't bombarded if they walk back and forth.
##
## Each entry is a small 2-3 keyframe camera path that lerps from the
## player's current camera state to the idle pose and back. No
## letterbox, no dialogue, no story flag — just a small grace note.

const RETURN_IDLES: Dictionary = {
	&"server_room": {
		"display_name": "Server Hum",
		"description": "Brief tilt up the cold blue arch as you near it.",
		"keyframes": [
			{"position": Vector3(-43, 1, -78), "look_at": Vector3(-45, 4, -90), "duration": 1.2, "fov": 60.0},
			{"position": Vector3(-44, 4, -82), "look_at": Vector3(-45, 6, -90), "duration": 1.5, "fov": 55.0},
		],
		"sfx_id": &"sfx_server_hum_swell",
		"music_sting": &"",  # subtle — no sting on return
		"cooldown_hours": 24,
	},
	&"memory_vaults": {
		"display_name": "Vault Whisper",
		"description": "Slow drift past the gold archway as it catches the light.",
		"keyframes": [
			{"position": Vector3(-12, 2, -78), "look_at": Vector3(-15, 3, -90), "duration": 1.3, "fov": 60.0},
			{"position": Vector3(-18, 2, -78), "look_at": Vector3(-15, 3, -90), "duration": 1.7, "fov": 55.0},
		],
		"sfx_id": &"sfx_vault_dust_motes",
		"music_sting": &"",
		"cooldown_hours": 24,
	},
	&"corrupted_wilds": {
		"display_name": "Wilds Breath",
		"description": "Camera dips into the spores and out — a brief brush.",
		"keyframes": [
			{"position": Vector3(13, 2, -78), "look_at": Vector3(15, 3, -90), "duration": 1.2, "fov": 60.0},
			{"position": Vector3(15, 1, -83), "look_at": Vector3(15, 3, -90), "duration": 1.6, "fov": 50.0},
		],
		"sfx_id": &"sfx_spore_drift",
		"music_sting": &"",
		"cooldown_hours": 24,
	},
	&"final_vault": {
		"display_name": "Sealed Watch",
		"description": "Brief look at the seals — never the same number twice.",
		"keyframes": [
			{"position": Vector3(43, 2, -78), "look_at": Vector3(45, 4, -90), "duration": 1.5, "fov": 55.0},
			{"position": Vector3(45, 6, -80), "look_at": Vector3(45, 4, -90), "duration": 2.0, "fov": 45.0},
		],
		"sfx_id": &"sfx_void_shimmer_swell",
		"music_sting": &"sting_final_vault_check",  # the only return idle that DOES sting
		"cooldown_hours": 12,  # half-day so the player notices the seal change
	},
}


static func get_idle(entrance_id: StringName) -> Dictionary:
	return RETURN_IDLES.get(entrance_id, {})


static func get_count() -> int:
	return RETURN_IDLES.size()
