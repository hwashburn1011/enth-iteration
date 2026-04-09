// compiler_phase_transition.gdshader
//
// Drives the visual evolution of the Compiler boss across its 3 phases.
// Replaces the per-phase static material with a single shader that
// interpolates between Phase 1 → Phase 2 → Phase 3 over time, driven by
// the phase_value uniform set by the boss controller.
//
// phase_value:
//   0.0  → Phase 1: clean polished gunmetal + cyan LEDs (server rack)
//   1.0  → Phase 2: cracked, magenta data streams, RGB chromatic split
//   2.0  → Phase 3: corrupted dark, crimson cracks, code rivulets
//
// Values between integers smoothly blend so the phase TRANSITION
// animation can lerp phase_value from 0→1 over 4 seconds while the
// boss is invulnerable.
//
// Used by:
//   - All Compiler boss body meshes (lower_base, mid_torso, shoulders,
//     arms — anything that should evolve across phases)
//   - The chest core uses a separate compiler_heart_core.gdshader
//   - Energy arms use the dedicated compiler_energy_arm shader (P3 only)
//
// The shader samples the same 4 baked PBR maps (albedo + normal + AO +
// curvature) but applies different processing per phase:
//   - P1: PBR straight, no overlay
//   - P2: PBR + magenta crack mask + RGB channel split + glitch noise
//   - P3: PBR darkened to ~30% + crimson crack mask thicker + scrolling
//         code rivulet overlay + heart cavity rim glow

shader_type spatial;
render_mode cull_back, specular_schlick_ggx;

// === BAKED MAPS ===
uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform sampler2D normal_tex : hint_normal;
uniform sampler2D ao_tex : hint_default_white;
uniform sampler2D crack_mask_tex : hint_default_black;
uniform sampler2D code_rivulet_tex : hint_default_black;

// === PHASE CONTROL ===
// Set by the boss controller. 0..2 with smooth lerp during transitions.
uniform float phase_value : hint_range(0.0, 2.0) = 0.0;

// === MATERIAL TUNING ===
uniform float metallic_p1 : hint_range(0.0, 1.0) = 1.0;
uniform float metallic_p3 : hint_range(0.0, 1.0) = 0.85;
uniform float roughness_p1 : hint_range(0.0, 1.0) = 0.30;
uniform float roughness_p3 : hint_range(0.0, 1.0) = 0.55;
uniform float normal_strength : hint_range(0.0, 3.0) = 1.0;

// === PHASE 1: Clean polished body ===
uniform vec3 led_color_p1 : source_color = vec3(0.0, 0.95, 0.95);
uniform float led_strength_p1 : hint_range(0.0, 20.0) = 5.0;
uniform float led_pulse_speed : hint_range(0.0, 8.0) = 1.5;

// === PHASE 2: Glitching, magenta cracks ===
uniform vec3 crack_color_p2 : source_color = vec3(1.0, 0.10, 0.85);
uniform float crack_strength_p2 : hint_range(0.0, 20.0) = 6.0;
uniform float p2_chromatic_aberration : hint_range(0.0, 0.05) = 0.012;
uniform float p2_glitch_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float p2_glitch_speed : hint_range(0.0, 12.0) = 5.5;

// === PHASE 3: Corrupted, crimson, code rivulets ===
uniform vec3 corruption_tint_p3 : source_color = vec3(0.40, 0.20, 0.30);
uniform vec3 crack_color_p3 : source_color = vec3(1.0, 0.10, 0.05);
uniform float crack_strength_p3 : hint_range(0.0, 20.0) = 8.0;
uniform float code_rivulet_speed : hint_range(0.0, 4.0) = 0.8;
uniform float code_rivulet_strength : hint_range(0.0, 4.0) = 1.6;

// === LOW HP RAGE ===
// 0..1, animated by HealthComponent → set as boss approaches death
uniform float low_hp_rage : hint_range(0.0, 1.0) = 0.0;

float hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	// Phase blend factors
	// p1_blend = 1 at 0, 0 at 1+
	// p2_blend = 0 at 0, 1 at 1, 0 at 2
	// p3_blend = 0 at <2, 1 at 2
	float p1_blend = 1.0 - clamp(phase_value, 0.0, 1.0);
	float p2_blend = 1.0 - abs(clamp(phase_value, 0.0, 2.0) - 1.0);
	float p3_blend = clamp(phase_value - 1.0, 0.0, 1.0);

	// === Sample base maps ===
	vec2 uv = UV;

	// Phase 2 chromatic aberration: sample R and B channels at offset UVs
	float ca = p2_chromatic_aberration * p2_blend;
	vec4 base_r = texture(albedo_tex, uv + vec2(ca, 0.0));
	vec4 base_g = texture(albedo_tex, uv);
	vec4 base_b = texture(albedo_tex, uv - vec2(ca, 0.0));
	vec3 base_color = vec3(base_r.r, base_g.g, base_b.b);

	float ao = texture(ao_tex, uv).r;
	float crack_sample = texture(crack_mask_tex, uv).r;
	vec3 nrm = texture(normal_tex, uv).rgb;

	// Apply normal map
	vec3 normal_local = nrm * 2.0 - 1.0;
	normal_local.xy *= normal_strength;
	NORMAL_MAP = normal_local * 0.5 + 0.5;

	// === Phase 1: clean polished surface ===
	vec3 albedo_p1 = base_color;
	// LED strips: detect cyan in the base albedo (LED accents are pre-baked)
	float led_mask = step(0.5, base_color.b) * step(0.5, base_color.g) * step(base_color.r, 0.3);
	float led_pulse = sin(TIME * led_pulse_speed) * 0.3 + 0.7;

	// === Phase 2: glitching crack overlay ===
	// Tint base color slightly toward magenta in the cracks
	vec3 albedo_p2 = base_color;
	// Glitch jitter: occasional small UV displacement
	float glitch_t = floor(TIME * p2_glitch_speed);
	float glitch_active = step(0.85, hash11(glitch_t));
	float glitch_offset_y = (hash11(glitch_t + 0.5) - 0.5) * 0.04;
	if (glitch_active > 0.5 && p2_blend > 0.5) {
		vec3 glitched = texture(albedo_tex, uv + vec2(0.0, glitch_offset_y)).rgb;
		albedo_p2 = mix(albedo_p2, glitched, p2_glitch_intensity);
	}

	// === Phase 3: corruption darkens base + adds code rivulets ===
	vec3 albedo_p3 = base_color * corruption_tint_p3 * 1.2;
	// Code rivulets — sample the code stream texture with scrolling V
	float code_v = uv.y - TIME * code_rivulet_speed * 0.15;
	float code_sample = texture(code_rivulet_tex, vec2(uv.x * 4.0, code_v)).r;
	// Code visible only on certain panel zones (where AO is in mid range)
	float code_zone = smoothstep(0.4, 0.7, ao);
	albedo_p3 += vec3(0.0, 0.95, 1.0) * code_sample * code_zone * code_rivulet_strength * p3_blend;

	// === Combine albedos ===
	vec3 final_albedo = albedo_p1 * p1_blend + albedo_p2 * p2_blend + albedo_p3 * p3_blend;

	// === Material properties ===
	METALLIC = mix(metallic_p1, metallic_p3, p3_blend);
	ROUGHNESS = mix(roughness_p1, roughness_p3, p3_blend);
	AO = ao;

	// === EMISSION ===
	// LEDs in P1
	vec3 emission_p1 = led_color_p1 * led_mask * led_strength_p1 * led_pulse;
	// Magenta cracks in P2
	float crack_pulse = sin(TIME * 4.0) * 0.2 + 0.8;
	vec3 emission_p2 = crack_color_p2 * crack_sample * crack_strength_p2 * crack_pulse;
	// Crimson cracks in P3 (thicker mask)
	float thick_crack = smoothstep(0.3, 0.6, crack_sample);
	vec3 emission_p3 = crack_color_p3 * thick_crack * crack_strength_p3;
	// Code rivulet emission
	emission_p3 += vec3(0.0, 0.95, 1.0) * code_sample * code_zone * code_rivulet_strength * 0.6;

	vec3 emission_combined = emission_p1 * p1_blend + emission_p2 * p2_blend + emission_p3 * p3_blend;

	// Low HP rage: boost overall emission
	emission_combined *= 1.0 + low_hp_rage * 1.5;

	EMISSION = emission_combined;
	ALBEDO = final_albedo;
}
