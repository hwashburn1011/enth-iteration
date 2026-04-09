// Snow accumulation shader. Task 26 of Epic 20.
// Drives white snow on the upward-facing surfaces of any mesh based on the
// world-space normal Y component. Apply as the main material to terrain or
// props in cold biomes.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 snow_color : source_color = vec4(0.95, 0.97, 1.00, 1.0);

uniform float snow_amount : hint_range(0.0, 1.0) = 0.5;
uniform float snow_blend_softness : hint_range(0.01, 0.5) = 0.10;
uniform float snow_threshold : hint_range(0.0, 1.0) = 0.4;
uniform float snow_roughness : hint_range(0.0, 1.0) = 0.85;
uniform float snow_glitter : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D noise_texture : hint_default_white;

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb * base_color.rgb;

	// Reconstruct world normal from view-space normal
	vec3 world_n = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float upness = clamp(world_n.y, 0.0, 1.0);

	// Snow factor: more snow on horizontal surfaces, scaled by snow_amount
	float snow_factor = smoothstep(snow_threshold - snow_blend_softness, snow_threshold, upness * snow_amount);

	// Sparkle: random bright spots in the snow
	float glitter = step(0.97, texture(noise_texture, UV * 10.0 + TIME * 0.05).r) * snow_glitter;

	vec3 final = mix(base, snow_color.rgb + vec3(glitter), snow_factor);
	ALBEDO = final;
	ROUGHNESS = mix(0.5, snow_roughness, snow_factor);
	METALLIC = 0.0;
}
