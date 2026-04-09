// Screen-space damage vignette. Task 34 of Epic 20.
// Apply as a CanvasItem material on a full-screen ColorRect overlay.
// Animate `intensity` from script: 0 -> 1 on damage, fade back to 0.

shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.85, 0.10, 0.10, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float radius : hint_range(0.0, 1.5) = 0.7;
uniform float softness : hint_range(0.0, 1.0) = 0.55;
uniform float pulse_speed : hint_range(0.0, 8.0) = 3.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float d = length(uv) * 2.0;
	float v = smoothstep(radius, radius + softness, d);
	float pulse = 1.0 + sin(TIME * pulse_speed) * 0.15;
	float a = v * intensity * pulse;
	COLOR = vec4(vignette_color.rgb, a * vignette_color.a);
}
