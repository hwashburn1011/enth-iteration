// Vertex wind shader for vegetation. Task 28 of Epic 20.
// Apply to leaf cards / grass / bushes. Adds gentle sway tied to global wind
// direction + a faster ripple to the upper portion of the mesh (driven by
// vertex Y) so trunks barely move while leaves dance.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform vec3 wind_direction = vec3(1.0, 0.0, 0.3);
uniform float wind_strength : hint_range(0.0, 0.5) = 0.05;
uniform float wind_speed    : hint_range(0.0, 4.0) = 1.5;
uniform float ripple_freq   : hint_range(0.0, 16.0) = 6.0;
uniform float weight_curve  : hint_range(0.5, 4.0) = 2.0;
uniform float alpha_cutoff  : hint_range(0.0, 1.0) = 0.45;

void vertex() {
	float weight = pow(clamp(VERTEX.y, 0.0, 2.0), weight_curve);
	float base_sway = sin(TIME * wind_speed + VERTEX.x * 0.6 + VERTEX.z * 0.4);
	float ripple = sin(TIME * wind_speed * 2.5 + VERTEX.x * ripple_freq) * 0.3;
	vec3 sway_offset = normalize(wind_direction) * (base_sway + ripple) * wind_strength * weight;
	VERTEX += sway_offset;
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	if (tex.a < alpha_cutoff) {
		discard;
	}
	ALBEDO = tex.rgb * base_color.rgb;
	ALPHA = tex.a;
	ROUGHNESS = 0.85;
	METALLIC = 0.0;
}
