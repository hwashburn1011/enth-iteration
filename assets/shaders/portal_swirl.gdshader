// Portal swirl shader. Task 18 of Epic 20.
// Compaction portals + dungeon entrances + iteration transitions.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec4 portal_color_inner : source_color = vec4(0.30, 0.95, 0.85, 1.0);
uniform vec4 portal_color_outer : source_color = vec4(0.10, 0.30, 0.95, 1.0);
uniform float swirl_strength : hint_range(0.0, 16.0) = 6.0;
uniform float swirl_speed    : hint_range(0.0, 8.0) = 1.5;
uniform float band_count     : hint_range(2.0, 24.0) = 8.0;
uniform float falloff_power  : hint_range(0.5, 8.0) = 2.0;

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float r = length(centered);
	float theta = atan(centered.y, centered.x);
	theta += swirl_strength * (1.0 - r) - TIME * swirl_speed;

	float bands = sin(theta * band_count) * 0.5 + 0.5;
	float radial_falloff = pow(1.0 - clamp(r * 2.0, 0.0, 1.0), falloff_power);

	vec3 col = mix(portal_color_outer.rgb, portal_color_inner.rgb, bands);
	col *= radial_falloff;

	ALBEDO = vec3(0.0);
	EMISSION = col * 3.0;
	ALPHA = radial_falloff;
}
