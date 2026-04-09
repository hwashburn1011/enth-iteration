// Energy aura shader. Task 42 of Epic 20.
// Soft glowing sphere/ellipsoid that surrounds player or boss during charge,
// OVERCLOCKED, or transformation states.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec4 aura_inner : source_color = vec4(0.30, 0.95, 0.85, 1.0);
uniform vec4 aura_outer : source_color = vec4(0.10, 0.45, 0.95, 1.0);
uniform float falloff : hint_range(0.5, 8.0) = 2.5;
uniform float pulse_speed : hint_range(0.0, 8.0) = 2.5;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.20;
uniform float intensity : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), falloff);
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;

	vec3 col = mix(aura_outer.rgb, aura_inner.rgb, fres);
	col *= pulse * intensity;

	ALBEDO = vec3(0.0);
	EMISSION = col;
	ALPHA = fres;
}
