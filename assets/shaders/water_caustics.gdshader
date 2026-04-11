// Animated water caustics decal. Task 6 of Epic 20.
// Apply to a Decal node or as a CanvasItem overlay on submerged ground.
// Uses two scrolling Voronoi-like patterns intersected for the classic
// caustic web pattern.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec4 caustic_color : source_color = vec4(0.55, 0.85, 1.00, 1.0);
uniform float scale : hint_range(0.5, 16.0) = 6.0;
uniform float speed : hint_range(0.0, 4.0) = 0.5;
uniform float intensity : hint_range(0.0, 4.0) = 1.5;
uniform float contrast : hint_range(1.0, 6.0) = 3.0;

float caustic_layer(vec2 uv, float t) {
	vec2 a = uv + vec2(sin(t * 1.3), cos(t * 0.7)) * 0.3;
	vec2 b = uv * 1.7 + vec2(cos(t * 0.9), sin(t * 1.1)) * 0.25;
	float v = sin(a.x * 6.28) * sin(a.y * 6.28) * 0.5 + 0.5;
	float w = sin(b.x * 6.28 + t * 2.0) * sin(b.y * 6.28 + t * 1.5) * 0.5 + 0.5;
	return min(v, w);
}

void fragment() {
	vec2 uv = UV * scale;
	float t = TIME * speed;
	float c = caustic_layer(uv, t);
	c = pow(c, contrast);

	ALBEDO = vec3(0.0);
	EMISSION = caustic_color.rgb * c * intensity;
	ALPHA = c;
}
