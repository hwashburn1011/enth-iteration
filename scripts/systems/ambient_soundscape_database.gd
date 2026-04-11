class_name AmbientSoundscapeDatabase
extends RefCounted

## Layered ambient soundscapes for each wilderness region. Every region
## defines a small set of looping SFX layers (wind, water, foliage,
## wildlife bed) with per-layer volume in dB, plus optional weather
## overlays that fade in when conditions change. AmbientSoundscapeMixer
## consumes this catalog at runtime.
##
## See `_bmad-output/wilderness/wilderness_bible.md` for the design.
##
## Layer slot conventions (consistent across all regions so the mixer
## can crossfade slot-by-slot without popping):
##   slot &"wind"     — primary wind tone, always present
##   slot &"water"    — water bed (river, lake, drips)
##   slot &"foliage"  — leaves, grass, branches
##   slot &"wildlife" — bird/insect ambient bed
##   slot &"specific" — region signature sound (chimes, distant chime,
##                      stones echoing wind, etc.)
##
## Weather overlays (slot key prefixed with &"wx_") are *additive* on top
## of whatever the base bed is for the region.

const REGION_SOUNDSCAPES: Array[Dictionary] = [
	{
		"region_id": &"wild_plateau",
		"display_name": "North Plateau",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_wind_grass_open",     "db": -10.0, "fade_in_s": 1.5},
			{"slot": &"foliage",  "sfx_id": &"amb_grass_rustle_soft",   "db": -16.0, "fade_in_s": 1.5},
			{"slot": &"wildlife", "sfx_id": &"amb_birds_meadow_day",    "db": -14.0, "fade_in_s": 2.0},
		],
		"phase_overlays": {
			&"dawn":  {"slot": &"specific", "sfx_id": &"amb_birdsong_dawn_chorus", "db": -10.0, "fade_in_s": 3.0},
			&"night": {"slot": &"wildlife", "sfx_id": &"amb_crickets_open",        "db": -16.0, "fade_in_s": 3.0},
		},
	},
	{
		"region_id": &"wild_river",
		"display_name": "River Valley",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_wind_river_low",      "db": -16.0, "fade_in_s": 1.5},
			{"slot": &"water",    "sfx_id": &"amb_river_flow_medium",   "db":  -8.0, "fade_in_s": 1.0},
			{"slot": &"foliage",  "sfx_id": &"amb_reeds_rustle",        "db": -18.0, "fade_in_s": 2.0},
			{"slot": &"wildlife", "sfx_id": &"amb_river_birds_day",     "db": -14.0, "fade_in_s": 2.0},
		],
		"phase_overlays": {
			&"dusk":  {"slot": &"specific", "sfx_id": &"amb_frogs_chorus_dusk",   "db": -12.0, "fade_in_s": 4.0},
			&"night": {"slot": &"wildlife", "sfx_id": &"amb_river_night_insects", "db": -12.0, "fade_in_s": 4.0},
		},
	},
	{
		"region_id": &"wild_forest",
		"display_name": "Forest Fringe",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_wind_canopy_high",    "db": -12.0, "fade_in_s": 2.0},
			{"slot": &"foliage",  "sfx_id": &"amb_leaves_canopy_dense", "db": -14.0, "fade_in_s": 2.0},
			{"slot": &"wildlife", "sfx_id": &"amb_forest_birds_day",    "db": -14.0, "fade_in_s": 2.5},
			{"slot": &"specific", "sfx_id": &"amb_chimes_listening_tree", "db": -18.0, "fade_in_s": 3.0},
		],
		"phase_overlays": {
			&"night": {"slot": &"wildlife", "sfx_id": &"amb_forest_owls_distant", "db": -14.0, "fade_in_s": 4.0},
		},
	},
	{
		"region_id": &"wild_ruins",
		"display_name": "Ruin Field",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_wind_through_stones", "db":  -8.0, "fade_in_s": 2.0},
			{"slot": &"foliage",  "sfx_id": &"amb_dead_grass_brittle",  "db": -20.0, "fade_in_s": 2.0},
			{"slot": &"wildlife", "sfx_id": &"amb_ravens_distant",      "db": -18.0, "fade_in_s": 3.0},
			{"slot": &"specific", "sfx_id": &"amb_stone_groans_low",    "db": -22.0, "fade_in_s": 4.0},
		],
		"phase_overlays": {
			&"night": {"slot": &"specific", "sfx_id": &"amb_choir_distant_night", "db": -18.0, "fade_in_s": 5.0},
		},
	},
	{
		"region_id": &"wild_cliffs",
		"display_name": "Cliff Line",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_wind_high_altitude",  "db":  -6.0, "fade_in_s": 1.5},
			{"slot": &"wildlife", "sfx_id": &"amb_cliff_swallows",      "db": -16.0, "fade_in_s": 2.5},
			{"slot": &"specific", "sfx_id": &"amb_drone_subterranean",  "db": -20.0, "fade_in_s": 4.0},
		],
		"phase_overlays": {},
	},
	{
		"region_id": &"wild_pasture",
		"display_name": "Quiet Pasture",
		"layers": [
			{"slot": &"wind",     "sfx_id": &"amb_wind_grass_soft",     "db": -14.0, "fade_in_s": 1.5},
			{"slot": &"foliage",  "sfx_id": &"amb_grass_rustle_soft",   "db": -16.0, "fade_in_s": 2.0},
			{"slot": &"wildlife", "sfx_id": &"amb_meadow_insects_day",  "db": -16.0, "fade_in_s": 2.5},
		],
		"phase_overlays": {
			&"night": {"slot": &"wildlife", "sfx_id": &"amb_pasture_crickets", "db": -14.0, "fade_in_s": 3.0},
		},
	},
]

# Weather overlays apply to ALL regions on top of their base bed
const WEATHER_OVERLAYS: Dictionary = {
	&"rain": [
		{"slot": &"wx_rain",  "sfx_id": &"amb_rain_medium",      "db":  -8.0, "fade_in_s": 2.5},
		{"slot": &"wx_drips", "sfx_id": &"amb_water_drips_soft", "db": -16.0, "fade_in_s": 3.0},
	],
	&"storm": [
		{"slot": &"wx_rain",    "sfx_id": &"amb_rain_heavy",       "db":  -4.0, "fade_in_s": 2.0},
		{"slot": &"wx_thunder", "sfx_id": &"amb_thunder_distant",  "db": -10.0, "fade_in_s": 3.0},
		{"slot": &"wx_wind",    "sfx_id": &"amb_wind_storm_gusts", "db":  -8.0, "fade_in_s": 2.0},
	],
	&"fog": [
		{"slot": &"wx_fog", "sfx_id": &"amb_fog_muffled_pad", "db": -14.0, "fade_in_s": 4.0},
	],
	&"glitch_storm": [
		{"slot": &"wx_glitch_a", "sfx_id": &"amb_glitch_static_bursts", "db": -10.0, "fade_in_s": 1.5},
		{"slot": &"wx_glitch_b", "sfx_id": &"amb_glitch_drone_unstable", "db": -12.0, "fade_in_s": 2.0},
	],
}

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in REGION_SOUNDSCAPES:
		_index[entry["region_id"]] = entry


static func get_soundscape(region_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(region_id, {})


static func get_weather_overlay(weather_id: StringName) -> Array:
	return WEATHER_OVERLAYS.get(weather_id, [])


static func get_all() -> Array[Dictionary]:
	return REGION_SOUNDSCAPES.duplicate()


static func get_count() -> int:
	return REGION_SOUNDSCAPES.size()
