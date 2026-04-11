// Subsurface skin shader. Task 32 of Epic 20.
// Approximate SSS via warm wrapped diffuse + edge translucency. Use on
// Globbler skin material variants and warm organic surfaces.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform sampler2D normal_texture : hint_normal;
uniform vec4 base_color : source_color = vec4(0.85, 0.62, 0.55, 1.0);
uniform vec4 sss_color : source_color = vec4(0.95, 0.45, 0.35, 1.0);

uniform float roughness : hint_range(0.0, 1.0) = 0.55;
uniform float specular : hint_range(0.0, 1.0) = 0.40;
uniform float sss_strength : hint_range(0.0, 2.0) = 0.50;
uniform float sss_wrap : hint_range(0.0, 1.0) = 0.25;
uniform float backlight_strength : hint_range(0.0, 4.0) = 1.0;

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb * base_color.rgb;
	NORMAL_MAP = texture(normal_texture, UV).rgb;

	ALBEDO = base;
	ROUGHNESS = roughness;
	METALLIC = 0.0;
	SPECULAR = specular;

	// Wrapped diffuse approximation: emit warm color in shadowed areas to
	// fake subsurface light bleeding
	float wrap = clamp(dot(NORMAL, VIEW) + sss_wrap, 0.0, 1.0);
	float backlight = pow(1.0 - wrap, 3.0);

	EMISSION = sss_color.rgb * sss_strength * backlight * backlight_strength;
}
