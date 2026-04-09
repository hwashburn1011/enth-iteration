// Rain wetness shader. Task 27 of Epic 20.
// Drops the roughness of any surface and adds a subtle dark tint to simulate
// a wet appearance during rain weather. Combined with puddle decals.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform sampler2D normal_texture : hint_normal;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float wetness : hint_range(0.0, 1.0) = 0.0;
uniform float dark_tint_amount : hint_range(0.0, 0.5) = 0.20;
uniform float wet_roughness : hint_range(0.0, 0.4) = 0.10;
uniform float dry_roughness : hint_range(0.0, 1.0) = 0.65;
uniform float metallic_boost : hint_range(0.0, 0.5) = 0.10;
uniform float drip_speed : hint_range(0.0, 4.0) = 1.0;
uniform sampler2D noise_texture : hint_default_white;

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb * base_color.rgb;
	NORMAL_MAP = texture(normal_texture, UV).rgb;

	// Reconstruct world normal upness for puddle pooling on flat surfaces
	vec3 world_n = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float upness = clamp(world_n.y, 0.0, 1.0);
	float pool = upness * wetness;

	// Animated drip noise — only active when wetness > 0
	vec2 drip_uv = UV + vec2(0.0, TIME * drip_speed);
	float drip_n = texture(noise_texture, drip_uv * 4.0).r;
	float drip_mask = step(0.7, drip_n) * wetness;

	// Darken the base color slightly when wet (water absorbs light)
	vec3 wet_col = base * (1.0 - dark_tint_amount * wetness);

	ALBEDO = wet_col;
	ROUGHNESS = mix(dry_roughness, wet_roughness, pool);
	METALLIC = metallic_boost * pool;
}
