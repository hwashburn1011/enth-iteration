// Per-outfit fresnel rim light contribution. Adds a colored edge highlight
// that reads at gameplay distance, helping the player identify equipped gear
// against busy backgrounds.
//
// Apply this as a secondary material (mix into Principled via shader graph)
// or use it as the main material for outfit pieces that need edge readability.

shader_type spatial;

uniform vec4 albedo : source_color = vec4(0.6, 0.7, 0.8, 1.0);
uniform float metallic : hint_range(0.0, 1.0) = 0.3;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 rim_color : source_color = vec4(0.0, 0.95, 0.85, 1.0);
uniform float rim_strength : hint_range(0.0, 5.0) = 1.5;
uniform float rim_falloff : hint_range(0.5, 8.0) = 2.5;
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform sampler2D normal_texture : hint_normal;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec4 tex_col = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb * tex_col.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;

	// Sample tangent-space normal
	vec3 n_tex = texture(normal_texture, UV).rgb * 2.0 - 1.0;
	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), n_tex * 0.5 + 0.5, normal_strength);

	// Fresnel rim light (additive emission)
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_falloff);
	EMISSION = rim_color.rgb * rim * rim_strength;
}
