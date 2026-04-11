// ai_sage_robe.gdshader
//
// Custom shader for the AI Sage's robe + body (Epic 09 task 37). Drives
// the digital-cloth visual identity:
//   - PBR base sampling the baked albedo + normal + AO + cavity
//   - Scrolling code rivulet overlay (the "structured data" cloth tell)
//   - Cyan rim Fresnel for the otherworldly look
//   - Dialogue intensity uniform that brightens emission + rim during
//     key dialogue moments (driven by AISageNPC component task 37)
//   - Subtle vertex hover bob baked into the shader so even a static
//     pose has the "I am not entirely here" floating motion

shader_type spatial;
render_mode cull_back, specular_schlick_ggx;

// === BAKED MAPS ===
uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform sampler2D normal_tex : hint_normal;
uniform sampler2D ao_tex : hint_default_white;
uniform sampler2D cavity_tex : hint_default_white;

// === MATERIAL TUNING ===
uniform float metallic_base : hint_range(0.0, 1.0) = 0.0;
uniform float roughness_base : hint_range(0.0, 1.0) = 0.65;
uniform float normal_strength : hint_range(0.0, 3.0) = 1.0;

// === RIM (the otherworldly cyan glow on edges) ===
uniform vec3 rim_color : source_color = vec3(0.0, 0.85, 1.0);
uniform float rim_power : hint_range(0.5, 8.0) = 3.0;
uniform float rim_strength : hint_range(0.0, 6.0) = 1.6;

// === DIALOGUE INTENSITY (0..1, driven by AISageNPC) ===
// Brightens rim + emission during key dialogue moments
uniform float dialogue_intensity : hint_range(0.0, 1.0) = 0.0;

// === SCROLLING CODE OVERLAY ===
uniform float code_scroll_speed : hint_range(0.0, 4.0) = 0.25;
uniform float code_strength : hint_range(0.0, 2.0) = 0.55;

// === VERTEX HOVER BOB (subtle, the "not fully here" feel) ===
uniform float vertex_bob_amplitude_m : hint_range(0.0, 0.05) = 0.006;
uniform float vertex_bob_speed : hint_range(0.0, 4.0) = 0.6;

void vertex() {
	// Subtle hover bob — only on Y, only on the upper body so the feet stay floaty
	float bob_t = TIME * vertex_bob_speed;
	float bob_amount = sin(bob_t) * vertex_bob_amplitude_m;
	// Apply more bob to higher verts (so robes drape gently)
	float vert_factor = clamp(VERTEX.y * 0.6, 0.0, 1.0);
	VERTEX.y += bob_amount * vert_factor;
}

void fragment() {
	vec4 base = texture(albedo_tex, UV);
	vec3 nrm = texture(normal_tex, UV).rgb;
	float ao = texture(ao_tex, UV).r;
	float cav = texture(cavity_tex, UV).r;

	// Apply normal map
	vec3 normal_local = nrm * 2.0 - 1.0;
	normal_local.xy *= normal_strength;
	NORMAL_MAP = normal_local * 0.5 + 0.5;

	// Albedo with cavity tightening
	ALBEDO = base.rgb * (0.7 + 0.3 * cav);
	METALLIC = metallic_base;
	ROUGHNESS = roughness_base;
	AO = ao;

	// Fresnel rim — brighter at glancing angles
	float ndotv = max(0.0, dot(normalize(NORMAL), normalize(VIEW)));
	float fresnel = pow(1.0 - ndotv, rim_power);

	// Scrolling code overlay — sample albedo at offset UV to find the
	// pre-baked code grid pixels and brighten them
	vec2 code_uv = vec2(UV.x, UV.y - TIME * code_scroll_speed * 0.1);
	float code_sample = texture(albedo_tex, code_uv).g;  // green channel has the code
	float code_mask = smoothstep(0.45, 0.65, code_sample);

	// EMISSION
	vec3 emission = rim_color * fresnel * rim_strength;
	emission += rim_color * code_mask * code_strength;

	// Dialogue intensity multiplies emission (1.0 → 2.5x at full)
	emission *= 1.0 + dialogue_intensity * 1.5;

	EMISSION = emission;
}
