---
epic: 14
title: "Corrupted Compiler Boss"
phase: 3
status: TODO
priority: high
estimated_hours: 90
dependencies: [1, 2, 3, 4, 5]
---

# Epic 14: Corrupted Compiler Boss Full Rebuild

## Overview

Complete visual rebuild of the Corrupted Compiler -- the first major boss encounter in Enth: Iteration. This is a massive multi-phase boss that blends mechanical horror with organic corruption, representing a core system process that has been consumed by the simulation's decay. The boss is significantly larger and more visually complex than standard enemies, requiring a more detailed model, multi-state textures, articulated rig with many moving parts, and a full cinematic animation set covering three distinct combat phases plus transitions.

**Visual Identity:** A towering mechanical construct (3m tall) that was once an orderly compiler process -- angular server-rack body, articulated arms with tool-attachments, a monitor-like "head" displaying garbled code. As the fight progresses, organic corruption cracks spread across the mechanical surface, revealing pulsing red biomechanical tissue beneath the metal shell. By phase 3, half the mechanical exterior has crumbled away, exposing a writhing corrupted mass with tendrils.

**Quality Target:** This is the visual showpiece of the demo dungeon. Higher detail than standard enemies: up to 5,000 tris, 1024x1024 texture atlas, detailed animations with cinematic quality for phase transitions. Must look imposing and horrifying -- the moment the player enters the boss arena and sees this thing, they should feel dread.

## Success Criteria

- [ ] Boss model is imposing at 3m tall with mechanical + organic horror elements
- [ ] Three texture states: intact (Phase 1), cracked (Phase 2), corrupted (Phase 3)
- [ ] Articulated rig with mechanical arms, head, and corruption tendrils
- [ ] Phase transition animations are cinematic quality
- [ ] Special attack animations are distinct and telegraphed per phase
- [ ] Death sequence is dramatic and satisfying
- [ ] Polycount under 5,000 tris; single 1024x1024 texture atlas
- [ ] Integrated with boss fight state machine in Godot

---

## Tasks

### Task 14.1: Boss Concept Art and Phase Design Document
**Status:** TODO
**Description:** Create a comprehensive concept sheet documenting the boss across all three phases. Phase 1 (Intact Compiler, 100-66% HP): clean mechanical form, server-rack torso with blinking LED-like lights, two articulated arms (left arm ends in a clamp/grabber, right arm ends in a spinning compile-wheel), monitor head displaying scrolling green code, legs are heavy industrial pistons. Phase 2 (Cracking, 66-33% HP): cracks appear across the torso plates, red glow visible through cracks, one arm partially corrupted (organic tendrils wrapping around mechanical parts), monitor flickers between code and error messages, posture becomes more hunched/aggressive. Phase 3 (Corrupted, 33-0% HP): half the mechanical shell crumbled away, exposed biomechanical mass with pulsing veins, corruption tendrils burst from the back, monitor shows only static/red error, movement becomes erratic and desperate. Sketch all three phases from front and isometric views.
**Acceptance Criteria:**
- All 3 phases sketched from front and isometric views
- Clear progression from mechanical to corrupted documented
- Arm attachments (clamp, compile-wheel) designed
- Monitor head display states per phase defined
- Size relationship to player character illustrated (boss is ~4x Globbler height)
- Color progression documented: blue/green (P1) to orange/red (P2) to red/black (P3)

### Task 14.2: Model -- Mechanical Torso and Base Frame
**Status:** TODO
**Description:** Model the boss torso using hard-surface techniques. The torso is a server-rack inspired box shape (~1.2m wide x 0.6m deep x 1.5m tall) with beveled edges and panel lines. Add ventilation slat details on the sides (5-6 horizontal grooves). Model the front panel with a recessed area for the monitor head mount. Add structural frame elements: visible I-beam-like supports at the corners, bolted junction plates at structural connections. The lower torso transitions to a hip joint area where the legs connect. Add a back panel with a large exhaust grate. Use Boolean operations or knife tool for panel line details, then clean up topology. This is the foundation piece -- everything attaches to or emerges from this torso.
**Acceptance Criteria:**
- Server-rack proportioned torso with beveled edges
- Ventilation slats on sides (5-6 grooves)
- Recessed monitor mount area on front
- Structural frame elements (I-beams, junction plates)
- Hip joint connection area at bottom
- Back exhaust grate modeled
- Clean topology suitable for UV unwrapping (~1,200-1,500 tris)

### Task 14.3: Model -- Arms and Tool Attachments
**Status:** TODO
**Description:** Model two articulated mechanical arms. Each arm has: shoulder joint (ball-socket housing), upper arm (cylindrical piston segment, 0.8m), elbow joint (visible hinge mechanism), forearm (slightly thinner cylinder, 0.6m), wrist joint (rotating ring). Left arm terminates in a clamp/grabber (two opposing jaw plates that open/close, ~0.3m span). Right arm terminates in a compile-wheel -- a circular saw-like disc with glowing code symbols on the rim (0.4m diameter). Both tools should look industrial and dangerous. Add hydraulic cable details (small cylindrical tubes) running along the arms between joints. Model each arm segment as a separate object parented to the assembly for easy rigging.
**Acceptance Criteria:**
- Two arms with shoulder/upper/elbow/forearm/wrist segments
- Left arm: clamp/grabber with opening jaw mechanism
- Right arm: compile-wheel disc with symbol rim detail
- Visible hinge and ball-socket joint mechanisms
- Hydraulic cable details along arm segments
- Each segment as a separate object for rigging
- Arms total ~800-1,000 tris combined

### Task 14.4: Model -- Head Monitor and Legs
**Status:** TODO
**Description:** Model the monitor head: a CRT-style boxy monitor (~0.4m wide x 0.3m tall x 0.25m deep) with a slightly curved screen face and thick bezels. Add a mounting bracket connecting head to torso (allowing tilt/swivel). Model a simple antenna array on top (2-3 thin rods). For the legs: two industrial piston-style legs with a heavy upper thigh (rectangular cross-section with panel lines), a hydraulic knee joint (visible cylinder), and a lower shin terminating in a wide flat foot pad (0.3m diameter, like an industrial robot base). Legs should be positioned wide for a stable, imposing stance. The feet connect to the ground with a slight forward angle for an aggressive lean.
**Acceptance Criteria:**
- CRT monitor head with curved screen face and thick bezels
- Mounting bracket allows tilt/swivel motion
- Antenna array on top of monitor
- Two industrial piston legs with hydraulic knee joints
- Wide flat foot pads for stable base
- Aggressive forward lean in rest pose
- Head + legs total ~600-800 tris

### Task 14.5: Model -- Corruption Overlay Geometry
**Status:** TODO
**Description:** Create the organic corruption elements that become visible in Phases 2 and 3. Model corruption tendrils: 4-6 tentacle-like forms that emerge from the back of the torso (these will be hidden in Phase 1, partially visible in Phase 2, fully extended in Phase 3). Each tendril is a tapered cylinder with organic undulations (3-4 bends). Model corruption mass: a bulging organic form that fits inside the torso cavity -- imagine the mechanical panels as a shell, and this is the creature growing inside. Model crack-edge geometry: thin mesh strips that sit along where the mechanical panels will "break away" (these display the red glow of exposed corruption). These elements exist in the mesh from the start but are revealed through animation/material changes.
**Acceptance Criteria:**
- 4-6 corruption tendrils modeled (tapered, undulating)
- Internal corruption mass fits within torso cavity
- Crack-edge geometry along panel break lines
- All corruption elements are separate objects or vertex groups for per-phase visibility
- Organic forms contrast clearly with mechanical geometry
- Corruption elements add ~600-800 tris to total budget

### Task 14.6: UV Unwrap -- Full Boss Assembly
**Status:** TODO
**Description:** UV unwrap the entire boss assembly onto a single 1024x1024 atlas. This is a complex unwrap requiring careful space allocation. Priority allocation: torso front panel 15% (most viewed), monitor screen 10% (displays code/errors), arms 15% combined, legs 10%, corruption elements 20% (need detail for organic texture), torso sides/back 15%, joints/misc 15%. Place seams along mechanical panel lines (natural visual breaks), along arm segment junctions, and along the back of the monitor. Corruption tendrils: seam on underside, unwrap lengthwise. Stack identical elements where possible (two legs share UV space, hydraulic cables share space). Verify no severe stretching on any visible surface.
**Acceptance Criteria:**
- All boss geometry on a single 1024x1024 UV atlas
- Space allocation follows visibility priority
- Seams placed along mechanical panel lines and junctions
- Identical elements (legs, cables) share UV space
- No severe stretching on visible surfaces (< 15%)
- 4px island padding throughout

### Task 14.7: Hand-Paint Texture -- Phase 1 (Intact Mechanical)
**Status:** TODO
**Description:** Paint the Phase 1 (intact) diffuse texture. This is the "clean" state before corruption is visible. Torso: industrial blue-grey (#4A5568) with darker panel line recesses, subtle metallic streaks painted with a textured brush, ventilation slats painted dark. Monitor screen: paint scrolling green code on black (#00CC44 on #0A0A0A) -- use a small text brush to paint several rows of code-like marks. Arms: slightly lighter grey than torso, with yellow hazard stripe (#DDAA00) bands at the elbow joints. Legs: darker grey (#3A3A4A) with grease/oil staining at the knee joints (dark brown #2A1A0A washes). Compile-wheel: bright cyan (#00CCDD) on the code symbol rim. Clamp jaws: worn silver (#AAAAAA) with scratch marks. LED lights on torso: small dots of green and blue.
**Acceptance Criteria:**
- Industrial blue-grey mechanical aesthetic throughout
- Monitor displays green code on black
- Hazard yellow stripes on arm joints
- Oil/grease staining on legs for lived-in feel
- Compile-wheel cyan glow on code symbols
- LED indicators painted on torso
- Reads as "functional industrial machine" in Phase 1

### Task 14.8: Hand-Paint Texture -- Phase 2 (Cracking)
**Status:** TODO
**Description:** Create the Phase 2 texture variant (or texture region for shader-based blend). Paint crack patterns across the torso panels: jagged fracture lines radiating from the center of the torso outward, filled with bright orange-red (#FF4400) to suggest glowing corruption underneath. Crack widths vary from hairline to ~0.02m painted width. Along the right arm, paint organic red tendrils (#AA0000) wrapping around the mechanical surface (as if growing through the metal). The monitor screen paint changes to flickering error messages ("ERROR", "STACK OVERFLOW", "CORRUPTION DETECTED") in red text on black. Darken the overall mechanical surface slightly (as if heat/stress is discoloring the metal). Left arm and legs remain mostly intact with just a few hairline cracks.
**Acceptance Criteria:**
- Crack patterns radiate from torso center with red-orange glow fill
- Cracks vary in width for natural fracture appearance
- Right arm has organic tendril growth painted over mechanical surface
- Monitor shows red error messages
- Overall surface slightly darkened (heat stress)
- Left arm and legs mostly intact (progressive damage, not uniform)
- Phase 2 clearly reads as "something is breaking through"

### Task 14.9: Hand-Paint Texture -- Phase 3 (Corrupted)
**Status:** TODO
**Description:** Create the Phase 3 texture variant. This is the most visually extreme state. Torso: 50% of mechanical panels show as "missing" -- paint the exposed areas with biomechanical corruption texture (dark red #660000 base with pulsing vein lines #FF0000, glistening wet-look highlights #FF6666). Remaining mechanical panels are heavily damaged, cracked, and scorched. Arms: both heavily corrupted, clamp arm partially melted/deformed (paint warped metal texture), compile-wheel arm with corruption growing over the disc. Monitor: paint pure static/noise pattern with red tint, or a single corrupted eye-like symbol. Corruption tendrils: deep crimson (#880000) with bioluminescent red vein patterns (#FF2200) along their length. Legs: corruption climbing up from the hip joints, feet still mostly mechanical.
**Acceptance Criteria:**
- 50% mechanical surface destroyed, showing biomechanical horror underneath
- Corruption texture has organic wet-look quality (veins, glistening highlights)
- Both arms heavily corrupted with distinct damage
- Monitor shows static/corrupted symbol
- Tendrils have bioluminescent vein patterns
- Phase 3 reads as "mechanical shell consumed by alien growth"
- All three phase textures saved (or documented as texture regions for shader blend)

### Task 14.10: Emission Maps for All Three Phases
**Status:** TODO
**Description:** Create emission maps for each phase (or a combined emission map with maskable regions). Phase 1 emission: monitor screen green glow at 80%, LED indicator dots at full, compile-wheel code symbols at 60%, all else black. Phase 2 emission: crack lines emit bright orange (#FF4400) at full intensity, monitor now emits red at 80%, corruption tendrils on arm emit faint red at 20%, Phase 1 elements reduced in intensity. Phase 3 emission: exposed corruption mass pulses bright red (#FF0000) at full intensity across all exposed areas, vein lines on tendrils at 80%, monitor static at 40%, remaining mechanical LEDs dead (no emission). The progression should clearly show the energy source shifting from technological (green/blue) to corrupted (red).
**Acceptance Criteria:**
- Phase 1: green/blue technological emission
- Phase 2: orange/red cracks + diminished green tech emission
- Phase 3: dominant red corruption emission, tech emission dead
- Clear energy-source progression across phases
- Emission maps saved for all 3 phases (or single map with masks)
- Each phase emission enhances readability under boss arena lighting

### Task 14.11: Skeletal Rig -- Mechanical Armature
**Status:** TODO
**Description:** Create the boss armature. This is the most complex rig in the project. Bone hierarchy: `root` at ground center, `hip` (connects to torso base), `spine_lower` and `spine_upper` (torso segments for leaning/twisting), `head_mount` (head tilt/swivel), `head` (monitor itself). Left arm chain: `shoulder_L`, `upper_arm_L`, `forearm_L`, `clamp_base_L`, `clamp_jaw_L` (for opening). Right arm chain: `shoulder_R`, `upper_arm_R`, `forearm_R`, `wheel_mount_R`, `wheel_spin_R` (for rotation). Leg chains: `thigh_L/R`, `shin_L/R`, `foot_L/R`. Corruption tendrils: `tendril_A/B/C/D/E/F` each with 3-4 bones for curl/wave. Total: ~45-55 bones. Set bone constraints for mechanical limits: arm joints limited to realistic hinge angles, head tilt limited to +/-30 degrees.
**Acceptance Criteria:**
- ~45-55 bones covering all mechanical and corruption elements
- Arm joints have mechanical hinge limits
- Head has tilt/swivel limits
- Clamp jaw opens/closes properly
- Compile-wheel spins on correct axis
- Tendril chains (4-6 tendrils x 3-4 bones each) for organic motion
- All bones named following project convention

### Task 14.12: Weight Painting -- Mechanical and Organic Zones
**Status:** TODO
**Description:** Weight paint the boss mesh. Mechanical parts use rigid binding (100% weight to assigned bone) since metal does not deform: torso panels to spine bones, arm segments to arm bones, leg segments to leg bones, head to head bone. Organic corruption elements use soft blending: corruption mass inside torso blended between spine_lower and spine_upper for subtle breathing deformation, tendrils use smooth weight falloff along their bone chains (similar to the MemoryLeak's tendril approach). The clamp jaw vertices bind rigidly to clamp_jaw_L. The compile-wheel disc binds to wheel_spin_R. Test all joints through their full range: arms should extend/retract cleanly, head should tilt without clipping into torso, legs should bend at knees without geometry popping.
**Acceptance Criteria:**
- Mechanical parts: rigid 100% weight binding
- Corruption mass: soft blended weights for breathing deformation
- Tendrils: smooth weight falloff along chains
- Clamp jaw opens/closes without geometry issues
- Compile-wheel spins freely on axis
- Full range-of-motion test passes on all joints
- No clipping between head and torso at tilt extremes

### Task 14.13: Animation -- Phase 1 Idle and Attacks
**Status:** TODO
**Description:** Animate Phase 1 behaviors. **Idle** (3 seconds, 72 frames, looping): mechanical breathing (spine_upper rises/falls 0.02m), head slowly scans left-right (20-degree sweep), compile-wheel spins continuously, clamp opens/closes slowly, legs shift weight subtly. **Clamp Slam attack** (1.5s, 36f): left arm raises high (12f wind-up), slams downward with clamp open (6f strike), clamp snaps shut on impact (2f), holds (4f), retracts (12f). Hitbox active frames 13-18. **Compile Beam attack** (2s, 48f): right arm extends forward (10f), compile-wheel spins up to maximum speed (8f wind-up with increasing glow), then sweeps in an arc (16f beam active), slows and retracts (14f). Beam active frames 19-34. Both attacks must have clear telegraph wind-ups.
**Acceptance Criteria:**
- Phase 1 idle loops naturally with mechanical personality
- Clamp Slam: clear overhead wind-up, fast strike, satisfying snap
- Compile Beam: spin-up telegraph, sweeping beam arc, wind-down
- Both attacks have documented hitbox active frame ranges
- Wind-up phases are telegraphed (readable by player)
- All animations export with correct bone references

### Task 14.14: Animation -- Phase 1 to Phase 2 Transition
**Status:** TODO
**Description:** Create the cinematic Phase 1-to-2 transition animation (4 seconds, 96 frames, one-shot). This plays when the boss crosses the 66% HP threshold. Frames 1-20: boss staggers backward (root translates back 0.5m), arms drop to sides, head tilts down. Frames 21-40: body shudders violently (rapid oscillation on spine bones), the first visible cracks appear -- this is where the Phase 2 material/texture swap should trigger (around frame 30). Frames 41-60: corruption tendril bones begin to animate (previously static) -- one tendril pushes outward from the back, the right arm's corruption wrapping becomes visible. Frames 61-80: boss recovers, rises to a more hunched posture (spine_upper tilts forward 10 degrees permanently for Phase 2). Frames 81-96: roar/threat display (arms spread wide, head tilts up) signaling Phase 2 has begun.
**Acceptance Criteria:**
- 96-frame cinematic transition with clear dramatic arc
- Material/texture swap cue at frame 30 (documented)
- First corruption tendrils become visible during transition
- Boss posture permanently changes to more aggressive (hunched)
- Concludes with threat display signaling Phase 2
- Animation should feel like a boss "leveling up"

### Task 14.15: Animation -- Phase 2 Attacks (Enhanced)
**Status:** TODO
**Description:** Animate Phase 2 enhanced attacks. Phase 2 idle should be more agitated: faster head scanning, erratic twitches on spine bones (2-3 sudden small jolts per cycle), tendrils writhing slowly. **Enhanced Clamp Slam** (1.2s, 29f): faster than Phase 1 version (shorter wind-up at 8f), plus a corruption aftershock (tendril bone slams down after the clamp, adding a second hit zone at frame 20). **Tendril Sweep** (new attack, 1.8s, 43f): two corruption tendrils extend forward and sweep in a wide arc (wind-up 12f, sweep 16f, retract 15f). **Corruption Spit** (new attack, 1s, 24f): head tilts forward, body compresses (8f gather), then expels a projectile from the chest area (tendril launch motion, 6f), recovery 10f.
**Acceptance Criteria:**
- Phase 2 idle is more agitated and erratic than Phase 1
- Enhanced Clamp Slam is faster with tendril follow-up hit
- Tendril Sweep is a new wide-arc melee attack
- Corruption Spit provides ranged attack capability
- All attacks have clear telegraph and hitbox frame ranges documented
- Phase 2 attacks are noticeably more aggressive than Phase 1

### Task 14.16: Animation -- Phase 2 to Phase 3 Transition
**Status:** TODO
**Description:** Create the Phase 2-to-3 transition (5 seconds, 120 frames). This is the most dramatic transition -- the mechanical shell fails. Frames 1-30: boss freezes mid-action, all motion stops, ominous stillness. Frames 31-50: violent internal convulsion (spine bones oscillate wildly), mechanical panel geometry begins to "break" (panel bones -- if using this approach -- tilt outward, or material swap triggers at frame 40). Frames 51-80: corruption explosion -- all tendrils extend to maximum length simultaneously, the corruption mass inside the torso becomes fully visible, the boss grows slightly (scale 105%) as the organic mass expands. Frames 81-100: boss thrashes wildly (arms flail, tendrils whip, head spins 360). Frames 101-120: stabilizes into Phase 3 posture -- wider stance, lower center of gravity, arms slightly raised, tendrils actively reaching.
**Acceptance Criteria:**
- Dramatic 120-frame transition with palpable tension
- Ominous stillness before the eruption (frames 1-30)
- Mechanical shell failure is visible and violent
- Corruption mass fully revealed during transition
- Boss grows slightly (105% scale) from internal expansion
- Phase 3 posture is wider, lower, more threatening
- Material/texture swap cue documented (frame 40)

### Task 14.17: Animation -- Phase 3 Attacks (Desperation)
**Status:** TODO
**Description:** Animate Phase 3 desperation attacks. Phase 3 idle should feel unstable: constant body tremor, tendrils constantly writhing with independent timing, head bobbing/flickering. **Frenzy Flail** (2s, 48f): both arms and all tendrils attack in a rapid sequence of swipes -- 6 individual hit zones over the duration, making it a sustained danger zone. **Corruption Nova** (2.5s, 60f): boss hunches down and gathers energy (20f, glowing intensely), then explodes outward with all tendrils/arms at maximum extension (10f), creating a radial damage zone, then slowly retracts (30f recovery -- punish window). **Desperate Lunge** (1.5s, 36f): entire boss lurches forward 3m (root motion), dragging itself with arms and tendrils, slamming down with full body weight.
**Acceptance Criteria:**
- Phase 3 idle conveys instability and desperation
- Frenzy Flail has 6 distinct hit zones over 2 seconds
- Corruption Nova has clear gather-and-explode with punish window
- Desperate Lunge covers 3m with terrifying forward momentum
- All Phase 3 attacks are faster and more dangerous than earlier phases
- Hitbox frame ranges documented for all attacks

### Task 14.18: Animation -- Death Sequence
**Status:** TODO
**Description:** Create the boss death animation (6 seconds, 144 frames). This must be cinematic and satisfying. Frames 1-20: boss freezes, all motion stops, then slowly begins to collapse. Frames 21-50: sequential system failure -- each arm goes limp (one at a time, 10f apart), tendrils retract and curl inward, legs buckle (knees bend outward). Frames 51-80: the boss sinks to its knees (hip drops, feet slide outward), head droops forward, monitor flickers off. Frames 81-110: final corruption pulse -- the remaining mechanical shell cracks and the organic mass contracts violently, pulling inward. Frames 111-130: body compresses to 70% scale as everything collapses inward. Frames 131-144: final stillness, held pose for death VFX overlay (explosion/dissolve per Epic 15 and Epic 18). This is the payoff for the entire boss fight -- it should feel earned.
**Acceptance Criteria:**
- 144-frame cinematic death with clear dramatic stages
- Sequential system failure (arms, legs, head shut down one by one)
- Boss sinks to knees (not just falls over)
- Final corruption contraction is dramatic and horrifying
- Ends in held stillness for VFX overlay
- Feels like a satisfying payoff for defeating the boss

### Task 14.19: Export and Multi-Phase Material System
**Status:** TODO
**Description:** Prepare the complex boss export. This model needs to support 3 texture states, which can be handled via: (A) three separate materials swapped by game code at phase transitions, (B) a single material with shader-driven texture blending using a phase parameter, or (C) three separate .glb exports (one per phase) that are swapped at transitions. Evaluate and implement the most practical approach for Godot. Document the chosen approach. Export all animations: `idle_p1`, `clamp_slam`, `compile_beam`, `transition_1_2`, `idle_p2`, `enhanced_clamp`, `tendril_sweep`, `corruption_spit`, `transition_2_3`, `idle_p3`, `frenzy_flail`, `corruption_nova`, `desperate_lunge`, `death` (14 total animations). Verify all export correctly with no missing bones or broken references.
**Acceptance Criteria:**
- Multi-phase material approach chosen, implemented, and documented
- All 14 animations exported and named correctly
- Phase transitions trigger material/texture changes at documented frames
- File exports without errors
- Godot import shows all animations and correct material setup
- Total file size reasonable for a boss asset (under 5MB)

### Task 14.20: Godot Boss Scene Integration and Fight Testing
**Status:** TODO
**Description:** Build or update the Corrupted Compiler boss scene in Godot. Set up a complex AnimationTree with three state sub-machines (Phase 1, Phase 2, Phase 3) connected by transition states. Each phase sub-machine contains its idle, attacks, and damage reactions. Connect phase transition animations to HP threshold triggers. Set up the multi-phase material system (per approach from 14.19). Create collision shapes for each attack type (clamp area, beam sweep, tendril arc, nova radius, lunge path). Configure hitbox timing to match documented active frames. Test the full boss fight: verify all 3 phase idles, 8 attacks, 2 transitions, and death sequence play correctly. Verify material/texture swaps are seamless during transitions. Adjust timing and damage values. Take before/after screenshots of each phase.
**Acceptance Criteria:**
- Boss scene with 3-phase AnimationTree state machine
- HP threshold triggers phase transitions correctly
- All 8 attacks have properly timed hitboxes
- Phase transition material swaps are seamless (no pop or flicker)
- Death sequence triggers correctly at 0 HP
- Full boss fight plays through all phases without animation errors
- Before/after screenshots of all 3 phases captured

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings
- **Epic 2** (Visual Style Guide): Style and proportion rules
- **Epic 3** (Texture Workflow): UV and texture standards
- **Epic 4** (Animation Pipeline): Rig and animation standards
- **Epic 5** (Combat System Fixes): Boss fight state machine and HP threshold system
- **Epic 15** (Enemy Shared VFX): Death dissolution VFX
- **Epic 18** (Boss Phase Visuals): Arena environment changes during phases

## Notes

- This is the most complex single asset in the game -- plan for longer iteration cycles
- The 14 animations make this a major animation workload; prioritize idle + transitions first, then attacks
- Phase texture approach decision (Task 14.19) should be made early since it affects how textures are painted
- Consider using vertex color masks on the mesh to drive phase-based material blending in shader
- The boss should be tested with boss arena lighting (Epic 37) for proper dramatic effect
- Compile-wheel spin can be driven by a simple bone rotation in code rather than baked animation for smoother results
