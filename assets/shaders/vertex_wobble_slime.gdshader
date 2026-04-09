// Vertex wobble shader for slime / blob enemies. Task 29 of Epic 20.
// Translucent jelly with internal data scroll. Apply to MemoryLeak family.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D inner_data_texture : source_color, hint_default_white, repeat_enable;
uniform vec4 base_color : source_color = vec4(0.30, 0.85, 0.65, 0.85);
uniform vec4 inner_color : source_color = vec4(0.10, 1.00, 0.85, 1.0);

uniform float wobble_amplitude : hint_range(0.0, 0.3) = 0.04;
uniform float wobble_speed     : hint_range(0.0, 8.0) = 2.0;
uniform float wobble_freq      : hint_range(0.5, 20.0) = 5.0;
uniform float scroll_speed     : hint_range(0.0, 4.0) = 0.6;
uniform float fresnel_strength : hint_range(0.0, 5.0) = 1.5;
uniform float subsurface_scale : hint_range(0.0, 5.0) = 1.0;

void vertex() {
	float t = TIME * wobble_speed;
	vec3 offset = vec3(
		sin(VERTEX.y * wobble_freq + t),
		sin(VERTEX.x * wobble_freq + t * 1.3),
		sin(VERTEX.x * wobble_freq * 0.7 + t * 0.8)
	);
	VERTEX += NORMAL * dot(offset, vec3(0.33)) * wobble_amplitude;
}

void fragment() {
	vec2 inner_uv = UV + vec2(TIME * scroll_speed, sin(TIME * 0.5) * 0.1);
	vec3 inner = texture(inner_data_texture, inner_uv).rgb * inner_color.rgb;

	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);

	ALBEDO = base_color.rgb;
	EMISSION = inner * (1.0 - fres) * subsurface_scale + base_color.rgb * fres * fresnel_strength * 0.5;
	ALPHA = mix(0.6, 0.95, fres) * base_color.a;
	ROUGHNESS = 0.25;
	METALLIC = 0.0;
}
