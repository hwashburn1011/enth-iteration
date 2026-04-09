// Thruster heat distortion shader for the RogueProcess (Epic 06 task 28).
//
// The RogueProcess hovers above the ground with thruster nozzles where
// its legs would be. The exhaust column rising from the thrusters should
// distort the air behind it like real heat shimmer — anything seen
// through the heat column gets a wavy refraction.
//
// Implementation: applied to a mesh sized like the exhaust plume (a
// cone or cylinder above each thruster). The shader samples
// SCREEN_TEXTURE at UVs offset by an animated noise pattern, then
// outputs that displaced sample with soft alpha falloff at the edges
// of the plume mesh. No actual emissive — the thruster glow itself is
// a separate shader/light. This shader ONLY handles the air-distortion
// refraction effect.
//
// Apply to: cone/cylinder mesh placed at each thruster nozzle, oriented
// upward (+Y in local space) and sized to match the thruster exhaust
// extent. Use this shader as material override.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_prepass_alpha, cull_disabled, unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D distortion_noise : hint_default_white, repeat_enable;

// === Distortion tunables ===
uniform float distortion_strength : hint_range(0.0, 0.10) = 0.025;
uniform float scroll_speed : hint_range(0.0, 8.0) = 1.6;
uniform vec2 scroll_direction = vec2(0.0, 0.8);
uniform float noise_scale : hint_range(0.5, 16.0) = 4.0;

// === Heat tint ===
// Subtle warm color shift on the distorted sample so the heat column
// feels orange-tinted rather than perfectly neutral
uniform vec3 heat_tint : source_color = vec3(1.0, 0.92, 0.78);
uniform float heat_tint_strength : hint_range(0.0, 1.0) = 0.20;

// === Edge falloff ===
// The distortion fades to zero at the edges of the plume mesh so the
// silhouette doesn't have a hard cutoff. Driven by distance from UV
// center.
uniform float edge_falloff_power : hint_range(0.5, 8.0) = 2.5;

void fragment() {
	// Animated noise sample at TIME-scrolled UVs — drives the
	// distortion direction
	vec2 noise_uv = UV * noise_scale + TIME * scroll_speed * scroll_direction;
	float n1 = texture(distortion_noise, noise_uv).r;
	float n2 = texture(distortion_noise, noise_uv + vec2(0.37, 0.13)).r;
	vec2 distortion = vec2(n1 - 0.5, n2 - 0.5) * 2.0;

	// Heat shimmer falls off with vertical distance from the bottom of
	// the plume (nozzle is at UV.y=0, top of plume at UV.y=1)
	float vertical_strength = 1.0 - clamp(UV.y * 0.6, 0.0, 1.0);

	// Sample the screen at the offset UVs
	vec2 screen_uv = SCREEN_UV + distortion * distortion_strength * vertical_strength;
	vec3 distorted = textureLod(screen_texture, screen_uv, 0.0).rgb;

	// Apply the warm heat tint
	vec3 tinted = mix(distorted, distorted * heat_tint, heat_tint_strength);

	// Edge falloff for soft alpha at the silhouette
	float dist_from_center = length(UV - vec2(0.5)) * 2.0;
	float edge_alpha = 1.0 - pow(clamp(dist_from_center, 0.0, 1.0), edge_falloff_power);
	float vertical_alpha = 1.0 - clamp(UV.y, 0.0, 1.0);

	ALBEDO = tinted;
	ALPHA = edge_alpha * vertical_alpha * 0.85;
}
