shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Dissolve shader — noise-driven alpha cutoff with edge glow.
// Drive `dissolve_amount` 0..1 to dissolve a mesh. Edge band glows
// in `edge_color` for the trailer-grade death/spawn animation.

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.3) = 0.06;
uniform vec4 edge_color : source_color = vec4(1.0, 0.55, 0.10, 1.0);
uniform vec4 base_color : source_color = vec4(0.85, 0.85, 0.85, 1.0);
uniform float noise_scale : hint_range(0.5, 30.0) = 6.0;

float hash3(vec3 p) {
    p = fract(p * vec3(443.8975, 397.2973, 491.1871));
    p += dot(p.yzx, p.xyz + 19.19);
    return fract((p.x + p.y) * p.z);
}

float value_noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n000 = hash3(i + vec3(0,0,0));
    float n100 = hash3(i + vec3(1,0,0));
    float n010 = hash3(i + vec3(0,1,0));
    float n110 = hash3(i + vec3(1,1,0));
    float n001 = hash3(i + vec3(0,0,1));
    float n101 = hash3(i + vec3(1,0,1));
    float n011 = hash3(i + vec3(0,1,1));
    float n111 = hash3(i + vec3(1,1,1));
    return mix(
        mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
        mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y),
        f.z
    );
}

void fragment() {
    float n = value_noise(VERTEX * noise_scale);
    if (n < dissolve_amount) discard;

    ALBEDO = base_color.rgb;
    ROUGHNESS = 0.6;

    // Edge glow band
    float edge = smoothstep(dissolve_amount, dissolve_amount + edge_width, n);
    vec3 emission = edge_color.rgb * (1.0 - edge) * 8.0;
    EMISSION = emission;
}
