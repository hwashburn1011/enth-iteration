class_name WeatherDatabase
extends RefCounted

## Static catalog of all 6 weather types with visual + audio + gameplay
## modifiers. Drives the WeatherController autoload.

const WEATHERS: Dictionary = {
	&"clear": {
		"display_name": "Clear",
		"icon_id": &"weather_clear",
		"wind_direction": Vector3(0.5, 0.0, 0.3),
		"wind_strength": 0.2,
		"particle_id": &"",
		"sfx_loops": [&"birdsong_loop"],
		"thunder_chance": 0.0,
		"sky_brightness_mult": 1.0,
		"fog_density_override": 0.0,
		"combat_modifiers": {
			"fire_dmg_mult": 1.0,
			"lightning_dmg_mult": 1.0,
			"vision_los_mult": 1.0,
		},
		"fish_modifiers": {"compiled_tuna_chance_mult": 1.2},
		"crop_modifiers": {"growth_speed_mult": 1.0},
	},
	&"cloudy": {
		"display_name": "Cloudy",
		"icon_id": &"weather_cloudy",
		"wind_direction": Vector3(0.7, 0.0, 0.4),
		"wind_strength": 0.4,
		"particle_id": &"",
		"sfx_loops": [&"wind_gust_loop"],
		"thunder_chance": 0.0,
		"sky_brightness_mult": 0.7,
		"fog_density_override": 0.005,
		"combat_modifiers": {
			"fire_dmg_mult": 1.0,
			"lightning_dmg_mult": 1.0,
			"vision_los_mult": 1.0,
		},
		"fish_modifiers": {},
		"crop_modifiers": {},
	},
	&"rain": {
		"display_name": "Rain",
		"icon_id": &"weather_rain",
		"wind_direction": Vector3(0.5, -1.0, 0.2),
		"wind_strength": 0.5,
		"particle_id": &"rain_particles",
		"sfx_loops": [&"wind_gust_loop"],
		"thunder_chance": 0.0,
		"sky_brightness_mult": 0.55,
		"fog_density_override": 0.015,
		"combat_modifiers": {
			"fire_dmg_mult": 0.75,
			"lightning_dmg_mult": 1.0,
			"vision_los_mult": 1.0,
		},
		"fish_modifiers": {"rare_fish_chance_mult": 1.2},
		"crop_modifiers": {"auto_water": true},
	},
	&"storm": {
		"display_name": "Storm",
		"icon_id": &"weather_storm",
		"wind_direction": Vector3(1.0, -1.0, 0.5),
		"wind_strength": 1.0,
		"particle_id": &"storm_particles",
		"sfx_loops": [&"wind_gust_loop"],
		"thunder_chance": 0.05,
		"sky_brightness_mult": 0.4,
		"fog_density_override": 0.025,
		"combat_modifiers": {
			"fire_dmg_mult": 0.5,
			"lightning_dmg_mult": 1.25,
			"chain_lightning_hop_mult": 1.10,
			"vision_los_mult": 0.85,
		},
		"fish_modifiers": {"voidshark_unlocked": true},
		"crop_modifiers": {"flatten_chance": 0.05},
	},
	&"fog": {
		"display_name": "Fog",
		"icon_id": &"weather_fog",
		"wind_direction": Vector3(0.0, 0.0, 0.0),
		"wind_strength": 0.0,
		"particle_id": &"fog_particles",
		"sfx_loops": [],
		"thunder_chance": 0.0,
		"sky_brightness_mult": 0.6,
		"fog_density_override": 0.08,
		"combat_modifiers": {
			"fire_dmg_mult": 1.0,
			"lightning_dmg_mult": 1.0,
			"vision_los_mult": 0.7,
		},
		"fish_modifiers": {},
		"crop_modifiers": {},
	},
	&"glitch_storm": {
		"display_name": "Glitch Storm",
		"icon_id": &"weather_glitch",
		"wind_direction": Vector3(2.0, -2.0, 1.0),
		"wind_strength": 1.5,
		"particle_id": &"glitch_storm_particles",
		"sfx_loops": [&"glitch_crackle_loop", &"wind_gust_loop"],
		"thunder_chance": 0.10,
		"sky_brightness_mult": 0.30,
		"fog_density_override": 0.04,
		"combat_modifiers": {
			"fire_dmg_mult": 0.8,
			"lightning_dmg_mult": 1.4,
			"vision_los_mult": 0.6,
			"chaos_buff_chance": 0.10,  # random buff/debuff every 10s
		},
		"fish_modifiers": {},
		"crop_modifiers": {"mutation_chance": 0.10},
	},
}

## Forbidden direct transitions (must pass through cloudy)
const FORBIDDEN_TRANSITIONS: Array[Array] = [
	[&"clear", &"glitch_storm"],
	[&"glitch_storm", &"clear"],
	[&"storm", &"clear"],
	[&"clear", &"storm"],
]

## Default weather chance distribution per zone
const ZONE_DEFAULTS: Dictionary = {
	&"town_center":         {&"clear": 0.85, &"cloudy": 0.15},
	&"town_residential":    {&"clear": 0.70, &"cloudy": 0.25, &"rain": 0.05},
	&"town_market":         {&"clear": 0.80, &"cloudy": 0.20},
	&"town_workshop":       {&"clear": 0.65, &"cloudy": 0.30, &"rain": 0.05},
	&"town_docks":          {&"clear": 0.50, &"cloudy": 0.30, &"rain": 0.15, &"storm": 0.05},
	&"wilderness":          {&"clear": 0.40, &"cloudy": 0.30, &"rain": 0.15, &"storm": 0.10, &"fog": 0.05},
	&"server_room":         {&"clear": 1.0},
	&"memory_vaults":       {&"fog": 0.60, &"clear": 0.40},
	&"corrupted_wilds":     {&"glitch_storm": 0.40, &"storm": 0.30, &"cloudy": 0.20, &"fog": 0.10},
	&"final_vault":         {&"clear": 1.0},
}


static func get_weather(id: StringName) -> Dictionary:
	return WEATHERS.get(id, {})


static func get_all_ids() -> Array:
	return WEATHERS.keys()


static func can_transition(from_id: StringName, to_id: StringName) -> bool:
	if from_id == to_id:
		return true
	for forbidden in FORBIDDEN_TRANSITIONS:
		if forbidden[0] == from_id and forbidden[1] == to_id:
			return false
	return true


static func get_zone_default_distribution(zone_id: StringName) -> Dictionary:
	return ZONE_DEFAULTS.get(zone_id, {&"clear": 1.0})


static func roll_weather_for_zone(zone_id: StringName, iteration_glitch_bonus: float = 0.0) -> StringName:
	## Picks a weather based on the zone's distribution. Higher iterations
	## get a glitch storm chance bonus.
	var dist: Dictionary = get_zone_default_distribution(zone_id).duplicate()
	if iteration_glitch_bonus > 0.0 and not dist.has(&"glitch_storm"):
		dist[&"glitch_storm"] = iteration_glitch_bonus
	# Normalize weights
	var total: float = 0.0
	for w in dist.values():
		total += w
	var roll: float = randf() * total
	var acc: float = 0.0
	for weather_id: StringName in dist.keys():
		acc += dist[weather_id]
		if roll <= acc:
			return weather_id
	return &"clear"


static func count() -> int:
	return WEATHERS.size()
