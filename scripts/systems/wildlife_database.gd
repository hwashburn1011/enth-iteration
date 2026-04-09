class_name WildlifeDatabase
extends RefCounted

## Catalog of passive wilderness wildlife. These are the always-on
## ambient critters — birds, rabbits, deer, otters, fireflies — that
## make the wilderness feel inhabited. See
## `_bmad-output/wilderness/wilderness_bible.md` "Passive wildlife".
##
## Each entry defines:
##   - region restriction
##   - active phase window (dawn/day/dusk/night)
##   - density (critters per region instance)
##   - flee behavior (radius, speed, return delay)
##   - locomotion type (walk, hop, fly, swim, hover, crawl)
##   - rarity tier (drives reaction sting on first sighting)

const WILDLIFE: Array[Dictionary] = [
	{
		"id": &"echo_bird",
		"display_name": "Echo Bird",
		"regions": [&"wild_plateau", &"wild_forest"],
		"phases": [&"dawn", &"day"],
		"weather_blacklist": [&"storm", &"glitch_storm"],
		"density": 4,
		"locomotion": &"fly",
		"flee_radius": 6.0,
		"flee_speed": 5.0,
		"return_delay_s": 12.0,
		"sound_id": &"sfx_echo_bird_call",
		"sound_chance_per_min": 0.4,
		"rarity": &"common",
		"can_be_caught": false,
	},
	{
		"id": &"sim_rabbit",
		"display_name": "Sim-Rabbit",
		"regions": [&"wild_plateau", &"wild_pasture"],
		"phases": [&"dawn", &"day", &"dusk"],
		"weather_blacklist": [&"storm"],
		"density": 6,
		"locomotion": &"hop",
		"flee_radius": 5.0,
		"flee_speed": 6.5,
		"return_delay_s": 15.0,
		"sound_id": &"",
		"sound_chance_per_min": 0.0,
		"rarity": &"common",
		"can_be_caught": false,
	},
	{
		"id": &"sim_deer",
		"display_name": "Sim-Deer",
		"regions": [&"wild_pasture"],
		"phases": [&"dawn", &"dusk"],
		"weather_blacklist": [&"storm", &"rain"],
		"density": 2,
		"locomotion": &"walk",
		"flee_radius": 8.0,
		"flee_speed": 9.0,
		"return_delay_s": 30.0,
		"sound_id": &"sfx_deer_snort",
		"sound_chance_per_min": 0.15,
		"rarity": &"uncommon",
		"can_be_caught": false,
		"signature_for_achievement": &"friend_of_the_wild",
	},
	{
		"id": &"river_otter",
		"display_name": "River Otter",
		"regions": [&"wild_river"],
		"phases": [&"day", &"dusk"],
		"weather_blacklist": [],
		"density": 3,
		"locomotion": &"swim",
		"flee_radius": 4.0,
		"flee_speed": 5.0,
		"return_delay_s": 8.0,
		"sound_id": &"sfx_otter_splash",
		"sound_chance_per_min": 0.3,
		"rarity": &"common",
		"can_be_caught": false,
	},
	{
		"id": &"dragonfly",
		"display_name": "Dragonfly",
		"regions": [&"wild_river"],
		"phases": [&"day", &"dusk"],
		"weather_blacklist": [&"storm", &"rain"],
		"density": 8,
		"locomotion": &"hover",
		"flee_radius": 0.0,  # No collision, never flees
		"flee_speed": 0.0,
		"return_delay_s": 0.0,
		"sound_id": &"",
		"sound_chance_per_min": 0.0,
		"rarity": &"common",
		"can_be_caught": false,
	},
	{
		"id": &"fox",
		"display_name": "Fox",
		"regions": [&"wild_forest"],
		"phases": [&"dusk", &"night", &"dawn"],
		"weather_blacklist": [&"storm"],
		"density": 1,
		"locomotion": &"walk",
		"flee_radius": 7.0,
		"flee_speed": 7.5,
		"return_delay_s": 25.0,
		"sound_id": &"sfx_fox_yip",
		"sound_chance_per_min": 0.1,
		"rarity": &"uncommon",
		"can_be_caught": false,
	},
	{
		"id": &"owl",
		"display_name": "Owl",
		"regions": [&"wild_forest"],
		"phases": [&"night"],
		"weather_blacklist": [&"storm"],
		"density": 2,
		"locomotion": &"perch",  # Sits in canopy, doesn't roam
		"flee_radius": 0.0,
		"flee_speed": 0.0,
		"return_delay_s": 0.0,
		"sound_id": &"sfx_owl_hoot",
		"sound_chance_per_min": 0.6,
		"rarity": &"common",
		"can_be_caught": false,
	},
	{
		"id": &"firefly",
		"display_name": "Firefly",
		"regions": [&"wild_forest"],
		"phases": [&"night"],
		"weather_blacklist": [&"storm", &"rain"],
		"density": 30,
		"locomotion": &"hover",
		"flee_radius": 0.0,
		"flee_speed": 0.0,
		"return_delay_s": 0.0,
		"sound_id": &"",
		"sound_chance_per_min": 0.0,
		"rarity": &"common",
		"can_be_caught": false,
		"emits_light": true,
		"light_color": Color(1.0, 0.85, 0.45),
		"light_energy": 0.6,
	},
	{
		"id": &"raven",
		"display_name": "Raven",
		"regions": [&"wild_ruins"],
		"phases": [&"day", &"dusk"],
		"weather_blacklist": [],
		"density": 4,
		"locomotion": &"perch_and_fly",
		"flee_radius": 5.0,
		"flee_speed": 6.0,
		"return_delay_s": 20.0,
		"sound_id": &"sfx_raven_caw",
		"sound_chance_per_min": 0.5,
		"rarity": &"common",
		"can_be_caught": false,
		"flock_size": 2,
	},
	{
		"id": &"lizard",
		"display_name": "Sun Lizard",
		"regions": [&"wild_ruins"],
		"phases": [&"day"],
		"weather_blacklist": [&"rain", &"storm", &"fog"],
		"density": 5,
		"locomotion": &"crawl",
		"flee_radius": 3.0,
		"flee_speed": 4.0,
		"return_delay_s": 30.0,
		"sound_id": &"",
		"sound_chance_per_min": 0.0,
		"rarity": &"common",
		"can_be_caught": false,
	},
	{
		"id": &"cliff_swallow",
		"display_name": "Cliff Swallow",
		"regions": [&"wild_cliffs"],
		"phases": [&"day", &"dusk"],
		"weather_blacklist": [&"storm"],
		"density": 6,
		"locomotion": &"fly",
		"flee_radius": 0.0,  # Stay aloft, untouchable
		"flee_speed": 0.0,
		"return_delay_s": 0.0,
		"sound_id": &"sfx_swallow_call",
		"sound_chance_per_min": 0.4,
		"rarity": &"common",
		"can_be_caught": false,
		"flock_size": 7,
		"flock_pattern": &"wheel",
	},
	{
		"id": &"frog",
		"display_name": "Frog",
		"regions": [&"wild_river"],
		"phases": [&"dusk", &"night"],
		"weather_blacklist": [],
		"density": 8,
		"locomotion": &"hop",
		"flee_radius": 2.5,
		"flee_speed": 3.5,
		"return_delay_s": 10.0,
		"sound_id": &"sfx_frog_croak",
		"sound_chance_per_min": 1.2,
		"rarity": &"common",
		"can_be_caught": false,
	},
	{
		"id": &"butterfly",
		"display_name": "Butterfly",
		"regions": [&"wild_pasture", &"wild_plateau"],
		"phases": [&"day"],
		"weather_blacklist": [&"rain", &"storm"],
		"density": 10,
		"locomotion": &"hover",
		"flee_radius": 0.0,
		"flee_speed": 0.0,
		"return_delay_s": 0.0,
		"sound_id": &"",
		"sound_chance_per_min": 0.0,
		"rarity": &"common",
		"can_be_caught": false,
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in WILDLIFE:
		_index[entry["id"]] = entry


static func get_critter(critter_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(critter_id, {})


static func get_all() -> Array[Dictionary]:
	return WILDLIFE.duplicate()


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in WILDLIFE:
		if entry.get("regions", []).has(region_id):
			result.append(entry)
	return result


static func get_active_for_region(region_id: StringName, phase: StringName, weather: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in get_for_region(region_id):
		if not entry.get("phases", []).has(phase):
			continue
		if entry.get("weather_blacklist", []).has(weather):
			continue
		result.append(entry)
	return result


static func get_count() -> int:
	return WILDLIFE.size()
