class_name FishingResolver
extends RefCounted

## Wilderness-aware fishing roll resolver. Wraps the existing
## FishDatabase with: region → fishing-location mapping, phase →
## time-of-day translation, bait preference weighting, weather
## awareness, and a unified `try_catch()` entry point that the
## wilderness fishing spot component calls.
##
## Bait preferences are layered ON TOP of the existing inverse-rarity
## roll, so a chrome spinner doesn't *guarantee* a compiled tuna but
## sharply increases the relative weight when a tuna is in the eligible
## pool.

# Wilderness/world region → FishDatabase location id
const REGION_TO_LOCATION: Dictionary = {
	&"wild_river":          &"any",
	&"hidden_grove_pond":   &"any",
	&"hidden_lake":         &"any",
	&"town_docks":          &"any",
	&"sage_pond":           &"sage_pond",
}

# Day-night phase → existing FishDatabase time tag
const PHASE_TO_TIME: Dictionary = {
	&"dawn":  &"dawn",
	&"day":   &"day",
	&"dusk":  &"twilight",
	&"night": &"night",
}

# Bait → per-fish weight bonus. Each entry maps a fish_id → multiplier.
# Fish not listed for a bait keep weight 1.0 (neutral bait).
const BAIT_PREFERENCES: Dictionary = {
	&"bait_worm": {
		&"bit_minnow":   1.6,
		&"cache_carp":   1.4,
		&"datafin":      1.4,
		&"patchsalmon":  1.2,
	},
	&"bait_lure": {
		&"memory_trout":  1.7,
		&"compiled_tuna": 1.6,
		&"server_squid":  1.4,
		&"wire_eel":      1.4,
	},
	&"bait_dough": {
		&"cache_carp":    2.0,
		&"patchsalmon":   1.5,
	},
	&"bait_voltage_pellet": {
		&"wire_eel":      2.5,
		&"voidshark":     2.0,
		&"server_squid":  1.6,
	},
	&"bait_chrome_spinner": {
		&"compiled_tuna":   2.5,
		&"voidshark":       1.8,
		&"iteration_pike":  1.7,
	},
	&"bait_glow_lure": {
		&"server_squid":    2.0,
		&"algorithm_octopus": 2.0,
		&"dream_whale":     2.5,
	},
	&"bait_sages_offering": {
		&"sages_goldfish":  3.0,
	},
	&"bait_users_seal_fragment": {
		&"users_salmon":    3.0,
	},
}


static func try_catch(region_id: StringName, bait_id: StringName) -> Dictionary:
	## Resolves a fishing roll for the current world state and returns
	## a fish dictionary, or {} if nothing was eligible.
	##
	## Calls the existing FishDatabase.get_eligible_fish() with the
	## translated parameters, applies bait weighting, then runs the
	## weighted roll.
	var location: StringName = REGION_TO_LOCATION.get(region_id, &"any")
	var phase: StringName = _current_phase()
	var time_of_day: StringName = PHASE_TO_TIME.get(phase, &"day")
	var weather: StringName = _current_weather()
	var moon_phase: StringName = _current_moon_phase()

	var eligible: Array = FishDatabase.get_eligible_fish(time_of_day, weather, moon_phase, location)
	if eligible.is_empty():
		return {}

	# Drop story-locked fish unless their flag is set
	eligible = eligible.filter(func(f: Dictionary) -> bool:
		if f.get("story_unlock", false):
			return _has_story_unlock(StringName(f["id"]))
		return true
	)
	if eligible.is_empty():
		return {}

	# Bait-weighted pick (overrides FishDatabase.roll_catch so we can
	# layer in bait multipliers per-fish)
	return _bait_weighted_roll(eligible, bait_id)


static func _bait_weighted_roll(pool: Array, bait_id: StringName) -> Dictionary:
	var bait_table: Dictionary = BAIT_PREFERENCES.get(bait_id, {})
	var rarity_base: Array = []
	var bait_mults: Array = []
	var total: float = 0.0
	for f in pool:
		var rarity: int = int(f.get("rarity", 0))
		var rarity_weight: float = pow(0.4, rarity)  # match FishDatabase.roll_catch
		var bait_mult: float = float(bait_table.get(f["id"], 1.0))
		var w: float = rarity_weight * bait_mult
		rarity_base.append(rarity_weight)
		bait_mults.append(bait_mult)
		total += w
	if total <= 0.0:
		return {}
	var roll: float = randf() * total
	var acc: float = 0.0
	for i in pool.size():
		acc += rarity_base[i] * bait_mults[i]
		if roll <= acc:
			return pool[i]
	return pool[pool.size() - 1]


# === STATE READERS ===

static func _current_phase() -> StringName:
	var dnc: Node = Engine.get_main_loop().root.get_node_or_null("DayNightController") if Engine.has_singleton("DayNightController") else null
	if dnc == null and Engine.get_main_loop() != null:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		dnc = root.get_node_or_null("DayNightController")
	if dnc != null and "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"


static func _current_weather() -> StringName:
	if Engine.get_main_loop() == null:
		return &"clear"
	var root: Node = (Engine.get_main_loop() as SceneTree).root
	var wc: Node = root.get_node_or_null("WeatherController")
	if wc != null and "current_weather_id" in wc:
		return StringName(wc.current_weather_id)
	return &"clear"


static func _current_moon_phase() -> StringName:
	if Engine.get_main_loop() == null:
		return &"new"
	var root: Node = (Engine.get_main_loop() as SceneTree).root
	var dnc: Node = root.get_node_or_null("DayNightController")
	if dnc != null and "current_moon_phase" in dnc:
		return StringName(dnc.current_moon_phase)
	return &"new"


static func _has_story_unlock(fish_id: StringName) -> bool:
	if Engine.get_main_loop() == null:
		return false
	var root: Node = (Engine.get_main_loop() as SceneTree).root
	var sm: Node = root.get_node_or_null("WildernessStoryManager")
	if sm == null:
		return false
	var flag: StringName = StringName("fish_unlocked_" + String(fish_id))
	if sm.has_method("has_flag"):
		return sm.has_flag(flag)
	return false
