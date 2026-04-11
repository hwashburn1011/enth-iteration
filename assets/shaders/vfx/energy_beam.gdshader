shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

// Energy beam shader — animated UV scroll with hot center + cool edges
// for laser/lightning/breath weapons. Apply to a flat tube mesh aligned
// to the beam direction.

uniform vec4 core_color : source_color = vec4(0.95, 0.98, 1.0, 1.0);
uniform vec4 outer_color : source_color = vec4(0.20, 0.65, 1.0, 1.0);
uniform float scroll_speed : hint_range(-10.0, 10.0) = 4.0;
uniform float intensity : hint_range(0.0, 30.0) = 10.0;
uniform float edge_softness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // Distance from beam center axis (assumes UV.y is along axis, UV.x is across)
    float radial = abs(UV.y - 0.5) * 2.0;

    // Animated scroll along beam length
    float scroll = fract(UV.x + TIME * scroll_speed);
    // Hot pulse traveling down the beam
    float pulse = 0.5 + 0.5 * sin(scroll * 12.566 + TIME * 6.0);

    // Hot core falls off radially
    float core_mask = pow(1.0 - radial, 4.0);
    float outer_mask = pow(1.0 - radial, 1.5) * (1.0 - core_mask);

    vec3 col = core_color.rgb * core_mask + outer_color.rgb * outer_mask;
    col *= (0.7 + 0.3 * pulse);
    col *= intensity;

    ALBEDO = vec3(0.0);
    EMISSION = col;
    ALPHA = (core_mask + outer_mask) * (1.0 - smoothstep(edge_softness, 1.0, radial));
}
