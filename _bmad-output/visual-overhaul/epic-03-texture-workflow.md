---
epic_id: 03
title: "Epic 03: Texture Painting Workflow"
phase: 1
status: DONE
priority: high
estimated_tasks: 20
---

# Epic 03: Texture Painting Workflow

## Overview
Define and implement the complete texture painting workflow from UV unwrapping through final Godot material setup. This epic covers UV standards, hand-painted texture techniques, atlas strategies, and the full map stack (albedo, normal, roughness, emission, AO) that gives Enth: Iteration its distinctive chunky hand-crafted look. Every texture in the game should feel like it was painted by the same artist following the same process.

## Success Criteria
- A repeatable, documented texture painting process exists that produces consistent stylized results
- UV unwrapping standards eliminate visible seams and texture stretching on all asset types
- The full texture map stack (albedo, normal, roughness, emission, AO) is defined with clear painting steps for each
- At least one complete asset demonstrates the full workflow as a reference for all future texturing work

## Tasks

### Task 03.01: Define UV Unwrapping Standards
**Status:** DONE
**Description:** Document UV unwrapping rules for all asset types. Seams must be placed along natural edges (back of legs, underside of objects, architectural corners) where they are least visible to the gameplay camera. Island packing density must be at least 80% (minimal wasted UV space). No UV island should have more than 10% stretching (use Blender's UV Stretch overlay to verify). Character UVs must be symmetrical where the model is symmetrical to allow mirrored painting. Props use single UV set; characters use primary UV for textures and secondary UV (UV2) for AO baking.
**Acceptance Criteria:**
- UV standards document specifies seam placement rules per asset category
- Minimum packing density (80%) and maximum stretch (10%) thresholds are stated
- Screenshots show Blender's stretch checker overlay on a correctly unwrapped example

### Task 03.02: Create UV Unwrapping Checklist and Verification Steps
**Status:** DONE
**Description:** Build a step-by-step UV unwrapping checklist: (1) Mark seams along hidden edges, (2) Unwrap with Blender's Smart UV Project as a starting point, (3) Manually adjust islands for minimal distortion using the Minimize Stretch tool, (4) Check stretch overlay (blue = good, red = bad), (5) Pack islands with margin of 4 pixels at target resolution (8px margin at 1024, 4px at 512), (6) Straighten UV islands for rectangular objects (buildings, crates), (7) Pin hero-face UVs to ensure they get the most texture space, (8) Final check: apply a checker texture to verify no visible distortion in 3D viewport.
**Acceptance Criteria:**
- Checklist has 8+ discrete steps with descriptions of what to verify at each step
- Pixel margin values are specified per texture resolution tier
- Checker texture verification step catches distortion issues before painting begins

### Task 03.03: Build Texture Atlas Layout for Small Props
**Status:** DONE
**Description:** Create a 2048x2048 texture atlas template for small props (barrels, crates, pots, bottles, tools, food items, crystals, small furniture). Divide the atlas into a 4x4 grid of 512x512 cells, giving each small prop one cell. Create the template in Krita or Photoshop with labeled grid guides and save it as `_art_source/textures_source/atlas_props_small.kra`. Map out the first 16 props that will share this atlas and assign each to a cell. Document the UV coordinate ranges for each cell so modelers know where to pack their UVs.
**Acceptance Criteria:**
- Atlas template file exists with 4x4 grid guides at 512x512 cell boundaries
- Cell assignment document maps at least 16 planned props to specific atlas cells
- UV coordinate ranges (0.0-0.25, 0.25-0.5, etc.) are documented per cell

### Task 03.04: Build Trim Sheet Layout for Architecture
**Status:** DONE
**Description:** Create a 2048x2048 trim sheet template for architectural detail reuse. The trim sheet contains horizontal bands of common building materials: wood planks (top row), stone blocks (second row), metal/tech panels (third row), ground/floor surfaces (fourth row). Each band is 2048x512 pixels, tileable horizontally. Include edge trims, corner details, and window frame elements within each band. This dramatically reduces unique texture work for buildings since many surfaces share the same trim details. Save as `_art_source/textures_source/trimsheet_architecture.kra`.
**Acceptance Criteria:**
- Trim sheet template has 4 horizontal material bands at 2048x512 each
- Each band includes base surface, edge detail, and at least one accent element
- The sheet is designed to be tileable horizontally for seamless wrapping on walls

### Task 03.05: Document Hand-Painted Albedo Technique — Base Layer
**Status:** DONE
**Description:** Write a detailed guide for the first phase of hand-painted texturing: the base color layer. Start by flood-filling the entire UV layout with the palette-appropriate mid-tone color (e.g., #7A5A3A for wood). Use a large soft brush (50% hardness, 100% opacity) to block in the main color zones: lighter for surfaces facing up (catching light), darker for surfaces facing down or in creases. Keep the base layer simple with only 2-3 value shifts across the surface. Use the color palette reference to select exact colors rather than eyeballing. This layer establishes the overall read of the material.
**Acceptance Criteria:**
- Guide explains the base layer process with specific brush settings (size, hardness, opacity)
- Color selection references the established palette document, not arbitrary picks
- Before/after images show a UV layout going from empty to base-colored

### Task 03.06: Document Hand-Painted Albedo Technique — Shadow Layer
**Status:** DONE
**Description:** Write the guide for phase two: painting shadows directly into the albedo texture. Create a new layer set to Multiply blending mode at 60-70% opacity. Use a medium brush (30% hardness) to paint shadow shapes in ambient occlusion areas: creases, undersides, where surfaces meet (e.g., barrel hoops against staves, roof against wall). Shadow color should be a warm purple-brown (#3A2A4A) not pure black, maintaining the warm art style even in dark areas. Use the sculpt/model's baked AO as a reference for where shadows fall.
**Acceptance Criteria:**
- Shadow layer technique specifies brush settings, layer blend mode, and opacity range
- Shadow color (#3A2A4A warm purple-brown) is mandated over pure black
- Guide explains how to use baked AO as a shadow placement reference

### Task 03.07: Document Hand-Painted Albedo Technique — Highlight Layer
**Status:** DONE
**Description:** Write the guide for phase three: painting highlights. Create a new layer set to Screen or Soft Light at 40-50% opacity. Use a small firm brush (70% hardness) to add highlights on upward-facing edges, prominent surface ridges, and wear points (corners of crates, tops of barrel staves, edges of stone blocks). Highlight color is warm cream (#FFF4E0). Add 2-3 very small specular-like dots on the most prominent highlight areas for a subtle painterly sparkle. Highlights should reinforce the top-left key light direction established in the style guide.
**Acceptance Criteria:**
- Highlight technique specifies layer blend mode, opacity, brush settings, and highlight color
- Highlights follow the top-left light direction consistently across all assets
- Guide includes tip about adding "painterly sparkle" dots for charm

### Task 03.08: Document Hand-Painted Albedo Technique — Detail Layer
**Status:** DONE
**Description:** Write the guide for phase four: adding surface details. On a new Normal layer at 100% opacity, paint material-specific details: wood grain lines (thin dark strokes following plank direction), stone surface cracks (subtle dark lines with light edge), metal rivets and seam lines, fabric weave patterns (cross-hatched light/dark), tech circuit lines (cyan glow color from palette). Details should be subtle enough to not overpower the base read at gameplay distance but add interest up close. Use a 1-3 pixel brush at the texture's working resolution.
**Acceptance Criteria:**
- Detail painting guide covers wood, stone, metal, fabric, and tech surface types
- Brush size recommendations are given relative to texture resolution (1-3px at 512, 2-5px at 1024)
- Guide warns against over-detailing that creates visual noise at gameplay camera distance

### Task 03.09: Create AO Baking Workflow from High-Poly
**Status:** DONE
**Description:** Document the process for baking ambient occlusion from a high-poly sculpt onto the low-poly game mesh UV layout. In Blender: (1) Create high-poly version by applying Subdivision Surface modifier (2 levels) and optionally sculpting additional detail, (2) Set up a new image texture node in the low-poly material for baking target, (3) Select high-poly, then Shift-select low-poly, (4) Bake > Ambient Occlusion with "Selected to Active" enabled, ray distance 0.1m, (5) Save the baked AO image. The AO map is used as a reference for shadow painting and can be multiplied onto the final albedo at 30-50% opacity for extra depth.
**Acceptance Criteria:**
- AO baking steps are numbered with exact Blender settings (ray distance, samples, margin)
- Document explains the Selected to Active workflow for high-to-low-poly baking
- AO map usage is documented: reference for painting and optional multiply blend at 30-50%

### Task 03.10: Define Vertex Color as Detail Layer Workflow
**Status:** DONE
**Description:** Document how vertex colors supplement textures for additional detail without extra texture samples. Use vertex color channel R for ambient occlusion (hand-painted in Blender's vertex paint mode using Dirty Vertex Colors as a starting point). Use vertex color channel G for blend masking (e.g., blending between grass and dirt on terrain). Use vertex color channel B for wind animation masking (how much each vertex sways, used by the wind shader). In Godot, enable "Vertex Color Use as Albedo" on the StandardMaterial3D or sample vertex colors in a custom shader.
**Acceptance Criteria:**
- Each vertex color channel (R, G, B) has a defined purpose documented
- Blender's Dirty Vertex Colors tool is explained as a starting point for AO painting
- Godot material setup for reading vertex colors is documented with screenshots

### Task 03.11: Create Stylized Normal Map Painting Guide
**Status:** DONE
**Description:** Document how to create stylized normal maps that enhance the hand-painted look without adding realistic detail that clashes. Rather than baking from ultra-high-poly sculpts, paint normal maps in a dedicated tool (Laigter, or manually in Krita using the Tangent Normal Map filter). Focus on painting broad, rounded surface curvature rather than fine cracks or pores. Key areas: subtle convexity on barrel staves, broad curvature on character limbs, panel indentation on tech surfaces. Normal map intensity should be subtle (Godot normal scale 0.5-0.8) to avoid looking too realistic.
**Acceptance Criteria:**
- Normal map guide distinguishes stylized normals (broad curvature) from realistic normals (fine detail)
- At least two creation methods are documented (bake from simple high-poly, paint directly)
- Recommended normal scale in Godot (0.5-0.8) is stated to keep the look stylized

### Task 03.12: Create Emission Map Painting Guide
**Status:** DONE
**Description:** Document emission map creation for tech and magical elements. Emission maps are black (no emission) everywhere except tech circuit lines, glowing eyes, active UI screens, magical runes, and energy sources. Paint emission areas in the accent color at full saturation on a black background. Circuit lines should be 1-2 pixels wide at texture resolution with occasional node points (small circles at intersections). Glow areas use a soft-edged brush to create a subtle bloom falloff already baked into the texture. Save emission maps as separate `_emission.png` files.
**Acceptance Criteria:**
- Emission map painting rules specify which surface types get emission and which do not
- Circuit line painting technique is described with pixel widths and node point placement
- Guide explains the pre-baked bloom technique (soft edge around glow source in texture)

### Task 03.13: Create Roughness Map Painting Guide
**Status:** DONE
**Description:** Document roughness map creation. Most of the roughness map should be a uniform grey matching the style guide's 0.7-0.9 range (pixel value 178-230 in 8-bit). Variation is subtle: slightly smoother (darker, 0.6) on polished surfaces like tech screens or wet stone. Slightly rougher (lighter, 0.95) on fabric, dirt-encrusted surfaces, or bark. Edge wear makes edges slightly smoother than flat surfaces (real-world physical accuracy that also looks good stylized). Roughness maps can often be generated by desaturating and adjusting the albedo map's contrast rather than painting from scratch.
**Acceptance Criteria:**
- Roughness range per material type is documented with pixel values and Godot roughness equivalents
- The desaturation shortcut technique for generating roughness from albedo is explained
- Guide warns against too much roughness variation which creates an unrealistic "wet/dry patches" look

### Task 03.14: Set Up Godot StandardMaterial3D with Full Map Stack
**Status:** DONE
**Description:** Document the exact Godot StandardMaterial3D configuration for applying the complete texture map stack. Create a step-by-step guide: (1) Create new StandardMaterial3D, (2) Albedo > Texture: assign `_albedo.png`, (3) Normal Map > Enable, assign `_normal.png`, set scale to 0.6, (4) Roughness > Texture: assign `_roughness.png`, set channel to Red, (5) Emission > Enable, assign `_emission.png`, set energy to 1.0-2.0, (6) Ambient Occlusion > Enable, assign `_ao.png`, set to channel Red, light affect 0.5. (7) Enable "Vertex Color Use as Albedo" if using vertex color AO. Save the configured material as `.tres` for reuse.
**Acceptance Criteria:**
- Step-by-step material setup covers all 5 texture map types with exact settings
- Normal map scale, emission energy, and AO light affect values match the style guide
- The configured material is saved as a reusable .tres resource, not just applied inline

### Task 03.15: Create Texture Painting Brush Preset Library
**Status:** DONE
**Description:** Build a library of custom brush presets in Krita (or the team's painting tool) optimized for stylized hand-painted texturing. Include: `Enth_Base` (large soft round, 50% hardness), `Enth_Shadow` (medium soft, warm purple tinted), `Enth_Highlight` (small firm, warm cream tinted), `Enth_Detail` (tiny hard, 100% opacity for fine lines), `Enth_WoodGrain` (elongated brush tip for painting wood direction), `Enth_StoneNoise` (textured round brush for stone surface variation), `Enth_CircuitLine` (1px hard for tech lines), `Enth_SoftGlow` (large very soft for emission falloff). Export the preset bundle for easy installation.
**Acceptance Criteria:**
- At least 8 brush presets exist with names and specific settings documented
- Presets are exported as an installable brush bundle file
- Each preset has a one-line description of its intended use case

### Task 03.16: Create Texture QA Verification Checklist
**Status:** DONE
**Description:** Build a texture quality assurance checklist that every texture set must pass before being committed. Checks include: (1) Resolution matches asset tier (512/1024/2048), (2) Image is power-of-two dimensions, (3) No visible UV seams in 3D viewport, (4) Albedo has proper value range (no pure black #000000, no pure white #FFFFFF — darkest should be ~#1A1A1A, lightest ~#F0F0F0), (5) Normal map is normalized (blue channel dominant), (6) Emission map is black except on intentional glow areas, (7) Roughness map is within 0.6-0.95 range, (8) All maps share the same UV layout, (9) Textures display correctly at gameplay camera distance (not too noisy, not too blurry).
**Acceptance Criteria:**
- QA checklist has at least 9 verification items with pass/fail criteria
- Value range limits prevent pure black/white which cause banding in stylized rendering
- The "gameplay distance" check ensures textures look good where players actually see them

### Task 03.17: Build Texture Painting Reference Time Estimates
**Status:** DONE
**Description:** Document expected time allocations for texturing each asset type to help with sprint planning. Small prop (512x512): 1-2 hours total (30min UV, 30min base/shadow/highlight, 30min detail, 15min maps). Character (1024x1024): 4-6 hours total (1hr UV, 2hr albedo painting, 1hr normal/roughness, 1hr emission/AO, 30min Godot setup). Building (2048x2048): 3-5 hours (1hr UV, 2hr albedo with trim sheet, 1hr maps, 30min Godot setup). These estimates assume the artist is familiar with the pipeline and tools.
**Acceptance Criteria:**
- Time estimates cover props, characters, enemies, buildings, and VFX textures
- Each estimate is broken down by pipeline stage (UV, painting, maps, Godot setup)
- Estimates are realistic for an experienced artist and note the learning curve for newcomers

### Task 03.18: Create Side-by-Side Texture Comparison Test
**Status:** DONE
**Description:** Build a Godot test scene (`scenes/test/TextureComparison.tscn`) that displays the same mesh (a standardized test sphere and a test cube) with different texture treatments side by side. Include: (1) Albedo only (flat look), (2) Albedo + Normal (adds depth), (3) Albedo + Normal + Roughness (adds material feel), (4) Full stack with emission and AO (final look). This scene visually demonstrates why each map layer matters and serves as a teaching tool for understanding the texture pipeline's impact on final visuals.
**Acceptance Criteria:**
- Test scene shows 4 material complexity levels on identical geometry side by side
- Visual improvement from each added map layer is obvious and demonstrable
- Scene includes labels (3D text or UI overlay) identifying each material configuration

### Task 03.19: Document Texture Iteration Workflow
**Status:** DONE
**Description:** Write a guide for the iterative texture refinement process. First pass: rough blocking with base colors only, import to Godot, check in-game at camera distance. Second pass: add shadows and highlights, re-export, check lighting interaction. Third pass: add details and emission, re-export, verify glow levels. Final pass: polish, add roughness/AO maps, final material setup. Document the hot-reload workflow: Godot auto-reimports textures when the source PNG is overwritten, so painting in Krita and saving directly to the Godot project folder enables rapid iteration without manual re-import steps.
**Acceptance Criteria:**
- Four-pass iteration workflow is documented with clear goals for each pass
- Hot-reload workflow (paint in Krita, save to res://, Godot auto-reimports) is explained
- Guide emphasizes checking textures in-game at gameplay distance after every pass

### Task 03.20: Execute Full Texture Workflow on Reference Asset
**Status:** DONE
**Description:** Apply the entire documented texture workflow to a single reference asset (the wooden crate from Epic 01 Task 01.20 or a new barrel prop). Create every map in the stack: hand-painted albedo (base → shadows → highlights → details), baked AO, painted roughness, stylized normal map, and emission map (subtle tech circuit detail on one side). Import all maps into Godot, configure the full StandardMaterial3D, and place the asset in the Style Guide Showcase scene. Take before/after screenshots documenting each painting phase as reference for future texturing work.
**Acceptance Criteria:**
- Reference asset has complete texture set: albedo, normal, roughness, emission, AO
- Phase-by-phase screenshots show the progression from flat color to finished texture
- Asset looks correct in Godot with proper lighting, material response, and no visible UV seams

## Dependencies
- Epic 01 (Art Pipeline Setup) for folder structure, naming conventions, and export presets
- Epic 02 (Visual Style Guide v3) for color palette, roughness standards, and lighting reference

## Notes
- Krita is the recommended painting tool (free, open-source, excellent brush engine) but Photoshop/Clip Studio also work
- All texture source files (.kra/.psd) are saved in `_art_source/textures_source/` with layers intact
- Exported .png files go directly into the Godot project's `assets/textures/` hierarchy
- The hand-painted technique intentionally avoids photo textures; all detail is artist-painted for style consistency
