---
epic: 18
title: "Boss Phase Visuals"
phase: 3
status: TODO
priority: high
estimated_hours: 55
dependencies: [1, 2, 5, 14, 15]
---

# Epic 18: Boss Phase Visuals

## Overview

Create the environmental and cinematic visual systems that support boss phase transitions in Enth: Iteration. While Epic 14 covers the boss model, textures, and animations, this epic handles everything around the boss: camera work during transitions, arena environment changes, progressive boss damage states, adds (additional enemy) spawn visuals, enrage effects, and the dramatic defeat cinematic. These systems are designed to be reusable across multiple bosses (Corrupted Compiler and future bosses).

**Design Philosophy:** Boss fights should feel like events, not just "fight a big enemy." Each phase transition is a cinematic moment. The arena itself changes to reflect the fight's progression. The boss's visual deterioration tells a story. The defeat sequence is a reward for overcoming the challenge.

**Quality Target:** Boss phase visuals should match or exceed the quality of ARPG boss fights in games like Hades, Diablo 3, or Path of Exile. Phase transitions should give the player a brief cinematic "breather" moment. Arena changes should be dramatic enough to notice mid-combat.

## Success Criteria

- [ ] Phase transition cutscene camera system works smoothly
- [ ] Arena environment visibly changes per phase
- [ ] Boss damage states show progressive visual deterioration
- [ ] Adds spawn visual is clear and distinct from normal enemy spawns
- [ ] Enrage visual is immediately obvious and threatening
- [ ] Defeat cinematic is dramatic and satisfying
- [ ] All systems are reusable for future bosses
- [ ] Player retains spatial awareness during camera transitions

---

## Tasks

### Task 18.1: Phase Transition Camera System -- Architecture
**Status:** TODO
**Description:** Design and implement a boss phase transition camera system that smoothly takes control from the gameplay camera for cinematic moments. Create a `BossCamera` script that extends the existing camera system. The system works in three modes: (1) **Gameplay mode**: normal isometric camera, player-controlled. (2) **Transition mode**: camera smoothly travels to a pre-defined cinematic position over 0.5 seconds, holds for the transition duration, then returns to gameplay position over 0.5 seconds. (3) **Defeat mode**: extended cinematic sequence with multiple camera positions. Store camera positions as Marker3D nodes placed in the boss arena scene. The transition uses bezier curve interpolation for smooth acceleration/deceleration. During transition mode, player input is suppressed (or limited to dodge-only for safety). The boss is invulnerable during transitions.
**Acceptance Criteria:**
- Three camera modes: gameplay, transition, defeat
- Smooth bezier interpolation between camera positions
- Camera positions defined as Marker3D nodes in arena scene
- Player input suppressed during transitions (boss invulnerable)
- 0.5s smooth travel to cinematic position and back
- System is reusable (reads positions from arena scene, not hardcoded)

### Task 18.2: Phase Transition Camera -- Corrupted Compiler Positions
**Status:** TODO
**Description:** Place specific camera Marker3D nodes in the boss arena for the Corrupted Compiler fight. Phase 1->2 transition camera: zooms in on the boss torso from a 45-degree angle (showing the cracks forming), positioned 3m from the boss at chest height. Phase 2->3 transition camera: pulls back to a wider shot (showing the full arena as the corruption erupts), positioned 5m away and slightly above (showing the boss and surrounding destruction). Defeat camera sequence: 3 positions -- (A) close-up on the boss face/monitor (1.5m distance), (B) wide shot as it collapses (6m, high angle), (C) dramatic low-angle looking up as the final dissolve happens (2m, ground level). Each position has a target look-at point (the boss center) and a field-of-view setting (transition cameras use 50 FOV for drama, gameplay uses the standard FOV).
**Acceptance Criteria:**
- 5 camera Marker3D positions placed in boss arena
- Phase 1->2: medium shot of torso (shows cracks)
- Phase 2->3: wide pullback (shows full eruption)
- Defeat: 3-shot sequence (close face, wide collapse, low-angle dissolve)
- Each marker has position, look-at target, and FOV data
- Camera angles are cinematic and dramatic

### Task 18.3: Arena Environment Change -- Phase 1 Baseline
**Status:** TODO
**Description:** Establish the boss arena's Phase 1 (initial) visual state. The arena should look like a server room that is still mostly intact. Implement the following baseline elements: (1) Floor: metallic grid tiles with subtle blue LED strip lights along the edges (emission material), (2) Walls: server rack panels lining the perimeter with green indicator lights, (3) Lighting: cool blue-white overhead lights (DirectionalLight3D or SpotLight3D array), even illumination with subtle shadows, (4) Ambient particles: slow-drifting data motes (small white particles floating at mid-height, very sparse -- 10-15 in the room), (5) Central area cleared for combat with the boss's starting position marked by a slightly different floor panel pattern.
**Acceptance Criteria:**
- Arena floor with metallic grid tiles and blue LED edges
- Server rack walls with green indicator lights
- Cool blue-white overhead lighting, even illumination
- Sparse data mote ambient particles
- Central combat area visually defined
- Phase 1 feels like "intact server room under control"

### Task 18.4: Arena Environment Change -- Phase 2 Degradation
**Status:** TODO
**Description:** When Phase 2 begins, the arena environment degrades. Implement the following changes that trigger during the Phase 1->2 transition animation: (1) Lighting shifts: overhead lights flicker (random intensity variation between 50-100% on a 0.5s cycle) and color-shift from blue-white to warm yellow (#FFDD88), suggesting power instability. (2) Wall server racks: green indicator lights change to yellow/amber (material property swap). (3) Floor LED strips: 30% of them switch from blue to red (randomly selected). (4) Particle change: data motes increase in count (30+) and turn from white to yellow-orange, drift faster. (5) New element: small sparks occasionally fall from the ceiling (GPUParticles3D emitter along the ceiling edge, 2-3 sparks per second). (6) Sound cue: a low rumble ambient sound starts (signal to AudioManager).
**Acceptance Criteria:**
- Overhead lights flicker and shift yellow during Phase 2
- Server rack indicators change to amber
- 30% of floor LEDs shift to red (random selection)
- Data motes increase and shift to yellow-orange
- Ceiling sparks begin falling intermittently
- Changes trigger during phase transition, not before
- Arena feels like "power failing, danger increasing"

### Task 18.5: Arena Environment Change -- Phase 3 Corruption
**Status:** TODO
**Description:** Phase 3 represents full corruption of the arena. Implement dramatic environmental changes during the Phase 2->3 transition: (1) Lighting: overhead lights die completely (energy drops to 0 over 2 seconds during transition), replaced by red emergency lighting from floor-level sources (new SpotLight3D nodes at floor edges, deep red #AA0000). (2) Walls: server rack panels crack/displace outward (subtle mesh position animation, 0.05-0.1m outward), indicator lights go dead or turn red. (3) Floor: corruption veins grow across the floor (animated decal system -- dark red vein textures that expand from the center outward over 3 seconds during transition, reaching wall edges). (4) Particles: data motes die, replaced by red corruption spores rising from the floor veins (dense, 50+ particles). (5) New element: organic corruption growths appear on walls (small mesh instances fading in at pre-placed points).
**Acceptance Criteria:**
- Overhead lights die, replaced by red floor-level emergency lighting
- Server rack walls crack and shift outward
- Floor corruption vein decals expand from center outward
- Data motes replaced by dense red corruption spores
- Organic growths appear on walls
- Arena feels like "server room consumed by alien corruption"
- Changes are dramatic and clearly signal Phase 3

### Task 18.6: Boss Damage States -- Progressive Crack System
**Status:** TODO
**Description:** Create a visual system that shows progressive damage on the boss model as HP decreases within each phase. This is separate from the phase transitions -- it provides continuous feedback. Implementation: use a damage overlay texture (or shader) that adds crack/damage detail as HP drops. Create a `damage_overlay.gdshader` that takes a `damage_level` uniform (0.0 = pristine, 1.0 = heavily damaged). As damage_level increases: (1) crack lines appear and widen (sampled from a crack pattern texture), (2) the crack interior glows with the corruption color (red emission through the cracks), (3) smoke/spark particles emit from crack locations (GPUParticles3D with emission points mapped to crack locations on the mesh). The damage_level is mapped to the current HP percentage within the active phase (e.g., at 80% of Phase 1 HP, damage_level = 0.2).
**Acceptance Criteria:**
- Crack overlay shader driven by `damage_level` uniform (0-1)
- Cracks appear gradually and widen with damage
- Red emission visible through crack lines
- Smoke/spark particles at crack locations
- Damage level mapped to HP within current phase
- Progressive damage is visible during gameplay
- Resets partially at phase transitions (new baseline damage)

### Task 18.7: Boss Damage States -- Missing Parts
**Status:** TODO
**Description:** At specific HP thresholds, visible parts of the boss should break off or become damaged. Define breakpoints: (1) At 80% HP (Phase 1): one antenna breaks off (mesh visibility toggle + small debris particle burst). (2) At 50% HP (Phase 2): the left arm clamp sparks and hangs limp (animation override: clamp arm goes to a "damaged" pose, sparks emit from the elbow joint). (3) At 40% HP (Phase 2): a section of torso panel falls away (mesh toggle + debris). (4) At 20% HP (Phase 3): the monitor head cracks (decal overlay on monitor mesh + flicker intensifies). Each breakpoint triggers a brief stagger animation (0.5s) and a debris particle effect. The broken parts persist as static meshes on the arena floor (cosmetic only, no collision).
**Acceptance Criteria:**
- 4 defined HP breakpoints with specific part damage
- Mesh visibility toggles for broken parts
- Debris particle bursts at each break event
- Brief stagger animation at each breakpoint
- Broken parts persist on arena floor as static cosmetic meshes
- Progressive part damage tells a visual story of the fight

### Task 18.8: Boss Damage States -- Damage Texture Layering
**Status:** TODO
**Description:** Layer the damage texture system from Task 18.6 with the phase textures from Epic 14. Create a material system that blends: (1) The current phase base texture (Phase 1/2/3 from Epic 14), (2) The damage overlay crack texture (from Task 18.6), (3) The emission enhancement from damage (brighter emission at crack locations). The layering must handle phase transitions gracefully: when transitioning from Phase 1 to Phase 2, the Phase 1 damage cracks should blend into the Phase 2 base texture (not reset to pristine). Create a shader that handles all three layers with uniforms: `phase_blend` (0.0 = Phase 1, 0.5 = Phase 2, 1.0 = Phase 3), `damage_level` (0-1 within current phase), and `crack_emission_energy` (driven by damage_level).
**Acceptance Criteria:**
- Three-layer material system: phase base + damage overlay + emission
- Phase transitions blend smoothly (no popping)
- Damage does not reset at phase transitions (carries over)
- Shader uniforms: phase_blend, damage_level, crack_emission_energy
- Works with all three phase textures from Epic 14
- Consistent visual quality at all damage/phase combinations

### Task 18.9: Adds Spawn Visual -- Boss Summon Effect
**Status:** TODO
**Description:** Create a visual effect for when the boss summons additional enemies (adds) during the fight. This must look different from standard enemy spawns (Epic 15) to communicate that the boss is summoning reinforcements. Effect: (1) Boss performs a summon gesture (raise arms, head tilts up, tendrils point toward spawn locations -- 1 second animation). (2) Red energy lines arc from the boss to each spawn point (line renderer particles tracing from boss center to spawn locations, 0.5 seconds). (3) At each spawn point, a corrupted version of the standard spawn effect plays: red/orange particle column (instead of the standard cyan), with a corruption vein decal appearing on the floor at the spawn point. (4) Summoned enemies emerge from the corruption pools (rise from Y=-0.5m to Y=0 over 1 second). The entire sequence communicates "the boss is calling for help."
**Acceptance Criteria:**
- Boss summon gesture animation (1 second)
- Energy lines arc from boss to spawn points
- Corrupted spawn effect at each point (red/orange, not standard cyan)
- Floor corruption vein decal at spawn points
- Adds emerge from corruption pools
- Clearly different from standard enemy spawn effect
- Communicates "boss is summoning reinforcements"

### Task 18.10: Adds Spawn Visual -- Corruption Pool Persistence
**Status:** TODO
**Description:** The corruption pools created by boss summon should persist as environmental hazards (if desired by game design) or as visual markers. Implement: (1) After adds spawn, the corruption vein decal at their spawn point persists with a subtle pulse (emission oscillation, 1-second cycle). (2) Small corruption particles rise from the pool continuously (2-3 particles/second, red, low). (3) If the add is killed, its spawn pool dims over 3 seconds and fades (no more adds from that point). (4) If the boss can re-summon, a killed add's pool reactivates with a brief flare before the next add emerges. (5) Corruption pools emit a faint red point light (OmniLight3D, 0.5m range, low energy) that adds to the arena's lighting degradation. Track pool states in a dictionary so any number of pools can exist.
**Acceptance Criteria:**
- Corruption pools persist after adds spawn
- Subtle pulse emission on active pools
- Particles rise continuously from active pools
- Pools dim and fade when associated add dies
- Pools reactivate for re-summons with flare effect
- Red point light from each pool contributes to arena lighting
- Pool states tracked in dictionary (scalable to any count)

### Task 18.11: Enrage Visual -- Red Aura and Screen Tint
**Status:** TODO
**Description:** Create the enrage visual effect that activates when the boss enters a berserk state (typically below 15-20% HP or after a time limit). This effect must be immediately obvious and threatening. Implementation: (1) Boss mesh gets a bright red rim-light shader overlay (#FF0000, intensity 0.5) that pulses at 2Hz. (2) GPUParticles3D: dense red energy particles (30-40) burst continuously upward from the boss, creating a visible column of rage. (3) Screen tint: apply a post-processing color overlay to the camera -- red vignette at the screen edges (20% opacity, inner radius 40% of screen, outer radius 100%). (4) Camera shake: continuous low-amplitude shake (1-pixel amplitude, constant during enrage). (5) Boss animation speed increases by 20% (applied via AnimationTree playback speed). (6) All boss emission values multiply by 2x.
**Acceptance Criteria:**
- Red rim-light pulse on boss mesh at 2Hz
- Dense upward red particle column from boss
- Red vignette screen tint on camera
- Continuous low-amplitude camera shake
- Animation speed increased 20%
- All emission doubled
- Combined effect reads as "extremely dangerous -- finish this quickly"

### Task 18.12: Enrage Visual -- Arena Intensity Shift
**Status:** TODO
**Description:** During enrage, the arena environment should also intensify. Implement: (1) Whatever phase the arena is in, increase all light energies by 30% and shift hue toward red. (2) Ambient particles increase in speed and density by 50%. (3) Floor corruption veins (if in Phase 3) pulse faster (0.5s cycle instead of 2s). (4) Add a new persistent effect: the arena edges darken (wall lights dim to 20% energy), creating a spotlight effect that focuses attention on the boss and center arena. (5) Optional screen-space effect: subtle chromatic aberration (0.5px offset on R channel) applied to the camera post-process, creating a slight color fringing that enhances the "something is very wrong" feeling. All enrage arena effects smoothly interpolate over 1 second when enrage activates.
**Acceptance Criteria:**
- All arena lights shift red and intensify 30%
- Particle speed and density increase 50%
- Floor corruption pulses faster
- Arena edges darken, focusing attention on center
- Chromatic aberration post-process (subtle)
- All changes interpolate smoothly over 1 second
- Arena amplifies the enrage threat level

### Task 18.13: Defeat Cinematic -- Sequence Controller
**Status:** TODO
**Description:** Implement the defeat cinematic sequence controller that orchestrates the boss death across multiple systems simultaneously. Create a `BossDefeatCinematic` script that: (1) Takes control of the camera system (switches to defeat mode), (2) Starts the boss death animation (Epic 14, Task 14.18), (3) Triggers arena reversal effects (corruption receding), (4) Manages timing of camera cuts between the 3 defeat camera positions, (5) Spawns reward loot at the end, (6) Returns camera to gameplay mode. The controller uses an AnimationPlayer with method call tracks to orchestrate all these systems at precise frame timings. Create a timeline document showing all parallel events during the defeat sequence. The entire sequence should last 8-10 seconds.
**Acceptance Criteria:**
- Sequence controller orchestrates camera, boss, arena, loot systems
- AnimationPlayer with method call tracks for precise timing
- 3 camera position cuts during the 8-10 second sequence
- Timeline document showing all parallel events
- Sequence ends with camera returning to gameplay mode
- System is reusable (configurable for different bosses)

### Task 18.14: Defeat Cinematic -- Corruption Reversal
**Status:** TODO
**Description:** During the defeat cinematic, the arena corruption recedes as the boss dies. This visual reversal mirrors the Phase 3 corruption but in reverse, symbolizing the system being "freed." Sequence: (1) Floor corruption veins begin to retract toward the boss (reverse of their expansion), pulling back from walls toward center over 4 seconds. (2) Red emergency lights shift to warm amber, then back to blue-white (lighting recovery, 3-second transition). (3) Corruption spore particles die off, replaced by returning white data motes. (4) Wall organic growths wither and fade (scale to 0% over 3 seconds). (5) Server rack indicator lights flicker back to green (one by one, staggered over 2 seconds). The reversal should not complete fully -- some damage remains (scarred floor, dark patches) to show the fight happened.
**Acceptance Criteria:**
- Floor corruption veins retract toward boss over 4 seconds
- Lighting recovers from red to amber to blue-white
- Corruption spores replaced by clean data motes
- Wall growths wither and fade
- Server rack lights return to green (staggered)
- Some permanent scarring remains (not fully pristine)
- Reversal is satisfying and symbolizes "victory over corruption"

### Task 18.15: Defeat Cinematic -- Boss Dissolve and Explosion
**Status:** TODO
**Description:** Create the boss-specific death VFX that plays during the defeat cinematic (enhanced version of the standard enemy death dissolve). Sequence: (1) As the boss collapses (frames 81-110 of death animation), emit increasingly dense particles from all crack locations and exposed corruption areas (ramping from 20 to 100 particles/second). (2) At the collapse point (frame 111), trigger a shockwave effect: a rapidly expanding ring (ground-level torus mesh with emission shader) that expands from the boss outward to 5m radius over 0.5 seconds, accompanied by 200+ pixel scatter particles bursting in all directions. (3) After the shockwave, the boss mesh dissolves using the standard death dissolve shader but at 0.5x speed (slower, more dramatic). (4) The dissolution particles are large (2x standard size) and colored with phase-appropriate colors (red/orange for Phase 3 state).
**Acceptance Criteria:**
- Ramping particle emission from cracks during collapse
- Shockwave ring effect expanding to 5m at collapse peak
- 200+ pixel scatter particles in all directions
- Slow-motion dissolve (0.5x speed) for dramatic effect
- Large dissolution particles in phase-appropriate colors
- Combined effect is the most dramatic death in the game

### Task 18.16: Defeat Cinematic -- Reward Reveal
**Status:** TODO
**Description:** At the end of the defeat cinematic, present the boss loot drop with fanfare. After the dissolution completes and particles clear: (1) A pillar of golden light descends from above at the boss's death position (cylinder mesh with emission + transparency, fades in over 1 second). (2) Loot items materialize within the pillar using the spawn materialization effect (Epic 15) but in gold color instead of cyan. (3) Once items are fully materialized, the pillar fades out and items settle to the ground with a gentle bounce. (4) A brief particle celebration effect: golden sparkles expanding outward in a ring at ground level. (5) Camera returns to gameplay position, player regains control. The loot reveal should feel earned and celebratory -- this is the payoff for the boss fight.
**Acceptance Criteria:**
- Golden light pillar descends at boss death position
- Loot materializes with gold-colored spawn effect
- Pillar fades, items settle to ground with bounce
- Golden sparkle celebration ring at ground level
- Camera returns to gameplay, player regains control
- Loot reveal feels earned and celebratory

### Task 18.17: Post-Fight Arena -- Scarring and Memory
**Status:** TODO
**Description:** After the defeat cinematic, the arena should show permanent evidence of the battle. Implement persistent scars: (1) Floor scorchmarks at locations where major attacks landed (decals placed at runtime during the fight, persisting after defeat). Track up to 10 scorchmark locations. (2) Cracked floor panels where the boss repeatedly slammed (decal overlays at frequently-hit positions). (3) Residual corruption stains: faint dark patches where the Phase 3 corruption veins were (50% faded version of the corruption vein decals). (4) Broken server rack sections remain dislocated. (5) The arena lighting settles to a slightly different baseline than Phase 1 -- warmer, slightly dimmer, suggesting the room has been through something. These scars make the empty arena a "memory" of the fight.
**Acceptance Criteria:**
- Up to 10 scorchmark decals at tracked impact locations
- Cracked floor panels at frequently-hit positions
- Faint corruption stain remnants (50% faded)
- Server rack sections remain displaced
- Lighting settles to "post-battle" warmth (not pristine Phase 1)
- Empty arena tells the story of the fight that happened

### Task 18.18: Phase System -- Reusable Framework
**Status:** TODO
**Description:** Refactor all boss phase visual systems into a reusable framework for future bosses. Create a `BossPhaseVisuals` base class (Resource or Node) that defines the interface: `setup_phase(phase_number: int)`, `transition_to_phase(from: int, to: int)`, `set_damage_level(level: float)`, `trigger_enrage()`, `play_defeat_cinematic()`. The Corrupted Compiler implementation becomes a concrete subclass/configuration. Create an `ArenaEnvironment` base class that defines the interface for arena changes: `set_phase(phase: int)`, `set_enrage(active: bool)`, `play_reversal()`. Document the framework API so future bosses (referenced in the GDD) can implement their own phase visuals by extending these base classes and providing their own camera positions, arena scenes, and phase data.
**Acceptance Criteria:**
- `BossPhaseVisuals` base class with standard interface
- `ArenaEnvironment` base class with standard interface
- Corrupted Compiler uses the framework (not hardcoded)
- Framework API documented with examples
- Future bosses can extend the base classes
- Framework handles camera, arena, damage, enrage, and defeat

### Task 18.19: Transition Timing Polish
**Status:** TODO
**Description:** Fine-tune the timing of all phase transitions for optimal pacing. Play through each transition multiple times and adjust: (1) Phase 1->2 transition total duration (target 4-5 seconds -- long enough to be dramatic, short enough to not frustrate). (2) Phase 2->3 transition total duration (target 5-6 seconds -- the most dramatic transition gets the most time). (3) Camera travel speeds (should feel smooth, not rushed or sluggish). (4) Material swap timing (must not pop -- should happen during visual cover like particle bursts or bright flashes). (5) Boss invulnerability window (matches transition duration exactly, +0.2s buffer). (6) Player stun/input-lock duration (shorter than transition -- player regains movement before camera fully returns, creating a "scramble back to position" moment). Document final timing values.
**Acceptance Criteria:**
- Phase 1->2: 4-5 second total duration
- Phase 2->3: 5-6 second total duration
- Camera travel feels smooth and cinematic
- Material swaps hidden behind visual cover (no popping)
- Invulnerability matches transition + 0.2s buffer
- Player regains control slightly before camera returns
- All timing values documented

### Task 18.20: Full Boss Fight Visual Playthrough Test
**Status:** TODO
**Description:** Complete end-to-end test of all boss phase visuals in a full fight. Start the boss fight from the arena entrance and play through the entire encounter: (1) Phase 1: verify arena baseline, boss animations, attack telegraphs, progressive damage (cracks, part breaking). (2) Cross 66% HP: verify Phase 1->2 transition cinematic, camera work, arena degradation, boss posture change. (3) Phase 2: verify enhanced arena, new attacks, continued damage progression. (4) Cross 33% HP: verify Phase 2->3 transition, arena corruption, dramatic eruption. (5) Phase 3: verify corrupted arena, desperation attacks, enrage activation below 15% HP. (6) Defeat: verify defeat cinematic, corruption reversal, boss dissolve, loot reveal. (7) Post-fight: verify arena scarring. Record a complete fight video for review. Note any visual glitches, timing issues, or impact-feel problems.
**Acceptance Criteria:**
- Full boss fight plays through all phases without visual errors
- All transitions are smooth and dramatic
- Arena environment changes are visible and appropriate per phase
- Damage states progress convincingly
- Enrage is immediately threatening
- Defeat cinematic is satisfying and celebratory
- Post-fight arena shows battle evidence
- Fight video recorded for team review

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Shader and material conventions
- **Epic 2** (Visual Style Guide): Color palette and cinematic direction
- **Epic 5** (Combat System Fixes): Boss HP thresholds, phase state machine
- **Epic 14** (Corrupted Compiler Boss): Boss model, textures, animations
- **Epic 15** (Enemy Shared VFX): Spawn and death base effects
- **Epic 37** (Boss Arena): Arena base geometry and layout

## Notes

- Phase transitions are the most impactful "wow moment" in the demo -- they must be polished
- Camera work should be tested on different display aspect ratios (16:9, 21:9, 4:3)
- The corruption reversal during defeat is symbolically important to the game's narrative
- Enrage should be rare enough that most players beat the boss before it triggers, but dramatic enough to panic those who see it
- Arena changes must not interfere with gameplay collision (visual only, except corruption pools if designed as hazards)
- Performance budget for the boss fight is tighter -- all effects from boss + arena + player + VFX running simultaneously
