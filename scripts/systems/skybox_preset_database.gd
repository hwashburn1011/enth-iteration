class_name SkyboxPresetDatabase
extends RefCounted

## Catalog of skybox presets used by the day/night cycle. Each preset
## defines a complete sky configuration that can be applied to the
## active WorldEnvironment's ProceduralSkyMaterial:
##
##   - sky_top_color, sky_horizon_color, sky_ground_color
##   - sky_energy_multiplier
##   - sun_angle_max
##   - ground_horizon_color
##   - cover/cloud tint hints (consumed by future cloud cookie shader)
##   - star_visibility (0..1, drives star particle layer alpha)
##   - moon_visibility (0..1, drives moon mesh alpha + light energy)
##
## DayNightController interpolates between two consecutive presets each
## frame using the current phase progress (0..1 within phase). The
## blend lives in DayNightSkyboxBlender (built per task 4 and reused
## here).
##
## Presets:
##   1. dawn          — golden horizon, blue-purple top, soft star hint
##   2. noon          — open blue, low fog, sun overhead
##   3. dusk          — deep orange-red horizon, indigo top, first stars
##   4. night         — deep blue-black, full starfield, moon visible
##   5. night_moon    — variant of night with brighter moon (full moon)
##   6. cloudy        — desaturated, slate horizon, no sun glow
##   7. storm         — dark gray, low energy, occasional lightning hint
##
## Each preset is just a static dict — designers tweak by editing this
## file. The blender component handles smooth interpolation.

const PRESETS: Dictionary = {
	&"dawn": {
		"display_name": "Dawn",
		"sky_horizon_color": Color(1.00, 0.62, 0.42),  # warm orange
		"sky_top_color":     Color(0.30, 0.32, 0.55),  # blue-purple
		"sky_ground_color":  Color(0.42, 0.32, 0.28),
		"sky_energy_multiplier": 0.85,
		"sun_angle_max": 80.0,
		"sun_curve": 0.18,
		"ground_horizon_color": Color(0.55, 0.40, 0.35),
		"cloud_tint": Color(1.00, 0.78, 0.62),
		"star_visibility": 0.35,  # very faint
		"moon_visibility": 0.20,
		"fog_color": Color(0.85, 0.65, 0.55),
		"fog_density": 0.014,
		"ambient_color": Color(0.55, 0.45, 0.45),
		"ambient_energy": 0.55,
	},
	&"noon": {
		"display_name": "Noon",
		"sky_horizon_color": Color(0.65, 0.82, 0.95),
		"sky_top_color":     Color(0.20, 0.42, 0.85),
		"sky_ground_color":  Color(0.42, 0.40, 0.32),
		"sky_energy_multiplier": 1.10,
		"sun_angle_max": 100.0,
		"sun_curve": 0.15,
		"ground_horizon_color": Color(0.45, 0.40, 0.32),
		"cloud_tint": Color(1.00, 1.00, 0.98),
		"star_visibility": 0.0,
		"moon_visibility": 0.0,
		"fog_color": Color(0.75, 0.85, 0.95),
		"fog_density": 0.0,
		"ambient_color": Color(0.62, 0.65, 0.62),
		"ambient_energy": 0.72,
	},
	&"dusk": {
		"display_name": "Dusk",
		"sky_horizon_color": Color(1.00, 0.42, 0.22),  # deep orange-red
		"sky_top_color":     Color(0.20, 0.18, 0.42),  # indigo
		"sky_ground_color":  Color(0.30, 0.22, 0.20),
		"sky_energy_multiplier": 0.80,
		"sun_angle_max": 80.0,
		"sun_curve": 0.20,
		"ground_horizon_color": Color(0.42, 0.22, 0.20),
		"cloud_tint": Color(1.00, 0.55, 0.32),
		"star_visibility": 0.45,  # first stars appearing
		"moon_visibility": 0.45,
		"fog_color": Color(0.85, 0.45, 0.30),
		"fog_density": 0.012,
		"ambient_color": Color(0.55, 0.35, 0.32),
		"ambient_energy": 0.50,
	},
	&"night": {
		"display_name": "Night",
		"sky_horizon_color": Color(0.05, 0.07, 0.14),
		"sky_top_color":     Color(0.01, 0.02, 0.06),  # near-black
		"sky_ground_color":  Color(0.0, 0.0, 0.02),
		"sky_energy_multiplier": 0.30,
		"sun_angle_max": 60.0,  # below horizon
		"sun_curve": 0.10,
		"ground_horizon_color": Color(0.05, 0.07, 0.14),
		"cloud_tint": Color(0.30, 0.40, 0.55),
		"star_visibility": 1.00,
		"moon_visibility": 0.85,
		"fog_color": Color(0.10, 0.13, 0.20),
		"fog_density": 0.006,
		"ambient_color": Color(0.10, 0.13, 0.22),
		"ambient_energy": 0.22,
	},
	&"night_moon": {
		"display_name": "Night with Moon",
		"sky_horizon_color": Color(0.06, 0.08, 0.18),
		"sky_top_color":     Color(0.02, 0.04, 0.10),
		"sky_ground_color":  Color(0.0, 0.0, 0.02),
		"sky_energy_multiplier": 0.40,  # brighter from moonlight
		"sun_angle_max": 60.0,
		"sun_curve": 0.10,
		"ground_horizon_color": Color(0.08, 0.10, 0.18),
		"cloud_tint": Color(0.45, 0.55, 0.70),
		"star_visibility": 0.85,  # slightly washed out by moon
		"moon_visibility": 1.00,  # FULL moon
		"fog_color": Color(0.14, 0.18, 0.28),
		"fog_density": 0.006,
		"ambient_color": Color(0.18, 0.22, 0.32),
		"ambient_energy": 0.32,
	},
	&"cloudy": {
		"display_name": "Cloudy",
		"sky_horizon_color": Color(0.65, 0.68, 0.72),
		"sky_top_color":     Color(0.45, 0.48, 0.55),
		"sky_ground_color":  Color(0.35, 0.35, 0.32),
		"sky_energy_multiplier": 0.65,
		"sun_angle_max": 80.0,
		"sun_curve": 0.30,  # softer sun edge
		"ground_horizon_color": Color(0.45, 0.45, 0.42),
		"cloud_tint": Color(0.78, 0.78, 0.82),
		"star_visibility": 0.0,
		"moon_visibility": 0.0,
		"fog_color": Color(0.65, 0.68, 0.72),
		"fog_density": 0.018,
		"ambient_color": Color(0.45, 0.48, 0.50),
		"ambient_energy": 0.55,
	},
	&"storm": {
		"display_name": "Storm",
		"sky_horizon_color": Color(0.32, 0.34, 0.40),
		"sky_top_color":     Color(0.18, 0.20, 0.28),
		"sky_ground_color":  Color(0.22, 0.22, 0.25),
		"sky_energy_multiplier": 0.45,
		"sun_angle_max": 80.0,
		"sun_curve": 0.40,  # very soft, sun barely visible
		"ground_horizon_color": Color(0.30, 0.32, 0.40),
		"cloud_tint": Color(0.45, 0.48, 0.55),
		"star_visibility": 0.0,
		"moon_visibility": 0.0,
		"fog_color": Color(0.30, 0.32, 0.42),
		"fog_density": 0.030,
		"ambient_color": Color(0.28, 0.30, 0.35),
		"ambient_energy": 0.40,
		"lightning_chance_per_sec": 0.10,
	},
}


static func get_preset(preset_id: StringName) -> Dictionary:
	return PRESETS.get(preset_id, {})


static func get_all_ids() -> Array:
	return PRESETS.keys()


static func get_count() -> int:
	return PRESETS.size()


static func interpolate(from_id: StringName, to_id: StringName, t: float) -> Dictionary:
	## Linear-interpolates between two presets. Used by the day/night
	## blender every frame to drive the active WorldEnvironment.
	var a: Dictionary = get_preset(from_id)
	var b: Dictionary = get_preset(to_id)
	if a.is_empty() or b.is_empty():
		return a if not a.is_empty() else b
	var result: Dictionary = {}
	t = clampf(t, 0.0, 1.0)
	for key in a.keys():
		var av: Variant = a[key]
		var bv: Variant = b.get(key, av)
		if av is Color and bv is Color:
			result[key] = (av as Color).lerp(bv, t)
		elif av is float and bv is float:
			result[key] = lerp(av as float, bv as float, t)
		elif av is int and bv is int:
			result[key] = int(round(lerp(float(av), float(bv), t)))
		else:
			# Non-numeric — switch at midpoint
			result[key] = (bv if t > 0.5 else av)
	return result
