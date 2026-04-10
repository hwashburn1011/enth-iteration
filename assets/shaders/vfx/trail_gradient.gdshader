shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

// Trail gradient — head-to-tail color and alpha fade for projectile or
// motion trails. Apply to a ribbon mesh w/ UV.x running 0=tail to 1=head.

uniform vec4 head_color : source_color = vec4(1.0, 0.95, 0.45, 1.0);
uniform vec4 tail_color : source_color = vec4(0.85, 0.20, 0.10, 1.0);
uniform float intensity : hint_range(0.0, 20.0) = 8.0;
uniform float head_softness : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    float t = UV.x;
    // Head fade-out (smooths the start)
    float head_fade = smoothstep(1.0 - head_softness, 1.0, t);
    // Tail fade-in
    float tail_fade = smoothstep(0.0, 0.5, t);
    float mask = tail_fade * (1.0 - head_fade * 0.4);
    // Cross-axis edge softening
    float radial = abs(UV.y - 0.5) * 2.0;
    mask *= 1.0 - smoothstep(0.6, 1.0, radial);

    vec3 col = mix(tail_color.rgb, head_color.rgb, t);
    ALBEDO = vec3(0.0);
    EMISSION = col * mask * intensity;
    ALPHA = mask;
}
