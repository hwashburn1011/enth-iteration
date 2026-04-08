---
epic: 17
title: "Enemy Variants"
phase: 3
status: TODO
priority: medium
estimated_hours: 45
dependencies: [1, 2, 11, 12, 13, 15]
---

# Epic 17: Enemy Variants

## Overview

Create visual variant systems for all enemy types to support elite versions, floor-based difficulty scaling, unique enhanced enemies, mini-boss treatments, and swarm visual density. Rather than building entirely new models, this epic leverages the base models from Epics 11-13 with material swaps, size scaling, particle auras, and additive VFX to create visually distinct variants that communicate gameplay differences to the player.

**Design Philosophy:** Every gameplay-meaningful enemy variation must have a corresponding visual variation. If an enemy hits harder, it looks different. If a swarm of weak enemies appears, they look like a swarm. If a mini-boss blocks the path, it looks imposing. Players should never die to an enemy they couldn't visually distinguish from a standard version.

**Quality Target:** Variants must be immediately distinguishable from base enemies at isometric camera distance. Color shifts and auras should be the primary differentiation tools, with size as secondary. Each variant tier should have a clear visual hierarchy.

## Success Criteria

- [ ] Elite color-shift materials for all 3 enemy types
- [ ] Size scaling system for floor difficulty
- [ ] Unique particle auras for enhanced enemies
- [ ] Mini-boss visual treatment is imposing and readable
- [ ] Swarm visual density communicates "many weak enemies"
- [ ] All variants are distinguishable from base at game camera distance
- [ ] Variant system is data-driven and extensible
- [ ] No new models needed -- all variants use base meshes

---

## Tasks

### Task 17.1: Variant System Architecture
**Status:** TODO
**Description:** Design a data-driven variant system that can apply visual modifications to any enemy. Create a Resource-based variant definition (`EnemyVariantData.gd`) extending Resource with: `@export var color_shift: Color`, `@export var size_multiplier: float`, `@export var emission_multiplier: float`, `@export var aura_scene: PackedScene`, `@export var animation_speed_multiplier: float`, `@export var name_prefix: String` (e.g., "Elite", "Frenzied", "Corrupted"). Create a variant applicator function in the enemy VFX controller that reads a variant resource and applies all visual modifications on `_ready()`. This system should be extensible -- adding a new variant tier requires only creating a new `.tres` file, not writing new code.
**Acceptance Criteria:**
- EnemyVariantData resource with all variant properties exported
- Variant applicator function in VFX controller
- Data-driven: new variants created as .tres files
- Extensible without code changes
- Static typed GDScript following project conventions
- Variant data includes all visual modification parameters

### Task 17.2: Elite Color-Shift Material -- GlitchBug Variants
**Status:** TODO
**Description:** Create 3 elite color variants for the GlitchBug by modifying its material parameters. (1) **Venomous GlitchBug** (green shift): hue-rotate the diffuse texture from red to toxic green (#44AA00), change emission to green, keep the glitch pattern overlay but shift pixel corruption blocks to magenta. (2) **Inferno GlitchBug** (orange/yellow): shift to bright orange-yellow (#FF8800), emission intensifies 2x, add a subtle heat distortion shader effect (screen-space refraction). (3) **Void GlitchBug** (purple/black): shift to deep purple (#440066) with black accents, reduced emission (darker, more menacing), add a shadow-trail particle effect (dark particles trailing behind movement). Each variant should be created as a new material instance (not modifying the base) so variants can coexist in the same room.
**Acceptance Criteria:**
- 3 GlitchBug color variants: green, orange, purple
- Each is a separate material instance (not modifying base)
- Color shift applied to diffuse, emission, and VFX particles
- Each variant has a unique secondary effect (heat distortion, shadow trail)
- Variants are immediately distinguishable from base and from each other
- Material instances created as .tres resources

### Task 17.3: Elite Color-Shift Material -- MemoryLeak Variants
**Status:** TODO
**Description:** Create 3 elite color variants for the MemoryLeak. (1) **Toxic MemoryLeak** (yellow shift): shift from green to sickly yellow (#AAAA00), corruption veins become dark brown, data fragments turn orange. The translucency illusion shifts to suggest acidic rather than digital corruption. Add a dripping particle effect (yellow drops falling from the body). (2) **Frozen MemoryLeak** (ice blue): shift to pale blue (#88CCFF), corruption veins become white frost patterns, data fragments become ice crystal shapes. Add frost particle aura (small white sparkle particles drifting slowly). Reduce animation speed to 0.8x (slower, more deliberate). (3) **Abyssal MemoryLeak** (dark red): shift to deep crimson (#660022), nearly opaque look (dark translucency), corruption veins become bright red (#FF0000), add a red mist ground fog particle.
**Acceptance Criteria:**
- 3 MemoryLeak color variants: yellow, ice blue, dark red
- Each variant modifies translucency illusion appropriately
- Unique particle effects per variant (drip, frost, mist)
- Frozen variant has reduced animation speed
- Variants maintain the MemoryLeak's blob silhouette while being distinct
- Material instances as .tres resources

### Task 17.4: Elite Color-Shift Material -- RogueProcess Variants
**Status:** TODO
**Description:** Create 3 elite color variants for the RogueProcess. (1) **Overcharged RogueProcess** (gold): shift from blue to gold (#DDAA00), emission seams become bright white, circuit traces glow intensely. Add electrical arc particles between shields (small lightning bolt meshes connecting shield plates). Shield orbit speed increases to 1.5x. (2) **Stealth RogueProcess** (dark grey): shift to near-black (#2A2A2A) with very faint emission (10% of base), making it harder to see in dark dungeons. Shields orbit slowly. Add a subtle cloaking shimmer shader (slight transparency flicker). (3) **Berserker RogueProcess** (crimson): shift to bright red (#CC0000), emission at 3x base, shields orbit at 2x speed. Add trailing particle streamers from each shield (red sparks trailing the orbit path). This variant should look aggressive and dangerous.
**Acceptance Criteria:**
- 3 RogueProcess color variants: gold, dark grey, crimson
- Each variant modifies emission, orbit speed, and has unique particles
- Overcharged: electrical arcs between shields
- Stealth: cloaking shimmer, reduced visibility
- Berserker: aggressive red with trailing sparks
- Material instances as .tres resources

### Task 17.5: Size Scaling System -- Floor-Based Growth
**Status:** TODO
**Description:** Implement a size scaling system that subtly increases enemy size on deeper dungeon floors. The scaling is applied to the enemy's mesh and collision shapes uniformly. Floor 1: 100% scale (base), Floor 2: 103%, Floor 3: 106%, Floor 4: 109%, Floor 5: 112%. The scaling is subtle enough that a floor-1 and floor-5 enemy side by side show a noticeable difference, but within a single floor, all enemies feel "normal." Implementation: apply the scale in the enemy scene's `_ready()` function based on the current floor number from GameManager. Also scale the enemy's health bar height offset, damage number spawn height, and aggro icon position to match the larger mesh. Ensure collision shapes scale proportionally.
**Acceptance Criteria:**
- +3% size increase per floor (compounding)
- Applied uniformly to mesh and collision shapes
- Health bar, damage numbers, and aggro icons reposition for scaled size
- Floor 1 vs Floor 5 comparison shows noticeable but not extreme difference
- Scale reads from GameManager floor number
- Does not affect animation playback (animations scale with mesh)

### Task 17.6: Size Scaling -- Elite Size Multiplier
**Status:** TODO
**Description:** In addition to floor scaling, elite enemy variants get an additive size bonus. Standard elite: +10% over floor-scaled base, champion elite: +20%, mini-boss: +40%. These multipliers stack with floor scaling (a floor 5 champion is 112% * 120% = 134% scale). Ensure the combined scaling does not cause visual problems: test maximum combined scale (floor 5 mini-boss at 157%) in a dungeon room for clipping with walls, doorway clearance, and camera framing. If the maximum scale causes issues, cap the combined scale at 150% and document the cap. Also ensure that the enemy's NavigationAgent path radius increases with size to prevent larger enemies from getting stuck on geometry.
**Acceptance Criteria:**
- Elite +10%, Champion +20%, Mini-boss +40% over floor scale
- Multipliers stack correctly with floor scaling
- Maximum combined scale tested in dungeon rooms (no clipping)
- Scale cap at 150% if needed (documented)
- NavigationAgent path radius scales with size
- Large enemies navigate dungeon geometry without getting stuck

### Task 17.7: Particle Aura -- Fire Aura
**Status:** TODO
**Description:** Create a fire aura particle system for "Inferno" type enhanced enemies. The aura consists of GPUParticles3D emitting from the enemy's mesh surface: small flame particles (billboard quads with a 4-frame fire sprite sheet animation) rising upward from the enemy body. Particle properties: 15-20 particles active at once, lifetime 0.5 seconds, initial velocity upward (0.3-0.5 m/s) with slight random spread, color gradient from yellow (#FFDD00) at birth to orange (#FF6600) to transparent at death, size 0.03-0.06m. Add a subtle warm point light (OmniLight3D, orange color, 0.2m range, energy 0.5) as a child of the enemy to cast warm light on nearby surfaces. The aura should be visible but not obscure the enemy silhouette.
**Acceptance Criteria:**
- 15-20 flame particles rising from enemy mesh surface
- 4-frame fire sprite sheet animation on each particle
- Color gradient: yellow -> orange -> transparent
- Warm point light casts on nearby surfaces
- Aura visible at camera distance without obscuring enemy silhouette
- Performant with multiple fire-aura enemies in a room

### Task 17.8: Particle Aura -- Ice/Frost Aura
**Status:** TODO
**Description:** Create a frost aura particle system for "Frozen" type enhanced enemies. Particle effect: small ice crystal particles (billboard quads with a diamond/snowflake shape) orbit slowly around the enemy at waist height. 10-15 particles, lifetime 2 seconds, slow orbit (one revolution per 4 seconds), slight vertical drift (float up 0.1m then back down). Color: pale blue-white (#CCDDFF) with subtle emission. Additionally, add a ground frost decal: a circular frost texture projected on the ground beneath the enemy (0.6m radius) that follows the enemy as it moves. The ground frost should have a subtle edge fade and use a tileable frost texture. Add a cold-mist ground particle (very low, 0.05m above ground, slow spread outward).
**Acceptance Criteria:**
- 10-15 ice crystal particles orbiting at waist height
- Slow orbit with vertical drift
- Ground frost decal follows enemy (0.6m radius)
- Cold mist particles at ground level
- Pale blue-white color scheme with subtle emission
- Frost effect is distinct from fire aura in shape and behavior

### Task 17.9: Particle Aura -- Void/Shadow Aura
**Status:** TODO
**Description:** Create a void/shadow aura for "Abyssal" or "Void" type enhanced enemies. This aura should make the enemy feel darker and more menacing. Particle effect: dark smoke-like particles (billboard quads with soft edge, dark grey/black #1A1A1A at 60% opacity) that rise slowly from the enemy's feet and drift outward. 20-25 particles, lifetime 1.5 seconds, slow upward velocity (0.1 m/s). The particles should be large enough (0.08-0.12m) to create a visible shroud around the enemy. Add a subtle darkening effect: a Decal projected below the enemy (1m radius) that darkens the ground (multiply blend, 20% darkening). Optionally, apply a slight vignette/darkening shader to the enemy's own mesh edges (inward gradient from normal to slightly darker, suggesting shadow absorption).
**Acceptance Criteria:**
- 20-25 dark smoke particles creating visible shroud
- Particles rise slowly and drift outward
- Ground darkening decal follows enemy (1m radius)
- Mesh edge darkening shader (optional but desirable)
- Enemy feels menacing and wrapped in shadow
- Dark aura distinct from fire and ice auras

### Task 17.10: Particle Aura -- Electric/Overcharge Aura
**Status:** TODO
**Description:** Create an electric aura for "Overcharged" type enhanced enemies. This aura should convey dangerous energy and instability. Particle effect: small bright sparks (#FFFFFF at birth fading to #00AAFF cyan) that snap between random positions on the enemy mesh (not smooth motion -- they appear at one position, hold for 2-3 frames, then teleport to another position). 8-12 sparks active at once, lifetime 0.2 seconds per snap. Add lightning arc meshes: 2-3 small procedural line segments connecting random points on the enemy surface, refreshing every 0.3 seconds (new random connection points). Arcs use a bright white-cyan material with emission. Add a persistent electrical crackle point light (cyan, 0.3m range, energy fluctuating randomly between 0.2 and 0.8).
**Acceptance Criteria:**
- Spark particles snap between positions (not smooth movement)
- 8-12 sparks with 0.2 second teleport lifetime
- 2-3 lightning arc line segments between random mesh points
- Arcs refresh every 0.3 seconds (new random connections)
- Fluctuating cyan point light for ambient electric glow
- Aura conveys "dangerously overcharged" energy
- Performant with multiple electric aura enemies

### Task 17.11: Mini-Boss Visual Treatment -- Crown and Frame
**Status:** TODO
**Description:** Create a visual treatment that marks an enemy as a mini-boss (a significant threat, but not a full boss fight). The treatment consists of: (1) Size increase (+40% from Task 17.6), (2) A golden crown icon (billboard sprite) floating above the enemy's head, slowly rotating (similar to the pack alpha crown from Epic 16 but larger and more ornate), (3) A golden glow outline -- apply a rim light shader (outline_color #FFDD00, intensity 0.3) to the mesh edges, making the mini-boss glow with a golden border, (4) Enhanced idle animation: add a subtle "breathing" scale oscillation (2% amplitude on a 3-second cycle) that suggests power, (5) Louder footstep/movement sounds (passed to audio system as a multiplier). The overall effect: "this is a big, important, golden-highlighted version of the normal enemy."
**Acceptance Criteria:**
- 40% size increase over base
- Golden crown billboard sprite above head (rotating)
- Golden rim light outline shader
- Breathing scale oscillation (2% amplitude)
- Louder movement sound multiplier
- Immediately reads as "important, dangerous enemy"
- Works with any enemy type (GlitchBug, MemoryLeak, RogueProcess)

### Task 17.12: Mini-Boss Visual Treatment -- Entrance Animation
**Status:** TODO
**Description:** Create a special spawn/entrance animation for mini-bosses that differentiates their appearance from standard enemy spawns. When a mini-boss spawns, instead of the standard digital assembly effect (Epic 15), play an enhanced sequence: (1) A 1-second pre-spawn effect: the ground at the spawn point cracks with golden light (projected decal animating from 0% to full crack pattern), accompanied by an expanding ring of golden particles. (2) The mini-boss emerges over 1.5 seconds: rises from below ground level (translate from Y=-1m to Y=0), with dust/debris particles around the emergence point. (3) Post-emergence roar: the mini-boss performs a threat display animation (type-specific: GlitchBug rears up and spreads mandibles, MemoryLeak swells to 120% then back, RogueProcess shields flare outward). (4) Brief invulnerability during the full 3.5-second sequence.
**Acceptance Criteria:**
- 3.5-second enhanced spawn sequence (pre-spawn, emergence, threat display)
- Golden ground crack effect pre-spawn
- Rise-from-below emergence with debris particles
- Type-specific threat display animation
- Invulnerability during the full sequence
- Dramatically distinguishes mini-boss spawn from standard spawns

### Task 17.13: Swarm Visual Density -- Reduced Detail System
**Status:** TODO
**Description:** When many weak enemies spawn as a swarm (6+ of the same type in a room), implement a visual density optimization that maintains readability. Create a "swarm mode" that activates when enemy count exceeds a threshold: (1) Reduce per-enemy particle effects to 50% count (halve all particle emission rates), (2) Disable individual hit flash spark particles (keep the white mesh flash only), (3) Reduce damage number display -- combine rapid hits into cumulative numbers with longer display interval, (4) Simplify health bars -- swarm enemies share a "swarm health" bar showing total remaining enemies instead of individual bars, (5) Add a swarm-specific visual: a persistent dust cloud particle effect at ground level across the swarm area (communicating "many enemies" at a glance).
**Acceptance Criteria:**
- Swarm mode activates at 6+ same-type enemies
- Particle effects reduced to 50% per enemy
- Hit spark particles disabled (mesh flash only)
- Damage numbers combined for rapid display
- Swarm health bar shows total count instead of individual bars
- Ground-level dust cloud communicates swarm density
- Performance remains stable with 10+ swarm enemies

### Task 17.14: Swarm Visual Density -- Swarm Movement Cohesion
**Status:** TODO
**Description:** Make swarm enemies look like a cohesive group, not just many individual enemies. When in swarm mode: (1) Apply a subtle "flocking" visual -- enemies in a swarm should have synchronized idle animation timing (offset within +/- 0.1 seconds, not perfectly synced but close enough to suggest group behavior), (2) Add a connection particle effect: very faint data-stream lines (#FFFFFF at 5% opacity) briefly connecting adjacent swarm members (appear for 0.3s, fade, appear between different pairs -- suggesting digital coordination), (3) When the swarm moves, add a "follow-the-leader" visual delay -- enemies further from the lead have 0.1-0.3 second movement delay, creating a ripple effect. (4) When a swarm member dies, nearby members briefly speed up their animations by 20% (panic response).
**Acceptance Criteria:**
- Synchronized idle timing within swarm (near-sync, not perfect)
- Faint data-stream connection particles between adjacent members
- Follow-the-leader movement ripple effect
- Death of member triggers brief panic speed-up in neighbors
- Swarm feels like a coordinated group, not random individuals
- Connection particles are subtle (5% opacity, intermittent)

### Task 17.15: Champion Enemy -- Dual Aura Combination
**Status:** TODO
**Description:** Champion enemies (rare, very powerful variants) combine two aura effects simultaneously. Create the system that layers two auras cleanly: (1) Define compatible aura pairs (fire+electric, frost+void, fire+void -- not fire+frost as they thematically conflict), (2) When a champion spawns with two auras, both particle systems activate simultaneously but with adjusted parameters -- each aura reduces to 70% particle count to avoid visual overload, (3) The champion's material color shift blends between both aura colors (e.g., fire+electric = orange-gold, frost+void = dark ice blue), (4) The champion gets a unique diamond-shaped icon above its head (different from the mini-boss crown) in the blended aura color. Test all valid aura combinations for visual clarity.
**Acceptance Criteria:**
- Dual aura system with defined compatible pairs
- Both auras render simultaneously at 70% particle count each
- Material color shift blends between both aura colors
- Diamond icon above head in blended color
- All valid combinations tested for visual clarity
- No visual overload or unreadable combinations

### Task 17.16: Variant Health Bar Integration
**Status:** TODO
**Description:** Update the health bar system (from Epic 15) to reflect variant information. Standard enemies: normal thin health bar. Elite enemies: health bar has a colored border matching the variant aura color (bronze/silver/gold). Champion enemies: health bar is wider (120% width) with a dual-colored border. Mini-bosses: health bar is 150% width with a golden ornate frame and the mini-boss name displayed above it (smaller version of the boss health bar style). The variant border should pulse subtly to draw attention. Additionally, the health bar background should tint slightly to match the variant color (5% color blend) so even without reading the border, the player gets a color cue.
**Acceptance Criteria:**
- Elite health bars have colored borders matching variant tier
- Champion health bars are wider with dual-colored borders
- Mini-boss health bars are 150% with golden frame and name
- Border pulses subtly to draw attention
- Health bar background tinted to variant color (5%)
- Variant information immediately readable from health bar alone

### Task 17.17: Variant Death Effects
**Status:** TODO
**Description:** Enhanced death effects for variant enemies that match their visual theme. Override the standard death dissolution (Epic 15) with variant-specific additions: (1) Fire variant: death dissolve particles are flame-colored, plus a brief explosion burst of fire particles, ground scorchmark decal left behind for 3 seconds. (2) Frost variant: death particles are ice-blue, body "shatters" into angular pieces (quick scale-to-zero on mesh sections), frost ground patch left behind. (3) Void variant: death particles are dark, body implodes (scale inward instead of dissolving outward), leaves a brief dark spot on the ground. (4) Electric variant: death triggers a lightning discharge (particles arc outward), brief screen flash. (5) Mini-boss death: slowed to 0.7x speed for dramatic effect, with a camera zoom-in (if not in boss fight).
**Acceptance Criteria:**
- Each variant type has unique death particle color and behavior
- Fire: explosion + scorchmark, Frost: shatter + frost patch
- Void: implosion + dark spot, Electric: lightning discharge + flash
- Mini-boss death slowed and camera-zoomed for drama
- Variant death effects override/layer on standard dissolution
- Ground effects persist briefly (2-3 seconds) then fade

### Task 17.18: Variant Loot Drop Visual
**Status:** TODO
**Description:** Differentiate loot drops visually based on the variant that dropped them. When a variant enemy dies and drops loot: (1) Standard enemy loot: normal drop with a small white particle puff. (2) Elite enemy loot: drop has a colored glow matching the variant tier (bronze/silver/gold), plus a brief pillar of light (0.5m tall) at the drop location lasting 1 second. (3) Champion loot: larger glow, taller light pillar (1m), plus a brief chime particle effect (expanding ring of sparkles). (4) Mini-boss loot: dramatic loot explosion -- items scatter outward slightly (0.3m radius), accompanied by a golden particle fountain (2 seconds), light pillar persists for 3 seconds. The visual quality of loot feedback should scale with the kill difficulty, rewarding the player's investment.
**Acceptance Criteria:**
- Four tiers of loot drop visuals matching variant quality
- Color-coded glow matches variant tier
- Light pillar scales with variant importance
- Mini-boss loot has dramatic explosion effect
- Visual quality scales with kill difficulty
- Loot drops are attention-grabbing appropriate to their significance

### Task 17.19: Variant Spawn Balance and Performance
**Status:** TODO
**Description:** Test the variant system's performance and visual balance in realistic dungeon scenarios. Set up test rooms with: (1) Mixed variants: room with 1 elite, 2 standards, test visual distinction. (2) All elites: room with 4 different color variant elites, test that each is distinguishable. (3) Champion + swarm: 1 champion with 6 swarm enemies, test that the champion stands out. (4) Mini-boss solo: mini-boss alone in arena, test imposing presence. (5) Maximum density: 10 enemies with mixed variants, test performance. Profile each scenario: ensure stable 60fps, check GPU particle budget, verify no shader compilation stalls. Adjust particle counts, aura intensities, or LOD thresholds as needed to maintain performance targets.
**Acceptance Criteria:**
- All variant combinations tested in realistic room scenarios
- Each variant tier visually distinct in mixed groups
- Champion stands out from swarm enemies
- Mini-boss has imposing solo presence
- Stable 60fps with 10 mixed-variant enemies
- No shader compilation stalls during testing

### Task 17.20: Variant Data Files and Documentation
**Status:** TODO
**Description:** Create all variant definition .tres files and write documentation for the variant system. Create the following variant data resources: `glitchbug_venomous.tres`, `glitchbug_inferno.tres`, `glitchbug_void.tres`, `memoryleak_toxic.tres`, `memoryleak_frozen.tres`, `memoryleak_abyssal.tres`, `rogueprocess_overcharged.tres`, `rogueprocess_stealth.tres`, `rogueprocess_berserker.tres`, `miniboss_treatment.tres`, `swarm_config.tres`. Each .tres file should have all EnemyVariantData properties filled in. Document the variant system in a reference file: how to create new variants, how to assign variants to spawn tables, performance budgets per variant tier, and the visual hierarchy (standard < elite < champion < mini-boss < boss). This document ensures future enemies can be given variants consistently.
**Acceptance Criteria:**
- 11 .tres variant data files created with complete property values
- Each file tested with its target enemy type
- Variant system reference document created
- Document covers: creation, assignment, performance budgets, hierarchy
- System is ready for future enemy types to use
- All files follow project naming conventions

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Material and resource conventions
- **Epic 2** (Visual Style Guide): Color palette and variant color rules
- **Epic 11** (GlitchBug): Base model and materials for variant creation
- **Epic 12** (MemoryLeak): Base model and materials
- **Epic 13** (RogueProcess): Base model and materials
- **Epic 15** (Enemy Shared VFX): Death dissolution, health bars, damage numbers

## Notes

- Color-shift materials should be created as material instances to allow multiple variants in the same room
- The aura particle system is the primary visual differentiator for enhanced enemies -- it must be visible but not obscuring
- Size scaling has diminishing returns -- beyond 150% enemies start looking silly rather than threatening
- Swarm mode optimization is essential for performance on mid-range hardware
- The champion dual-aura system should be tested carefully for visual clarity -- some combinations may need special handling
- Variant data files are an excellent example of the project's data-driven design philosophy
