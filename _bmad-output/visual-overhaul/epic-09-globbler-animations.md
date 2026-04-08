---
epic_id: 09
title: "Epic 09: Globbler Animations"
phase: 3
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 09: Globbler Animations

## Overview
Animate Globbler's complete action set in Blender, covering all gameplay states from idle to death. Each animation follows the style guide's bouncy, exaggerated timing with strong anticipation and follow-through. These animations are the primary way players experience Globbler's personality, so they must be expressive, responsive, and satisfying. Every animation is authored as a separate Blender action, exported via glTF, and integrated into Godot's AnimationTree state machine.

## Success Criteria
- All 12+ required animations are authored, exported, and playing correctly in Godot
- Movement animations (idle, walk, run) blend smoothly in the AnimationTree BlendSpace2D
- Combat animations (attack, hurt, death) have correct timing for hitbox activation and invincibility frames
- Animation events fire reliably for SFX triggers, hitbox timing, and gameplay callbacks

## Tasks

### Task 09.01: Animate Idle — Breathing Loop
**Status:** TODO
**Description:** Create the primary idle animation (`globbler_idle`) as a 90-frame (3.0s) loop at 30 FPS. The idle communicates "alive and aware" through subtle breathing motion. Key poses: Frame 0 — rest pose (default standing position). Frame 22 — inhale peak: chest/spine.001 rotates back 3 degrees, hips translate Y+0.01m (slight rise), shoulders rotate back 2 degrees. Frame 45 — exhale: return to rest pose with slight overshoot (chest forward 1 degree). Frame 67 — settle back to rest. Frame 90 — identical to frame 0 for seamless loop. Add very subtle head bob (1 degree nod following the breathing rhythm). Arms hang naturally with fingertips swaying 0.005m side-to-side using a secondary sine motion.
**Acceptance Criteria:**
- Idle loop is exactly 90 frames (3.0s at 30 FPS) and loops seamlessly
- Breathing motion is visible but subtle — not hyperventilating
- Head and arm secondary motion adds life without distracting from the stillness

### Task 09.02: Animate Idle — Look-Around Variation
**Status:** TODO
**Description:** Create a secondary idle variation (`globbler_idle_look`) as a 150-frame (5.0s) action that plays occasionally over the base idle. This animation has Globbler look left (head rotates Y -30 degrees over 15 frames), hold for 10 frames, look right (head rotates Y +30 degrees over 20 frames), hold for 10 frames, look up slightly (head tilts X -10 degrees, 10 frames), then return to center (15 frames). The eye_target bone (if rigged) moves to follow the look direction. The body stays in the breathing rhythm. This animation adds personality and makes Globbler feel curious about the environment.
**Acceptance Criteria:**
- Look-around animation shows Globbler glancing left, right, and up before resettling
- Head movement is smooth with slight ease-in/ease-out on each turn
- Animation can layer on top of the breathing idle without conflict

### Task 09.03: Animate Walk Cycle
**Status:** TODO
**Description:** Create the walk cycle (`globbler_walk`) as a 20-frame (0.67s) loop. The walk should be bouncy and characterful, matching the chunky art style. Contact poses at frames 0 and 10 (alternating feet). Pass positions at frames 5 and 15 (highest vertical bounce). Key animation details: hips translate Y with a sine wave (amplitude 0.03m, peak at pass positions), hips rotate Z by +/-5 degrees (side-to-side weight shift), spine counter-rotates to hips (chest stays relatively stable), arms swing in opposition to legs (right arm forward when left foot forward), arm swing amplitude is 20 degrees each direction. Feet use a standard walk cycle arc with toe-off and heel-strike.
**Acceptance Criteria:**
- Walk cycle loops seamlessly at 20 frames with clear foot contacts
- Vertical bounce (0.03m) gives the walk a bouncy, energetic feel
- Counter-rotation between hips and chest creates natural torsion

### Task 09.04: Animate Run Cycle
**Status:** TODO
**Description:** Create the run cycle (`globbler_run`) as a 14-frame (0.47s) loop — faster than the walk. The run is more exaggerated: increased vertical bounce (0.05m), more forward lean (spine rotates X 10 degrees forward), wider arm swing (30 degrees each direction), feet lift higher off the ground during pass positions. Key difference from walk: there should be a brief "flight phase" where both feet are off the ground (between contact and pass). Hips side-to-side rotation increases to 8 degrees. Head bobs with a slight delay behind the body (secondary motion). The overall feel should be "determined little creature charging forward."
**Acceptance Criteria:**
- Run cycle is visibly faster and more energetic than the walk
- Flight phase (both feet off ground) exists between contacts
- Forward lean and increased bounce make the run feel urgent

### Task 09.05: Animate Dash
**Status:** TODO
**Description:** Create the dash animation (`globbler_dash`) as an 8-frame (0.27s) one-shot. The dash is a quick burst of movement used for dodging. Frame 0 — anticipation squash: hips drop Y -0.05m, spine compresses, head tucks. Frame 2 — launch: full stretch in the dash direction, body elongates (scale Y 1.1, scale XZ 0.9 via bone scaling), arms trail behind, feet leave ground. Frames 3-6 — travel: body maintains stretched shape, speed blur implied by the extreme pose. Frame 7-8 — landing recovery: body snaps back to normal proportions, slight bounce on landing (overshoot and settle). The squash-stretch effect sells the speed without actual mesh deformation tools.
**Acceptance Criteria:**
- Dash reads as a fast burst even when viewed at normal speed
- Squash (frame 0-1) and stretch (frame 2-6) are visible and exaggerated
- Landing recovery (frame 7-8) provides a satisfying "thud" feeling

### Task 09.06: Animate Primary Attack
**Status:** TODO
**Description:** Create the primary melee attack (`globbler_attack_primary`) as a 12-frame (0.4s) one-shot. Phase breakdown: Anticipation (frames 0-3): torso rotates away from attack direction 20 degrees, attacking arm pulls back, weight shifts to back foot, head tilts down (coiling energy). Swing (frames 3-6): fast rotation toward attack direction 40 degrees (net 20 degrees past neutral), arm sweeps forward in a wide arc, weight transfers to front foot, slight forward lunge (hips translate Z +0.1m). Follow-through (frames 6-12): momentum carries the swing past, torso decelerates, arm returns toward rest, weight centers. Hitbox activates at frame 3, deactivates at frame 6.
**Acceptance Criteria:**
- Attack has clear anticipation, swing, and follow-through phases
- Swing phase (frames 3-6) is fast and impactful, covering 40 degrees of rotation
- Animation method call tracks are placed at frames 3 (hitbox on) and 6 (hitbox off)

### Task 09.07: Animate Charge Attack Start and Loop
**Status:** TODO
**Description:** Create two actions for the charge attack: `globbler_attack_charge_start` (15 frames, 0.5s one-shot transition into charge) and `globbler_attack_charge_loop` (20 frames, 0.67s loop that plays while the player holds the button). Charge start: Globbler plants feet wide, lowers center of gravity (hips Y -0.05m), arms pull back, circuit lines begin pulsing (this is communicated via the emission pulse shader parameter being animated). Charge loop: body vibrates with increasing intensity (small random rotations on spine at 1-2 degrees, arms trembling), particle effects implied by pose tension. The loop sustains the "building energy" feeling.
**Acceptance Criteria:**
- Charge start transitions smoothly from idle/walk into the charged stance
- Charge loop conveys building energy through vibration and tension
- Animation can hold indefinitely without looking robotic (loop point is seamless)

### Task 09.08: Animate Charge Attack Release
**Status:** TODO
**Description:** Create the charge release animation (`globbler_attack_charge_release`) as a 15-frame (0.5s) one-shot. This is the payoff for holding the charge. Frame 0-2 — final power coil: maximum crouch, arms fully pulled back, body at peak tension. Frame 2-5 — explosive release: body springs upward and forward, arms sweep in a massive arc (larger than primary attack), forward lunge (hips Z +0.2m), head whips forward. Frame 5-10 — energy wave: arms fully extended at the peak of the swing, body holds the extreme pose briefly (1-2 frames of hold for emphasis). Frame 10-15 — recovery: slow deceleration back toward rest pose, heavy breathing. Hitbox is larger and active frames 2-7 (wider window than primary).
**Acceptance Criteria:**
- Release feels significantly more powerful than the primary attack
- The brief hold at peak extension (frames 6-7) adds dramatic emphasis
- Recovery is slower than primary attack, creating a risk/reward balance

### Task 09.09: Animate Hurt Reaction
**Status:** TODO
**Description:** Create the hurt/flinch animation (`globbler_hurt`) as a 10-frame (0.33s) one-shot. This animation must be fast and punchy — the player needs to immediately understand they took damage. Frame 0-1 — impact: head snaps back 15 degrees, chest flinches backward 10 degrees, arms fly outward, hips shift backward 0.05m. The motion is INSTANT (within 2 frames) for maximum impact feel. Frame 2-6 — stagger: body holds the flinched position with slight wobble (2-3 degree oscillation on spine). Frame 7-10 — recovery: smooth return to rest/previous pose. Also create a shorter additive version (`globbler_hurt_additive`) that only keys spine/chest/head for the additive animation layer (plays on top of movement without interrupting legs).
**Acceptance Criteria:**
- Hurt reaction communicates damage within the first 2 frames (instant read)
- Full and additive versions exist for different usage contexts
- Recovery is fast enough to not feel like losing control of the character

### Task 09.10: Animate Death
**Status:** TODO
**Description:** Create the death animation (`globbler_death`) as a 30-frame (1.0s) one-shot that does NOT loop. Phase 1 — dramatic hit (frames 0-5): exaggerated version of hurt reaction, body flies backward, arms flung wide, head whips back. Phase 2 — suspension (frames 5-12): body hangs in the air momentarily (the "dramatic float" before falling — a classic animation trope), limbs go limp (IK off, FK with slight ragdoll feel by rotating limbs at random small angles). Phase 3 — collapse (frames 12-25): body falls downward, crumples on the ground, final settling. Phase 4 — dissolve prep (frames 25-30): body reaches final resting pose, held still for the dissolve shader effect to take over.
**Acceptance Criteria:**
- Death animation has dramatic weight with the suspension-before-collapse pattern
- Final resting pose is static and clean for the dissolve shader transition
- Animation feels sad/impactful — the player should feel the loss

### Task 09.11: Animate Level-Up Celebration
**Status:** TODO
**Description:** Create the level-up animation (`globbler_level_up`) as a 45-frame (1.5s) one-shot. This is a pure joy animation — the player just leveled up and should feel rewarded. Frame 0-10 — surprised look up: head tilts back, arms lower, body straightens (realization). Frame 10-20 — jump: anticipation squat (2 frames), launch into air (hips Y +0.3m over 4 frames), arms punch upward in a victory pose. Frame 20-30 — airborne celebration: arms pump, body rotates Y 360 degrees (a full spin in the air), legs tuck up. Frame 30-40 — landing: comes down with bounce (standard squash-stretch landing), arms spread wide. Frame 40-45 — victory pose: chest puffed out, hands on hips, slight head nod of satisfaction.
**Acceptance Criteria:**
- Level-up animation is visibly celebratory and joyful
- Full aerial spin adds excitement and spectacle
- Landing and victory pose are satisfying conclusion moments

### Task 09.12: Animate Interact Gesture
**Status:** TODO
**Description:** Create the interact animation (`globbler_interact`) as a 20-frame (0.67s) one-shot. This plays when the player interacts with NPCs, chests, doors, or objects. The animation is a simple forward reach: Frame 0-5 — lean forward slightly (spine 10 degrees), extend one arm forward (right arm reaches out, hand open). Frame 5-10 — hand makes contact with imaginary object (hand closes slightly, arm stops extending). Frame 10-15 — pull back (arm retracts, spine straightens). Frame 15-20 — return to rest pose. The interaction is generic enough to work for all interactable objects. Keep it subtle and quick so it doesn't slow down gameplay.
**Acceptance Criteria:**
- Interact animation is quick (0.67s) and doesn't interrupt gameplay flow
- Forward reach gesture communicates "touching/activating something"
- Animation works visually for chests, NPCs, doors, and switches without looking wrong for any

### Task 09.13: Export All Animations from Blender
**Status:** TODO
**Description:** Export all completed animations using the `EnthCharacter` export preset with animation data included. Ensure each animation is a separate action in Blender with a fake user assigned (to prevent orphan data deletion). In the export dialog, enable "Export Actions" (or "Group by NLA Track" if that workflow was chosen in Epic 04). Verify that all animation names are correct in the export preview: globbler_idle, globbler_idle_look, globbler_walk, globbler_run, globbler_dash, globbler_attack_primary, globbler_attack_charge_start, globbler_attack_charge_loop, globbler_attack_charge_release, globbler_hurt, globbler_hurt_additive, globbler_death, globbler_level_up, globbler_interact. Export to `assets/models/characters/globbler.glb` (overwriting the mesh-only version).
**Acceptance Criteria:**
- All 14 animations are present in the exported .glb file
- Animation names match the naming convention exactly
- No extra unwanted animations are included (rest pose, default action, etc.)

### Task 09.14: Import and Verify Animations in Godot
**Status:** TODO
**Description:** Import the updated globbler.glb into Godot and verify all animations in the AnimationPlayer. For each animation: (1) Play it in the Godot animation panel and verify it looks correct (no broken bones, no jittering, correct speed), (2) Check loop flag: idle and walk/run should loop, all others should be one-shot, (3) Check duration matches the Blender source (idle: 3.0s, walk: 0.67s, etc.), (4) Verify no bone transform drift (animation ends at the same pose it started for looping clips). Fix any import issues by adjusting Blender export settings or Godot import configuration.
**Acceptance Criteria:**
- All 14 animations play correctly in Godot's AnimationPlayer preview
- Loop flags are correct (loops for idle/walk/run, one-shot for everything else)
- Durations match Blender source within 1 frame tolerance

### Task 09.15: Configure AnimationTree State Machine
**Status:** TODO
**Description:** Build out Globbler's AnimationTree state machine using the template from Epic 04 Task 04.10, now with real animations replacing placeholders. State machine structure: `idle` (plays globbler_idle, randomly triggers globbler_idle_look every 8-15 seconds), `move` (BlendSpace1D blending walk↔run based on speed parameter), `dash` (one-shot, auto-return to move or idle), `attack_primary` (one-shot, auto-return), `attack_charge` (sub-state: start → loop → release), `hurt` (one-shot, auto-return to previous), `death` (one-shot, no return). Connect all transitions with the cross-fade times defined in Epic 04.
**Acceptance Criteria:**
- State machine has all states connected with correct transition rules
- Idle randomly plays look-around variation at natural intervals
- Movement BlendSpace smoothly interpolates between walk and run based on speed

### Task 09.16: Add Animation Method Call Tracks for Combat
**Status:** TODO
**Description:** In Godot's AnimationPlayer, add method call tracks to the combat animations for hitbox timing and SFX triggers. Attack primary: `enable_hitbox()` at 0.1s (frame 3), `disable_hitbox()` at 0.2s (frame 6), `play_sfx("attack_whoosh")` at 0.09s (frame 2.7, just before hitbox). Charge release: `enable_hitbox()` at 0.067s (frame 2), `disable_hitbox()` at 0.233s (frame 7), `play_sfx("charge_release")` at 0.05s. Hurt: `play_sfx("hurt")` at 0.0s (immediate), `start_invincibility()` at 0.0s. Death: `play_sfx("death")` at 0.0s, `disable_all_collision()` at 0.0s, `on_death_animation_finished()` at 1.0s (end of animation).
**Acceptance Criteria:**
- All combat animations have method call tracks at the documented timestamps
- Hitbox enable/disable is driven by animation events, not timers
- SFX calls are placed slightly before visual impact for perceptual synchronization

### Task 09.17: Add Footstep Animation Events
**Status:** TODO
**Description:** Add method call tracks to the walk and run animations for footstep SFX synchronization. Walk cycle: `play_footstep("left")` at 0.0s (frame 0, left foot contact), `play_footstep("right")` at 0.33s (frame 10, right foot contact). Run cycle: `play_footstep("left")` at 0.0s (frame 0), `play_footstep("right")` at 0.23s (frame 7). The footstep function should check the surface material beneath the character (grass, stone, wood, dirt) and play the appropriate sound variant. Also emit a footstep particle event for the VFX system (dust puffs from Epic 10).
**Acceptance Criteria:**
- Footstep SFX play in sync with foot-ground contact frames
- Left and right feet trigger independently for proper stereo panning
- Footstep events include surface type detection for material-appropriate sounds

### Task 09.18: Tune Transition Cross-Fades in AnimationTree
**Status:** TODO
**Description:** Play-test all animation transitions and tune the cross-fade durations for responsiveness. Critical transitions to tune: idle → walk (0.15s — responsive but not jarring), walk → run (0.2s — smooth acceleration feel), any → attack (0.05s — near-instant for responsive combat), attack → idle/walk (0.2s — smooth recovery), any → hurt (0.0s — absolutely instant for damage feedback), any → death (0.0s — immediate), idle → dash (0.05s — near-instant), dash → idle/walk (0.1s — quick recovery). Test each transition by rapidly switching between states and checking for visual glitches (feet sliding, arms teleporting, torso popping).
**Acceptance Criteria:**
- All transitions feel responsive with no perceptible lag between input and animation change
- No visual artifacts (foot sliding, limb teleportation) during cross-fades
- Combat-critical transitions (attack, hurt, death) are near-instant for gameplay responsiveness

### Task 09.19: Create Animation Debug Overlay
**Status:** TODO
**Description:** Build a debug UI overlay that displays the current animation state in real-time during gameplay. Show: current AnimationTree state name, active animation clip name, animation playback position (progress bar), blend weights for BlendSpace (when in move state), queued transition (if any), last animation event fired. Display this as a compact panel in the bottom-left corner using a CanvasLayer with Label nodes. Update every frame via the `_process` function. Gate behind the debug toggle established in Epic 05. This overlay is invaluable for diagnosing animation issues during play-testing.
**Acceptance Criteria:**
- Debug overlay shows current state, animation name, and progress in real-time
- BlendSpace weights are visible when in the movement state
- Overlay updates every frame and is gated behind the debug toggle

### Task 09.20: Conduct Full Animation Integration Test
**Status:** TODO
**Description:** Perform a comprehensive play-test of all animations in the actual game environment (not just test scenes). Walk Globbler through the town, enter a dungeon, engage enemies in combat, take damage, defeat enemies, level up. For each animation, verify: (1) Correct animation plays for the gameplay state, (2) Transitions are smooth and responsive, (3) Animation events fire correctly (footsteps, hitbox timing, SFX), (4) No animation gets stuck (infinite loop on a one-shot, state machine deadlock), (5) Edge cases work: interrupt attack with hurt, dash during walk, level up during combat. Document any issues found and fix them before closing this epic.
**Acceptance Criteria:**
- All animations play correctly during actual gameplay, not just isolated testing
- State machine handles all edge cases (interrupt, rapid input, simultaneous triggers)
- No animation gets stuck or fails to transition back to idle/movement
- Combat hitbox timing works correctly against live enemies in dungeon encounters

## Dependencies
- Epic 04 (Animation Pipeline) for AnimationTree template and export workflow
- Epic 05 (Combat System Fixes) for hitbox/hurtbox system that animation events drive
- Epic 06 (Globbler Character Model) for the finished mesh
- Epic 08 (Globbler Rig & Skeleton) for the production armature and weight painting

## Notes
- All animations are authored at 30 FPS in Blender; Godot interpolates to runtime frame rate
- Animations are authored in-place (no root motion) — movement is script-driven
- The additive hurt animation (Task 09.09) is optional but significantly improves combat feel
- Idle look-around should feel random and natural, not on a fixed timer
- Consider adding subtle procedural animation (breathing, head tracking) via code to supplement baked animations
