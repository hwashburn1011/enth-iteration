// Soft outline shader for equipped outfit pieces.
// Uses inverted-hull approach: render the back faces with vertex extrusion
// along normals in a single color, then the regular pass renders on top.
// Apply to a child MeshInstance3D that duplicates the geometry.

shader_type spatial;
render_mode unshaded, cull_front, depth_draw_opaque, shadows_disabled;

uniform vec4 outline_color : source_color = vec4(0.0, 0.95, 0.85, 1.0);
uniform float outline_width : hint_range(0.0, 0.05) = 0.012;
uniform float outline_pulse_speed : hint_range(0.0, 8.0) = 2.0;
uniform float outline_pulse_amount : hint_range(0.0, 1.0) = 0.25;
uniform float fresnel_falloff : hint_range(0.5, 8.0) = 3.0;
uniform float min_alpha : hint_range(0.0, 1.0) = 0.4;

void vertex() {
	// Extrude along normal in object space
	float pulse = 1.0 + sin(TIME * outline_pulse_speed) * outline_pulse_amount;
	VERTEX += NORMAL * outline_width * pulse;
}

void fragment() {
	// Fresnel-style falloff so the outline is stronger at silhouette edges
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_falloff);
	float alpha = max(min_alpha, fresnel);
	ALBEDO = outline_color.rgb;
	EMISSION = outline_color.rgb * 1.5;
	ALPHA = outline_color.a * alpha;
}
