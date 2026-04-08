---
epic: 34
title: "Floor Visual Themes"
phase: 6 — Dungeon Environment
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 34: Floor Visual Themes

## Overview

Create unique visual themes for each of the 5 dungeon floors: Floor 1 (clean tutorial, bright and sterile), Floor 2 (data center, green screen glow), Floor 3 (abandoned, broken pipes, flickering), Floor 4 (corrupted, glitch visual artifacts), Floor 5 (boss core, pulsing red, organic corruption). Each floor should feel like a distinct zone within the computer simulation, telling the story of increasing degradation and corruption as the player descends deeper.

## Success Criteria

- Each floor is immediately visually distinguishable from the others
- Visual degradation clearly increases from Floor 1 (pristine) to Floor 5 (corrupted)
- Floor-specific color palettes established and consistent within each floor
- Unique props, textures, or overlays per floor that reinforce the theme
- Smooth visual transition when descending between floors
- Floor themes enhance gameplay readability (Floor 4 corruption = danger visual)
- All floor themes maintain 60fps

---

## Tasks

### Task 34.1: Floor Theme Design Document
- **Status:** TODO
- **Description:** Create a detailed visual design document for all 5 floor themes. For each floor define: dominant color palette (3-4 colors), accent color, lighting preset modifications (from Epic 33 base), unique props or prop modifications, texture tint or overlay, particle effects, audio mood, and narrative justification within the "crumbling simulation" story. Include reference images for each floor's target look. Map the degradation progression: Floor 1 = brand new server room, Floor 2 = busy working data center, Floor 3 = abandoned/failing, Floor 4 = actively corrupting, Floor 5 = consumed by corruption. This document guides all subsequent tasks.
- **Acceptance Criteria:**
  - [ ] All 5 floor themes fully described with visual details
  - [ ] Color palettes defined per floor (specific hex values)
  - [ ] Degradation progression is logical and visual
  - [ ] Reference images collected per floor
  - [ ] Narrative justification per floor documented
  - [ ] Design document reviewed before implementation

### Task 34.2: Floor 1 — Clean Tutorial Theme Setup
- **Status:** TODO
- **Description:** Implement Floor 1's visual theme: clean, bright, sterile, brand-new server room. Override the base tile materials with a Floor 1 variant: brighten the wall color by 15% (#7A8A9A -> #8A9AAA), clean up all rust and damage textures (use pristine versions), set ceiling light panels to 100% brightness with pure white (#FFFFFF) emission. Remove damaged floor tiles — use only plain and tech panel variants. All pipes should be clean (no rust). Server racks should have 90%+ active bays (mostly green LEDs). Add a slight bloom/glow to everything to create a "just-manufactured" feeling. The tutorial floor should feel safe and controlled.
- **Acceptance Criteria:**
  - [ ] Walls brighter and cleaner than base texture
  - [ ] No rust, damage, or wear visible
  - [ ] Ceiling lights at full brightness, pure white
  - [ ] Only pristine floor tiles used
  - [ ] Server racks mostly active (green LEDs)
  - [ ] Atmosphere feels new, safe, and sterile

### Task 34.3: Floor 2 — Data Center Theme Setup
- **Status:** TODO
- **Description:** Implement Floor 2's visual theme: busy working data center with green screen ambiance. Apply a green color tint to the lighting: ceiling panels emit cool white with green tint (#D0FFD0), data terminals have brighter green screens (#40FF40), server racks are fully active with predominantly green status lights. Add extra data terminal props along corridors (this floor has the most active computing). Create a green ambient haze (FogVolume with green tint, density 0.008). Add scrolling data visualization on terminal screens (Matrix-style green code via emission map animation or shader). The floor should feel alive with processing activity — humming with computation.
- **Acceptance Criteria:**
  - [ ] Green tint to lighting throughout
  - [ ] Data terminals more numerous than other floors
  - [ ] Server racks fully active with green status
  - [ ] Green ambient haze/fog
  - [ ] Scrolling data on terminal screens
  - [ ] Floor feels alive with active computation

### Task 34.4: Floor 3 — Abandoned Theme Setup
- **Status:** TODO
- **Description:** Implement Floor 3's visual theme: abandoned, failing infrastructure. Increase damaged floor tile usage to 40-50% of floor area. Add broken pipe props with dripping water particles (from Epic 28). 50% of ceiling lights are flickering or dead (using FlickerLight from Epic 33). Apply a blue-gray desaturation to the lighting ambient (#606878). Server racks have 70% dead bays (red/dark LEDs). Add debris props on the floor: fallen panels, loose cables, broken glass. Puddles form under broken pipes. Introduce mushroom clusters in dark corners (life growing in the abandonment). The floor should feel like years of neglect.
- **Acceptance Criteria:**
  - [ ] 40-50% damaged floor tiles
  - [ ] Broken pipes with drip particles
  - [ ] Half the lights flickering or dead
  - [ ] Desaturated blue-gray lighting
  - [ ] Server racks mostly dead
  - [ ] Floor debris (panels, cables, glass)

### Task 34.5: Floor 4 — Corrupted Theme Setup
- **Status:** TODO
- **Description:** Implement Floor 4's visual theme: active digital corruption consuming the environment. Apply a glitch visual overlay to the screen (subtle chromatic aberration and occasional scan line disruption via post-process shader). Corruption "growths" appear on walls and floor — organic-looking tendrils in dark purple-red (#5A1A2A) modeled as simple mesh overlays or decal projections. Lighting becomes unstable: random color shifts between normal and corrupted (purple/magenta #C040C0). Some wall sections have visual holes showing a void/digital noise behind them. Add glitch particle effects (small squares that appear, distort, and disappear). 70% of tech systems are dead; only corrupted ones glow.
- **Acceptance Criteria:**
  - [ ] Glitch post-process overlay (chromatic aberration, scan lines)
  - [ ] Corruption growths on walls and floors
  - [ ] Unstable lighting with random color shifts
  - [ ] Visual "holes" in walls showing void
  - [ ] Glitch particle effects
  - [ ] 70% of tech dead, remaining is corrupted purple

### Task 34.6: Floor 5 — Boss Core Theme Setup
- **Status:** TODO
- **Description:** Implement Floor 5's visual theme: the corrupted core, pulsing red organic nightmare. Replace metal wall textures with a hybrid organic-tech texture: metal base visible underneath fleshy corruption that covers 60-80% of surfaces. The corruption is dark red-black (#3A0A0A) with pulsing veins of bright red (#FF2020) that pulse in a slow heartbeat rhythm (1 beat per 2 seconds). All ceiling lights are dead — the only illumination comes from the pulsing corruption veins (emission), energy crystals (if present), and the player's own abilities. Thick red fog (density 0.03). The floor should feel alive and hostile — like being inside a corrupted organism.
- **Acceptance Criteria:**
  - [ ] Organic corruption covers 60-80% of surfaces
  - [ ] Pulsing red veins with heartbeat rhythm
  - [ ] All ceiling lights dead
  - [ ] Only corruption and crystals provide light
  - [ ] Thick red atmospheric fog
  - [ ] Floor feels alive, organic, and hostile

### Task 34.7: Corruption Growth Mesh/Decal System
- **Status:** TODO
- **Description:** Create the corruption visual overlay system used on Floors 4 and 5. Model 4-5 corruption growth variants in Blender: tendril patches (flat decal-like meshes that project onto walls/floors), node clusters (bulbous growths at wall junctions), vein networks (thin branching lines across surfaces), and a large mass (focal corruption point). UV unwrap and texture paint with dark organic colors plus emissive veins. In Godot, create these as Decal nodes or MeshInstance3D overlay props that can be placed on any surface. Create a CorruptionGrowth.gd script that animates the emissive pulse and can spread over time.
- **Acceptance Criteria:**
  - [ ] 4-5 corruption mesh variants modeled and textured
  - [ ] Emissive veins painted with pulsing capability
  - [ ] Placeable as decals or overlay meshes on any surface
  - [ ] CorruptionGrowth.gd animates emissive pulse
  - [ ] Visual style matches Floor 4/5 theme
  - [ ] Corruption can "spread" via animation

### Task 34.8: Glitch Post-Process Shader
- **Status:** TODO
- **Description:** Create a screen-space post-process glitch shader (`res://shaders/glitch_overlay.gdshader`) for Floor 4's corruption effect. Apply it via a full-screen ColorRect or a custom rendering pass. The shader should include: chromatic aberration (split RGB channels with slight offset, intensity 0.002-0.005), scan line overlay (horizontal lines at 2px spacing, 5% opacity), occasional horizontal tear (random chance per frame, a section of the screen shifts horizontally for 1-2 frames then snaps back), and static noise patches (small rectangular areas filled with noise for 1-3 frames). All effects should have a `corruption_intensity` uniform (0.0-1.0) so they can scale with floor depth.
- **Acceptance Criteria:**
  - [ ] Chromatic aberration with configurable intensity
  - [ ] Scan line overlay at appropriate density
  - [ ] Random horizontal tear effect
  - [ ] Static noise patches
  - [ ] corruption_intensity uniform controls all effects
  - [ ] Shader doesn't cause discomfort at intended intensities

### Task 34.9: Floor-Specific Prop Variations
- **Status:** TODO
- **Description:** Create or modify prop appearances per floor to reinforce themes. Floor 1: pristine versions of all props (no damage, full glow). Floor 2: extra terminals and racks (quantity, not quality change). Floor 3: damaged props (toppled racks, broken terminals from Epic 32 damage variants), overgrown with mushrooms. Floor 4: corrupted props (corruption growths on racks, terminals showing glitch screens, crystals with unstable flicker). Floor 5: most props are consumed by corruption (barely recognizable), only corruption masses and a few crystals remain. Document which prop variants are used on each floor.
- **Acceptance Criteria:**
  - [ ] Floor 1 uses pristine prop variants
  - [ ] Floor 2 has increased terminal/rack density
  - [ ] Floor 3 uses damaged variants with mushroom overgrowth
  - [ ] Floor 4 has corruption-overlaid props
  - [ ] Floor 5 props are consumed, barely recognizable
  - [ ] Variant usage documented per floor

### Task 34.10: Floor Color Palette Application to Tiles
- **Status:** TODO
- **Description:** Create per-floor color tint materials for the dungeon tileset. Rather than repainting entire textures, create ShaderMaterial overrides that tint the base tile textures per floor. Floor 1: slight blue-white tint (clean). Floor 2: green tint on emissive elements. Floor 3: desaturated blue-gray tint. Floor 4: purple-red corruption tint. Floor 5: deep red-black tint. The shader should blend between the base texture and the floor's tint color based on a `tint_strength` uniform. Save these as .tres material resources per floor. This approach reuses base textures while giving each floor a distinct color identity.
- **Acceptance Criteria:**
  - [ ] Tint shader created with configurable color and strength
  - [ ] Floor 1-5 tint materials saved as .tres resources
  - [ ] Each floor has a distinct color identity
  - [ ] Base texture detail preserved under tint
  - [ ] Tint materials apply to wall, floor, and ceiling tiles
  - [ ] Color progression tells degradation story

### Task 34.11: Floor Transition Visual — Elevator/Descent
- **Status:** TODO
- **Description:** Create a visual effect for when the player descends to a new floor, emphasizing the theme change. When the player activates the floor transition: play a brief descending elevator animation (screen scrolls downward with metal walls blurring past), flash the new floor's dominant color as a screen tint during transition, then fade in to the new floor's environment. During the transition, display the floor number and name in the custom game font (from Epic 39) with floor-appropriate styling: Floor 1 = clean white text, Floor 4 = glitching purple text, Floor 5 = blood-red dripping text. Transition duration: 2-3 seconds.
- **Acceptance Criteria:**
  - [ ] Descending elevator visual during floor transition
  - [ ] New floor's color flashes during transition
  - [ ] Floor number and name displayed in themed style
  - [ ] Text styling matches floor theme
  - [ ] Transition is 2-3 seconds
  - [ ] Transition communicates "going deeper"

### Task 34.12: Floor 3 — Water and Environmental Hazard Visuals
- **Status:** TODO
- **Description:** Add environmental detail specific to Floor 3's abandoned theme. Place water puddles (from Epic 28) under broken pipes and in low spots. Add steam/vapor particles rising from broken pipes (white-gray GPUParticles3D, upward drift, short lifetime). Create spark particle effects on exposed wiring (small yellow-white sparks, intermittent). Add fallen ceiling panels on the floor (use ceiling tile meshes rotated and placed as debris). Create a dripping ambient sound trigger zone for pipe areas. The floor should feel like an infrastructure failure in progress — water, steam, sparks, and debris everywhere.
- **Acceptance Criteria:**
  - [ ] Water puddles under broken pipes
  - [ ] Steam particles from pipe breaks
  - [ ] Spark particles on exposed wiring
  - [ ] Fallen ceiling panels as floor debris
  - [ ] Sound trigger zones for dripping ambient
  - [ ] Infrastructure failure atmosphere achieved

### Task 34.13: Floor 4 — Digital Void Holes
- **Status:** TODO
- **Description:** Create the "void hole" visual for Floor 4 where the simulation is breaking apart. Model a ragged-edged hole mesh that can overlay on walls and floors. Behind the hole, render a scrolling digital noise pattern (shader: random black/white pixel noise scrolling rapidly) to represent the void outside the simulation. The hole edges should have glitch particle effects (small rectangles in neon colors appearing and disappearing). Add a faint light source from the void (cool white #C0C0FF, energy 0.3) that illuminates the hole edges. Place 3-5 void holes per room on Floor 4, increasing to more near the floor exit.
- **Acceptance Criteria:**
  - [ ] Ragged-edged hole meshes modelable on walls and floors
  - [ ] Digital noise shader visible through holes
  - [ ] Glitch particles at hole edges
  - [ ] Faint void light illuminates edges
  - [ ] 3-5 holes per room on Floor 4
  - [ ] Holes increase in frequency toward floor exit

### Task 34.14: Floor 5 — Organic Pulsing Animation
- **Status:** TODO
- **Description:** Implement the heartbeat pulse animation for Floor 5's corruption veins. Create a shader that modulates the emission intensity of corruption vein textures in a heartbeat pattern: two quick pulses (bright for 0.15s, dim for 0.1s, bright for 0.15s) followed by a longer rest (dim for 1.6s), totaling a 2-second cycle. The pulse should propagate spatially — veins near the floor's center (boss room) pulse first, then the wave travels outward, creating a visible "pulse wave" that ripples through the corridors. This requires a distance-from-center calculation in the shader using world position.
- **Acceptance Criteria:**
  - [ ] Heartbeat pulse pattern (two quick beats, rest)
  - [ ] 2-second cycle duration
  - [ ] Pulse propagates spatially from center outward
  - [ ] Wave visible traveling through corridors
  - [ ] All corruption veins on Floor 5 participate
  - [ ] Effect is mesmerizing but not nauseating

### Task 34.15: Floor Theme Transition Blending
- **Status:** TODO
- **Description:** Implement visual blending between floor themes at the boundaries. When a floor has rooms near the exit to the next floor, those rooms should show hints of the next floor's theme: Floor 1 exit rooms have a few green-tinted terminals (Floor 2 hint), Floor 2 exit rooms have a few flickering lights and a broken pipe (Floor 3 hint), Floor 3 exit rooms have purple corruption spots starting to appear (Floor 4 hint), Floor 4 exit rooms have red organic growths beginning (Floor 5 hint). This foreshadowing prepares the player for what's coming and makes the progression feel continuous rather than abrupt.
- **Acceptance Criteria:**
  - [ ] Exit rooms blend current and next floor themes
  - [ ] Hints of next floor are subtle (10-20% presence)
  - [ ] Each transition foreshadows the next floor correctly
  - [ ] Blending feels natural, not forced
  - [ ] Progression feels continuous across floors
  - [ ] Player subconsciously notices the shift

### Task 34.16: Floor-Specific Ambient Particle Effects
- **Status:** TODO
- **Description:** Create ambient particle effects unique to each floor. Floor 1: clean white data motes floating in air (sparse, gentle). Floor 2: green data streams flowing along walls (like data visualized moving through circuits). Floor 3: dust particles falling from ceiling (debris, heavier than town dust). Floor 4: glitch particles throughout (random colored squares appearing/disappearing). Floor 5: red spore particles drifting upward from corruption (organic, slow, menacing). Each floor's particles should be immediately recognizable and reinforce the floor's identity.
- **Acceptance Criteria:**
  - [ ] Floor 1: white data motes
  - [ ] Floor 2: green data streams along walls
  - [ ] Floor 3: falling dust/debris particles
  - [ ] Floor 4: random glitch square particles
  - [ ] Floor 5: red spore particles from corruption
  - [ ] Each floor's particles are distinctive

### Task 34.17: Create Floor Theme Manager
- **Status:** TODO
- **Description:** Create a FloorThemeManager.gd script that coordinates all floor-specific visual changes. The manager receives the current floor number and applies: tile material tint, lighting preset modifications, fog settings, ambient particle activation, post-process shader intensity (glitch for Floor 4-5), corruption growth density, and prop variant selection. Provide methods: `apply_floor_theme(floor_number: int)`, `blend_floor_themes(current: int, next: int, blend_factor: float)` for transition rooms, and `get_floor_palette() -> Dictionary` returning the current floor's color values for other systems to reference.
- **Acceptance Criteria:**
  - [ ] FloorThemeManager coordinates all visual changes
  - [ ] apply_floor_theme() configures all visual systems
  - [ ] blend_floor_themes() handles transition rooms
  - [ ] get_floor_palette() provides colors to other systems
  - [ ] All 5 floors correctly themed through the manager
  - [ ] Script follows project coding standards

### Task 34.18: Playtest Each Floor Theme
- **Status:** TODO
- **Description:** Walk through all 5 floors in sequence and evaluate each theme's effectiveness. For each floor, assess: is the theme immediately recognizable? Does it feel different from adjacent floors? Is the color palette consistent within the floor? Does the degradation progression feel natural? Are there any readability issues (can the player see enemies, items, and navigation clearly)? Does the mood match the gameplay intensity of that floor? Take notes and screenshots of any issues. Fix problems before proceeding — every floor must pass the "screenshot test" (a single screenshot clearly communicates which floor you're on).
- **Acceptance Criteria:**
  - [ ] All 5 floors walked through in sequence
  - [ ] Each floor passes the "screenshot test" (instantly recognizable)
  - [ ] Degradation progression feels natural
  - [ ] No gameplay readability issues on any floor
  - [ ] Mood matches gameplay intensity per floor
  - [ ] All identified issues fixed

### Task 34.19: Performance Profiling Per Floor
- **Status:** TODO
- **Description:** Profile rendering performance on each floor, particularly Floors 4 and 5 which have the most visual effects (glitch shader, corruption meshes, particles, pulsing emission). Measure frame time per floor with typical room content. Floor 4's glitch post-process shader should be lightweight (<0.5ms). Floor 5's pulsing emission shader should update efficiently. Corruption growth meshes should not add excessive draw calls (consider batching). If any floor drops below 60fps, optimize: reduce particle counts, simplify shaders, reduce corruption mesh density, lower fog quality.
- **Acceptance Criteria:**
  - [ ] Each floor profiled for frame time
  - [ ] Floor 4 glitch shader under 0.5ms
  - [ ] Floor 5 pulse animation performant
  - [ ] All floors maintain 60fps at 1080p
  - [ ] Optimizations applied where needed
  - [ ] Performance documented per floor

### Task 34.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture comprehensive screenshots showing each floor's visual theme. Take matching camera angles on each floor for direct comparison. Create a 5-image strip showing the degradation progression (Floor 1 to Floor 5 at the same room type). Capture close-up details unique to each floor: Floor 2 green screens, Floor 3 water/debris, Floor 4 void holes and glitch, Floor 5 corruption veins pulsing. Save to `_bmad-output/visual-overhaul/screenshots/epic-34/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Each floor captured at matching camera angle
  - [ ] 5-image degradation progression strip
  - [ ] Close-up unique details per floor
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated
  - [ ] Progression tells a clear visual story

---

## Dependencies

- **Epic 31** (Dungeon Tileset) — Base tiles for theming
- **Epic 32** (Dungeon Props) — Props for floor-specific variants
- **Epic 33** (Dungeon Lighting) — Lighting presets for floor modification

## Notes

- Floor identity should be so strong that a screenshot from any floor is instantly identifiable without UI
- The degradation progression IS the visual narrative — it tells the player they're descending into danger
- Floor 4's glitch effects should be uncomfortable but not seizure-inducing; include a settings option to reduce/disable
- Floor 5's organic corruption is the visual climax — make it alien and beautiful in its horror
- Performance is most at risk on Floors 4-5; budget extra optimization time for these
