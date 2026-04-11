---
epic: 35
title: "Combat Arena Design"
phase: 6 — Dungeon Environment
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 35: Combat Arena Design

## Overview

Design and build distinct combat arena layouts: open arena with pillars for cover, elevated platforms with ramps, narrow corridor ambush zones, multi-level arenas, destructible cover objects, hazard zones with visual warnings, and boss arenas with phase-specific layouts. Each arena type should create different tactical situations, encourage varied playstyles, and be visually distinct enough that players immediately understand the tactical landscape upon entering.

## Success Criteria

- 5+ distinct arena layouts with different tactical properties
- Cover objects placed for meaningful tactical decisions
- Elevated platforms accessible via ramps with clear height advantage
- Destructible objects break visually and affect combat flow
- Hazard zones clearly telegraphed with visual warnings before activation
- Boss arena supports multiple phases with visual transitions
- All arenas maintain 60fps during combat with maximum enemy count
- Arena layouts tested for balanced gameplay (no exploit positions)

---

## Tasks

### Task 35.1: Arena Design Document and Blockout Plan
- **Status:** TODO
- **Description:** Design 7 arena types on paper before building: (1) Open Pillared Hall — large rectangular room with 4-6 pillars for cover, (2) Elevated Platform Arena — central elevated platform with 2 ramps, lower perimeter, (3) Narrow Corridor Ambush — long narrow room with alcoves enemies emerge from, (4) Multi-Level Arena — two connected floors with holes/ramps between them, (5) Circular Pit — round arena with central depression and raised ring, (6) Hazard Grid — open room with hazard zones occupying 30% of floor space, (7) Boss Arena — large dramatic space detailed in Epic 37. For each, sketch the top-down layout with dimensions, cover positions, enemy spawn points, player entry, and intended combat flow.
- **Acceptance Criteria:**
  - [ ] 7 arena types designed on paper
  - [ ] Top-down layout sketches with dimensions
  - [ ] Cover positions marked per arena
  - [ ] Enemy spawn points defined
  - [ ] Intended combat flow documented
  - [ ] Arena sizes appropriate for the game's combat range

### Task 35.2: Open Pillared Hall — Layout and Construction
- **Status:** TODO
- **Description:** Build the Open Pillared Hall arena using dungeon tiles (Epic 31). Room dimensions: 12m x 10m (6x5 floor tiles). Place 6 pillars (2x3 grid, offset from center) using a custom pillar mesh — thick square columns (0.8m x 0.8m) floor-to-ceiling with the same metal panel texture as walls. Pillars provide LOS-breaking cover but enemies can path around them. Leave a clear 3m open lane along each wall for flanking. Add ceiling light panels in a grid. Place the player entrance on one short wall, with 2 enemy spawn alcoves on the opposite wall and 2 on the side walls. The arena should support 4-8 enemies simultaneously.
- **Acceptance Criteria:**
  - [ ] Room built from dungeon tiles at 12m x 10m
  - [ ] 6 pillars in offset grid providing cover
  - [ ] Clear flanking lanes along walls
  - [ ] Player entrance on short wall
  - [ ] 4 enemy spawn positions on opposite/side walls
  - [ ] Navigation mesh allows pathfinding around pillars

### Task 35.3: Elevated Platform Arena — Layout and Construction
- **Status:** TODO
- **Description:** Build the Elevated Platform Arena. Room dimensions: 14m x 12m. Central elevated platform (6m x 6m, raised 1.5m) with 2 ramps on opposite sides (2m wide, 45-degree slope). Lower perimeter is 3-4m wide on all sides. The platform gives height advantage (ranged attacks from above are stronger, melee enemies must funnel up ramps). Place cover on both levels: low walls (0.8m tall) on the platform edges, crate clusters on the lower level. Enemy spawns on the lower level force the player to decide: hold the high ground or drop down to engage. Model the platform as a raised floor section using wall pieces for the sides.
- **Acceptance Criteria:**
  - [ ] Central platform raised 1.5m with 2 ramps
  - [ ] Lower perimeter walkable on all sides
  - [ ] Cover objects on both levels
  - [ ] Ramps are 2m wide (funnel choke points)
  - [ ] Height advantage is tactically meaningful
  - [ ] Navigation mesh handles both levels and ramps

### Task 35.4: Narrow Corridor Ambush — Layout and Construction
- **Status:** TODO
- **Description:** Build the Narrow Corridor Ambush arena. Dimensions: 20m long x 4m wide — this is deliberately cramped. Add 4 alcoves (2m x 2m) on alternating sides of the corridor, where enemies spawn from. Place destructible barriers (crates, server racks) at the corridor midpoint that initially block the player's view of the far end. The combat flow should be: player enters, first wave from alcoves 1-2, player pushes forward, barriers block advancement, second wave from alcoves 3-4, player destroys barriers and proceeds. The narrow space forces close-range combat and limits escape options — high tension.
- **Acceptance Criteria:**
  - [ ] Corridor 20m x 4m, deliberately cramped
  - [ ] 4 alcoves on alternating sides for enemy spawns
  - [ ] Destructible barriers at midpoint
  - [ ] Combat flow: waves from alternating alcoves
  - [ ] Narrow space forces close-range combat
  - [ ] Navigation handles alcove and corridor widths

### Task 35.5: Multi-Level Arena — Layout and Construction
- **Status:** TODO
- **Description:** Build the Multi-Level Arena with two interconnected combat floors. Lower level: 10m x 10m with standard ceiling height (3m). Upper level: 8m x 8m centered above, with the outer 1m perimeter open (grated floor looking down to lower level). Connect levels with a ramp and a drop-down hole (player can jump down but not back up without the ramp). Enemies spawn on both levels simultaneously. The grated floor between levels allows light and visual tracking (see enemies below through the grate) but not direct attack (shots blocked by the grate). This creates dynamic vertical combat with decisions about which level to clear first.
- **Acceptance Criteria:**
  - [ ] Two-level arena with proper height separation
  - [ ] Grated floor section for visual tracking between levels
  - [ ] Ramp for controlled ascent, drop-down for fast descent
  - [ ] Enemies spawn on both levels
  - [ ] Grate blocks attacks but allows visual tracking
  - [ ] Navigation mesh handles both levels correctly

### Task 35.6: Pillar and Cover Object Models
- **Status:** TODO
- **Description:** Create dedicated cover object models in Blender. Pillar: 0.8m x 0.8m square column, floor-to-ceiling, with the dungeon metal panel texture and circuit trace emission accents. Low Wall: 2m wide x 0.8m tall x 0.3m thick barrier with matching dungeon texture. Barrier Crate: 1m x 1m x 1m reinforced crate with metal bands and hazard marking, destructible. Server Rack Barrier: repurposed server rack (from Epic 32) oriented as a barricade. UV unwrap and texture paint all with dungeon-appropriate materials. Export as .glb with collision and add to the dungeon prop library.
- **Acceptance Criteria:**
  - [ ] Pillar model textured with dungeon style
  - [ ] Low wall model for partial cover
  - [ ] Barrier crate model with hazard markings
  - [ ] Server rack repurposed as barricade
  - [ ] All models UV unwrapped and textured
  - [ ] Exported as .glb with collision shapes

### Task 35.7: Destructible Cover System
- **Status:** TODO
- **Description:** Implement a destructible cover system for barrier crates and server rack barricades. Create a DestructibleProp.gd script that: tracks hit points (default 3 hits), shows visual damage progression (intact -> damaged -> destroyed), emits particles on each hit (sparks, debris fragments), and on destruction plays a break animation (pieces scatter outward using RigidBody3D fragments). Create 3 visual states per destructible prop: intact (normal texture), damaged (cracked/dented texture overlay, sparking), and destroyed (rubble pile with scattered debris). The system should feel impactful — destroying cover should be dramatic.
- **Acceptance Criteria:**
  - [ ] DestructibleProp.gd tracks HP and damage states
  - [ ] 3 visual states: intact, damaged, destroyed
  - [ ] Spark/debris particles on each hit
  - [ ] Break animation with physics-based fragment scatter
  - [ ] Destroyed cover becomes passable terrain
  - [ ] Destruction feels impactful and dramatic

### Task 35.8: Hazard Zone Visual Warnings
- **Status:** TODO
- **Description:** Create the visual warning system for hazard zones that tells the player "danger here" before the hazard activates. Design a 3-stage warning sequence: Stage 1 (3 seconds before): hazard area boundary glows with a dim yellow outline (decal or flat mesh on the floor). Stage 2 (1 second before): outline pulses brighter and turns orange, warning particles rise from the area, a sound cue plays. Stage 3 (activation): hazard activates with full visual effect (from Epic 36). The warning boundary shape matches the hazard's area of effect (circle for explosions, rectangle for beams, etc.). Create a HazardWarning.tscn scene with configurable shape, color, and timing.
- **Acceptance Criteria:**
  - [ ] 3-stage warning sequence (yellow -> orange -> activate)
  - [ ] Warning boundary matches hazard area shape
  - [ ] Warning particles during Stage 2
  - [ ] Timing gives player 3 seconds to react
  - [ ] HazardWarning.tscn is reusable and configurable
  - [ ] Warnings are clear without being annoying

### Task 35.9: Hazard Grid Arena — Layout and Construction
- **Status:** TODO
- **Description:** Build the Hazard Grid Arena. Room dimensions: 10m x 10m. Divide the floor into a 5x5 grid of 2m x 2m zones. 30% of zones (8 zones) are hazard zones that activate on a rotating timer — each hazard zone is active for 3 seconds, then safe for 6 seconds, staggered so only 2-3 are active simultaneously. Use the hazard warning system from Task 35.8. Mark hazard zone floor tiles with a distinct texture (red-tinted tech panel). The remaining 70% of floor is safe. Place enemies that can also be damaged by hazards (encouraging the player to kite enemies into active zones). No permanent cover — only the safe zones provide breathing room.
- **Acceptance Criteria:**
  - [ ] 5x5 grid of 2m zones, 30% are hazards
  - [ ] Hazards rotate on staggered timers
  - [ ] Only 2-3 active simultaneously
  - [ ] Hazard zones clearly marked on floor texture
  - [ ] Warning system active before each activation
  - [ ] Enemies also damaged by hazards

### Task 35.10: Circular Pit Arena — Layout and Construction
- **Status:** TODO
- **Description:** Build the Circular Pit Arena. Outer room: 14m x 14m square with the dungeon tileset. Central pit: 8m diameter circle, recessed 1m, with a sloped edge (the player can walk in and out but movement is slower on the slope). A raised ring (0.5m high) surrounds the pit at 10m diameter with 4 gaps for access. Enemies spawn in the pit center and around the ring. The tactical decision: fight in the pit (closer to enemies, restricted escape) or fight from the ring (range advantage, but enemies climb out). Place 4 small pillars on the ring for minimal cover.
- **Acceptance Criteria:**
  - [ ] Central pit 8m diameter, 1m deep
  - [ ] Raised ring with 4 access gaps
  - [ ] Movement slowed on pit slope
  - [ ] Enemies spawn in pit and on ring
  - [ ] Tactical choice between pit and ring fighting
  - [ ] 4 small pillars on ring for cover

### Task 35.11: Arena Entrance Design
- **Status:** TODO
- **Description:** Design the entrance transition for each combat arena to build anticipation. Create a short (4m) entrance corridor for each arena with: door frame that seals behind the player (preventing retreat during combat), a brief view of the arena through the doorway before entering (the player can see the layout before committing), and lighting that hints at the arena type (pillared hall has shadows from pillars visible, hazard grid has red floor glow visible). The entrance corridor should have dimmer lighting than the arena, creating a "stepping into the spotlight" effect when the player enters.
- **Acceptance Criteria:**
  - [ ] Each arena has a 4m entrance corridor
  - [ ] Door seals behind player during combat
  - [ ] Arena partially visible through doorway before entry
  - [ ] Entrance lighting hints at arena type
  - [ ] Dim-to-bright transition on entry
  - [ ] Entrance builds anticipation

### Task 35.12: Arena Victory State
- **Status:** TODO
- **Description:** Design the visual transition when combat ends in an arena. When all enemies are defeated: the red combat lighting fades back to the room's base lighting over 1.5 seconds, a warm gold spotlight fades in on the loot drop location (center of arena), the sealed entrance door re-opens with a pneumatic hiss animation, and a subtle particle effect (golden sparkles) plays at the loot location. If the arena had hazards, they deactivate permanently. If cover was destroyed, debris remains (tells the story of the battle). The victory transition should feel rewarding — a moment of relief and accomplishment.
- **Acceptance Criteria:**
  - [ ] Red combat lighting fades over 1.5 seconds
  - [ ] Gold spotlight on loot drop position
  - [ ] Sealed door re-opens with animation
  - [ ] Golden sparkle particles at loot location
  - [ ] Hazards deactivate permanently
  - [ ] Victory moment feels rewarding

### Task 35.13: Enemy Spawn Point Visuals
- **Status:** TODO
- **Description:** Create visual markers for enemy spawn points that telegraph where enemies will appear. Design a spawn pad: a 1m diameter circle on the floor with a glowing ring that activates 1 second before an enemy materializes. The ring color matches the enemy type (red for GlitchBug, green for MemoryLeak, blue for RogueProcess). Add a particle effect: data/energy swirling upward from the pad as the enemy materializes (digital dissolution in reverse). After the enemy spawns, the pad dims and becomes inactive floor. This gives the player critical information: how many enemies, what type, and where they'll appear.
- **Acceptance Criteria:**
  - [ ] Spawn pad visual on arena floor
  - [ ] Glowing ring activates 1s before spawn
  - [ ] Ring color indicates enemy type
  - [ ] Materialization particle effect (digital dissolution)
  - [ ] Pad dims after spawn complete
  - [ ] Player gets tactical information from spawn visuals

### Task 35.14: Arena Navigation Mesh Optimization
- **Status:** TODO
- **Description:** Configure navigation meshes for all arena types to enable proper enemy AI pathfinding. Each arena needs: walkable area marked (excluding walls, pillars, and solid obstacles), ramp navigation links for level changes, cover positions marked for enemy AI to use, patrol points for pre-combat enemy placement, and proper agent radius settings (enemies are wider than the player). Test pathfinding for each arena by spawning enemies at each spawn point and verifying they can reach the player at any position. Fix any navigation deadlocks where enemies get stuck on corners or in alcoves.
- **Acceptance Criteria:**
  - [ ] Navigation mesh covers all walkable areas per arena
  - [ ] Ramps and level changes navigable
  - [ ] No pathfinding deadlocks or stuck positions
  - [ ] Agent radius appropriate for enemy sizes
  - [ ] Enemies can reach player from any spawn to any position
  - [ ] Cover positions accessible to enemy AI

### Task 35.15: Arena Gameplay Testing — Pillared Hall
- **Status:** TODO
- **Description:** Playtest the Pillared Hall arena with actual combat encounters. Spawn 4-6 enemies of mixed types and play through the encounter. Evaluate: is there enough room to dodge between pillars? Can the player use pillars for meaningful LOS breaks? Do enemies navigate around pillars effectively? Is the arena too large (boring running) or too small (no room to breathe)? Does the combat flow create interesting tactical moments? Adjust pillar positions, room size, or spawn points based on findings. Play through at least 5 times with different enemy compositions.
- **Acceptance Criteria:**
  - [ ] 5+ playthroughs with varied enemy compositions
  - [ ] Pillar cover is tactically useful
  - [ ] Enemies navigate pillars without getting stuck
  - [ ] Room size feels appropriate for combat
  - [ ] Adjustments applied based on playtesting
  - [ ] Arena is fun and tactically interesting

### Task 35.16: Arena Gameplay Testing — Elevated and Multi-Level
- **Status:** TODO
- **Description:** Playtest the Elevated Platform and Multi-Level arenas with combat encounters. For the Elevated Platform: verify ramps create interesting choke points, height advantage is meaningful but not overpowered, enemies use ramps effectively. For Multi-Level: verify the drop-down creates interesting risk/reward decisions, enemies on both levels create pressure, the grated floor visual tracking works for gameplay awareness. Adjust platform heights, ramp widths, and level connections based on findings. Ensure both arenas create combat that feels different from the flat arenas.
- **Acceptance Criteria:**
  - [ ] Elevated Platform playtested 5+ times
  - [ ] Multi-Level playtested 5+ times
  - [ ] Height advantage balanced (meaningful but fair)
  - [ ] Ramps and connections create tactical interest
  - [ ] Both arenas feel distinct from flat arenas
  - [ ] Adjustments applied based on playtesting

### Task 35.17: Arena Gameplay Testing — Corridor and Hazard
- **Status:** TODO
- **Description:** Playtest the Narrow Corridor and Hazard Grid arenas. For the Corridor: verify the cramped space creates tension, alcove ambushes feel surprising, destructible barriers add gameplay variety. For Hazard Grid: verify hazard timing is learnable but challenging, hazard warnings give enough reaction time, kiting enemies into hazards is viable and fun, safe zones are large enough for combat but small enough to be tense. Adjust corridor width, alcove positions, hazard timings, and zone sizes based on findings.
- **Acceptance Criteria:**
  - [ ] Corridor playtested 5+ times
  - [ ] Hazard Grid playtested 5+ times
  - [ ] Corridor tension and ambush surprise work
  - [ ] Hazard timings are learnable and fair
  - [ ] Kiting into hazards is viable strategy
  - [ ] Adjustments applied based on playtesting

### Task 35.18: Arena Visual Polish Pass
- **Status:** TODO
- **Description:** Do a visual polish pass on all arenas after gameplay adjustments. Add detail props in non-gameplay areas (corners, behind spawn alcoves): pipes, cables, broken terminals, mushroom clusters. Ensure each arena type has a distinct visual identity beyond just layout: Pillared Hall has circuit-traced pillars, Elevated has industrial platform supports, Corridor has pipe-lined walls, Multi-Level has grated views, Hazard Grid has red floor markings, Circular Pit has concentric ring textures. Add wall-mounted lights at key positions for gameplay readability. Verify all arenas look good with floor theme variations (clean on Floor 1, corrupted on Floor 4).
- **Acceptance Criteria:**
  - [ ] Detail props added in non-gameplay areas
  - [ ] Each arena has distinct visual identity
  - [ ] Gameplay-relevant areas well-lit
  - [ ] Arenas work with all floor theme variations
  - [ ] No visual clutter in combat areas
  - [ ] Arenas look polished and intentional

### Task 35.19: Arena Performance Profiling
- **Status:** TODO
- **Description:** Profile each arena with worst-case combat: maximum enemies, all destructibles breaking, hazards active, combat lighting, particles. Measure frame time per arena. The most demanding arena (likely Hazard Grid with active hazards + enemies + particles) must stay at 60fps. If any arena drops below: reduce particle counts, simplify hazard effects, limit simultaneous destructible breaks, or reduce shadow-casting lights. Document performance per arena and per floor theme combination (Floor 5 theme on Hazard Grid is the worst case).
- **Acceptance Criteria:**
  - [ ] Each arena profiled with worst-case combat
  - [ ] All arenas maintain 60fps at 1080p
  - [ ] Floor theme combinations tested
  - [ ] Optimizations applied where needed
  - [ ] Performance documented per arena
  - [ ] Worst-case identified and confirmed performant

### Task 35.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture screenshots of all arena types from the isometric camera: empty (showing layout), during combat (showing tactical use), and victory state. Create top-down diagrams overlaid on screenshots showing tactical flow arrows. Save to `_bmad-output/visual-overhaul/screenshots/epic-35/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Each arena captured empty, in-combat, and victory
  - [ ] Top-down tactical diagrams created
  - [ ] All 7 arena types documented
  - [ ] Media saved to correct directory
  - [ ] MASTER-PLAN.md updated
  - [ ] Arenas look visually distinct in screenshots

---

## Dependencies

- **Epic 31** (Dungeon Tileset) — Tiles for arena construction
- **Epic 32** (Dungeon Props) — Props for arena detail
- **Epic 33** (Dungeon Lighting) — Combat lighting system
- **Epic 05** (Combat Fixes) — Working combat for playtesting

## Notes

- Arena design is where art and gameplay design intersect most directly — every visual element affects gameplay
- Playtest EARLY with greybox (untextured) versions to nail the layout before spending time on polish
- The "3 second rule" for hazard warnings is a starting point — adjust based on playtesting
- Destructible cover adds hugely to combat feel but is expensive; budget 3-4 destructibles per arena max
- Boss arena is detailed in Epic 37 — this epic focuses on the 6 regular combat arenas
