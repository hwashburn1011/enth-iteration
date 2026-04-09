// Hologram shader: scanlines + fresnel edge glow + flicker.
// Tasks 10-12 of Epic 20 in one file. Apply to UI projections, ghost characters,
// holographic NPCs, dungeon lore terminals.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec4 hologram_color : source_color = vec4(0.20, 0.85, 1.00, 1.0);
uniform float scanline_count : hint_range(10.0, 500.0) = 120.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.6;
uniform float scanline_scroll_speed : hint_range(0.0, 5.0) = 0.5;
uniform float fresnel_power : hint_range(0.5, 8.0) = 2.5;
uniform float fresnel_strength : hint_range(0.0, 5.0) = 2.0;
uniform float flicker_speed : hint_range(0.0, 30.0) = 12.0;
uniform float flicker_amount : hint_range(0.0, 1.0) = 0.15;
uniform float global_alpha : hint_range(0.0, 1.0) = 0.85;

float random(vec2 v) { return fract(sin(dot(v, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	// Scanlines
	float scan = sin((SCREEN_UV.y + TIME * scanline_scroll_speed) * scanline_count * 3.14159);
	scan = scan * 0.5 + 0.5;
	scan = mix(1.0, scan, scanline_intensity);

	// Fresnel edge glow
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	float edge = fres * fresnel_strength;

	// Flicker (random per frame, occasional dropouts)
	float flicker = mix(1.0 - flicker_amount, 1.0, random(vec2(floor(TIME * flicker_speed), 0.0)));

	vec3 col = hologram_color.rgb * scan * flicker;
	float alpha = (edge + 0.3) * global_alpha * flicker;

	ALBEDO = col;
	EMISSION = col * edge * 2.0;
	ALPHA = alpha;
}
