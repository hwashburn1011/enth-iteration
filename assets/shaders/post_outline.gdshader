// Post-process outline shader. Task 38 of Epic 20.
// Apply to a full-screen quad in a SubViewport pipeline. Detects depth + normal
// discontinuities to draw outlines around objects (cel-shaded look).

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float depth_threshold : hint_range(0.0, 1.0) = 0.0008;
uniform float normal_threshold : hint_range(0.0, 1.0) = 0.6;
uniform float outline_thickness : hint_range(0.5, 4.0) = 1.0;

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE * outline_thickness;
	vec3 base = texture(screen_texture, SCREEN_UV).rgb;

	float d_c = texture(depth_texture, SCREEN_UV).r;
	float d_l = texture(depth_texture, SCREEN_UV - vec2(px.x, 0.0)).r;
	float d_r = texture(depth_texture, SCREEN_UV + vec2(px.x, 0.0)).r;
	float d_u = texture(depth_texture, SCREEN_UV - vec2(0.0, px.y)).r;
	float d_d = texture(depth_texture, SCREEN_UV + vec2(0.0, px.y)).r;

	float depth_diff = max(max(abs(d_c - d_l), abs(d_c - d_r)), max(abs(d_c - d_u), abs(d_c - d_d)));
	float depth_edge = step(depth_threshold, depth_diff);

	vec3 n_c = texture(normal_texture, SCREEN_UV).rgb;
	vec3 n_l = texture(normal_texture, SCREEN_UV - vec2(px.x, 0.0)).rgb;
	vec3 n_r = texture(normal_texture, SCREEN_UV + vec2(px.x, 0.0)).rgb;
	float normal_diff = max(length(n_c - n_l), length(n_c - n_r));
	float normal_edge = step(normal_threshold, normal_diff);

	float edge = max(depth_edge, normal_edge);
	COLOR = vec4(mix(base, outline_color.rgb, edge), 1.0);
}
