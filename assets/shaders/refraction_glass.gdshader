// Refraction shader for glass / crystal / chest core windows. Task 36 of Epic 20.
// Real refraction via screen texture sampling — not just transparency.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D normal_texture : hint_normal;

uniform vec4 tint : source_color = vec4(0.85, 0.95, 1.00, 1.0);
uniform float ior_strength : hint_range(0.0, 0.2) = 0.04;
uniform float roughness : hint_range(0.0, 1.0) = 0.05;
uniform float fresnel_power : hint_range(0.5, 8.0) = 3.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float thickness_tint_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	NORMAL_MAP = texture(normal_texture, UV).rgb;

	// Use the surface normal in view space to bend the screen UV (cheap refraction)
	vec2 distortion = NORMAL.xy * ior_strength;
	vec2 refracted_uv = SCREEN_UV + distortion;
	vec3 refracted = texture(screen_texture, refracted_uv).rgb;

	// Tint by the glass color
	vec3 tinted = mix(refracted, refracted * tint.rgb, thickness_tint_strength);

	// Fresnel for edge brightness
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);

	ALBEDO = tinted;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = 0.7 + fres * 0.3;
	EMISSION = tint.rgb * fres * 0.3;
}
