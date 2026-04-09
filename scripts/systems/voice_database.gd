class_name VoiceDatabase
extends RefCounted

## Static catalog of per-NPC voice configurations and grunt pools.
## Each NPC entry has pitch, speed, reverb, font, and 6 emotion grunts.

const NPC_VOICES: Array = [
	{
		"npc_id": &"globbler",
		"display_name": "Globbler",
		"pitch": 1.05,
		"text_speed_cps": 30.0,
		"reverb": &"dry",
		"font": &"default",
		"volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"globbler_grunt_neutral_01", &"globbler_grunt_neutral_02", &"globbler_grunt_neutral_03"],
			&"happy":       [&"globbler_grunt_happy_01", &"globbler_grunt_happy_02"],
			&"sad":         [&"globbler_grunt_sad_01"],
			&"surprised":   [&"globbler_grunt_surprised_01"],
			&"angry":       [&"globbler_grunt_angry_01"],
			&"questioning": [&"globbler_grunt_question_01"],
		},
	},
	{
		"npc_id": &"sage",
		"display_name": "AI Sage",
		"pitch": 0.85,
		"text_speed_cps": 20.0,
		"reverb": &"hall",
		"font": &"serif",
		"volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"sage_grunt_neutral_01", &"sage_grunt_neutral_02", &"sage_grunt_neutral_03"],
			&"happy":       [&"sage_grunt_happy_01"],
			&"sad":         [&"sage_grunt_sad_01"],
			&"surprised":   [&"sage_grunt_surprised_01"],
			&"angry":       [&"sage_grunt_angry_01"],
			&"questioning": [&"sage_grunt_question_01"],
		},
	},
	{
		"npc_id": &"pixel", "display_name": "Pixel", "pitch": 1.10, "text_speed_cps": 35.0, "reverb": &"dry", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"pixel_grunt_01", &"pixel_grunt_02", &"pixel_grunt_03"],
			&"happy":       [&"pixel_happy_01"],
			&"sad":         [&"pixel_sad_01"],
			&"surprised":   [&"pixel_surprised_01"],
			&"angry":       [&"pixel_angry_01"],
			&"questioning": [&"pixel_question_01"],
		},
	},
	{
		"npc_id": &"forge", "display_name": "Forge", "pitch": 0.90, "text_speed_cps": 25.0, "reverb": &"room", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"forge_grunt_01", &"forge_grunt_02", &"forge_grunt_03"],
			&"happy":       [&"forge_happy_01"],
			&"sad":         [&"forge_sad_01"],
			&"surprised":   [&"forge_surprised_01"],
			&"angry":       [&"forge_angry_01"],
			&"questioning": [&"forge_question_01"],
		},
	},
	{
		"npc_id": &"cache", "display_name": "Cache", "pitch": 1.00, "text_speed_cps": 30.0, "reverb": &"room", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"cache_grunt_01", &"cache_grunt_02", &"cache_grunt_03"],
			&"happy":       [&"cache_happy_01"],
			&"sad":         [&"cache_sad_01"],
			&"surprised":   [&"cache_surprised_01"],
			&"angry":       [&"cache_angry_01"],
			&"questioning": [&"cache_question_01"],
		},
	},
	{
		"npc_id": &"index", "display_name": "Index", "pitch": 0.95, "text_speed_cps": 28.0, "reverb": &"hall", "font": &"default", "volume_db": -1.0,
		"grunts": {
			&"neutral":     [&"index_grunt_01", &"index_grunt_02", &"index_grunt_03"],
			&"happy":       [&"index_happy_01"],
			&"sad":         [&"index_sad_01"],
			&"surprised":   [&"index_surprised_01"],
			&"angry":       [&"index_angry_01"],
			&"questioning": [&"index_question_01"],
		},
	},
	{
		"npc_id": &"harvest", "display_name": "Harvest", "pitch": 1.00, "text_speed_cps": 30.0, "reverb": &"dry", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"harvest_grunt_01", &"harvest_grunt_02", &"harvest_grunt_03"],
			&"happy":       [&"harvest_happy_01"],
			&"sad":         [&"harvest_sad_01"],
			&"surprised":   [&"harvest_surprised_01"],
			&"angry":       [&"harvest_angry_01"],
			&"questioning": [&"harvest_question_01"],
		},
	},
	{
		"npc_id": &"bit", "display_name": "Bit", "pitch": 1.30, "text_speed_cps": 40.0, "reverb": &"dry", "font": &"rounded", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"bit_grunt_01", &"bit_grunt_02", &"bit_grunt_03"],
			&"happy":       [&"bit_happy_01", &"bit_happy_02"],
			&"sad":         [&"bit_sad_01"],
			&"surprised":   [&"bit_surprised_01"],
			&"angry":       [&"bit_angry_01"],
			&"questioning": [&"bit_question_01"],
		},
	},
	{
		"npc_id": &"legacy", "display_name": "Legacy", "pitch": 0.80, "text_speed_cps": 18.0, "reverb": &"hall", "font": &"serif", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"legacy_grunt_01", &"legacy_grunt_02", &"legacy_grunt_03"],
			&"happy":       [&"legacy_happy_01"],
			&"sad":         [&"legacy_sad_01"],
			&"surprised":   [&"legacy_surprised_01"],
			&"angry":       [&"legacy_angry_01"],
			&"questioning": [&"legacy_question_01"],
		},
	},
	{
		"npc_id": &"trade", "display_name": "Trade", "pitch": 1.05, "text_speed_cps": 32.0, "reverb": &"dry", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"trade_grunt_01", &"trade_grunt_02", &"trade_grunt_03"],
			&"happy":       [&"trade_happy_01"],
			&"sad":         [&"trade_sad_01"],
			&"surprised":   [&"trade_surprised_01"],
			&"angry":       [&"trade_angry_01"],
			&"questioning": [&"trade_question_01"],
		},
	},
	{
		"npc_id": &"lab", "display_name": "Lab", "pitch": 1.10, "text_speed_cps": 33.0, "reverb": &"room", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"lab_grunt_01", &"lab_grunt_02", &"lab_grunt_03"],
			&"happy":       [&"lab_happy_01"],
			&"sad":         [&"lab_sad_01"],
			&"surprised":   [&"lab_surprised_01"],
			&"angry":       [&"lab_angry_01"],
			&"questioning": [&"lab_question_01"],
		},
	},
	{
		"npc_id": &"render", "display_name": "Render", "pitch": 1.05, "text_speed_cps": 32.0, "reverb": &"dry", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"render_grunt_01", &"render_grunt_02", &"render_grunt_03"],
			&"happy":       [&"render_happy_01"],
			&"sad":         [&"render_sad_01"],
			&"surprised":   [&"render_surprised_01"],
			&"angry":       [&"render_angry_01"],
			&"questioning": [&"render_question_01"],
		},
	},
	{
		"npc_id": &"sync", "display_name": "Sync", "pitch": 1.00, "text_speed_cps": 30.0, "reverb": &"hall", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"sync_grunt_01", &"sync_grunt_02", &"sync_grunt_03"],
			&"happy":       [&"sync_happy_01"],
			&"sad":         [&"sync_sad_01"],
			&"surprised":   [&"sync_surprised_01"],
			&"angry":       [&"sync_angry_01"],
			&"questioning": [&"sync_question_01"],
		},
	},
	{
		"npc_id": &"sentinel", "display_name": "Sentinel", "pitch": 0.85, "text_speed_cps": 26.0, "reverb": &"room", "font": &"default", "volume_db": 0.0,
		"grunts": {
			&"neutral":     [&"sentinel_grunt_01", &"sentinel_grunt_02", &"sentinel_grunt_03"],
			&"happy":       [&"sentinel_happy_01"],
			&"sad":         [&"sentinel_sad_01"],
			&"surprised":   [&"sentinel_surprised_01"],
			&"angry":       [&"sentinel_angry_01"],
			&"questioning": [&"sentinel_question_01"],
		},
	},
]

const REACTIVE_GRUNTS: Dictionary = {
	&"hit_light":  &"globbler_hit_light",
	&"hit_med":    &"globbler_hit_med",
	&"hit_heavy":  &"globbler_hit_heavy",
	&"death":      &"globbler_death",
	&"level_up":   &"globbler_levelup",
	&"surprised":  &"globbler_grunt_surprised_01",
}

const NARRATOR_TRACKS: Dictionary = {
	&"opening":      "res://assets/audio/voice/narrator_opening.ogg",
	&"iter_2":       "res://assets/audio/voice/narrator_iter2.ogg",
	&"iter_5":       "res://assets/audio/voice/narrator_iter5.ogg",
	&"iter_9_end":   "res://assets/audio/voice/narrator_iter9_end.ogg",
}

const COMBAT_CALLOUTS: PackedStringArray = [
	"Behind you!",
	"Look out!",
	"I'll hold them!",
	"On your six!",
	"Got him!",
	"Heads up!",
	"They're coming!",
	"Watch the trap!",
]

const AUDIO_BASE_PATH: String = "res://assets/audio/voice/"

static var _index: Dictionary = {}


static func get_npc_voice(npc_id: StringName) -> Dictionary:
	if _index.is_empty():
		for v in NPC_VOICES:
			_index[v["npc_id"]] = v
	return _index.get(npc_id, {})


static func get_grunt_pool(npc_id: StringName, emotion: StringName = &"neutral") -> Array:
	var v: Dictionary = get_npc_voice(npc_id)
	if v.is_empty():
		return []
	var grunts: Dictionary = v.get("grunts", {})
	return grunts.get(emotion, grunts.get(&"neutral", []))


static func get_random_grunt(npc_id: StringName, emotion: StringName = &"neutral", exclude: StringName = &"") -> StringName:
	var pool: Array = get_grunt_pool(npc_id, emotion)
	if pool.is_empty():
		return &""
	if pool.size() == 1 or exclude == &"":
		return pool[randi() % pool.size()]
	# Exclude the last-played to avoid repetition
	var filtered: Array = []
	for g in pool:
		if g != exclude:
			filtered.append(g)
	if filtered.is_empty():
		return pool[0]
	return filtered[randi() % filtered.size()]


static func get_file_path(grunt_id: StringName) -> String:
	return AUDIO_BASE_PATH + String(grunt_id) + ".ogg"


static func get_random_callout() -> String:
	return COMBAT_CALLOUTS[randi() % COMBAT_CALLOUTS.size()]


static func count_npcs() -> int:
	return NPC_VOICES.size()
