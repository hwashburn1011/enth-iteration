shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Status effect overlay — drives a fresnel rim glow + scrolling
// pattern in `status_color`. Single shader, designer picks the
// status preset (poison/burn/freeze/shock) via `status_id`.

uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform float base_roughness : hint_range(0.0, 1.0) = 0.65;
uniform float base_metallic : hint_range(0.0, 1.0) = 0.0;

uniform int status_id : hint_range(0, 3) = 0;
// 0 = poison (green ripple)
// 1 = burn (orange flicker)
// 2 = freeze (cyan still)
// 3 = shock (yellow zaps)
uniform float status_strength : hint_range(0.0, 1.0) = 1.0;

vec4 status_preset() {
    if (status_id == 0) return vec4(0.20, 0.95, 0.30, 1.0); // poison
    if (status_id == 1) return vec4(1.0, 0.45, 0.10, 1.0);  // burn
    if (status_id == 2) return vec4(0.55, 0.85, 1.0, 1.0);  // freeze
    return vec4(1.0, 0.95, 0.30, 1.0);                       // shock
}

float fresnel(vec3 normal, vec3 view) {
    return pow(1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0), 3.0);
}

void fragment() {
    vec4 base = texture(albedo_tex, UV);
    vec4 status = status_preset();

    // Per-status time animation
    float t_anim = TIME;
    float pattern;
    if (status_id == 0) {
        // poison ripple
        pattern = 0.5 + 0.5 * sin(UV.y * 14.0 + t_anim * 3.0);
    } else if (status_id == 1) {
        // burn flicker
        pattern = 0.5 + 0.5 * sin(t_anim * 14.0 + UV.x * 8.0);
    } else if (status_id == 2) {
        // freeze still
        pattern = 0.7;
    } else {
        // shock zap
        pattern = step(0.7, fract(sin(UV.x * 50.0 + t_anim * 20.0) * 43758.5453));
    }

    float fres = fresnel(NORMAL, VIEW);
    vec3 status_emission = status.rgb * (fres * 0.7 + pattern * 0.3) * status_strength * 6.0;

    ALBEDO = base.rgb;
    EMISSION = status_emission;
    ROUGHNESS = base_roughness;
    METALLIC = base_metallic;
}
