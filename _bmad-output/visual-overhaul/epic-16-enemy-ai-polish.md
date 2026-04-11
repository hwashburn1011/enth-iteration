---
epic: 16
title: "Enemy AI Visual Polish"
phase: 3
status: TODO
priority: medium
estimated_hours: 45
dependencies: [1, 2, 5, 11, 12, 13, 15]
---

# Epic 16: Enemy AI Visual Polish

## Overview

Polish the visual communication of enemy AI behaviors to ensure the player can read and react to enemy intentions. This epic bridges the gap between AI logic (which is invisible) and player comprehension (which requires visual cues). Every significant AI state change -- attack wind-up, patrol behavior, aggro transition, leash return, group coordination, and difficulty scaling -- gets a corresponding visual treatment that makes the AI feel alive, fair, and readable.

**Design Philosophy:** Enemies should never feel unfair because of invisible AI. If an enemy is about to attack, the player sees a telegraph. If an enemy is patrolling, its body language communicates passive scanning. If enemies are coordinating, the player can see the communication. This is not just polish -- it is core to combat feeling fair at higher difficulties.

**Quality Target:** All AI visual cues must be readable at isometric camera distance during active combat. They must not be so subtle that they are missed, nor so flashy that they compete with the player's own VFX for attention.

## Success Criteria

- [ ] Attack telegraphs provide readable wind-up cues for all enemy attacks
- [ ] Patrol visualization exists for debug mode
- [ ] Aggro transition has smooth visual blending
- [ ] Leash return behavior is visually communicated
- [ ] Group coordination has visible communication cues
- [ ] Difficulty scaling provides visual differentiation
- [ ] All cues are readable during active combat
- [ ] Debug visualization can be toggled for development

---

## Tasks

### Task 16.1: Attack Telegraph System -- Glow Charge Effect
**Status:** TODO
**Description:** Create a universal attack telegraph system that gives players visual warning before every enemy attack. The system works by applying a "charge glow" to the attacking body part during the wind-up phase of attack animations. Implementation: create a shader (`attack_telegraph.gdshader`) that adds an additive color overlay to specific mesh regions. The shader takes a `charge_progress` uniform (0.0 to 1.0) and a `charge_color` uniform (default bright red #FF2200). As charge_progress increases, the glow intensifies and pulses faster (pulse frequency = 2 + charge_progress * 8 Hz). For the GlitchBug: glow on the mandibles during lunge wind-up. For the MemoryLeak: glow on the front surface during spit wind-up. For the RogueProcess: glow on shields during charge wind-up. Map each enemy's attack animations to their glow target regions.
**Acceptance Criteria:**
- Telegraph shader provides visible progressive glow during wind-up
- Glow intensifies and pulses faster as attack approaches
- Mapped to specific body parts per enemy type
- Red color default, configurable per attack type
- Readable at isometric camera distance during combat
- Does not trigger during non-attack animations

### Task 16.2: Attack Telegraph -- Ground Indicators
**Status:** TODO
**Description:** For area-of-effect and directional attacks, add ground-projected danger zone indicators. Create a decal/projected texture system that shows the attack's area of effect on the ground during wind-up. Types needed: (1) Circular AoE -- red circle expanding to full radius during wind-up (used for the Corrupted Compiler's Corruption Nova), (2) Cone/arc -- fan-shaped indicator for sweeping attacks (Compile Beam arc, Tendril Sweep), (3) Line -- narrow rectangle for charge/lunge attacks (GlitchBug lunge, RogueProcess charge). Each indicator uses a red (#FF2200 at 30% opacity) filled area with a brighter edge line, and pulses in opacity as the attack approaches. Indicators appear at the start of wind-up and disappear when the attack fires. Create reusable Decal or MeshInstance3D nodes for each shape.
**Acceptance Criteria:**
- Three ground indicator shapes: circle, cone/arc, and line
- Red semi-transparent fill with bright edge
- Opacity pulses as attack approaches
- Indicators appear during wind-up, disappear on attack fire
- Accurately represent actual hitbox areas
- Reusable as node components for any enemy attack

### Task 16.3: Attack Telegraph -- Boss-Specific Indicators
**Status:** TODO
**Description:** Create enhanced telegraph indicators specifically for the Corrupted Compiler boss (and future bosses). Boss attacks need stronger, more readable telegraphs because they deal more damage and the arena is larger. Enhancements over standard indicators: (1) Boss ground indicators have a secondary "warning ring" that expands outward ahead of the actual attack (preview of where the AoE will reach), (2) Boss charge_glow effect is accompanied by particle emission (sparks flying from the glowing body part), (3) Phase 2 and 3 attacks get progressively shorter telegraph times but the visual intensity increases (brighter glow, faster pulse), (4) Multi-hit attacks (Frenzy Flail) show sequential indicators that chain across the attack zones. Test all boss attack telegraphs in the arena context.
**Acceptance Criteria:**
- Boss telegraphs are more dramatic than standard enemy telegraphs
- Warning ring preview for AoE attacks
- Spark particles accompany boss charge glow
- Telegraph intensity scales with phase (shorter but brighter)
- Sequential indicators for multi-hit attacks
- All boss attacks tested in arena context for readability

### Task 16.4: Patrol Path Debug Visualization
**Status:** TODO
**Description:** Create a debug visualization system for enemy patrol paths, visible only when a debug flag is enabled. When toggled on, each enemy draws: (1) its patrol path as a series of connected line segments (Line3D or ImmediateMesh) in yellow, (2) a circle at each waypoint node with a directional arrow showing intended facing, (3) the aggro detection radius as a semi-transparent red sphere/circle, (4) the leash return radius as a semi-transparent blue sphere/circle, (5) the current AI state as a text label above the enemy (PATROL, CHASE, ATTACK, RETURN, etc.). This visualization is toggled via a debug keybind (F3 or similar) and should have zero performance cost when disabled (do not process when invisible). Store the toggle in a project-level debug setting.
**Acceptance Criteria:**
- Patrol paths drawn as yellow connected line segments
- Waypoint circles with direction arrows
- Aggro radius visualized as red semi-transparent sphere
- Leash radius visualized as blue semi-transparent sphere
- Current AI state text label above enemy
- Zero performance cost when disabled
- Toggled via debug keybind (configurable)

### Task 16.5: Aggro Transition -- Posture Shift Animation
**Status:** TODO
**Description:** Create smooth visual transitions for the aggro state change. When an enemy transitions from passive/patrol to aggro/chase, the visual change should not be instantaneous -- it needs a brief transition animation. For each enemy type, create a "posture shift" blend: (1) GlitchBug: mandibles spread wider, body lowers into an aggressive crouch, front legs raise slightly -- blend from idle to chase over 0.3 seconds. (2) MemoryLeak: body swells upward 10%, tendrils extend and orient toward the player -- blend over 0.5 seconds. (3) RogueProcess: shield orbit speed doubles, core tilt toward player, emission brightens -- blend over 0.4 seconds. These transitions are handled via AnimationTree blend parameters, not separate animations. Adjust the AnimationTree blend speeds for each enemy.
**Acceptance Criteria:**
- GlitchBug posture shifts to aggressive crouch over 0.3s
- MemoryLeak swells and extends tendrils over 0.5s
- RogueProcess shields accelerate and core tilts over 0.4s
- Transitions use AnimationTree blend parameters (smooth, not abrupt)
- De-aggro reverses the posture shift at similar speeds
- Transitions are subtle but noticeable at camera distance

### Task 16.6: Aggro Transition -- Visual Intensity Shift
**Status:** TODO
**Description:** Beyond posture, enemy visual intensity should increase when aggro. Implement a material parameter system that shifts enemy appearance between passive and aggressive states. When aggro activates: (1) increase emission energy by 30% (enemy glows slightly brighter), (2) saturate the base color slightly (shift from neutral to vivid), (3) increase the speed of any animated shader effects (the GlitchBug's glitch pattern scrolls faster, the MemoryLeak's corruption veins pulse faster, the RogueProcess's seam glow pulses). These shifts are driven by a single `aggro_intensity` parameter tweened from 0.0 to 1.0 over the transition duration. Create a shared function in the VFX controller that applies these material changes.
**Acceptance Criteria:**
- Emission energy increases 30% on aggro
- Base color saturation increases subtly
- Animated shader effects speed up when aggro
- All changes driven by single `aggro_intensity` parameter
- Tween from 0 to 1 over transition duration
- Reverse tween on de-aggro
- Shared implementation in VFX controller works for all enemies

### Task 16.7: Leash Return -- "Giving Up" Animation
**Status:** TODO
**Description:** When an enemy reaches its leash distance and returns to patrol, it needs a visual "giving up" moment beyond the "?" icon (Epic 15). Create per-enemy leash return transitions: (1) GlitchBug: stops running, mandibles close, body raises from aggressive crouch, turns away with a brief hesitation (0.5s pause facing the player direction before turning), then walks back at reduced speed. (2) MemoryLeak: stops, tendrils retract, shrinks down 10%, then oozes back slowly. (3) RogueProcess: shields decelerate to idle speed, core tilts away from player, drifts back with a slight "dismissive" rotation. The hesitation pause is key -- it communicates "I have lost interest" rather than "my invisible leash pulled me back."
**Acceptance Criteria:**
- Each enemy type has a unique leash return transition
- Brief hesitation pause before turning away (0.3-0.5s)
- Movement speed reduced during return (not the same as chase speed)
- Posture shifts from aggressive back to passive during return
- Communicates "giving up" rather than "invisible wall"
- Return path follows patrol pathfinding (not straight line back)

### Task 16.8: Leash Return -- Trail Fade Effect
**Status:** TODO
**Description:** Add a subtle visual trail effect during leash return to communicate the enemy is returning to its home zone. Create a simple particle trail that emits behind the returning enemy: small dim particles in the enemy's color palette at 20% opacity, lifetime 1 second, spaced 0.2m apart, that mark the return path briefly. This trail fades quickly and is intentionally subtle -- it is not a highlight, just a gentle indicator for attentive players. The trail stops emitting when the enemy reaches its patrol start point. Additionally, when the enemy reaches its home position, play a brief "settling" particle puff (similar to the spawn effect but smaller and shorter, 0.3 seconds) to indicate it has returned to its patrol.
**Acceptance Criteria:**
- Subtle particle trail during leash return movement
- Trail color matches enemy type at 20% opacity
- Particles fade over 1 second, spaced 0.2m
- Trail stops at patrol start point
- "Settling" particle puff on arrival at home position
- Subtle enough to not distract from active combat elsewhere

### Task 16.9: Group Coordination -- Communication Pulse
**Status:** TODO
**Description:** When enemies coordinate (e.g., one enemy calls others to attack, pack behavior), visualize the communication. Create a "data pulse" effect: when an enemy sends a coordination signal, a ring of particles expands outward from it (bright colored ring, expands to the coordination radius over 0.5 seconds, fades). Any enemy that receives the signal responds with a brief flash in the same color. This creates a visible "ripple" of coordination that the player can see. Use orange (#FF8800) for "attack together" coordination, blue (#0088FF) for "spread out" coordination, and yellow (#FFAA00) for "retreat" coordination. The sending enemy plays a brief antenna/tendril gesture (whatever is thematically appropriate per enemy type).
**Acceptance Criteria:**
- Expanding ring particle effect from coordinating enemy
- Ring expands to coordination radius over 0.5 seconds
- Receiving enemies flash in the same color
- Three color codes: orange (attack), blue (spread), yellow (retreat)
- Sending enemy plays a brief gesture animation
- Communication is visible but does not overwhelm the combat scene

### Task 16.10: Group Coordination -- Formation Indicators
**Status:** TODO
**Description:** When enemies move into tactical formations (flanking, surrounding, holding positions), provide subtle visual cues. Create a debug-mode formation overlay (toggled with the patrol path debug): thin colored lines connecting coordinating enemies, with an icon at the formation center point. For non-debug gameplay: add a subtle ground effect at the enemy's "assignment position" -- a faint glow marker on the ground where the AI is trying to position the enemy (like a waypoint marker, but very subtle). This helps the player understand that enemies are not moving randomly but are trying to surround them. The markers are small circular decals in the enemy's color at 10% opacity, visible only within 5m of the player.
**Acceptance Criteria:**
- Debug mode: colored lines connecting coordinating enemies
- Debug mode: formation center point icon
- Gameplay mode: subtle ground glow at assignment positions
- Ground markers are enemy-colored at 10% opacity
- Markers only visible within 5m of player
- Helps player intuit tactical AI behavior
- Zero performance cost when debug visualization is off

### Task 16.11: Difficulty Scaling -- Floor-Based Visual Cues
**Status:** TODO
**Description:** As the player descends deeper into the dungeon, enemies on each floor should look progressively more dangerous. Implement a floor-based visual modifier system. The VFX controller reads the current floor number and applies: (1) emission intensity scales up 5% per floor (floor 5 enemies glow 25% brighter than floor 1), (2) a subtle dark aura particle effect activates on floor 3+ (small dark particles orbit the enemy slowly), (3) enemy idle animation speed increases slightly per floor (2% faster per floor -- floor 5 is 10% faster, suggesting increased agitation), (4) on floor 5, all enemies get a very faint red edge-highlight on their mesh (rim lighting shader effect at 5% intensity). These changes are cumulative and subtle -- the player should feel increasing danger without identifying exactly why.
**Acceptance Criteria:**
- Emission intensity scales +5% per floor
- Dark aura particles activate floor 3+
- Idle animation speed increases +2% per floor
- Floor 5 red rim lighting at 5% intensity
- Changes are cumulative across all modifiers
- Player feels increasing danger subliminally
- System reads floor number from GameManager/dungeon state

### Task 16.12: Difficulty Scaling -- Enhanced Enemy Glow
**Status:** TODO
**Description:** Create a visual system for "enhanced" enemies that appear on deeper floors with buffed stats. Enhanced enemies are the same creature type but need to look noticeably tougher (without being a completely different model). Implementation: apply a colored aura ring at the enemy's feet (ground-level flat torus mesh with an animated glow shader). Color coding by enhancement level: bronze (#CC8844) for level 1 enhancement, silver (#AAAACC) for level 2, gold (#FFDD44) for level 3. The aura ring rotates slowly and pulses gently. Additionally, the enhanced enemy's base emission is multiplied by 1.5x (level 1), 2.0x (level 2), or 3.0x (level 3). Enhanced enemies also have a brief "power-up" animation on spawn (scale from 100% to 110% and back over 0.5 seconds).
**Acceptance Criteria:**
- Ground-level aura ring with color coded enhancement level
- Bronze/silver/gold color coding is clear and readable
- Aura ring rotates and pulses gently
- Emission multiplied by enhancement level
- Spawn power-up animation (scale pulse)
- Enhancement level communicated without changing the enemy model

### Task 16.13: Idle Behavior -- Environmental Awareness
**Status:** TODO
**Description:** Make enemy idle behaviors feel more alive by adding environmental awareness animations. When enemies are idle (not aggro), they should occasionally: (1) look toward nearby sounds or movement (head/body turn toward the player when they are within detection range but not yet triggering aggro -- a "suspicious" pre-aggro state), (2) interact with the environment (GlitchBug: occasionally scratches at the ground, MemoryLeak: extends a tendril toward nearby walls, RogueProcess: scans back and forth with head rotation), (3) exhibit "personality" idle variations (small chance per cycle to play a variant idle: yawn, stretch, fidget). These are blended on top of the base idle animation using AnimationTree's additive blend system.
**Acceptance Criteria:**
- Enemies turn toward player when within detection range (pre-aggro)
- Each enemy type has 1-2 environmental interaction idles
- Personality idle variations trigger randomly (10-20% chance per cycle)
- Additive animation blending via AnimationTree
- Behaviors trigger only during non-aggro idle state
- Adds life without interfering with combat readability

### Task 16.14: Death State -- Ragdoll-Like Knockback
**Status:** TODO
**Description:** When enemies die, apply a physics-influenced knockback to make deaths feel impactful. On death: (1) calculate knockback direction from the killing hit source, (2) during the first 0.3 seconds of the death animation, translate the enemy 0.3-0.5m in the knockback direction (fast initial push, then decelerate), (3) if the killing blow was a critical hit, increase knockback distance to 0.8m and add a slight upward arc (enemy briefly leaves the ground 0.1m). This is not true ragdoll physics -- it is a scripted translation applied on top of the death animation to give deaths directional impact. The knockback should respect collision boundaries (do not push enemies through walls). Apply via a tween on the enemy's position in the VFX controller.
**Acceptance Criteria:**
- Death knockback in direction of killing blow
- Standard death: 0.3-0.5m knockback over 0.3 seconds
- Critical death: 0.8m knockback with slight upward arc
- Knockback respects collision boundaries
- Applied via positional tween (not physics engine)
- Combines cleanly with death animation playback

### Task 16.15: Combat Engagement -- Camera Micro-Shake
**Status:** TODO
**Description:** Add subtle camera effects that reinforce combat impact. Create a camera shake system in the game camera script that triggers micro-shakes on specific events: (1) enemy takes heavy hit: 0.5-pixel shake for 3 frames, (2) enemy dies: 1-pixel shake for 5 frames, (3) boss attack lands: 2-pixel shake for 8 frames, (4) boss phase transition: 3-pixel shake for 15 frames, (5) boss death: 5-pixel shake that decays over 30 frames. Shake is applied as a random offset to the camera position, with decay over the duration. Include a camera shake intensity setting (0-100%) in the options so players sensitive to screen shake can reduce or disable it. Never shake on player attacks (only on hits received or environmental events).
**Acceptance Criteria:**
- Five shake tiers for different combat events
- Shake applied as random camera offset with decay
- Intensity setting in options (0-100%)
- Never triggers on player attacks (only hits/events)
- Shake amounts are subtle (measured in pixels, not meters)
- Multiple simultaneous shake events use the strongest magnitude

### Task 16.16: Combat Engagement -- Hit Stop (Frame Freeze)
**Status:** TODO
**Description:** Implement a hit stop system that briefly freezes the game on significant hits. Hit stop is a classic ARPG game-feel technique: on contact, the game pauses for 1-3 frames to emphasize impact. Implementation: (1) standard enemy hit: 1 frame freeze (16ms at 60fps), (2) critical hit on enemy: 2 frames freeze, (3) player takes damage: 2 frames freeze, (4) boss takes heavy hit: 3 frames freeze. The freeze is achieved by setting Engine.time_scale to 0.0 for the freeze duration, then restoring to 1.0. To prevent input lag during freeze, continue processing input during the freeze frames. Include a hit stop toggle in game options (on/off). Hit stop should stack up to a maximum of 3 frames total (prevent excessive freezing from rapid multi-hits).
**Acceptance Criteria:**
- Hit stop freezes game for 1-3 frames on significant hits
- Four tiers matching hit significance
- Implemented via Engine.time_scale manipulation
- Input still processed during freeze (no input lag)
- Toggle option in game settings
- Maximum 3-frame stack prevents excessive freezing

### Task 16.17: Awareness State -- Suspicious Pre-Aggro
**Status:** TODO
**Description:** Implement a visual "suspicious" state between passive idle and full aggro. When the player is within 70-100% of the enemy's aggro radius, the enemy should show curiosity before committing to aggro. Visual indicators: (1) enemy turns to face the player gradually (0.5s turn), (2) a subtle "?" thought bubble flickers briefly above the head (smaller and faster than the de-aggro "?"), (3) emission increases by 10% (getting more alert), (4) idle animation pauses briefly (0.3s freeze, then resumes -- as if the enemy "heard something"). If the player moves away, the enemy returns to normal idle. If the player moves closer, the suspicious state transitions to full aggro with the "!" indicator. This pre-aggro warning gives skilled players a chance to back off.
**Acceptance Criteria:**
- Suspicious state triggers at 70-100% of aggro radius
- Enemy gradually turns toward player over 0.5s
- Small flickering "?" thought bubble (distinct from de-aggro "?")
- Emission increases 10% during suspicious state
- Brief idle pause for "alert" effect
- Transitions to full aggro or back to idle based on player proximity

### Task 16.18: Attack Variety -- Animation Speed Variation
**Status:** TODO
**Description:** Add subtle variation to enemy attack timing to prevent enemies from feeling robotic. For each attack animation, implement a +/- 10% speed variation: each time the attack triggers, randomly select an animation playback speed between 0.9x and 1.1x. This makes enemies feel unpredictable without changing the underlying AI timing significantly. Additionally, vary the wind-up phase independently from the strike phase: sometimes the wind-up is slightly longer (more telegraphed) and the strike is faster, sometimes vice versa. This is achieved by setting different playback speeds on different sections of the animation via AnimationTree. Cap the variation so the fastest variant is still readable (minimum wind-up of 60% original duration).
**Acceptance Criteria:**
- +/- 10% random speed variation on each attack execution
- Wind-up and strike phases vary independently
- Minimum wind-up duration is 60% of original (always readable)
- Variation creates unpredictability without unfairness
- Applied per-attack-instance (not per-enemy-type)
- System reads from configurable variation range per attack

### Task 16.19: Pack Behavior -- Alpha Visual
**Status:** TODO
**Description:** When multiple enemies of the same type are in a room, designate one as the "alpha" and give it a visual distinction. The alpha is the enemy that coordinates group behavior (sends attack signals, etc.). Visual treatment: (1) the alpha is 5% larger than its peers (subtle scale increase), (2) the alpha has a faint crown-like particle effect above its head -- 3-4 small glowing dots arranged in a semicircle that slowly orbit (matching enemy color), (3) the alpha's emission is 20% brighter than peers. When the alpha dies, the crown effect transfers to the next designated alpha (brief particle travel effect from the death location to the new alpha over 0.5 seconds). This helps the player identify which enemy to prioritize in group encounters.
**Acceptance Criteria:**
- Alpha enemy is 5% larger than peers
- Crown-like particle dot arrangement above alpha's head
- Alpha emission 20% brighter
- Crown transfers to new alpha on death (particle travel effect)
- Player can identify pack leader visually
- Only one alpha per enemy-type group in a room

### Task 16.20: Full AI Visual Polish Integration Test
**Status:** TODO
**Description:** Comprehensive integration test of all AI visual polish systems working together. Set up a test dungeon room with a mixed group of enemies (2 GlitchBugs, 1 MemoryLeak, 1 RogueProcess) with group coordination enabled. Walk the player through a complete combat scenario: (1) approach -- enemies show suspicious pre-aggro, (2) enter aggro range -- "!" indicators, posture shifts, emission increase, (3) combat -- attack telegraphs, hit reactions, damage numbers, (4) focus the alpha -- verify crown transfer, (5) retreat past leash -- enemies show "?" and return behavior, (6) re-engage and kill all -- death knockback, camera shake, hit stop. Verify all systems work simultaneously without visual clutter, performance issues, or conflicting animations. Adjust any timing or intensity values. Toggle debug visualization to verify patrol paths and formations.
**Acceptance Criteria:**
- Full combat scenario plays through all AI visual states
- All systems function simultaneously without conflicts
- No visual clutter (competing effects readable)
- No performance issues with all systems active
- Debug visualization toggles cleanly
- All timing and intensity values feel balanced
- Combat feels fair, readable, and satisfying

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Shader conventions
- **Epic 2** (Visual Style Guide): Color palette for visual cues
- **Epic 5** (Combat System Fixes): AI state machine, damage pipeline
- **Epic 11-13** (Enemy Models): Animations and rigs to attach telegraphs to
- **Epic 15** (Enemy Shared VFX): Hit flash, damage numbers, health bars

## Notes

- Attack telegraphs are the single most important combat readability feature -- they must be prioritized
- Hit stop is controversial; provide an option to disable it
- Camera shake amounts should be very conservative -- too much is worse than none
- The suspicious pre-aggro state adds a tactical layer for skilled players
- Group coordination visuals are important for communicating pack AI fairness
- Debug visualization should be fully featured to support ongoing AI tuning
