// Enemy hit-reaction glitch displacement shader (Epic 04 task 38).
//
// Triggered by a script that drives `hit_pulse` from 1.0 → 0.0 over
// ~0.25s after the enemy takes damage. While the pulse is active the
// enemy briefly fragments — vertices snap outward in horizontal bands
// based on world position, the surface gets a strong chromatic
// aberration ghost, magenta+cyan crack lines crawl over the body, and
// emission spikes for a single visible frame on impact.
//
// Distinct from the Epic 20 generic `glitch_displacement.gdshader`:
//   - Stays clean when hit_pulse == 0 (only fires on damage)
//   - Drives the displacement off pulse magnitude, not raw time
//   - Adds emissive impact flash that fades with the pulse
//   - Carries the GlitchBug's signature cyan/magenta crack hue baked in
//
// Hook from GD code:
//   var mat: ShaderMaterial = mesh.material_override
//   mat.set_shader_parameter("hit_pulse", 1.0)
//   var tw := create_tween()
//   tw.tween_property(mat, "shader_parameter/hit_pulse", 0.0, 0.25)

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, specular_schlick_ggx;

// === Base PBR inputs (so this can be the actual enemy material) ===
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D normal_texture : hint_normal;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.65;
uniform float roughness : hint_range(0.0, 1.0) = 0.25;

// === Hit pulse (the only thing the gameplay code drives) ===
// 0.0 = fully clean. 1.0 = peak hit fragmentation.
uniform float hit_pulse : hint_range(0.0, 1.0) = 0.0;

// === Tunables (set per-enemy, baked at material level) ===
uniform float band_count : hint_range(1.0, 128.0) = 32.0;
uniform float displacement_max : hint_range(0.0, 0.40) = 0.12;
uniform float chromatic_max : hint_range(0.0, 0.10) = 0.025;
uniform vec3 crack_color_a : source_color = vec3(0.0, 0.95, 0.95);  // cyan
uniform vec3 crack_color_b : source_color = vec3(0.95, 0.05, 0.55); // magenta
uniform float impact_flash_intensity : hint_range(0.0, 12.0) = 6.0;
uniform float crack_density : hint_range(0.0, 24.0) = 8.0;

float hash11(float n) { return fract(sin(n) * 43758.5453123); }

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void vertex() {
	// Only displace when hit_pulse > 0 — leave clean otherwise
	if (hit_pulse > 0.001) {
		// Horizontal-band displacement based on local Y, snapped per-band
		// so adjacent vertices in the same band move together (chunky look,
		// not noisy). Bands are picked by floor(VERTEX.y * band_count).
		float band = floor(VERTEX.y * band_count);
		float jitter = hash11(band + TIME * 30.0);

		// Each band gets a kick along its own random direction. The kick
		// magnitude is proportional to hit_pulse so the effect peaks at
		// impact and fades out smoothly with the tween.
		// Strong kick is boosted by the cube of pulse so it snaps in fast.
		float kick_strength = hit_pulse * hit_pulse * hit_pulse;
		float kick_x = (jitter * 2.0 - 1.0) * displacement_max * kick_strength;
		float kick_z = (hash11(band + 7.13) * 2.0 - 1.0) * displacement_max * kick_strength * 0.6;

		VERTEX.x += kick_x;
		VERTEX.z += kick_z;
	}
}

void fragment() {
	// Base sample
	vec2 uv = UV;
	vec4 base_sample = texture(albedo_texture, uv) * base_color;

	if (hit_pulse > 0.001) {
		// Horizontal-band UV jitter for the chromatic ghost
		float band = floor(uv.y * band_count + TIME * 12.0);
		float band_jitter = hash11(band);
		float local_kick = (band_jitter * 2.0 - 1.0) * 0.06 * hit_pulse;
		uv.x += local_kick;

		// 3-tap chromatic split — displaces R/B channels by chromatic_max
		// scaled by hit_pulse so the effect fades to clean at pulse=0
		float ca = chromatic_max * hit_pulse;
		float r = texture(albedo_texture, uv + vec2(ca, 0.0)).r;
		float g = texture(albedo_texture, uv).g;
		float b = texture(albedo_texture, uv - vec2(ca, 0.0)).b;
		base_sample.rgb = vec3(r, g, b) * base_color.rgb;
	}

	// Crack noise: 2D hash sampled at crack_density × UV. Cells with
	// hash > 0.92 become crack lines that take the cyan/magenta color.
	// Crack visibility is tied to hit_pulse so cracks only show on hit.
	vec2 crack_uv = uv * crack_density;
	float crack_hash = hash21(floor(crack_uv));
	float crack_mask = step(0.92, crack_hash) * hit_pulse;
	float crack_phase = hash21(floor(crack_uv) + vec2(13.0, 7.0));
	vec3 crack_col = mix(crack_color_a, crack_color_b, crack_phase);

	// Mix the cracks into albedo at full strength when active
	vec3 final_albedo = mix(base_sample.rgb, crack_col, crack_mask);

	// Impact flash: brief whole-surface emission boost driven by pulse^2
	// (so it spikes at impact frame and fades fast)
	float flash = hit_pulse * hit_pulse * impact_flash_intensity;
	vec3 emission = crack_col * crack_mask * 4.0 + base_sample.rgb * flash * 0.3;

	// Normal sample for proper PBR
	vec3 nrm = texture(normal_texture, UV).rgb * 2.0 - 1.0;
	nrm.xy *= normal_strength;

	ALBEDO = final_albedo;
	NORMAL_MAP = nrm * 0.5 + 0.5;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	EMISSION = emission;
}
