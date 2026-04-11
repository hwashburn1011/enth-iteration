// PBR water shader: normals + foam + depth fade + shore foam + flow direction.
// Single shader covers tasks 1-5 of Epic 20 by exposing all features as uniforms.
// Apply to a flat MeshInstance3D plane positioned at the water surface.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color   : source_color = vec4(0.05, 0.20, 0.35, 1.0);
uniform vec4 shallow_color: source_color = vec4(0.20, 0.55, 0.65, 1.0);
uniform vec4 foam_color   : source_color = vec4(0.95, 0.98, 1.00, 1.0);

uniform sampler2D normal_map_a : hint_normal;
uniform sampler2D normal_map_b : hint_normal;
uniform sampler2D flow_map     : hint_default_black;

uniform float wave_speed : hint_range(0.0, 2.0) = 0.15;
uniform float wave_scale : hint_range(0.1, 5.0) = 1.0;
uniform float depth_fade_distance : hint_range(0.1, 10.0) = 1.5;
uniform float foam_distance       : hint_range(0.0, 1.0) = 0.25;
uniform float foam_softness       : hint_range(0.01, 1.0) = 0.20;
uniform float roughness_value     : hint_range(0.0, 1.0) = 0.10;
uniform float metallic_value      : hint_range(0.0, 1.0) = 0.05;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D depth_texture  : hint_depth_texture,  repeat_disable, filter_nearest;

void fragment() {
	// Sample two scrolling normal maps in opposite directions for shimmer
	vec2 flow = texture(flow_map, UV).rg * 2.0 - 1.0;
	vec2 uv_a = UV * wave_scale + flow * 0.1 + vec2(TIME * wave_speed, 0.0);
	vec2 uv_b = UV * wave_scale * 1.7 - flow * 0.07 + vec2(0.0, TIME * wave_speed * 0.7);
	vec3 n_a = texture(normal_map_a, uv_a).rgb * 2.0 - 1.0;
	vec3 n_b = texture(normal_map_b, uv_b).rgb * 2.0 - 1.0;
	NORMAL_MAP = normalize(mix(vec3(0.5, 0.5, 1.0), (n_a + n_b) * 0.5 + 0.5, 0.85));

	// Read scene depth to compute water column thickness for depth fade + shore foam
	float scene_depth_raw = texture(depth_texture, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, scene_depth_raw);
	vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view_pos.xyz /= view_pos.w;
	float scene_z = -view_pos.z;
	float frag_z = -VERTEX.z;
	float depth_diff = scene_z - frag_z;

	// Depth tint
	float depth_t = clamp(depth_diff / depth_fade_distance, 0.0, 1.0);
	vec3 base_col = mix(shallow_color.rgb, deep_color.rgb, depth_t);

	// Shore foam
	float foam_mask = 1.0 - smoothstep(foam_distance - foam_softness, foam_distance, depth_diff);
	float foam_anim = sin(TIME * 1.5 + UV.x * 12.0 + UV.y * 9.0) * 0.5 + 0.5;
	foam_mask *= mix(0.7, 1.0, foam_anim);

	ALBEDO = mix(base_col, foam_color.rgb, foam_mask);
	ROUGHNESS = mix(roughness_value, 0.4, foam_mask);
	METALLIC = metallic_value;

	// Alpha goes opaque under foam, mostly transparent in deep water
	ALPHA = mix(0.85, 1.0, foam_mask);
}
