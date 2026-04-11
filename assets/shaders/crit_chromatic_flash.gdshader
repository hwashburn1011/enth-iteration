// Crit hit chromatic flash post-process. Task 45 of Epic 20.
// Brief one-shot flash on critical hits — drives intensity from script
// (animate from 1.0 to 0 over ~80ms).

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float chromatic_amount : hint_range(0.0, 0.05) = 0.012;
uniform vec4 flash_tint : source_color = vec4(1.00, 0.95, 0.85, 1.0);
uniform float zoom_amount : hint_range(0.0, 0.05) = 0.008;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = uv - vec2(0.5);

	// Brief radial zoom
	uv = vec2(0.5) + center * (1.0 - zoom_amount * intensity);

	vec3 r = texture(screen_texture, uv + center * chromatic_amount * intensity).rgb;
	vec3 g = texture(screen_texture, uv).rgb;
	vec3 b = texture(screen_texture, uv - center * chromatic_amount * intensity).rgb;
	vec3 col = vec3(r.r, g.g, b.b);

	// Add a brief tint flash
	col = mix(col, col + flash_tint.rgb * 0.3, intensity);

	COLOR = vec4(col, 1.0);
}
