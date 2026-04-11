class_name SoundtrackDatabase
extends RefCounted

## Soundtrack Database (Epic 46 tasks 1-34, 46, 49).
##
## Hosts the full spec for all 33 original soundtrack tracks. Each entry
## defines the artistic brief that a composer (or AI music generation tool)
## must deliver against:
##   - id, title, duration_target_seconds, mood, key, bpm, instrumentation
##   - scene_tags (where this track plays)
##   - reference_artist (for vibe matching)
##   - file_path (where the final WAV/OGG lives)
##   - attribution (composer/AI tool credit)
##
## Used by:
##   - MusicManager to load + play tracks
##   - Coverage validator (task 46) to ensure no scene is missing music
##   - Credits screen (task 49) to display all attributions

const TRACKS: Dictionary = {
	# === Town & Districts (1-8) ===
	&"town_main_theme": {
		"title": "Enth Theme",
		"duration_target": 180,
		"mood": "warm, hopeful, settled",
		"key": "C major", "bpm": 92,
		"instrumentation": ["acoustic guitar", "piano", "soft strings", "wood flute"],
		"scene_tags": [&"town_central", &"town_day"],
		"reference": "Stardew Valley town theme",
		"file_path": "res://audio/music/town_main_theme.ogg",
	},
	&"town_night": {
		"title": "Enth After Dark",
		"duration_target": 150,
		"mood": "soft, intimate, nocturnal",
		"key": "A minor", "bpm": 78,
		"instrumentation": ["nylon guitar", "soft pad", "distant bell", "vinyl crackle"],
		"scene_tags": [&"town_central", &"town_night"],
		"reference": "Animal Crossing 2am",
		"file_path": "res://audio/music/town_night.ogg",
	},
	&"residential_ambient": {
		"title": "Quiet Streets",
		"duration_target": 120,
		"mood": "homely, lived-in",
		"key": "F major", "bpm": 84,
		"instrumentation": ["piano", "bowed strings", "soft chimes"],
		"scene_tags": [&"residential_district"],
		"reference": "Spiritfarer hub themes",
		"file_path": "res://audio/music/residential_ambient.ogg",
	},
	&"market_ambient": {
		"title": "Market Day",
		"duration_target": 130,
		"mood": "lively, bustling",
		"key": "G major", "bpm": 110,
		"instrumentation": ["mandolin", "hand drums", "fiddle", "whistle"],
		"scene_tags": [&"market_district"],
		"reference": "Witcher 3 Novigrad market",
		"file_path": "res://audio/music/market_ambient.ogg",
	},
	&"commons_ambient": {
		"title": "Town Square",
		"duration_target": 140,
		"mood": "communal, celebratory",
		"key": "D major", "bpm": 96,
		"instrumentation": ["acoustic guitar", "fiddle", "tambourine", "soft accordion"],
		"scene_tags": [&"commons_district"],
		"reference": "Hollow Knight Dirtmouth",
		"file_path": "res://audio/music/commons_ambient.ogg",
	},
	&"workshop_ambient": {
		"title": "Hammer Song",
		"duration_target": 120,
		"mood": "industrious, rhythmic",
		"key": "E minor", "bpm": 100,
		"instrumentation": ["anvil hits", "low drums", "bass plucks", "metallic chimes"],
		"scene_tags": [&"workshop_district"],
		"reference": "Bastion forge tracks",
		"file_path": "res://audio/music/workshop_ambient.ogg",
	},
	&"docks_ambient": {
		"title": "Salt Wind",
		"duration_target": 130,
		"mood": "nautical, melancholic",
		"key": "D minor", "bpm": 70,
		"instrumentation": ["accordion", "wave SFX bed", "soft strings", "seagulls"],
		"scene_tags": [&"docks_district"],
		"reference": "Sea of Thieves shanty",
		"file_path": "res://audio/music/docks_ambient.ogg",
	},

	# === Wilderness (9-10) ===
	&"wilderness_day": {
		"title": "Open Skies",
		"duration_target": 180,
		"mood": "expansive, adventurous",
		"key": "G major", "bpm": 100,
		"instrumentation": ["epic strings", "horns", "wood flute", "soft choir"],
		"scene_tags": [&"wilderness", &"day"],
		"reference": "Skyrim wilderness exploration",
		"file_path": "res://audio/music/wilderness_day.ogg",
	},
	&"wilderness_night": {
		"title": "Under Star",
		"duration_target": 160,
		"mood": "haunting, vast",
		"key": "A minor", "bpm": 75,
		"instrumentation": ["soft strings", "harp", "low pad", "night bird calls"],
		"scene_tags": [&"wilderness", &"night"],
		"reference": "Outer Wilds night",
		"file_path": "res://audio/music/wilderness_night.ogg",
	},

	# === Dungeon Biomes (11-14) ===
	&"server_room_theme": {
		"title": "Cold Compute",
		"duration_target": 200,
		"mood": "cold, mechanical, mysterious",
		"key": "F# minor", "bpm": 85,
		"instrumentation": ["synth pad", "metallic clicks", "deep bass drone", "data hums"],
		"scene_tags": [&"server_room"],
		"reference": "TRON: Legacy",
		"file_path": "res://audio/music/server_room_theme.ogg",
	},
	&"memory_vaults_theme": {
		"title": "Forgotten Pages",
		"duration_target": 200,
		"mood": "ancient, contemplative, sacred",
		"key": "E minor", "bpm": 70,
		"instrumentation": ["organ", "low strings", "distant bells", "whispered choir"],
		"scene_tags": [&"memory_vaults"],
		"reference": "Hollow Knight City of Tears",
		"file_path": "res://audio/music/memory_vaults_theme.ogg",
	},
	&"corrupted_wilds_theme": {
		"title": "Twisted Roots",
		"duration_target": 200,
		"mood": "uneasy, organic, corrupted",
		"key": "D minor", "bpm": 90,
		"instrumentation": ["detuned strings", "low woodwinds", "creaking wood", "distorted choir"],
		"scene_tags": [&"corrupted_wilds"],
		"reference": "Bloodborne forest",
		"file_path": "res://audio/music/corrupted_wilds_theme.ogg",
	},
	&"final_vault_theme": {
		"title": "Last Iteration",
		"duration_target": 220,
		"mood": "epic, final, climactic",
		"key": "C minor", "bpm": 105,
		"instrumentation": ["full orchestra", "choir", "deep brass", "percussion"],
		"scene_tags": [&"boss_sanctum", &"final_vault"],
		"reference": "Dark Souls Gwyn theme",
		"file_path": "res://audio/music/final_vault_theme.ogg",
	},

	# === Combat Layers (15-17) ===
	&"combat_layer_1_light": {
		"title": "Skirmish",
		"duration_target": 90,
		"mood": "tense, alert",
		"key": "E minor", "bpm": 110,
		"instrumentation": ["light percussion", "tense strings", "low pulse"],
		"scene_tags": [&"combat_low_intensity"],
		"file_path": "res://audio/music/combat_layer_1.ogg",
	},
	&"combat_layer_2_mid": {
		"title": "Engagement",
		"duration_target": 100,
		"mood": "active, urgent",
		"key": "E minor", "bpm": 130,
		"instrumentation": ["full drums", "string ostinato", "brass stabs"],
		"scene_tags": [&"combat_mid_intensity"],
		"file_path": "res://audio/music/combat_layer_2.ogg",
	},
	&"combat_layer_3_intense": {
		"title": "Onslaught",
		"duration_target": 110,
		"mood": "frenetic, do-or-die",
		"key": "E minor", "bpm": 150,
		"instrumentation": ["full orchestra", "heavy percussion", "synth lead", "choir shouts"],
		"scene_tags": [&"combat_high_intensity"],
		"file_path": "res://audio/music/combat_layer_3.ogg",
	},

	# === Boss Music (18-24) ===
	&"boss_intro_stinger": {
		"title": "Awaken",
		"duration_target": 8,
		"mood": "menacing, sudden",
		"key": "C minor", "bpm": 60,
		"instrumentation": ["brass hit", "low choir", "deep tom"],
		"scene_tags": [&"boss_intro"],
		"file_path": "res://audio/music/boss_intro_stinger.ogg",
	},
	&"compiler_boss_theme": {
		"title": "The First Compiler",
		"duration_target": 240,
		"mood": "grand, ancient, powerful",
		"key": "D minor", "bpm": 120,
		"instrumentation": ["epic orchestra", "synth lead", "choir"],
		"scene_tags": [&"boss_compiler"],
		"reference": "DOOM Mick Gordon style",
		"file_path": "res://audio/music/compiler_boss_theme.ogg",
	},
	&"memory_warden_theme": {
		"title": "Pages of Iron",
		"duration_target": 200,
		"mood": "regal, weighty",
		"key": "B minor", "bpm": 95,
		"instrumentation": ["full orchestra", "organ", "deep choir"],
		"scene_tags": [&"boss_memory_warden"],
		"file_path": "res://audio/music/memory_warden_theme.ogg",
	},
	&"root_heart_theme": {
		"title": "Beating Bark",
		"duration_target": 200,
		"mood": "organic, rhythmic, primal",
		"key": "E minor", "bpm": 80,
		"instrumentation": ["tribal drums", "low woodwinds", "distorted strings"],
		"scene_tags": [&"boss_root_heart"],
		"file_path": "res://audio/music/root_heart_theme.ogg",
	},
	&"sentinel_prime_theme": {
		"title": "Three Eyes Watching",
		"duration_target": 220,
		"mood": "industrial, oppressive, mechanical",
		"key": "F# minor", "bpm": 130,
		"instrumentation": ["industrial synths", "metallic percussion", "brass stabs"],
		"scene_tags": [&"boss_sentinel_prime"],
		"file_path": "res://audio/music/sentinel_prime_theme.ogg",
	},
	&"iteration_phantom_theme": {
		"title": "Mirror Dance",
		"duration_target": 210,
		"mood": "uncanny, unsettling, fast",
		"key": "A minor", "bpm": 140,
		"instrumentation": ["string ostinato", "synth lead", "choir whispers", "glitch SFX"],
		"scene_tags": [&"boss_iteration_phantom"],
		"file_path": "res://audio/music/iteration_phantom_theme.ogg",
	},
	&"compiler_reborn_theme": {
		"title": "Loop Closes",
		"duration_target": 300,
		"mood": "epic, climactic, transcendent",
		"key": "C minor", "bpm": 110,
		"instrumentation": ["full orchestra", "epic choir", "deep brass", "synth pad", "tribal percussion"],
		"scene_tags": [&"boss_compiler_reborn", &"final_boss"],
		"reference": "Final Fantasy XIV final boss",
		"file_path": "res://audio/music/compiler_reborn_theme.ogg",
	},

	# === Stings & Misc (25-34) ===
	&"victory_fanfare": {
		"title": "Iteration Sealed",
		"duration_target": 12,
		"mood": "triumphant, brief",
		"key": "C major", "bpm": 120,
		"instrumentation": ["brass fanfare", "timpani", "choir"],
		"scene_tags": [&"victory"],
		"file_path": "res://audio/music/victory_fanfare.ogg",
	},
	&"defeat_sting": {
		"title": "Run Aborted",
		"duration_target": 8,
		"mood": "somber, finality",
		"key": "A minor", "bpm": 60,
		"instrumentation": ["low strings", "bell toll", "single piano note"],
		"scene_tags": [&"defeat"],
		"file_path": "res://audio/music/defeat_sting.ogg",
	},
	&"levelup_sting": {
		"title": "Iteration Up",
		"duration_target": 4,
		"mood": "celebratory, brief",
		"key": "G major", "bpm": 140,
		"instrumentation": ["chimes", "harp glissando", "bright pad"],
		"scene_tags": [&"levelup"],
		"file_path": "res://audio/music/levelup_sting.ogg",
	},
	&"iteration_reset_theme": {
		"title": "Restart the Loop",
		"duration_target": 60,
		"mood": "ethereal, transitional",
		"key": "F# major", "bpm": 60,
		"instrumentation": ["pad", "soft choir", "bell tones", "reverb-heavy piano"],
		"scene_tags": [&"iteration_reset_cinematic"],
		"file_path": "res://audio/music/iteration_reset_theme.ogg",
	},
	&"main_menu_theme": {
		"title": "Welcome Back",
		"duration_target": 180,
		"mood": "inviting, mysterious",
		"key": "D minor", "bpm": 88,
		"instrumentation": ["piano", "soft strings", "wind chimes", "ambient pad"],
		"scene_tags": [&"main_menu"],
		"reference": "Hades main menu",
		"file_path": "res://audio/music/main_menu_theme.ogg",
	},
	&"credits_theme": {
		"title": "All The Iterations",
		"duration_target": 240,
		"mood": "warm, nostalgic, conclusive",
		"key": "C major", "bpm": 84,
		"instrumentation": ["full ensemble", "piano lead", "soft choir", "epic finale"],
		"scene_tags": [&"credits"],
		"file_path": "res://audio/music/credits_theme.ogg",
	},
	&"dialogue_ambient": {
		"title": "Conversation Bed",
		"duration_target": 120,
		"mood": "soft, non-intrusive",
		"key": "C major", "bpm": 70,
		"instrumentation": ["soft pad", "single piano", "subtle strings"],
		"scene_tags": [&"dialogue_active"],
		"file_path": "res://audio/music/dialogue_ambient.ogg",
	},
	&"tavern_music": {
		"title": "Cache's Bar",
		"duration_target": 150,
		"mood": "warm, social, slightly tipsy",
		"key": "G major", "bpm": 105,
		"instrumentation": ["acoustic guitar", "harmonica", "soft fiddle", "bar chatter bed"],
		"scene_tags": [&"tavern", &"underground_lounge"],
		"file_path": "res://audio/music/tavern_music.ogg",
	},
	&"forge_music": {
		"title": "Forge's Hammer",
		"duration_target": 120,
		"mood": "industrious, focused",
		"key": "E minor", "bpm": 110,
		"instrumentation": ["anvil hits as percussion", "low drums", "metallic resonance"],
		"scene_tags": [&"forge_workshop"],
		"file_path": "res://audio/music/forge_music.ogg",
	},
	&"archive_music": {
		"title": "Index's Library",
		"duration_target": 150,
		"mood": "studious, calm",
		"key": "F major", "bpm": 75,
		"instrumentation": ["harpsichord", "soft strings", "page-turn SFX bed"],
		"scene_tags": [&"index_library", &"sage_library"],
		"file_path": "res://audio/music/archive_music.ogg",
	},
}


static func get_track(track_id: StringName) -> Dictionary:
	return TRACKS.get(track_id, {}).duplicate(true)


static func get_all_track_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for k in TRACKS.keys():
		ids.append(k)
	return ids


static func get_tracks_for_scene(scene_tag: StringName) -> Array[StringName]:
	var matching: Array[StringName] = []
	for tid in TRACKS.keys():
		var t: Dictionary = TRACKS[tid]
		if t.get("scene_tags", []).has(scene_tag):
			matching.append(tid)
	return matching


static func get_total_duration_target() -> int:
	var total: int = 0
	for tid in TRACKS.keys():
		total += int(TRACKS[tid].get("duration_target", 0))
	return total


# === TASK 46: Coverage validator ===
## Verifies every required scene tag has at least one music track.
static func validate_coverage(required_scene_tags: Array[StringName]) -> Dictionary:
	var report: Dictionary = {
		"covered": [],
		"uncovered": [],
		"track_count": TRACKS.size(),
		"total_duration_target": get_total_duration_target(),
	}
	for tag in required_scene_tags:
		var tracks: Array[StringName] = get_tracks_for_scene(tag)
		if tracks.is_empty():
			report["uncovered"].append(tag)
		else:
			report["covered"].append({"tag": tag, "tracks": tracks})
	return report


# === TASK 49: Attribution credits ===
const ATTRIBUTIONS: Array[Dictionary] = [
	{"role": "Original Compositions", "credit": "AI music generation pipeline (Suno / Udio / placeholder)"},
	{"role": "Theme Coordinator", "credit": "Enth: Iteration Audio Direction"},
	{"role": "Mastering", "credit": "In-engine via AudioBus EQ + Compressor"},
	{"role": "License", "credit": "All tracks composed/generated for Enth: Iteration. CC-BY for any AI-tool stems."},
]


static func get_attribution_credits() -> Array[Dictionary]:
	return ATTRIBUTIONS.duplicate(true)
