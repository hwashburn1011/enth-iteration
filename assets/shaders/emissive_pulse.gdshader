// Emissive pulse shader. Task 33 of Epic 20.
// Drives a sin-wave pulse on the emission strength of any material. Used for
// circuit traces, charging weapons, ability cooldown indicators.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform sampler2D emission_mask  : hint_default_black;
uniform vec4 base_color : source_color = vec4(0.20, 0.25, 0.30, 1.0);
uniform vec4 pulse_color : source_color = vec4(0.20, 0.95, 0.85, 1.0);

uniform float pulse_speed : hint_range(0.0, 16.0) = 2.0;
uniform float pulse_min : hint_range(0.0, 10.0) = 0.5;
uniform float pulse_max : hint_range(0.0, 20.0) = 4.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.6;
uniform float roughness : hint_range(0.0, 1.0) = 0.30;

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb * base_color.rgb;
	float mask = texture(emission_mask, UV).r;

	float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5);
	float strength = mix(pulse_min, pulse_max, pulse);

	ALBEDO = base;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	EMISSION = pulse_color.rgb * mask * strength;
}
