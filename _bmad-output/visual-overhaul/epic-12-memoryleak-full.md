---
epic: 12
title: "MemoryLeak Full Rebuild"
phase: 3
status: IN_PROGRESS
priority: high
estimated_hours: 65
dependencies: [1, 2, 3, 4]
---

# Epic 12: MemoryLeak Full Rebuild

## Overview

Complete visual rebuild of the MemoryLeak enemy -- a ranged attacker that embodies corrupted data as a sentient green ooze blob. The MemoryLeak is an amorphous slime creature with pseudopod tendrils that spits corrosive data projectiles at the player from a distance. This epic covers the full art pipeline: high-poly sculpt of the organic blob form, retopology optimized for soft-body-like deformation, UV mapping, hand-painted translucent green slime textures with data corruption patterns, a bone rig that simulates jiggly soft-body motion, full animation set, and Godot integration.

**Visual Identity:** A quivering mound of luminous green gel with darker corruption veins running through its semi-transparent mass. Pseudopod tendrils extend and retract from the main body. Trapped data fragments (tiny glowing text/numbers) are visible suspended inside the translucent body. Two uneven "eye" spots of concentrated brightness serve as a focal point. The creature pulses rhythmically as if breathing.

**Quality Target:** Chunky stylized 3D with hand-painted textures. The translucency effect is achieved through texture painting (not real-time subsurface scattering) to keep performance budget. Readable as "dangerous ooze" at isometric camera distance.

## Success Criteria

- [ ] MemoryLeak model is a properly sculpted amorphous blob (not a stretched sphere)
- [ ] Hand-painted diffuse texture with green translucency illusion and data corruption veins
- [ ] Soft-body-like bone rig with jiggle/wobble deformation
- [ ] Full animation set: idle pulse, ooze crawl, spit attack, hurt recoil, death dissolve
- [ ] Exported as .glb and integrated in Godot replacing the current placeholder
- [ ] Silhouette reads as "ooze blob" distinctly from the GlitchBug
- [ ] Polycount under 2,000 tris; single 512x512 texture atlas
- [ ] All animations play correctly through the enemy state machine

---

## Tasks

### Task 12.1: Reference Sheet and Concept Design
**Status:** TODO
**Description:** Collect reference images of stylized slime creatures from games (Dragon Quest slimes, Stardew Valley slimes, Terraria slimes) and real-world translucent organisms (jellyfish, amoebas). Create a concept sketch sheet showing the MemoryLeak from front, side, and isometric views. Define the shape language: the main body is a roughly hemispherical mound (~0.6m tall x 0.8m diameter) that is never perfectly round -- it has organic undulations and asymmetry. Mark pseudopod placement (2-3 primary tendrils emerging from the base perimeter), eye spot positions (two uneven bright spots in the upper-front area), and data fragment inclusions. Annotate the green color palette: deep forest green (#1A5C2A) for the core, bright toxic green (#44DD44) for the surface, neon green (#00FF66) for eye spots and data fragments.
**Acceptance Criteria:**
- Reference sheet with 3+ views and clear silhouette
- Shape language defined: asymmetric hemispherical blob
- Pseudopod tendril placement marked (2-3 locations)
- Color palette annotated with hex values
- Distinct visual identity from GlitchBug confirmed via silhouette comparison

### Task 12.2: High-Poly Sculpt -- Main Blob Body
**Status:** TODO
**Description:** In Blender, start with a UV sphere and sculpt the main blob body. Use Grab brush to break the symmetry -- pull one side slightly higher, create subtle bumps and valleys across the surface to suggest internal pressure. Use Inflate brush to fatten the lower portions where the blob meets the ground, creating a natural "pooling" base. Sculpt 3-4 surface tension ridges (subtle raised lines running from top to base) that suggest the blob is barely holding its shape. The top surface should have a slight dome with a gentle depression (like a water droplet crown). Use Smooth brush liberally -- this creature should feel wet and soft, with no hard edges anywhere. Target 200K-400K polys for sculpt detail.
**Acceptance Criteria:**
- Asymmetric hemispherical blob shape, not a perfect sphere
- Natural "pooling" base where body meets ground plane
- 3-4 surface tension ridges visible
- Gentle top depression suggesting liquid surface behavior
- All surfaces smooth and organic -- zero hard edges
- Saved as `memoryleak_highpoly.blend`

### Task 12.3: High-Poly Sculpt -- Pseudopod Tendrils
**Status:** TODO
**Description:** Sculpt 3 primary pseudopod tendrils emerging from the blob's base perimeter. Each tendril should taper from a thick base (blending seamlessly into the main body) to a thin, slightly bulbous tip. Tendrils vary in length: one long (~0.5m extended), one medium (~0.3m), one short and stubby (~0.15m). Shape them with gentle S-curves to suggest fluid motion frozen in time. The connection point where each tendril meets the body should look like pulled taffy -- stretched but smooth. Add 2-3 small surface bubbles on the main body (raised half-spheres suggesting gas pockets trapped in the gel). These bubbles will catch light and enhance the translucency illusion.
**Acceptance Criteria:**
- 3 pseudopod tendrils with varying lengths and natural taper
- Smooth taffy-pull connection points to main body
- S-curve shapes suggesting organic fluid motion
- 2-3 surface bubbles (raised half-spheres) on main body
- All transitions seamless -- no hard edges at attachment points

### Task 12.4: Retopology -- Deformation-Ready Mesh
**Status:** TODO
**Description:** Retopologize the high-poly sculpt into a game-ready mesh targeting 1,400-2,000 triangles. This mesh requires special topology planning because it will deform heavily during animation. Place denser edge loops (4-5 concentric rings) around pseudopod bases where tendrils will stretch and retract. The main body dome needs at least 3-4 horizontal loop rings to support the pulse/breathe deformation without faceting. Use quad-dominant topology on the body surface for clean deformation. Tendril topology should follow the length with 6-8 edge loops each for smooth bending. The ground-contact base ring needs good resolution (12-16 edge segments) since it visibly flattens during movement.
**Acceptance Criteria:**
- Total triangle count between 1,400-2,000
- Dense edge loops at pseudopod attachment zones
- 3-4 horizontal loops on body dome for pulse deformation
- Quad-dominant topology on main body surfaces
- 6-8 edge loops per tendril for smooth bending
- Ground-contact base has 12-16 edge segments
- No non-manifold geometry; all normals outward

### Task 12.5: UV Unwrap and Layout
**Status:** TODO
**Description:** UV unwrap the retopologized mesh. For the main body, place a single seam running along the bottom (ground contact, hidden from camera) and unwrap as one large island. Tendrils get individual islands unwrapped along their length (seam on the underside). Surface bubbles can share a small stacked UV island. The main body island should occupy roughly 60% of UV space (most visual detail), tendrils share 30%, and bubbles/misc get 10%. Pack at 512x512 resolution with 4px island padding. Minimize UV stretching on the front-facing dome surface since that is where the eye spots and data fragments will be painted with the most detail.
**Acceptance Criteria:**
- Main body as single large UV island (seam hidden underneath)
- Tendrils as individual islands with underside seams
- UV space allocation: 60% body, 30% tendrils, 10% misc
- Minimal stretching on front-facing dome surface
- 4px island padding at 512x512 resolution
- All islands packed cleanly in 0-1 space

### Task 12.6: Bake Normal Map
**Status:** TODO
**Description:** Bake a normal map from the high-poly sculpt to the low-poly mesh. The normal map is critical for this character because the surface tension ridges, surface bubbles, and subtle organic undulations will not be present in the low-poly mesh. Set up cage/ray distance carefully -- the blob shape means some areas will need larger ray distances than a hard-surface model. Check for artifacts at pseudopod-to-body junctions where geometry overlaps in screen space. Apply 4px edge bleed on all UV islands. Verify the baked result by comparing the normal-mapped low-poly against the sculpt under rotating lighting. Save as `memoryleak_normal.png` at 512x512.
**Acceptance Criteria:**
- Surface tension ridges, bubbles, and undulations captured in normal map
- No artifacts at pseudopod junction areas
- 4px edge bleed applied
- Normal-mapped low-poly reads close to high-poly under directional light
- Saved as `memoryleak_normal.png` at 512x512

### Task 12.7: Hand-Paint Diffuse -- Base Green and Translucency Illusion
**Status:** TODO
**Description:** Paint the base diffuse texture to create the illusion of translucent green gel (without actual transparency rendering). Use a three-layer approach: (1) Dark core color (#1A5C2A) as the base fill, representing the deep interior. (2) Bright surface green (#44DD44) painted over the top and sides with a soft gradient, leaving darker areas at the very base and in concavities -- this simulates light passing through the outer layer. (3) Rim-light highlight zones (#88FF88) painted along the upper dome edges and tendril edges where a real translucent object would appear brightest due to subsurface scattering. The eye spots get the brightest treatment (#AAFFAA) to draw attention. This three-layer gradient is the key to faking translucency in an opaque material.
**Acceptance Criteria:**
- Three-layer gradient creates convincing translucency illusion
- Dark core, bright surface, brightest rim highlight progression
- Eye spots are clearly the brightest focal points
- Tendrils follow the same gradient logic (darker at base, brighter at tips)
- Overall reads as "glowing green gel" not "painted green sphere"

### Task 12.8: Hand-Paint Diffuse -- Corruption Veins and Data Fragments
**Status:** TODO
**Description:** Layer corruption detail over the base translucency paint. Paint dark vein-like tendrils (#0A3A1A) branching through the interior of the blob -- imagine corrupted data pathways visible through the gel. Veins should be organic and branching (not straight lines), radiating from the eye spots outward. Paint 5-8 small "data fragment" inclusions: tiny clusters of hex text, binary digits, or glitched pixel blocks (#00FF66 neon green) that appear suspended inside the gel. These should be painted slightly blurred to suggest depth -- as if seen through the translucent surface. Add a few horizontal scan-line distortions (#00CC44) that suggest the creature is made of corrupted digital memory.
**Acceptance Criteria:**
- Corruption veins branch organically from eye spots outward
- Veins are dark (#0A3A1A) suggesting internal depth
- 5-8 data fragment inclusions painted at various depths (varying blur)
- Data fragments use neon green (#00FF66) for contrast
- 2-3 scan-line distortions present
- Detail enhances the digital corruption theme without overwhelming translucency read
- Saved as `memoryleak_diffuse.png` at 512x512

### Task 12.9: Emission Map and Material Configuration
**Status:** TODO
**Description:** Create the emission map at 512x512. The MemoryLeak should have a pervasive soft glow: eye spots emit at full intensity (bright green #00FF66), data fragment inclusions emit at ~50% intensity, the upper dome surface emits at ~10% intensity (subtle overall glow suggesting bioluminescence), and corruption veins emit at ~5% (barely perceptible pulse). Save as `memoryleak_emission.png`. Set up the Blender material: Base Color = diffuse, Normal = normal map, Emission = emission map with energy multiplier of 1.5 to make it properly luminous. Set Roughness to 0.3 (slime is wet and glossy). Metallic 0.0. Test under dark lighting to verify the glow effect reads correctly.
**Acceptance Criteria:**
- Emission map with proper intensity zones (eyes > data > surface > veins)
- Material roughness 0.3 for wet/glossy appearance
- Emission energy multiplier creates visible glow without blowout
- Model reads as self-luminous under dark lighting conditions
- Saved as `memoryleak_emission.png` at 512x512

### Task 12.10: Skeletal Rig -- Core and Wobble Bones
**Status:** TODO
**Description:** Create the armature for soft-body-like deformation. Bone hierarchy: `root` at the base center, `body_core` at the center of mass (slightly above midpoint), `body_top` at the dome apex, `body_ring_N` (4 bones arranged in a compass ring around the body midline for lateral wobble). The ring bones are the key to the jiggle effect -- when animated with slight offset timing, they create a convincing soft-body wobble without physics simulation. Add `tendril_A_01/02/03` (3 bones per tendril for curl/extend), `eye_L` and `eye_R` bones (for subtle independent eye spot drift), and `bubble_01/02/03` bones for the surface bubbles (these will scale during the pulse animation). Total: ~22 bones.
**Acceptance Criteria:**
- Root, core, top, and 4 ring bones for body deformation
- 9 tendril bones (3 per tendril, 3 tendrils)
- 2 eye bones for independent movement
- 3 bubble bones for scale animation
- ~22 total bones with clean hierarchy
- Ring bones positioned for convincing lateral wobble simulation

### Task 12.11: Weight Painting for Soft-Body Deformation
**Status:** TODO
**Description:** Weight paint the mesh with careful attention to creating believable soft deformation. The `body_core` bone gets influence over the central mass (~50% falloff gradient to the surface). `body_top` controls the dome apex with a wide soft gradient. The 4 `body_ring` bones each control a quadrant of the outer surface with smooth overlap between adjacent quadrants (use ~30% overlap zones to prevent creasing). Tendril bones should have sharp influence boundaries at the tips but soft blending at the base where they meet the body. Eye bones get tight, localized influence (small radius). Bubble bones get point-weight influence on just the bubble vertices. Test by rotating each ring bone 5-10 degrees -- the body should deform smoothly like jelly, not crease or collapse.
**Acceptance Criteria:**
- Soft gradient weight transitions across the body surface
- Ring bones create smooth jelly-like deformation when rotated
- No creasing or hard edges during deformation test
- Tendril base weights blend smoothly into body influence
- Eye and bubble bones have localized influence
- Full range-of-motion test shows no mesh collapse or volume loss

### Task 12.12: Animation -- Idle Pulse Cycle
**Status:** TODO
**Description:** Create a 3-second looping idle animation (72 frames at 24fps). The MemoryLeak's idle should feel alive and unstable. Primary motion: slow full-body pulse (body_top rises 0.03m and descends over 72 frames, one complete breath cycle). Secondary motion: ring bones wobble in a staggered wave pattern -- each ring bone oscillates with a 6-frame offset from its neighbor, creating a ripple that travels around the body. Tendrils lazily drift and curl (slow sinusoidal rotation on tendril bones, different frequencies per tendril). Eye spots slowly drift apart and together (eye bones translate ~0.01m). Bubbles subtly scale up 10% during the pulse peak and down during the trough. The overall effect should read as "quietly breathing blob."
**Acceptance Criteria:**
- 72-frame seamless loop with visible pulse/breathe motion
- Ring bone wave creates traveling ripple effect around body
- Tendrils drift lazily with different timing per tendril
- Eye spots drift independently, adding organic feel
- Bubbles scale with pulse cycle
- Overall reads as alive and gelatinous, not mechanical

### Task 12.13: Animation -- Ooze Crawl Movement
**Status:** TODO
**Description:** Create a 1.5-second looping crawl cycle (36 frames at 24fps). The MemoryLeak moves by flowing forward like an amoeba: the body leans into the movement direction (body_core tilts 10-15 degrees forward), the leading edge stretches forward (front ring bones extend), then the mass follows and the trailing edge contracts (back ring bones compress). This creates a slug-like pulse-crawl motion. Tendrils on the underside act as grip points (plant forward, drag backward). The top surface should ripple as the mass shifts. Root motion should translate ~1m per cycle. The movement should feel heavy, viscous, and slightly repulsive -- this creature has weight and inertia.
**Acceptance Criteria:**
- Amoeba-like pulse-crawl locomotion (not walking or sliding)
- Body tilts into movement direction during travel phase
- Leading edge stretches, mass follows, trailing edge contracts
- Top surface ripple during mass transfer
- ~1m root translation per cycle (slow, deliberate)
- Movement feels heavy and viscous

### Task 12.14: Animation -- Spit Projectile Attack
**Status:** TODO
**Description:** Create the ranged spit attack animation (1.2 seconds, 29 frames). Phase 1 -- gather (frames 1-10): the MemoryLeak swells upward (body_top rises 0.05m, ring bones expand outward) as it gathers corrosive material, a visible bulge forms on the front surface (front ring bones push outward extra). Phase 2 -- spit (frames 11-16): violent forward contraction (body_core slams forward, front ring bones snap inward) expelling the projectile from the front surface. The body visibly deflates during the spit. Phase 3 -- recovery (frames 17-29): body slowly re-inflates to normal volume, wobbles from the recoil (ring bones oscillate with damping). Mark frame 13 as the projectile spawn frame for gameplay synchronization.
**Acceptance Criteria:**
- Visible swell/gather phase with front-surface bulge
- Fast, violent contraction for the spit release
- Body deflation during spit is noticeable
- Recoil wobble with natural damping during recovery
- Frame 13 clearly marked as projectile spawn frame
- Animation has impactful feel -- the spit looks forceful

### Task 12.15: Animation -- Hurt Recoil
**Status:** TODO
**Description:** Create a hurt reaction animation (0.75 seconds, 18 frames). When hit, the MemoryLeak should react like a water balloon being poked: immediate indentation at the hit point (front ring bones compress inward), then a ripple wave propagates around the body (each ring bone compresses and expands in sequence, 2-frame delay between adjacent bones). The body temporarily compresses downward (body_top drops 0.02m) then bounces back with slight overshoot. Tendrils briefly retract toward the body (defensive curl). Eye spots "blink" (eye bones scale to 0% briefly then back to 100%). The whole reaction should feel like disturbing a body of jello.
**Acceptance Criteria:**
- Initial indentation at impact point
- Ripple wave propagates around the body in sequence
- Compression and overshoot bounce on the vertical axis
- Tendrils retract defensively
- Eye spot "blink" reaction
- Returns to neutral pose for animation blending

### Task 12.16: Animation -- Death Dissolve
**Status:** TODO
**Description:** Create the death animation (2.5 seconds, 60 frames). The MemoryLeak's death should feel like a contained liquid losing its cohesion. Frames 1-15: body shudders violently (high-frequency oscillation on all ring bones, decreasing amplitude), tendrils go rigid then limp. Frames 16-35: body begins to flatten and spread (body_top descends, ring bones spread outward), as if the surface tension is failing. The shape becomes increasingly pancake-like. Frames 36-50: final collapse -- body_top reaches near ground level, ring bones are at maximum spread, tendrils lay flat. Frames 51-60: settle into final puddle pose (completely flat disc shape). This final pose will be held while the shared death VFX (Epic 15) handles the pixel-scatter dissolve effect.
**Acceptance Criteria:**
- Violent shudder phase (high-frequency ring bone oscillation)
- Gradual flattening/spreading as surface tension fails
- Tendrils transition from rigid to limp
- Final puddle pose is a flat disc shape
- Animation timing allows shared death VFX to layer on top
- 60 frames total, held on last frame

### Task 12.17: Animation Polish -- Secondary Motion and Overlap
**Status:** TODO
**Description:** Polish pass on all animations to add secondary motion and overlapping action. For each animation, add 2-3 frame delays on the tendril bones so they drag behind the primary body motion (follow-through). Add subtle bubble jiggle (rapid small scale oscillation on bubble bones) triggered by any sudden body movement. Ensure the eye spots have micro-drift in every animation (never perfectly still). Add a very subtle surface shimmer by oscillating the body_ring bones at high frequency and low amplitude (1-2 degree, 4-frame cycle) layered on top of all animations. Review all animation curves in the Graph Editor -- convert any linear interpolation to bezier for organic easing. Remove any pops or hitches at blend transition points.
**Acceptance Criteria:**
- Tendrils exhibit follow-through delay on all animations
- Bubble jiggle triggers on sudden movements
- Eye spots have micro-drift in every animation
- Surface shimmer overlay present on all animations
- All animation curves use bezier interpolation (no linear)
- No pops or hitches visible during state transitions

### Task 12.18: GLB Export and Texture Verification
**Status:** TODO
**Description:** Prepare the final export. In Blender, verify all animation actions are properly named in the NLA editor: `idle`, `crawl`, `attack_spit`, `hurt`, `death`. Clean up the file: delete the high-poly sculpt (or move to a separate file), remove any unused materials or textures, apply all modifiers except Armature. Set the mesh origin to the base center (where the blob meets the ground). Export as `memoryleak.glb` with embedded textures (diffuse, normal, emission). Verify file size is reasonable (under 2MB). Import into a test Godot scene and verify: mesh displays correctly, all 3 texture maps are present, material properties (roughness 0.3, emission energy) transferred, all 5 animations are listed in AnimationPlayer.
**Acceptance Criteria:**
- 5 animations properly named and exported in .glb
- No leftover high-poly or unused data in export
- Mesh origin at base center
- File size under 2MB
- Godot import shows correct mesh, textures, and material properties
- All 5 animations accessible in AnimationPlayer

### Task 12.19: Godot Scene Setup and State Machine Integration
**Status:** TODO
**Description:** Create or update the MemoryLeak enemy scene in Godot. Replace the placeholder mesh with the new imported model. Configure the AnimationTree state machine: idle state plays `idle` (looping), move state plays `crawl` (looping), attack state plays `attack_spit` (one-shot, triggers projectile spawn at frame 13), hurt state plays `hurt` (one-shot, returns to previous state), death state plays `death` (one-shot, triggers dissolve VFX at end). Update collision shapes to match the new blob proportions (likely a flattened sphere or capsule shape). Set up the projectile spawn point node at the front-center of the blob mesh. Verify the ranged attack distance and projectile origin align with the existing AI behavior scripts.
**Acceptance Criteria:**
- New model replaces placeholder in enemy scene
- AnimationTree states properly mapped to new animations
- Projectile spawn frame (13) triggers correctly in attack state
- Collision shape matches new mesh proportions
- Projectile spawn point positioned at front-center
- AI behavior scripts work without modification (or with minimal tweaks)

### Task 12.20: In-Game Testing and Visual Validation
**Status:** TODO
**Description:** Comprehensive in-game test of the rebuilt MemoryLeak. Spawn the enemy in a dungeon room and verify: (1) idle pulse animation plays and looks gelatinous/alive, (2) crawl animation plays during movement with correct speed matching (no sliding), (3) spit attack fires projectile at correct timing and from correct position, (4) hurt reaction plays on damage with proper ripple effect, (5) death animation plays through to puddle pose then shared VFX dissolves it, (6) emission glow is visible but not overpowering in dungeon lighting, (7) the MemoryLeak is visually distinct from GlitchBug at all camera distances, (8) multiple MemoryLeaks in one room do not cause performance issues. Take before/after screenshots. Adjust animation speeds, emission intensity, or material properties as needed.
**Acceptance Criteria:**
- All 5 animation states function correctly in gameplay context
- Spit projectile timing and origin are accurate
- Emission glow visible in dungeon lighting without being excessive
- Visually distinct from GlitchBug at game camera distance
- No performance regression with 5+ MemoryLeaks in a room
- Before/after screenshots captured

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings and naming conventions
- **Epic 2** (Visual Style Guide): Color palette and stylization rules
- **Epic 3** (Texture Workflow): UV standards and texture resolution
- **Epic 4** (Animation Pipeline): Rig standards and bone naming
- **Epic 15** (Enemy Shared VFX): Death dissolution effect for final death transition

## Notes

- The translucency illusion is the make-or-break visual for this character -- spend extra time on Task 12.7 getting the gradient right
- Soft-body wobble through bone animation is a performance-friendly alternative to actual soft-body physics
- The MemoryLeak should feel like the opposite of the GlitchBug: slow, heavy, unsettling vs. fast, aggressive, skittery
- Consider adding a subtle green glow light node (OmniLight3D) as a child of the MemoryLeak scene for environmental lighting effect
- The same rig and animations will be reused for MemoryLeak variants (Epic 17) with color/scale changes
