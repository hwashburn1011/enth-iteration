shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

// Portal swirl — animated polar-coordinate spiral on a flat disc.
// Apply to a circle mesh facing camera.

uniform vec4 color_inner : source_color = vec4(0.30, 0.85, 1.0, 1.0);
uniform vec4 color_outer : source_color = vec4(0.55, 0.20, 0.85, 1.0);
uniform float intensity : hint_range(0.0, 30.0) = 14.0;
uniform float spin_speed : hint_range(-10.0, 10.0) = 2.0;
uniform float arms : hint_range(1.0, 12.0) = 5.0;

void fragment() {
    vec2 c = UV - 0.5;
    float r = length(c);
    float a = atan(c.y, c.x);

    // Spiral mask: r + arm angle + time
    float spiral = sin(arms * a + r * 18.0 + TIME * spin_speed);
    spiral = 0.5 + 0.5 * spiral;

    // Radial falloff
    float radial_fall = smoothstep(0.5, 0.0, r);
    float mask = spiral * radial_fall;

    vec3 col = mix(color_outer.rgb, color_inner.rgb, radial_fall);
    col *= mask * intensity;

    ALBEDO = vec3(0.0);
    EMISSION = col;
    ALPHA = mask;
}
