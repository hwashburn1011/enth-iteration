// Cloth simulation shader (vertex displacement only, no real physics).
// Task 30 of Epic 20. For Architect cape, banners, hanging cloth.
// Uses sin waves driven by wind direction + vertex weight along the cloth length.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(0.85, 0.20, 0.20, 1.0);

uniform vec3 wind_dir = vec3(1.0, 0.0, 0.3);
uniform float wind_strength : hint_range(0.0, 0.5) = 0.10;
uniform float wave_speed : hint_range(0.0, 4.0) = 1.5;
uniform float wave_freq : hint_range(0.5, 16.0) = 3.0;
uniform float anchor_y : hint_range(0.0, 5.0) = 1.0;  // top of cape attaches at this Y
uniform float falloff : hint_range(0.5, 4.0) = 2.0;

void vertex() {
	// Distance from anchor — vertices farther from anchor sway more
	float dist = clamp((anchor_y - VERTEX.y) / anchor_y, 0.0, 1.0);
	float weight = pow(dist, falloff);

	float wave1 = sin(TIME * wave_speed + VERTEX.y * wave_freq) * 0.5;
	float wave2 = sin(TIME * wave_speed * 1.7 + VERTEX.y * wave_freq * 1.3 + VERTEX.x * 2.0) * 0.3;
	float total = wave1 + wave2;

	vec3 sway = normalize(wind_dir) * total * wind_strength * weight;
	VERTEX += sway;
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb * base_color.rgb;
	ROUGHNESS = 0.85;
	METALLIC = 0.0;
	ALPHA = tex.a;
}
