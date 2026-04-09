// Laser beam shader. Task 19 of Epic 20.
// Apply to a stretched cylinder or quad. Animates a hot core + outer glow
// with subtle scrolling noise to suggest energy flow along the beam.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 core_color  : source_color = vec4(1.00, 1.00, 0.95, 1.0);
uniform vec4 outer_color : source_color = vec4(1.00, 0.30, 0.10, 1.0);
uniform float core_width   : hint_range(0.0, 1.0) = 0.10;
uniform float outer_width  : hint_range(0.0, 1.0) = 0.45;
uniform float scroll_speed : hint_range(-8.0, 8.0) = 4.0;
uniform float intensity    : hint_range(0.0, 5.0) = 2.5;

void fragment() {
	float dist_from_center = abs(UV.y - 0.5) * 2.0;
	float core = 1.0 - smoothstep(0.0, core_width, dist_from_center);
	float outer = 1.0 - smoothstep(core_width, outer_width, dist_from_center);

	float flow = sin((UV.x - TIME * scroll_speed) * 30.0) * 0.5 + 0.5;
	flow = mix(0.7, 1.0, flow);

	vec3 col = mix(outer_color.rgb * outer, core_color.rgb * core, core);
	col *= flow * intensity;

	ALBEDO = vec3(0.0);
	EMISSION = col;
	ALPHA = max(core, outer * 0.7);
}
