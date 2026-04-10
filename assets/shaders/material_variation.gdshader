shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// =============================================================
// Procedural Material Variation Shader
// =============================================================
// Hashes object world position into 8 micro-variations so identical
// meshes (e.g. 8 ore_iron nodes spawned by the runtime decorator)
// don't all read as a copy-paste forest. Drop this onto any spawned
// resource node and Globbler-tier eyes will see real diversity.
//
// Per-instance variations applied:
//   - Hue rotation (±0.10 in [0,1])
//   - Lightness offset (±0.18)
//   - Roughness offset (±0.20)
//   - Normal map UV rotation (8 discrete angles)
//   - Detail noise scale (1.0 / 1.4 / 1.8 / 2.4 cycle)
//
// All variations are deterministic per world position so the same
// node always picks the same variant across save/load.
// =============================================================

uniform vec4 base_color : source_color = vec4(0.55, 0.45, 0.32, 1.0);
uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform sampler2D normal_tex : hint_normal;
uniform sampler2D roughness_tex : hint_default_white;
uniform float base_roughness : hint_range(0.0, 1.0) = 0.75;
uniform float base_metallic : hint_range(0.0, 1.0) = 0.0;
uniform float variation_strength : hint_range(0.0, 1.0) = 1.0;
uniform float detail_strength : hint_range(0.0, 1.0) = 0.30;

// -------------------------------------------------------------
// Hash helpers — produce stable pseudo-random per object position
// -------------------------------------------------------------
float hash3_to_float(vec3 p) {
    p = fract(p * vec3(443.8975, 397.2973, 491.1871));
    p += dot(p.yzx, p.xyz + 19.19);
    return fract((p.x + p.y) * p.z);
}

vec3 hash3_to_vec3(vec3 p) {
    return vec3(
        hash3_to_float(p + vec3(0.0,  0.0, 0.0)),
        hash3_to_float(p + vec3(13.2, 7.7, 0.0)),
        hash3_to_float(p + vec3(0.0,  17.5, 23.1))
    );
}

// HSL <-> RGB so we can rotate hue without losing detail
vec3 rgb_to_hsl(vec3 c) {
    float mx = max(max(c.r, c.g), c.b);
    float mn = min(min(c.r, c.g), c.b);
    float h = 0.0; float s = 0.0; float l = (mx + mn) * 0.5;
    if (mx != mn) {
        float d = mx - mn;
        s = l > 0.5 ? d / (2.0 - mx - mn) : d / (mx + mn);
        if (mx == c.r) h = (c.g - c.b) / d + (c.g < c.b ? 6.0 : 0.0);
        else if (mx == c.g) h = (c.b - c.r) / d + 2.0;
        else h = (c.r - c.g) / d + 4.0;
        h /= 6.0;
    }
    return vec3(h, s, l);
}

float hue_to_rgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0/6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0/2.0) return q;
    if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6.0;
    return p;
}

vec3 hsl_to_rgb(vec3 hsl) {
    float h = hsl.x; float s = hsl.y; float l = hsl.z;
    if (s == 0.0) return vec3(l, l, l);
    float q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    float p = 2.0 * l - q;
    return vec3(
        hue_to_rgb(p, q, h + 1.0/3.0),
        hue_to_rgb(p, q, h),
        hue_to_rgb(p, q, h - 1.0/3.0)
    );
}

// 2D rotation matrix (used to spin normal-map UVs per instance)
mat2 rot2(float a) {
    float c = cos(a); float s = sin(a);
    return mat2(vec2(c, -s), vec2(s, c));
}

// Per-instance state — computed once per fragment from object position
varying vec3 v_inst_hash;
varying float v_uv_rotate;
varying float v_detail_scale;

void vertex() {
    // Use the object's world origin (model[3].xyz) so all verts of one
    // instance share the same hash regardless of mesh shape.
    vec3 inst_pos = MODEL_MATRIX[3].xyz;
    v_inst_hash = hash3_to_vec3(floor(inst_pos * 4.0));
    // 8 discrete rotation angles for normal-map UV spin
    int rot_idx = int(floor(v_inst_hash.x * 8.0));
    v_uv_rotate = float(rot_idx) * (PI / 4.0);
    // 4 detail-scale buckets
    int scale_idx = int(floor(v_inst_hash.y * 4.0));
    v_detail_scale = 1.0 + float(scale_idx) * 0.4;
}

void fragment() {
    // Sample albedo at default UVs
    vec4 albedo_sample = texture(albedo_tex, UV);
    vec3 base = albedo_sample.rgb * base_color.rgb;

    // Apply HSL variation
    vec3 hsl = rgb_to_hsl(base);
    float hue_shift   = (v_inst_hash.x - 0.5) * 0.20 * variation_strength;
    float light_shift = (v_inst_hash.z - 0.5) * 0.36 * variation_strength;
    hsl.x = fract(hsl.x + hue_shift);
    hsl.z = clamp(hsl.z + light_shift, 0.0, 1.0);
    vec3 varied = hsl_to_rgb(hsl);

    ALBEDO = varied;

    // Roughness variation
    float r_sample = texture(roughness_tex, UV).r;
    float r_shift = (v_inst_hash.y - 0.5) * 0.40 * variation_strength;
    ROUGHNESS = clamp(base_roughness * r_sample + r_shift, 0.0, 1.0);
    METALLIC = base_metallic;

    // Normal map sampled at rotated/scaled UVs for per-instance normal variation
    vec2 nrm_uv = (UV - 0.5) * v_detail_scale;
    nrm_uv = rot2(v_uv_rotate) * nrm_uv + 0.5;
    vec3 nrm = texture(normal_tex, nrm_uv).xyz * 2.0 - 1.0;
    NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), nrm * 0.5 + 0.5, detail_strength);
}
