class_name GroundDecalDatabase
extends RefCounted

## Catalog of ground decal types — wear marks, scuffs, mud patches, leaf
## piles, blood, glyph stains. Each entry defines the texture path,
## albedo tint, normal map (optional), size range, allowed regions,
## phase + weather restrictions, and rarity weight.
##
## A `GroundDecalSpawner` reads from this catalog at scene load time
## to scatter Decal3D nodes along path lines and inside region bounds,
## producing the lived-in feel the bible asks for ("ground decals for
## wear" — the difference between a video game floor and a place that
## people walk).
##
## Decal textures are expected at:
##   res://assets/textures/decals/<texture_id>.png
## Missing textures fall back to a tinted white plane so the system
## works even before art is produced.

const DECALS: Array[Dictionary] = [
	# === Path wear ===
	{
		"id": &"decal_path_scuff",
		"texture_id": &"path_scuff_a",
		"display_name": "Path Scuff",
		"category": &"wear",
		"regions": [&"wild_plateau", &"wild_pasture", &"wild_river", &"wild_forest", &"wild_ruins"],
		"phase_filter": [],
		"weather_blacklist": [],
		"size_min": Vector2(0.6, 0.6),
		"size_max": Vector2(1.4, 1.4),
		"albedo_tint": Color(0.55, 0.50, 0.42, 1.0),
		"depth_meters": 0.4,
		"random_rotation": true,
		"weight": 60,
		"density_per_path_meter": 0.35,
	},
	{
		"id": &"decal_footprint_human",
		"texture_id": &"footprint_human",
		"display_name": "Footprint",
		"category": &"wear",
		"regions": [&"wild_plateau", &"wild_pasture", &"wild_river"],
		"phase_filter": [],
		"weather_blacklist": [],
		"size_min": Vector2(0.25, 0.4),
		"size_max": Vector2(0.35, 0.55),
		"albedo_tint": Color(0.45, 0.40, 0.35, 1.0),
		"depth_meters": 0.2,
		"random_rotation": false,
		"weight": 25,
		"density_per_path_meter": 0.5,
	},
	{
		"id": &"decal_footprint_deer",
		"texture_id": &"footprint_deer",
		"display_name": "Deer Track",
		"category": &"wildlife",
		"regions": [&"wild_pasture", &"wild_forest"],
		"phase_filter": [],
		"weather_blacklist": [],
		"size_min": Vector2(0.18, 0.28),
		"size_max": Vector2(0.22, 0.34),
		"albedo_tint": Color(0.42, 0.36, 0.30, 1.0),
		"depth_meters": 0.18,
		"random_rotation": false,
		"weight": 12,
		"density_per_path_meter": 0.08,
	},
	# === Mud / wet ===
	{
		"id": &"decal_mud_patch",
		"texture_id": &"mud_patch",
		"display_name": "Mud Patch",
		"category": &"wet",
		"regions": [&"wild_river", &"wild_forest"],
		"phase_filter": [],
		"weather_blacklist": [],
		"size_min": Vector2(1.0, 1.0),
		"size_max": Vector2(2.5, 2.5),
		"albedo_tint": Color(0.30, 0.25, 0.18, 1.0),
		"depth_meters": 0.5,
		"random_rotation": true,
		"weight": 30,
		"density_per_region_100m2": 1.5,
		"weather_amplification": {&"rain": 2.0, &"storm": 2.5, &"clear": 0.4},
	},
	{
		"id": &"decal_puddle",
		"texture_id": &"puddle_water",
		"display_name": "Puddle",
		"category": &"wet",
		"regions": [&"wild_plateau", &"wild_pasture", &"wild_river", &"wild_forest", &"wild_ruins"],
		"phase_filter": [],
		"weather_blacklist": [&"clear"],
		"size_min": Vector2(0.8, 0.8),
		"size_max": Vector2(1.8, 1.8),
		"albedo_tint": Color(0.55, 0.62, 0.70, 0.85),
		"depth_meters": 0.3,
		"random_rotation": true,
		"weight": 18,
		"density_per_region_100m2": 0.8,
		"weather_amplification": {&"rain": 3.0, &"storm": 4.0},
	},
	# === Leaves / flora debris ===
	{
		"id": &"decal_leaf_pile",
		"texture_id": &"leaves_pile",
		"display_name": "Leaf Pile",
		"category": &"flora",
		"regions": [&"wild_forest"],
		"phase_filter": [],
		"weather_blacklist": [],
		"size_min": Vector2(0.7, 0.7),
		"size_max": Vector2(1.6, 1.6),
		"albedo_tint": Color(0.55, 0.42, 0.22, 1.0),
		"depth_meters": 0.4,
		"random_rotation": true,
		"weight": 22,
		"density_per_region_100m2": 2.0,
	},
	{
		"id": &"decal_petal_drift",
		"texture_id": &"petal_drift",
		"display_name": "Petal Drift",
		"category": &"flora",
		"regions": [&"wild_pasture"],
		"phase_filter": [&"day", &"dawn", &"dusk"],
		"weather_blacklist": [&"storm", &"glitch_storm"],
		"size_min": Vector2(0.5, 0.5),
		"size_max": Vector2(1.2, 1.2),
		"albedo_tint": Color(0.95, 0.85, 0.78, 1.0),
		"depth_meters": 0.2,
		"random_rotation": true,
		"weight": 15,
		"density_per_region_100m2": 1.0,
	},
	# === Ruin stains ===
	{
		"id": &"decal_glyph_stain",
		"texture_id": &"glyph_stain",
		"display_name": "Faded Glyph",
		"category": &"ruin",
		"regions": [&"wild_ruins"],
		"phase_filter": [],
		"weather_blacklist": [],
		"size_min": Vector2(0.6, 0.6),
		"size_max": Vector2(1.5, 1.5),
		"albedo_tint": Color(0.65, 0.55, 0.42, 1.0),
		"depth_meters": 0.25,
		"random_rotation": true,
		"weight": 18,
		"density_per_region_100m2": 1.5,
		"emissive_at_night": true,
		"emission_color": Color(0.55, 0.40, 0.85, 1.0),
		"emission_energy": 0.4,
	},
	{
		"id": &"decal_corruption_smear",
		"texture_id": &"corruption_smear",
		"display_name": "Corruption Smear",
		"category": &"ruin",
		"regions": [&"wild_ruins"],
		"phase_filter": [],
		"weather_blacklist": [],
		"size_min": Vector2(0.8, 0.8),
		"size_max": Vector2(2.0, 2.0),
		"albedo_tint": Color(0.30, 0.10, 0.40, 1.0),
		"depth_meters": 0.35,
		"random_rotation": true,
		"weight": 8,
		"density_per_region_100m2": 0.6,
		"emissive_at_night": true,
		"emission_color": Color(0.85, 0.20, 0.95, 1.0),
		"emission_energy": 0.6,
		"iteration_unlock": 3,
	},
	# === Cliff side ===
	{
		"id": &"decal_wind_polish",
		"texture_id": &"wind_polish",
		"display_name": "Wind-Polished Stone",
		"category": &"wear",
		"regions": [&"wild_cliffs"],
		"phase_filter": [],
		"weather_blacklist": [],
		"size_min": Vector2(0.6, 0.6),
		"size_max": Vector2(1.4, 1.4),
		"albedo_tint": Color(0.78, 0.78, 0.82, 1.0),
		"depth_meters": 0.3,
		"random_rotation": true,
		"weight": 25,
		"density_per_region_100m2": 1.2,
	},
]


static func get_decal(decal_id: StringName) -> Dictionary:
	for entry in DECALS:
		if entry["id"] == decal_id:
			return entry
	return {}


static func get_for_region(region_id: StringName, weather: StringName, phase: StringName, iteration: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in DECALS:
		if not entry.get("regions", []).has(region_id):
			continue
		var phase_filter: Array = entry.get("phase_filter", [])
		if not phase_filter.is_empty() and not phase_filter.has(phase):
			continue
		var blacklist: Array = entry.get("weather_blacklist", [])
		if blacklist.has(weather):
			continue
		var iter_unlock: int = entry.get("iteration_unlock", 0)
		if iter_unlock > 0 and iteration < iter_unlock:
			continue
		result.append(entry)
	return result


static func get_count() -> int:
	return DECALS.size()
