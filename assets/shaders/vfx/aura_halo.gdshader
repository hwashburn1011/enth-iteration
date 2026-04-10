shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

// Aura halo — soft animated radial glow plane that floats around an
// entity. Apply to a billboard quad facing the camera.

uniform vec4 inner_color : source_color = vec4(1.0, 0.85, 0.40, 1.0);
uniform vec4 outer_color : source_color = vec4(1.0, 0.45, 0.10, 1.0);
uniform float intensity : hint_range(0.0, 20.0) = 6.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float falloff : hint_range(0.5, 8.0) = 3.0;

void fragment() {
    // Distance from center of quad
    float d = length(UV - 0.5) * 2.0;
    float ring = 1.0 - clamp(d, 0.0, 1.0);
    float falloff_curve = pow(ring, falloff);

    // Pulsing radius
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
    falloff_curve *= (0.7 + 0.3 * pulse);

    vec3 col = mix(outer_color.rgb, inner_color.rgb, falloff_curve);
    col *= falloff_curve * intensity;

    ALBEDO = vec3(0.0);
    EMISSION = col;
    ALPHA = falloff_curve;
}
