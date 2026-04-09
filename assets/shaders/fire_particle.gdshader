// Fire particle shader. Task 21 of Epic 20.
// Apply as a ParticleProcessMaterial via custom material on the GPUParticles3D.
// Single quad billboards drawn additively, color graded by particle lifetime.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

uniform sampler2D noise_texture : hint_default_white;
uniform vec4 hot_color : source_color = vec4(1.00, 0.95, 0.45, 1.0);
uniform vec4 mid_color : source_color = vec4(1.00, 0.45, 0.05, 1.0);
uniform vec4 cool_color: source_color = vec4(0.40, 0.05, 0.00, 1.0);
uniform float intensity : hint_range(0.0, 5.0) = 2.5;
uniform float fade_power : hint_range(0.5, 4.0) = 2.0;

void fragment() {
	// Sample noise once
	vec2 uv = UV;
	float n = texture(noise_texture, uv).r;

	// Radial falloff (round particle)
	vec2 c = uv - vec2(0.5);
	float r = length(c) * 2.0;
	float circle = pow(1.0 - clamp(r, 0.0, 1.0), fade_power);

	// Color gradient hot -> mid -> cool based on noise
	vec3 col;
	if (n > 0.66) {
		col = mix(mid_color.rgb, hot_color.rgb, (n - 0.66) / 0.34);
	} else if (n > 0.33) {
		col = mix(cool_color.rgb, mid_color.rgb, (n - 0.33) / 0.33);
	} else {
		col = cool_color.rgb * (n / 0.33);
	}

	ALBEDO = vec3(0.0);
	EMISSION = col * intensity * circle;
	ALPHA = circle;
}
