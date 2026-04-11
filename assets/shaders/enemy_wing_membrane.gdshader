// Wing membrane shader for the GlitchBug (Epic 04 task 13).
//
// The wing membranes are normally hidden under the closed carapace
// elytra and only become visible during the AGGRO REAR-UP pose (per
// epic-04-glitchbug-references.md silhouette pose 3 + the variant
// bible knob 7). When exposed, they should look like animated
// stained-glass windows holding live code — translucent with backlit
// glow when the player is on the opposite side of the wing.
//
// Implementation uses Godot's BACKLIGHT input to fake subsurface
// scattering. BACKLIGHT is added to the lit color when light passes
// THROUGH the surface (backface lit by light source), so it produces
// the "stained glass" effect cheaply without true SSS cost.
//
// The membrane also carries an animated UV-scrolling code overlay
// (similar to the gel_refraction shader for the MemoryLeak but
// composited differently) so the wing surface shows drifting source
// code behind the iridescence.
//
// Apply to: the wing membrane mesh (built later as a separate mesh
// parented to the wing case bone) using this shader as material
// override.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_prepass_alpha, cull_disabled, specular_schlick_ggx;

// === Membrane base ===
uniform vec4 membrane_color : source_color = vec4(0.75, 0.45, 0.95, 0.85);
uniform float membrane_alpha : hint_range(0.0, 1.0) = 0.55;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.18;
uniform float specular : hint_range(0.0, 1.0) = 0.65;

// === Backlight transmission (fake SSS) ===
uniform vec3 backlight_tint : source_color = vec3(0.85, 0.40, 1.0);
uniform float backlight_strength : hint_range(0.0, 4.0) = 1.6;

// === Iridescent rim (stained glass edge) ===
uniform vec3 rim_color : source_color = vec3(0.95, 0.85, 1.0);
uniform float rim_power : hint_range(0.5, 8.0) = 2.5;
uniform float rim_strength : hint_range(0.0, 4.0) = 1.4;

// === Internal code overlay ===
uniform sampler2D code_texture : hint_default_white, repeat_enable;
uniform float code_scale : hint_range(0.5, 16.0) = 4.0;
uniform vec2 code_scroll = vec2(0.06, 0.20);
uniform vec3 code_color : source_color = vec3(0.0, 0.95, 0.95);
uniform float code_strength : hint_range(0.0, 4.0) = 1.2;

// === Reveal mask ===
// Lets gameplay code (the rear-up pose state) tween the wing from fully
// hidden (reveal=0.0) to fully visible (reveal=1.0). At 0 the wing is
// invisible — alpha forced to 0 — so the wing mesh can stay parented
// to the rig with the shader handling visibility.
uniform float reveal : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	// Base membrane color, modulated by reveal
	vec3 base = membrane_color.rgb;

	// Animated code overlay — drifts upward and slightly across the wing
	vec2 code_uv = UV * code_scale + TIME * code_scroll;
	float code_sample = texture(code_texture, code_uv).r;
	vec3 code_layer = code_color * code_sample * code_strength;

	// Fresnel rim — bright at glancing angles
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	vec3 rim = rim_color * fres * rim_strength;

	// Composite
	ALBEDO = base + code_layer * 0.3;  // code shows through faintly in albedo
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;

	// BACKLIGHT is the fake-SSS contribution — light passing through
	// the surface from the back. Tinted by membrane color so the
	// transmitted light feels like it picked up the membrane's hue.
	BACKLIGHT = backlight_tint * backlight_strength * (membrane_color.rgb * 0.5 + 0.5);

	// Emission carries the code overlay strongly + the rim glow.
	// This way the code is visible even in dark dungeon lighting where
	// the backlight wouldn't fire
	EMISSION = code_layer + rim;

	// Alpha modulated by reveal so gameplay can fade the wing in/out
	ALPHA = membrane_alpha * reveal;
}
