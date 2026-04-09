// Dissolve shader for enemy deaths and respawns.
// Tasks 13-15 of Epic 20: dissolve + edge emissive + noise mask variants.
// Drive `dissolve` from 0.0 (fully visible) to 1.0 (fully gone) via animation.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D noise_texture : hint_default_white, repeat_enable;

uniform float dissolve : hint_range(0.0, 1.1) = 0.0;
uniform float edge_width : hint_range(0.0, 0.3) = 0.04;
uniform vec4 edge_color : source_color = vec4(0.20, 0.95, 0.85, 1.0);
uniform float edge_emission_strength : hint_range(0.0, 10.0) = 4.0;
uniform float noise_scale : hint_range(0.5, 8.0) = 1.5;
uniform int noise_variant : hint_range(0, 2) = 0;  // 0=organic, 1=hex grid, 2=scanlines
uniform float metallic : hint_range(0.0, 1.0) = 0.3;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;

float hex_pattern(vec2 uv) {
	vec2 r = vec2(1.0, sqrt(3.0));
	vec2 h = r * 0.5;
	vec2 a = mod(uv, r) - h;
	vec2 b = mod(uv - h, r) - h;
	vec2 closer = dot(a, a) < dot(b, b) ? a : b;
	return 0.5 - length(closer);
}

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb * base_color.rgb;

	// Sample noise based on variant
	float noise = 0.0;
	if (noise_variant == 0) {
		noise = texture(noise_texture, UV * noise_scale).r;
	} else if (noise_variant == 1) {
		noise = hex_pattern(UV * noise_scale * 8.0);
	} else {
		noise = sin(UV.y * noise_scale * 20.0) * 0.5 + 0.5;
	}

	// Cutoff based on dissolve threshold
	float cutoff = dissolve;
	if (noise < cutoff - edge_width) {
		discard;
	}

	// Edge band: emissive glow
	float edge_factor = 1.0 - smoothstep(cutoff - edge_width, cutoff, noise);

	ALBEDO = mix(base, edge_color.rgb, edge_factor);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	EMISSION = edge_color.rgb * edge_factor * edge_emission_strength;
}
