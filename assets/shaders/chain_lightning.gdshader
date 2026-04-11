// Chain lightning shader. Task 20 of Epic 20.
// Apply to an elongated quad ribbon between two points. Animates a jagged
// lightning bolt with bright core and flickering glow halo.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 core_color : source_color = vec4(0.95, 0.98, 1.00, 1.0);
uniform vec4 outer_color: source_color = vec4(0.40, 0.65, 1.00, 1.0);
uniform float core_thickness : hint_range(0.0, 0.5) = 0.05;
uniform float outer_thickness : hint_range(0.0, 1.0) = 0.30;
uniform float jaggedness : hint_range(0.0, 1.0) = 0.5;
uniform float flicker_speed : hint_range(0.0, 30.0) = 18.0;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	float along = UV.x;
	float across = UV.y - 0.5;

	// Jaggedness — perturb the centerline based on along position + time
	float zigzag = (hash(vec2(floor(along * 30.0), floor(TIME * 12.0))) - 0.5) * jaggedness * 0.3;
	float dist = abs(across - zigzag);

	float core = 1.0 - smoothstep(0.0, core_thickness, dist);
	float outer = 1.0 - smoothstep(core_thickness, outer_thickness, dist);

	float flicker = mix(0.7, 1.0, hash(vec2(floor(TIME * flicker_speed), 0.0)));

	vec3 col = mix(outer_color.rgb * outer, core_color.rgb, core) * flicker;
	float a = max(core, outer * 0.5);

	ALBEDO = vec3(0.0);
	EMISSION = col * 3.0;
	ALPHA = a;
}
