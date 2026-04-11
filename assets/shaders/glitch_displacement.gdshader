// Digital corruption / glitch shader. Tasks 7-9 of Epic 20 in one file.
// Vertex displacement bands + chromatic aberration + horizontal color shift bands.
// Apply to objects that are corrupted, glitching out, or in error states.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float glitch_speed     : hint_range(0.0, 20.0) = 6.0;
uniform float band_count       : hint_range(1.0, 64.0) = 16.0;
uniform float chromatic_offset : hint_range(0.0, 0.05) = 0.012;
uniform float displacement_amount : hint_range(0.0, 0.5) = 0.03;
uniform vec3 shift_color_a : source_color = vec3(0.0, 0.95, 0.95);
uniform vec3 shift_color_b : source_color = vec3(0.95, 0.05, 0.55);

float hash(float n) { return fract(sin(n) * 43758.5453); }

void vertex() {
	// Horizontal displacement bands that snap-glitch
	float band = floor(VERTEX.y * band_count + TIME * 0.5);
	float jitter = hash(band + floor(TIME * glitch_speed));
	float kick = step(0.85, jitter) * (jitter * 2.0 - 1.7);
	VERTEX.x += kick * displacement_amount * glitch_intensity;
}

void fragment() {
	// Chromatic aberration: sample the texture three times with offset UVs
	vec2 uv = UV;
	float band = floor(uv.y * band_count + TIME * 0.5);
	float band_jitter = hash(band + floor(TIME * glitch_speed));
	float local_kick = step(0.92, band_jitter) * 0.04 * glitch_intensity;
	uv.x += local_kick;

	float r = texture(albedo_texture, uv + vec2(chromatic_offset, 0.0)).r;
	float g = texture(albedo_texture, uv).g;
	float b = texture(albedo_texture, uv - vec2(chromatic_offset, 0.0)).b;
	vec3 col = vec3(r, g, b) * base_color.rgb;

	// Color shift bands
	float shift_mask = step(0.97, band_jitter);
	col = mix(col, mix(shift_color_a, shift_color_b, sin(TIME * 8.0) * 0.5 + 0.5), shift_mask * 0.6);

	ALBEDO = col;
	EMISSION = col * shift_mask * 1.5;
}
