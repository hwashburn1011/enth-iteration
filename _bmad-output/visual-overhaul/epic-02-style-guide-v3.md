---
epic_id: 02
title: "Epic 02: Visual Style Guide v3"
phase: 1
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 02: Visual Style Guide v3

## Overview
Create the definitive visual style guide for Enth: Iteration that locks down the Emberville/Stardew Valley-inspired chunky 3D art direction. This document serves as the single source of truth for every modeling, texturing, and lighting decision across the project, preventing style drift and ensuring visual coherence between assets made at different times or by different contributors.

## Success Criteria
- A comprehensive visual style guide document exists with reference images, proportion rules, and color specifications
- Any new asset created by following the guide matches existing assets without requiring revision
- Lighting and material settings are defined precisely enough to replicate in any scene
- Silhouette readability tests confirm characters and enemies are distinguishable at gameplay camera distance

## Tasks

### Task 02.01: Compile Emberville Reference Image Board
**Status:** TODO
**Description:** Gather 20-30 reference screenshots from Emberville, Stardew Valley (3D fan-art), A Short Hike, Lil Gator Game, and Ooblets that exemplify the target art style. Organize them into categories: characters, environments, props, lighting, UI. Save the reference board as `_art_source/reference/style_reference_board.png` (a single composite image) and individual images in `_art_source/reference/inspiration/`. Annotate key features: rounded edges, chunky proportions, warm color palettes, soft shadows, hand-painted texture look.
**Acceptance Criteria:**
- Reference board contains at least 20 annotated screenshots organized by category
- Key style traits are called out with arrows/labels on the composite image
- References cover characters, environments, props, lighting moods, and UI styling

### Task 02.02: Define Character Proportion Rules
**Status:** TODO
**Description:** Document exact proportion ratios for all character types. Globbler (player): 3 heads tall, head is 40% of body width, arms reach to mid-thigh, legs are 1 head-length long, hands are oversized (60% of head width). NPCs: 3.5-4 heads tall, slightly more realistic but still chunky. Enemies: varied but always readable silhouette, small enemies 2 heads tall, bosses up to 6 heads tall. Create a proportion reference sheet image showing front/side views with measurement lines at `_art_source/reference/proportion_guide.png`.
**Acceptance Criteria:**
- Proportion rules cover player, NPCs, small enemies, large enemies, and bosses
- A visual reference sheet shows front and side silhouettes with head-unit measurements
- Rules explain when to break proportions for emphasis (boss hands bigger, etc.)

### Task 02.03: Establish Edge Treatment Rules
**Status:** TODO
**Description:** Define the edge treatment standard: all modeled edges must have at least a small bevel (0.02-0.05m depending on object scale). No razor-sharp 90-degree edges anywhere in the game. Organic objects (characters, plants, food) use smooth shading with auto-smooth at 60 degrees. Architectural objects (buildings, furniture) use smooth shading at 45 degrees with supporting edge loops to create controlled creases. Document specific bevel width ranges per asset category and provide Blender modifier stack examples (Bevel modifier: width 0.02, segments 2, clamp overlap on).
**Acceptance Criteria:**
- Edge treatment rules specify bevel widths and smooth angles for organic vs. hard-surface objects
- At least two Blender screenshots show correct vs. incorrect edge treatment
- Rules explain the "never sharp" principle and its contribution to the chunky stylized look

### Task 02.04: Lock Down Primary Color Palette
**Status:** TODO
**Description:** Finalize the primary color palette with exact hex values, RGB values, and Blender/Godot color picker values. Environment base colors: grass #6FAF6A, dirt path #8A6A4A, stone #9A9A9A, dark stone #5A5A5A, wood #7A5A3A, dark wood #5A3A2A, water surface #4A8ABA, water deep #2A5A7A, sand #C4A46A, snow #E8E0D8. Sky palette: day sky #87CEEB, sunset sky #FF9A5A, night sky #1A1A3A. Create a Godot Resource file (`assets/materials/color_palette.tres`) storing these as a custom resource for easy script access.
**Acceptance Criteria:**
- All environment base colors are documented with hex, RGB, and usage context
- Sky colors cover day, sunset/sunrise, and night conditions
- A Godot resource exists that scripts can reference for consistent color usage

### Task 02.05: Lock Down Accent and Tech Color Palette
**Status:** TODO
**Description:** Define the accent colors used for tech elements, UI highlights, and gameplay feedback. Neon cyan #00FFDD (player abilities, friendly tech), neon magenta #FF00AA (enemy attacks, corruption), neon yellow #FFE500 (loot, collectibles, interaction prompts), neon green #00FF88 (healing, nature restoration), warning red #FF3344 (damage, danger zones), XP gold #FFD700 (experience, level-up). Each accent has a dim variant at 40% brightness for subtle uses and a bloom-ready variant at 120% emission energy for glow effects.
**Acceptance Criteria:**
- Accent palette includes bright, dim, and emission variants for each color
- Usage context specifies which gameplay systems use which accent color
- Colors are tested against the dark dungeon and bright outdoor environments to ensure readability

### Task 02.06: Define Lighting Reference Standard
**Status:** TODO
**Description:** Establish the three-point lighting standard for all scenes. Key light: warm directional light (#FFF4E0, energy 1.2) positioned top-left at 45 degrees elevation, 30 degrees azimuth, casting soft shadows (shadow bias 0.02, shadow blur 1.0). Fill light: cool ambient (#8A9ABE, energy 0.3) from the opposite side to prevent pure-black shadows. Rim/back light: subtle (#FFFFFF, energy 0.2) from behind-above to separate characters from background. Document these as a Godot Environment + DirectionalLight3D preset saved as `assets/lighting/standard_outdoor.tres`.
**Acceptance Criteria:**
- Lighting setup produces warm, inviting outdoor scenes matching the Emberville mood
- No area of any scene is pure black; fill light ensures shadow detail is always visible
- A reusable lighting preset .tres file can be dropped into any outdoor scene

### Task 02.07: Define Dungeon Lighting Variant
**Status:** TODO
**Description:** Create a dungeon/indoor lighting variant that shifts the mood to mysterious-tech-ruin while keeping the same chunky stylized feel. Key light is dimmer (#B0B0C0, energy 0.6) simulating ambient glow from tech ruins. Replace the sky fill with point lights from tech elements (#00FFDD, energy 0.4, range 5m) creating pools of colored light. Add volumetric fog (Godot FogVolume with density 0.02, #1A1A3A tint) for depth atmosphere. Save as `assets/lighting/standard_dungeon.tres`.
**Acceptance Criteria:**
- Dungeon scenes feel distinctly different from outdoor scenes while sharing the same art style
- Tech glow point lights create interesting light/shadow interplay on dungeon geometry
- Volumetric fog adds depth without obscuring gameplay-critical elements

### Task 02.08: Define Material Roughness and Metallic Standards
**Status:** TODO
**Description:** Document the material property ranges that define the Enth visual style. Standard roughness range is 0.7-0.9 (matte, non-reflective look). Only metal objects (swords, armor, tech panels) go below 0.7 roughness, and never below 0.4. Metallic is 0.0 for everything except actual metal (which is 0.8-1.0). Specular is kept at default 0.5. This prevents the "plasticky" look that comes from low roughness on non-metal objects. Create example material comparison screenshots showing correct vs. incorrect roughness for wood, stone, skin, and metal.
**Acceptance Criteria:**
- Roughness/metallic rules are documented with min/max ranges per material type
- Comparison screenshots show the visual difference between correct and incorrect settings
- Rules explicitly forbid common mistakes (metallic on wood, low roughness on fabric)

### Task 02.09: Define Emission Standards for Tech Elements
**Status:** TODO
**Description:** Document how emission is used to convey the "tech-ruin" aesthetic. Circuit lines on surfaces use emission energy 0.5-1.0 with the cyan accent color. Active tech panels use emission energy 1.5-2.0 with pulsing animation (sine wave, period 2s). Corrupted tech uses magenta emission at higher energy (2.0-3.0) with flickering animation (noise-based). Emission should never be so bright it washes out the albedo texture. Create a test scene with examples of each emission tier side by side.
**Acceptance Criteria:**
- Three emission tiers (subtle, active, corrupted) are defined with energy ranges and colors
- Animation patterns (pulse, flicker) are described with specific math (sine period, noise frequency)
- Test scene confirms emission looks good with and without bloom post-processing

### Task 02.10: Create Silhouette Readability Test Protocol
**Status:** TODO
**Description:** Define a repeatable test for confirming that characters and enemies are visually distinguishable. Take a screenshot of the game at normal gameplay camera distance, convert it to a pure black silhouette (threshold filter), and verify that each entity type has a unique recognizable outline. Globbler should be identifiable by the big-head/small-body ratio. Each enemy type must have at least one distinguishing silhouette feature (spikes, tentacles, wings, size). Document the test steps and create a Godot editor script that renders silhouette-only view for quick testing.
**Acceptance Criteria:**
- Test protocol document explains the silhouette test process step by step
- At least Globbler and 3 enemy types pass the silhouette readability test at gameplay camera distance
- A shader or post-process script exists that renders silhouette-only view for testing

### Task 02.11: Define Vegetation Style Rules
**Status:** TODO
**Description:** Document how plants, trees, grass, and flowers are modeled and textured in the Enth style. Trees are chunky with blob-shaped canopies (3-5 sphere-ish shapes merged, no individual leaf geometry). Grass uses vertex-colored mesh planes in clusters, not individual blade geometry. Flowers are simple 4-6 petal shapes with bright color variation. All vegetation uses alpha scissor (not alpha blend) to avoid sorting issues. Tree trunks are slightly tapered cylinders with painted bark texture, never realistic bark normal maps.
**Acceptance Criteria:**
- Vegetation rules cover trees, bushes, grass, flowers, and mushrooms/fungi
- Polygon budget per vegetation type is specified (tree: ~500 tris, grass clump: ~24 tris)
- Alpha scissor threshold is standardized at 0.5 for all vegetation transparency

### Task 02.12: Define Architecture Style Rules
**Status:** TODO
**Description:** Document building and structure design rules. Buildings use simple geometric volumes (rectangular prisms, cylinders) with chunky proportions (walls thicker than realistic, windows larger than realistic). Roofs have visible overhang (0.3m minimum). Door frames are arched or rounded, never sharp rectangular. Tech-ruin buildings mix organic rounded shapes with angular circuit-board panel sections. Color follows the palette: warm wood/stone base with cyan tech accent lines. Provide 2-3 sketch/blockout references showing correct proportions.
**Acceptance Criteria:**
- Architecture rules cover residential, commercial, tech-ruin, and dungeon structure types
- Proportion guidelines specify wall thickness, window size ratios, and roof overhang
- At least 2 reference blockout images show correct chunky architectural proportions

### Task 02.13: Define Prop Style Rules
**Status:** TODO
**Description:** Document interactive and decorative prop design standards. All props are slightly oversized compared to realistic scale (a barrel is 1.0m tall instead of 0.8m, a sword is 1.2m long instead of 0.9m). This exaggeration improves visibility at the isometric-ish camera distance. Props have minimal surface detail (painted on textures, not modeled). Functional props (chests, doors, levers) must have a clear visual affordance (glow outline, color contrast) indicating interactability. Decorative props can be simpler (100-300 tris) while functional props get more detail (300-800 tris).
**Acceptance Criteria:**
- Prop rules specify scale exaggeration ratios and polygon budgets by prop type
- Visual affordance rules ensure players can distinguish interactive from decorative props
- Size reference table lists common props with their exaggerated dimensions

### Task 02.14: Define UI Visual Style Rules
**Status:** TODO
**Description:** Document the UI art direction that complements the 3D world. UI panels use dark semi-transparent backgrounds (#1A1A2E at 85% opacity) with rounded corners (border radius 8px equivalent). Text uses a clean sans-serif font (press-start-2p or a custom chunky font) in light color (#E0E0E0) with subtle drop shadow. Health bars are segmented (not smooth gradients). Accent colors from the tech palette highlight interactive UI elements. Buttons have a chunky 3D-extruded appearance with hover/press states. Icons use the same hand-painted texture style as in-game assets.
**Acceptance Criteria:**
- UI style rules cover panels, text, buttons, health bars, icons, and tooltip styling
- Color values for all UI elements are specified with hex codes
- Rules ensure UI is readable against both bright outdoor and dark dungeon backgrounds

### Task 02.15: Define Camera and Perspective Rules
**Status:** TODO
**Description:** Document the gameplay camera setup that influences how all art is perceived. Camera is a perspective camera at 45-degree pitch, positioned 8-12m above and behind the player. Field of view is 50 degrees (narrower than default 70 for a more intimate feel). This camera angle means the top and front faces of objects are most visible, so texturing priority goes to those faces. Document which faces of buildings/props are "hero" faces (visible to camera) vs. "waste" faces (facing away, can be simpler).
**Acceptance Criteria:**
- Camera settings (pitch, distance, FOV) are documented with exact values
- Hero face vs. waste face concept is explained with visual examples
- Texture UV space allocation recommendations prioritize camera-facing surfaces

### Task 02.16: Create Material Comparison Reference Sheet
**Status:** TODO
**Description:** Build a reference image showing the same test sphere rendered with correct and incorrect material settings for each surface type. Show: wood (correct: rough 0.85, metallic 0.0 vs. wrong: rough 0.3, metallic 0.5), stone (correct: rough 0.9, metallic 0.0 vs. wrong: rough 0.5, metallic 0.2), metal (correct: rough 0.45, metallic 0.9 vs. wrong: rough 0.8, metallic 0.0), skin/organic (correct: rough 0.75, metallic 0.0 with subtle subsurface vs. wrong: rough 0.2 giving plastic look), tech panel (correct: rough 0.6, metallic 0.7, emission 1.0 vs. wrong: no emission, too rough).
**Acceptance Criteria:**
- Reference sheet shows 5 material types with correct and incorrect versions side by side
- Each comparison is labeled with exact material parameter values
- Sheet is saved as a PNG reference image accessible to all team members

### Task 02.17: Define Animation Style Rules
**Status:** TODO
**Description:** Document the animation aesthetic that matches the chunky visual style. All movement is snappy with exaggerated anticipation and follow-through (squash and stretch principles). Walk cycles use bouncy vertical oscillation (head bobs 5-8% of character height). Idle animations are exaggerated (visible breathing, occasional look-around). Attacks use strong wind-up poses held for 2-3 frames before fast execution. Hit reactions are punchy with brief freeze-frames (2-frame hit-stop). Death animations are dramatic with brief float before collapse.
**Acceptance Criteria:**
- Animation style rules cover movement, combat, reaction, and idle animation categories
- Timing guidelines specify frame counts for key poses (anticipation, hold, execution)
- Rules reference the 12 principles of animation and explain which ones are emphasized

### Task 02.18: Define VFX Style Rules
**Status:** TODO
**Description:** Document the visual effects aesthetic. All VFX use simple shapes (circles, arcs, rings) with gradient textures rather than complex particle simulations. Colors follow the accent palette strictly. Attack trails use mesh-based geometry (not particle trails) for consistent thickness. Particle effects prefer fewer large particles over many small ones (max 50 particles per effect for performance). Screen effects (flash, shake) are brief (under 0.2s) and subtle. Emission and additive blending are the primary VFX blending modes.
**Acceptance Criteria:**
- VFX rules specify particle count limits, blending modes, and color source requirements
- Shape language for VFX is defined (circles for heal, sharp angles for damage, spirals for magic)
- Performance budget per VFX effect is stated (max particles, max draw calls)

### Task 02.19: Build Style Guide Test Scene
**Status:** TODO
**Description:** Create a Godot test scene (`scenes/test/StyleGuideShowcase.tscn`) that contains one representative asset from each category (character, NPC, enemy, building, prop, vegetation, VFX) arranged in a well-lit environment using the standard outdoor lighting setup. This scene serves as the living reference for the art style. Any new asset should be temporarily placed in this scene and visually compared to existing assets to check for style consistency before being placed in production scenes.
**Acceptance Criteria:**
- Showcase scene contains at least one asset per category (even if placeholder/greybox initially)
- Standard outdoor lighting is applied so colors and materials are accurately represented
- Scene can be opened and reviewed in under 5 seconds (no heavy loading)

### Task 02.20: Write Style Guide Summary Document
**Status:** TODO
**Description:** Compile all rules from the above tasks into a single comprehensive style guide document at `_bmad-output/visual-overhaul/style-guide-v3.md`. Organize it with clear sections: Overview, Color Palette, Proportions, Edge Treatment, Materials, Lighting, Animation, VFX, UI, Camera. Each section references the detailed task documents and includes inline examples. This is the single document an artist reads before starting work on any Enth: Iteration asset. Keep it under 3000 words for readability, linking to detailed reference images rather than embedding them.
**Acceptance Criteria:**
- Style guide is a single readable document covering all visual rules
- Document is under 3000 words with links to reference images and detailed sub-documents
- A new contributor can read this document and produce an on-style asset without additional guidance

## Dependencies
- Epic 01 (Art Pipeline Setup) should be complete so folder structures and naming conventions are established

## Notes
- "v3" because this supersedes two earlier informal style guides used during prototyping
- The Emberville reference is the strongest single-game reference, but Enth has more tech/sci-fi elements
- Style guide should be treated as a living document, updated when edge cases arise during production
- All color values assume linear color space in Godot (sRGB input, linear workflow)
