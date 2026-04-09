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

// === Subsurface inner glow (Epic 05 task 11) ===
// Drives Godot's SSS_STRENGTH and SSS_TRANSMITTANCE_COLOR so the body
// glows softly from inside as if there's an internal light source. The
// glow color is independent of the surface tint so the leak's interior
// can read as a different hue (default warmer green) than the outer skin.
uniform float sss_strength : hint_range(0.0, 1.0) = 0.45;
uniform vec3 sss_color : source_color = vec3(0.40, 1.0, 0.55);
uniform float sss_brightness : hint_range(0.0, 4.0) = 1.4;

void fragment() {
	// Compute view-space refraction offset from the surface normal.
	// Surfaces facing the camera get small offsets; angled surfaces get
	// larger offsets so the refraction is most visible at the silhouette.
	vec3 view_normal = (VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec2 refract_uv = SCREEN_UV + view_normal.xy * refraction_strength;

	// Sample the background through the gel
	vec3 refracted = textureLod(screen_texture, refract_uv, 0.0).rgb;

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
