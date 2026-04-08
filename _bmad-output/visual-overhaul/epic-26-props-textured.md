---
epic: 26
title: "Town Props Textured"
phase: 5 — Town Environment
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 26: Town Props Textured

## Overview

UV unwrap and hand-paint textures for all town prop assets: stone well (stone texture, water surface), benches (wood grain), barrels (wood staves + metal bands), crates (planks + nails), signpost (weathered wood + painted text), lanterns (metal + glass glow), and fences (worn wood posts). Every prop must match the Emberville/Stardew Valley hand-painted stylized aesthetic established in Epic 02 (Style Guide v3) and integrate seamlessly with the town environment built in Epics 23-25.

## Success Criteria

- All 7 prop categories have clean UV layouts with no stretching or overlapping islands
- Hand-painted diffuse textures at 512x512 or 1024x1024 per prop (appropriate to screen size)
- Normal maps baked from high-poly sculpt details where needed (stone, metal bands)
- Emission maps for lantern glass glow and any other light-emitting surfaces
- All props exported as .glb with embedded textures and verified in Godot scene
- Consistent color palette and paint style across all props (warm earth tones, visible brushwork)
- Texture memory budget stays under 32MB total for all town props combined
- Props read clearly at the game's isometric camera distance

---

## Tasks

### Task 26.1: Audit Existing Prop Models and Plan UV Strategy
- **Status:** TODO
- **Description:** Open every existing town prop model in Blender (stone well, benches, barrels, crates, signpost, lanterns, fences) and assess geometry quality. Document which models need topology cleanup before UV unwrapping versus which can proceed directly. Plan the UV texel density target (pixels per meter) based on the isometric camera distance and screen resolution. Decide which props share a texture atlas versus get individual maps. Create a spreadsheet or markdown table listing each prop, its texture resolution, whether it gets its own sheet or shares an atlas, and any geometry fixes needed.
- **Acceptance Criteria:**
  - [ ] All 7 prop categories opened and inspected in Blender
  - [ ] Topology issues documented (n-gons, overlapping verts, missing faces)
  - [ ] Texel density target established (e.g., 10.24 px/cm at 1024x1024)
  - [ ] Atlas vs individual texture decision documented per prop
  - [ ] Task list for geometry fixes created

### Task 26.2: Stone Well — Geometry Cleanup and UV Unwrap
- **Status:** TODO
- **Description:** Clean up the stone well model topology: ensure the circular stone rim has even quad distribution, the bucket mechanism has clean geometry, and the water surface plane sits correctly inside the well opening. Mark seams strategically — hide seams on the bottom edges of stones and along the mortar lines where they will be invisible. Unwrap using Blender's Smart UV Project as a starting point, then manually adjust islands for the stone cylinder body, the rim cap, the wooden crossbar, the rope, the bucket, and the water surface plane. Pack UV islands efficiently with consistent texel density. Verify no stretching using the UV checker texture.
- **Acceptance Criteria:**
  - [ ] Stone well model has clean quad-based topology (no n-gons on visible faces)
  - [ ] UV seams placed along mortar lines and hidden edges
  - [ ] All UV islands unwrapped with no overlapping
  - [ ] Checker texture shows uniform texel density across all parts
  - [ ] UV layout exported as reference image for texture painting

### Task 26.3: Stone Well — Hand-Paint Diffuse Texture
- **Status:** TODO
- **Description:** In Blender's Texture Paint mode (or Krita with UV overlay), hand-paint the stone well diffuse texture at 1024x1024. Paint individual stones with varied warm grays and tans (hex range #8B8B7A to #A09882), add mortar lines in darker gray (#6B6B5E), paint moss/lichen growth in muted greens on the north-facing side, paint the wooden crossbar with brown wood grain (#7B5B3A with #5A3F2A grain lines), paint the rope with braided hemp texture in tan, paint the bucket with dark stained wood. Add subtle color variation per stone to avoid repetition. Include wear marks on the rim where hands would rest.
- **Acceptance Criteria:**
  - [ ] Each stone has individual color variation (minimum 4 distinct stone colors)
  - [ ] Mortar lines are consistently painted between all stones
  - [ ] Moss/lichen present on 20-30% of stone surface, concentrated on one side
  - [ ] Wood grain visible on crossbar and bucket at texture resolution
  - [ ] Rope has braided texture appearance
  - [ ] Wear marks visible on the well rim
  - [ ] Overall palette matches the warm earth-tone style guide

### Task 26.4: Stone Well — Water Surface Material and Normal Map
- **Status:** TODO
- **Description:** Create the water surface material for inside the well. Bake a normal map from a high-poly sculpted version of the stone well to capture stone surface detail (chisel marks, rounded edges, surface roughness). For the water plane, create a separate material with a dark blue-green base color (#1A3A4A), slight transparency, and a tiling normal map that will be animated in Godot's shader. Bake ambient occlusion into the diffuse texture to add depth in the mortar crevices and under the rim overhang. Export the normal map at matching resolution (1024x1024).
- **Acceptance Criteria:**
  - [ ] Normal map baked from high-poly sculpt captures stone detail
  - [ ] Water surface has separate material slot with appropriate base color
  - [ ] Water normal map is tileable for runtime animation
  - [ ] AO baked into diffuse adds depth to crevices
  - [ ] Normal map has no baking artifacts (no ray misses, proper cage distance)

### Task 26.5: Bench — UV Unwrap and Hand-Paint Texture
- **Status:** TODO
- **Description:** UV unwrap the town bench model. Place seams along the bottom edges of planks and the inside faces of leg supports. Unwrap at 512x512 (bench is a smaller prop). Hand-paint the diffuse texture with warm brown wood planks (#8B6F47 base), visible wood grain running lengthwise along each plank, slightly different tones per plank to suggest different wood pieces, darker knot holes on 2-3 planks, worn/lighter areas on the sitting surface where the finish has worn away, and metal bolt heads at joints in dark iron (#3A3A3A). Add subtle green algae staining on the bottom legs to ground the bench visually.
- **Acceptance Criteria:**
  - [ ] Clean UV layout at 512x512 with no stretching
  - [ ] Each plank has unique wood grain direction and color variation
  - [ ] Knot holes present on 2-3 planks
  - [ ] Sitting surface shows wear (lighter, smoother-looking paint strokes)
  - [ ] Metal bolt heads visible at joints
  - [ ] Bottom legs have algae/dirt staining for grounding
  - [ ] Reads clearly at isometric camera distance

### Task 26.6: Barrel — UV Unwrap and Hand-Paint Texture
- **Status:** TODO
- **Description:** UV unwrap the barrel model, placing seams along the vertical stave edges (where wood joins) and along the top/bottom rims. Use 512x512 resolution. Hand-paint individual wood staves with warm oak tones (#A0784A base), each stave slightly different in shade to suggest separate pieces of wood. Paint the metal bands with a dark iron color (#4A4A4A) with subtle rust spots (#8B4513) where water would collect. Add wood grain running vertically on each stave. Paint the barrel lid with concentric circle grain pattern. Include a branded maker's mark or burnt symbol on one stave. Add wear and scuff marks around the bottom where the barrel contacts the ground.
- **Acceptance Criteria:**
  - [ ] Each stave has distinct color and grain variation
  - [ ] Metal bands show iron base color with rust accumulation spots
  - [ ] Barrel lid has visible concentric wood grain
  - [ ] Maker's mark or brand visible on one stave
  - [ ] Bottom edge shows ground contact wear
  - [ ] UV layout efficiently packed with consistent texel density

### Task 26.7: Crate — UV Unwrap and Hand-Paint Texture
- **Status:** TODO
- **Description:** UV unwrap the crate model at 512x512. Place seams along internal edges where planks meet. Hand-paint rough-sawn lumber planks in pale yellow-brown (#C4A E6A base) with visible saw marks as horizontal texture lines. Paint nail heads at each plank intersection — small dark circles with a lighter highlight dot for the rounded head. Add knot holes, splits, and cracks in 2-3 planks to suggest wear. Paint darker shadows in the gaps between planks. Include a stenciled shipping label or arrow symbol on one face to add character. Vary the plank widths in the texture to avoid a repetitive grid look.
- **Acceptance Criteria:**
  - [ ] Plank textures show visible saw marks and rough surface
  - [ ] Nail heads visible at every plank intersection
  - [ ] 2-3 planks have knot holes or splits
  - [ ] Gaps between planks have painted shadow depth
  - [ ] At least one face has a stenciled marking
  - [ ] Plank widths vary across the crate surface
  - [ ] Texture reads as rough construction lumber, not smooth furniture

### Task 26.8: Signpost — UV Unwrap and Hand-Paint Texture
- **Status:** TODO
- **Description:** UV unwrap the signpost model at 512x512. The signpost consists of a vertical post and one or more directional arrow boards. Place seams on the back face of the post and boards. Hand-paint the vertical post with heavily weathered gray-brown wood (#7A6B5A) showing deep grain, rain-streak discoloration running vertically, and lichen at the base. Paint the arrow boards with a base coat of faded paint (muted blue #5A7A8A or green #5A7A5A) over the wood, with paint chipping at edges to reveal wood underneath. Letter the direction text in cream/white (#F0E8D0) with slightly imperfect hand-painted lettering. Add a carved notch or rope lashing where boards attach to the post.
- **Acceptance Criteria:**
  - [ ] Post shows heavy weathering with rain streaks and deep grain
  - [ ] Arrow boards have layered paint-over-wood appearance
  - [ ] Paint chipping reveals wood at board edges and corners
  - [ ] Text is legible but has hand-painted imperfections
  - [ ] Base of post has lichen/moss growth
  - [ ] Attachment points show carved notches or rope lashing detail
  - [ ] Weathering increases from top to bottom (rain accumulation)

### Task 26.9: Lantern — UV Unwrap and Hand-Paint Texture
- **Status:** TODO
- **Description:** UV unwrap the lantern model at 512x512. The lantern has a metal frame, glass panels, a top cap/hook, and an internal light source. Place seams along the metal frame edges. Hand-paint the metal frame in dark wrought iron (#3A3A3A) with subtle forge-scale texture and rust in the joints (#6B3A1A). Paint the glass panels with a warm amber tint (#FFD080 at 50% opacity) to suggest the glow even in the texture. Paint the top cap with a verdigris patina where rain collects (#4A7A5A). The hook should show polished wear where hands grip it. Create a separate emission map where the glass panels are white/yellow (#FFDD88) and everything else is black, to drive the in-engine glow.
- **Acceptance Criteria:**
  - [ ] Metal frame has forge-scale texture and joint rust
  - [ ] Glass panels have warm amber tint in diffuse
  - [ ] Emission map isolates glass panels for engine glow
  - [ ] Top cap shows verdigris patina accumulation
  - [ ] Hook shows polished wear marks
  - [ ] Lantern reads as a warm light source even in unlit preview

### Task 26.10: Fence Sections — UV Unwrap and Hand-Paint Texture
- **Status:** TODO
- **Description:** UV unwrap all fence section variants (straight, corner post, gate) at 512x512 shared atlas. Place seams on the bottom and back faces of posts and rails. Hand-paint fence posts with weathered gray wood (#8A8A7A) showing vertical grain and splitting along the grain at the top where rain enters. Paint horizontal rails with slightly newer brown wood (#7A6A5A) to suggest replacement rails. Add nail rust stains running vertically down from each nail. Paint lichen on the north-facing side of posts. Vary the post heights slightly in the texture (darker top = shorter post illusion) to avoid a too-uniform look. Gate posts should be slightly thicker with a more worn, darker appearance.
- **Acceptance Criteria:**
  - [ ] All fence variants share a single 512x512 atlas
  - [ ] Posts show grain splitting at the tops
  - [ ] Rails are visually newer/different color than posts
  - [ ] Nail rust stains visible running down from attachment points
  - [ ] Lichen present on post faces
  - [ ] Gate posts visually distinct (thicker, darker, more worn)
  - [ ] Fence reads as aged but maintained at camera distance

### Task 26.11: Create Shared Town Props Texture Atlas
- **Status:** TODO
- **Description:** For smaller props that don't warrant individual 512x512 textures (e.g., small decorative items, flower pots, stepping stones, hitching posts), create a shared 1024x1024 texture atlas. Lay out UV islands for all small props on a single sheet with padding between islands (minimum 4px at 1024 resolution) to prevent mip-map bleeding. Paint all small props in this atlas with consistent style and color palette. Ensure each prop's UV island has enough resolution to show the key surface details at the isometric camera distance. Document which props use this atlas for future reference.
- **Acceptance Criteria:**
  - [ ] Atlas contains all small decorative town props
  - [ ] Minimum 4px padding between all UV islands
  - [ ] All props painted in consistent hand-painted style
  - [ ] No mip-map bleeding visible at any LOD level
  - [ ] Atlas documented with prop-to-island mapping

### Task 26.12: Bake Normal Maps for All Metal and Stone Props
- **Status:** TODO
- **Description:** For props with hard-surface detail that benefits from normal mapping (stone well, lantern metal frame, barrel metal bands, any stone props), create high-poly sculpted versions in Blender with surface detail: chisel marks on stone, hammered texture on metal, rivet heads, dents. Bake normal maps from high-poly to low-poly for each prop. Use a cage mesh slightly offset from the low-poly to prevent ray intersection issues. Verify normal maps in Blender's material preview with a directional light to check for artifacts. Export normal maps at matching resolution to their diffuse textures.
- **Acceptance Criteria:**
  - [ ] High-poly versions sculpted for stone well, lantern, barrel bands
  - [ ] Normal maps baked with proper cage distance (no ray miss artifacts)
  - [ ] Normal maps show surface detail: chisel marks, hammer texture, dents
  - [ ] Normal maps verified under directional light in Blender preview
  - [ ] All normal maps exported at matching diffuse resolution

### Task 26.13: Create Ambient Occlusion Overlays
- **Status:** TODO
- **Description:** Bake ambient occlusion maps for all town props and multiply them into the diffuse textures to add depth and grounding. AO should darken crevices (between barrel staves, in well mortar lines, under bench seats, at fence post bases, inside lantern frames). Use Blender's bake AO with appropriate ray distance settings for each prop's scale. After baking, open each diffuse texture and multiply the AO layer at 40-60% opacity so the effect is subtle but adds depth without making the textures look muddy. Re-export the combined diffuse textures.
- **Acceptance Criteria:**
  - [ ] AO baked for all 7 prop categories
  - [ ] AO multiplied into diffuse at 40-60% opacity (not overpowering)
  - [ ] Crevices and contact points visually darkened
  - [ ] Props appear grounded and three-dimensional
  - [ ] No AO baking artifacts (splotches, wrong ray distance)

### Task 26.14: Material Setup in Blender for Export
- **Status:** TODO
- **Description:** Set up proper Blender materials for every prop for .glb export. Each prop needs a Principled BSDF node with: diffuse texture in Base Color, normal map in Normal (with Normal Map node), emission map in Emission (for lanterns), roughness set to 0.7-0.9 for natural materials (wood, stone), 0.3-0.5 for metal. Ensure texture paths are relative and images are packed into the .blend file. Set up material slots correctly for props with multiple materials (e.g., stone well has stone, wood, rope, water as separate materials). Name all materials with the convention `prop_name_material` (e.g., `well_stone`, `well_wood`).
- **Acceptance Criteria:**
  - [ ] Every prop has Principled BSDF with correct texture connections
  - [ ] Roughness values appropriate per surface type
  - [ ] Lantern emission map connected to Emission channel
  - [ ] Material naming follows `prop_name_material` convention
  - [ ] All textures packed into .blend files
  - [ ] Multi-material props have correctly assigned material slots

### Task 26.15: Export All Props as .glb Files
- **Status:** TODO
- **Description:** Export each town prop as a .glb file with embedded textures for Godot import. Configure export settings: apply modifiers, triangulate faces, include normals, include UVs, embed textures as binary, Y-up coordinate system for Godot compatibility. Export each prop category to the correct project directory (`res://assets/models/town/props/`). Verify file sizes are reasonable (under 2MB per prop including textures). Run a quick visual check in Blender's glb import to verify the round-trip looks correct before moving to Godot.
- **Acceptance Criteria:**
  - [ ] All props exported as individual .glb files
  - [ ] Textures embedded in .glb (not external references)
  - [ ] Correct coordinate system (Y-up for Godot)
  - [ ] File sizes under 2MB per prop
  - [ ] Round-trip import in Blender matches original appearance
  - [ ] Files placed in correct project directory

### Task 26.16: Import Props into Godot and Verify Materials
- **Status:** TODO
- **Description:** Import all .glb prop files into Godot and verify that materials, textures, and normal maps transferred correctly. Check each prop in the Godot 3D viewport with the scene's environment lighting. Verify that: diffuse textures appear correct (no color space issues — ensure sRGB for diffuse, Linear for normal maps), normal maps are oriented correctly (no inverted channels between Blender and Godot), emission maps drive the lantern glow, roughness values match expectations. Fix any import issues by adjusting Godot's import settings or re-exporting from Blender.
- **Acceptance Criteria:**
  - [ ] All props visible in Godot 3D viewport
  - [ ] Diffuse textures show correct colors (sRGB color space)
  - [ ] Normal maps oriented correctly (no inverted bumps)
  - [ ] Lantern emission visible in Godot
  - [ ] Roughness values produce expected surface appearance
  - [ ] No import warnings or errors in Godot console

### Task 26.17: Place Textured Props in Town Scene
- **Status:** TODO
- **Description:** Replace all existing primitive/untextured prop instances in the Town.tscn scene with the new textured versions. Maintain the same positions, rotations, and scales as the existing props (or adjust slightly if the new models have different proportions). Ensure props are on the correct collision layers, have their existing collision shapes updated if geometry changed, and that any script references (interaction triggers, etc.) still connect properly. Place multiple instances of generic props (barrels, crates, fences) with slight rotation variations to avoid a copy-pasted look.
- **Acceptance Criteria:**
  - [ ] All primitive prop instances replaced with textured versions
  - [ ] Props maintain correct position/rotation in the scene
  - [ ] Collision shapes updated for any geometry changes
  - [ ] Script references and interaction triggers still function
  - [ ] Multiple instances have rotation variation (no identical copies)
  - [ ] Scene runs without errors

### Task 26.18: Texture Memory and Performance Audit
- **Status:** TODO
- **Description:** Run a texture memory audit for all town prop textures. In Godot, check the import settings for each texture: enable mipmaps, set appropriate compression (VRAM Compressed for diffuse and normal maps, Lossless for emission maps with sharp edges). Calculate total VRAM usage for all prop textures at their current resolutions. If the total exceeds the 32MB budget, identify candidates for resolution reduction (props that are small on screen can drop from 512 to 256). Check rendering performance with all props visible — verify no frame drops below 60fps at 1080p.
- **Acceptance Criteria:**
  - [ ] All textures have mipmaps enabled
  - [ ] Compression set appropriately per texture type
  - [ ] Total prop texture VRAM usage documented and under 32MB
  - [ ] No frame rate drops below 60fps with all props visible
  - [ ] Oversized textures identified and downscaled if needed

### Task 26.19: Visual Consistency Pass
- **Status:** TODO
- **Description:** With all textured props placed in the town scene, do a full visual consistency review. Check that: all props use the same color temperature and saturation level (no prop looks out of place), the level of detail/paint quality is consistent (no prop is noticeably higher or lower quality than others), props match the terrain, building, and vegetation textures from Epics 23-25, shadow and lighting interaction looks correct on all surfaces, no texture seams are visible from the isometric camera angle. Take comparison screenshots from multiple camera angles and note any inconsistencies to fix.
- **Acceptance Criteria:**
  - [ ] All props match the style guide color palette
  - [ ] Paint quality is consistent across all props
  - [ ] Props integrate visually with terrain, buildings, and vegetation
  - [ ] No visible texture seams from isometric camera
  - [ ] Comparison screenshots taken and reviewed
  - [ ] All noted inconsistencies corrected

### Task 26.20: Before/After Documentation and Final Screenshots
- **Status:** TODO
- **Description:** Capture final before/after comparison screenshots for the epic completion record. Take "before" screenshots using the old primitive/flat-color props (from git history or backup) and "after" screenshots of the textured props in the same camera positions. Capture: overview shot of the full town, close-up of the stone well, grouping of barrels and crates, fence line, lit lanterns at dusk lighting, signpost detail, and bench. Save screenshots to `_bmad-output/visual-overhaul/screenshots/epic-26/`. Update the MASTER-PLAN.md with completion status.
- **Acceptance Criteria:**
  - [ ] Before/after pairs for at least 7 shots (one per prop category)
  - [ ] Full town overview before/after
  - [ ] Screenshots saved to correct directory
  - [ ] MASTER-PLAN.md updated with Epic 26 completion status
  - [ ] Visual quality improvement is clearly visible in comparisons

---

## Dependencies

- **Epic 02** (Style Guide v3) — Color palette and style reference
- **Epic 03** (Texture Workflow) — UV standards and texture resolution rules
- **Epic 23** (Town Terrain) — Ground textures for visual consistency
- **Epic 24** (Buildings Textured) — Building textures for palette matching
- **Epic 25** (Vegetation System) — Vegetation for environment context

## Notes

- Prioritize the stone well and lanterns first — they are centerpiece props that set the visual bar for everything else
- Keep wood textures warm and stone textures cool-neutral to create natural contrast
- Test all props at the actual isometric camera distance regularly — detail that is invisible at game zoom is wasted texture budget
- When in doubt, paint LESS detail with MORE color variation — this reads better at distance than detailed-but-flat textures
