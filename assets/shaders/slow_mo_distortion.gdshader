// Slow-motion time distortion post-process. Task 44 of Epic 20.
// Adds a blue tint, soft chromatic aberration, and edge vignette when active.
// Apply to a full-screen ColorRect overlay.

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(0.55, 0.75, 1.00, 1.0);
uniform float chromatic_amount : hint_range(0.0, 0.02) = 0.005;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 r = texture(screen_texture, uv + vec2(chromatic_amount, 0.0) * intensity).rgb;
	vec3 g = texture(screen_texture, uv).rgb;
	vec3 b = texture(screen_texture, uv - vec2(chromatic_amount, 0.0) * intensity).rgb;
	vec3 col = vec3(r.r, g.g, b.b);

	col = mix(col, col * tint.rgb, intensity);

	// Vignette
	vec2 c = uv - vec2(0.5);
	float v = smoothstep(0.4, 0.85, length(c));
	col = mix(col, col * (1.0 - vignette_strength), v * intensity);

	COLOR = vec4(col, 1.0);
}
