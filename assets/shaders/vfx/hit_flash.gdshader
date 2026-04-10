shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Hit flash overlay — apply to enemy mesh and pulse `flash_amount` to
// 1.0 for a frame on damage. Tints the entire mesh in flash_color.

uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform vec4 base_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float base_roughness : hint_range(0.0, 1.0) = 0.65;
uniform float base_metallic : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 base = texture(albedo_tex, UV) * base_tint;
    ALBEDO = mix(base.rgb, flash_color.rgb, flash_amount);
    EMISSION = flash_color.rgb * flash_amount * 4.0;
    ROUGHNESS = base_roughness;
    METALLIC = base_metallic;
}
