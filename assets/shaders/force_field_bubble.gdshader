// Force field / energy shield bubble. Tasks 16-17 of Epic 20 in one shader.
// Hex pattern + fresnel rim + impact ripples. Uniform `is_shield` flips
// the visual between defensive shield (blue, calmer) and force field
// (cyan-white, more aggressive).

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec4 field_color    : source_color = vec4(0.30, 0.65, 1.00, 1.0);
uniform vec4 hex_color      : source_color = vec4(0.65, 0.95, 1.00, 1.0);
uniform vec4 impact_color   : source_color = vec4(1.00, 1.00, 1.00, 1.0);

uniform float fresnel_power      : hint_range(0.5, 8.0) = 2.0;
uniform float hex_scale          : hint_range(1.0, 60.0) = 18.0;
uniform float hex_brightness     : hint_range(0.0, 3.0) = 1.0;
uniform float pulse_speed        : hint_range(0.0, 8.0) = 2.5;
uniform float impact_intensity   : hint_range(0.0, 2.0) = 0.0; // animate from script
uniform vec3  impact_origin_local: source_color = vec3(0.0);
uniform float impact_radius      : hint_range(0.0, 5.0) = 1.5;
uniform bool  is_shield = true;

float hex_grid(vec2 uv) {
	vec2 r = vec2(1.0, sqrt(3.0));
	vec2 h = r * 0.5;
	vec2 a = mod(uv, r) - h;
	vec2 b = mod(uv - h, r) - h;
	vec2 closer = dot(a, a) < dot(b, b) ? a : b;
	float d = length(closer);
	return smoothstep(0.40, 0.50, d);
}

void fragment() {
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	float pulse = sin(TIME * pulse_speed) * 0.10 + 0.90;

	// Hex pattern over the surface
	vec2 hex_uv = UV * hex_scale + vec2(TIME * 0.05, 0.0);
	float hex = hex_grid(hex_uv) * hex_brightness;

	// Impact ripple — distance from a local-space hit point
	float dist_to_impact = length(VERTEX - impact_origin_local);
	float ripple = smoothstep(impact_radius, impact_radius - 0.4, dist_to_impact) * impact_intensity;

	vec3 col = field_color.rgb * pulse + hex_color.rgb * hex + impact_color.rgb * ripple;
	col *= (is_shield ? 0.85 : 1.15);

	ALBEDO = vec3(0.0);
	EMISSION = col;
	ALPHA = clamp(fres + hex * 0.4 + ripple, 0.05, 1.0);
}
