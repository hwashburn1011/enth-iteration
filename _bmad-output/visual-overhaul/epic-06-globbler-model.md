---
epic_id: 06
title: "Epic 06: Globbler Character Model"
phase: 2
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 06: Globbler Character Model

## Overview
Create Globbler's production-quality 3D character model in Blender, replacing the current placeholder/primitive-based representation. Globbler is the player character — a small AI agent with a big personality — so this model must be charming, expressive, and immediately recognizable in silhouette. The modeling process follows the style guide's chunky, rounded, 3-heads-tall proportions with hand-sculpted detail and clean topology suitable for animation deformation.

## Success Criteria
- Globbler has a finished, production-ready low-poly model (~2000 triangles) with clean quad topology
- The model matches the style guide proportions (3 heads tall, big head, stubby limbs, chunky body)
- Mesh deforms correctly during basic animation tests (bend arms, bend legs, turn head)
- Silhouette is unique and recognizable at gameplay camera distance

## Tasks

### Task 06.01: Create Globbler Concept Sketch and Proportion Blockout
**Status:** TODO
**Description:** Before touching Blender, sketch Globbler's design from front, side, and three-quarter views (digital sketch or paper photo). Establish the key proportions: total height 1.5m (3 head-units tall), head is 0.5m diameter sphere, body is 0.6m wide × 0.5m tall rounded cylinder, arms are 0.15m diameter tubes reaching to mid-thigh, legs are 0.18m diameter tubes with 0.2m wide feet. The face has two large circular eyes (0.12m diameter each, placed on the upper-front of the head), a small curved mouth, and digital circuit-line markings running from the back of the head down the spine. Save sketches to `_art_source/reference/globbler_concept.png`.
**Acceptance Criteria:**
- Front, side, and three-quarter concept sketches exist with dimension annotations
- Key features are defined: big eyes, circuit markings, chunky proportions
- Proportions match the style guide's 3-heads-tall specification

### Task 06.02: Build Head Base Mesh from Sphere
**Status:** TODO
**Description:** In Blender, start with a UV Sphere (16 segments, 12 rings) and sculpt Globbler's head shape. Scale to 0.5m diameter. Flatten the front face slightly to create a "screen-like" flat area where the eyes will be. Push the top of the head up slightly to create a gentle dome. Pull the back of the head out slightly for a rounded-rectangle profile (not perfectly spherical). Use Proportional Editing (Connected, Sphere falloff) for smooth organic shaping. The head should look like a rounded monitor or CRT screen from the front — a nod to Globbler's digital nature.
**Acceptance Criteria:**
- Head mesh is approximately 0.5m diameter with a flattened front face
- Shape reads as "rounded digital device" — organic but with a tech hint
- Mesh has clean topology with no triangles or n-gons at this stage

### Task 06.03: Model Eye Sockets and Mouth Cavity
**Status:** TODO
**Description:** Create eye socket indentations on the flattened front face of the head. Select the face loops where each eye will sit (upper-center of the flat face, spaced 0.15m apart center-to-center) and inset them, then push them back slightly (0.02m depth) to create shallow sockets. The eyes themselves will be separate geometry (emissive spheres) placed inside these sockets. Below the eyes, create a small mouth indent: select 3-4 faces, inset, push back 0.01m, creating a subtle curved line. The mouth is tiny compared to the eyes — Globbler communicates more through eye animation (squinting, widening) than mouth movement.
**Acceptance Criteria:**
- Two symmetrical eye sockets are indented on the front face with room for eye sphere geometry
- Mouth is a subtle curved indent, small relative to the eyes
- Face topology flows cleanly around eye sockets without pinching or star vertices

### Task 06.04: Model Body Core
**Status:** TODO
**Description:** Create Globbler's torso as a separate mesh (to be joined later). Start with a cylinder (12 vertices, 4 subdivisions) scaled to 0.6m wide × 0.5m tall. Round the top and bottom edges with a Bevel modifier (width 0.05, segments 2) to eliminate sharp edges. Shape the body into a slightly tapered form: wider at the "chest" area, slightly narrower at the bottom where it meets the legs. The body should feel solid and chunky — like a rounded appliance or robot torso. Add a slight belly bulge on the front for personality. Position the body directly below the head with a 0.05m gap (the neck area).
**Acceptance Criteria:**
- Body mesh is 0.6m wide × 0.5m tall with rounded edges (no sharp corners)
- Slight taper from chest to hip adds visual interest to the silhouette
- Body positioned below head with a small neck gap for eventual neck bone deformation

### Task 06.05: Model Arms
**Status:** TODO
**Description:** Create Globbler's arms as stubby cylindrical tubes. Each arm: start with a cylinder (8 vertices, 3 subdivisions), scale to 0.15m diameter × 0.35m long. Round the ends with bevel. The arm has three segments: upper arm (0.15m), forearm (0.12m), and a bulbous hand (0.1m diameter sphere, slightly flattened). No individual fingers — the hands are mitten-like rounded stumps with a thumb indent sculpted on the inner side. Position arms at shoulder height on the body, angled slightly outward in a relaxed A-pose (15 degrees from body). The A-pose is preferred over T-pose for better shoulder deformation during animation.
**Acceptance Criteria:**
- Both arms are symmetrical, modeled on one side then mirrored
- Arms are in A-pose (15 degrees from body) for optimal deformation
- Hands are mitten-shaped stumps with thumb indent, no individual fingers

### Task 06.06: Model Legs and Feet
**Status:** TODO
**Description:** Create Globbler's legs as slightly thicker tubes than the arms. Each leg: cylinder (8 vertices, 3 subdivisions), 0.18m diameter × 0.3m long. Two segments: thigh (0.17m) and shin (0.13m). Feet are wide flattened ovals (0.2m wide × 0.12m long × 0.08m tall) that give Globbler a stable, grounded look — like cartoon shoes without laces. Add a slight curve to the bottom of each foot so it isn't perfectly flat (toe area slightly raised for walk animation rocking). Position legs at the bottom of the body, spaced 0.25m apart (center to center), in a relaxed standing pose with knees pointing forward.
**Acceptance Criteria:**
- Legs are slightly thicker than arms, giving a stable grounded proportion
- Feet are wide flattened ovals that sell the "chunky character" silhouette
- Standing pose has natural slight knee bend, not locked straight

### Task 06.07: Add Circuit Line Detail Geometry
**Status:** TODO
**Description:** Model subtle circuit-line channels running along Globbler's body surface. These are shallow grooves (0.005m deep, 0.01m wide) that trace paths from the back of the head, down the spine, branching across the chest and down the arms. Use the Knife tool to cut edge loops along the circuit path, then select those faces, inset by 0.005m, and push inward by 0.005m. Keep the circuit lines flowing in smooth curves, not rigid straight lines — matching the organic-tech fusion aesthetic. These grooves will be highlighted with emission in the texture phase. Limit circuit detail to 5-8 main lines to avoid over-complicating the mesh.
**Acceptance Criteria:**
- 5-8 circuit channel grooves are cut into the mesh surface along head, spine, and arms
- Grooves are shallow enough to not disrupt the overall silhouette but visible in close-up
- Circuit paths flow in organic curves, not rigid straight lines

### Task 06.08: Join Meshes and Verify Topology
**Status:** TODO
**Description:** Join all separate body part meshes (head, body, arms, legs, feet) into a single mesh object. Use Ctrl+J in Blender to join, then manually bridge the gaps between body parts using edge loops and the Bridge Edge Loops tool. Neck: bridge head bottom loop to body top loop. Shoulders: bridge arm top loop to body side loops. Hips: bridge leg top loop to body bottom loops. After bridging, clean up topology: merge any duplicate vertices (by distance, 0.001m threshold), remove any internal faces, and ensure all faces are quads. Run Blender's Mesh > Clean Up > Degenerate Dissolve to remove zero-area faces.
**Acceptance Criteria:**
- All body parts are joined into a single continuous mesh with no gaps
- Bridge areas (neck, shoulders, hips) have clean quad topology for good deformation
- No duplicate vertices, internal faces, or degenerate geometry exists

### Task 06.09: Sculpt Surface Detail and Polish
**Status:** TODO
**Description:** Enter Sculpt Mode and apply final surface polish to the joined mesh. Use the Smooth brush (strength 0.3) to even out any lumps from the bridging process. Use the Clay Strips brush to add subtle organic surface variation — Globbler should not look perfectly mathematical. Add slight bulges at the elbows and knees (joint area reinforcement common in the style). Smooth the circuit line edges so they blend naturally into the body surface. Use the Crease brush along the mouth line to sharpen it slightly. Ensure the overall silhouette remains clean and readable after sculpt detailing.
**Acceptance Criteria:**
- Surface has subtle organic variation, not mathematically perfect
- Joint areas (elbows, knees, neck) have natural-looking topology flow
- Circuit lines blend into the surface with smooth edges, not sharp cuts

### Task 06.10: Create Eye Geometry
**Status:** TODO
**Description:** Model Globbler's eyes as separate geometry placed inside the eye sockets. Each eye is a slightly flattened sphere (0.12m diameter, scale Z to 0.8 for a disc-like shape) with the flat face pointing outward. The iris/pupil area is modeled as a slight concavity in the center of the front face (inset + push in 0.005m). Eyes are separate objects from the body mesh so they can have their own emissive material (eyes always glow, body does not). Position eyes inside the sockets with 0.005m clearance from the socket walls. The eyes should look slightly oversized relative to the face — big expressive eyes are key to Globbler's charm.
**Acceptance Criteria:**
- Two eye meshes are positioned inside the head's eye sockets as separate objects
- Eyes are slightly flattened spheres with pupil concavity detail
- Eyes are oversized relative to the face, matching the style guide's expressive character direction

### Task 06.11: Apply Mirror Modifier and Finalize Symmetry
**Status:** TODO
**Description:** If the model was built using a Mirror modifier (recommended), apply it now to create the final symmetric mesh. Before applying: verify the mirror axis is correct (X axis for left/right symmetry), check that the mirror merge threshold (0.001m) eliminates the center seam vertices, and confirm that both sides look identical in all views. After applying, do a final manual check: rotate the model 360 degrees looking for any asymmetry that snuck in, especially around the circuit line geometry which may not have been mirrored perfectly. Fix any asymmetry issues manually.
**Acceptance Criteria:**
- Mirror modifier is applied, creating a fully symmetric mesh
- Center seam vertices are properly merged with no visible split
- 360-degree visual inspection confirms clean symmetry

### Task 06.12: Retopologize to Target Triangle Count
**Status:** TODO
**Description:** If the current mesh exceeds the ~2000 triangle target (check with Blender's Viewport Overlays > Statistics), retopologize to bring it within budget. Use Blender's Decimate modifier (Planar or Un-Subdivide mode) as a starting point, then manually clean up the result to restore quad flow in critical deformation areas (shoulders, elbows, knees, hips, neck). Deformation zones need at least 3 edge loops to bend smoothly. Flat areas (top of head, back of body) can have fewer polygons. Final triangle count target: 1800-2200 triangles (900-1100 quads).
**Acceptance Criteria:**
- Final mesh is within 1800-2200 triangle budget
- Deformation zones (joints) retain sufficient edge loops for smooth bending
- Flat/low-deformation areas are optimized with fewer polygons

### Task 06.13: Verify Clean Mesh for Export
**Status:** TODO
**Description:** Run a comprehensive mesh cleanup check before moving to UV unwrapping. In Blender: (1) Select All > Mesh > Clean Up > Merge by Distance (threshold 0.0001m) to catch any near-duplicate vertices, (2) Recalculate normals outward (Shift+N) to fix any inverted faces, (3) Check for non-manifold edges (Select > All by Trait > Non Manifold) and fix any found, (4) Verify no loose vertices or edges exist, (5) Check face orientation overlay (blue = correct outward normals, red = inverted). The mesh must be watertight (manifold) for proper rendering and collision generation.
**Acceptance Criteria:**
- Zero non-manifold edges or vertices
- All face normals point outward (no red faces in face orientation overlay)
- No loose geometry (vertices, edges, or faces not connected to the main mesh)

### Task 06.14: UV Unwrap Globbler Body
**Status:** TODO
**Description:** UV unwrap the body mesh following the texture workflow standards. Place seams along: center back (head to hips), inner arms, inner legs, bottom of feet, and along circuit line edges (circuit channels create natural seam-hiding locations). Unwrap using Blender's standard Unwrap (Angle Based), then manually adjust islands for minimal stretching. The face/front of the character gets the most UV space (hero face for the camera). Pack islands with 8px margin at 1024x1024 resolution. Apply a checker texture to verify no visible stretching in the 3D viewport.
**Acceptance Criteria:**
- UV seams are placed along hidden edges (back, inner limbs, circuit lines)
- No visible stretching when checker texture is applied (Blender's stretch overlay all blue/green)
- Face/chest UV islands receive proportionally more space than back/underside

### Task 06.15: UV Unwrap Eye Geometry
**Status:** TODO
**Description:** UV unwrap the eye meshes separately from the body. Each eye gets a simple planar projection from the front (since eyes are essentially flat discs facing the camera). The UV layout should map the eye's front face to fill most of the UV space, with the sides and back compressed (rarely visible). Eyes will have their own small texture (256x256 is sufficient) or share a region of the character's 1024x1024 texture. If sharing the main texture, place the eye UV islands in a dedicated corner of the UV space where the eye texture details (iris, pupil, glow) will be painted.
**Acceptance Criteria:**
- Eye UVs are clean planar projections showing the front face clearly
- Eye UV islands are either on a separate 256x256 texture or in a dedicated area of the main 1024
- No visible UV distortion on the eye's visible front surface

### Task 06.16: Test Mesh Deformation with Temporary Rig
**Status:** TODO
**Description:** Before committing to the final model, perform a quick deformation test. Parent the mesh to the armature template from Epic 04 (Task 04.02), use automatic weights (Ctrl+P > Armature Deform > With Automatic Weights), and pose the character in extreme positions: arms raised overhead, arms behind back, legs in a wide step, head turned 45 degrees each way, spine bent forward (bow pose). Check for: mesh collapsing at joints, vertices not moving with the correct bone, ugly stretching at shoulders/hips. If deformation issues appear, add edge loops at the problem joints before proceeding to final UV/texture work.
**Acceptance Criteria:**
- Arms raise overhead without shoulder mesh collapsing or tearing
- Legs achieve a full stride pose without hip mesh folding inside out
- Head turns 45 degrees without neck mesh pinching

### Task 06.17: Create Collision Mesh
**Status:** TODO
**Description:** Build a simplified collision mesh for Globbler's CharacterBody3D. The collision shape should be a simple capsule (0.3m radius, 1.0m height) centered on the character, not a detailed mesh collider. Model this as a low-poly capsule mesh in Blender, name it `globbler-col` (the `-col` suffix tells Godot's importer to treat it as collision), and place it in the Collision collection. Alternatively, skip the Blender collision mesh and configure a CapsuleShape3D directly in Godot (0.3m radius, 1.0m height), which is more performant and easier to adjust.
**Acceptance Criteria:**
- Collision shape is a simple capsule, not a complex mesh collider
- Capsule dimensions (0.3m radius, 1.0m height) encompass the character model
- Collision shape is centered on the character and aligned with the standing position

### Task 06.18: Create Shadow Mesh (Optional)
**Status:** TODO
**Description:** Create a simple circular shadow disc mesh that sits at ground level below Globbler. This is a flat circle (0.4m radius, 8 vertices) with a radial gradient texture (black center fading to transparent edge) that provides a clean stylized shadow without relying on real-time shadow mapping (which can look noisy on small characters). The shadow disc is a separate child node that always stays at ground level (Y=0 relative to the floor) regardless of character Y position (jumping). This technique is common in stylized games and avoids shadow acne artifacts.
**Acceptance Criteria:**
- Shadow disc is a flat circle mesh with gradient transparency texture
- Disc stays at ground level even when the character jumps or is elevated
- Shadow provides clear visual grounding without real-time shadow map artifacts

### Task 06.19: Export Globbler Model to Godot
**Status:** TODO
**Description:** Export the finished Globbler model using the `EnthCharacter` export preset. Export includes: body mesh, eye meshes, armature (from the deformation test), and collision mesh. Do NOT include the reference/guide objects. Verify the export settings: +Y Up, apply modifiers, embed textures (even if placeholder), bone limit 4. Save the .glb to `assets/models/characters/globbler.glb` in the Godot project. After import, verify in Godot: correct scale (1.5m tall), correct orientation (facing -Z forward), mesh visible, armature present, collision shape detected.
**Acceptance Criteria:**
- Exported .glb file is in `assets/models/characters/globbler.glb`
- Model imports at correct 1.5m scale with no orientation correction needed
- Armature and mesh are both present in the Godot scene tree after import

### Task 06.20: Place Globbler in Style Guide Showcase and Review
**Status:** TODO
**Description:** Place the imported Globbler model in the Style Guide Showcase scene (from Epic 02 Task 02.19) under the standard outdoor lighting setup. Apply a temporary flat-color material matching the planned albedo base color (cyan-ish #4AB8B8 for body, white #FFFFFF emissive for eyes). Rotate the model in the scene to verify silhouette from all angles. Take screenshots from front, side, three-quarter, and gameplay camera angles. Compare the silhouette to the concept sketches. Identify any proportion issues that need adjustment before committing to the texture phase. This is the last chance for major geometry changes.
**Acceptance Criteria:**
- Globbler model is visible in the showcase scene with temporary materials
- Screenshots from 4+ angles are saved for review
- Silhouette matches concept sketches and is recognizable at gameplay camera distance

## Dependencies
- Epic 01 (Art Pipeline Setup) for Blender template, export presets, and Godot folder structure
- Epic 02 (Visual Style Guide v3) for proportion rules, edge treatment, and silhouette standards
- Epic 04 (Animation Pipeline) for armature template used in deformation testing

## Notes
- Globbler's design should evoke "cute digital creature" — think Wall-E's expressiveness meets a game console mascot
- The circuit lines are a key design element tying Globbler to the game's digital-world narrative
- Eyes being separate geometry allows them to have independent emissive material and potential eye animation
- The ~2000 triangle budget is generous for a stylized character; prioritize silhouette clarity over detail
- A-pose is used instead of T-pose for better default shoulder deformation
