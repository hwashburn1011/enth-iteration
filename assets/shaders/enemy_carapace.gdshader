// Carapace shader for the GlitchBug (Epic 04 task 11) and reusable on
// any hard-shelled enemy. PBR base + iridescent oil-slick Fresnel
// rim highlight that color-cycles based on view angle.
//
// Designed to consume the baked texture set from Epic 04 task 9-10:
//   - albedo (dark base color + crack lines)
//   - normal (high-poly bevel + plate seam detail)
//   - AO (concave seam shading)
//   - cavity (sharper concave detection for the iridescent crack
//     boost — cracks should be MORE iridescent than flat plates)
//
// The iridescent layer is what makes a real beetle's chitin shell
// catch the light differently from any angle — it's the difference
// between "plastic insect" and "alive insect."

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, specular_schlick_ggx;

// === PBR base inputs ===
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D normal_texture : hint_normal;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform sampler2D ao_texture : hint_default_white;
uniform float ao_strength : hint_range(0.0, 1.0) = 0.85;
uniform sampler2D cavity_texture : hint_default_white;

uniform float metallic : hint_range(0.0, 1.0) = 0.65;
uniform float roughness : hint_range(0.0, 1.0) = 0.25;

// === Iridescence ===
// The iridescent layer cycles through 3 hues based on view angle
// (Fresnel). Subtle by default — should read as "wet sheen" not
// "rainbow puddle."
uniform vec3 iridescence_color_a : source_color = vec3(0.20, 0.10, 0.55);  // deep purple
uniform vec3 iridescence_color_b : source_color = vec3(0.10, 0.40, 0.55);  // teal
uniform vec3 iridescence_color_c : source_color = vec3(0.55, 0.20, 0.30);  // dusty rose
uniform float iridescence_strength : hint_range(0.0, 2.0) = 0.40;
uniform float iridescence_power : hint_range(0.5, 8.0) = 3.0;
uniform float iridescence_cavity_boost : hint_range(0.0, 4.0) = 1.6;

// === Crack glow ===
// Boost emission on the cyan crack lines from the albedo bake. The
// albedo texture already has them painted in but the runtime shader
// can pulse them based on TIME for the "alive" feeling.
uniform vec3 crack_color : source_color = vec3(0.0, 0.95, 0.95);
uniform float crack_pulse_speed : hint_range(0.0, 8.0) = 1.5;
uniform float crack_emission : hint_range(0.0, 6.0) = 2.5;

// === Emissive crawling glitch pattern (Epic 04 task 12) ===
// A separate emission overlay that uses a noise texture sampled at
// TIME-scrolled UVs. The noise is masked to faint streaks along the
// carapace surface and slowly drifts so the player sees the glitch
// pattern crawling continuously. Not tied to the crack mask — this
// is a separate, broader visual layer that hits the WHOLE surface
// occasionally rather than just the seams.
uniform sampler2D crawl_noise_texture : hint_default_white, repeat_enable;
uniform float crawl_speed : hint_range(0.0, 4.0) = 0.18;
uniform vec2 crawl_direction = vec2(0.10, 0.65);
uniform float crawl_scale : hint_range(0.5, 16.0) = 4.0;
uniform float crawl_threshold : hint_range(0.0, 1.0) = 0.78;
uniform float crawl_emission_strength : hint_range(0.0, 8.0) = 3.5;
uniform vec3 crawl_color : source_color = vec3(0.95, 0.05, 0.55);

void fragment() {
	vec4 base_sample = texture(albedo_texture, UV);
	vec3 albedo_col = base_sample.rgb * base_color.rgb;

	// Cavity sample for the iridescent boost in cracks
	float cavity = texture(cavity_texture, UV).r;
	float ao = mix(1.0, texture(ao_texture, UV).r, ao_strength);

	// Normal sample
	vec3 nrm = texture(normal_texture, UV).rgb * 2.0 - 1.0;
	nrm.xy *= normal_strength;

	// Fresnel for the iridescent edge
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), iridescence_power);

	// Iridescence color cycling: 3-color triangle blend driven by Fresnel
	// 0.0-0.5 of fres → blend a→b
	// 0.5-1.0 of fres → blend b→c
	vec3 irid_col;
	if (fres < 0.5) {
		irid_col = mix(iridescence_color_a, iridescence_color_b, fres * 2.0);
	} else {
		irid_col = mix(iridescence_color_b, iridescence_color_c, (fres - 0.5) * 2.0);
	}

	// Iridescent contribution scales with Fresnel and gets boosted in cavity areas
	float irid_amount = fres * iridescence_strength * (1.0 + cavity * iridescence_cavity_boost);

	// Final albedo: base + iridescent additive
	vec3 final_albedo = albedo_col + irid_col * irid_amount;

	// Detect the cyan crack lines from the albedo by checking if the
	// blue+green channels exceed the red — crack pixels are cyan-tinted
	// while base pixels are purple-tinted. This isolates the crack mask
	// without needing a separate texture
	float cyan_detect = clamp((base_sample.g + base_sample.b - base_sample.r * 2.0) * 2.0, 0.0, 1.0);
	float pulse = 0.5 + 0.5 * sin(TIME * crack_pulse_speed);
	vec3 emission = crack_color * cyan_detect * crack_emission * (0.7 + pulse * 0.3);

	// Crawling glitch pattern overlay — sample noise at TIME-scrolled UVs
	// and threshold to bright streaks. The streaks crawl across the
	// surface continuously, sold by the offset that grows with TIME.
	vec2 crawl_uv = UV * crawl_scale + TIME * crawl_speed * crawl_direction;
	float crawl_sample = texture(crawl_noise_texture, crawl_uv).r;
	float crawl_mask = smoothstep(crawl_threshold, 1.0, crawl_sample);
	emission += crawl_color * crawl_mask * crawl_emission_strength;

	ALBEDO = final_albedo;
	NORMAL_MAP = nrm * 0.5 + 0.5;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	AO = ao;
	EMISSION = emission;
}
