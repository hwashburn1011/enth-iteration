---
epic: 44
title: "Combat VFX Overhaul"
phase: 8 — VFX & Particles
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 44: Combat VFX Overhaul

## Overview

Overhaul all combat visual effects: Data Pulse slash with textured mesh trail, Energy Burst expanding ring (shader-based), hit impact sparks (GPU particles with texture), projectile trails (ribbon particles), area-of-effect circle indicators, critical hit emphasis (time slow + zoom), and combo counter visual. Combat VFX are the moment-to-moment feedback that makes attacks feel impactful and satisfying.

## Success Criteria

- Every attack has a distinct, satisfying visual effect
- Hit impacts feel weighty with sparks, flash, and screen feedback
- Projectile trails are visible and readable during fast combat
- AoE indicators clearly show danger zones before damage
- Critical hits feel special with emphasis effects
- Combo counter rewards sustained combat engagement
- All VFX maintain 60fps during max-intensity combat (8 enemies, all attacking)
- VFX readable against all dungeon floor themes

---

## Tasks

### Task 44.1: VFX Style Guide and Standards
- **Status:** TODO
- **Description:** Establish visual standards for all combat VFX. Define: the particle color palette (player attacks = blue/teal, enemy attacks = red/orange, neutral/environment = white/yellow), the line weight/thickness standard (trail width, particle size ranges), the blend mode convention (additive for energy effects, alpha blend for solid particles), the layering order (effect -> impact -> screen response), and the timing standard (anticipation 0.1s, strike 0.05s, follow-through 0.2s, impact 0.15s). Create a reference sheet showing the VFX timing and layering for a standard attack sequence. This ensures visual consistency across all combat effects.
- **Acceptance Criteria:**
  - [ ] Color palette defined (player/enemy/neutral)
  - [ ] Particle size and line weight standards set
  - [ ] Blend mode conventions documented
  - [ ] Timing standards for all VFX phases
  - [ ] Reference sheet with attack sequence layers
  - [ ] Standards apply to all subsequent VFX tasks

### Task 44.2: Data Pulse — Slash Trail Effect
- **Status:** TODO
- **Description:** Create the Data Pulse (basic attack) slash trail effect. Use a textured mesh trail: a quad strip that follows the weapon/arm arc during the attack animation. The trail texture should be a gradient from bright teal center (#40C0C0) to transparent edges, with a subtle circuit-pattern overlay (data flowing along the slash). The trail should: appear at attack start, follow the arc path, and fade over 0.2 seconds after the attack completes. Trail width: 0.3m at the center, tapering to 0 at the tip. Add a brief flash at the attack origin point and a subtle whoosh of air particles along the trail path.
- **Acceptance Criteria:**
  - [ ] Textured mesh trail follows attack arc
  - [ ] Teal gradient with circuit-pattern texture
  - [ ] Trail fades over 0.2s after attack
  - [ ] Tapers from center to tip
  - [ ] Origin flash on attack start
  - [ ] Whoosh air particles along trail

### Task 44.3: Energy Burst — Expanding Ring Effect
- **Status:** TODO
- **Description:** Create the Energy Burst (charged attack) expanding ring effect using a custom shader. When the charged attack releases: a ring of energy expands outward from the player. Create a flat ring mesh (torus with thin cross-section). Apply a shader that: animates the ring expanding (scale increasing over 0.3s), creates a bright edge with trail fade (leading edge bright orange #FF8020, trailing edge fading to transparent), adds a distortion effect at the ring edge (screen-space refraction), and includes data particle scatter at the ring edge (small rectangular particles flying outward). The ring expansion speed should match the attack's damage radius. Add a brief screen flash (white, 0.05s) on release for emphasis.
- **Acceptance Criteria:**
  - [ ] Expanding ring mesh with shader-based animation
  - [ ] Bright leading edge with trailing fade
  - [ ] Screen-space distortion at ring edge
  - [ ] Data particle scatter at edge
  - [ ] Expansion matches damage radius
  - [ ] Screen flash on release

### Task 44.4: Hit Impact — Spark Particles
- **Status:** TODO
- **Description:** Create a versatile hit impact particle system that plays when any attack connects with a target. Use GPUParticles3D with a textured particle (32x32 spark texture — bright center, soft edges). Configure: 15-25 particles per impact, burst emission (all at once), radial velocity outward from impact point (5-10 m/s), short lifetime (0.15-0.25s), starting size 0.05m shrinking to 0, color matching the attack type (teal for player attacks, red for enemy attacks). Add a secondary emitter for larger "chunk" particles (3-5 per impact, slower, larger, representing fragments). The combined effect should feel like a clash of energy and data.
- **Acceptance Criteria:**
  - [ ] 15-25 spark particles per impact
  - [ ] Burst emission at impact point
  - [ ] Color matches attack type
  - [ ] Sparks radiate outward from impact
  - [ ] Secondary "chunk" particles for weight
  - [ ] Short lifetime (impact is brief and punchy)

### Task 44.5: Hit Impact — Screen Response
- **Status:** TODO
- **Description:** Add screen-level feedback to hit impacts for extra weight. When the player hits an enemy: brief camera freeze (1-2 frames of hitlag, where the game pauses for a nearly imperceptible moment), subtle camera shake (2-3px amplitude, 0.1s duration), and a small screen flash (enemy's hit color, very brief 0.03s, low opacity 10%). When the player gets hit: stronger camera shake (5-8px, 0.15s), red vignette flash (from Epic 40 low health system but single-pulse), and screen desaturation for 0.1s. Create a CombatScreenEffects.gd that provides `on_hit_dealt()` and `on_hit_received()` methods with configurable intensity.
- **Acceptance Criteria:**
  - [ ] Hitlag on successful hit (1-2 frame pause)
  - [ ] Camera shake on hit dealt (subtle)
  - [ ] Stronger shake on hit received
  - [ ] Red vignette on damage taken
  - [ ] Configurable intensity per hit type
  - [ ] CombatScreenEffects.gd with clean API

### Task 44.6: Projectile Trail — Ribbon Particle
- **Status:** TODO
- **Description:** Create a ribbon trail particle for projectile attacks (enemy ranged attacks, module abilities that fire projectiles). The trail should follow the projectile's path using a GPUParticles3D trail mode or a custom mesh trail. Trail appearance: thin ribbon (0.1m width) that stretches behind the projectile for 1-2m, color matching the attack type (red for enemy, teal for player), with animated internal texture (flowing energy pattern that moves along the trail toward the projectile head). The trail head (at the projectile) should be the brightest, with the tail fading to transparent. Add a small point light on the projectile that moves with it.
- **Acceptance Criteria:**
  - [ ] Ribbon trail follows projectile path
  - [ ] Trail stretches 1-2m behind projectile
  - [ ] Color matches attack type
  - [ ] Internal texture flows toward projectile head
  - [ ] Head brightest, tail fades
  - [ ] Point light moves with projectile

### Task 44.7: AoE Circle Indicator
- **Status:** TODO
- **Description:** Create a reusable area-of-effect indicator that shows where an AoE ability will land or where an enemy AoE attack will hit. Design a circle shader on a flat mesh: outer ring (bright, visible) with inner fill (semi-transparent, danger zone), pulsing animation (ring contracts inward over the warning period), and color coding (red for enemy AoE, teal for player AoE). Create AoEIndicator.tscn with configurable: radius, color, warning_duration, and type (circle, cone, line). The indicator should be clearly visible on all floor types (add contrast outline). When the AoE activates: the indicator flashes bright, then the actual effect plays.
- **Acceptance Criteria:**
  - [ ] Circle indicator with outer ring and inner fill
  - [ ] Pulsing contraction animation during warning
  - [ ] Color-coded by friendly/hostile
  - [ ] Configurable radius, color, duration
  - [ ] Visible on all floor types (contrast outline)
  - [ ] Flash on activation, then effect plays

### Task 44.8: Critical Hit Emphasis
- **Status:** TODO
- **Description:** Create special emphasis effects for critical hits to make them feel exceptional. When a critical hit lands: time slows briefly (0.15s at 30% speed — "hit stop"), camera zooms in slightly (3% zoom toward the impact, 0.1s), impact sparks are 2x larger and brighter, a screen flash in gold (0.05s), the damage number is larger and gold (from Epic 40), and a "data shatter" effect plays (the area around the impact shows a brief crack pattern that appears and fades — like the simulation cracking under the force). The combined effect should make the player feel powerful without disrupting combat flow.
- **Acceptance Criteria:**
  - [ ] Time slow on critical hit (0.15s at 30% speed)
  - [ ] Camera zoom toward impact (3%, brief)
  - [ ] 2x larger impact sparks
  - [ ] Gold screen flash
  - [ ] Data shatter crack pattern at impact
  - [ ] Effect feels powerful but doesn't disrupt flow

### Task 44.9: Combo Counter Visual
- **Status:** TODO
- **Description:** Create a visual combo counter that appears during sustained combat. When the player hits enemies in rapid succession (within 2 seconds between hits): a counter appears on screen showing the current combo count. Display: large number (TITLE font bold) with "COMBO" text below in BODY_SMALL. The counter increases with each hit: number scales up briefly (1.0 to 1.3, bounce back), color shifts from white (1-5) to yellow (6-10) to orange (11-20) to red (21+). At milestones (10, 20, 50): extra celebration effect (brief ring of particles, "INCREDIBLE!" text). The counter fades out after 2 seconds of no hits. Position the counter at the right side of the screen, above the minimap.
- **Acceptance Criteria:**
  - [ ] Combo count tracks rapid successive hits
  - [ ] Number bounces on each increment
  - [ ] Color escalation with combo count
  - [ ] Milestone celebrations at 10, 20, 50
  - [ ] Counter fades after 2s no hits
  - [ ] Positioned clearly without obscuring gameplay

### Task 44.10: Enemy Death VFX
- **Status:** TODO
- **Description:** Create a satisfying enemy death visual effect. When an enemy's health reaches zero: the enemy plays a brief stagger animation (0.2s), then a digital dissolution effect (from the hit point outward, the enemy mesh breaks into pixel blocks that scatter and fade), accompanied by a burst of sparks matching the enemy's color, a brief flash of light at the death position, and XP/loot particles that arc toward the player (or drop point). The dissolution should take 0.5-0.8 seconds and leave a brief ghost afterimage (1-2 frames of the enemy's silhouette at low opacity). Different enemy types should have slightly different death effects (GlitchBug shatters, MemoryLeak dissolves, RogueProcess explodes).
- **Acceptance Criteria:**
  - [ ] Digital dissolution effect from hit point outward
  - [ ] Pixel block scatter and fade
  - [ ] Spark burst in enemy's color
  - [ ] Flash of light at death position
  - [ ] XP/loot particles arc toward drop point
  - [ ] Enemy-specific variation in death effect

### Task 44.11: Player Dash VFX
- **Status:** TODO
- **Description:** Create a visual effect for the player's teleport dash. During the dash: the player's current position leaves a ghost afterimage (semi-transparent copy of the player mesh at 50% opacity in teal), the player streaks to the new position (motion blur or stretched mesh for 0.1s), at the destination a brief digital materialization effect plays (pixel blocks assembling into the player from scattered to solid, 0.1s). Leave a trail of small data particles along the dash path that fade over 0.3s. The dash should feel instantaneous and digital — not like running fast, but like teleporting through data space.
- **Acceptance Criteria:**
  - [ ] Ghost afterimage at origin position
  - [ ] Motion streak during dash
  - [ ] Digital materialization at destination
  - [ ] Data particle trail along dash path
  - [ ] Feels like teleportation, not fast movement
  - [ ] i-frame visual (player slightly transparent during dash)

### Task 44.12: Status Effect Visuals on Characters
- **Status:** TODO
- **Description:** Create visual indicators for active status effects on characters (player and enemies). Corrupted: purple aura particles orbiting the character, with small corruption growths briefly appearing and disappearing on the mesh. Fragmented: character mesh occasionally "shifts" (vertex offset jitter for 1-2 frames, 0.5Hz). Throttled: orange chains/tendrils visible wrapping around the character (simple mesh overlay), movement appears slowed. Overclocked: yellow electric sparks on the character, brighter overall emission. Segfault: character flickers (visibility toggling rapidly), with error-text particles floating off them. Each effect must be visible during gameplay without obscuring the character.
- **Acceptance Criteria:**
  - [ ] Corrupted: purple orbiting particles
  - [ ] Fragmented: periodic mesh jitter
  - [ ] Throttled: orange chain overlay
  - [ ] Overclocked: yellow electric sparks
  - [ ] Segfault: flickering with error-text particles
  - [ ] All effects visible but not obscuring character

### Task 44.13: Module Ability VFX Templates
- **Status:** TODO
- **Description:** Create VFX templates for each module ability category from the GDD. Offensive Module VFX: weapon swing effect (similar to Data Pulse but different color per module), projectile launch effect (muzzle flash + trail), explosion effect (expanding sphere with debris). Defensive Module VFX: shield activation (bubble expand from center), shield hit (ripple on shield surface), shield break (shatter particles). Utility Module VFX: speed boost (wind lines on character), area pulse (ground ring). Support Module VFX: heal effect (green particles rising, cross symbol), buff application (golden glow descending). Each template is configurable in color and intensity.
- **Acceptance Criteria:**
  - [ ] Offensive VFX templates (swing, projectile, explosion)
  - [ ] Defensive VFX templates (activate, hit, break)
  - [ ] Utility VFX templates (speed, area pulse)
  - [ ] Support VFX templates (heal, buff)
  - [ ] All templates configurable in color/intensity
  - [ ] Templates reusable across different specific modules

### Task 44.14: Attack Telegraph — Enemy Warning VFX
- **Status:** TODO
- **Description:** Create visual telegraph effects that warn the player of incoming enemy attacks. For melee enemies: a brief red glow on the attacking appendage during wind-up (0.3-0.5s before the attack), and a red arc indicator on the ground showing the attack's sweep area. For ranged enemies: a targeting line from the enemy to the player (dotted red line, 0.5s) before firing. For AoE enemies: the AoE circle indicator from Task 44.7 on the ground. For boss attacks: combined telegraph with screen-edge warning glow and a distinct sound. Each telegraph should give enough time to react (dash) without being so long they slow combat.
- **Acceptance Criteria:**
  - [ ] Melee telegraph: glowing appendage + ground arc
  - [ ] Ranged telegraph: targeting line to player
  - [ ] AoE telegraph: circle indicator on ground
  - [ ] Boss telegraph: enhanced with screen warning
  - [ ] 0.3-0.5s warning time for reaction
  - [ ] Telegraphs don't slow combat pace

### Task 44.15: Loot Drop VFX
- **Status:** TODO
- **Description:** Create visual effects for loot dropping after enemy death or chest opening. When loot spawns: items materialize from a burst of data particles (digital assembly, 0.3s), each item type has a distinct drop particle color (matching rarity: gray/green/blue/gold), a brief pillar of light shoots up from the drop point and fades (0.5s, height 2m, color matches rarity), and the item gently bobs in place (sine wave hover, 0.1m amplitude, 1Hz). Legendary drops get extra treatment: slow-motion on the drop (0.3s at 50% speed), brighter/larger pillar of light, golden sparkle particles, and a brief angelic/heroic sound hook.
- **Acceptance Criteria:**
  - [ ] Digital assembly materialization effect
  - [ ] Rarity-colored drop particles
  - [ ] Light pillar from drop point
  - [ ] Item bobbing hover animation
  - [ ] Legendary enhanced treatment (slow-mo, sparkle)
  - [ ] Drop VFX scales with rarity

### Task 44.16: VFX Object Pooling System
- **Status:** TODO
- **Description:** Implement an object pool for all combat VFX to prevent frame drops from constant instantiation/destruction. Create a VFXPool.gd autoload or manager that pre-creates pools of: impact spark systems (10 pooled), trail meshes (5), AoE indicators (5), damage numbers (20), death effects (5), and loot effects (10). When a VFX is needed: retrieve from pool, position, play. When finished: return to pool (don't free). The pool should automatically expand if demand exceeds pre-allocated count (lazy allocation). Log a warning if pool size exceeds 2x the initial allocation (suggests a leak). This is critical for maintaining 60fps during intense combat.
- **Acceptance Criteria:**
  - [ ] VFXPool manages all combat VFX instances
  - [ ] Pre-allocated pools for each VFX type
  - [ ] Retrieve -> play -> return lifecycle
  - [ ] Automatic expansion if pool exhausted
  - [ ] Warning log on excessive pool growth
  - [ ] Frame-drop-free VFX instantiation

### Task 44.17: VFX Quality Settings
- **Status:** TODO
- **Description:** Create quality settings for combat VFX that allow players to reduce effects for performance. Define 3 quality levels: High (full effects as designed), Medium (reduce particle counts by 50%, disable screen-space distortion, simplify trails), Low (further reduce particles to 25%, disable camera effects like hitlag and zoom, simplify death effects to a simple fade). The quality setting should be exposed in the Settings screen (from Epic 43) under the Video tab. Create a VFXQuality.gd that provides the current quality level and scaling factors for all VFX systems to reference.
- **Acceptance Criteria:**
  - [ ] 3 quality levels defined (High/Medium/Low)
  - [ ] Particle counts scale with quality
  - [ ] Screen effects disable at Medium/Low
  - [ ] Setting exposed in Video settings
  - [ ] VFXQuality.gd provides scaling factors
  - [ ] All VFX systems reference quality setting

### Task 44.18: VFX Readability Across Floor Themes
- **Status:** TODO
- **Description:** Test all combat VFX on each of the 5 dungeon floor themes and the town. Verify that: teal player attack trails are visible on Floor 2 (green theme — may need brightness boost), red enemy effects don't disappear against Floor 5 combat lighting (adjust to bright red-orange), impact sparks read on both bright (Floor 1) and dark (Floor 5) environments, AoE indicators are visible on all floor textures, and damage numbers are readable everywhere. Create contrast-boosting fallbacks for any VFX that fails readability on a specific floor theme.
- **Acceptance Criteria:**
  - [ ] All VFX tested on Floors 1-5 and town
  - [ ] Player attacks visible on all backgrounds
  - [ ] Enemy attacks visible on all backgrounds
  - [ ] AoE indicators readable on all floor textures
  - [ ] Damage numbers readable everywhere
  - [ ] Contrast adjustments applied where needed

### Task 44.19: Performance Profiling — Max Combat
- **Status:** TODO
- **Description:** Profile VFX performance during maximum-intensity combat: 8 enemies active, all attacking simultaneously, player using AoE abilities, multiple death effects active, combo counter running, critical hit effects, loot dropping. Measure: total VFX particle cost, total VFX shader cost, pool allocation count, frame time. Target: all VFX combined under 3ms at 1080p on High quality. If over budget: reduce particle counts on the least impactful effects, simplify shaders, or reduce pool sizes.
- **Acceptance Criteria:**
  - [ ] Max combat scenario profiled (8 enemies, all effects)
  - [ ] Total VFX cost under 3ms
  - [ ] Pool allocation tracked (no leaks)
  - [ ] 60fps maintained during max combat
  - [ ] Optimizations documented
  - [ ] Performance acceptable at High quality

### Task 44.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture combat VFX in action: Data Pulse slash, Energy Burst ring, hit impacts on enemies, projectile trails, AoE indicators, critical hit emphasis, combo counter, enemy death dissolution, dash effect, and loot drops. Record video of a full combat encounter showing all effects. Save to `_bmad-output/visual-overhaul/screenshots/epic-44/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All combat VFX types captured
  - [ ] Video of full combat encounter
  - [ ] Critical hit emphasis shown
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 09** (Globbler Animations) — Attack animations for VFX sync
- **Epic 15** (Enemy VFX) — Shared enemy VFX for consistency
- **Epic 33** (Dungeon Lighting) — Combat lighting context

## Notes

- Combat VFX are the #1 contributor to "game feel" — invest heavily here
- Hitlag (the 1-2 frame pause) is the single most impactful technique for hit weight
- Less is more for individual effects; MORE is more for the total experience
- Test all VFX at game speed, not slow motion — effects that look amazing at 50% speed may be invisible at 100%
- Object pooling is mandatory — VFX without pooling WILL cause frame drops in intense combat
