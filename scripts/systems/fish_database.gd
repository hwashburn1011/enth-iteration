class_name FishDatabase
extends RefCounted

## Static catalog of all 15 fish types. Time-of-day, weather, and location
## conditions filter which fish appear at a given fishing spot.

const FISH: Array = [
	# Common
	{"id": &"bit_minnow",        "name": "Bit Minnow",       "rarity": 0, "time": &"day",      "weather": &"any",   "drops": {&"bit_fragment": 1}, "behavior": &"calm",     "size": 1},
	{"id": &"wire_eel",          "name": "Wire Eel",         "rarity": 0, "time": &"night",    "weather": &"any",   "drops": {&"wire": 1},          "behavior": &"erratic",  "size": 2},
	{"id": &"cache_carp",        "name": "Cache Carp",       "rarity": 0, "time": &"day",      "weather": &"any",   "drops": {&"cache_crystal": 1}, "behavior": &"sinker",   "size": 2},
	{"id": &"datafin",           "name": "Datafin",          "rarity": 0, "time": &"twilight", "weather": &"any",   "drops": {&"bit_fragment": 2}, "behavior": &"calm",     "size": 1},
	{"id": &"patchsalmon",       "name": "Patchsalmon",      "rarity": 0, "time": &"day",      "weather": &"any",   "drops": {&"patch": 2},         "behavior": &"dasher",   "size": 3},
	# Uncommon
	{"id": &"memory_trout",      "name": "Memory Trout",     "rarity": 1, "time": &"day",      "weather": &"any",   "drops": {&"memory_glass": 1}, "behavior": &"erratic",  "size": 2},
	{"id": &"server_squid",      "name": "Server Squid",     "rarity": 1, "time": &"night",    "weather": &"any",   "drops": {&"server_coil": 1},  "behavior": &"sinker",   "size": 3},
	{"id": &"quantum_crab",      "name": "Quantum Crab",     "rarity": 1, "time": &"twilight", "weather": &"any",   "drops": {&"quantum_shard": 1},"behavior": &"dasher",   "size": 2},
	{"id": &"algorithm_octopus", "name": "Algorithm Octopus","rarity": 1, "time": &"night",    "weather": &"any",   "drops": {&"algorithm_stone": 1},"behavior": &"erratic","size": 4},
	# Rare
	{"id": &"voidshark",         "name": "Voidshark",        "rarity": 2, "time": &"night",    "weather": &"storm", "drops": {&"voidsteel": 1},    "behavior": &"dasher",   "size": 5},
	{"id": &"dream_whale",       "name": "Dream Whale",      "rarity": 2, "time": &"night",    "weather": &"clear", "drops": {&"dream_silk": 1},   "behavior": &"sinker",   "size": 6, "moon_phase": &"full"},
	{"id": &"compiled_tuna",     "name": "Compiled Tuna",    "rarity": 2, "time": &"day",      "weather": &"clear", "drops": {&"compiled_steel": 1},"behavior": &"erratic", "size": 4},
	{"id": &"iteration_pike",    "name": "Iteration Pike",   "rarity": 2, "time": &"dawn",     "weather": &"any",   "drops": {&"iteration_echo": 1},"behavior": &"dasher",  "size": 4},
	# Legendary
	{"id": &"sages_goldfish",    "name": "Sage's Goldfish",  "rarity": 3, "time": &"dawn",     "weather": &"any",   "drops": {&"sages_tear": 1},   "behavior": &"calm",     "size": 1, "location": &"sage_pond"},
	{"id": &"users_salmon",      "name": "The User's Salmon","rarity": 3, "time": &"any",      "weather": &"any",   "drops": {&"users_seal": 1},   "behavior": &"erratic",  "size": 5, "story_unlock": true},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return FISH


static func get_fish(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for f in FISH:
		_index[f["id"]] = f


static func get_eligible_fish(time_of_day: StringName, weather: StringName, moon_phase: StringName, location: StringName) -> Array:
	## Returns fish that can be caught right now at this location.
	var result: Array = []
	for f in FISH:
		# Story-locked fish must be unlocked
		if f.get("story_unlock", false):
			continue  # caller checks unlock state
		# Location filter
		var loc_req: StringName = f.get("location", &"any")
		if loc_req != &"any" and loc_req != location:
			continue
		# Time filter
		var time_req: StringName = f.get("time", &"any")
		if time_req != &"any" and time_req != time_of_day:
			continue
		# Weather filter
		var weather_req: StringName = f.get("weather", &"any")
		if weather_req != &"any" and weather_req != weather:
			continue
		# Moon phase filter
		if f.has("moon_phase") and f["moon_phase"] != moon_phase:
			continue
		result.append(f)
	return result


static func roll_catch(eligible: Array) -> Dictionary:
	## Picks a fish from eligible weighted by inverse rarity (commons more likely).
	if eligible.is_empty():
		return {}
	var weights: Array = []
	var total: float = 0.0
	for f in eligible:
		var w: float = pow(0.4, f["rarity"])  # rarer fish are exponentially less likely
		weights.append(w)
		total += w
	var roll: float = randf() * total
	var acc: float = 0.0
	for i in eligible.size():
		acc += weights[i]
		if roll <= acc:
			return eligible[i]
	return eligible[-1]


static func count() -> int:
	return FISH.size()
