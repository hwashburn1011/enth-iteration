---
epic: 13
title: "RogueProcess Full Rebuild"
phase: 3
status: TODO
priority: high
estimated_hours: 70
dependencies: [1, 2, 3, 4]
---

# Epic 13: RogueProcess Full Rebuild

## Overview

Complete visual rebuild of the RogueProcess enemy -- an elite-tier geometric entity that embodies a rogue system process gone haywire. The RogueProcess is a hard-surface angular creature with floating shield plates that orbits its core body, making it a visually complex and mechanically distinct enemy. This epic covers the full art pipeline from concept through Godot integration: hard-surface modeling of the geometric core, floating shield plate creation, hand-painted metallic blue textures with circuit trace patterns, constraint-based rig for floating parts, full animation set including hover, charge attack, and shield break, and in-engine hookup.

**Visual Identity:** A central dodecahedron-like core body with glowing seams between angular plates. Four floating shield segments orbit the core in a loose ring, each a curved triangular plate with circuit-board etch patterns. The whole assembly hovers above the ground with a faint energy field beneath it. Blue/cyan color scheme with white energy accents. The creature is angular where the GlitchBug is spiky and the MemoryLeak is blobby -- clear visual distinction through shape language.

**Quality Target:** Chunky stylized 3D with hand-painted textures. Hard-surface modeling with beveled edges and painted metal/energy materials. Readable as "dangerous floating geometric thing" at isometric camera distance.

## Success Criteria

- [ ] RogueProcess model features a geometric core with 4 floating shield plates
- [ ] Hand-painted diffuse texture with metallic blue finish and circuit trace details
- [ ] Constraint-based rig for floating/orbiting shield plates and hovering core
- [ ] Full animation set: hover idle, patrol drift, charge attack, shield break, death shatter
- [ ] Exported as .glb and integrated in Godot replacing the current placeholder
- [ ] Silhouette is distinctly geometric/angular compared to other enemies
- [ ] Polycount under 3,000 tris (core + 4 shields); single 512x512 texture atlas
- [ ] Shield break mechanic is visually clear and satisfying

---

## Tasks

### Task 13.1: Reference Sheet and Geometric Design Language
**Status:** TODO
**Description:** Create a concept reference sheet for the RogueProcess. Gather references from geometric abstract art, sci-fi sentinel/drone designs, and polyhedra diagrams. Design the core body: a modified dodecahedron with beveled edges and slightly concave faces, approximately 0.5m diameter. Design the shield plates: curved triangular shards, each roughly 0.3m x 0.4m, that float in a ring 0.2m away from the core surface. Sketch the assembly from front, side, top, and isometric views. Define the hover height (0.3m above ground). Annotate color zones: deep cobalt blue (#1A3A6C) for plate surfaces, bright cyan (#00AAFF) for seam energy, white (#EEFFFF) for core glow, gunmetal grey (#3A3A4C) for shield plate backs. Include a silhouette comparison against GlitchBug and MemoryLeak to confirm distinct shape language.
**Acceptance Criteria:**
- 4+ view reference sheet with dimensions annotated
- Core body geometric design finalized (modified dodecahedron)
- Shield plate shape and floating arrangement defined
- Color palette with hex values documented
- Silhouette comparison confirms distinctness from other enemies

### Task 13.2: Hard-Surface Model -- Core Body
**Status:** TODO
**Description:** Model the RogueProcess core in Blender using hard-surface techniques (not sculpting). Start with an icosphere or dodecahedron primitive. Apply a Bevel modifier to all edges (0.02m width, 2 segments) for the stylized chunky edge look. Use Inset Faces on each polygonal face to create recessed panel lines (0.01m inset depth) -- these seams will glow with energy in the texture. Add Loop Cuts to create additional geometric detail: each face should have a subtle raised center plate with a recessed border. The overall shape should read as a technological artifact, not an organic form. Apply smooth shading with Auto Smooth at 30 degrees so flat faces stay flat but bevels smooth. Keep the mesh clean for easy UV work -- no n-gons, no internal faces.
**Acceptance Criteria:**
- Modified dodecahedron shape with beveled edges (chunky, not sharp)
- Recessed panel line seams on every face
- Raised center plates with recessed borders on faces
- Clean quad topology with no n-gons or internal geometry
- Auto Smooth at 30 degrees applied
- Approximately 600-800 tris for the core body alone

### Task 13.3: Hard-Surface Model -- Shield Plates
**Status:** TODO
**Description:** Model the four floating shield plates as separate mesh objects. Each shield is a curved triangular plate: start with a triangle, extrude for thickness (0.015m), then apply a slight spherical curve (Proportional Edit or lattice deform) so the concave side faces the core. Bevel all edges (0.005m, 1 segment) for the chunky stylized look. Add surface detail: shallow etched circuit trace grooves on the outer face (use Boolean or knife tool to create recessed line patterns following geometric paths). Each shield plate should have a central circular "power node" -- a small extruded disc on the outer face. Create one shield plate, then duplicate and rotate for the 4 cardinal positions. Name them `Shield_N`, `Shield_E`, `Shield_S`, `Shield_W`.
**Acceptance Criteria:**
- 4 separate shield plate mesh objects
- Curved triangular shape with spherical concavity toward core
- Beveled edges matching core body style
- Circuit trace grooves etched on outer face
- Central power node disc on each plate
- Each plate approximately 150-200 tris (600-800 total)
- Named consistently (Shield_N/E/S/W)

### Task 13.4: Model Assembly and Proportional Refinement
**Status:** TODO
**Description:** Assemble the core body and four shield plates into their final arrangement. Position shield plates in a ring around the core at 0.2m distance, evenly spaced at 90-degree intervals. Each shield should be slightly tilted (5-10 degrees) to break the perfect symmetry and add visual interest. Verify proportions at game camera distance by setting up a camera at the expected isometric angle and checking readability: the core should be clearly visible, shields should be readable as separate floating elements, and the overall silhouette should be compact but complex. Add a simple disc mesh beneath the assembly (0.4m diameter, transparent in-game) as a ground shadow placeholder. Adjust sizes if anything reads as too small or too cluttered at camera distance.
**Acceptance Criteria:**
- Shield plates positioned at 0.2m radius, 90-degree spacing
- Slight tilt variation on each shield for asymmetry
- Assembly reads clearly at isometric camera distance
- Core visible between shield gaps
- Shadow disc placeholder added beneath
- Total assembly polycount within 3,000 tri budget

### Task 13.5: UV Unwrap -- Core and Shields
**Status:** TODO
**Description:** UV unwrap all mesh objects for a shared 512x512 texture atlas. For the core body: unwrap each polygonal face as its own small island (they share similar texture detail), or use Smart UV Project and manually adjust. Place seams along the recessed panel lines (natural visual breaks). For shield plates: unwrap outer face as the main island (most detail), inner face and edges as secondary islands. Since all 4 shields share the same texture, overlap their UVs (stack identical islands) to maximize texture resolution. Allocate UV space: 50% to core body (most visible, most detail), 40% to one shield plate (shared by all 4), 10% to edges/backs. Check stretching on beveled edges.
**Acceptance Criteria:**
- All objects share a single UV space for one texture atlas
- Core body seams along panel lines (hidden in visual breaks)
- 4 shield plate UVs stacked/overlapped for texture reuse
- UV space allocation: 50% core, 40% shield face, 10% misc
- Minimal stretching on visible surfaces
- 4px padding between islands

### Task 13.6: Bake Normal Map -- Panel Detail Transfer
**Status:** TODO
**Description:** If any high-poly detail was added (additional circuit traces, finer bevels), bake a normal map from high to low poly. For the RogueProcess, the normal map primarily needs to capture: fine bevel smoothing (supplementing the auto-smooth), circuit trace groove depth on shields, and panel line depth on the core. If the geometric detail is already present in the low-poly mesh (which is viable for hard-surface), the normal map can be minimal -- just bake ambient occlusion into a cavity map to guide texture painting. Either way, produce a 512x512 normal map (`rogueprocess_normal.png`) that enhances the geometric panel detail under lighting.
**Acceptance Criteria:**
- 512x512 normal map enhancing geometric detail
- Bevel smoothing captured if not handled by auto-smooth
- Circuit trace grooves have depth in normal map
- Panel line seams have visible depth
- No artifacts on floating geometry (shields baked separately if needed)
- Saved as `rogueprocess_normal.png`

### Task 13.7: Hand-Paint Diffuse -- Metallic Blue Plates
**Status:** TODO
**Description:** Paint the diffuse texture base layer. Core body faces: deep cobalt blue (#1A3A6C) with subtle warm-to-cool gradient (slightly warmer blue on light-facing surfaces, cooler/darker on shadow sides). Use a slightly textured brush (not perfectly flat fill) to add hand-painted character -- subtle brush stroke variation, tiny color shifts between adjacent panels to suggest they were forged separately. Shield plate outer faces: slightly lighter blue (#2A4A7C) to differentiate from core. Shield plate inner faces (concave side): dark gunmetal (#3A3A4C). All beveled edges: paint a subtle edge highlight (lighter blue/silver) to make geometry read clearly. Power nodes on shields: white-blue (#CCDDFF) center.
**Acceptance Criteria:**
- Core body: deep cobalt blue with subtle gradient variation
- Hand-painted texture quality (not flat fill -- visible brush character)
- Shield plates slightly lighter than core for differentiation
- Edge highlights on all bevels for geometric readability
- Power nodes bright white-blue
- Inner shield faces dark gunmetal
- No raw/unpainted UV areas

### Task 13.8: Hand-Paint Diffuse -- Circuit Traces and Tech Detail
**Status:** TODO
**Description:** Paint circuit trace patterns over the base blue. On shield plates: paint thin circuit lines (#4488CC lighter blue) following geometric paths that connect the power node to the plate edges. Lines should be 2-3px wide on the texture, with right-angle turns and T-junctions mimicking PCB traces. Add small component dots at junctions. On the core body: paint panel-interior tech detail -- each face gets subtle geometric patterns (concentric rings, crosshair marks, or grid fragments) painted in slightly lighter blue to suggest internal technology. Add tiny text fragments ("PID:0x3F7A", "ROGUE", "PRIORITY:MAX") in very small, slightly transparent lettering on 2-3 panels. These details reward close inspection.
**Acceptance Criteria:**
- Circuit traces on shields connect power node to edges with PCB-style routing
- Trace lines are clean geometric paths with right-angle turns
- Junction dots/components at circuit intersections
- Core panels have interior tech patterns (concentric rings, grids)
- 2-3 panels have tiny readable text fragments
- All detail uses lighter blue, maintaining cohesive color scheme
- Saved as `rogueprocess_diffuse.png`

### Task 13.9: Emission Map -- Energy Seams and Power Nodes
**Status:** TODO
**Description:** Create the 512x512 emission map. The RogueProcess should glow along its structural seams to look powered and dangerous. Core body panel seams: bright cyan (#00AAFF) emission at full intensity along every recessed seam line -- this makes the geometric structure pop dramatically. Shield plate power nodes: white (#EEFFFF) emission at full intensity. Circuit traces on shields: cyan emission at ~40% intensity (visible glow following the circuit paths). Core face interiors: very subtle cyan emission at ~5% (barely there ambient tech glow). Shield inner faces: no emission (dark). The emission pattern should clearly communicate "this thing is energized" and make the seam structure the dominant visual feature.
**Acceptance Criteria:**
- Core seam lines emit bright cyan at full intensity
- Shield power nodes emit white at full intensity
- Circuit traces emit at ~40% intensity
- Core face interiors at ~5% subtle glow
- Emission makes geometric structure dramatically readable
- Saved as `rogueprocess_emission.png`

### Task 13.10: Material Setup and Lighting Test
**Status:** TODO
**Description:** Configure the Blender material for Godot compatibility. Set Base Color to the diffuse texture, Normal to the normal map (Non-Color), Emission to the emission map with energy multiplier 2.0 (higher than the MemoryLeak because this enemy should look more energized). Roughness 0.4 (metallic surfaces are somewhat reflective but hand-painted style is not mirror-sharp). Metallic 0.1 (subtle metallic hint without full PBR metal). Test under the game's approximate lighting setup: directional light from above-left, ambient fill. The core seam glow should be the primary visual draw. Shield plates should look like separate floating objects. Export a test .glb and verify material transfer to Godot.
**Acceptance Criteria:**
- Material properties: roughness 0.4, metallic 0.1, emission energy 2.0
- Core seam glow is the dominant visual feature under test lighting
- Shield plates read as separate objects floating around core
- Material transfers correctly to Godot (no channel swaps)
- Test .glb imports clean with all texture maps

### Task 13.11: Rig -- Floating Assembly Constraints
**Status:** TODO
**Description:** Create the armature for the RogueProcess. This rig is fundamentally different from the organic rigs (GlitchBug, MemoryLeak) because it uses constraints for floating/orbiting behavior. Bone hierarchy: `root` at the ground shadow position, `hover_bone` (translates the entire assembly up 0.3m, used for bob animation), `core_bone` (rotates the core body), `shield_N/E/S/W_orbit` (4 bones that orbit around the core -- these will be keyframed or driven to rotate around the vertical axis), `shield_N/E/S/W_local` (child of orbit bone, controls individual shield tilt/offset). This dual-bone-per-shield setup allows shields to orbit while also having independent motion. Add `core_pulse` bone (scales the core for breathing effect).
**Acceptance Criteria:**
- Root bone at ground level for proper placement
- Hover bone provides 0.3m vertical offset
- Core bone rotates the central body
- 4 orbit + 4 local bones per shield (8 shield bones total)
- Core pulse bone for scale breathing
- ~14 bones total with clean parent hierarchy
- Orbit bones positioned for circular motion around core

### Task 13.12: Weight Painting -- Rigid Binding
**Status:** TODO
**Description:** Weight paint the RogueProcess mesh. Unlike organic models, this is mostly rigid binding: the core body mesh is weighted 100% to `core_bone` (no soft deformation needed). Each shield plate mesh is weighted 100% to its respective `shield_X_local` bone. The shadow disc is weighted to `root`. Since these are hard-surface objects, there should be zero weight blending between bones -- each vertex belongs to exactly one bone at 1.0 weight. Verify by entering Pose Mode and rotating each bone: only the intended mesh should move, with no vertex pulling from adjacent objects. The `core_pulse` bone should scale the core mesh uniformly (weight the core to both core_bone for rotation and core_pulse for scale using a constraint or dual weight approach).
**Acceptance Criteria:**
- Core mesh: 100% weight to core_bone
- Each shield plate: 100% weight to its local bone
- Shadow disc: 100% weight to root
- Zero blending between bones (rigid hard-surface binding)
- Rotation test shows no unintended vertex movement
- Core pulse scale effect works independently of rotation

### Task 13.13: Animation -- Hover Idle
**Status:** TODO
**Description:** Create a 3-second looping hover idle animation (72 frames at 24fps). Primary motion: gentle vertical bob on hover_bone (0.02m amplitude sinusoidal, one full cycle over 72 frames). Shield orbit: all 4 shield orbit bones rotate slowly around the vertical axis (complete one full revolution every 6 seconds -- so 180 degrees over this 72-frame cycle). Each shield should orbit at a slightly different speed (multiply base by 0.9, 0.95, 1.0, 1.05) to prevent mechanical lock-step. Individual shield tilt: each local bone oscillates 3-5 degrees on a unique timing to add floating instability. Core rotation: very slow rotation on the vertical axis (10 degrees per cycle) in the opposite direction of shield orbit. Core pulse: subtle 3% scale oscillation on core_pulse bone.
**Acceptance Criteria:**
- 72-frame seamless loop
- Vertical bob on hover bone is smooth and gentle
- Shields orbit at slightly different speeds (not lock-step)
- Individual shield tilt adds floating instability
- Core counter-rotates slowly against shield orbit direction
- Core pulse creates subtle breathing/power oscillation
- Overall reads as a hovering technological sentinel

### Task 13.14: Animation -- Patrol Drift
**Status:** TODO
**Description:** Create a 2-second looping patrol movement animation (48 frames at 24fps). The RogueProcess does not walk -- it drifts. The assembly tilts 10-15 degrees in the movement direction (hover_bone tilts forward, causing the whole assembly to lean into movement). Shield orbit speed increases to 1.5x the idle rate (shields spin faster when moving, suggesting increased energy output). Root motion translates ~1.5m per cycle (faster than MemoryLeak, slower than GlitchBug). Add a subtle lateral oscillation (2-3 degree yaw wobble on the hover_bone) to prevent perfectly straight drift. The ground shadow should stretch slightly in the movement direction via scale on the root bone.
**Acceptance Criteria:**
- Assembly tilts into movement direction (10-15 degrees)
- Shield orbit speed increases vs. idle
- ~1.5m root translation per cycle
- Lateral yaw wobble adds organic imperfection
- Shadow stretches in movement direction
- Seamless loop with no pop at cycle boundary

### Task 13.15: Animation -- Charge Attack
**Status:** TODO
**Description:** Create the charge attack animation (1.5 seconds, 36 frames). The RogueProcess charges forward with its shields leading. Phase 1 -- wind-up (frames 1-10): shields stop orbiting and snap to a forward-facing formation (all 4 move to the front hemisphere), core pulls back (hover_bone tilts backward 15 degrees), shield plates angle forward like a battering ram. Energy builds (core_pulse scales up 10%). Phase 2 -- charge (frames 11-20): explosive forward dash (~2m root motion), all shields lead the charge in tight formation, core trails behind. Phase 3 -- recovery (frames 21-36): shields scatter back to their orbit positions (each takes a different path), core re-centers, hover_bone returns to neutral. The wind-up must be telegraphed enough for player reaction.
**Acceptance Criteria:**
- Clear wind-up telegraph (shields snap forward, core pulls back)
- Shield formation shift from orbit to battering-ram configuration
- Explosive forward charge with ~2m root motion
- Shields scatter back to orbit during recovery
- Wind-up phase long enough for player reaction (10 frames / ~0.4s)
- Charge phase feels fast and impactful

### Task 13.16: Animation -- Shield Break
**Status:** TODO
**Description:** Create the shield break animation (1 second, 24 frames). This plays when enough damage destroys one of the shield plates. The targeted shield plate: violent outward explosion (rapid translation 0.5m away from core over 4 frames), spinning wildly (720-degree rotation over the next 8 frames), then freeze in the distant position (it will be hidden/despawned by gameplay code at frame 12). The remaining shields: scatter reaction (each jolts outward 0.1m then returns over 12 frames), orbit speed momentarily disrupted. Core reaction: shudder (rapid 2-3 degree oscillation on core_bone for 12 frames), core_pulse compresses 5% then returns. The overall effect should communicate "a defensive layer was destroyed."
**Acceptance Criteria:**
- Targeted shield explodes outward with violent spin
- Shield hidden/despawnable at frame 12
- Remaining shields scatter-react then recover
- Core shudders from the loss
- Clear visual communication of defensive layer destruction
- Animation works regardless of which shield (N/E/S/W) is targeted

### Task 13.17: Animation -- Death Shatter
**Status:** TODO
**Description:** Create the death animation (2 seconds, 48 frames). The RogueProcess death should feel like a system crash -- sudden and catastrophic. Frames 1-8: all remaining shields stop orbiting, freeze in place, then simultaneously explode outward (each in a different direction, translating 1m+ away). Frames 9-16: core flickers (rapid scale oscillation between 100% and 80% every 2 frames, simulating a power failure). Frames 17-30: core begins to fragment -- rotate wildly on all axes while shrinking (scale from 100% to 50%). Frames 31-40: core collapse -- scale to 10%, all rotation stops. Frames 41-48: hold the collapsed/disappeared state for the shared death VFX to take over. The hover_bone drops the assembly to ground level during frames 17-30 (loss of hover power).
**Acceptance Criteria:**
- Shields explode outward simultaneously in different directions
- Core flickers with power-failure effect
- Wild rotation + shrink simulates fragmentation
- Hover drops to ground (loss of power)
- Final collapsed state held for VFX overlay
- Death feels sudden and catastrophic (system crash aesthetic)

### Task 13.18: Animation Export and NLA Cleanup
**Status:** TODO
**Description:** Prepare all animations for export. In the NLA Editor, verify each action is named correctly: `idle`, `patrol`, `attack_charge`, `shield_break`, `death`. Ensure no animation actions reference deleted bones or have orphan keyframes. For the shield_break animation, create 4 variants (or use a single animation where the game code selects which shield to hide) -- document the approach chosen. Verify animation curves: all should use bezier interpolation. Check bone constraint behavior during export -- Blender constraints do not export to glTF, so any constraint-driven motion must be baked to keyframes (use Bake Action with visual keying). Export as `rogueprocess.glb` with all animations and embedded textures.
**Acceptance Criteria:**
- 5 animations properly named in NLA editor
- All constraint-driven motion baked to keyframes for export
- No orphan keyframes or deleted bone references
- Shield break approach documented (single anim or 4 variants)
- Bezier interpolation on all curves
- Clean .glb export with embedded textures

### Task 13.19: Godot Scene Setup and Combat Integration
**Status:** TODO
**Description:** Build or update the RogueProcess enemy scene in Godot. Import the .glb model. Set up the AnimationTree state machine: idle plays `idle` (looping), patrol plays `patrol` (looping), attack plays `attack_charge` (one-shot, charge hitbox activates at frame 11), shield_break plays `shield_break` (one-shot, triggered by damage threshold), death plays `death` (one-shot, triggers dissolve VFX). Create 4 shield visibility flags that the game code toggles when shields are destroyed. Update collision shapes: main body as a sphere collider, each shield as a separate collider (disabled when destroyed). Configure the charge attack hitbox as a forward-swept area. Integrate with the existing enemy AI: aggro range, leash distance, attack cooldown.
**Acceptance Criteria:**
- New model replaces placeholder in enemy scene
- AnimationTree states properly mapped to all animations
- 4 shield visibility/collision toggles functional
- Charge attack hitbox activates at correct frame
- Shield break triggers at correct damage threshold
- AI behavior integration works with existing scripts

### Task 13.20: In-Game Testing and Balance Verification
**Status:** TODO
**Description:** Full in-game test of the rebuilt RogueProcess. Verify: (1) hover idle looks like a powered sentinel scanning for threats, (2) patrol drift movement speed matches AI pathfinding (no sliding or overshoot), (3) charge attack wind-up is telegraphed enough for player dodge but fast enough to be threatening, (4) shield break visual clearly communicates lost protection to the player, (5) death shatter is dramatic and satisfying, (6) emission glow makes the RogueProcess visible and threatening in dungeon lighting, (7) the enemy is visually distinct from GlitchBug (organic insect) and MemoryLeak (ooze blob) -- the geometric/technological aesthetic is clear, (8) shield collision properly blocks player projectiles when intact. Take before/after screenshots.
**Acceptance Criteria:**
- All animation states function correctly during gameplay
- Charge attack telegraph timing feels fair but dangerous
- Shield mechanics work visually and mechanically
- Emission glow appropriate for dungeon lighting
- Visually distinct from all other enemies at game camera distance
- Shield collision blocks projectiles when intact
- Before/after screenshots captured

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings and naming conventions
- **Epic 2** (Visual Style Guide): Color palette and stylization rules
- **Epic 3** (Texture Workflow): UV standards and texture resolution
- **Epic 4** (Animation Pipeline): Rig standards and bone naming
- **Epic 15** (Enemy Shared VFX): Death dissolution effect
- **Epic 5** (Combat System Fixes): Shield-break mechanic may need combat system support

## Notes

- The floating shield mechanic makes this the most technically complex enemy rig -- constraint baking is essential for clean export
- Shield break animation may need to be handled as 4 separate animations or via code-driven bone visibility -- test both approaches
- The RogueProcess is an elite enemy, so it should look more impressive/complex than the GlitchBug or MemoryLeak
- Consider adding a subtle cyan OmniLight3D to the scene for environmental light casting
- The same base model will be used for RogueProcess variants (Epic 17) with color shifts and additional shields
