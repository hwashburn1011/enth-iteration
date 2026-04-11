// compiler_displacement.gdshader
//
// Vertex-displacement extension shader for the Compiler boss key
// surfaces (Epic 07 task 13). Drives the chest core panel + shoulder
// armor + base ring with heightmap-driven mesh deformation so those
// "hero" surfaces have visible 3D detail beyond what the normal map
// alone provides — critical for the trailer hero shots.
//
// Used by:
//   - Compiler boss chest core mesh (the "face" of the boss at z=1.95)
//   - The 4 shoulder ball joints (UR/UL/LR/LL)
//   - The lower base ring (where the tethers attach)
//
// Combines with compiler_phase_transition.gdshader by sampling the same
// baked maps PLUS a dedicated heightmap (compiler_boss_p{1,2,3}_height.png)
// that drives vertex displacement along the surface normal.
//
// Phase progression:
//   P1 — subtle displacement (clean panels, slight raised LED bezels)
//   P2 — heavier displacement (cracks bulge outward + chunks displaced)
//   P3 — extreme displacement (cavity tear visible, code rivulets carve
//        runnels into the surface)

shader_type spatial;
render_mode cull_back, specular_schlick_ggx;

// === BAKED MAPS ===
uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform sampler2D normal_tex : hint_normal;
uniform sampler2D ao_tex : hint_default_white;
uniform sampler2D height_tex : hint_default_black;
uniform sampler2D crack_mask_tex : hint_default_black;
uniform sampler2D code_rivulet_tex : hint_default_black;

// === PHASE CONTROL ===
uniform float phase_value : hint_range(0.0, 2.0) = 0.0;

// === DISPLACEMENT TUNING ===
uniform float displacement_strength_p1 : hint_range(0.0, 0.30) = 0.025;
uniform float displacement_strength_p2 : hint_range(0.0, 0.50) = 0.060;
uniform float displacement_strength_p3 : hint_range(0.0, 1.00) = 0.140;
uniform float displacement_bias : hint_range(-0.5, 0.5) = -0.05;

// === CRACK BULGE (P2/P3) ===
// Cracks displace OUTWARD when present, simulating the surface bulging
// before failure
uniform float crack_bulge_amount : hint_range(0.0, 0.40) = 0.085;
uniform float crack_bulge_pulse_speed : hint_range(0.0, 8.0) = 2.0;

// === CODE RIVULET DISPLACEMENT (P3 only) ===
// The code carves runnels INTO the surface — negative displacement
uniform float rivulet_carve_depth : hint_range(0.0, 0.30) = 0.045;

// === MATERIAL (passed through to fragment) ===
uniform vec3 base_tint_p1 : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 base_tint_p3 : source_color = vec3(0.45, 0.20, 0.25);
uniform float metallic_base : hint_range(0.0, 1.0) = 1.0;
uniform float roughness_base : hint_range(0.0, 1.0) = 0.30;

void vertex() {
	// Sample heightmap at the vertex's UV (using a coarse derivative-free
	// approach since vertex shaders can't access mipmaps)
	float h = textureLod(height_tex, UV, 0.0).r;
	float crack_h = textureLod(crack_mask_tex, UV, 0.0).r;
	float code_h = textureLod(code_rivulet_tex, UV, 0.0).r;

	// Phase blend factors
	float p1_blend = 1.0 - clamp(phase_value, 0.0, 1.0);
	float p2_blend = 1.0 - abs(clamp(phase_value, 0.0, 2.0) - 1.0);
	float p3_blend = clamp(phase_value - 1.0, 0.0, 1.0);

	// Per-phase displacement strength
	float strength = displacement_strength_p1 * p1_blend
	               + displacement_strength_p2 * p2_blend
	               + displacement_strength_p3 * p3_blend;

	// Base height displacement along normal
	float disp = (h + displacement_bias) * strength;

	// Crack bulge: where cracks are present in P2/P3, push surface OUT
	// Pulses in time so the bulge "breathes" before failure
	float crack_pulse = sin(TIME * crack_bulge_pulse_speed) * 0.5 + 0.5;
	float crack_disp = crack_h * crack_bulge_amount * (p2_blend + p3_blend) * (0.7 + 0.3 * crack_pulse);
	disp += crack_disp;

	// Code rivulet carve: P3 only, scrolling V offset so the runnels move
	float code_v = UV.y - TIME * 0.10;
	float code_sample = textureLod(code_rivulet_tex, vec2(UV.x * 4.0, code_v), 0.0).r;
	disp -= code_sample * rivulet_carve_depth * p3_blend;

	// Apply displacement along the vertex normal
	VERTEX += NORMAL * disp;
}

void fragment() {
	vec4 base = texture(albedo_tex, UV);
	vec3 nrm = texture(normal_tex, UV).rgb;
	float ao = texture(ao_tex, UV).r;

	NORMAL_MAP = nrm;

	float p3_blend = clamp(phase_value - 1.0, 0.0, 1.0);
	vec3 tint = mix(base_tint_p1, base_tint_p3, p3_blend);

	ALBEDO = base.rgb * tint;
	METALLIC = metallic_base;
	ROUGHNESS = roughness_base + p3_blend * 0.20;
	AO = ao;
}
