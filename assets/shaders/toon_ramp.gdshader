// Cell-shading toon ramp shader. Task 37 of Epic 20.
// Quantized lighting with a 1D ramp texture. Use as an alternative material
// for stylized characters when needed (Sea of Stars-leaning aesthetic).

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform sampler2D ramp_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 light_color : source_color = vec4(1.0, 0.95, 0.85, 1.0);
uniform vec3 light_direction = vec3(0.3, 1.0, 0.5);
uniform float ambient_amount : hint_range(0.0, 1.0) = 0.35;
uniform float rim_strength : hint_range(0.0, 4.0) = 1.0;
uniform float rim_falloff : hint_range(0.5, 8.0) = 3.0;
uniform vec4 rim_color : source_color = vec4(1.0, 0.95, 0.85, 1.0);

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb * base_color.rgb;

	// Lambert -> ramp lookup
	vec3 light_dir_view = (VIEW_MATRIX * vec4(normalize(light_direction), 0.0)).xyz;
	float ndotl = clamp(dot(NORMAL, light_dir_view), 0.0, 1.0);
	float ramp = texture(ramp_texture, vec2(ndotl, 0.5)).r;

	vec3 lit = base * (light_color.rgb * ramp + vec3(ambient_amount));

	// Rim light
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_falloff);
	lit += rim_color.rgb * rim * rim_strength;

	ALBEDO = lit;
}
