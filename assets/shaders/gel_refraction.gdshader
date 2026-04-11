// Reflective + refractive gel shader for the MemoryLeak (Epic 05 task 30).
//
// The leak's outer skin is semi-translucent gel — light should bend
// through it (refraction) AND the curved surface should pick up faint
// reflections of the environment at glancing angles (Fresnel reflection).
//
// Implementation:
// - Sample SCREEN_TEXTURE at UVs offset by the surface normal to fake
//   refraction without per-pixel raytracing
// - Composite with the variant tint color so the leak still reads as
//   "green/blue/amber" while showing the refracted background through it
// - Apply a Fresnel edge highlight that brightens at glancing angles —
//   this is what gives the surface its "wet" look
// - Optional internal data overlay sampled from a scrolling texture and
//   composited inside the body. (Pass &"" to internal_data_texture if
//   not used.)
//
// Apply to: the MemoryLeak's body mesh as material override. The shader
// requires depth_prepass_alpha so it works correctly with translucent
// surfaces in Forward+ renderer.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_prepass_alpha, cull_back, specular_schlick_ggx;

// === Refraction tunables ===
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float refraction_strength : hint_range(0.0, 0.20) = 0.04;
uniform float ior : hint_range(1.0, 2.0) = 1.35;

// === Tint + transparency ===
uniform vec4 tint_color : source_color = vec4(0.20, 0.85, 0.45, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.55;
uniform float gel_alpha : hint_range(0.0, 1.0) = 0.65;

// === Fresnel reflection edge ===
uniform float fresnel_power : hint_range(0.5, 8.0) = 3.0;
uniform float fresnel_intensity : hint_range(0.0, 4.0) = 1.6;
uniform vec3 rim_color : source_color = vec3(0.85, 1.0, 0.95);

// === Internal data overlay ===
uniform sampler2D internal_data_texture : hint_default_white, repeat_enable;
uniform float internal_data_strength : hint_range(0.0, 1.0) = 0.40;
uniform vec2 internal_data_scroll = vec2(0.05, 0.18);
uniform float internal_data_scale : hint_range(0.5, 8.0) = 2.5;
uniform vec3 internal_data_color : source_color = vec3(0.85, 1.0, 0.95);

// === PBR ===
uniform float metallic : hint_range(0.0, 1.0) = 0.05;
uniform float roughness : hint_range(0.0, 1.0) = 0.10;
uniform float specular : hint_range(0.0, 1.0) = 0.55;

// === Quality level (Epic 05 task 33) ===
// Mobile-spec hardware can't afford SCREEN_TEXTURE refraction sampling
// or per-vertex displacement loops. Drop quality_level to disable the
// most expensive features:
//   2 = full quality (default — desktop)
//   1 = skip refraction (use solid tint instead of SCREEN_TEXTURE sample)
//   0 = also skip vertex wobble + hit ripple (animation jitter only,
//       no per-vertex computation in vertex())
// The branch checks are uniform-driven so the GPU shader compiler can
// dead-code-eliminate the unused paths per material instance.
uniform int quality_level : hint_range(0, 2) = 2;

// === Subsurface inner glow (Epic 05 task 11) ===
// Drives Godot's SSS_STRENGTH and SSS_TRANSMITTANCE_COLOR so the body
// glows softly from inside as if there's an internal light source. The
// glow color is independent of the surface tint so the leak's interior
// can read as a different hue (default warmer green) than the outer skin.
uniform float sss_strength : hint_range(0.0, 1.0) = 0.45;
uniform vec3 sss_color : source_color = vec3(0.40, 1.0, 0.55);
uniform float sss_brightness : hint_range(0.0, 4.0) = 1.4;

// === Vertex jelly wobble (Epic 05 task 12) ===
// Continuous high-frequency vertex displacement that makes the gel
// surface jiggle constantly even when the body is at rest. The
// references doc calls this "macro slow + micro jiggle" — the body
// itself moves slowly via animation, but the surface skin oscillates
// at a faster rate, sold by this vertex wobble.
//
// Phase coordinate (Epic 05 task 46 polish): the phase is computed
// from UV coordinates (which are continuous within UV islands by
// definition) PLUS a small contribution from rest VERTEX position.
// This avoids the visible wobble seams that the previous world_pos
// version produced at bone envelope boundaries — vertices at the
// same UV coordinate get the same phase regardless of which bone
// they're weighted to.
uniform float wobble_amplitude : hint_range(0.0, 0.10) = 0.012;
uniform float wobble_frequency : hint_range(0.5, 16.0) = 6.0;
uniform float wobble_spatial_scale : hint_range(0.5, 16.0) = 4.0;
uniform float wobble_seam_dampen : hint_range(0.0, 1.0) = 0.4;

// === Reactive ripples on hit (Epic 05 task 13) ===
// When the body is hit, gameplay code sets hit_origin_local (a point
// in object space where the impact happened) and starts a hit_age_s
// timer. The shader expands a circular ripple from that origin: a
// brief outward bulge that travels across the surface, peaks, and
// fades over hit_ripple_lifetime_s. Multiple hits stack since each
// only lives until the timer exceeds the lifetime.
uniform vec3 hit_origin_local = vec3(0.0, 0.0, 0.0);
uniform float hit_age_s : hint_range(0.0, 4.0) = 999.0;  // 999 = no active hit
uniform float hit_ripple_lifetime_s : hint_range(0.1, 4.0) = 0.6;
uniform float hit_ripple_speed_m_s : hint_range(0.5, 8.0) = 3.0;
uniform float hit_ripple_amplitude : hint_range(0.0, 0.30) = 0.10;
uniform float hit_ripple_width_m : hint_range(0.05, 1.0) = 0.25;

void vertex() {
	// Quality 0 = skip per-vertex computation entirely
	if (quality_level <= 0) {
		return;
	}

	// Vertex wobble — displaces each vertex along its normal by a sin
	// wave. Phase computed from UV coordinates (continuous within UV
	// islands by design) + small rest VERTEX contribution for variety.
	// This is the seam-polished version from Epic 05 task 46 — the
	// previous world_pos version produced visible wobble seams at bone
	// envelope boundaries.
	float phase = UV.x * wobble_spatial_scale * 6.28
				+ UV.y * wobble_spatial_scale * 6.28 * 0.7
				+ VERTEX.z * 0.5
				+ TIME * wobble_frequency;
	// Cross-island seam dampening: vertices near UV island borders
	// (UV.x or UV.y near 0 or 1) get reduced amplitude so any
	// discontinuities at island edges are less visible
	float seam_factor = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	seam_factor = clamp(seam_factor * 8.0, 0.0, 1.0);  // sharp ramp into 0..1
	float seam_amplitude = mix(wobble_amplitude * (1.0 - wobble_seam_dampen), wobble_amplitude, seam_factor);
	float displacement = sin(phase) * seam_amplitude;
	VERTEX += NORMAL * displacement;

	// Hit ripple — when hit_age_s is within the ripple lifetime, expand
	// a circular bulge from hit_origin_local outward at hit_ripple_speed.
	// Vertices within hit_ripple_width_m of the current ripple radius
	// get a brief outward push along their normal.
	if (hit_age_s < hit_ripple_lifetime_s) {
		float ripple_radius = hit_age_s * hit_ripple_speed_m_s;
		float dist_from_hit = distance(VERTEX, hit_origin_local);
		float dist_from_ripple = abs(dist_from_hit - ripple_radius);
		if (dist_from_ripple < hit_ripple_width_m) {
			// Falloff: 1.0 at the ripple peak, 0 at the edge of the band
			float ripple_strength = 1.0 - (dist_from_ripple / hit_ripple_width_m);
			// Lifetime fade: amplitude scales down as the ripple ages
			float lifetime_fade = 1.0 - (hit_age_s / hit_ripple_lifetime_s);
			VERTEX += NORMAL * hit_ripple_amplitude * ripple_strength * lifetime_fade;
		}
	}
}

void fragment() {
	// Compute view-space refraction offset from the surface normal.
	// Surfaces facing the camera get small offsets; angled surfaces get
	// larger offsets so the refraction is most visible at the silhouette.
	vec3 view_normal = (VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec2 refract_uv = SCREEN_UV + view_normal.xy * refraction_strength;

	// Quality 1+ samples SCREEN_TEXTURE for refraction; quality 0 uses
	// solid tint (mobile fallback — no expensive screen texture sample)
	vec3 refracted;
	if (quality_level >= 1) {
		refracted = textureLod(screen_texture, refract_uv, 0.0).rgb;
	} else {
		refracted = tint_color.rgb * 0.6;  // dark fallback color
	}

	// Tint the refracted background by the gel's variant color
	vec3 tinted = mix(refracted, refracted * tint_color.rgb, tint_strength);

	// Internal data overlay — animated scroll + multiplicative composite
	// inside the body. Sample fades toward edges so the data only shows
	// in the body's interior, not on the rim.
	vec2 data_uv = UV * internal_data_scale + TIME * internal_data_scroll;
	float data_sample = texture(internal_data_texture, data_uv).r;
	float interior_mask = clamp(dot(NORMAL, VIEW), 0.0, 1.0);  // 1 at center, 0 at rim
	vec3 with_data = tinted + internal_data_color * data_sample * internal_data_strength * interior_mask;

	// Fresnel rim brightening — Schlick approximation
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	vec3 rim_add = rim_color * fres * fresnel_intensity;

	ALBEDO = with_data + rim_add;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;

	// Alpha is full at the rim (so the silhouette is clean) and lower
	// in the interior (so the refraction shows through). This is the
	// inverse of how most translucent materials work and is what makes
	// the gel feel like a held drop rather than a glass shell.
	ALPHA = mix(gel_alpha, 1.0, fres);

	// Faint emission tied to the rim so the leak gently glows at its
	// silhouette regardless of scene lighting
	EMISSION = rim_color * fres * 0.25;

	// Subsurface scatter — the body glows from inside as if there's an
	// internal light source. SSS_STRENGTH drives Godot's built-in
	// subsurface scatter pass; SSS_TRANSMITTANCE_COLOR tints the
	// scattered light passing through thin areas of the body.
	SSS_STRENGTH = sss_strength;
	SSS_TRANSMITTANCE_COLOR = vec4(sss_color * sss_brightness, 1.0);
}
