// Absorb-light shader for the MemoryLeak (Epic 05 task 28).
//
// Most shaders add light. This one TAKES IT AWAY from the surfaces
// behind the mesh — the MemoryLeak should feel like it eats the
// ambient illumination of the room around it, not just casts a shadow.
//
// Implementation: blend_mul render mode multiplies the shader's output
// by the underlying screen color. If we output dark colors the screen
// gets darker; if we output white we leave it alone. So we drive the
// output color from a Fresnel falloff so the multiplication is most
// aggressive at the silhouette edge facing the camera and tapers toward
// the center (where the MemoryLeak's own body covers the screen anyway).
//
// Apply to: a SphereMesh slightly larger than the leak's body, parented
// to the leak's root so the absorb sphere follows the body. Use this
// shader as the material on that sphere.
//
// Tunable feel:
//   absorb_strength    — how dark the multiplication goes (0 = no effect,
//                         1 = full black at the strongest point)
//   falloff_power      — Fresnel exponent — higher = thinner darkening edge
//   inner_softness     — how much of the inner area is left untouched
//                         (so the leak's own body is the main visual)
//   tint_color         — slight color shift of the absorbed light. The
//                         MemoryLeak default is a cold blue-green so the
//                         absorbed area looks like it's been "fed through"
//                         the leak rather than just darkened
//   rim_emission       — emissive halo at the absorb edge (kept low so
//                         the sphere doesn't visibly glow but the seam
//                         between absorbed and normal area has a tint)

shader_type spatial;
render_mode blend_mul, depth_draw_opaque, cull_front, unshaded;

uniform float absorb_strength : hint_range(0.0, 1.0) = 0.65;
uniform float falloff_power : hint_range(0.5, 8.0) = 2.5;
uniform float inner_softness : hint_range(0.0, 1.0) = 0.30;
uniform vec3 tint_color : source_color = vec3(0.55, 0.75, 0.80);
uniform float rim_emission : hint_range(0.0, 4.0) = 0.6;

void fragment() {
	// Fresnel: 1.0 at edges (where view direction is most perpendicular
	// to surface normal), 0.0 at center (looking straight at the surface)
	float fres = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float fres_pow = pow(fres, falloff_power);

	// Bias the falloff so the inner region passes through unchanged.
	// inner_softness raises the floor of the curve so multiplications
	// near the center come out close to 1.0 (no darkening).
	float darken_amount = mix(inner_softness, 1.0, fres_pow);

	// The output color in blend_mul mode IS the multiplier. White = no
	// change, black = full darken. Lerp between white and the tint
	// color modulated by absorb_strength.
	vec3 multiplier = mix(vec3(1.0), tint_color * (1.0 - absorb_strength), darken_amount);

	ALBEDO = multiplier;

	// Rim emission painted at the absorb edge so the seam has a faint
	// teal halo. Kept very low so the effect remains primarily
	// subtractive.
	EMISSION = tint_color * fres_pow * rim_emission * 0.25;
}
