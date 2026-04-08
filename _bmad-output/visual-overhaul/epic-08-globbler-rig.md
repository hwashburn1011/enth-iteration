---
epic_id: 08
title: "Epic 08: Globbler Rig & Skeleton"
phase: 3
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 08: Globbler Rig & Skeleton

## Overview
Create a production-quality armature and weight painting for Globbler's character model, building on the armature template from Epic 04 and adapting it to Globbler's specific proportions. This rig must deform cleanly for all planned animations (idle, walk, run, attack, hurt, death, level-up) while staying within Godot's 4-bone-per-vertex influence limit. The rig is the invisible backbone that makes the difference between stiff robotic movement and lively expressive animation.

## Success Criteria
- Armature matches Globbler's proportions with bones correctly positioned at joint centers
- Weight painting produces clean deformation with no mesh tearing, collapsing, or unexpected stretching
- IK constraints work correctly for foot planting and optional hand positioning
- Exported rig imports into Godot with all bones recognized and functional in AnimationPlayer

## Tasks

### Task 08.01: Duplicate and Adapt Armature Template
**Status:** TODO
**Description:** Open the armature template from Epic 04 (`_art_source/template_armature.blend`) and append/link it into Globbler's model file. Scale the armature to fit Globbler's proportions: total height 1.5m, hips bone at 0.5m height (one-third up from ground, center of mass), chest at 0.75m, head at 1.1-1.3m (big head means the neck is short). Adjust arm bones to match Globbler's stubby arm length: shoulder starts at chest width, upper_arm is 0.15m, forearm is 0.12m, hand is 0.08m. Adjust leg bones: thigh is 0.17m, shin is 0.13m, foot is at ground level (Y=0).
**Acceptance Criteria:**
- Armature bones are repositioned to exactly match Globbler's mesh joint locations
- Hips are at center of mass (one-third height for this big-headed character)
- All bone proportions match Globbler's stubby limb lengths

### Task 08.02: Position Spine Chain Bones
**Status:** TODO
**Description:** Adjust the spine bone chain for Globbler's short torso. The chain is: `hips` (at 0.5m height, Y=0.5) → `spine` (at 0.6m, controls lower torso bending) → `spine.001` (at 0.7m, upper torso — may be redundant for this short character) → `chest` (at 0.8m, controls shoulder area). Since Globbler's torso is only 0.5m tall, having 4 spine bones may be excessive. Consider removing `spine.001` and using just `hips` → `spine` → `chest` for a simpler 3-bone spine that still allows adequate bending. Position each bone's head at the center of the mesh cross-section at that height for proper deformation.
**Acceptance Criteria:**
- Spine chain has 3-4 bones positioned at correct heights within the torso mesh
- Each bone is centered horizontally within the mesh cross-section at its height
- Spine can bend forward/backward without the mesh folding inside out

### Task 08.03: Position Neck and Head Bones
**Status:** TODO
**Description:** Adjust the neck and head bones for Globbler's big head on a short neck. `neck` bone: starts at chest top (0.85m), ends at base of head (0.95m) — only 0.1m long (very short neck, head sits close to body). `head` bone: starts at neck end (0.95m), ends at top of head dome (1.45m) — 0.5m long to match the head's size. The head bone's tail position determines the "pivot point" feel when the head rotates. Place the head bone's head (start point) at the center of the neck, not at the jaw line, so head rotation feels natural. Consider adding a single `jaw` bone if mouth animation is planned.
**Acceptance Criteria:**
- Neck bone is short (0.1m) matching Globbler's head-sitting-on-body design
- Head bone spans the full head height for proper rotation
- Head rotation pivots at a natural point (neck base, not head center)

### Task 08.04: Position Arm Bones with A-Pose Angles
**Status:** TODO
**Description:** Fine-tune arm bone positions in the A-pose. `shoulder.L` bone: starts at chest bone, extends 0.05m outward to the shoulder joint (the point where the arm meets the body). `upper_arm.L`: starts at shoulder end, extends 0.15m outward-downward at 15 degrees from horizontal. `forearm.L`: starts at upper_arm end (elbow), extends 0.12m continuing the angle. `hand.L`: starts at forearm end (wrist), extends 0.08m to the center of the mitten hand. Ensure the elbow has a very slight bend (5 degrees) in the A-pose — this defines the preferred bend direction and prevents IK solver ambiguity.
**Acceptance Criteria:**
- Arm bones are positioned at 15 degrees from horizontal (A-pose, not T-pose)
- Elbow has a slight 5-degree pre-bend to define preferred bend direction
- Shoulder bone connects arm chain to chest bone via a short connector bone

### Task 08.05: Position Leg Bones with Proper Knee Bend
**Status:** TODO
**Description:** Fine-tune leg bone positions. `thigh.L`: starts at hips bone side, extends 0.17m downward to the knee. `shin.L`: starts at thigh end (knee), extends 0.13m downward to the ankle. `foot.L`: starts at shin end (ankle), extends 0.1m forward along the ground to the ball of the foot. `toe.L` (optional): extends 0.05m forward to the toe tip. Ensure the knee has a slight forward bend (5 degrees) in the rest pose — this is critical for IK solver stability (prevents knee-flip). The thigh bone should angle slightly inward from hip to knee for a natural standing pose.
**Acceptance Criteria:**
- Leg bones create a natural standing pose with slight knee bend
- Knee pre-bend of 5 degrees is present to stabilize IK solving
- Foot bone extends forward along the ground for proper foot-roll animation

### Task 08.06: Set Up IK Control Bones for Legs
**Status:** TODO
**Description:** Create IK target and pole target bones for each leg, building on the template from Epic 04 Task 04.03. `foot_ik.L` bone: positioned at the foot's ground contact point, parented to the `root` bone (not part of the leg chain). `knee_target.L`: positioned 0.4m in front of the knee, also parented to `root`. Add an IK constraint to `shin.L` targeting `foot_ik.L` with chain length 2, and pole target set to `knee_target.L`. Mark both IK control bones as non-deforming (Bone Properties > Deform: unchecked) so they don't receive vertex weights or export as deform bones.
**Acceptance Criteria:**
- IK foot targets control leg positioning when moved
- Pole targets keep knees pointing forward and prevent knee-flip
- IK control bones are non-deforming and won't interfere with mesh skinning

### Task 08.07: Configure IK Chain Stiffness
**Status:** TODO
**Description:** Tune the IK chain behavior for natural-looking leg bending. Set the IK stiffness on the thigh bone to 0.2 (allows hip rotation to contribute to leg movement) and the shin bone to 0.0 (full IK freedom for the knee). Set the IK stretch factor to 0.0 (bones should never stretch beyond their rest length). Set the IK iterations to 50 and chain length to exactly 2 on each leg. Test the IK by moving the foot_ik target in pose mode: the leg should bend naturally at the knee without the hip flying off or the mesh distorting. If the knee flips when the foot goes behind the body, increase the knee_target distance.
**Acceptance Criteria:**
- Leg IK bends naturally when foot target is moved through full range of motion
- No knee-flip occurs when the foot passes behind or above the body
- IK does not stretch bones beyond their natural length

### Task 08.08: Assign Automatic Weights as Starting Point
**Status:** TODO
**Description:** Parent the Globbler mesh to the armature using automatic weights as a starting point. In Object mode, select the mesh, then Shift-select the armature, press Ctrl+P > Armature Deform > With Automatic Weights. Blender's heat-map algorithm will assign initial vertex weights based on bone proximity. Test the result by entering Pose mode and rotating each bone individually: check hips rotation, spine twist, head tilt, arm raise, leg stride. Automatic weights typically produce 70-80% correct results, with problems at shoulders, hips, and overlapping bone influence areas that will be fixed with manual weight painting.
**Acceptance Criteria:**
- Mesh follows armature bones when posed
- Basic deformation works for simple poses (head turn, arm raise, leg step)
- Problem areas are identified and logged for manual weight painting fixes

### Task 08.09: Weight Paint Head and Neck Region
**Status:** TODO
**Description:** Manually refine vertex weights for the head and neck area. In Weight Paint mode, select the `head` bone and verify that all head vertices are weighted 1.0 to the head bone (pure red in the weight paint overlay). The eyes (separate meshes) should also be fully weighted to the head bone. The neck region needs a smooth gradient: vertices at the top of the neck are 0.8 head / 0.2 chest, vertices at the bottom are 0.2 head / 0.8 chest. Use the Smooth brush to blend weight transitions at the neck. Verify by posing the head at extreme rotation (45 degrees each axis) — the neck should stretch smoothly, not fold.
**Acceptance Criteria:**
- Head vertices are fully weighted to the head bone with no chest bone influence
- Neck region has a smooth weight gradient between head and chest
- Head rotation of 45 degrees produces smooth neck deformation without folding

### Task 08.10: Weight Paint Shoulder and Upper Arm Region
**Status:** TODO
**Description:** Fix the shoulder area weights, which is the most critical and typically problematic deformation zone. The shoulder joint needs a clean falloff from `chest` to `shoulder.L` to `upper_arm.L`. Vertices directly at the armpit should be weighted: 0.5 chest / 0.5 upper_arm with zero shoulder influence (shoulder is a short connector). Vertices on the shoulder cap: 0.8 shoulder / 0.2 upper_arm. Vertices on the upper body near the arm: 0.9 chest / 0.1 shoulder. Use the Subtract brush to remove unwanted bone influences in this area. Test by raising the arm overhead — the armpit mesh should stretch smoothly without collapsing.
**Acceptance Criteria:**
- Arm raises to overhead without the shoulder mesh tearing or collapsing inward
- Arm lowered to rest returns to its default shape without residual distortion
- No more than 3 bones influence any single vertex in the shoulder region

### Task 08.11: Weight Paint Arm and Hand Region
**Status:** TODO
**Description:** Refine weights along the arm chain. Upper arm vertices: fully weighted to `upper_arm.L` (1.0). Elbow region: gradient from `upper_arm.L` (1.0 at mid-upper-arm) through a 0.5/0.5 split at the elbow bend point to `forearm.L` (1.0 at mid-forearm). Wrist region: gradient from `forearm.L` to `hand.L` over a very short distance (Globbler's wrists are short). Hand/mitten vertices: fully weighted to `hand.L` (1.0). Test by bending the arm 120 degrees at the elbow — the mesh should compress on the inner elbow and stretch on the outer elbow without vertices poking through.
**Acceptance Criteria:**
- Elbow bend to 120 degrees produces clean deformation on both inner and outer surfaces
- Wrist rotation doesn't cause candy-wrapper twist (keep wrist influence zone narrow)
- Hand vertices are exclusively controlled by the hand bone

### Task 08.12: Weight Paint Hip and Thigh Region
**Status:** TODO
**Description:** Fix the hip area weights, the second most problematic deformation zone. Vertices at the hip joint between body and leg need careful painting: outer hip 0.5 hips / 0.5 thigh, inner thigh 0.7 thigh / 0.3 hips, groin area 0.8 hips / 0.2 thigh. The body (above the hip joint) should have zero thigh influence. Test by posing a wide stride (one leg forward 45 degrees, one leg back 45 degrees) — the crotch area should stretch without the mesh folding inside the body. Use the Lock feature in weight paint to lock all non-relevant bones while painting each bone's weights.
**Acceptance Criteria:**
- Full stride pose (45 degrees forward/back) produces clean hip deformation
- Crotch area does not fold inside the body during leg movement
- Body vertices above the hip joint have zero leg bone influence

### Task 08.13: Weight Paint Leg and Foot Region
**Status:** TODO
**Description:** Refine weights along the leg chain. Thigh vertices: 1.0 to `thigh.L`. Knee region: gradient from thigh to shin over a 0.05m zone centered on the knee joint. Shin vertices: 1.0 to `shin.L`. Ankle region: gradient from shin to foot over a very short zone. Foot vertices: 1.0 to `foot.L`. If toe bone exists, toe tip vertices: 1.0 to `toe.L` with a gradient at the ball of the foot. Test knee bend to 90 degrees (deep squat) — the back of the knee should stretch and the front should compress without pinching. Test foot rotation for walk cycle foot-roll.
**Acceptance Criteria:**
- Knee bend to 90 degrees produces smooth deformation without pinching
- Foot rotation works for walk cycle foot-roll animation
- Ankle doesn't candy-wrapper twist during foot yaw rotation

### Task 08.14: Verify 4-Bone Influence Limit Per Vertex
**Status:** TODO
**Description:** Check that no vertex is influenced by more than 4 bones, which is Godot's default limit. In Blender, use the "Limit Total" operator: select the mesh, go to Weight Paint mode > Weights > Limit Total, set limit to 4. This automatically reduces any vertex with more than 4 bone influences to only the 4 strongest, renormalizing the weights. After running Limit Total, re-test all extreme poses to verify the cleanup didn't introduce deformation artifacts. The shoulder and hip areas are most likely to have excessive influences from automatic weights.
**Acceptance Criteria:**
- No vertex has more than 4 bone influences
- Running Blender's "Limit Total" operator with limit 4 produces no visible deformation change
- All extreme poses still deform correctly after the limit is applied

### Task 08.15: Add Custom Bone Shapes for Posing
**Status:** TODO
**Description:** Assign custom bone shapes to make the rig intuitive for animation. Create simple mesh shapes: a circle for the `root` bone (ground plane controller), a diamond for `hips` (center of mass), arrows for spine/chest/neck (pointing up along the spine), spheres for IK targets (foot_ik, hand_ik), cube for the head, and flat rectangles for limb bones. Assign shapes via Bone Properties > Viewport Display > Custom Shape. Scale each shape to be visible but not cluttering. These shapes make it immediately obvious which bone controls which body part during animation work.
**Acceptance Criteria:**
- Every bone in the rig has a custom shape assigned (no default octahedra visible)
- Shapes are intuitively matched to function (arrows for direction, spheres for targets)
- Shapes are scaled appropriately for Globbler's proportions

### Task 08.16: Create Bone Constraint for Eye Tracking (Optional)
**Status:** TODO
**Description:** Add a "Track To" constraint on the eye meshes (or a dedicated `eye_target` bone) so Globbler's eyes can look toward a target point. Create a single `eye_target` bone parented to `root`, positioned 2m in front of the face at eye height. Add a Track To constraint on each eye's parent bone (or directly on the eye mesh objects) targeting the `eye_target` bone, with -Z as the Track axis and Y as the Up axis. Limit the tracking angle to +/- 30 degrees from forward using the constraint's influence or manual clamping in the animation to prevent eyes from rotating unnaturally far.
**Acceptance Criteria:**
- Moving the eye_target bone causes both eyes to look toward it
- Eye tracking is limited to +/- 30 degrees to prevent unnatural rotation
- Eye target bone is non-deforming and easily keyframeable for look-around animations

### Task 08.17: Test Full Deformation Range
**Status:** TODO
**Description:** Perform a comprehensive deformation test by posing Globbler in every extreme position needed for the planned animation set. Test poses: (1) Arms raised overhead (idle stretch), (2) Deep squat (landing), (3) Full stride (walk/run extreme), (4) Torso twist 45 degrees (attack wind-up), (5) Head tilt each direction 30 degrees (look-around), (6) Spine forward bend 30 degrees (hurt flinch), (7) Asymmetric pose: one arm up, one down, twist (complex action), (8) Collapse pose: spine curled, limbs folded under (death). For each pose, check for mesh collapse, pinching, stretching, and vertex poke-through. Fix any issues with weight paint adjustments.
**Acceptance Criteria:**
- All 8 test poses produce clean deformation with no mesh artifacts
- Weight paint adjustments from testing are saved
- Screenshot gallery of all test poses is saved for reference

### Task 08.18: Export Rig and Verify in Godot
**Status:** TODO
**Description:** Export the rigged Globbler model using the `EnthCharacter` export preset. The export should include: body mesh, eye meshes (parented to head bone or eye bones), armature with all deform bones, and bone hierarchy. Non-deform bones (IK targets, pole targets, custom shape references) should be excluded from export (ensure they are marked as non-deforming). After import into Godot, verify: (1) Skeleton3D node exists with correct bone count, (2) Mesh deforms when bones are manipulated in the Godot editor's skeleton tool, (3) Bone names match the naming convention, (4) No "orphan bone" warnings in the import log.
**Acceptance Criteria:**
- Exported .glb imports cleanly with Skeleton3D and MeshInstance3D nodes
- Only deformation bones are present in the Godot skeleton (no IK helpers)
- Bone manipulation in Godot's editor produces correct mesh deformation

### Task 08.19: Configure Godot Skeleton Profile
**Status:** TODO
**Description:** Set up a SkeletonProfileHumanoid (or custom SkeletonProfile) in Godot for Globbler's skeleton. Map each bone in the profile to the corresponding bone in the imported skeleton: hips → hips, spine → spine, chest → chest, head → head, left_upper_arm → upper_arm.L, etc. This profile enables Godot's retargeting system to share animations between characters with different proportions. Save the profile as `assets/models/characters/globbler_skeleton_profile.tres`. Verify the profile by applying a test animation through the retarget system.
**Acceptance Criteria:**
- Skeleton profile maps all major bones to Godot's humanoid standard naming
- Profile is saved as a reusable .tres resource
- Retargeting system recognizes the profile and can apply test animations

### Task 08.20: Create Rig Documentation and Bone Reference Sheet
**Status:** TODO
**Description:** Create a reference document listing every bone in Globbler's rig with its purpose, rest position, and weight painting notes. Format as a table: Bone Name | Parent | Deform | Purpose | Weight Notes. Example row: `upper_arm.L | shoulder.L | Yes | Left upper arm rotation | Gradient with chest at shoulder, gradient with forearm at elbow`. Include a visual diagram (screenshot of the rig in Blender with bone names labeled) for quick reference. This document helps anyone working with the rig understand the bone hierarchy without opening Blender. Save to `_bmad-output/visual-overhaul/globbler-rig-reference.md`.
**Acceptance Criteria:**
- Every bone is listed with parent, deform flag, purpose, and weight painting notes
- Visual diagram shows the bone hierarchy labeled on the character
- Document is comprehensive enough for someone to fix weight painting issues without prior context

## Dependencies
- Epic 04 (Animation Pipeline) for armature template and bone naming conventions
- Epic 06 (Globbler Character Model) for the finished mesh to rig
- Epic 01 (Art Pipeline Setup) for export presets

## Notes
- The 4-bone influence limit is a hard constraint from Godot's default GPU skinning
- A-pose is used throughout (not T-pose) for better default shoulder deformation
- IK is primarily for legs (foot planting); arms mostly use FK in animation
- Eye tracking is a nice-to-have that adds personality during idle and cutscenes
- The rig should be tested with placeholder animations before committing to full animation production
