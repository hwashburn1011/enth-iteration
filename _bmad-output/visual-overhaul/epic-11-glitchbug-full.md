---
epic: 11
title: "GlitchBug Full Rebuild"
phase: 3
status: IN_PROGRESS
priority: high
estimated_hours: 60
dependencies: [1, 2, 3, 4]
---

# Epic 11: GlitchBug Full Rebuild

## Overview

Complete visual rebuild of the GlitchBug enemy -- the primary melee threat in Enth: Iteration's dungeon floors. The GlitchBug is an aggressive red spiky insect creature born from corrupted code, skittering rapidly toward the player and lunging with razor-sharp mandibles. This epic covers the full art pipeline from Blender sculpt through Godot integration: high-poly sculpt, retopology, UV mapping, hand-painted textures, skeletal rig, animation set, and in-engine hookup with the existing enemy state machine.

**Visual Identity:** Organic insectoid body with angular chitinous spikes, segmented thorax and abdomen, six articulated legs, mandible pincers, and glowing red compound eyes. The surface blends organic insect anatomy with digital glitch artifacts -- hex patterns in the chitin, static-noise texture breaks, and pixel-corruption edges on the spikes.

**Quality Target:** Emberville/Stardew Valley stylized 3D -- chunky rounded proportions with hand-painted texture detail. Not realistic, not low-poly flat-shaded. Readable silhouette at isometric camera distance.

## Success Criteria

- [ ] GlitchBug model is a proper sculpted/retopologized mesh (not stacked primitives)
- [ ] Hand-painted diffuse texture with red/orange gradient and glitch overlay
- [ ] Skeletal rig with 6 legs, 3 body segments, mandibles, antennae
- [ ] Full animation set: idle, skitter walk, attack lunge, hurt flinch, death thrash
- [ ] Exported as .glb and integrated in Godot replacing the current placeholder
- [ ] Silhouette is instantly readable as "aggressive insect" at game camera distance
- [ ] Polycount under 2,500 tris; single 512x512 texture atlas
- [ ] All animations play correctly through the enemy AnimationPlayer/state machine

---

## Tasks

### Task 11.1: Reference Sheet and Concept Sketches
**Status:** TODO
**Description:** Gather reference images of stylized insects (beetles, mantises, centipedes) and digital glitch art. Create a concept sketch sheet in Blender's grease pencil or external tool showing the GlitchBug from front, side, top, and 3/4 isometric view. Define proportions: body is roughly 0.8m long x 0.4m wide x 0.3m tall. Mark spike placement, leg joint positions, mandible shape, and eye cluster location. Annotate color zones (deep red body, orange spike tips, black leg joints, glowing red eyes). Include a silhouette test at expected game camera distance to verify readability.
**Acceptance Criteria:**
- Reference sheet with at least 4 views (front, side, top, 3/4)
- Proportion annotations with metric measurements
- Color zone markup matching the red/orange/black palette
- Silhouette reads clearly as "spiky insect" at thumbnail size

### Task 11.2: High-Poly Sculpt -- Body Core
**Status:** TODO
**Description:** In Blender, begin the high-poly sculpt starting with a sphere base. Use the Grab, Clay Strips, and Crease brushes to block out the three main body segments: head (compact, slightly flattened), thorax (wider, carries the leg attachment points), and abdomen (elongated, tapered). Maintain chunky rounded proportions per the style guide -- no sharp realistic anatomy, think "cartoon beetle." Use Smooth brush to keep surfaces clean between intentional creases. Target roughly 200K-500K polys for the high-poly sculpt. Save the .blend file as `glitchbug_highpoly.blend` in the `models/enemies/` directory.
**Acceptance Criteria:**
- Three distinct body segments clearly readable
- Chunky stylized proportions, not anatomically realistic
- Clean topology flow between segments
- Smooth surfaces with intentional creases at segment boundaries
- File saved in correct project directory

### Task 11.3: High-Poly Sculpt -- Spikes and Surface Detail
**Status:** TODO
**Description:** Add the signature spikes to the GlitchBug's body. Use the Snake Hook brush or extrude method to pull 8-12 spikes from the thorax and abdomen -- larger dorsal spikes (3-4 along the back) and smaller lateral spikes (2-3 per side). Spikes should be conical with slightly curved tips, chunky at the base. Sculpt surface detail: shallow groove lines on the chitin plates to suggest segmented armor, subtle bump texture on the abdomen for organic feel. Add the compound eye cluster on the head (5-7 rounded bumps in a cluster pattern). Sculpt mandible pincers as two curved blade shapes extending from the head front.
**Acceptance Criteria:**
- 8-12 spikes placed asymmetrically for visual interest
- Dorsal spikes larger than lateral spikes (clear hierarchy)
- Chitin groove detail visible but not noisy
- Compound eye cluster of 5-7 rounded bumps
- Two mandible pincers with curved blade shape
- Overall silhouette enhanced -- spikier and more threatening

### Task 11.4: High-Poly Sculpt -- Legs and Antennae
**Status:** TODO
**Description:** Sculpt six insect legs, each with 3 segments (coxa/femur/tibia) plus a pointed tarsus foot. Legs attach to the thorax in pairs: front pair shorter and forward-reaching (manipulator legs), middle pair longest (primary locomotion), rear pair medium and angled backward (stability). Each leg joint should have a visible ball-socket bulge. Sculpt two antennae on the head -- segmented whip-like appendages that curve backward. Keep leg proportions chunky (not spindly) to match the stylized aesthetic and to rig/animate cleanly.
**Acceptance Criteria:**
- Six legs with 3 segments each plus tarsus tip
- Three leg pairs with distinct sizes and angles
- Ball-socket joint bulges at each articulation point
- Two segmented antennae curving backward from head
- Chunky proportions maintained throughout

### Task 11.5: Retopology -- Clean Game-Ready Mesh
**Status:** TODO
**Description:** Create a new low-poly mesh over the high-poly sculpt using Blender's retopology tools (Shrinkwrap modifier or RetopoFlow addon). Target 1,800-2,500 triangles total. Prioritize edge loops around deformation zones: leg joints (3-4 loops per joint), mandible pivot, body segment boundaries, and spike bases. The body core should use the most budget (800-1,000 tris), legs get roughly 80-100 tris each (480-600 total), spikes get 12-20 tris each (150-240 total), and remaining budget goes to mandibles, eyes, and antennae. Ensure all normals face outward. Name the mesh object `GlitchBug_Body`.
**Acceptance Criteria:**
- Total triangle count between 1,800-2,500
- Clean edge loops at all deformation zones
- No flipped normals, no non-manifold geometry
- Proper polygon density distribution (more at joints, less on flat areas)
- Object named `GlitchBug_Body` with clean hierarchy

### Task 11.6: UV Unwrap -- Layout and Optimization
**Status:** TODO
**Description:** Mark seams on the retopologized mesh for UV unwrapping. Place seams along natural visual breaks: underside of body (hidden from camera), inside of legs, back of spikes. Unwrap using Blender's Smart UV Project as a starting point, then manually adjust islands. The body core gets the largest UV island (most texture detail). Group all 6 legs into a shared UV space (they share the same texture pattern). Stack identical spike UVs to reuse texture space. Pack all islands into a single 0-1 UV space with 4px padding between islands. Target 512x512 texture resolution. Minimize stretching -- check with the UV stretch overlay.
**Acceptance Criteria:**
- Seams hidden from primary isometric camera angle
- Body core has the largest UV island allocation
- Leg UVs share space efficiently (mirrored/stacked where possible)
- Spike UVs stacked for texture reuse
- All islands fit in 0-1 space with minimum 4px padding
- UV stretch checker shows no severe distortion (< 15% max)

### Task 11.7: Bake Normal Map from High-Poly
**Status:** TODO
**Description:** Set up a bake in Blender to transfer detail from the high-poly sculpt to the low-poly game mesh via a normal map. Create a new 512x512 image in the shader editor, assign it to the low-poly mesh material. Set bake type to Normal (Tangent Space). Adjust ray distance to encompass all high-poly detail without artifacts. Bake and inspect the result -- check for seam artifacts along UV boundaries (fix with edge padding/bleed), check spike tips for normal map errors, verify that chitin groove detail transfers cleanly. Save as `glitchbug_normal.png`. The normal map should make the low-poly mesh look nearly identical to the sculpt under directional lighting.
**Acceptance Criteria:**
- 512x512 tangent-space normal map baked without artifacts
- Chitin grooves, spike detail, and eye bumps visible in normal map
- No visible seam lines when viewed on low-poly mesh
- Edge padding/bleed of at least 4px on all UV island borders
- File saved as `glitchbug_normal.png`

### Task 11.8: Hand-Paint Diffuse Texture -- Base Colors
**Status:** TODO
**Description:** Begin hand-painting the diffuse texture in Blender's Texture Paint mode (or Krita if needed for detail work). Start with a base color pass: deep crimson red (#8B1A1A) for the main body chitin, darker burgundy (#5C0A0A) in the segment creases and underside, warm orange (#CC4400) gradient on spike tips, jet black (#1A1A1A) for leg joints and tarsus tips, bright glowing red (#FF2200) for compound eyes. Use broad strokes first to establish the color zones, blending with soft brush edges at boundaries. The overall impression should be "angry red insect" even before any detail painting.
**Acceptance Criteria:**
- All color zones laid down matching the reference sheet
- Red-to-orange gradient visible on spikes (base to tip)
- Dark creases at segment boundaries add depth
- Eye cluster reads as glowing even without emission
- No raw white/unpainted areas anywhere on the UV

### Task 11.9: Hand-Paint Diffuse Texture -- Detail Pass
**Status:** TODO
**Description:** Add detail painting over the base colors. Paint chitin plate edge highlights (lighter red/orange lines along plate boundaries) to suggest hard shell material. Add subtle specular dot highlights on the compound eyes. Paint tiny scratch marks and wear on the legs and mandibles using a fine brush with slightly lighter color. Add a subtle warm ambient occlusion effect by darkening concave areas (leg attachment points, underside creases, between spikes) with a dark multiply brush. Paint mandible tips with a pale bone-white gradient. Add subtle color temperature variation -- warmer (more orange) on top surfaces catching light, cooler (more purple-red) on undersides.
**Acceptance Criteria:**
- Chitin edge highlights define plate boundaries clearly
- Compound eyes have specular dot highlights
- Scratch/wear marks on high-contact surfaces (legs, mandibles)
- Hand-painted AO darkening in concave areas
- Color temperature variation between top and bottom surfaces
- Mandible tips have bone-white gradient

### Task 11.10: Hand-Paint Diffuse Texture -- Glitch Pattern Overlay
**Status:** TODO
**Description:** Apply the signature digital glitch effect that ties the GlitchBug to the game's "corrupted computer simulation" theme. Paint hexadecimal number fragments on the larger chitin plates (faint, as if printed on the shell) using a very small brush and a slightly lighter red. Add pixel-corruption blocks along spike edges and body segment boundaries -- small rectangular patches where the texture appears to "break" into raw colored pixels (neon green #00FF00 and cyan #00FFFF accents against the red). Paint 2-3 scan-line artifacts (thin horizontal lines of slightly different hue) across the abdomen. Keep these effects subtle -- they should be discoverable detail, not overwhelming the organic insect read.
**Acceptance Criteria:**
- Hexadecimal text fragments visible on close inspection (3-4 instances)
- Pixel-corruption blocks at 4-6 locations along edges and boundaries
- Neon green and cyan accent pixels contrast against red base
- 2-3 scan-line artifacts on abdomen
- Glitch effects are subtle -- insect silhouette still reads first
- Save final texture as `glitchbug_diffuse.png` at 512x512

### Task 11.11: Emission Map for Glowing Elements
**Status:** TODO
**Description:** Create a 512x512 emission map to define which parts of the GlitchBug glow. The compound eyes should have strong emission (bright red #FF0000 at full intensity). The pixel-corruption patches from the diffuse texture should have subtle emission (neon green/cyan at ~30% intensity) to create a faint digital glow effect. Optionally add very faint emission along the chitin plate edge highlights (~5% intensity warm orange) for a subtle bioluminescent effect. All other areas should be pure black (no emission). Save as `glitchbug_emission.png`. In Godot, this will drive the emission channel of the StandardMaterial3D.
**Acceptance Criteria:**
- Compound eyes emit bright red at full intensity
- Pixel-corruption patches emit green/cyan at ~30%
- Optional subtle edge glow at ~5%
- All non-emitting areas are pure black
- Saved as `glitchbug_emission.png` at 512x512

### Task 11.12: Material Setup and Export Test
**Status:** TODO
**Description:** Create a StandardMaterial3D-compatible material setup in Blender. Assign the diffuse texture to Base Color, normal map to Normal (set to Non-Color), and emission map to Emission. Set up basic material properties: roughness 0.7 (chitin is slightly glossy), metallic 0.0 (organic material). Test the material under Blender's viewport with a 3-point lighting setup that approximates the game's isometric lighting. Verify textures display correctly with no UV offset issues. Export the model as `glitchbug.glb` with embedded textures. Import into Godot and verify the material transfers correctly -- check that normal map, emission, and diffuse all display as intended.
**Acceptance Criteria:**
- Material has diffuse, normal, and emission maps correctly assigned
- Roughness 0.7, metallic 0.0 configured
- Model looks correct under test lighting in Blender
- Exported as .glb with embedded textures
- Imported into Godot with material properties intact
- No texture offset, tiling, or channel-swap issues

### Task 11.13: Skeletal Rig -- Armature Creation
**Status:** TODO
**Description:** Create the skeletal armature for the GlitchBug. Build the bone hierarchy: Root bone at body center of mass (thorax), spine chain of 3 bones (head, thorax, abdomen), 6 leg chains (each with 4 bones: coxa, femur, tibia, tarsus), 2 mandible bones (single bone each, pivoting from head), 2 antenna chains (2 bones each). Name all bones following the project convention: `root`, `spine_head`, `spine_thorax`, `spine_abdomen`, `leg_FL_coxa` / `leg_FL_femur` / `leg_FL_tibia` / `leg_FL_tarsus` (FL=front-left, FM=front-mid... etc), `mandible_L`, `mandible_R`, `antenna_L_01`, `antenna_L_02`. Position bone heads and tails at joint centers. Set bone roll angles so local axes align with natural rotation directions.
**Acceptance Criteria:**
- Complete bone hierarchy with root, 3 spine, 24 leg, 2 mandible, 4 antenna bones (33 total)
- All bones named following project convention with clear L/R/F/M/B prefixes
- Bone positions match joint centers on the mesh
- Bone roll angles set for natural rotation axes
- Parent-child hierarchy is clean (no orphan bones)

### Task 11.14: Skeletal Rig -- Weight Painting
**Status:** TODO
**Description:** Weight paint the mesh to the armature. Start with automatic weights (Armature Deform With Automatic Weights) as a base, then manually refine. Key areas requiring manual attention: leg attachment points (each leg's coxa bone should have clean influence with no bleed into the body), body segment boundaries (spine bones should deform smoothly between segments), mandible pivots (sharp falloff to prevent jaw movement affecting the head), spike bases (spikes should follow their parent body segment rigidly -- paint weights to 1.0 for the nearest spine bone). Test deformation by posing each bone through its expected range of motion and checking for volume loss, clipping, or unexpected vertex pulling.
**Acceptance Criteria:**
- All vertices assigned to at least one bone (no unweighted verts)
- Leg coxa weights have clean boundaries -- no bleed into body mesh
- Body segments deform smoothly when spine bones rotate
- Spikes follow parent segment rigidly (weight = 1.0 to nearest spine bone)
- Mandibles pivot cleanly without affecting head geometry
- No volume loss or mesh collapse at any expected pose extreme

### Task 11.15: Animation -- Idle Cycle
**Status:** TODO
**Description:** Create a looping idle animation (2 seconds, 48 frames at 24fps). The GlitchBug should exhibit subtle restless movement while stationary: gentle body bob (abdomen raises/lowers ~0.02m), mandibles slowly open and close with a slight offset between left and right (not perfectly synchronized), antennae sway gently (2-3 degree oscillation), front legs occasionally "tap" the ground (lift and replace). The middle and rear legs should shift weight subtly but remain planted. Add a slight thorax rotation (1-2 degrees left/right) to prevent the idle from feeling frozen. Key all movements on different timings to avoid mechanical repetition.
**Acceptance Criteria:**
- 48-frame looping cycle with no visible pop at loop point
- Body bob, mandible movement, antenna sway all present
- Movements are on offset timings (not synchronized)
- Front leg occasional tap adds personality
- Subtle enough to read as "alert and waiting" not "dancing"

### Task 11.16: Animation -- Skitter Walk Cycle
**Status:** TODO
**Description:** Create a looping skitter walk cycle (1 second, 24 frames at 24fps) for the GlitchBug's rapid ground movement. Use the insect tripod gait pattern: legs move in two alternating groups of three (FL+MR+BL then FR+ML+BR). Each leg lifts quickly (4 frames up), swings forward (4 frames), and plants (4 frames down) while the opposing tripod is in stance phase. The body should have a slight forward lean during movement and subtle lateral sway (the body shifts slightly toward the stance-phase side). Speed should feel frantic and skittery -- short stride length with high step frequency. Mandibles should be held forward in an aggressive posture. Root motion should translate approximately 2m per cycle.
**Acceptance Criteria:**
- Proper insect tripod gait (two alternating groups of 3 legs)
- No foot sliding when root motion is applied
- Body has forward lean and subtle lateral sway
- Frantic, rapid step frequency matching the GlitchBug's aggressive personality
- Mandibles held in aggressive forward posture
- Clean loop with ~2m of root translation per cycle

### Task 11.17: Animation -- Attack Lunge
**Status:** TODO
**Description:** Create the attack lunge animation (1 second, 24 frames). This is a two-phase animation: wind-up (frames 1-8) where the GlitchBug rears back slightly, draws mandibles wide open, and front legs lift off the ground; strike (frames 9-16) where it lunges forward explosively, mandibles snap shut, and front legs slam down; recovery (frames 17-24) where it returns to idle-adjacent pose. The lunge should cover ~1m of forward root motion during the strike phase. Add a subtle full-body shake/vibration during wind-up (1-2 frame offset jitter on spine bones) to telegraph the incoming attack. The mandible snap should be the fastest movement in the animation (2-3 frames from open to closed).
**Acceptance Criteria:**
- Three clear phases: wind-up (8f), strike (8f), recovery (8f)
- Wind-up telegraph is visible and readable (rear-back + mandible spread)
- Strike is fast and aggressive with ~1m forward root motion
- Mandible snap completes in 2-3 frames (snappy impact feel)
- Recovery returns to a pose compatible with idle or walk blend
- Body jitter during wind-up adds menace

### Task 11.18: Animation -- Hurt Flinch and Death Thrash
**Status:** TODO
**Description:** Create two damage-response animations. **Hurt flinch** (0.5 seconds, 12 frames): full-body recoil away from the hit direction (backward lean on spine, legs scramble briefly, mandibles snap shut defensively, spikes flare). Should be blendable and not require specific facing. **Death thrash** (2 seconds, 48 frames): dramatic death sequence where the GlitchBug flips partially onto its back (spine rotation ~60 degrees), legs curl inward and twitch spasmodically (rapid small rotations on leg bones at decreasing frequency), mandibles lock open, antennae go limp. Final 12 frames: all movement stops, body settles into a static "dead bug" pose on its side. This final pose will be held until the death VFX dissolves the mesh.
**Acceptance Criteria:**
- Hurt flinch is 12 frames, directional recoil, blendable
- Hurt flinch recovers to neutral pose quickly
- Death thrash has dramatic flip/curl sequence over 48 frames
- Leg twitching decreases in frequency (starts fast, slows to stop)
- Final death pose is static and stable (no jittering)
- Both animations export cleanly with no bone constraint issues

### Task 11.19: Animation Export and Godot Integration
**Status:** TODO
**Description:** Export all animations embedded in the .glb file. In Blender, ensure all animation actions are named consistently: `idle`, `walk`, `attack_lunge`, `hurt`, `death`. Use the NLA editor to verify each action is properly stripped and labeled. Export with "Apply Modifiers" and "Animation" enabled. In Godot, import the .glb as an inherited scene. Verify AnimationPlayer has all 5 animations listed. Set loop mode on `idle` and `walk`. Configure the existing enemy AnimationTree state machine to reference the new animations: idle state plays `idle`, chase state plays `walk`, attack state plays `attack_lunge`, hurt state plays `hurt`, dead state plays `death`. Test each transition in the AnimationTree preview.
**Acceptance Criteria:**
- All 5 animations present in Godot's AnimationPlayer after import
- `idle` and `walk` set to loop; `attack_lunge`, `hurt`, `death` set to one-shot
- AnimationTree state machine transitions reference new animations
- Each state transition plays correctly in preview
- No bone/track name mismatches between .glb and Godot

### Task 11.20: In-Game Integration and Polish
**Status:** TODO
**Description:** Replace the existing placeholder GlitchBug mesh and materials in the game scene with the new asset. Update the enemy scene (`scenes/enemies/GlitchBug.tscn` or equivalent) to reference the new .glb model. Adjust collision shapes to match the new mesh bounds. Verify the following in-game: (1) GlitchBug spawns correctly in dungeon rooms, (2) idle animation plays when not aggro, (3) walk animation plays during chase with correct movement speed matching, (4) attack animation triggers at correct range and the hitbox timing aligns with the mandible snap frame, (5) hurt flinch plays on damage received, (6) death animation plays and transitions to the shared death VFX (Epic 15). Adjust animation playback speeds if needed to match gameplay timing. Take before/after screenshots for documentation.
**Acceptance Criteria:**
- New model replaces placeholder in the game scene
- Collision shapes updated to match new mesh bounds
- All 5 animation states trigger correctly during gameplay
- Attack hitbox timing matches mandible snap frame (frame 9-12 of lunge)
- No visual glitches, Z-fighting, or scale issues
- Before/after screenshots captured

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings and naming conventions must be established
- **Epic 2** (Visual Style Guide): Proportions, color palette, and stylization rules referenced throughout
- **Epic 3** (Texture Workflow): UV standards and texture resolution established
- **Epic 4** (Animation Pipeline): Rig standards, bone naming, export format defined
- **Epic 15** (Enemy Shared VFX): Death dissolution effect referenced in Task 11.20

## Notes

- The GlitchBug is the most common enemy -- it must look great but also be efficient (low polycount, single texture atlas)
- Skitter animation is critical for game feel -- if it does not look frantic and aggressive, the enemy loses its identity
- Glitch overlay effects on the texture should be subtle enough to not compete with gameplay readability
- Consider creating a Blender shape key for "mandibles wide open" to supplement the bone rig if needed
- The same base rig will be reused for GlitchBug elite variants (Epic 17) with material swaps
