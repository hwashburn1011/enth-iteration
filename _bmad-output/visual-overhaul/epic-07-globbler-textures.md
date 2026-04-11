---
epic_id: 07
title: "Epic 07: Globbler Textures"
phase: 3
status: IN_PROGRESS
priority: high
estimated_tasks: 20
---

# Epic 07: Globbler Textures

## Overview
Paint the complete texture set for Globbler's character model, transforming the raw mesh into a vibrant, hand-painted character that embodies the game's chunky stylized aesthetic. This epic follows the texture painting workflow established in Epic 03, applying every technique to the player character — the most-seen asset in the game. The final result is a full map stack (albedo, normal, roughness, emission, AO) that makes Globbler feel alive, digital, and charming under all lighting conditions.

## Success Criteria
- Globbler has a complete 1024x1024 texture set with all five map types (albedo, normal, roughness, emission, AO)
- The hand-painted albedo matches the Emberville/stylized art direction with warm shadows and painterly charm
- Circuit line emission glows convincingly under both outdoor and dungeon lighting
- Texture quality holds up at gameplay camera distance without visible seams or stretching

## Tasks

### Task 07.01: Prepare Texture Template and UV Snapshot
**Status:** TODO
**Description:** In Blender, render a UV layout snapshot of Globbler's body mesh at 1024x1024 resolution. Go to UV Editor > UV > Export UV Layout, export as PNG with black wireframe on transparent background. Open this UV snapshot in Krita (or preferred painting tool) as the bottom layer. Create the layer stack for painting: Layer 1 (bottom) — UV wireframe reference (locked), Layer 2 — Base color fill, Layer 3 — Shadow (Multiply), Layer 4 — Highlight (Screen), Layer 5 — Detail lines, Layer 6 — Circuit lines, Layer 7 — Face detail. Save this template as `_art_source/textures_source/globbler_albedo.kra` with all layers preserved.
**Acceptance Criteria:**
- UV snapshot exported at 1024x1024 matches the model's UV layout exactly
- Krita file has 7+ organized layers ready for painting
- UV wireframe layer is locked to prevent accidental modification

### Task 07.02: Paint Albedo Base Color Layer
**Status:** TODO
**Description:** Fill the entire UV layout with Globbler's base mid-tone color. Body and head base: a warm cyan-teal (#4AB8B8) that reads as "digital creature" while fitting the warm palette. Arms and legs: slightly darker variant (#3A9898) to create visual separation from the torso. Feet: darker still (#2A7878) to ground the character visually. Use a large soft brush (Enth_Base preset, 50% hardness) to fill each UV island with its designated color. Maintain clean edges along UV island boundaries. This layer should look flat and even — the 3D shading will come from subsequent layers.
**Acceptance Criteria:**
- Body, limbs, and feet each have distinct but harmonious base colors in the teal family
- UV islands are cleanly filled with no bleed into neighboring island padding
- Color values match the palette document (warm cyan, not cold blue)

### Task 07.03: Paint Albedo Shadow Layer
**Status:** TODO
**Description:** Create the shadow layer (Multiply blending mode, 60% opacity). Paint warm purple-brown shadows (#3A2A4A) in all concave and downward-facing areas of the mesh. Key shadow areas: underside of the head, beneath the chin, armpits (inner arm-to-body junction), between the legs, underside of the arms, bottom of the feet, inside the circuit line grooves. Reference the baked AO from Blender (or use Blender's Dirty Vertex Colors as a guide) to know where shadows naturally accumulate. Keep shadow edges soft using a 30% hardness brush — no hard shadow lines on an organic character.
**Acceptance Criteria:**
- Shadows appear in all correct concave areas (underside, creases, junction points)
- Shadow color is warm purple-brown, not cold grey or pure black
- Shadow edges are soft and blend naturally into the base color

### Task 07.04: Paint Albedo Highlight Layer
**Status:** TODO
**Description:** Create the highlight layer (Screen blending mode, 45% opacity). Paint warm cream highlights (#FFF4E0) on all upward-facing and convex surfaces that catch the top-left key light. Key highlight areas: top of the head (the dome), top of the shoulders, front upper chest, top of the forearms, bridge between the eyes, top surface of the feet. Add 2-3 very small bright specular dots (pure white, 1-2 pixel size) on the highest points of the head dome and shoulder tops for painterly sparkle. Highlights should reinforce the top-left lighting direction established in the style guide.
**Acceptance Criteria:**
- Highlights appear on all upward-facing convex surfaces
- Light direction in the texture matches the style guide's top-left key light
- Painterly specular dots add charm without looking like lens flare artifacts

### Task 07.05: Paint Face Details on Albedo
**Status:** TODO
**Description:** Paint Globbler's face details on a dedicated layer. The face area (flattened front of the head) gets special attention as the character's primary expressive surface. Paint the eye socket surrounds in a slightly darker shade (#3A8A8A) to create depth. Add a subtle "screen bezel" effect around the flat face area — a thin (2px) dark line (#2A6868) where the flat face meets the curved head, suggesting the face is a display panel. Paint a subtle blush on the "cheeks" (below and to the sides of the eyes) using warm pink (#C88A8A) at very low opacity (15%) to add life and warmth.
**Acceptance Criteria:**
- Eye socket surrounds are darker, creating depth even before eye geometry is textured
- Screen bezel line subtly suggests the face is a digital display panel
- Blush is barely perceptible but adds warmth — should not look like obvious circles of pink

### Task 07.06: Paint Circuit Line Details on Albedo
**Status:** TODO
**Description:** On a dedicated layer, paint the circuit line patterns that run along the grooves modeled into Globbler's body mesh. Use a thin hard brush (2-3px, 100% opacity) in a bright teal (#00CCAA) to trace lines along the UV coordinates that correspond to the circuit grooves. At intersection points, paint small circular nodes (4-5px diameter). The circuit pattern should feel organic — smooth curves, not rigid PCB traces. Lines branch from the spine down across the chest, along the outer arms, and around the back of the head. Keep the albedo circuit lines relatively subtle; the emission map will make them glow.
**Acceptance Criteria:**
- Circuit lines follow the modeled groove paths accurately on the UV layout
- Lines are 2-3px wide with node circles at intersections
- Pattern feels organic with smooth curves, matching the character's rounded form

### Task 07.07: Paint Arm and Leg Color Variation
**Status:** TODO
**Description:** Add color variation to the arms and legs to prevent them from reading as flat tubes. Paint subtle darker bands at the "joint" areas (elbows, wrists, knees, ankles) using a soft brush with the shadow color at 20% opacity. Add lighter patches on the outer surface of the upper arms and thighs (facing the camera) and darker patches on the inner surfaces. Paint the hand/mitten area with a slightly different hue (#3AB0A0, warmer) to distinguish them from the arms. Add tiny (1px) dot patterns on the shoulder caps suggesting circuit nodes or rivet details.
**Acceptance Criteria:**
- Joint areas (elbows, knees) are subtly darker, suggesting articulation
- Inner vs. outer limb surfaces have different values for visual interest
- Hands are distinguishable from arms through slight hue shift

### Task 07.08: Final Albedo Polish and Flatten
**Status:** TODO
**Description:** Review the complete albedo painting by applying it to the 3D model in Blender's Material Preview mode. Check for: visible UV seams (fix by painting across seam boundaries using Blender's texture paint mode in 3D view), color imbalance (any area too dark or too bright), consistency of detail level (face shouldn't be 10x more detailed than back), and overall color harmony. Once satisfied, flatten the Krita layer stack to a single layer and export as `assets/textures/characters/globbler_albedo.png` at 1024x1024. Keep the layered .kra file as the editable source.
**Acceptance Criteria:**
- No visible UV seams when viewing the textured model in 3D
- Consistent detail level across the entire character (front slightly more detailed is OK)
- Exported PNG is exactly 1024x1024 with no alpha channel (RGB only)

### Task 07.09: Create Ambient Occlusion Map
**Status:** TODO
**Description:** Generate the AO map using Blender's baking system. Select the Globbler mesh, create a new 1024x1024 image in the material's texture node, set it as the active bake target. Go to Render Properties > Bake > Bake Type: Ambient Occlusion. Set samples to 128 for clean results, ray distance to 0.5m. Bake. The result should show dark areas in crevices (eye sockets, mouth, circuit grooves, underarms, between legs) and light areas on exposed surfaces. If the AO looks too harsh, reduce contrast by adjusting levels (crush the darks up from 0 to ~30). Save as `assets/textures/characters/globbler_ao.png`.
**Acceptance Criteria:**
- AO map shows correct darkening in concave areas and crevices
- No bake artifacts (black spots from ray distance issues or inverted normals)
- AO contrast is moderate — enhances depth without creating harsh black patches

### Task 07.10: Create Normal Map
**Status:** TODO
**Description:** Generate a stylized normal map for Globbler. Since the character is intentionally low-poly and stylized, the normal map should add broad, rounded surface curvature rather than fine wrinkles or pores. Method: (1) In Blender, apply 2 levels of Subdivision Surface to a copy of the mesh, sculpt subtle broad bumps (inflate brush on muscle areas, smooth the circuit grooves slightly), (2) Bake normals from the subdivided copy to the original UV layout (Selected to Active, ray distance 0.05m). Alternatively, generate from the albedo using a normal map generation tool (Laigter, NormalMap Online) at low strength (0.3). Save as `assets/textures/characters/globbler_normal.png`.
**Acceptance Criteria:**
- Normal map adds broad curvature detail, not fine realistic wrinkles
- Bake has no artifacts (purple/green patches from incorrect normals)
- Normal map intensity is subtle — visible but not making the character look bumpy

### Task 07.11: Create Emission Map for Circuit Lines
**Status:** TODO
**Description:** Paint the emission map as a black image with bright areas only where glow occurs. Open a new 1024x1024 canvas, flood fill with pure black (#000000). Using the UV layout reference, paint the circuit lines in bright cyan (#00FFDD) at 2-3px width, matching the albedo circuit lines exactly. Paint circuit node intersections as slightly larger glowing dots (4-5px, same cyan). Add a soft glow halo around each line (use a 10px soft brush at 30% opacity in the same cyan) to create a pre-baked bloom effect in the texture itself. Paint the eye areas with bright white (#FFFFFF) — eyes always glow.
**Acceptance Criteria:**
- Emission map is black everywhere except circuit lines and eyes
- Circuit lines match the albedo layer's circuit pattern exactly (same UV positions)
- Pre-baked bloom halos around lines create a convincing glow even without post-processing bloom

### Task 07.12: Add Emission Pulse Zones
**Status:** TODO
**Description:** Designate specific areas of the emission map as "pulse zones" that will animate with a breathing glow effect in Godot. Paint these zones with a slightly different color (bright green channel, like #00FF88) to distinguish them from static glow in the shader. Pulse zones: the two largest circuit nodes on the chest (Globbler's "core"), the circuit lines running down the spine, and the eye pupils. The shader will use the green channel value to modulate emission intensity with a sine wave over time. Mark the rest of the circuit lines as static glow (pure cyan, no green channel pulse).
**Acceptance Criteria:**
- Pulse zones are painted in a distinguishable color (#00FF88 vs. #00FFDD for static)
- Chest core nodes, spine lines, and eye pupils are designated as pulsing
- Non-pulse circuit lines remain static cyan for visual variety

### Task 07.13: Create Roughness Map
**Status:** TODO
**Description:** Paint the roughness map using the albedo as a reference base. Start with a uniform mid-grey fill (pixel value 200, corresponding to ~0.78 roughness). Modify per area: head (slightly smoother, value 180/roughness 0.7 — it's a "screen surface"), body (standard, value 200/roughness 0.78), arms and legs (slightly rougher, value 210/roughness 0.82), feet (roughest, value 220/roughness 0.86), circuit line grooves (much smoother, value 140/roughness 0.55 — tech surfaces are smoother). Generate the base by desaturating the albedo, inverting, and adjusting levels, then manually paint over the specific areas listed above.
**Acceptance Criteria:**
- Roughness values are within the style guide's 0.55-0.9 range
- Circuit grooves are noticeably smoother than surrounding surfaces
- Head "screen" area is slightly smoother than the body, suggesting a display surface

### Task 07.14: Set Up Eye Material in Godot
**Status:** TODO
**Description:** Create a dedicated material for Globbler's eye meshes in Godot. The eye material is emissive, always glowing regardless of scene lighting. Configure: StandardMaterial3D with albedo color white (#FFFFFF), emission enabled with energy 2.0, emission color white (#FFFFFF), roughness 0.3 (eyes are glossy), no normal map needed. The eye glow should be visible even in dark dungeon scenes, serving as a player beacon. Optionally add a shader that pulses the emission energy between 1.5 and 2.5 using a sine wave (period 3.0s) for a subtle "alive" breathing light effect.
**Acceptance Criteria:**
- Eye material is self-illuminating and visible in both bright and dark scenes
- Emission energy (2.0 base) is bright enough to read as "glowing" but not so bright it washes out
- Optional pulse shader creates subtle living-light effect on the eyes

### Task 07.15: Set Up Body Material in Godot
**Status:** TODO
**Description:** Create Globbler's body material as a StandardMaterial3D in Godot with the full texture map stack. Configuration: (1) Albedo texture: `globbler_albedo.png`, (2) Normal Map: enabled, texture: `globbler_normal.png`, normal scale: 0.6, (3) Roughness: texture: `globbler_roughness.png`, channel: Red, (4) Emission: enabled, texture: `globbler_emission.png`, energy: 1.5, (5) Ambient Occlusion: enabled, texture: `globbler_ao.png`, channel: Red, AO light affect: 0.5. Save as `assets/materials/mat_globbler_body.tres`. Apply to the body mesh and verify all maps are loading correctly in the material preview.
**Acceptance Criteria:**
- Material .tres file exists with all 5 texture maps correctly referenced
- Normal map adds subtle depth without making the surface look bumpy
- Emission makes circuit lines glow at the specified energy level

### Task 07.16: Create Emission Pulse Shader
**Status:** TODO
**Description:** Write a custom Godot shader (or ShaderMaterial overlay) that makes designated emission zones pulse. The shader reads the emission texture and uses the green channel intensity to determine which areas pulse. Pulse formula: `final_emission = base_emission * (1.0 + pulse_zones * 0.3 * sin(TIME * 2.0))` where `pulse_zones` is the green channel value (0.0 for static, 1.0 for full pulse). This creates a gentle breathing effect on the chest core and spine lines while leaving other circuit lines at constant brightness. Save as `assets/shaders/emission_pulse.gdshader`.
**Acceptance Criteria:**
- Shader correctly reads emission texture green channel for pulse zone masking
- Pulse is a smooth sine wave at ~2 second period with 30% intensity variation
- Static emission zones (regular circuit lines) are completely unaffected by the pulse

### Task 07.17: Test Textures Under Outdoor Lighting
**Status:** TODO
**Description:** Place the fully textured Globbler model in the Style Guide Showcase scene under standard outdoor lighting. Verify: albedo colors read correctly under warm key light (not washed out or too dark), shadows painted into the texture enhance rather than conflict with real-time shadows, normal map curvature is visible but subtle, circuit line emission glows visibly but doesn't overpower the albedo, roughness variation creates subtle specular differences when the camera rotates. Take screenshots from gameplay camera angle and close-up angles. Compare to the Emberville reference images for style consistency.
**Acceptance Criteria:**
- Character reads clearly at gameplay camera distance (7-10m)
- Painted shadows and real-time shadows work together without creating "double shadow" artifacts
- Circuit glow is visible outdoors but not distractingly bright

### Task 07.18: Test Textures Under Dungeon Lighting
**Status:** TODO
**Description:** Place the textured Globbler in a dungeon-lit test scene (using the dungeon lighting preset from Epic 02 Task 02.07). Verify: the character is visible in low-light conditions (not disappearing into darkness), circuit line emission provides a subtle self-illumination that helps the player track their character, eye glow serves as a visible beacon in dark corridors, the warm cyan body color contrasts sufficiently against cool blue-purple dungeon environments. Adjust emission energy if the character is too dim or too bright in dungeon lighting. The player should ALWAYS be able to see Globbler clearly.
**Acceptance Criteria:**
- Globbler is clearly visible in dungeon lighting conditions at all times
- Circuit emission and eye glow help players track their character in dark environments
- Warm character colors contrast against cool dungeon palette for easy visual separation

### Task 07.19: Fix UV Seams Visible in Engine
**Status:** TODO
**Description:** With the final textures applied in Godot, rotate the camera around Globbler and identify any visible UV seams — lines where texture color or lighting appears to discontinue along the mesh surface. Common problem seam locations: center back of head/body, inner arms, inner legs. Fix seams by: (1) Re-opening the Krita source file, (2) Painting across the seam boundary using Blender's 3D texture paint mode (which projects paint across UV island boundaries), (3) Re-exporting the fixed albedo PNG. Also check for seam visibility in the normal map and fix similarly. Seams are most visible when the character is side-lit.
**Acceptance Criteria:**
- No visible texture discontinuities along UV seam lines when viewed in Godot
- Seam check is performed under multiple lighting angles (front, side, back lit)
- Both albedo and normal map seams are addressed

### Task 07.20: Create Texture Variant System for Iteration Progression
**Status:** TODO
**Description:** Design (but do not fully paint yet) the texture variant system for Globbler's visual progression across the game's 9 iterations. Document the planned changes per iteration: Iteration 1 (base colors, minimal circuit glow), Iteration 3 (brighter circuits, subtle color shift toward warmer tones), Iteration 5 (additional circuit patterns appear, emission energy increases), Iteration 7 (gold accent circuits, body color enriches), Iteration 9 (full circuit coverage, maximum glow, color saturation peak). Create a reference sheet showing the color/emission progression. Implement the system as swappable material presets or shader parameters that IterationManager can control.
**Acceptance Criteria:**
- Progression plan documents visual changes for iterations 1, 3, 5, 7, and 9
- Reference sheet shows the color/emission progression visually
- Technical approach (material swaps vs. shader parameters) is chosen and documented

## Dependencies
- Epic 03 (Texture Painting Workflow) for painting techniques, brush presets, and map standards
- Epic 06 (Globbler Character Model) for the finished UV-unwrapped mesh to paint on
- Epic 02 (Visual Style Guide v3) for color palette and material standards

## Notes
- The 1024x1024 resolution is the character texture tier defined in Epic 01
- Keep the layered Krita source file (.kra) as the editable master; PNG exports go to Godot
- The emission pulse shader is the first custom shader in the project — keep it simple and well-commented
- Eye textures may need iteration once facial animation is prototyped (Epic 09)
- The iteration variant system is a stretch goal; base textures are the priority
