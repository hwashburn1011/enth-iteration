// Hair card shader. Task 31 of Epic 20.
// Layered alpha-cutout strips with anisotropic highlight along the strand
// direction. Apply to hair card meshes (planes textured with hair strips).

shader_type spatial;
render_mode blend_mix, depth_draw_alpha_prepass, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D hair_texture : source_color, hint_default_white;
uniform sampler2D normal_texture : hint_normal;
uniform vec4 hair_color : source_color = vec4(0.30, 0.18, 0.08, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.85, 0.65, 0.30, 1.0);
uniform float alpha_cutoff : hint_range(0.0, 1.0) = 0.4;
uniform float anisotropy : hint_range(0.0, 1.0) = 0.85;
uniform float roughness_along : hint_range(0.0, 1.0) = 0.20;
uniform float roughness_across : hint_range(0.0, 1.0) = 0.85;
uniform float ao_root : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec4 tex = texture(hair_texture, UV);
	if (tex.a < alpha_cutoff) {
		discard;
	}
	NORMAL_MAP = texture(normal_texture, UV).rgb;

	// Root darkening — vertices near UV.y = 0 are at the root
	float ao = mix(ao_root, 1.0, UV.y);

	ALBEDO = tex.rgb * hair_color.rgb * ao;
	ALPHA = tex.a;

	// Anisotropic-style roughness — flat across the strand, rough along it
	float u_falloff = abs(UV.x - 0.5) * 2.0;
	ROUGHNESS = mix(roughness_along, roughness_across, u_falloff);
	METALLIC = 0.0;
	SPECULAR = anisotropy;
}
