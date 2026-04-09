// Holographic damage flash shader for the RogueProcess (Epic 06 task 29).
//
// On damage, the RogueProcess briefly renders as a "holographic readout"
// of itself — the surface flickers between its normal PBR appearance and
// a wireframe-grid hologram overlay with scanlines, edge highlight, and
// cyan tint. Drives off a hit_pulse uniform 0..1 that gets tweened from
// 1 → 0 over ~0.30s on damage_taken.
//
// Distinct from enemy_hit_glitch.gdshader (which fragments the body via
// vertex displacement — the GlitchBug's organic hit reaction). This one
// is purely surface-shading, no vertex modification — appropriate for
// a rigid machine where "fragmenting" would feel wrong.
//
// Apply to: the RogueProcess body mesh as material override. This is a
// FULL PBR drop-in (consumes albedo/normal/metallic/roughness like the
// carapace shader), so it can be the actual enemy material with the
// damage flash baked into the same pass.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, specular_schlick_ggx;

// === PBR base inputs ===
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(0.30, 0.32, 0.36, 1.0);
uniform sampler2D normal_texture : hint_normal;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.85;
uniform float roughness : hint_range(0.0, 1.0) = 0.30;

// === Damage flash pulse ===
// 0 = clean, 1 = peak hologram. Driven by gameplay code via tween.
uniform float hit_pulse : hint_range(0.0, 1.0) = 0.0;

// === Hologram tint + scanlines ===
uniform vec3 holo_color : source_color = vec3(0.0, 0.95, 1.0);
uniform float scanline_density : hint_range(8.0, 256.0) = 96.0;
uniform float scanline_speed : hint_range(0.0, 16.0) = 6.0;
uniform float scanline_intensity : hint_range(0.0, 4.0) = 1.5;

// === Edge highlight (Fresnel rim) ===
uniform float fresnel_power : hint_range(0.5, 8.0) = 2.5;
uniform float fresnel_intensity : hint_range(0.0, 6.0) = 3.5;

// === Wireframe grid ===
// Pseudo-wireframe via UV-space grid pattern
uniform float grid_density : hint_range(2.0, 64.0) = 16.0;
uniform float grid_thickness : hint_range(0.0, 0.2) = 0.04;

void fragment() {
	vec4 base_sample = texture(albedo_texture, UV) * base_color;
	vec3 nrm = texture(normal_texture, UV).rgb * 2.0 - 1.0;
	nrm.xy *= normal_strength;

	// Fresnel rim — bright at glancing angles
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);

	// === Holographic surface (only computed when hit_pulse > 0) ===
	vec3 final_albedo = base_sample.rgb;
	vec3 emission = vec3(0.0);

	if (hit_pulse > 0.001) {
		// Scanlines: horizontal bright bands scrolling vertically over time
		float scanline = sin(UV.y * scanline_density + TIME * scanline_speed);
		float scanline_mask = step(0.0, scanline) * scanline_intensity;

		// Wireframe grid: bright lines at integer UV multiples
		vec2 grid_uv = fract(UV * grid_density);
		float grid_x = step(grid_uv.x, grid_thickness) + step(1.0 - grid_thickness, grid_uv.x);
		float grid_y = step(grid_uv.y, grid_thickness) + step(1.0 - grid_thickness, grid_uv.y);
		float grid_mask = clamp(grid_x + grid_y, 0.0, 1.0);

		// Holographic albedo: base color washed toward holo color, brightened
		// at scanlines + grid lines + Fresnel edges
		vec3 holo_surface = mix(base_sample.rgb, holo_color, 0.5);
		holo_surface += holo_color * (scanline_mask * 0.4 + grid_mask * 0.6 + fres * 0.5);

		// Lerp from base PBR appearance to hologram driven by hit_pulse
		final_albedo = mix(base_sample.rgb, holo_surface, hit_pulse);

		// Emission spike for the impact frame — pulse^2 so it's brightest
		// at peak and fades fast
		float impact_flash = hit_pulse * hit_pulse;
		emission = holo_color * (
			grid_mask * 4.0 +              // grid lines glow
			scanline_mask * 2.0 +          // scanlines glow
			fres * fresnel_intensity +     // edge rim glow
			impact_flash * 6.0             // base impact flash
		) * hit_pulse;
	}

	ALBEDO = final_albedo;
	NORMAL_MAP = nrm * 0.5 + 0.5;
	METALLIC = mix(metallic, 0.0, hit_pulse);  // hologram is non-metallic
	ROUGHNESS = mix(roughness, 0.0, hit_pulse);  // hologram is glossy
	EMISSION = emission;
}
