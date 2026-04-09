// Mind control swirl shader. Task 43 of Epic 20.
// Spiraling pattern over a target's body when they're charmed/dominated.
// Apply as a secondary material on top of the base albedo.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec4 swirl_color : source_color = vec4(0.85, 0.20, 0.95, 1.0);
uniform float swirl_speed : hint_range(0.0, 8.0) = 1.5;
uniform float swirl_density : hint_range(1.0, 24.0) = 8.0;
uniform float intensity : hint_range(0.0, 4.0) = 1.5;

void fragment() {
	vec2 c = UV - vec2(0.5);
	float r = length(c) * 2.0;
	float theta = atan(c.y, c.x);

	float band = sin(theta * swirl_density - r * 4.0 + TIME * swirl_speed);
	band = band * 0.5 + 0.5;

	float radial_falloff = 1.0 - smoothstep(0.0, 1.0, r);
	float pattern = band * radial_falloff;

	ALBEDO = vec3(0.0);
	EMISSION = swirl_color.rgb * pattern * intensity;
	ALPHA = pattern;
}
