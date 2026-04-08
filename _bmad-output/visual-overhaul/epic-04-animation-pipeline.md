---
epic_id: 04
title: "Epic 04: Animation Pipeline"
phase: 1
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 04: Animation Pipeline

## Overview
Establish the complete animation production pipeline from Blender armature setup through Godot AnimationPlayer and AnimationTree integration. This epic covers bone naming standards, IK constraint configuration, animation action organization in Blender's NLA editor, export workflows, and the Godot-side blend tree setup that drives character animation during gameplay. A solid animation pipeline is critical because every character, enemy, and NPC needs consistent, well-timed animations.

## Success Criteria
- Armature naming conventions are standardized so all characters share compatible skeletons for potential animation reuse
- Animation actions export cleanly from Blender to Godot with correct naming, looping flags, and timing
- Godot AnimationTree blend trees are documented and templated for player and enemy movement
- Animation events (notifies) are reliably triggering SFX and gameplay callbacks at the correct frames

## Tasks

### Task 04.01: Define Armature Bone Naming Convention
**Status:** TODO
**Description:** Document the mandatory bone naming convention for all humanoid characters, following Blender's standard naming with `.L`/`.R` suffixes for automatic symmetry. Root bone hierarchy: `root` (world-space anchor, no deformation) → `hips` (center of mass) → `spine` → `spine.001` → `chest` → `neck` → `head`. Arms: `chest` → `shoulder.L` → `upper_arm.L` → `forearm.L` → `hand.L` → `finger_index.L` (optional). Legs: `hips` → `thigh.L` → `shin.L` → `foot.L` → `toe.L`. This naming matches Blender's Rigify conventions for familiarity and ensures Godot's retarget system can map between characters if needed.
**Acceptance Criteria:**
- Every bone in the hierarchy is named and documented with its parent relationship
- `.L`/`.R` suffix convention is mandatory for all paired bones
- Naming matches Blender Rigify conventions for compatibility with standard animation tools

### Task 04.02: Create Armature Template in Blender
**Status:** TODO
**Description:** Build a reusable armature template in Blender (`_art_source/template_armature.blend`) with all bones from the naming convention pre-created, correctly positioned for a 1.5m tall humanoid character, and colored by bone group (spine = yellow, arms = blue, legs = green, root/hips = red). Set the armature display mode to "Wire" for clean viewport display. Add custom bone shapes (circles for hips/chest, arrows for limbs, box for root) to make posing intuitive. This template is duplicated and scaled for each new character.
**Acceptance Criteria:**
- Armature template file exists with all humanoid bones correctly named and parented
- Bone groups are colored for visual identification in pose mode
- Custom bone shapes are assigned making the rig more intuitive than default octahedra

### Task 04.03: Set Up IK Constraints for Legs
**Status:** TODO
**Description:** Add Inverse Kinematics constraints to the leg chains in the armature template. Each leg gets an IK constraint on `shin.L`/`shin.R` targeting a `foot_ik.L`/`foot_ik.R` control bone (parented to root, not part of the deformation chain). Chain length is 2 (thigh → shin). Add a pole target bone `knee_target.L`/`knee_target.R` positioned 0.5m in front of the knee to prevent knee-flip. The IK targets allow foot planting and ground-contact animations without manual FK posing of each bone. Mark IK bones as non-deforming so they don't export as weighted bones.
**Acceptance Criteria:**
- IK constraints on both legs target foot_ik control bones with chain length 2
- Pole targets prevent knee direction flipping during animation
- IK control bones are marked non-deforming and excluded from mesh skinning export

### Task 04.04: Set Up IK Constraints for Arms (Optional)
**Status:** TODO
**Description:** Add optional IK constraints for the arms, disabled by default (influence 0.0) but available when needed for specific animations (e.g., reaching for objects, holding weapons in fixed positions). Arm IK target: `hand_ik.L`/`hand_ik.R` control bones parented to root. Chain length is 2 (upper_arm → forearm). Pole target `elbow_target.L`/`elbow_target.R` positioned behind the elbow. Since most animations use FK arms (more natural-looking arm swings), IK is only enabled per-animation via keying the constraint influence from 0.0 to 1.0.
**Acceptance Criteria:**
- Arm IK constraints exist but are disabled by default (influence 0.0)
- Constraint influence can be keyframed per-animation action for selective use
- Pole targets prevent elbow direction flipping when IK is active

### Task 04.05: Define Animation Action Naming Convention
**Status:** TODO
**Description:** Document the naming convention for Blender animation actions that maps directly to Godot animation names. Format: `charactername_actionname` in snake_case. Standard action set for player: `globbler_idle`, `globbler_walk`, `globbler_run`, `globbler_dash`, `globbler_attack_primary`, `globbler_attack_charge_start`, `globbler_attack_charge_loop`, `globbler_attack_charge_release`, `globbler_hurt`, `globbler_death`, `globbler_interact`, `globbler_level_up`. Standard action set for enemies: `enemyname_idle`, `enemyname_walk`, `enemyname_attack_01`, `enemyname_hurt`, `enemyname_death`, `enemyname_spawn`. Each action must have its own fake user in Blender to prevent orphan data deletion.
**Acceptance Criteria:**
- Naming convention table lists all standard actions for player, NPCs, and enemies
- Fake user requirement is documented to prevent Blender from purging unused actions
- Names use snake_case and map 1:1 to Godot AnimationPlayer clip names

### Task 04.06: Configure NLA Editor Workflow
**Status:** TODO
**Description:** Document the Blender NLA (Non-Linear Animation) editor workflow for organizing multiple animation actions on a single character. Each animation action is created in the Action Editor, then pushed down to an NLA strip. Strips should be stacked vertically (not overlapping) with each action on its own NLA track. Enable "Solo" on the track being worked on to isolate it during editing. Mute all NLA tracks before export so that the action editor's active action is what plays in preview. This workflow prevents action contamination where editing one animation accidentally modifies another.
**Acceptance Criteria:**
- NLA workflow is documented with screenshots showing correct track organization
- Solo and Mute features are explained for isolating animations during editing
- Warning about action contamination is included with prevention steps

### Task 04.07: Define Animation Timing Standards
**Status:** TODO
**Description:** Document frame rate and duration standards for all animation types. All animations are authored at 30 FPS in Blender (Godot interpolates to the game's frame rate). Timing guide: idle loop 60-120 frames (2-4 seconds), walk cycle 20 frames (0.67s per cycle), run cycle 14 frames (0.47s per cycle), dash 8 frames (0.27s), attack_primary 12 frames (0.4s: 3 frames anticipation, 3 frames swing, 6 frames follow-through), hurt reaction 10 frames (0.33s), death 30 frames (1.0s), interact 20 frames (0.67s). These timings must feel snappy, matching the style guide's "exaggerated anticipation, fast execution" rule.
**Acceptance Criteria:**
- Frame counts and durations are specified for every standard animation type
- Timing breakdown shows anticipation, action, and recovery phases for combat animations
- 30 FPS authoring standard is stated with explanation of Godot's interpolation

### Task 04.08: Set Up Animation Export Configuration
**Status:** TODO
**Description:** Configure the glTF export settings for animation data. In the `EnthCharacter` export preset, enable "Group by NLA Track" so each NLA track becomes a separate animation clip in Godot. Alternatively, if using the Action-based workflow, enable "Export Actions" and disable "Group by NLA Track". Test both approaches and document which produces cleaner results in Godot. Set the animation sampling rate to match the authoring FPS (30). Enable "Optimize Animations" to remove redundant keyframes. Verify that loop flags are preserved (Blender marks looping actions; Godot should detect them).
**Acceptance Criteria:**
- Export configuration is documented with exact settings for animation data
- Either NLA Track grouping or Action export is chosen and justified
- Loop detection is verified: animations marked as looping in Blender loop correctly in Godot

### Task 04.09: Set Up Godot AnimationPlayer Integration
**Status:** TODO
**Description:** Document the Godot-side workflow for imported animations. When a character .glb is imported, Godot creates an AnimationPlayer node with all animation clips. Document how to: (1) Access the AnimationPlayer in the imported scene, (2) Set loop mode on cycling animations (idle, walk, run) via the Animation panel's loop button, (3) Set one-shot mode on non-looping animations (attack, hurt, death), (4) Adjust animation speed scale if Blender timing needs tweaking in-engine, (5) Set up the animation library so animations can be referenced by name in code (e.g., `$AnimationPlayer.play("walk")`).
**Acceptance Criteria:**
- AnimationPlayer setup steps are documented with Godot editor screenshots
- Loop vs. one-shot configuration is specified per animation type
- Code examples show how to play, stop, and queue animations from GDScript

### Task 04.10: Create AnimationTree Blend Tree Template for Player Movement
**Status:** TODO
**Description:** Build an AnimationTree resource for Globbler's movement system using a BlendSpace2D node for directional movement. The BlendSpace2D maps the player's movement vector to blended animations: center = idle, edges = walk at various directions, outer ring = run. Set the blend tree structure: Root (AnimationNodeStateMachine) → states: `idle_blend` (BlendSpace2D for idle variations), `move_blend` (BlendSpace2D for walk/run), `dash` (one-shot), `attack` (sub-state machine for attack combos), `hurt` (one-shot), `death` (one-shot). Save as a reusable .tres template.
**Acceptance Criteria:**
- AnimationTree has a state machine root with at least 6 states
- Movement uses BlendSpace2D for smooth directional blending
- Template is saved as .tres and documented for reuse on NPCs/enemies with different animation sets

### Task 04.11: Configure AnimationTree State Machine Transitions
**Status:** TODO
**Description:** Set up all transition rules between AnimationTree states. Movement transitions: `idle_blend` ↔ `move_blend` (auto-transition based on speed parameter, threshold 0.1), `move_blend` → `dash` (triggered by dash input, auto-return after playback), any state → `hurt` (triggered by damage event, auto-return to previous state after playback), any state → `death` (triggered by death event, no return), `idle_blend`/`move_blend` → `attack` (triggered by attack input, auto-return after playback). Set cross-fade times: 0.1s for most transitions, 0.0s for hurt (instant reaction), 0.2s for attack → idle (smooth recovery).
**Acceptance Criteria:**
- All state transitions are documented with trigger conditions and cross-fade durations
- Priority rules handle conflicting inputs (death overrides everything, hurt overrides attack)
- Cross-fade times are short enough for responsive gameplay feel

### Task 04.12: Set Up Animation Events (Method Calls) for SFX Timing
**Status:** TODO
**Description:** Document how to add method call tracks to animations in Godot's AnimationPlayer for triggering SFX and gameplay events at precise frames. Key events to add: walk cycle footstep SFX at frames where feet contact ground (usually frame 5 and 15 of a 20-frame walk), attack damage activation at the swing frame (frame 4 of 12), attack SFX whoosh at swing start (frame 3), hurt SFX at frame 0 (immediate), death SFX at frame 0, dash SFX at frame 0. Each method call invokes a function on the character script (e.g., `_on_animation_event("footstep_left")`).
**Acceptance Criteria:**
- Method call tracks are set up for footsteps, attack hits, and reaction SFX
- Frame numbers for each event are documented relative to the animation's total length
- The character script's event handler function signature is documented

### Task 04.13: Create Animation-to-Hitbox Timing System
**Status:** TODO
**Description:** Design and document the system that activates/deactivates hitboxes in sync with attack animations. During attack_primary: hitbox is disabled during anticipation frames (0-3), enabled during swing frames (3-6), disabled during follow-through (6-12). Use animation method call tracks to invoke `enable_hitbox()` and `disable_hitbox()` at the correct frames. The HitboxComponent should have a `set_active(enabled: bool)` method that toggles the collision shape's disabled property. This prevents damage from registering during wind-up or recovery.
**Acceptance Criteria:**
- Hitbox activation/deactivation is driven by animation events, not timers
- Active frames for each attack animation are documented (e.g., frames 3-6 of 12)
- The system prevents damage during anticipation and follow-through phases

### Task 04.14: Build Animation Preview Tool Scene
**Status:** TODO
**Description:** Create a Godot debug scene (`scenes/test/AnimationPreview.tscn`) with a character model, AnimationPlayer, and a simple UI panel listing all available animations as buttons. Clicking a button plays that animation. Add a speed slider (0.1x to 2.0x) for reviewing timing, a frame-step button for advancing one frame at a time, and a loop toggle. This tool allows rapid animation review without launching the full game. Include a grid floor and rotating camera for viewing from any angle.
**Acceptance Criteria:**
- Preview scene loads any character and lists all their animations as clickable buttons
- Speed slider and frame-step controls allow detailed timing review
- Rotating camera allows viewing animation from front, side, and three-quarter angles

### Task 04.15: Define Enemy Animation Requirements by Type
**Status:** TODO
**Description:** Document the minimum animation set required for each enemy type in the game. Basic melee enemy: idle, walk, attack_01, hurt, death (5 animations). Ranged enemy: add attack_ranged (6 total). Elite enemy: add attack_02, attack_telegraph (8 total). Boss: add phase_transition, special_attack_01, special_attack_02, enrage_idle (12+ total). NPCs: idle, walk, talk (mouth flap or gesture), interact (hand up or wave), emote_happy, emote_sad (6 animations). This list feeds into sprint planning for animation production scheduling.
**Acceptance Criteria:**
- Animation requirements table lists every enemy type with their required animation set
- Minimum vs. stretch goal animations are distinguished (required vs. nice-to-have)
- Total animation count across all character types is tallied for production planning

### Task 04.16: Set Up Additive Animation Layer for Hit Reactions
**Status:** TODO
**Description:** Configure an additive animation layer in the AnimationTree that plays hit reaction animations on top of whatever the character is currently doing. This allows the character to flinch while still walking or mid-attack without interrupting the base animation. In the AnimationTree, add an AnimationNodeAdd2 that blends the base state machine output with a hurt_additive animation. The hurt_additive animation only keys the spine and head bones (flinch backward) and fades out over 0.3s. This creates more responsive-feeling combat without complex state machine interrupts.
**Acceptance Criteria:**
- Additive layer plays hurt reaction on top of any base animation
- Only spine/chest/head bones are affected, leaving legs mid-stride
- Fade-out duration (0.3s) is tuned so the flinch is visible but doesn't linger

### Task 04.17: Create Root Motion Configuration Guide
**Status:** TODO
**Description:** Document whether the project uses root motion or script-driven movement, and configure accordingly. For Enth: Iteration, use script-driven movement (CharacterBody3D.velocity) with animations playing in-place (character moves via code, animation provides visual). This means all walk/run animations must be authored with the character moving in-place on the origin, not traveling through world space. Document the Blender setup: animate the character with the hips bone staying at origin on X/Z, only bobbing on Y for bounce. Explicitly disable "Root Motion" in Godot's AnimationTree to prevent conflicts with script movement.
**Acceptance Criteria:**
- Script-driven movement is chosen and justified over root motion for this project
- Blender animation authoring rules enforce in-place animation (no X/Z hip translation)
- Godot AnimationTree root motion is explicitly disabled

### Task 04.18: Set Up Animation Retargeting Between Characters
**Status:** TODO
**Description:** Document Godot 4.4's skeleton retargeting system for sharing animations between characters with different proportions. Since all characters use the same bone naming convention, the retarget system can map animations from one skeleton to another. Configure a SkeletonProfileHumanoid on the player character and test applying the player's walk animation to an NPC of different proportions. Document any bone mapping adjustments needed. This allows idle and walk animations to be shared across NPCs, reducing the total number of unique animations needed.
**Acceptance Criteria:**
- Retargeting is configured and tested between at least two different character meshes
- Bone mapping adjustments (if any) are documented per character type
- Shared animation list identifies which animations can be retargeted vs. which need unique versions

### Task 04.19: Create Animation Production Schedule
**Status:** TODO
**Description:** Build a production schedule estimating time per animation and total animation work. Time estimates: simple loop (idle, walk) = 2-3 hours each. Complex action (attack, death) = 4-6 hours each. Simple one-shot (hurt, interact) = 1-2 hours each. Calculate totals: Globbler needs ~12 animations (estimated 40 hours), each basic enemy needs 5 animations (estimated 15 hours per enemy), NPCs need 6 shared + 2 unique each (estimated 6 hours per NPC after shared animations exist). Total animation work estimate feeds into sprint planning.
**Acceptance Criteria:**
- Time estimates per animation complexity tier are documented
- Total hours are calculated for all planned characters, enemies, and NPCs
- Schedule identifies which animations should be produced first (player, then enemies, then NPCs)

### Task 04.20: Execute Full Animation Pipeline Smoke Test
**Status:** TODO
**Description:** Perform an end-to-end animation pipeline test. Using the armature template, skin it to a simple test character (a capsule with arms and legs is fine). Animate a 20-frame walk cycle and a 12-frame attack in Blender, push both actions to NLA tracks, export via the `EnthCharacter` preset. Import into Godot, verify AnimationPlayer has both clips with correct names. Set up an AnimationTree with idle/walk/attack states, connect it to a test script that moves the character with WASD and attacks with mouse click. Verify smooth transitions, correct loop flags, and that an animation method call event fires at the attack's hit frame.
**Acceptance Criteria:**
- Walk and attack animations play correctly in Godot after Blender export
- AnimationTree transitions work: idle → walk → idle, any → attack → return
- A method call track fires at the attack hit frame, confirmed by debug output

## Dependencies
- Epic 01 (Art Pipeline Setup) for export presets and folder structure
- Epic 02 (Visual Style Guide v3) for animation style rules (bouncy, exaggerated timing)

## Notes
- All animations target 30 FPS authoring; Godot interpolates to runtime frame rate
- The project uses script-driven movement, not root motion
- Blender's Action Editor is preferred over Dope Sheet for per-action workflow
- Godot 4.4's improved AnimationTree and retargeting features should be leveraged
- Consider AnimationLibrary for organizing shared animations across multiple characters
