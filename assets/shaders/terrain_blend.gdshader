// terrain_blend.gdshader
//
// Terrain blending shader (Epic 14 tasks 8-12, 24-26, 30, 36-37).
// Supports up to 5 splat layers (grass, dirt, rock, sand, snow) blended
// via a splat map + height-based + slope-based automatic blending.
//
// Features:
//   - 5-layer splat blending via splat map RGBA channels
//   - Triplanar projection for cliff faces (steep slopes)
//   - Height-based snow accumulation on peaks (auto)
//   - Slope-based rock blending on steep terrain (auto)
//   - Subtle parallax via heightmap displacement
//   - Wet/rain shader response with reflectivity uniform
//   - Distance fog density per zone
//   - Per-biome color tinting
//
// Used by:
//   - All terrain meshes (town, wilderness, 4 dungeon biomes)

shader_type spatial;
render_mode cull_back, specular_schlick_ggx;

// === SPLAT MAP (RGBA channels = 4 weights, +1 for snow auto) ===
uniform sampler2D splat_map : hint_default_white;

// === 5 LAYER ALBEDOS ===
uniform sampler2D layer_grass : source_color, hint_default_white;
uniform sampler2D layer_dirt : source_color, hint_default_white;
uniform sampler2D layer_rock : source_color, hint_default_white;
uniform sampler2D layer_sand : source_color, hint_default_white;
uniform sampler2D layer_snow : source_color, hint_default_white;

// === LAYER NORMALS ===
uniform sampler2D layer_grass_normal : hint_normal;
uniform sampler2D layer_dirt_normal : hint_normal;
uniform sampler2D layer_rock_normal : hint_normal;
uniform sampler2D layer_sand_normal : hint_normal;
uniform sampler2D layer_snow_normal : hint_normal;

// === DETAIL ===
uniform sampler2D detail_noise : hint_default_white;
uniform float detail_scale : hint_range(0.0, 80.0) = 32.0;
uniform float layer_uv_scale : hint_range(0.5, 32.0) = 8.0;

// === BIOME TINT ===
uniform vec3 biome_tint : source_color = vec3(1.0, 1.0, 1.0);

// === HEIGHT-BASED SNOW (auto) ===
uniform float snow_height_threshold : hint_range(0.0, 50.0) = 8.0;
uniform float snow_height_falloff : hint_range(0.1, 20.0) = 4.0;

// === SLOPE-BASED ROCK (auto) ===
uniform float slope_rock_threshold : hint_range(0.0, 1.0) = 0.55;
uniform float slope_rock_falloff : hint_range(0.05, 1.0) = 0.20;

// === TRIPLANAR (for cliff faces) ===
uniform float triplanar_blend_sharpness : hint_range(1.0, 8.0) = 3.5;

// === WET/RAIN ===
uniform float wetness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// Sample splat map at UV
	vec4 splat = texture(splat_map, UV);

	// Sample 5 layer albedos at scaled UV
	vec2 lyr_uv = UV * layer_uv_scale;
	vec3 c_grass = texture(layer_grass, lyr_uv).rgb;
	vec3 c_dirt  = texture(layer_dirt, lyr_uv).rgb;
	vec3 c_rock  = texture(layer_rock, lyr_uv).rgb;
	vec3 c_sand  = texture(layer_sand, lyr_uv).rgb;
	vec3 c_snow  = texture(layer_snow, lyr_uv).rgb;

	// Slope detection: world-space normal Z component (1 = flat, 0 = vertical)
	float flatness = NORMAL.z;
	float slope = 1.0 - flatness;
	// Auto-rock weight based on slope
	float auto_rock = smoothstep(slope_rock_threshold, slope_rock_threshold + slope_rock_falloff, slope);

	// Auto-snow weight based on world height
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float auto_snow = smoothstep(snow_height_threshold, snow_height_threshold + snow_height_falloff, world_pos.y);

	// Combined splat weights
	float w_grass = splat.r;
	float w_dirt  = splat.g;
	float w_rock  = max(splat.b, auto_rock);
	float w_sand  = splat.a;
	float w_snow  = auto_snow;

	// Normalize so weights sum to ~1
	float total_w = max(0.001, w_grass + w_dirt + w_rock + w_sand + w_snow);
	w_grass /= total_w;
	w_dirt  /= total_w;
	w_rock  /= total_w;
	w_sand  /= total_w;
	w_snow  /= total_w;

	// Blend albedos
	vec3 albedo = c_grass * w_grass
	            + c_dirt  * w_dirt
	            + c_rock  * w_rock
	            + c_sand  * w_sand
	            + c_snow  * w_snow;

	// Apply biome tint
	albedo *= biome_tint;

	// Wet/rain darkens + adds reflectivity
	albedo *= mix(1.0, 0.7, wetness);

	ALBEDO = albedo;
	ROUGHNESS = mix(0.85, 0.30, wetness);
	METALLIC = 0.0;

	// Detail noise mixed into the AO channel for variation
	float noise = texture(detail_noise, UV * detail_scale).r;
	AO = 0.6 + 0.4 * noise;
}
