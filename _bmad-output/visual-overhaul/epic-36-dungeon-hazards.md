---
epic: 36
title: "Dungeon Hazard Visuals"
phase: 6 — Dungeon Environment
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 36: Dungeon Hazard Visuals

## Overview

Create visually compelling hazard effects for the dungeon: laser grid with beam shader, acid pool with dissolve shader, spark trap with electricity particles, crushing wall with warning lights, rotating blade with motion blur, data corruption zone with glitch shader, and fire vent with flame particles. Each hazard must be immediately readable (players must understand the danger within 0.5 seconds) while being visually spectacular enough to enhance the dungeon's atmosphere.

## Success Criteria

- 7 distinct hazard types with unique visual effects
- Each hazard readable within 0.5 seconds (shape = danger type)
- Warning phase clearly distinguishable from active phase
- Hazard visual effects feel dangerous and impactful
- Active hazards create dynamic lighting (laser casts red, acid casts green, etc.)
- All hazard effects maintain 60fps even with 3+ active simultaneously
- Hazard visuals work across all 5 floor themes

---

## Tasks

### Task 36.1: Hazard Visual Design Reference
- **Status:** TODO
- **Description:** Collect reference images and design the visual language for all 7 hazards. For each hazard define: the active visual (what it looks like when dangerous), the warning visual (what warns the player), the idle visual (when inactive/safe), the damage area shape and size, the color coding (red = physical damage, green = acid/poison, blue = electric, purple = data corruption, orange = fire), and any special shader or particle needs. Create a one-page reference sheet showing all 7 hazards in their 3 states (idle, warning, active). This reference ensures visual consistency across all hazard implementations.
- **Acceptance Criteria:**
  - [ ] All 7 hazards designed with 3 states each
  - [ ] Color coding system defined and documented
  - [ ] Active/warning/idle visuals distinct per hazard
  - [ ] Damage area shape and size defined per hazard
  - [ ] Reference sheet created showing all hazards
  - [ ] Visual language is consistent and learnable

### Task 36.2: Laser Grid — Beam Shader
- **Status:** TODO
- **Description:** Create a laser beam shader (`res://shaders/laser_beam.gdshader`) for the laser grid hazard. The laser is a horizontal beam crossing the corridor at waist height. The shader renders on a quad mesh stretched along the beam path. Effect: bright red core (#FF2020) with soft red glow falloff (#FF4040 -> transparent), animated noise along the beam length creating a "scanning" effect (bright spots traveling along the beam), and heat distortion haze around the beam (offset screen UV sampling). Add a GPUParticles3D emitter where the beam hits walls (red sparks). The beam should cast red light on nearby surfaces via an accompanying OmniLight3D strip.
- **Acceptance Criteria:**
  - [ ] Beam shader renders bright red core with glow
  - [ ] Animated noise creates scanning effect along beam
  - [ ] Heat distortion visible around the beam
  - [ ] Spark particles where beam contacts walls
  - [ ] Beam casts red light on nearby surfaces
  - [ ] Instantly readable as "don't touch this"

### Task 36.3: Laser Grid — Animation States
- **Status:** TODO
- **Description:** Implement the laser grid's 3 states with smooth transitions. Idle: emitter nodes visible as small red dots on walls (showing where the beam will appear), no beam. Warning: red dots pulse brighter, a thin pilot beam flickers between them (low opacity, intermittent), warning sound cue trigger. Active: full beam snaps on at 100% intensity, holds for 3-5 seconds. The beam can optionally sweep vertically (slow oscillation) or toggle on/off in a pattern. Create a LaserGrid.gd script managing the state machine with configurable timing, beam count (1-4 parallel beams), and sweep pattern. Each beam should have independent timing for pattern variety.
- **Acceptance Criteria:**
  - [ ] 3 states: idle (dots), warning (pilot beam), active (full beam)
  - [ ] Smooth transitions between states
  - [ ] Configurable timing per state
  - [ ] Optional sweep and toggle patterns
  - [ ] Multiple parallel beams with independent timing
  - [ ] LaserGrid.gd manages complete state machine

### Task 36.4: Acid Pool — Dissolve Shader
- **Status:** TODO
- **Description:** Create an acid pool shader (`res://shaders/acid_pool.gdshader`) for a floor hazard. The pool is a flat mesh on the ground with: bubbling surface animation (vertex displacement with random bubble bumps), bright toxic green base color (#40FF40 at 70% opacity), darker green depth (center more opaque), foam/froth at edges where acid meets floor (use depth fade like water shader). Add bubble particle GPUParticles3D (small green spheres rising from the surface, popping at 0.5m height). The acid should cast green light downward and onto nearby walls. Create a dissolve effect where objects touching the acid appear to corrode (darken and roughen from the contact point outward).
- **Acceptance Criteria:**
  - [ ] Bubbling surface animation
  - [ ] Toxic green with depth-based opacity
  - [ ] Edge foam at pool boundaries
  - [ ] Bubble particles rising and popping
  - [ ] Green light cast on surroundings
  - [ ] Dissolve/corrosion visual on contact

### Task 36.5: Acid Pool — Area and States
- **Status:** TODO
- **Description:** Implement the acid pool states and area configuration. Idle: floor area has a slight green stain/discoloration (texture overlay suggesting acid residue), small green wisps of gas. Warning: green bubbling begins, acid seeps up from floor cracks, green glow intensifies, gas wisps become thicker. Active: full acid pool at maximum intensity, bubbling vigorously, damage area matches the visual pool boundary. Create an AcidPool.gd script with configurable area (rectangular or circular), damage per tick, activation timer, and floor theme tinting (on Floor 4-5, the acid might be purple instead of green). The pool boundary should use the HazardWarning system from Epic 35.
- **Acceptance Criteria:**
  - [ ] 3 states with distinct visuals
  - [ ] Configurable area shape (rectangle/circle)
  - [ ] Green stain remains even when inactive
  - [ ] Warning shows acid seeping up
  - [ ] Damage area matches visual boundary
  - [ ] Floor theme color override supported

### Task 36.6: Spark Trap — Electricity Particles
- **Status:** TODO
- **Description:** Create an electricity/spark trap hazard. Model two electrode prongs on opposite walls or floor/ceiling. When active, electrical arcs jump between the prongs. Create the arc effect using a Line2D-like approach in 3D: a series of connected points forming a jagged lightning bolt path between the two prongs, regenerated every 2-3 frames for a flickering effect. Color: bright blue-white (#80C0FF core, #4080FF outer glow). Add branching sub-arcs (smaller bolts forking off the main arc). Spark particles scatter from both prong contact points. The arc should cast bright blue light on nearby surfaces. Add a crackling particle effect (tiny bright dots jumping erratically near the arc).
- **Acceptance Criteria:**
  - [ ] Jagged lightning arc between two prongs
  - [ ] Arc regenerates every 2-3 frames (flickering)
  - [ ] Blue-white color with outer glow
  - [ ] Branching sub-arcs for complexity
  - [ ] Spark particles at contact points
  - [ ] Blue light cast on nearby surfaces

### Task 36.7: Spark Trap — States and Timing
- **Status:** TODO
- **Description:** Implement spark trap states. Idle: electrode prongs visible with a faint blue glow, small occasional spark (1 per 2-3 seconds) between prongs. Warning: prongs glow brighter, sparks increase in frequency (2-3 per second), a charging hum sound cue triggers, small arcs begin forming. Active: full electrical arc for 2-4 seconds with maximum brightness and particle density. The trap should have a rhythmic on/off pattern (active 2s, idle 4s, repeat). Create SparkTrap.gd with configurable prong positions, arc path (straight, angled), timing, and damage. Multiple spark traps should have staggered timing.
- **Acceptance Criteria:**
  - [ ] 3 states with escalating electrical activity
  - [ ] Rhythmic on/off pattern
  - [ ] Configurable prong positions and arc path
  - [ ] Staggered timing between multiple traps
  - [ ] Charging warning is clearly visible
  - [ ] SparkTrap.gd manages state machine

### Task 36.8: Crushing Wall — Model and Warning Lights
- **Status:** TODO
- **Description:** Create the crushing wall hazard: a heavy metal wall section that slides out from one wall, crushes anything in its path, then retracts. Model the crusher as a thick (0.5m) wall section with reinforced plating, hydraulic rams on the sides, and a row of warning lights along the top edge (5 small circle lights). Paint the texture with heavy metal, hazard yellow-black stripes on the crushing face, and hydraulic oil stains. The warning lights should cycle through a sequence: all off (idle), sequential yellow activation left-to-right (warning), all red and pulsing (imminent), then the wall extends. Create a CrushWall.gd script managing the slide-out animation (0.3s fast), hold (0.5s), and retract (1s slow).
- **Acceptance Criteria:**
  - [ ] Crusher modeled with reinforced plating and hydraulics
  - [ ] Hazard stripes on crushing face
  - [ ] 5 warning lights with sequential activation
  - [ ] Fast extension (0.3s), hold (0.5s), slow retract (1s)
  - [ ] Crushing face model and texture look heavy/dangerous
  - [ ] CrushWall.gd handles full animation cycle

### Task 36.9: Rotating Blade — Model and Motion Blur
- **Status:** TODO
- **Description:** Create a rotating blade hazard: a saw blade embedded in the floor that spins at high speed. Model the blade as a circular disc (1m diameter, 0.05m thick) with serrated teeth around the edge. Texture paint with dark metal and wear marks on the teeth. For the motion blur effect: when spinning, replace the blade mesh with a semi-transparent disc showing radial blur streaks (either a shader effect that smears the texture radially, or a pre-rendered blurred version). The spinning blade should create a cutting wind effect (thin particle trails from the teeth) and cast dynamic light (spark shower when anything touches it). Sound: high-pitched spinning whine.
- **Acceptance Criteria:**
  - [ ] Blade modeled with serrated teeth detail
  - [ ] Motion blur effect when spinning at full speed
  - [ ] Radial blur creates sense of dangerous speed
  - [ ] Wind/particle trails from blade tips
  - [ ] Spark shower on contact with objects
  - [ ] Blade looks lethally fast when active

### Task 36.10: Rotating Blade — States and Path
- **Status:** TODO
- **Description:** Implement blade states and movement patterns. Idle: blade visible but stationary, reflective metal surface, no danger. Warning: blade begins to spin slowly (visibly accelerating), motor sound cue, sparks from the axle as it starts. Active: full speed rotation with motion blur, blade can either stay stationary (area denial) or move along a track path (sweeping across the room). For tracked blades, create a visible groove in the floor showing the path. Create RotatingBlade.gd with: configurable spin speed, movement path (Path3D), movement speed, and timing pattern. The blade should smoothly accelerate/decelerate.
- **Acceptance Criteria:**
  - [ ] 3 states: stationary, spinning up, full speed
  - [ ] Smooth acceleration and deceleration
  - [ ] Optional track path with visible floor groove
  - [ ] Configurable speed and movement pattern
  - [ ] RotatingBlade.gd manages full lifecycle
  - [ ] Track path clearly shows blade's route

### Task 36.11: Data Corruption Zone — Glitch Shader
- **Status:** TODO
- **Description:** Create a data corruption zone hazard unique to this game's digital theme. The corruption zone is a 3D volume (FogVolume or transparent mesh) where reality breaks down. Create a corruption shader: inside the zone, the rendered image is distorted with chromatic aberration, scan line tears, pixel displacement, and color inversion patches. Objects inside the zone appear to glitch and fragment. Model the zone boundary as an unstable shimmering membrane (vertex-animated mesh with noise displacement). Add floating glitch particles inside the zone (rectangular pixel blocks in random neon colors). The zone damages the player's "data integrity" (health) while inside.
- **Acceptance Criteria:**
  - [ ] Corruption zone distorts the view inside it
  - [ ] Chromatic aberration, scan tears, pixel displacement
  - [ ] Shimmering boundary membrane visible
  - [ ] Glitch particles float inside the zone
  - [ ] Zone boundary is clearly defined (player knows inside vs. outside)
  - [ ] Effect is thematically unique to the digital setting

### Task 36.12: Data Corruption Zone — States
- **Status:** TODO
- **Description:** Implement corruption zone states. Idle: faint shimmer at the zone boundary (barely visible), occasional small glitch particle. Warning: shimmer intensifies, boundary becomes clearly visible, glitch particles increase, corrupted data symbols appear floating in the zone. Active: full corruption effect with maximum distortion, dense particles, strong boundary membrane, damage active. The zone should expand slightly during active phase and contract during idle. Create CorruptionZone.gd with configurable volume size, damage rate, activation pattern, and distortion intensity. On Floor 4-5, corruption zones should be more common and larger.
- **Acceptance Criteria:**
  - [ ] 3 states with escalating corruption visibility
  - [ ] Zone expands during active, contracts during idle
  - [ ] Configurable size, damage, and timing
  - [ ] Floor 4-5 scaled variants
  - [ ] CorruptionZone.gd manages lifecycle
  - [ ] Unique to the game's digital theme

### Task 36.13: Fire Vent — Flame Particles
- **Status:** TODO
- **Description:** Create a fire vent hazard: a floor grate that periodically blasts flame upward. Model the vent as a circular grate (0.5m diameter) with a dark opening below. Create the flame effect using GPUParticles3D: orange-yellow (#FF8020 -> #FFD040) particles shooting upward (5-8 m/s initial velocity), particle count 100-200 during active phase, lifetime 0.3-0.5s, size starting at 0.1m and expanding to 0.3m, alpha fading from 100% to 0% over lifetime. Add a heat distortion effect above the flame (screen-space shader on a mesh above the vent). The flame should cast warm orange light upward onto the ceiling and nearby walls.
- **Acceptance Criteria:**
  - [ ] Flame particles shoot upward from floor grate
  - [ ] Orange-yellow color gradient over lifetime
  - [ ] 100-200 particles during active (dense flame)
  - [ ] Heat distortion above the flame column
  - [ ] Warm orange light cast on ceiling and walls
  - [ ] Flame looks hot and dangerous

### Task 36.14: Fire Vent — States and Timing
- **Status:** TODO
- **Description:** Implement fire vent states. Idle: vent grate visible with faint orange glow from below (ember glow emission), occasional small flame lick (1-2 particles per second). Warning: rumbling sound, glow intensifies, more frequent flame licks (5-10 per second), vent edges glow orange-hot. Active: full flame blast for 2-3 seconds with maximum particle density, light intensity, and heat distortion. Create FireVent.gd with configurable blast duration, cooldown, flame height (1-3m column), and spread angle. Multiple vents can create flame walls when placed in a row.
- **Acceptance Criteria:**
  - [ ] 3 states: ember glow, warming, full blast
  - [ ] Configurable blast duration and cooldown
  - [ ] Adjustable flame height and spread
  - [ ] Multiple vents can create flame walls
  - [ ] FireVent.gd manages complete lifecycle
  - [ ] Warning gives player 1-2 seconds reaction time

### Task 36.15: Hazard Dynamic Lighting
- **Status:** TODO
- **Description:** Ensure every hazard properly contributes dynamic lighting to the dungeon. Add OmniLight3D or SpotLight3D nodes to each hazard that activate with the hazard: Laser = red directional light along beam, Acid = green pool light, Spark = blue flash light (rapid flicker synced with arcs), Crusher = yellow warning lights + white flash on impact, Blade = white spinning light (no, just ambient metal reflection), Corruption = purple unstable light, Fire = orange uplight. Each light should scale intensity with the hazard state (dim during warning, bright during active). Ensure hazard lights interact correctly with the room's combat lighting.
- **Acceptance Criteria:**
  - [ ] Each hazard type has color-coded dynamic lighting
  - [ ] Light intensity matches hazard state
  - [ ] Hazard lights visible in dark dungeon rooms
  - [ ] Lights interact correctly with combat red lighting
  - [ ] Multiple hazards create dynamic, colorful lighting
  - [ ] Performance acceptable with 3+ hazard lights active

### Task 36.16: Hazard Damage Visual Feedback
- **Status:** TODO
- **Description:** Create visual feedback for when the player takes damage from each hazard type. Laser: red burn line across the player (brief texture flash), camera shake. Acid: green dissolve particles on the player, screen edge green tint. Spark: electric arc effect on the player (small lightning bolts), screen flash white. Crusher: heavy impact shake, debris particles. Blade: slash effect (red arc), blood/data particles. Corruption: full-screen glitch effect intensifies, pixel scatter on player. Fire: orange flame cling particles on player, screen edge orange. Each feedback should be distinct so the player knows what hit them without looking.
- **Acceptance Criteria:**
  - [ ] 7 distinct damage feedback effects (one per hazard)
  - [ ] Player can identify hazard type from feedback alone
  - [ ] Camera effects (shake, tint, flash) per hazard
  - [ ] Particle effects on player character per hazard
  - [ ] Feedback is impactful but brief (doesn't obscure gameplay)
  - [ ] All feedbacks tested and visually distinct

### Task 36.17: Hazard Combinations and Interactions
- **Status:** TODO
- **Description:** Design and test visual interactions when multiple hazards are active near each other. Verify: laser and fire don't create confusing overlapping red (laser should be brighter, sharper). Acid pool and corruption zone look different when adjacent (green vs. purple). Spark trap and laser create an interesting blue+red light show. Fire and acid create contrasting warm+cool danger zones. Ensure the visual language remains clear with 2-3 hazards visible simultaneously — the player must still instantly identify each danger. Adjust colors, intensities, or shapes if any combination is confusing.
- **Acceptance Criteria:**
  - [ ] All hazard combinations tested visually
  - [ ] No confusing overlapping similar colors
  - [ ] Each hazard identifiable with others active nearby
  - [ ] Light combinations create interesting (not muddy) results
  - [ ] 2-3 simultaneous hazards remain readable
  - [ ] Problematic combinations adjusted

### Task 36.18: Hazard Scene Prefabs
- **Status:** TODO
- **Description:** Create reusable .tscn scene prefabs for each hazard type that can be drag-and-dropped into any dungeon room. Each prefab should include: the hazard mesh/visual, all particle systems, all light nodes, the damage Area3D with appropriate CollisionShape3D, the warning system (from Epic 35), the hazard script with @export configuration variables, and an @export enum for floor theme compatibility. Document each prefab's configuration options in a comment at the script top. Save all prefab scenes to `res://scenes/dungeon/hazards/`.
- **Acceptance Criteria:**
  - [ ] 7 hazard .tscn prefab scenes created
  - [ ] Each includes mesh, particles, lights, collision, script
  - [ ] @export variables for easy configuration
  - [ ] Floor theme compatibility setting
  - [ ] Documentation comments in each script
  - [ ] Prefabs saved in correct directory

### Task 36.19: Performance Profiling with Multiple Hazards
- **Status:** TODO
- **Description:** Profile performance with multiple hazards active simultaneously in a single room. Test worst case: Hazard Grid arena (from Epic 35) with 3 different hazard types cycling. Measure: particle rendering cost per hazard, shader cost per hazard, dynamic light cost per hazard, total frame time. Target: 3+ active hazards maintain 60fps. If over budget: reduce particle counts on least visible hazards, simplify shaders (remove heat distortion if expensive), reduce hazard light shadow quality, or use baked lights instead of dynamic for some effects.
- **Acceptance Criteria:**
  - [ ] 3+ simultaneous hazards profiled
  - [ ] Per-hazard performance cost documented
  - [ ] 60fps maintained with 3+ active hazards
  - [ ] Optimizations applied if needed
  - [ ] Worst-case scenario tested (Hazard Grid arena)
  - [ ] Performance acceptable on mid-range hardware

### Task 36.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture each hazard in all 3 states (idle, warning, active). Record short video clips of each hazard activating through its cycle. Show hazard combinations in the Hazard Grid arena. Capture damage feedback effects. Save to `_bmad-output/visual-overhaul/screenshots/epic-36/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All 7 hazards captured in 3 states
  - [ ] Video clips of activation cycles
  - [ ] Hazard combinations shown
  - [ ] Damage feedback effects captured
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 31** (Dungeon Tileset) — Room environment for hazard placement
- **Epic 33** (Dungeon Lighting) — Room lighting for hazard light integration
- **Epic 35** (Combat Arena) — Hazard Grid arena and warning system

## Notes

- Readability is king — if the player can't instantly understand a hazard, it's a design failure regardless of how cool it looks
- Color coding MUST be consistent: red=physical, green=acid, blue=electric, purple=corruption, orange=fire
- The data corruption zone is this game's unique hazard — make it feel special and thematically fitting
- Test hazards against the combat red lighting to ensure they're still visible during encounters
- Consider accessibility: provide a settings option for high-contrast hazard outlines for colorblind players
