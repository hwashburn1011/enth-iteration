class_name HubAmbientSoundscapeDatabase
extends RefCounted

## Per-hub-space ambient soundscape catalog. Sister system to the
## wilderness AmbientSoundscapeDatabase — where the wilderness mixer
## handles broad regional ambience (cliff wind, ruin stone groans),
## this catalog handles the localized ambient bed for each of the 13
## new hub spaces from the Hub Expansion Bible.
##
## Each space defines a small set of looping SFX layers using the same
## slot conventions as the wilderness mixer (so AmbientSoundscapeMixer
## can crossfade slot-by-slot when the player walks between spaces),
## with optional phase overlays (Cache's kitchen gets a bigger choir
## hum at night, the cooking fire crackles louder at dawn breakfast,
## etc.).
##
## Slot keys (consistent with the wilderness mixer):
##   wind     — primary low background tone
##   water    — water bed (kitchen sink, fishing dock waves)
##   foliage  — leaf rustle, garden, plant ambient
##   wildlife — animal/insect bed, bird ambient
##   specific — space signature sound (anvil, jukebox, telescope hum)

const SPACE_SOUNDSCAPES: Array[Dictionary] = [
	{
		"region_id": &"hub_lounge",
		"display_name": "Underground Lounge",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_lounge_pipe_low",     "db": -18.0, "fade_in_s": 1.5},
			{"slot": &"specific", "sfx_id": &"amb_lounge_jukebox_idle", "db": -16.0, "fade_in_s": 2.0},
			{"slot": &"wildlife", "sfx_id": &"amb_lounge_chatter_low",  "db": -14.0, "fade_in_s": 1.5},
			{"slot": &"water",    "sfx_id": &"amb_lounge_glass_clink",  "db": -22.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {
			&"night": {"slot": &"specific", "sfx_id": &"amb_lounge_jazz_set_distant", "db": -12.0, "fade_in_s": 3.0},
		},
	},
	{
		"region_id": &"hub_tower_top",
		"display_name": "Tower Top",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_tower_wind_high_altitude", "db":  -8.0, "fade_in_s": 2.0},
			{"slot": &"specific", "sfx_id": &"amb_tower_telescope_creak",     "db": -22.0, "fade_in_s": 3.0},
			{"slot": &"wildlife", "sfx_id": &"amb_tower_swallows",            "db": -18.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {
			&"night": {"slot": &"specific", "sfx_id": &"amb_tower_starfield_hum", "db": -16.0, "fade_in_s": 4.0},
		},
	},
	{
		"region_id": &"hub_sage_study",
		"display_name": "Sage's Study",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_study_window_creak",     "db": -22.0, "fade_in_s": 2.0},
			{"slot": &"specific", "sfx_id": &"amb_study_fire_crackle",     "db": -14.0, "fade_in_s": 1.5},
			{"slot": &"foliage",  "sfx_id": &"amb_study_paper_rustle",     "db": -18.0, "fade_in_s": 2.0},
			{"slot": &"wildlife", "sfx_id": &"amb_study_clock_tick",       "db": -20.0, "fade_in_s": 3.0},
		],
		"phase_overlays": {
			&"dawn": {"slot": &"specific", "sfx_id": &"amb_study_quill_writing", "db": -14.0, "fade_in_s": 2.5},
		},
	},
	{
		"region_id": &"hub_sage_library",
		"display_name": "Sage's Library",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_library_breath_low",      "db": -18.0, "fade_in_s": 2.0},
			{"slot": &"specific", "sfx_id": &"amb_library_archive_hum",     "db": -14.0, "fade_in_s": 2.5},
			{"slot": &"foliage",  "sfx_id": &"amb_library_paper_rustle",    "db": -20.0, "fade_in_s": 2.5},
			{"slot": &"wildlife", "sfx_id": &"amb_library_choir_pad_distant","db": -16.0, "fade_in_s": 3.5},
		],
		"phase_overlays": {},
	},
	{
		"region_id": &"hub_training_arena",
		"display_name": "Training Arena",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_arena_outdoor_wind",      "db": -14.0, "fade_in_s": 1.5},
			{"slot": &"foliage",  "sfx_id": &"amb_arena_dust_settle",       "db": -22.0, "fade_in_s": 2.0},
			{"slot": &"specific", "sfx_id": &"amb_arena_metal_creak",       "db": -20.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {},
	},
	{
		"region_id": &"hub_farm",
		"display_name": "Farm Plot",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_farm_wind_grass",         "db": -14.0, "fade_in_s": 1.5},
			{"slot": &"foliage",  "sfx_id": &"amb_farm_leaves_rustle",      "db": -18.0, "fade_in_s": 2.0},
			{"slot": &"wildlife", "sfx_id": &"amb_farm_insects_day",        "db": -14.0, "fade_in_s": 2.0},
			{"slot": &"water",    "sfx_id": &"amb_farm_well_drip",          "db": -22.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {
			&"night": {"slot": &"wildlife", "sfx_id": &"amb_farm_crickets", "db": -14.0, "fade_in_s": 3.0},
		},
	},
	{
		"region_id": &"hub_fishing_dock",
		"display_name": "Fishing Dock",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_dock_breeze",             "db": -16.0, "fade_in_s": 1.5},
			{"slot": &"water",    "sfx_id": &"amb_dock_waves_lap",          "db": -10.0, "fade_in_s": 1.5},
			{"slot": &"wildlife", "sfx_id": &"amb_dock_gulls",              "db": -14.0, "fade_in_s": 2.5},
			{"slot": &"specific", "sfx_id": &"amb_dock_rope_creak",         "db": -22.0, "fade_in_s": 2.0},
		],
		"phase_overlays": {
			&"dusk": {"slot": &"wildlife", "sfx_id": &"amb_dock_evening_birds", "db": -14.0, "fade_in_s": 3.0},
		},
	},
	{
		"region_id": &"hub_cooking",
		"display_name": "Cache's Kitchen",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_kitchen_hood_whisper",    "db": -22.0, "fade_in_s": 2.0},
			{"slot": &"specific", "sfx_id": &"amb_kitchen_pan_hang_creak",  "db": -20.0, "fade_in_s": 2.0},
			{"slot": &"water",    "sfx_id": &"amb_kitchen_pot_simmer",      "db": -14.0, "fade_in_s": 1.5},
			{"slot": &"foliage",  "sfx_id": &"amb_kitchen_herb_rustle",     "db": -22.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {
			&"dawn": {"slot": &"specific", "sfx_id": &"amb_kitchen_breakfast_clatter", "db": -14.0, "fade_in_s": 2.0},
		},
	},
	{
		"region_id": &"hub_workshop",
		"display_name": "Crafting Workshop",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_workshop_bellows_low",    "db": -16.0, "fade_in_s": 1.5},
			{"slot": &"specific", "sfx_id": &"amb_workshop_anvil_distant",  "db": -14.0, "fade_in_s": 2.0},
			{"slot": &"foliage",  "sfx_id": &"amb_workshop_metal_clink",    "db": -18.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {},
	},
	{
		"region_id": &"hub_pet_hutch",
		"display_name": "Pet Hutch",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_hutch_wind_soft",         "db": -20.0, "fade_in_s": 2.0},
			{"slot": &"foliage",  "sfx_id": &"amb_hutch_straw_rustle",      "db": -18.0, "fade_in_s": 2.0},
			{"slot": &"wildlife", "sfx_id": &"amb_hutch_pet_chatter",       "db": -14.0, "fade_in_s": 2.5},
			{"slot": &"specific", "sfx_id": &"amb_hutch_water_bowl_lap",    "db": -22.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {},
	},
	{
		"region_id": &"hub_memorial_gallery",
		"display_name": "Memorial Gallery",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_memorial_silence_breath", "db": -22.0, "fade_in_s": 3.0},
			{"slot": &"specific", "sfx_id": &"amb_memorial_choir_hum",      "db": -14.0, "fade_in_s": 4.0},
			{"slot": &"wildlife", "sfx_id": &"amb_memorial_candle_flicker", "db": -20.0, "fade_in_s": 3.0},
			{"slot": &"foliage",  "sfx_id": &"amb_memorial_incense_drift",  "db": -22.0, "fade_in_s": 3.5},
		],
		"phase_overlays": {
			&"night": {"slot": &"specific", "sfx_id": &"amb_memorial_distant_bell", "db": -16.0, "fade_in_s": 5.0},
		},
	},
	{
		"region_id": &"hub_trophy_hall",
		"display_name": "Trophy Display Hall",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_trophy_hall_silence",     "db": -22.0, "fade_in_s": 3.0},
			{"slot": &"specific", "sfx_id": &"amb_trophy_hall_spotlight_hum","db": -16.0, "fade_in_s": 2.5},
			{"slot": &"foliage",  "sfx_id": &"amb_trophy_hall_polish_dust", "db": -22.0, "fade_in_s": 3.0},
		],
		"phase_overlays": {},
	},
	{
		"region_id": &"hub_wardrobe",
		"display_name": "Wardrobe Room",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_wardrobe_curtain_breath", "db": -22.0, "fade_in_s": 2.5},
			{"slot": &"specific", "sfx_id": &"amb_wardrobe_mirror_chime",   "db": -20.0, "fade_in_s": 3.0},
			{"slot": &"foliage",  "sfx_id": &"amb_wardrobe_fabric_settle",  "db": -22.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {},
	},
	{
		"region_id": &"hub_hidden_treasure",
		"display_name": "Hidden Treasure Room",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_treasure_dust_breath",    "db": -22.0, "fade_in_s": 4.0},
			{"slot": &"specific", "sfx_id": &"amb_treasure_candle_flicker", "db": -16.0, "fade_in_s": 3.0},
			{"slot": &"wildlife", "sfx_id": &"amb_treasure_silence_thick",  "db": -22.0, "fade_in_s": 4.0},
		],
		"phase_overlays": {},
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in SPACE_SOUNDSCAPES:
		_index[entry["region_id"]] = entry


static func get_soundscape(region_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(region_id, {})


static func get_all() -> Array[Dictionary]:
	return SPACE_SOUNDSCAPES.duplicate()


static func get_count() -> int:
	return SPACE_SOUNDSCAPES.size()
