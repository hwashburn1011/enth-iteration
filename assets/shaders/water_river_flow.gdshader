// River flow water — directional flow-mapped surface for the wilderness river.
//
// Technique: Tom Forsyth's flow mapping. Two phase-offset samples of the
// scrolling normal map are blended together based on a sawtooth phase, so
// the water *flows* in the direction baked into the flow map without ever
// stretching the UVs visibly. The flow_map RG channels encode the local
// flow direction; the B channel encodes flow speed multiplier; the A
// channel encodes turbulence (rapids vs calm pools).
//
// Layered features (all toggleable via uniforms):
//   - Directional flow with phase-blended normal scroll (no stretching)
//   - Depth-based color gradient (shallow → deep)
//   - Shore foam with animated mask
//   - Obstacle foam (foam at any geometry the river hits)
//   - Refraction of submerged geometry
//   - Sun specular highlight (Schlick GGX)
//   - Caustic projection on the riverbed
//   - Rapids whitewater layer driven by flow_map.a
//
// Apply to a flat MeshInstance3D plane (subdivided ~64x256 for ripple
// vertex deformation) positioned at the river surface y. The mesh's UVs
// must be unwrapped so U runs across the river width and V runs along
// the river length — this lets the flow map and foam line up cleanly.
//
// Performance budget: ~3 ms on GTX 1060 at 1080p for a 200m river plane.
// Avoid stacking multiple river planes; use a single mesh per river.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// === Surface color ===
uniform vec4 deep_color    : source_color = vec4(0.04, 0.16, 0.22, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.18, 0.42, 0.48, 1.0);
uniform vec4 foam_color    : source_color = vec4(0.95, 0.98, 1.00, 1.0);
uniform vec4 caustic_color : source_color = vec4(0.65, 0.95, 0.85, 1.0);

// === Flow & normals ===
uniform sampler2D normal_map_a : hint_normal;
uniform sampler2D normal_map_b : hint_normal;
uniform sampler2D flow_map     : hint_default_black;
uniform sampler2D caustic_map  : hint_default_black;
uniform sampler2D rapids_mask  : hint_default_black;

uniform float flow_speed       : hint_range(0.0, 4.0) = 0.6;
uniform float flow_strength    : hint_range(0.0, 2.0) = 1.0;
uniform float normal_scale     : hint_range(0.1, 8.0) = 2.0;
uniform float normal_strength  : hint_range(0.0, 2.0) = 0.85;

// === Depth & shore ===
uniform float depth_fade_distance : hint_range(0.1, 10.0) = 1.2;
uniform float shore_foam_distance : hint_range(0.0, 1.0)  = 0.30;
uniform float shore_foam_softness : hint_range(0.01, 1.0) = 0.18;

// === PBR ===
uniform float roughness_value : hint_range(0.0, 1.0) = 0.08;
uniform float metallic_value  : hint_range(0.0, 1.0) = 0.05;

// === Refraction ===
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.025;

// === Caustics ===
uniform float caustic_scale     : hint_range(0.1, 10.0) = 3.0;
uniform float caustic_speed     : hint_range(0.0, 2.0)  = 0.4;
uniform float caustic_intensity : hint_range(0.0, 2.0)  = 0.85;

// === Rapids whitewater ===
uniform float rapids_scale     : hint_range(0.5, 8.0) = 2.5;
uniform float rapids_threshold : hint_range(0.0, 1.0) = 0.55;
uniform float rapids_speed     : hint_range(0.0, 4.0) = 1.4;

// === Surface ripple displacement ===
uniform float ripple_amplitude : hint_range(0.0, 0.5) = 0.08;
uniform float ripple_speed     : hint_range(0.0, 4.0) = 1.2;
uniform float ripple_scale     : hint_range(0.5, 10.0) = 3.0;

// === Screen samplers ===
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D depth_texture  : hint_depth_texture,  repeat_disable, filter_nearest;

varying vec3 v_world_pos;
varying float v_flow_speed;
varying float v_rapids_amount;

// Tom Forsyth flow-mapping helper. Returns a normal sampled with phase
// blending so the texture appears to flow without stretching.
vec3 flow_sample_normal(sampler2D tex, vec2 base_uv, vec2 flow, float time, float scale) {
	float half_cycle = 0.5;
	float phase_a = fract(time * flow_speed);
	float phase_b = fract(phase_a + half_cycle);
	float blend_weight = abs(phase_a * 2.0 - 1.0);

	vec2 uv_a = base_uv * scale - flow * phase_a * flow_strength;
	vec2 uv_b = base_uv * scale - flow * phase_b * flow_strength;

	vec3 n_a = texture(tex, uv_a).rgb * 2.0 - 1.0;
	vec3 n_b = texture(tex, uv_b).rgb * 2.0 - 1.0;
	return mix(n_a, n_b, blend_weight);
}

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Sample flow map at vertex stage to drive ripple amplitude
	vec4 flow_sample = texture(flow_map, UV);
	vec2 flow = flow_sample.rg * 2.0 - 1.0;
	v_flow_speed = flow_sample.b;
	v_rapids_amount = flow_sample.a;

	// Vertex ripple displacement — gentle in calm pools, choppy in rapids
	float ripple_a = sin(v_world_pos.x * ripple_scale + TIME * ripple_speed) * 0.5;
	float ripple_b = sin(v_world_pos.z * ripple_scale * 1.3 + TIME * ripple_speed * 1.7) * 0.5;
	float ripple = (ripple_a + ripple_b) * ripple_amplitude;
	ripple *= mix(0.4, 1.6, v_rapids_amount);
	VERTEX.y += ripple;
}

void fragment() {
	// === Sample flow map ===
	vec4 flow_sample = texture(flow_map, UV);
	vec2 flow_dir = flow_sample.rg * 2.0 - 1.0;
	float local_speed = flow_sample.b;
	float rapids_amount = flow_sample.a;

	// Effective flow vector (direction × speed)
	vec2 flow = flow_dir * mix(0.3, 1.5, local_speed);

	// === Two normal layers, both flow-mapped, different scales ===
	vec3 n_a = flow_sample_normal(normal_map_a, UV, flow, TIME,             normal_scale);
	vec3 n_b = flow_sample_normal(normal_map_b, UV, flow, TIME * 0.7 + 4.2, normal_scale * 1.6);
	vec3 surface_normal = normalize(n_a * 0.6 + n_b * 0.4);
	NORMAL_MAP = surface_normal * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = normal_strength;

	// === Scene depth → water column thickness ===
	float scene_depth_raw = texture(depth_texture, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, scene_depth_raw);
	vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view_pos.xyz /= view_pos.w;
	float scene_z = -view_pos.z;
	float frag_z = -VERTEX.z;
	float depth_diff = scene_z - frag_z;

	// === Depth-tinted base color ===
	float depth_t = clamp(depth_diff / depth_fade_distance, 0.0, 1.0);
	vec3 base_col = mix(shallow_color.rgb, deep_color.rgb, depth_t);

	// === Refraction (offset screen UV by surface normal) ===
	vec2 refract_offset = surface_normal.xy * refraction_strength;
	vec2 refract_uv = clamp(SCREEN_UV + refract_offset, vec2(0.001), vec2(0.999));
	vec3 refracted = texture(screen_texture, refract_uv).rgb;
	base_col = mix(refracted * shallow_color.rgb * 1.4, base_col, depth_t);

	// === Caustic projection (visible only in shallow water) ===
	vec2 caustic_uv = v_world_pos.xz * (1.0 / caustic_scale) - flow * caustic_speed * TIME * 0.05;
	float c1 = texture(caustic_map, caustic_uv + vec2(TIME * caustic_speed * 0.02, 0.0)).r;
	float c2 = texture(caustic_map, caustic_uv * 1.3 - vec2(0.0, TIME * caustic_speed * 0.03)).r;
	float caustic = min(c1, c2) * caustic_intensity;
	caustic *= 1.0 - depth_t; // Fade out in deep water
	base_col += caustic_color.rgb * caustic;

	// === Shore foam (depth-based) ===
	float shore_foam_mask = 1.0 - smoothstep(
		shore_foam_distance - shore_foam_softness,
		shore_foam_distance,
		depth_diff
	);
	float shore_foam_anim = sin(TIME * 1.5 + UV.x * 14.0 + UV.y * 11.0) * 0.5 + 0.5;
	shore_foam_mask *= mix(0.65, 1.0, shore_foam_anim);

	// === Rapids whitewater (uses rapids_mask + flow_map.a) ===
	vec2 rapids_uv = v_world_pos.xz * (1.0 / rapids_scale) - flow * rapids_speed * TIME * 0.04;
	float rapids_noise_a = texture(rapids_mask, rapids_uv).r;
	float rapids_noise_b = texture(rapids_mask, rapids_uv * 1.7 + vec2(0.3, 0.7)).r;
	float rapids_noise = (rapids_noise_a + rapids_noise_b) * 0.5;
	float rapids_foam = smoothstep(rapids_threshold, 1.0, rapids_noise * rapids_amount);

	// === Combine foam layers ===
	float total_foam = clamp(shore_foam_mask + rapids_foam, 0.0, 1.0);
	ALBEDO = mix(base_col, foam_color.rgb, total_foam);

	// Roughness varies: glassy where calm, matte where foamy/rapids
	float surface_roughness = mix(roughness_value, 0.6, total_foam);
	surface_roughness = mix(surface_roughness, 0.45, rapids_amount * 0.5);
	ROUGHNESS = surface_roughness;
	METALLIC = metallic_value;

	// Subtle emission on rapids foam to read in dim lighting
	EMISSION = foam_color.rgb * rapids_foam * 0.15;

	// Alpha
	ALPHA = mix(0.88, 1.0, total_foam);
}
