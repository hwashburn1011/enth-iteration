// Heat distortion shader. Task 35 of Epic 20.
// Refraction-based heat shimmer for fire pits, exhaust vents, hot terrain.
// Apply to a quad billboard or vent prop.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D noise_texture : hint_default_white, repeat_enable;

uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float scroll_speed : hint_range(0.0, 4.0) = 0.8;
uniform float fade_top : hint_range(0.0, 1.0) = 0.7;
uniform float fade_bottom : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec2 uv = UV;
	uv.y -= TIME * scroll_speed * 0.3;

	vec2 noise_uv = uv * 2.0;
	float n = texture(noise_texture, noise_uv).r;

	// Distort screen coordinates by noise
	vec2 screen_uv = SCREEN_UV;
	screen_uv.x += (n - 0.5) * distortion_strength;
	screen_uv.y += (texture(noise_texture, noise_uv * 1.3).r - 0.5) * distortion_strength;

	vec3 col = texture(screen_texture, screen_uv).rgb;

	// Vertical fade so the distortion is strongest in the middle of the quad
	float fade = smoothstep(fade_bottom, 0.5, UV.y) * (1.0 - smoothstep(0.5, fade_top, UV.y));

	ALBEDO = col;
	ALPHA = fade;
}
