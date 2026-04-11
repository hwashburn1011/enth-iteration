---
epic: 29
title: "Town Atmosphere"
phase: 5 — Town Environment
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 29: Town Atmosphere

## Overview

Add atmospheric environmental effects to bring the town to life: volumetric god rays through trees, improved firefly particles with varied wandering paths, wind effects on vegetation (grass sway, leaf flutter), dust motes drifting in light shafts, ambient bird and butterfly creatures as simple animated sprites, chimney smoke with turbulent rise, and heat haze near the forge. These effects layer together to create a living, breathing environment that rewards players for lingering in the town.

## Success Criteria

- God rays visible streaming through tree canopies, responding to key light direction
- Fireflies wander with organic, varied paths (not uniform circular orbits)
- Wind visibly affects grass, tree leaves, and hanging objects (signs, lanterns)
- Dust motes drift lazily through visible light shafts
- Birds/butterflies add life as ambient sprite creatures with simple movement
- Chimney smoke rises with realistic turbulence and wind influence
- Forge area has visible heat haze distortion
- All atmosphere effects combined maintain 60fps at 1080p
- Effects enhance mood without distracting from gameplay

---

## Tasks

### Task 29.1: Volumetric Fog Setup for God Rays
- **Status:** TODO
- **Description:** Enable Godot's volumetric fog system in the WorldEnvironment to create the foundation for god rays. In the Environment resource, enable `volumetric_fog_enabled`, set `volumetric_fog_density` to a low value (0.01-0.03 for subtle haze), set `volumetric_fog_albedo` to a warm white (#FFF8F0) to pick up the warm key light color, and set `volumetric_fog_emission` to zero (fog should only scatter light, not glow on its own). Set `volumetric_fog_length` to cover the visible scene area. The result should be subtle atmospheric haze that makes distant objects slightly faded and allows light shafts to become visible where the directional light is partially blocked by trees and buildings.
- **Acceptance Criteria:**
  - [ ] Volumetric fog enabled in WorldEnvironment
  - [ ] Fog density is subtle (slight haze, not soupy)
  - [ ] Fog picks up warm key light color for atmospheric tint
  - [ ] Distant objects show slight atmospheric fade
  - [ ] God ray potential visible where light is partially occluded
  - [ ] No heavy performance impact from fog alone

### Task 29.2: God Ray Enhancement via FogVolume Nodes
- **Status:** TODO
- **Description:** Place FogVolume nodes (Box or Cylinder shaped) in areas where god rays should be most dramatic: between tree canopies where sunlight filters down, near the dungeon entrance where light hits a building edge, and in any narrow gap between buildings. Set each FogVolume's material to a FogMaterial with slightly higher density than the global fog (0.05-0.1) so the light shafts are more visible in these specific areas. Adjust the box size and rotation to match the light direction — the volume should be elongated along the light's ray direction. The effect creates localized beams of visible light rather than uniform global haze.
- **Acceptance Criteria:**
  - [ ] FogVolume nodes placed in key god ray locations
  - [ ] Light shafts clearly visible streaming through tree gaps
  - [ ] Volumes aligned with the directional light direction
  - [ ] God ray intensity is stronger than ambient haze but not blinding
  - [ ] Rays visible from the isometric camera angle
  - [ ] 3-5 god ray locations across the town scene

### Task 29.3: Improved Firefly Particle System
- **Status:** TODO
- **Description:** Replace the existing firefly particles with an improved system using GPUParticles3D. Create a warm yellow-green emissive point (color #D0FF60 with emission energy 3.0) as the particle mesh. Configure the ParticleProcessMaterial for organic wandering: use the velocity_curve and orbit properties to make fireflies drift in gentle, irregular paths rather than uniform orbits. Set long lifetime (5-8 seconds), very slow speed (0.2-0.5 m/s), and random start positions within a large emission box encompassing grassy/garden areas. Add a pulsing glow effect by animating the particle's color alpha with a sine curve (scale_over_lifetime with a sine pattern). Emit 15-30 fireflies across the town.
- **Acceptance Criteria:**
  - [ ] Fireflies drift in organic, varied paths (not circles)
  - [ ] Warm yellow-green glow matches firefly color
  - [ ] Glow pulses (fade in/out) like real firefly bioluminescence
  - [ ] 15-30 fireflies visible across the town
  - [ ] Fireflies confined to appropriate areas (grass, gardens, trees)
  - [ ] Each firefly path feels unique

### Task 29.4: Firefly Attraction to Light Sources
- **Status:** TODO
- **Description:** Add a behavioral enhancement to fireflies: they should drift preferentially toward warm light sources (lanterns, windows) while still maintaining their wandering pattern. Implement this by placing multiple GPUParticles3D emitters near light sources with slightly higher density, and using the attractor system (PointAttractor3D) near lanterns with very weak attraction strength. The fireflies shouldn't orbit the lantern — they should drift past, briefly attracted, then wander away. This creates the natural behavior of insects being drawn to light. Place attractors at 3-4 key lantern locations.
- **Acceptance Criteria:**
  - [ ] Fireflies drift preferentially near light sources
  - [ ] Fireflies don't orbit or get stuck on lights
  - [ ] Behavior looks like natural insect light attraction
  - [ ] Attractors placed at key lantern locations
  - [ ] Wandering pattern still dominant (attraction is subtle)
  - [ ] Effect visible but not exaggerated

### Task 29.5: Wind System — Global Wind Parameters
- **Status:** TODO
- **Description:** Create a WindManager autoload or singleton script (or add to GameManager) that provides global wind parameters accessible to all wind-responsive objects. Define: `wind_direction` (Vector2, default (1.0, 0.3) — mostly east with slight north), `wind_strength` (float, 0.0-1.0, default 0.3 for gentle breeze), `wind_gust_frequency` (float, default 0.1 Hz — periodic stronger gusts), and `wind_gust_strength` (float, default 0.7). The manager should update a slowly varying wind value each frame using layered sine waves: base wind + periodic gusts + random noise for organic variation. Expose the current effective wind vector for other systems to sample.
- **Acceptance Criteria:**
  - [ ] Wind parameter system created and accessible globally
  - [ ] wind_direction and wind_strength configurable
  - [ ] Periodic gusts create natural wind variation
  - [ ] Random noise prevents perfectly periodic behavior
  - [ ] Current effective wind vector available for other systems
  - [ ] Parameters exported for editor tuning

### Task 29.6: Wind Effect on Grass
- **Status:** TODO
- **Description:** Apply wind-responsive animation to the grass system from Epic 25. If grass uses a shader (billboard grass), add a vertex displacement in the grass shader that bends grass blades in the wind direction. Sample the global wind parameters via a uniform and displace the top vertices of each grass blade horizontally. The displacement should: increase with vertex height (base stays planted, tips bend most), include a per-instance random phase offset so blades don't all move in sync, and include a fast small-amplitude flutter on top of the slow wind sway. The result should look like a gentle breeze rippling through a grass field.
- **Acceptance Criteria:**
  - [ ] Grass blades sway in the wind direction
  - [ ] Sway increases from base (none) to tip (maximum)
  - [ ] Per-instance phase offset prevents synchronized movement
  - [ ] Fast flutter adds high-frequency detail to the sway
  - [ ] Wind direction changes smoothly affect grass
  - [ ] Grass sway visible and natural at isometric distance

### Task 29.7: Wind Effect on Tree Leaves
- **Status:** TODO
- **Description:** Add wind animation to tree canopies. If trees use a mesh for the leaf canopy, apply a vertex shader that displaces leaf vertices based on wind. Use a noise texture sampled at world-space XZ position with time offset to create spatially varying wind (some areas bend more than others, creating a wave-like effect through the canopy). The trunk and lower branches should be nearly unaffected (use vertex color or UV channel to mask wind influence — paint wind influence weight in Blender). Upper branches and leaves should sway noticeably. On strong gusts, the entire canopy should lean slightly in the wind direction.
- **Acceptance Criteria:**
  - [ ] Tree canopies sway in wind with natural motion
  - [ ] Trunk/lower branches remain stable
  - [ ] Upper branches and leaves have maximum sway
  - [ ] Noise-based displacement creates wave-like canopy motion
  - [ ] Gusts cause a noticeable canopy lean
  - [ ] Wind influence masked by vertex painting

### Task 29.8: Wind Effect on Hanging Objects
- **Status:** TODO
- **Description:** Add wind-responsive swinging animation to hanging objects in the town: shop signs, hanging lanterns, banners/flags, and any cloth elements. For each hanging object, create a simple pendulum animation driven by the wind system. Use a script or AnimationPlayer with wind input: the hanging object rotates around its hinge point proportional to wind strength, with a damped oscillation so it swings past center and settles. Flags and banners should use a simple cloth simulation — either a vertex shader with cascading wave displacement or 3-4 bones with physics simulation for more complex items.
- **Acceptance Criteria:**
  - [ ] Shop signs swing gently in the wind
  - [ ] Hanging lanterns sway (not just swing — gentle multi-axis)
  - [ ] Flags/banners ripple in the wind direction
  - [ ] Swinging responds to wind gusts (stronger swing on gusts)
  - [ ] Damped oscillation (not perpetual motion)
  - [ ] All hanging objects contribute to feeling of air movement

### Task 29.9: Dust Mote Particle System
- **Status:** TODO
- **Description:** Create a GPUParticles3D system for dust motes floating in light shafts. Use very small billboard quads (0.01-0.03m) with a soft circular texture and warm golden color (#FFF0C0 at low opacity). Set lifetime to 8-12 seconds, very slow upward drift (0.02 m/s), with random horizontal drift influenced by wind direction. Emit 30-50 particles within each god ray FogVolume area. The motes should catch the light — use additive blending so they glow when in lit areas and are nearly invisible in shadow. This creates the atmospheric effect of dust drifting through sunbeams.
- **Acceptance Criteria:**
  - [ ] Dust motes visible drifting through light shafts
  - [ ] Motes are very small (specks, not orbs)
  - [ ] Golden color catches the warm light
  - [ ] Additive blending makes motes glow in light, invisible in shadow
  - [ ] Slow drift with wind influence
  - [ ] 30-50 motes per light shaft area

### Task 29.10: Ambient Birds — Sprite Animation
- **Status:** TODO
- **Description:** Create 2-3 simple bird silhouette sprites (16x16 or 32x32 pixel art) with a 4-frame wing flap animation. Place Bird3D nodes (Sprite3D with AnimatedSprite3D or AnimationPlayer) in the town that fly predetermined paths between perch points. Create 3-5 flight paths: roof to tree, tree to tree, circling above the town. Each bird should: perch for 5-15 seconds (idle frame), take off (animation + upward movement), fly the path (flapping animation), and land at the destination (reverse takeoff). Use PathFollow3D on Path3D curves for smooth flight paths. Have 3-5 birds active at any time.
- **Acceptance Criteria:**
  - [ ] 2-3 bird sprite designs created (silhouette style)
  - [ ] 4-frame wing flap animation is smooth
  - [ ] Birds perch on roofs and tree branches
  - [ ] Flight paths between perch points are smooth curves
  - [ ] Birds take off, fly, and land with appropriate animations
  - [ ] 3-5 birds visible in the town at any time

### Task 29.11: Ambient Butterflies — Sprite Animation
- **Status:** TODO
- **Description:** Create 2-3 butterfly sprite designs (16x16) with a 3-frame wing flutter animation in warm colors (orange monarch, blue morpho, yellow swallowtail). Place Butterfly3D nodes near flower patches and the garden area. Unlike birds, butterflies should wander randomly in a small area rather than following paths. Implement wandering by choosing a random nearby target point (within 2m), drifting toward it with gentle bobbing motion (sine wave on Y), then choosing a new target when close. Flutter speed should be faster than bird flapping. Have 4-8 butterflies in garden areas.
- **Acceptance Criteria:**
  - [ ] 2-3 colorful butterfly sprite designs created
  - [ ] 3-frame flutter animation is smooth and quick
  - [ ] Butterflies wander randomly near flower patches
  - [ ] Bobbing motion adds natural up-and-down drift
  - [ ] 4-8 butterflies active in garden areas
  - [ ] Butterflies confined to appropriate garden/flower areas

### Task 29.12: Chimney Smoke Particle System
- **Status:** TODO
- **Description:** Create a GPU particle system for chimney smoke rising from inhabited buildings. Use a 64x64 soft cloud texture with transparency on billboard quads. Configure the ParticleProcessMaterial: spawn at chimney top, initial velocity upward (0.5-1.0 m/s) with slight wind direction offset, gravity set to negative (particles rise), increasing size over lifetime (0.3m start to 1.5m end), fading opacity from 60% to 0% over lifetime, slight rotation for organic look. Color should shift from warm gray (#A0A0A0) near the chimney to nearly invisible blue-gray (#C0C8D0) at the top. Emit 5-8 particles per second for a continuous plume. Wind should push the plume to lean in the wind direction.
- **Acceptance Criteria:**
  - [ ] Smoke rises from chimney tops of inhabited buildings
  - [ ] Plume expands and fades as it rises
  - [ ] Color shifts from warm gray to cool transparent gray
  - [ ] Wind pushes the plume in the wind direction
  - [ ] Smoke has slight rotation for organic look
  - [ ] 2-3 buildings emit chimney smoke

### Task 29.13: Chimney Smoke — Wind Interaction
- **Status:** TODO
- **Description:** Enhance the chimney smoke to respond dynamically to the wind system. Read the current wind vector from the wind system and apply it as a constant acceleration to the smoke particles. On calm wind (0.1-0.2), smoke rises mostly straight up with a gentle lean. On moderate wind (0.3-0.5), the plume clearly bends in the wind direction. On strong gusts (0.6-1.0), smoke streams nearly horizontal before dissipating. Update the particle material's velocity and acceleration based on wind each frame. Also add turbulence — use the noise-based wind variation so the plume wobbles rather than streaming in a perfectly straight line.
- **Acceptance Criteria:**
  - [ ] Smoke responds to wind direction and strength in real-time
  - [ ] Calm wind: smoke rises with gentle lean
  - [ ] Moderate wind: plume clearly bends sideways
  - [ ] Strong gusts: smoke streams nearly horizontal
  - [ ] Turbulence creates wobble in the plume
  - [ ] Wind response matches other wind-affected elements

### Task 29.14: Heat Haze Distortion Near Forge
- **Status:** TODO
- **Description:** Create a heat haze post-processing effect near the blacksmith forge area. Use a MeshInstance3D with a custom shader placed above the forge. The shader should sample the screen texture (SCREEN_TEXTURE) with UV offset based on a scrolling noise pattern to create wavy distortion. The distortion should be strongest directly above the forge and fade to zero at the edges of the mesh. Use a vertical noise scroll (heat rises upward) with subtle horizontal wobble. Set the mesh to be transparent and render after the main scene. The effect should be subtle — visible when you look for it, but not distracting during gameplay.
- **Acceptance Criteria:**
  - [ ] Heat haze distortion visible above the forge area
  - [ ] Distortion scrolls upward (heat rises)
  - [ ] Effect fades at edges (strongest at center, zero at perimeter)
  - [ ] Distortion is subtle (not nauseating or game-disrupting)
  - [ ] Effect uses screen-space distortion (not geometry displacement)
  - [ ] Only visible in the forge area, not bleeding into other areas

### Task 29.15: Falling Leaves Particle System
- **Status:** TODO
- **Description:** Create a seasonal falling leaf particle effect near deciduous trees. Use 3-4 small leaf textures (16x16 or 32x32 pixel art) in autumn colors (orange, red, yellow, brown) as billboard particles. Configure: spawn in a large emission box above the tree canopy, slow downward drift (0.3-0.5 m/s) with wind horizontal displacement, gentle tumbling rotation on all axes, lifetime 6-10 seconds, 3-5 particles per second per tree. Add a random delay before each leaf starts falling to avoid synchronized drops. Leaves should drift and tumble, not fall straight down. This effect is optional/seasonal but adds beautiful ambient detail.
- **Acceptance Criteria:**
  - [ ] 3-4 distinct leaf textures in autumn colors
  - [ ] Leaves tumble and drift naturally as they fall
  - [ ] Wind displaces leaves during fall
  - [ ] Random start delays prevent synchronized dropping
  - [ ] 3-5 leaves per second per tree (not overwhelming)
  - [ ] Leaves are small and appropriate scale for the trees

### Task 29.16: Ambient Sound Trigger Zones
- **Status:** TODO
- **Description:** Prepare spatial audio trigger zones for the atmosphere system (actual audio in Epic 49). Place Area3D nodes in zones corresponding to different ambient soundscapes: near trees (bird song zone), near water (water ambience zone), near forge (hammering/fire zone), garden area (insect buzz zone), town center (chatter/bustle zone). Create an AmbientSoundZone.gd script that emits EventBus signals when the player enters/exits each zone: `ambient_zone_entered(zone_type: String)`, `ambient_zone_exited(zone_type: String)`. Support overlapping zones with priority stacking (closer/smaller zone wins in overlap).
- **Acceptance Criteria:**
  - [ ] Area3D trigger zones placed for all ambient sound areas
  - [ ] 5+ distinct zone types defined
  - [ ] EventBus signals emitted on zone enter/exit
  - [ ] Overlapping zones handle priority correctly
  - [ ] Zone boundaries are reasonable for each sound type
  - [ ] Script follows project coding standards

### Task 29.17: Particle LOD and Distance Culling
- **Status:** TODO
- **Description:** Implement distance-based level-of-detail for all atmospheric particle systems. Particles that are far from the camera or at the edges of the screen should either reduce emission rate or cull entirely. For each GPUParticles3D node, configure the `visibility_range_begin` and `visibility_range_end` properties to fade particles at distance. Set fireflies visible range to 20m (they glow, visible further), dust motes to 10m (very small, invisible at distance), birds to 30m, butterflies to 15m, chimney smoke to 25m, falling leaves to 15m. This prevents rendering particles that the player can't see anyway.
- **Acceptance Criteria:**
  - [ ] All atmospheric particles have visibility range configured
  - [ ] Particles fade or cull at appropriate distances
  - [ ] Range values appropriate per particle size and brightness
  - [ ] No visible pop-in (use fade transition)
  - [ ] Performance improves at long camera distances
  - [ ] Close-up viewing still shows full particle density

### Task 29.18: Atmosphere Manager Script
- **Status:** TODO
- **Description:** Create an AtmosphereManager.gd script (or extend GameManager) that coordinates all atmospheric effects based on game state. The manager should: disable expensive effects during combat (reduce particle counts, disable dust motes), adjust atmosphere for time of day (more fireflies at dusk, no butterflies at night, chimney smoke color shifts), respond to weather events (increase wind, add rain ripples to puddles, reduce visibility in fog). Provide methods: `set_atmosphere_quality(level: int)` for player settings (Low/Medium/High atmosphere detail), and `set_time_period(period: String)` for day/night adjustments.
- **Acceptance Criteria:**
  - [ ] AtmosphereManager coordinates all atmospheric effects
  - [ ] Effects reduce during combat for performance/clarity
  - [ ] Time-of-day adjustments (fireflies at dusk, etc.)
  - [ ] Quality setting controls particle density
  - [ ] Weather state affects atmosphere (wind, rain, fog)
  - [ ] Manager follows project coding standards

### Task 29.19: Performance Profiling of All Atmosphere Effects
- **Status:** TODO
- **Description:** Profile the combined performance impact of all atmospheric effects. Enable all effects simultaneously and measure: total particle rendering cost (GPU time), volumetric fog cost, heat haze shader cost, wind shader cost on vegetation, and total frame time. Target: all atmosphere effects combined should add no more than 3ms to frame time at 1080p. If over budget, prioritize cuts: heat haze (least impactful visually) first, then dust motes, then reduce firefly count, then simplify smoke, then reduce fog quality. Document the performance breakdown per effect.
- **Acceptance Criteria:**
  - [ ] All atmospheric effects profiled individually and combined
  - [ ] Per-effect GPU cost documented
  - [ ] Total atmosphere cost under 3ms at 1080p
  - [ ] 60fps maintained with all effects active
  - [ ] Optimization cuts documented if applied
  - [ ] Low/Medium/High quality settings all meet target fps

### Task 29.20: Before/After Documentation and Final Review
- **Status:** TODO
- **Description:** Capture comprehensive before/after media showing the atmosphere overhaul. Take screenshots and short video recordings showing: god rays through trees, fireflies wandering, grass and trees swaying in wind, dust motes in light shafts, birds flying between perches, butterflies near flowers, chimney smoke with wind, and heat haze near the forge. Create a comparison gif or video showing the town with atmosphere effects off vs. on to demonstrate the dramatic impact. Save all media to `_bmad-output/visual-overhaul/screenshots/epic-29/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Before/after media for all major atmospheric effects
  - [ ] Video recordings of animated effects (particles, wind, etc.)
  - [ ] Comparison showing atmosphere off vs. on
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated with Epic 29 completion status
  - [ ] Town feels alive and atmospheric

---

## Dependencies

- **Epic 25** (Vegetation System) — Trees and grass for wind effects
- **Epic 27** (Town Lighting) — Light shafts and god ray foundation
- **Epic 28** (Water Effects) — Water for rain ripple integration

## Notes

- Atmosphere effects are layered — each one adds a small amount, but together they create a huge impact
- Prioritize wind on vegetation above all other effects — moving grass and trees make the biggest visual difference for the cost
- Fireflies and birds are "delight" effects — they make the player stop and watch, which is exactly the Stardew Valley feeling we're targeting
- Heat haze is the lowest priority — cut it if performance is tight
- Test all effects from the actual isometric camera distance, not just close up in the editor
