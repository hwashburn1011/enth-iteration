---
epic: 27
title: "Town Lighting Overhaul"
phase: 5 — Town Environment
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 27: Town Lighting Overhaul

## Overview

Overhaul the town's lighting from flat uniform illumination to a professionally lit environment with baked lightmap GI, warm key light with proper shadow cascades, cool sky fill light, building interior warm glow through windows, lantern warm pool lighting, time-of-day color shift preparation, ambient occlusion in corners, and light cookie patterns for windows. The goal is a cozy, inviting town that feels alive with light and shadow, matching the warmth and atmosphere of games like Stardew Valley and Emberville.

## Success Criteria

- Directional key light casts crisp shadows with 3-cascade shadow map (no shadow pop-in)
- Fill light provides cool ambient that prevents pitch-black shadows
- Every building window emits warm interior glow (OmniLight3D or SpotLight3D)
- Lantern props cast warm localized light pools on surrounding geometry
- LightmapGI baked for static geometry with no light leaks or artifacts
- AO visible in corners, under overhangs, and at wall/floor junctions
- Light cookies project window frame patterns onto ground near buildings
- Time-of-day system data structure prepared (3 presets: morning, noon, evening)
- Performance maintains 60fps at 1080p with all lighting active

---

## Tasks

### Task 27.1: Audit Current Lighting Setup
- **Status:** TODO
- **Description:** Document the current lighting state of Town.tscn. List all existing light nodes (DirectionalLight3D, OmniLight3D, SpotLight3D), their positions, colors, intensities, and shadow settings. Take screenshots from the 4 cardinal isometric angles and from directly above. Identify specific problems: flat areas with no shadow variation, objects that look floating due to missing contact shadows, areas that are too dark or too bright, any existing light leaking through walls. Create a lighting brief document listing all issues and the target look for each area of town.
- **Acceptance Criteria:**
  - [ ] All existing light nodes documented with properties
  - [ ] Screenshots captured from 4 angles plus overhead
  - [ ] Problem areas identified and documented
  - [ ] Lighting brief created with target look per area
  - [ ] Reference images from Emberville/Stardew Valley collected for comparison

### Task 27.2: Configure Directional Key Light
- **Status:** TODO
- **Description:** Set up the primary DirectionalLight3D as the sun/key light. Position the light direction to come from upper-left (roughly 45 degrees azimuth, 50 degrees elevation) to create readable shadows that don't obscure the isometric view. Set color to warm daylight (#FFF4E0, color temperature ~5500K). Set energy to 1.2-1.5 for a bright but not blown-out look. Enable shadows with 3 shadow cascades: cascade 0 at 8m (sharp player shadows), cascade 1 at 20m (medium building shadows), cascade 2 at 50m (distant soft shadows). Set shadow normal bias to 1.0 and shadow bias to 0.1 to minimize shadow acne while avoiding peter-panning.
- **Acceptance Criteria:**
  - [ ] Key light direction creates readable shadows at isometric angle
  - [ ] Light color is warm daylight, not pure white
  - [ ] 3 shadow cascades configured with appropriate distances
  - [ ] No shadow acne on any surface
  - [ ] No peter-panning (shadows don't float away from objects)
  - [ ] Shadow transitions between cascades are not visible

### Task 27.3: Configure Sky Fill Light
- **Status:** TODO
- **Description:** Add a secondary DirectionalLight3D as the sky fill, pointing roughly opposite to the key light but more overhead (60 degrees elevation). Set color to cool sky blue (#C8D8F0) with energy at 0.3-0.4 — just enough to fill the shadow areas with color without eliminating shadow contrast. Disable shadows on this light (shadows from fill create confusing double-shadow artifacts). This fill light should make shadow areas appear blue-tinted rather than black, creating the classic warm-light/cool-shadow color contrast that makes outdoor scenes feel natural.
- **Acceptance Criteria:**
  - [ ] Fill light direction opposes key light
  - [ ] Fill color is cool blue, not white or gray
  - [ ] Shadow areas now show blue tint instead of pure black
  - [ ] Fill energy is subtle (shadows still clearly readable)
  - [ ] No shadows cast by fill light
  - [ ] Warm/cool contrast visible in the scene

### Task 27.4: Set Up WorldEnvironment and Sky
- **Status:** TODO
- **Description:** Configure the WorldEnvironment node in Town.tscn with a ProceduralSky or panoramic sky HDRI. Set the sky to a warm afternoon look with soft clouds. Configure the Environment resource: enable ambient light set to Sky mode with energy 0.2 (subtle global bounce approximation), set tonemap to Filmic for a cinematic look, set white point to 1.0, enable auto-exposure with min sensitivity 100 and max 400 for subtle adaptation. Set background mode to Sky. Configure fog if needed (very subtle distance fog with warm tint at far edges of the town).
- **Acceptance Criteria:**
  - [ ] Sky visible and appropriate (warm afternoon, soft clouds)
  - [ ] Ambient light from sky provides subtle global illumination
  - [ ] Filmic tonemapping applied (no harsh clipping)
  - [ ] Auto-exposure range is subtle (no dramatic brightness shifts)
  - [ ] Optional distance fog adds atmospheric depth
  - [ ] Overall scene mood is warm and inviting

### Task 27.5: Bake LightmapGI for Static Town Geometry
- **Status:** TODO
- **Description:** Prepare all static town geometry for lightmap baking. In Godot, ensure all static meshes (terrain, buildings, fences, well, benches, large props) have `gi_mode` set to `Static` and have proper UV2 (lightmap UV) channels. If UV2 is missing, generate it in Godot's import settings (check "Generate Lightmap UV2"). Add a LightmapGI node to the Town.tscn scene. Configure bake settings: quality Medium for iteration (switch to High for final), bounces 3, use_denoiser true, texel_scale 1.0 (adjust based on result quality). Bake and verify the result — lightmap should show color bleeding (warm light bouncing off wood surfaces onto nearby stone), soft shadows in corners, and no light leaks.
- **Acceptance Criteria:**
  - [ ] All static meshes have UV2 lightmap channels
  - [ ] LightmapGI node added and configured
  - [ ] Bake completes without errors
  - [ ] Color bleeding visible (light bounces off colored surfaces)
  - [ ] Soft indirect shadows visible in corners and under overhangs
  - [ ] No light leaks through walls or floors

### Task 27.6: Fix Lightmap Artifacts and Light Leaks
- **Status:** TODO
- **Description:** After the initial bake, systematically check for and fix common lightmap problems. Walk through the entire town in the editor and look for: light leaking through walls (caused by thin geometry — add double-sided walls or thicken mesh), splotchy areas (increase texel density for those meshes), seams at UV2 island boundaries (adjust UV2 padding in import settings), dark spots where indirect light should reach (check that contributing lights are set to bake mode). For each issue found, apply the fix and re-bake the affected area. Document each fix for future reference.
- **Acceptance Criteria:**
  - [ ] No light leaking through any wall or floor
  - [ ] No splotchy/blotchy areas in the lightmap
  - [ ] UV2 seams not visible in the lightmap result
  - [ ] All indoor areas receive appropriate indirect light
  - [ ] Fixes documented for future bake iterations
  - [ ] Final bake is clean and artifact-free

### Task 27.7: Building Interior Warm Glow — Window Lights
- **Status:** TODO
- **Description:** For each building with windows (all 3 town buildings), place OmniLight3D nodes inside the building at window height. Set color to warm interior (#FFD4A0, warm amber/candlelight). Set energy to 0.8-1.2 depending on window size. Set range to 4-6m so light spills out the window onto the ground and nearby props. Enable shadows so the window frame casts a shadow pattern from the interior light. Set attenuation to a natural inverse-square falloff. The effect should suggest warm, inhabited interiors even without modeled interior rooms — the player sees light spilling out through windows and doorways.
- **Acceptance Criteria:**
  - [ ] Each building has at least one interior light per window
  - [ ] Light color is warm amber (not yellow or orange)
  - [ ] Light spills visibly onto ground and nearby surfaces
  - [ ] Window frame shadows cast by interior lights
  - [ ] Light range is appropriate (doesn't extend too far)
  - [ ] Buildings feel inhabited and warm from the outside

### Task 27.8: Create Window Light Cookies
- **Status:** TODO
- **Description:** Create light cookie textures (projector textures) that shape the interior light into window frame patterns. In an image editor, create a 256x256 grayscale texture for each window type in the game: rectangular window with mullions (cross pattern), arched window, small round window. White areas let light through, black areas block it. Apply these as the light's `light_projector` texture in Godot. Position SpotLight3D nodes (replacing or supplementing the OmniLights) aimed outward through each window so the cookie pattern projects onto the ground, creating the classic cozy window-light-on-cobblestone effect.
- **Acceptance Criteria:**
  - [ ] Light cookie textures created for each window type
  - [ ] Cookies project correct window frame patterns onto ground
  - [ ] Pattern scale matches actual window proportions
  - [ ] Warm window light pattern visible on ground near buildings
  - [ ] Cookies work with both the key light and interior light setup
  - [ ] Multiple window types have distinct patterns

### Task 27.9: Lantern Light Pools
- **Status:** TODO
- **Description:** Add OmniLight3D nodes to every lantern prop instance in the town scene. Set color to warm lantern glow (#FFB870, slightly more orange than building interiors to differentiate). Set energy to 0.6-0.8. Set range to 3-4m for a localized pool of light on the ground around each lantern. Set attenuation to create a tight falloff — bright near the lantern, fading within the range. Enable shadows so the lantern illuminates the ground beneath it and casts soft shadows of nearby objects. Ensure the light position is inside the lantern glass, not at the mesh origin. For wall-mounted lanterns, aim the light downward slightly.
- **Acceptance Criteria:**
  - [ ] Every lantern instance has its own OmniLight3D
  - [ ] Light color is warm orange-amber, distinct from building interiors
  - [ ] Light pools visible on ground beneath each lantern
  - [ ] Falloff is tight (bright center, quick fade to ambient)
  - [ ] Shadows cast from lantern light
  - [ ] Light source positioned inside the lantern glass geometry

### Task 27.10: Ambient Occlusion in Corners and Crevices
- **Status:** TODO
- **Description:** Enable screen-space ambient occlusion (SSAO) in the Environment resource to add real-time darkening in corners, under overhangs, and where surfaces meet. Configure SSAO settings: radius 0.5-1.0m (appropriate for the scene scale), intensity 0.5-0.8 (visible but not overpowering), bias 0.01, blur quality Medium. Test SSAO at the isometric camera distance — it should darken wall-floor junctions, under bench seats, inside the well, between fence posts, and in building doorways. Ensure SSAO doesn't create visible halo artifacts around character edges (adjust bias if needed). SSAO complements the baked AO in diffuse textures.
- **Acceptance Criteria:**
  - [ ] SSAO enabled and configured in Environment resource
  - [ ] Darkening visible at wall/floor junctions
  - [ ] Contact shadows under props and furniture visible
  - [ ] No halo artifacts around moving characters
  - [ ] SSAO intensity is subtle (enhances, doesn't dominate)
  - [ ] Performance impact is acceptable (less than 2ms on target hardware)

### Task 27.11: Shadow Quality Tuning
- **Status:** TODO
- **Description:** Fine-tune shadow quality across all light sources in the town. For the directional key light: set shadow map size to 4096 (or 2048 if performance is tight), enable shadow filter mode PCF13 for soft shadow edges, adjust shadow pancake_size if shadows disappear at steep angles. For OmniLight3D and SpotLight3D: set shadow resolution per-light based on importance (main building windows: 1024, lanterns: 512, secondary lights: 256). Verify shadows are sharp near the player's feet and soft at distance. Check that all props cast shadows onto the terrain and each other.
- **Acceptance Criteria:**
  - [ ] Directional shadow map is appropriately sized (no pixelation)
  - [ ] Shadow filtering produces soft edges (not hard pixel steps)
  - [ ] Point/spot light shadow resolution appropriate per importance
  - [ ] Character shadow is sharp and clear near feet
  - [ ] All props cast shadows onto terrain
  - [ ] Shadow rendering budget stays within frame time budget

### Task 27.12: Time-of-Day Data Structure
- **Status:** TODO
- **Description:** Create a Resource-based data structure for time-of-day lighting presets. Define a custom Resource class `LightingPreset` (res://resources/lighting/) with exported properties: key_light_color, key_light_energy, key_light_direction, fill_light_color, fill_light_energy, ambient_color, ambient_energy, fog_color, fog_density, sky_tint. Create 3 preset .tres files: `morning.tres` (cool blue-pink key, low angle, mist), `noon.tres` (warm white key, high angle, clear), `evening.tres` (deep orange key, low opposite angle, warm fog). These presets will be lerped between in future time-of-day implementation.
- **Acceptance Criteria:**
  - [ ] LightingPreset Resource class created with all relevant properties
  - [ ] morning.tres preset created with dawn colors and low angle
  - [ ] noon.tres preset created with bright daylight values
  - [ ] evening.tres preset created with sunset warmth
  - [ ] Presets are loadable and their values can drive light nodes
  - [ ] Resource files saved in correct project directory

### Task 27.13: Time-of-Day Transition Script
- **Status:** TODO
- **Description:** Create a TownLighting.gd script (attached to a Node3D in Town.tscn) that can lerp between LightingPreset resources over time. The script should hold references to the key light, fill light, WorldEnvironment, and all relevant light nodes. Implement a `transition_to(preset: LightingPreset, duration: float)` method that smoothly interpolates all lighting properties using a Tween. For the initial implementation, expose an @export variable to select the active preset in the editor for testing. Full time-of-day cycling will be implemented later — this task just builds the transition mechanism.
- **Acceptance Criteria:**
  - [ ] TownLighting.gd script created with preset transition capability
  - [ ] transition_to() method smoothly lerps all lighting properties
  - [ ] @export preset selector works in editor for testing
  - [ ] Morning, noon, and evening presets all look correct when applied
  - [ ] Transitions are smooth with no popping or artifacts
  - [ ] Script follows project coding standards (static typing, etc.)

### Task 27.14: Mood Zone Lighting for Town Areas
- **Status:** TODO
- **Description:** Create distinct lighting moods for different town areas using localized light sources. The marketplace area should feel bustling (slightly brighter, warmer fill). The garden/park area should feel peaceful (dappled light through trees, green-tinted bounce). The dungeon entrance area should feel ominous (cooler, dimmer, with a faint purple/blue accent). The residential area should feel cozy (warm lantern pools dominate). Add SpotLight3D or OmniLight3D nodes with appropriate colors and falloff to create these mood zones. The zones should blend naturally at boundaries.
- **Acceptance Criteria:**
  - [ ] Marketplace area has warm, bright, inviting lighting
  - [ ] Garden/park area has dappled, green-tinted ambient
  - [ ] Dungeon entrance area has cool, ominous accent lighting
  - [ ] Residential area dominated by warm lantern pools
  - [ ] Zone transitions blend smoothly (no hard light boundaries)
  - [ ] Each area has distinct mood visible in screenshots

### Task 27.15: Dappled Light Through Trees
- **Status:** TODO
- **Description:** Create a dappled light effect under the town's trees using light cookies or carefully placed SpotLight3D nodes. Create a 512x512 light cookie texture with an organic leaf shadow pattern — irregular blobs of black (shadow) and white (light) resembling sunlight filtering through a canopy. Apply this cookie to SpotLight3D nodes aimed downward through each tree's canopy, matching the tree's crown diameter. Set the light color to match the key light but slightly tinted green from the leaves (#F0F4D0). The dappled pattern should be visible on the ground beneath trees.
- **Acceptance Criteria:**
  - [ ] Leaf shadow light cookie texture created with organic pattern
  - [ ] SpotLights placed under each tree with cookie applied
  - [ ] Dappled light pattern visible on ground beneath trees
  - [ ] Light color slightly tinted from "leaf filtering"
  - [ ] Pattern scale is appropriate (not too large or too small)
  - [ ] Effect visible at isometric camera distance

### Task 27.16: Emissive Material Setup for Glowing Objects
- **Status:** TODO
- **Description:** Configure emissive materials in Godot for all objects that should emit light: lantern glass, forge fire, window interiors (if visible), any magical/tech elements, and the dungeon entrance portal. In the StandardMaterial3D, set emission_enabled to true, assign the emission texture (from texture painting), set emission color to complement the texture, and set emission_energy to 2.0-4.0 (high enough to bloom but not blow out). Ensure these emissive surfaces interact correctly with the WorldEnvironment's glow settings (bloom). The glow should create a soft halo around emissive objects without being overwhelming.
- **Acceptance Criteria:**
  - [ ] All glowing objects have emission enabled in their materials
  - [ ] Emission textures correctly mapped (only glowing parts emit)
  - [ ] Emission energy produces visible glow/bloom
  - [ ] Bloom halos are soft and not overpowering
  - [ ] Emissive objects visible from distance as points of warm light
  - [ ] Glow settings in WorldEnvironment tuned for the scene

### Task 27.17: Enable and Tune Glow (Bloom) Post-Processing
- **Status:** TODO
- **Description:** Enable the Glow (bloom) post-processing effect in the WorldEnvironment's Environment resource. Configure glow settings: set glow_enabled to true, set glow_intensity to 0.3-0.5 (subtle overall bloom), set glow_strength to 1.0, configure glow_bloom to 0.1 (threshold for what blooms), enable glow_hdr_threshold at 1.0 so only bright emissive surfaces and the sky bloom (not regular diffuse surfaces). Set glow_blend_mode to Additive or Softlight. Add 2-3 glow levels for varied bloom size. The result should be soft halos around lanterns, windows, and emissive objects without a washed-out look.
- **Acceptance Criteria:**
  - [ ] Glow enabled and configured in Environment
  - [ ] Lanterns and windows show visible soft bloom halos
  - [ ] Regular surfaces do NOT bloom (only emissive/bright)
  - [ ] Glow threshold correctly separates bright from normal surfaces
  - [ ] Multiple glow levels create varied bloom sizes
  - [ ] Overall image is not washed out or hazy

### Task 27.18: Light Group Organization and Editor Workflow
- **Status:** TODO
- **Description:** Organize all light nodes in Town.tscn into a clean hierarchy for editor usability. Create parent Node3D groups: `Lighting/KeyLights`, `Lighting/FillLights`, `Lighting/BuildingInteriors`, `Lighting/Lanterns`, `Lighting/MoodZones`, `Lighting/TreeDapple`. Move all light nodes into appropriate groups. Set meaningful names (e.g., `Lantern_Well_01`, `Window_BlacksmithN`). Add all lights to editor groups for batch toggle. Create an @tool script or editor comment documenting the lighting structure for future maintainability. This organizational work ensures lighting can be iterated on efficiently.
- **Acceptance Criteria:**
  - [ ] All light nodes organized into named parent groups
  - [ ] Every light node has a descriptive name
  - [ ] Lights can be toggled by group in the editor
  - [ ] Hierarchy is clean and navigable in Scene dock
  - [ ] Documentation comment describes the lighting structure
  - [ ] No orphan light nodes outside the Lighting hierarchy

### Task 27.19: Performance Profiling and Optimization
- **Status:** TODO
- **Description:** Profile the town scene's rendering performance with all lighting active. Use Godot's built-in profiler to measure: total frame time, shadow rendering time, lightmap contribution, SSAO cost, glow/post-processing cost, and total draw calls. Target: total frame time under 16.6ms (60fps) at 1080p. If performance is over budget, apply optimizations in priority order: reduce shadow map sizes for less important lights, reduce SSAO quality, reduce glow levels, increase lightmap texel scale (lower resolution), disable shadows on small/far lights. Document the performance breakdown and any optimizations applied.
- **Acceptance Criteria:**
  - [ ] Performance profiled with all lighting active
  - [ ] Frame time breakdown documented per system
  - [ ] Target 60fps achieved at 1080p
  - [ ] Optimizations applied if needed (documented which)
  - [ ] Shadow rendering cost is acceptable
  - [ ] Post-processing cost is acceptable

### Task 27.20: Before/After Documentation and Final Review
- **Status:** TODO
- **Description:** Capture comprehensive before/after screenshots for the lighting overhaul. "Before" should show the flat, uniformly lit town from git history. "After" should show the same camera angles with the full lighting setup. Capture: overview of full town, close-up of building with window glow, lantern light pool, tree dapple pattern, dungeon entrance mood, each mood zone, and a comparison of morning/noon/evening presets. Save all screenshots to `_bmad-output/visual-overhaul/screenshots/epic-27/`. Update MASTER-PLAN.md with completion status. Review the overall mood — the town should feel warm, cozy, and alive.
- **Acceptance Criteria:**
  - [ ] Before/after pairs from at least 8 camera angles
  - [ ] Time-of-day preset comparison shots (morning, noon, evening)
  - [ ] Mood zone comparison shots
  - [ ] Screenshots saved to correct directory
  - [ ] MASTER-PLAN.md updated with Epic 27 completion status
  - [ ] Town feels warm, cozy, and dramatically improved

---

## Dependencies

- **Epic 23** (Town Terrain) — Static geometry for lightmap baking
- **Epic 24** (Buildings Textured) — Buildings with windows for interior glow
- **Epic 25** (Vegetation System) — Trees for dappled light
- **Epic 26** (Props Textured) — Props for shadow casting and light interaction

## Notes

- Bake lightmaps frequently during iteration — don't wait until the end
- Warm key + cool fill is the #1 technique for making outdoor scenes look good
- Light cookies are cheap and dramatically improve the cozy feel
- SSAO radius should be tuned to the scene scale — too large and it looks like vignetting
- Keep the total number of shadow-casting lights under 8 for performance on mid-range hardware
