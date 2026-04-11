// Status effect overlay shader: poison + burn + wet + ice freeze.
// Tasks 22-25 of Epic 20 in one parameterized shader. Use the `effect_type`
// uniform to switch between effects without swapping shaders.
//
// effect_type:
//   0 - none
//   1 - poison (green pulse)
//   2 - burn (orange flicker)
//   3 - wet (blue tint + extra reflectivity)
//   4 - ice freeze (white crystalline overlay)

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D noise_texture : hint_default_white;

uniform int effect_type : hint_range(0, 4) = 0;
uniform float effect_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;

const vec3 POISON_COLOR = vec3(0.20, 0.95, 0.30);
const vec3 BURN_COLOR   = vec3(1.00, 0.40, 0.05);
const vec3 WET_COLOR    = vec3(0.40, 0.55, 0.85);
const vec3 ICE_COLOR    = vec3(0.85, 0.95, 1.00);

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb * base_color.rgb;
	vec3 final = base;
	float final_rough = roughness;
	float final_metal = metallic;
	vec3 emission = vec3(0.0);

	if (effect_type == 1) {
		// Poison — sickly pulsing green tint with bubble noise
		float bubble = texture(noise_texture, UV * 4.0 + TIME * 0.3).r;
		float pulse = sin(TIME * 3.0) * 0.5 + 0.5;
		final = mix(base, POISON_COLOR, effect_intensity * 0.6 * (0.5 + bubble * 0.5));
		emission = POISON_COLOR * pulse * effect_intensity * 0.5;
	} else if (effect_type == 2) {
		// Burn — flickering orange overlay with embers
		float ember = texture(noise_texture, UV * 3.0 + TIME).r;
		float flicker = step(0.6, ember) * (sin(TIME * 25.0) * 0.5 + 0.5);
		final = mix(base, BURN_COLOR, effect_intensity * 0.5);
		emission = BURN_COLOR * flicker * effect_intensity * 1.5;
	} else if (effect_type == 3) {
		// Wet — desaturated tint, increased reflectivity
		final = mix(base, base * WET_COLOR, effect_intensity * 0.4);
		final_rough = mix(roughness, 0.05, effect_intensity);
		final_metal = mix(metallic, 0.2, effect_intensity);
	} else if (effect_type == 4) {
		// Ice — white crystalline overlay
		float crystal = texture(noise_texture, UV * 6.0).r;
		float crystal_mask = step(0.6, crystal) * effect_intensity;
		final = mix(base, ICE_COLOR, crystal_mask);
		final_rough = mix(roughness, 0.15, effect_intensity * 0.7);
		emission = ICE_COLOR * crystal_mask * 0.3;
	}

	ALBEDO = final;
	METALLIC = final_metal;
	ROUGHNESS = final_rough;
	EMISSION = emission;
}
