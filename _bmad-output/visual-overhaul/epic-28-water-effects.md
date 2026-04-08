---
epic: 28
title: "Water Effects"
phase: 5 — Town Environment
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 28: Water Effects

## Overview

Implement polished water visual effects for the town environment: well water shader with animated normals, reflection, refraction, and caustics; puddle shader with rain ripple support; stream flow with foam edges; water particle splash on player interaction; underwater fog tint; and water surface planes with depth fade. All water effects should use Godot 4.4 shader language and GPU particles for performance, creating a visually rich and reactive water system that enhances the town's atmosphere.

## Success Criteria

- Well water has animated surface with believable reflection and refraction
- Puddles react to rain with expanding ring ripple animations
- Stream/creek flow visible with directional current and foam at edges
- Player interaction with water triggers splash particle effects
- Underwater fog tint applied when camera or objects are below water surface
- Water depth fade creates natural transition from shallow (visible bottom) to deep (opaque)
- All water shaders run at 60fps with no visible performance impact
- Water integrates seamlessly with surrounding textured environment

---

## Tasks

### Task 28.1: Research and Reference Water Shader Approaches
- **Status:** TODO
- **Description:** Research water shader techniques suitable for Godot 4.4's rendering pipeline and the game's stylized aesthetic. Collect reference screenshots from Emberville, Stardew Valley, and other stylized games showing how they handle water. Document the technical approach for each water type: well water (small contained, needs reflection), stream (directional flow, foam), puddles (flat, rain reaction). Decide between screen-space reflections vs. planar reflections vs. cubemap reflections based on what the isometric camera angle actually shows. Test basic shader performance in an isolated scene before committing to an approach.
- **Acceptance Criteria:**
  - [ ] Reference images collected for stylized water approaches
  - [ ] Technical approach documented for well, stream, and puddle water
  - [ ] Reflection method chosen with performance justification
  - [ ] Test shader prototype running at 60fps
  - [ ] Approach matches the game's hand-painted aesthetic

### Task 28.2: Well Water Surface Shader — Base Setup
- **Status:** TODO
- **Description:** Create the base water shader for the well's water surface plane. In Godot, create a new ShaderMaterial with a custom .gdshader file (`res://shaders/water_well.gdshader`). Set up the shader with: vertex displacement using two layered sine waves at different frequencies and directions for gentle surface ripple, a dark blue-green base color (#1A3A4A) with depth-based opacity (more opaque in center where water is deeper), and basic fresnel effect that makes the water more reflective at glancing angles and more transparent when viewed from above. Apply this shader to the water plane mesh inside the well.
- **Acceptance Criteria:**
  - [ ] Custom .gdshader file created for well water
  - [ ] Vertex displacement creates gentle surface ripple
  - [ ] Two wave layers at different frequencies create natural-looking motion
  - [ ] Dark blue-green base color matches the well's interior
  - [ ] Fresnel effect varies opacity with view angle
  - [ ] Shader applied to well water plane mesh

### Task 28.3: Well Water — Animated Normal Map for Surface Detail
- **Status:** TODO
- **Description:** Create or source a tileable water normal map texture (256x256) with organic ripple patterns. In the well water shader, sample this normal map twice with different UV scales and scroll speeds (one layer at `UV * 2.0 + TIME * 0.02`, second at `UV * 3.0 - TIME * 0.015` rotated 30 degrees) and blend the normals together. This dual-layer normal creates the appearance of complex, ever-changing water surface detail without any repeating pattern being visible. Connect the blended normal to the shader's surface normal output. The ripples should be gentle — this is still water in a well, not a rushing river.
- **Acceptance Criteria:**
  - [ ] Tileable water normal map texture created/sourced
  - [ ] Two normal map layers scrolling at different speeds and scales
  - [ ] Layers rotated relative to each other to break repetition
  - [ ] Blended normals create complex, natural-looking ripple pattern
  - [ ] Ripple intensity is gentle (well water, not ocean)
  - [ ] No visible tiling pattern at any time

### Task 28.4: Well Water — Reflection and Refraction
- **Status:** TODO
- **Description:** Add reflection and refraction to the well water shader. For reflection: sample the scene's screen texture with UV offset based on the water normal map to create distorted reflections of objects above the water. Use the fresnel term to blend between reflection and the water's base color. For refraction: sample the screen texture below the water surface with a smaller normal-based UV offset to create the distorted view of the well bottom (stones, sediment). Add a `refraction_strength` uniform (default 0.02) to control distortion amount. Ensure the refraction doesn't sample pixels from outside the well opening.
- **Acceptance Criteria:**
  - [ ] Reflection visible on the water surface (distorted by normals)
  - [ ] Fresnel controls reflection intensity (more at edges)
  - [ ] Refraction shows distorted view of well bottom
  - [ ] Refraction strength is configurable via uniform
  - [ ] No screen-space artifacts (sampling outside the well)
  - [ ] Both effects work together for believable water

### Task 28.5: Well Water — Caustic Light Pattern
- **Status:** TODO
- **Description:** Add a caustic light pattern effect to the well water surface or the well bottom. Create or source a tileable caustic texture (256x256, grayscale, organic light pattern). In the shader, project this caustic pattern onto surfaces below the water by sampling it with UV scrolling (similar to normals but at a different speed). Blend the caustic as an additive light contribution — bright caustic areas add brightness to the water bottom or to the water surface depending on the artistic look desired. Use two caustic layers at different scales to create complex, shifting patterns that mimic real underwater light refraction.
- **Acceptance Criteria:**
  - [ ] Caustic texture created/sourced (tileable, organic pattern)
  - [ ] Caustic pattern scrolls and shifts over time
  - [ ] Two layers create complex, non-repeating pattern
  - [ ] Caustic adds light to the water surface or well bottom
  - [ ] Caustic intensity is subtle (enhancement, not distraction)
  - [ ] Effect matches the stylized aesthetic

### Task 28.6: Well Water — Depth Fade and Edge Foam
- **Status:** TODO
- **Description:** Implement depth-based opacity fading so the well water transitions from transparent at the edges (where water is shallow) to opaque in the center (where water is deep). Use the DEPTH texture in the shader to calculate the distance between the water surface and the geometry behind it. Map this distance to opacity: `opacity = clamp(depth_difference * depth_fade_factor, 0.0, 1.0)`. At the very edge where water meets stone, add a thin foam/froth line by detecting where depth_difference is very small and adding a white-ish tint. This edge foam makes the water feel like it's lapping against the stone walls.
- **Acceptance Criteria:**
  - [ ] Water is transparent at edges where shallow
  - [ ] Water is opaque in the center where deep
  - [ ] Depth fade transition is smooth and natural
  - [ ] Thin foam/froth line visible at water-stone contact edge
  - [ ] Depth fade factor is configurable via uniform
  - [ ] Effect visible from the isometric camera angle

### Task 28.7: Puddle Shader — Base Setup with Ground Blend
- **Status:** TODO
- **Description:** Create a puddle shader (`res://shaders/water_puddle.gdshader`) for flat puddle planes placed on the town ground. The puddle should blend naturally with the ground texture around it — use the depth fade technique to create soft edges where the puddle meets the terrain rather than a hard circular boundary. The puddle surface should be highly reflective (more so than well water, since puddles are thin and act as mirrors). Base color should be dark and mostly transparent, with the reflection doing most of the visual work. Add very subtle normal map scrolling for minimal surface movement.
- **Acceptance Criteria:**
  - [ ] Puddle shader created as separate .gdshader file
  - [ ] Soft edges where puddle meets terrain (no hard boundary)
  - [ ] High reflectivity on puddle surface
  - [ ] Dark, mostly transparent base color
  - [ ] Subtle surface normal animation (nearly still water)
  - [ ] Puddle blends naturally into surrounding ground texture

### Task 28.8: Puddle — Rain Ripple Effect
- **Status:** TODO
- **Description:** Add rain ripple rings to the puddle shader. Create a ripple normal map texture with a single expanding ring pattern (256x256). In the shader, randomly sample this ripple at multiple UV positions using a pseudo-random function seeded by world position, with each instance starting at a random time offset. Each ripple should expand and fade over 1-2 seconds. Layer 4-8 simultaneous ripples at different positions across the puddle surface. The ripple rate should be controllable via a `rain_intensity` uniform (0.0 = no rain/no ripples, 1.0 = heavy rain/many ripples). Add the ripple normals to the base puddle normals.
- **Acceptance Criteria:**
  - [ ] Ripple ring texture created
  - [ ] Multiple simultaneous ripples visible across puddle surface
  - [ ] Ripples expand and fade naturally over time
  - [ ] Ripple positions are random and vary per puddle instance
  - [ ] rain_intensity uniform controls ripple frequency
  - [ ] Ripples blend naturally with base water normals

### Task 28.9: Stream Flow — Directional Current Shader
- **Status:** TODO
- **Description:** Create a stream/creek water shader (`res://shaders/water_stream.gdshader`) with visible directional flow. Unlike the well water (nearly still) and puddles (flat mirror), the stream water should clearly move in one direction. Scroll the normal map primarily along the stream's flow direction using a `flow_direction` uniform (vec2). Add a secondary slower cross-current scroll to create turbulence. Include vertex displacement with larger amplitude than the well water to create visible surface waves. The stream shader should feel energetic compared to the calm well water.
- **Acceptance Criteria:**
  - [ ] Stream shader created with directional flow visible
  - [ ] Flow direction configurable via uniform
  - [ ] Primary flow + secondary cross-current creates turbulence
  - [ ] Vertex displacement creates visible surface waves
  - [ ] Flow feels energetic and directional
  - [ ] Water clearly moves in a consistent direction

### Task 28.10: Stream — Foam at Edges and Obstacles
- **Status:** TODO
- **Description:** Add foam effects where the stream water meets banks, rocks, and obstacles. Use the depth fade technique to detect edge proximity, then overlay a foam texture (scrolling with the flow direction) at those edges. Create a tileable foam texture (256x256) with white frothy patterns on a transparent background. The foam should be denser and more opaque right at the edge and fade quickly into the clear water. Around any rocks or obstacles in the stream, increase foam density and add wake patterns (v-shaped foam trail downstream of the obstacle).
- **Acceptance Criteria:**
  - [ ] Foam visible along stream banks
  - [ ] Foam texture scrolls with the flow direction
  - [ ] Foam is dense at edges, fading into clear water
  - [ ] Obstacle wake patterns visible (foam behind rocks)
  - [ ] Foam texture is tileable with no visible seams
  - [ ] Foam amount is proportional to flow speed

### Task 28.11: Water Splash Particle Effect
- **Status:** TODO
- **Description:** Create a GPU particle system for water splash effects triggered when the player walks through water or interacts with the well. Use a GPUParticles3D node with a ParticleProcessMaterial. Configure: initial velocity upward (2-4 m/s) with random spread, gravity pulling particles down, 0.3-0.5 second lifetime, start size 0.05m shrinking to 0.0 at end, white-blue color (#C0D8FF) fading to transparent. Use 20-40 particles per splash. Create the splash mesh as a small stretched sphere or use a droplet texture on a billboard quad. Add a second emitter for the ring splash (expanding ring on the water surface).
- **Acceptance Criteria:**
  - [ ] Splash particles burst upward on water interaction
  - [ ] Particles arc under gravity and fade naturally
  - [ ] Particle count and size appropriate for small splashes
  - [ ] Ring splash visible on water surface at impact point
  - [ ] Splash triggers when player enters water areas
  - [ ] Performance impact is negligible (GPU particles)

### Task 28.12: Water Drip and Drop Particles
- **Status:** TODO
- **Description:** Create small-scale water drip particle effects for the well bucket, pipe drips, and overflowing surfaces. Use GPUParticles3D with very low emission rate (1-3 particles per second). Each drip particle should: spawn at the drip source, fall straight down under gravity, and trigger a tiny ripple splash on impact with the water surface below. Create a small spherical drip mesh (0.02m radius). The drip should stretch slightly during fall (scale Y increasing, scale XZ decreasing) to look like a falling water droplet. Add these drips to the well bucket, any leaky pipes, and roof edges after rain.
- **Acceptance Criteria:**
  - [ ] Drip particles fall from designated drip sources
  - [ ] Droplets stretch during fall (teardrop shape)
  - [ ] Splash/ripple triggered on impact with water surface
  - [ ] Emission rate is low and natural (intermittent drips)
  - [ ] Drip sources include well bucket and roof edges
  - [ ] Effect is subtle and atmospheric

### Task 28.13: Underwater Fog Tint
- **Status:** TODO
- **Description:** Implement a visual tint/fog effect for objects seen through or beneath water surfaces. In the water shaders, modify the refracted view (the screen texture sample behind the water) by blending it toward the water's base color based on depth. Objects very close to the surface (just below) should be barely tinted, while objects deeper should be heavily tinted toward the water color. This creates the effect of water absorbing light — deeper = darker and more blue-green. Add a slight blur to the refracted view by sampling the screen texture at a lower mip level for deeper water.
- **Acceptance Criteria:**
  - [ ] Objects below water surface are tinted toward water color
  - [ ] Tint intensity increases with depth
  - [ ] Shallow objects are barely affected, deep objects are opaque water color
  - [ ] Slight blur on deeper refracted objects
  - [ ] Effect works in the well and any stream areas
  - [ ] Tint color matches the water's base color

### Task 28.14: Water Surface Transparency and Sorting
- **Status:** TODO
- **Description:** Ensure water surface rendering handles transparency correctly in Godot's render pipeline. Set all water materials to use the Transparent render priority so they render after opaque geometry. Set the render priority on water meshes so they render in the correct order relative to other transparent objects (particles, glass, etc.). Verify that depth writing is configured correctly — water should write to depth for particles that land on it, but should read depth for the depth fade effect. Test with multiple overlapping water surfaces (puddle near stream) to ensure no z-fighting or sorting artifacts.
- **Acceptance Criteria:**
  - [ ] Water surfaces render after opaque geometry
  - [ ] No z-fighting between water and terrain
  - [ ] No sorting artifacts with other transparent objects
  - [ ] Particles render correctly on top of water
  - [ ] Overlapping water areas don't cause visual glitches
  - [ ] Depth fade works correctly with transparency settings

### Task 28.15: Water Audio Integration Points
- **Status:** TODO
- **Description:** Prepare the water system for audio integration (actual audio in Epic 49). Add Area3D trigger zones around each water body (well, stream, puddles). Create a WaterAudioZone.gd script that detects when the player enters/exits the water area and emits signals via EventBus: `water_entered(water_type: String)`, `water_exited(water_type: String)`, `water_splash(position: Vector3, intensity: float)`. The water_type string differentiates "well", "stream", "puddle" for different audio. The splash signal triggers on player footsteps in water. This prepares the audio hooks without implementing actual sounds yet.
- **Acceptance Criteria:**
  - [ ] Area3D trigger zones placed around all water bodies
  - [ ] WaterAudioZone.gd script detects player entry/exit
  - [ ] EventBus signals emitted for water_entered, water_exited, water_splash
  - [ ] water_type parameter differentiates water body types
  - [ ] Splash signal includes position and intensity data
  - [ ] Script follows project coding standards

### Task 28.16: Shader Uniform Exposed as Godot Properties
- **Status:** TODO
- **Description:** Expose all important water shader uniforms as Godot-friendly properties so designers can tune water appearance without editing shader code. For each water shader, create a companion .tres ShaderMaterial resource with uniforms exposed: wave_speed, wave_amplitude, reflection_strength, refraction_strength, depth_fade_distance, base_color, foam_color, foam_threshold, flow_direction, flow_speed, rain_intensity, caustic_intensity. Document each uniform with a comment in the shader explaining its range and effect. Save preset ShaderMaterial .tres files for each water type (well, stream, puddle) with tuned default values.
- **Acceptance Criteria:**
  - [ ] All shader uniforms exposed and accessible in Inspector
  - [ ] Each uniform documented with range and effect
  - [ ] Preset .tres files saved for well, stream, and puddle
  - [ ] Uniforms can be adjusted in real-time in the editor
  - [ ] Default values produce good results out of the box
  - [ ] No shader recompilation needed for tuning

### Task 28.17: Place Water Elements in Town Scene
- **Status:** TODO
- **Description:** Place all water elements in Town.tscn: update the well's water plane with the new well water shader, place puddle planes in appropriate locations (near the well, in low spots on paths, near building downspouts), set up stream/creek geometry if the town design includes one (or a drainage channel). Ensure water planes are at the correct Y height relative to surrounding geometry. Scale and orient puddles to look natural (irregular shapes, not perfect circles). Position stream flow direction to follow the terrain's downhill slope. Verify all water elements are visible from the isometric camera.
- **Acceptance Criteria:**
  - [ ] Well water plane updated with new water shader
  - [ ] Puddles placed in natural low-lying areas
  - [ ] Stream geometry placed along terrain (if applicable)
  - [ ] Water planes at correct heights relative to terrain
  - [ ] Puddles have irregular, natural shapes
  - [ ] All water visible and looking good from isometric camera

### Task 28.18: Water Interaction with Lighting
- **Status:** TODO
- **Description:** Verify and tune how the water shaders interact with the town's lighting setup from Epic 27. Water reflections should pick up the key light color and direction. Caustics should be influenced by the key light angle. Puddle reflections should show the sky color and nearby emissive objects (lanterns). Test water appearance with the morning, noon, and evening lighting presets — water should look different in each (morning: gray-blue with mist, noon: bright with strong reflections, evening: warm orange reflections). Adjust shader uniforms per time-of-day if needed, or confirm the lighting changes naturally produce good water visuals.
- **Acceptance Criteria:**
  - [ ] Water reflections respond to key light changes
  - [ ] Caustics align with light direction
  - [ ] Puddles reflect sky color and nearby light sources
  - [ ] Water looks appropriate in morning, noon, and evening presets
  - [ ] No visual artifacts when lighting changes
  - [ ] Water enhances the lighting mood (doesn't contradict it)

### Task 28.19: Performance Profiling of Water Effects
- **Status:** TODO
- **Description:** Profile the performance impact of all water effects combined. Measure frame time with water effects on vs. off: well water shader, all puddle instances, stream shader, splash particles, caustics. Each water shader's fragment cost should be documented. If the total water rendering cost exceeds 2ms, optimize: reduce normal map texture resolution, simplify the caustic calculation, reduce the number of ripple layers in puddles, use LOD to simplify distant water. Ensure all water effects run within budget on mid-range hardware at 1080p.
- **Acceptance Criteria:**
  - [ ] Frame time measured with all water effects active
  - [ ] Per-shader cost documented
  - [ ] Total water rendering cost under 2ms
  - [ ] 60fps maintained with all water effects active
  - [ ] Optimizations applied and documented if needed
  - [ ] Water performance acceptable on mid-range hardware

### Task 28.20: Before/After Documentation and Final Review
- **Status:** TODO
- **Description:** Capture before/after screenshots and short screen recordings of the water effects. "Before" should show the flat, untextured water planes (from git history). "After" should show: well water with animated surface and reflections, puddle with rain ripples, stream flow with foam, splash particle effect, and the water under different lighting conditions. Record a 10-second clip of each water type showing the animation in motion (animated effects don't convey well in still screenshots). Save to `_bmad-output/visual-overhaul/screenshots/epic-28/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Before/after screenshots for all water types
  - [ ] Screen recordings showing animated water effects
  - [ ] Water shown under multiple lighting conditions
  - [ ] Splash particle effect captured
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated with Epic 28 completion status

---

## Dependencies

- **Epic 23** (Town Terrain) — Ground geometry for puddle/stream placement
- **Epic 26** (Props Textured) — Well model for water placement
- **Epic 27** (Town Lighting) — Lighting for reflection and caustic interaction

## Notes

- The isometric camera angle means reflections are less critical than in a first-person game — prioritize surface animation and depth fade over perfect reflections
- Stylized water often looks better with exaggerated normals and saturated colors rather than physically accurate simulation
- Keep shader complexity manageable — water shaders can easily become expensive; start simple and add complexity only where it improves the visible result
- Test puddle rain ripples with rain_intensity = 0 as the default (no rain in the base town), ripples activate when weather system triggers rain
