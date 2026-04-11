// foliage_wind.gdshader
//
// Vertex animation wind shader for vegetation (Epic 13 task 8).
// Drives gentle wind sway on trees, bushes, grass, and other foliage.
// Vertex displacement is height-weighted so the base of the plant stays
// rooted while the top sways naturally.
//
// Used by:
//   - All foliage MeshInstance3D in the vegetation library
//   - Hooks to a global wind direction uniform set by the WindZone autoload
//
// The shader uses world-space vertex position to ensure that nearby
// foliage sways in sync (avoids the "jelly grass" artifact where every
// instance has its own random phase).

shader_type spatial;
render_mode cull_disabled, blend_mix, depth_draw_opaque;

// === BAKED MAPS ===
uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform sampler2D normal_tex : hint_normal;

// === MATERIAL ===
uniform float roughness : hint_range(0.0, 1.0) = 0.75;
uniform float alpha_cutoff : hint_range(0.0, 1.0) = 0.5;
uniform vec3 translucency_color : source_color = vec3(0.45, 0.65, 0.20);
uniform float translucency_strength : hint_range(0.0, 2.0) = 0.45;

// === WIND ===
// Set globally per scene by a WindZone autoload
uniform vec2 wind_direction = vec2(1.0, 0.0);
uniform float wind_strength : hint_range(0.0, 5.0) = 0.6;
uniform float wind_speed : hint_range(0.0, 8.0) = 1.5;
uniform float wind_height_falloff : hint_range(0.0, 8.0) = 2.0;

// === GUST ===
// Higher-frequency local wobble on top of the base wind
uniform float gust_frequency : hint_range(0.0, 12.0) = 4.0;
uniform float gust_amplitude : hint_range(0.0, 0.40) = 0.08;

void vertex() {
	// Height factor: 0 at base, 1 at top — controls how much wind affects each vert
	// Use the vertex's local Y as the proxy for height (most foliage models are
	// authored with Z up, so we use Z)
	float height_factor = clamp(VERTEX.z * wind_height_falloff, 0.0, 1.0);
	height_factor = pow(height_factor, 1.5);  // ease so the bottom is rock-solid

	// Base wind sway: sin wave driven by world position so neighboring instances align
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * wind_speed;
	float wave = sin(t + world_pos.x * 0.3 + world_pos.z * 0.2);
	vec2 sway = wind_direction * wave * wind_strength * 0.10;

	// Gust: higher-frequency local wobble
	float gust = sin(t * gust_frequency + world_pos.x * 1.2) * gust_amplitude;
	sway += wind_direction * gust;

	// Apply only at non-base verts
	VERTEX.x += sway.x * height_factor;
	VERTEX.y += sway.y * height_factor;
}

void fragment() {
	vec4 base = texture(albedo_tex, UV);
	if (base.a < alpha_cutoff) {
		discard;
	}
	ALBEDO = base.rgb;
	ROUGHNESS = roughness;
	NORMAL_MAP = texture(normal_tex, UV).rgb;

	// Translucency — gives leaves the "light through them" look
	BACKLIGHT = translucency_color * translucency_strength;
}
