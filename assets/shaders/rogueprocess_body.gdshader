// rogueprocess_body.gdshader
//
// The main RogueProcess body shader. Drives the cold-metal PBR look on top
// of the baked normal/AO/curvature/cavity passes, the cyan→combat alert
// emission strobe (sampled from the emission mask + multiplied by the
// variant's combat_alert_color uniform), and the vertex floating motion that
// makes the unit gently bob in place even when no animation is playing
// (Epic 06 task 12 — vertex shader).
//
// The bobbing motion is in OBJECT space and is gentle (under 1 cm) so it
// stacks cleanly with the AnimationPlayer hover_idle clip without fighting
// it. It exists so a paused/spawned RogueProcess never goes fully static —
// the species is always alive.
//
// Used by:
//   - All RogueProcess body sections (lower_torso, chest, neck, shoulders,
//     head, face_plate, sensors, antenna, arms, claws, exhaust housing)
//   - VariantBodyUpgrade routes per-variant idle_scan_color and
//     combat_alert_color into idle_emission_color and combat_emission_color
//
// Strobe:
//   alert_phase = 0  → idle scan (cyan-default, slow pulse)
//   alert_phase = 1  → combat (alert color, fast pulse)
//   blends linearly so a state machine can lerp the value over 0.2s

shader_type spatial;
render_mode cull_back, specular_schlick_ggx, blend_mix;

// === BAKED MAPS ===
uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform sampler2D normal_tex : hint_normal;
uniform sampler2D ao_tex : hint_default_white;
uniform sampler2D cavity_tex : hint_default_white;
uniform sampler2D emission_tex : hint_default_black;

// === MATERIAL TUNING ===
uniform float metallic_base : hint_range(0.0, 1.0) = 1.0;
uniform float roughness_base : hint_range(0.0, 1.0) = 0.32;
uniform float normal_strength : hint_range(0.0, 3.0) = 1.0;
uniform float ao_strength : hint_range(0.0, 1.0) = 0.85;
uniform float cavity_darken_strength : hint_range(0.0, 1.0) = 0.5;

// === EMISSION ===
// idle_emission_color = the cyan default (or scout yellow, etc.)
// combat_emission_color = the red/crimson/magenta combat tell
uniform vec3 idle_emission_color : source_color = vec3(0.0, 0.95, 0.95);
uniform vec3 combat_emission_color : source_color = vec3(1.0, 0.10, 0.05);
uniform float emission_intensity : hint_range(0.0, 20.0) = 5.0;
// alert_phase: 0 = idle (cyan), 1 = combat (red). Lerp via Tween/AI state.
uniform float alert_phase : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed_idle : hint_range(0.1, 8.0) = 1.2;
uniform float pulse_speed_combat : hint_range(0.1, 12.0) = 4.5;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.45;

// === VERTEX BOB ===
// Subtle bob so a static RogueProcess still reads as "alive"
uniform float bob_amplitude_m : hint_range(0.0, 0.05) = 0.008;
uniform float bob_speed : hint_range(0.0, 6.0) = 1.6;
// Random phase per instance so a pack doesn't bob in lockstep
uniform float bob_phase_offset : hint_range(0.0, 6.28318) = 0.0;
// Lateral sway is even smaller — prevents the bob looking purely vertical
uniform float sway_amplitude_m : hint_range(0.0, 0.03) = 0.003;

void vertex() {
	float t = TIME * bob_speed + bob_phase_offset;
	// Vertical bob (sin)
	float bob = sin(t) * bob_amplitude_m;
	// Lateral sway (cos at half freq) — figure-8 feel
	float sway = cos(t * 0.5) * sway_amplitude_m;
	VERTEX.y += bob;
	VERTEX.x += sway;
}

void fragment() {
	vec4 base = texture(albedo_tex, UV);
	vec3 nrm = texture(normal_tex, UV).rgb;
	float ao_sample = texture(ao_tex, UV).r;
	float cavity_sample = texture(cavity_tex, UV).r;
	float em_mask = texture(emission_tex, UV).r;

	// Apply normal map with strength
	vec3 normal_local = nrm * 2.0 - 1.0;
	normal_local.xy *= normal_strength;
	NORMAL_MAP = normal_local * 0.5 + 0.5;

	// Cavity darkens the albedo in deep crevices
	float cav_factor = mix(1.0, cavity_sample, cavity_darken_strength);

	// AO standard
	float ao_factor = mix(1.0, ao_sample, ao_strength);

	ALBEDO = base.rgb * cav_factor * ao_factor;
	METALLIC = metallic_base;
	ROUGHNESS = roughness_base;
	AO = ao_sample;

	// === EMISSION STROBE ===
	// Idle pulse (slow, sinusoidal, 60-100% intensity)
	float idle_pulse = (sin(TIME * pulse_speed_idle) * 0.5 + 0.5) * pulse_amount + (1.0 - pulse_amount);
	// Combat pulse (fast, sharper)
	float combat_pulse = (sin(TIME * pulse_speed_combat) * 0.5 + 0.5) * pulse_amount + (1.0 - pulse_amount);

	// Lerp colors AND pulse rates
	vec3 alert_color = mix(idle_emission_color, combat_emission_color, alert_phase);
	float pulse = mix(idle_pulse, combat_pulse, alert_phase);

	EMISSION = alert_color * em_mask * emission_intensity * pulse;
}
