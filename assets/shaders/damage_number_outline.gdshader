// Damage number outline shader. Task 46 of Epic 20.
// Apply to a Label or RichTextLabel via theme override for crisp readable
// damage numbers over busy combat backgrounds. Sharp 1px outline + drop shadow.

shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);
uniform vec2 shadow_offset = vec2(0.0, 2.0);
uniform float outline_thickness : hint_range(0.0, 4.0) = 1.5;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * outline_thickness;

	float a_l = texture(TEXTURE, UV - vec2(px.x, 0.0)).a;
	float a_r = texture(TEXTURE, UV + vec2(px.x, 0.0)).a;
	float a_u = texture(TEXTURE, UV - vec2(0.0, px.y)).a;
	float a_d = texture(TEXTURE, UV + vec2(0.0, px.y)).a;
	float outline_alpha = max(max(a_l, a_r), max(a_u, a_d)) * (1.0 - base.a);

	vec4 shadow = vec4(shadow_color.rgb, texture(TEXTURE, UV - shadow_offset * TEXTURE_PIXEL_SIZE).a * shadow_color.a);
	vec4 with_shadow = mix(shadow, base, base.a);
	vec4 with_outline = mix(with_shadow, outline_color, outline_alpha * outline_color.a);

	COLOR = with_outline;
}
