shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

// Shockwave ring — expanding ring of light from impact point. Apply to
// a flat disc and animate `progress` 0..1 over the ring lifetime.

uniform vec4 ring_color : source_color = vec4(1.0, 0.85, 0.45, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform float ring_width : hint_range(0.01, 0.5) = 0.10;
uniform float intensity : hint_range(0.0, 30.0) = 16.0;

void fragment() {
    float r = length(UV - 0.5) * 2.0;
    // The ring's current radius
    float center = progress;
    float dist_from_ring = abs(r - center);
    float ring_mask = 1.0 - smoothstep(0.0, ring_width, dist_from_ring);
    // Fade out as progress nears 1
    float lifetime_fade = 1.0 - smoothstep(0.7, 1.0, progress);

    ALBEDO = vec3(0.0);
    EMISSION = ring_color.rgb * ring_mask * lifetime_fade * intensity;
    ALPHA = ring_mask * lifetime_fade;
}
