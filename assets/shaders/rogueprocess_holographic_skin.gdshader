// rogueprocess_holographic_skin.gdshader
//
// The "always-on hologram" variant skin for the RogueProcess (Epic 06 task
// 13). Distinct from holographic_damage_flash.gdshader (which is a brief
// hit reaction lerp) — this one drops the entire body into a permanent
// hologram look used by:
//
//   - Phantom variant (post-launch — phase variant, half-corporeal)
//   - Defeated/captured cutscene state (the unit appears as a hologram
//     transmission of itself)
//   - Sentinel boss intro flicker phase before he fully materializes
//
// Reads the same baked normal/AO maps as the body shader so the silhouette
// stays accurate, but replaces the PBR shading with:
//   - Fully unshaded color = base hologram tint
//   - Animated horizontal scanlines
//   - UV-space wireframe grid (cyan)
//   - Fresnel rim brighter at glancing angles
//   - Vertical sweep band (the "transmission scan" line that travels up the
//     body once per cycle)
//   - Interrupt flicker that occasionally drops alpha to 0 for 1-2 frames
//     (driven by hash noise on TIME) — sells the "unstable signal"

shader_type spatial;
render_mode unshaded, cull_back, blend_add, depth_draw_opaque;

uniform sampler2D normal_tex : hint_normal;
uniform sampler2D ao_tex : hint_default_white;

uniform vec3 hologram_color : source_color = vec3(0.0, 0.85, 0.95);
uniform vec3 rim_color : source_color = vec3(0.55, 0.95, 1.0);
uniform float base_intensity : hint_range(0.0, 8.0) = 1.6;
uniform float rim_strength : hint_range(0.0, 6.0) = 3.0;
uniform float rim_power : hint_range(0.5, 8.0) = 3.0;

// Scanlines
uniform float scanline_freq : hint_range(10.0, 400.0) = 180.0;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.45;
uniform float scanline_speed : hint_range(0.0, 8.0) = 1.4;

// UV grid
uniform float grid_freq : hint_range(4.0, 80.0) = 24.0;
uniform float grid_strength : hint_range(0.0, 2.0) = 0.7;
uniform float grid_line_width : hint_range(0.001, 0.10) = 0.02;

// Sweep
uniform float sweep_period_s : hint_range(0.5, 12.0) = 3.5;
uniform float sweep_strength : hint_range(0.0, 4.0) = 1.5;
uniform float sweep_band_width : hint_range(0.02, 0.5) = 0.12;

// Flicker (signal interrupt)
uniform float flicker_chance : hint_range(0.0, 1.0) = 0.04;
uniform float flicker_speed : hint_range(0.5, 30.0) = 12.0;

// Output alpha (for fade-in/out cutscenes)
uniform float global_alpha : hint_range(0.0, 1.0) = 1.0;

float hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

void fragment() {
	vec3 nrm = texture(normal_tex, UV).rgb * 2.0 - 1.0;
	float ao = texture(ao_tex, UV).r;

	// Fresnel rim using VIEW direction (camera-space normal)
	float ndotv = max(0.0, dot(normalize(NORMAL), normalize(VIEW)));
	float fresnel = pow(1.0 - ndotv, rim_power);

	// Base color = hologram tint, brighter at edges
	vec3 col = hologram_color * base_intensity;
	col += rim_color * fresnel * rim_strength;

	// Scanlines: SCREEN_UV-based so they don't scale with the model
	float scan = sin(SCREEN_UV.y * scanline_freq + TIME * scanline_speed);
	scan = (scan * 0.5 + 0.5);
	col *= mix(1.0, scan, scanline_strength);

	// UV grid: thin lines on a square lattice
	vec2 grid_uv = fract(UV * grid_freq);
	float gx = step(1.0 - grid_line_width, grid_uv.x) + step(grid_uv.x, grid_line_width);
	float gy = step(1.0 - grid_line_width, grid_uv.y) + step(grid_uv.y, grid_line_width);
	float grid = clamp(gx + gy, 0.0, 1.0);
	col += hologram_color * grid * grid_strength;

	// Vertical sweep band — uses world Y of fragment (so it travels up the
	// body cleanly even with bone deformation)
	float sweep_y = fract(TIME / sweep_period_s);
	float band = 1.0 - clamp(abs(UV.y - sweep_y) / sweep_band_width, 0.0, 1.0);
	col += hologram_color * pow(band, 2.0) * sweep_strength;

	// AO darkens slightly so cavities still read in the hologram
	col *= 0.6 + 0.4 * ao;

	// Flicker: hash by quantized time
	float t_flicker = floor(TIME * flicker_speed);
	float flicker_sample = hash11(t_flicker);
	float flicker_active = step(1.0 - flicker_chance, flicker_sample);
	float flicker_factor = mix(1.0, 0.0, flicker_active);

	ALBEDO = col;
	ALPHA = global_alpha * flicker_factor;
}
