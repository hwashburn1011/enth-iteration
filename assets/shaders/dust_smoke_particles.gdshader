// Combined dust + smoke particle shader. Tasks 40-41 of Epic 20.
// Soft alpha billboards driven by a noise texture for organic edges. Set the
// uniforms to make it dust (small, light) or smoke (large, dark, persistent).

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform sampler2D noise_texture : hint_default_white;
uniform vec4 base_color : source_color = vec4(0.65, 0.55, 0.40, 1.0);
uniform float softness : hint_range(0.5, 4.0) = 1.5;
uniform float scroll_speed : hint_range(0.0, 2.0) = 0.2;
uniform float opacity : hint_range(0.0, 1.0) = 0.6;
uniform float emission_strength : hint_range(0.0, 4.0) = 0.0;

void fragment() {
	vec2 uv = UV;
	float n = texture(noise_texture, uv + vec2(TIME * scroll_speed, 0.0)).r;

	// Round particle falloff
	vec2 c = uv - vec2(0.5);
	float r = length(c) * 2.0;
	float circle = pow(1.0 - clamp(r, 0.0, 1.0), softness);

	// Combine
	float a = circle * n * opacity;

	ALBEDO = base_color.rgb;
	EMISSION = base_color.rgb * emission_strength * a;
	ALPHA = a;
}
