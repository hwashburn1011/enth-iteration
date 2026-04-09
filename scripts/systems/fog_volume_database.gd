class_name FogVolumeDatabase
extends RefCounted

## Per-region volumetric fog volume configurations. Where the
## WildernessLightingDirector handles the GLOBAL fog parameters on the
## active Environment, fog VOLUMES are localized FogVolume nodes that
## shape mist into specific places — rising off the river surface,
## pooled around the tilted spire's base, drifting through the forest
## clearings at night, etc.
##
## Each entry defines one or more fog volumes (size, position offset,
## density, color, shape) keyed to a region. A `WildernessFogVolumeSpawner`
## component reads from this catalog at scene load time and creates the
## actual FogVolume nodes.
##
## All entries support phase + weather modulation so the river mist
## intensifies at dawn and the ruin fog thickens during fog weather.

const REGION_VOLUMES: Dictionary = {
	&"wild_river": [
		{
			"id": &"river_surface_mist",
			"display_name": "River Surface Mist",
			"shape": &"box",
			"position_offset": Vector3(0, 0.4, 0),
			"size": Vector3(120, 1.5, 14),
			"density": 0.18,
			"albedo": Color(0.85, 0.92, 0.96),
			"emission": Color(0.0, 0.0, 0.0),
			"phase_density_mult": {&"dawn": 2.2, &"day": 0.5, &"dusk": 1.4, &"night": 1.0},
			"weather_density_mult": {&"clear": 1.0, &"cloudy": 1.2, &"rain": 1.5, &"storm": 1.0, &"fog": 2.5},
		},
		{
			"id": &"river_bank_pools",
			"display_name": "River Bank Mist Pools",
			"shape": &"box",
			"position_offset": Vector3(0, 0.6, 0),
			"size": Vector3(140, 2.0, 30),
			"density": 0.06,
			"albedo": Color(0.78, 0.85, 0.92),
			"emission": Color(0.0, 0.0, 0.0),
			"phase_density_mult": {&"dawn": 1.8, &"day": 0.3, &"dusk": 1.0, &"night": 0.8},
			"weather_density_mult": {&"clear": 1.0, &"rain": 1.3, &"fog": 2.0},
		},
	],
	&"wild_forest": [
		{
			"id": &"forest_canopy_filter",
			"display_name": "Canopy Filtered Mist",
			"shape": &"box",
			"position_offset": Vector3(0, 5.0, 0),
			"size": Vector3(90, 6.0, 60),
			"density": 0.04,
			"albedo": Color(0.62, 0.78, 0.55),
			"emission": Color(0.0, 0.0, 0.0),
			"phase_density_mult": {&"dawn": 1.5, &"day": 0.7, &"dusk": 1.2, &"night": 1.6},
			"weather_density_mult": {&"clear": 1.0, &"rain": 1.6, &"storm": 1.4, &"fog": 2.2},
		},
		{
			"id": &"forest_clearing_drift",
			"display_name": "Clearing Drift",
			"shape": &"box",
			"position_offset": Vector3(0, 1.0, 0),
			"size": Vector3(40, 2.0, 40),
			"density": 0.10,
			"albedo": Color(0.75, 0.85, 0.65),
			"emission": Color(0.05, 0.10, 0.04),  # subtle bioluminescence at night
			"phase_density_mult": {&"dawn": 1.4, &"day": 0.4, &"dusk": 1.2, &"night": 1.8},
			"weather_density_mult": {&"clear": 1.0, &"rain": 1.3, &"fog": 2.5},
		},
	],
	&"wild_ruins": [
		{
			"id": &"spire_base_pool",
			"display_name": "Spire Base Cold Fog",
			"shape": &"box",
			"position_offset": Vector3(28, 0.8, -15),  # at the tilted spire
			"size": Vector3(35, 3.0, 35),
			"density": 0.16,
			"albedo": Color(0.55, 0.55, 0.62),
			"emission": Color(0.10, 0.05, 0.18),  # faint corruption purple
			"phase_density_mult": {&"dawn": 1.4, &"day": 0.7, &"dusk": 1.2, &"night": 2.0},
			"weather_density_mult": {&"clear": 1.0, &"cloudy": 1.3, &"rain": 1.4, &"fog": 2.8, &"glitch_storm": 3.0},
		},
		{
			"id": &"ruin_floor_drift",
			"display_name": "Ruin Floor Drift",
			"shape": &"box",
			"position_offset": Vector3(0, 0.3, 0),
			"size": Vector3(110, 1.2, 50),
			"density": 0.05,
			"albedo": Color(0.62, 0.60, 0.58),
			"emission": Color(0.0, 0.0, 0.0),
			"phase_density_mult": {&"dawn": 1.2, &"day": 0.5, &"dusk": 1.0, &"night": 1.5},
			"weather_density_mult": {&"clear": 1.0, &"fog": 2.2, &"glitch_storm": 2.5},
		},
	],
	&"wild_cliffs": [
		{
			"id": &"cliff_wind_streamers",
			"display_name": "Cliff Wind Streamers",
			"shape": &"box",
			"position_offset": Vector3(0, 4.0, 0),
			"size": Vector3(220, 8.0, 25),
			"density": 0.03,
			"albedo": Color(0.85, 0.85, 0.92),
			"emission": Color(0.0, 0.0, 0.0),
			"phase_density_mult": {&"dawn": 1.6, &"day": 0.8, &"dusk": 1.4, &"night": 1.0},
			"weather_density_mult": {&"clear": 1.0, &"cloudy": 1.5, &"storm": 2.0, &"fog": 2.8},
		},
		{
			"id": &"final_vault_emanation",
			"display_name": "Final Vault Emanation",
			"shape": &"box",
			"position_offset": Vector3(45, 0.0, -85),  # at the eastmost mouth
			"size": Vector3(20, 4.0, 14),
			"density": 0.10,
			"albedo": Color(0.80, 0.78, 0.95),
			"emission": Color(0.30, 0.30, 0.50),  # always faintly glowing
			"phase_density_mult": {&"dawn": 1.0, &"day": 1.0, &"dusk": 1.0, &"night": 1.4},
			"weather_density_mult": {&"clear": 1.0, &"glitch_storm": 2.5},
			"iteration_gate_min": 4,  # only appears once the player has seen it
		},
	],
	&"wild_pasture": [
		{
			"id": &"pasture_dawn_mist",
			"display_name": "Pasture Dawn Mist",
			"shape": &"box",
			"position_offset": Vector3(0, 0.6, 0),
			"size": Vector3(60, 1.5, 50),
			"density": 0.08,
			"albedo": Color(0.92, 0.90, 0.78),
			"emission": Color(0.0, 0.0, 0.0),
			"phase_density_mult": {&"dawn": 2.5, &"day": 0.2, &"dusk": 0.8, &"night": 1.0},
			"weather_density_mult": {&"clear": 1.0, &"rain": 1.3, &"fog": 2.0},
		},
	],
	&"wild_plateau": [
		{
			"id": &"plateau_horizon_haze",
			"display_name": "Plateau Horizon Haze",
			"shape": &"box",
			"position_offset": Vector3(0, 3.0, 0),
			"size": Vector3(120, 4.0, 80),
			"density": 0.025,
			"albedo": Color(0.92, 0.88, 0.82),
			"emission": Color(0.0, 0.0, 0.0),
			"phase_density_mult": {&"dawn": 1.4, &"day": 0.6, &"dusk": 1.5, &"night": 0.9},
			"weather_density_mult": {&"clear": 1.0, &"cloudy": 1.4, &"rain": 1.2, &"fog": 2.5},
		},
	],
}


static func get_volumes_for_region(region_id: StringName) -> Array:
	return REGION_VOLUMES.get(region_id, [])


static func get_density_for(entry: Dictionary, phase: StringName, weather: StringName) -> float:
	var base: float = float(entry.get("density", 0.05))
	var phase_mult: float = float(entry.get("phase_density_mult", {}).get(phase, 1.0))
	var weather_mult: float = float(entry.get("weather_density_mult", {}).get(weather, 1.0))
	return base * phase_mult * weather_mult


static func get_count() -> int:
	var n: int = 0
	for region in REGION_VOLUMES.keys():
		n += (REGION_VOLUMES[region] as Array).size()
	return n
