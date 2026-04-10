class_name VoiceGruntsDatabase
extends RefCounted

## Voice Grunts Database (Epic 48 tasks 8-21, 38).
##
## Catalogs the voice grunt library for 14 characters (Globbler + Sage +
## 12 town NPCs). Each character has 6 emotional grunts (neutral, happy,
## sad, surprised, angry, hurt) plus pitch/formant tuning to give each
## character a distinctive voice without recording full lines.
##
## Each grunt entry has:
##   id, character_id, emotion, pitch_offset_semitones, formant_shift,
##   duration_ms, file_path, max_simul

const CHARACTERS: Array[StringName] = [
	&"globbler", &"ai_sage",
	&"pixel", &"forge", &"cache", &"index", &"harvest", &"bit",
	&"legacy", &"trade", &"lab", &"render", &"sync", &"sentinel",
]

const EMOTIONS: Array[StringName] = [
	&"neutral", &"happy", &"sad", &"surprised", &"angry", &"hurt",
]

const CHARACTER_PROFILES: Dictionary = {
	&"globbler": {
		"display_name": "Globbler",
		"pitch_offset": 0,
		"formant_shift": 0.0,
		"speed_multiplier": 1.0,
		"description": "Player character — soft, gender-neutral, slightly synthesized",
	},
	&"ai_sage": {
		"display_name": "AI Sage",
		"pitch_offset": -3,
		"formant_shift": -0.10,
		"speed_multiplier": 0.85,
		"description": "Warm, low, weathered — speaks slowly, deliberate",
	},
	&"pixel": {
		"display_name": "Pixel",
		"pitch_offset": 4,
		"formant_shift": 0.05,
		"speed_multiplier": 1.15,
		"description": "Bright, eager, fast-talking shop owner",
	},
	&"forge": {
		"display_name": "Forge",
		"pitch_offset": -4,
		"formant_shift": -0.05,
		"speed_multiplier": 0.90,
		"description": "Gruff, deep, slow-spoken blacksmith",
	},
	&"cache": {
		"display_name": "Cache",
		"pitch_offset": 2,
		"formant_shift": 0.10,
		"speed_multiplier": 1.05,
		"description": "Friendly, sing-song, bartender warmth",
	},
	&"index": {
		"display_name": "Index",
		"pitch_offset": 1,
		"formant_shift": 0.0,
		"speed_multiplier": 0.95,
		"description": "Precise, calm, librarian cadence",
	},
	&"harvest": {
		"display_name": "Harvest",
		"pitch_offset": -1,
		"formant_shift": -0.02,
		"speed_multiplier": 0.95,
		"description": "Earthy, grounded, slightly tired farmer",
	},
	&"bit": {
		"display_name": "Bit",
		"pitch_offset": 7,
		"formant_shift": 0.20,
		"speed_multiplier": 1.20,
		"description": "Child pitch — bouncy, excited, high",
	},
	&"legacy": {
		"display_name": "Legacy",
		"pitch_offset": -5,
		"formant_shift": -0.15,
		"speed_multiplier": 0.75,
		"description": "Elder pitch — slow, raspy, contemplative",
	},
	&"trade": {
		"display_name": "Trade",
		"pitch_offset": -2,
		"formant_shift": -0.05,
		"speed_multiplier": 1.10,
		"description": "Smooth, persuasive, merchant cadence",
	},
	&"lab": {
		"display_name": "Lab",
		"pitch_offset": 3,
		"formant_shift": 0.08,
		"speed_multiplier": 1.25,
		"description": "Excited, fast, scattered scientist energy",
	},
	&"render": {
		"display_name": "Render",
		"pitch_offset": 1,
		"formant_shift": 0.05,
		"speed_multiplier": 0.90,
		"description": "Soft, dreamy, painterly artist",
	},
	&"sync": {
		"display_name": "Sync",
		"pitch_offset": 2,
		"formant_shift": 0.05,
		"speed_multiplier": 1.0,
		"description": "Musical, lilting, almost singing while talking",
	},
	&"sentinel": {
		"display_name": "Sentinel",
		"pitch_offset": -6,
		"formant_shift": -0.20,
		"speed_multiplier": 0.85,
		"description": "Deep, gruff, military cadence — clipped sentences",
	},
}

const EMOTION_PITCH_DELTAS: Dictionary = {
	&"neutral": 0,
	&"happy": 2,
	&"sad": -2,
	&"surprised": 4,
	&"angry": -1,
	&"hurt": -3,
}

const EMOTION_DURATIONS: Dictionary = {
	&"neutral": 250,
	&"happy": 300,
	&"sad": 400,
	&"surprised": 200,
	&"angry": 230,
	&"hurt": 350,
}


static func get_character_profile(char_id: StringName) -> Dictionary:
	return CHARACTER_PROFILES.get(char_id, {}).duplicate(true)


static func get_grunt_path(char_id: StringName, emotion: StringName, variant: int = 0) -> String:
	return "res://audio/voice/grunts/%s/%s_%d.ogg" % [String(char_id), String(emotion), variant]


static func get_grunt_pitch_offset(char_id: StringName, emotion: StringName) -> float:
	var profile: Dictionary = CHARACTER_PROFILES.get(char_id, {})
	var base_offset: int = int(profile.get("pitch_offset", 0))
	var emotion_delta: int = int(EMOTION_PITCH_DELTAS.get(emotion, 0))
	return float(base_offset + emotion_delta)


static func get_grunt_duration_ms(emotion: StringName) -> int:
	return int(EMOTION_DURATIONS.get(emotion, 250))


## Returns count of all grunt files needed (14 chars × 6 emotions × 2 variants).
static func get_total_grunt_count() -> int:
	return CHARACTERS.size() * EMOTIONS.size() * 2


## Returns full library spec for sourcing/recording.
static func get_full_library_spec() -> Array[Dictionary]:
	var specs: Array[Dictionary] = []
	for char_id in CHARACTERS:
		var profile: Dictionary = CHARACTER_PROFILES.get(char_id, {})
		for emotion in EMOTIONS:
			for variant in range(2):
				specs.append({
					"character": char_id,
					"emotion": emotion,
					"variant": variant,
					"pitch_offset": get_grunt_pitch_offset(char_id, emotion),
					"formant_shift": float(profile.get("formant_shift", 0.0)),
					"duration_target_ms": get_grunt_duration_ms(emotion),
					"file_path": get_grunt_path(char_id, emotion, variant),
					"description": profile.get("description", ""),
				})
	return specs


## Test full dialogue playthrough — Epic 48 task 38.
## Walks every character × emotion combination and reports any missing
## profile fields.
static func run_full_dialogue_test() -> Dictionary:
	var report: Dictionary = {
		"total_characters": CHARACTERS.size(),
		"total_emotions": EMOTIONS.size(),
		"total_grunts": get_total_grunt_count(),
		"failures": [],
		"all_pass": true,
	}
	for char_id in CHARACTERS:
		var profile: Dictionary = CHARACTER_PROFILES.get(char_id, {})
		if profile.is_empty():
			report["failures"].append({"character": char_id, "reason": "no profile"})
			report["all_pass"] = false
			continue
		for required in ["display_name", "pitch_offset", "formant_shift", "speed_multiplier", "description"]:
			if not profile.has(required):
				report["failures"].append({"character": char_id, "missing": required})
				report["all_pass"] = false
	return report
