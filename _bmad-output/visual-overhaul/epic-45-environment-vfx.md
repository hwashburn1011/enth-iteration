---
epic: 45
title: "Environment VFX"
phase: 8 — VFX & Particles
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 45: Environment VFX

## Overview

Create atmospheric environment VFX: dungeon fog with light shafts, digital rain (Matrix-style data cascade), portal energy vortex, crystal growth animation, pipe steam vents, electrical sparks on damaged wires, corruption spread visual, and holographic display flicker. These effects bring the dungeon environment to life and reinforce the "inside a crumbling computer" narrative.

## Success Criteria

- Each environment VFX reinforces the digital/tech dungeon theme
- Fog with light shafts creates depth and atmosphere in every room
- Digital rain is immediately recognizable and thematically iconic
- Portal effects are visually compelling and inviting
- Corruption spread tells the degradation story visually
- All effects performant (combined under 2ms GPU cost)
- Effects work across all 5 floor themes

---

## Tasks

### Task 45.1: Dungeon Fog with Light Shafts
- **Status:** TODO
- **Description:** Implement localized dungeon fog using FogVolume nodes per room. Configure density per room type (combat rooms thicker during engagement, corridors thin, loot rooms minimal). Add volumetric light shaft effect by placing FogVolumes aligned with SpotLight3D/OmniLight3D positions. The fog should scatter light from ceiling panels creating visible beams downward, and grated floors should allow upward light shafts. Color the fog per floor theme (Floor 1: white, Floor 3: blue-gray, Floor 5: red). Create a DungeonFog.gd component that auto-configures fog based on room type and floor number.
- **Acceptance Criteria:**
  - [ ] FogVolume per room with appropriate density
  - [ ] Light shafts visible from ceiling panels
  - [ ] Upward shafts through grated floors
  - [ ] Fog color matches floor theme
  - [ ] DungeonFog.gd auto-configures per room/floor
  - [ ] Adds atmospheric depth to every room

### Task 45.2: Digital Rain — Matrix-Style Data Cascade
- **Status:** TODO
- **Description:** Create a digital rain effect using a custom shader on vertical planes placed against walls or in open spaces. The shader renders columns of falling characters (use a character grid texture — rows of small tech symbols/kanji at 16x16 per cell). Each column scrolls downward at a random speed, with the leading character bright (green #40FF40 for Floor 2, teal for general) and trailing characters fading to dark. New characters appear randomly at column tops. The rain should be semi-transparent (don't occlude the wall behind it). Place digital rain planes in data-heavy rooms (Floor 2, story rooms, server areas).
- **Acceptance Criteria:**
  - [ ] Falling character columns at varied speeds
  - [ ] Leading character bright, trailing fade
  - [ ] Semi-transparent (walls visible behind)
  - [ ] Character grid texture with tech symbols
  - [ ] Color matches floor theme
  - [ ] Placed in data-heavy rooms

### Task 45.3: Portal Energy Vortex
- **Status:** TODO
- **Description:** Create a reusable portal vortex shader for dungeon portals and the compaction portal. The shader renders a circular vortex with spiraling energy arms on a disc mesh. Effect: 3-4 spiral arms rotating slowly (15 RPM), bright at the outer edge fading to a bright center point, color configurable (blue for room portals, white-gold for compaction portal). Add particle emitters: data motes being drawn toward the center (50 particles, inward radial velocity), and occasional bright flares that pulse outward from the center. The portal should cast colored light on nearby surfaces matching its color. Create PortalVortex.tscn as a reusable effect.
- **Acceptance Criteria:**
  - [ ] Spiraling energy arms rotating on disc
  - [ ] Color configurable per portal type
  - [ ] Data mote particles drawn inward
  - [ ] Occasional outward flare pulses
  - [ ] Colored light cast on nearby surfaces
  - [ ] PortalVortex.tscn reusable component

### Task 45.4: Crystal Growth Animation
- **Status:** TODO
- **Description:** Create an animation for energy crystals growing/appearing in the environment. When a crystal is revealed (room entered for the first time, or crystal spawns from a loot event): the crystal starts at 0 scale and grows to full size over 1 second with a natural crystal growth motion — quick initial growth that decelerates. The growth emits small sparkle particles matching the crystal color. The crystal's internal glow pulses brighter during growth then settles to idle intensity. If the crystal is a pickup, add a "ready to collect" idle pulse (gentle brightness oscillation at 0.5Hz). Create CrystalGrowth.gd with `grow()` and `shrink()` (reverse for collection) methods.
- **Acceptance Criteria:**
  - [ ] Growth animation from 0 to full scale over 1s
  - [ ] Decelerating growth curve (quick start, slow end)
  - [ ] Sparkle particles during growth
  - [ ] Glow pulses during growth, settles to idle
  - [ ] Collection shrink animation (reverse)
  - [ ] CrystalGrowth.gd with grow/shrink API

### Task 45.5: Pipe Steam Vents
- **Status:** TODO
- **Description:** Create steam vent particle effects for dungeon pipes. Use GPUParticles3D with: white-gray color (#D0D0D0 at 60% opacity fading to 0%), initial velocity in the vent direction (2-4 m/s), particles expand over lifetime (0.05m to 0.3m), lifetime 0.5-1.0s, 10-20 particles per second for continuous steam, use turbulence (noise-based velocity variation) for organic swirling. The vent should be triggered intermittently: 3s of steam, 2s pause, repeat. Add a subtle hissing sound hook. Place steam vents on broken pipes (Floor 3+), and on functioning valves (all floors). The steam should scatter light if a light source is nearby.
- **Acceptance Criteria:**
  - [ ] White-gray expanding particles
  - [ ] Turbulence creates organic swirling
  - [ ] Intermittent timing (3s on, 2s off)
  - [ ] Placed on broken pipes and valves
  - [ ] Sound hook for hissing
  - [ ] Light scattering in steam when near lights

### Task 45.6: Electrical Sparks on Damaged Wires
- **Status:** TODO
- **Description:** Create spark particle effects for exposed/damaged wiring in the dungeon. Model small wire bundles that protrude from damaged wall sections (or use existing damage geometry). At the exposed wire point, emit intermittent spark bursts: 5-10 bright blue-white particles (#80C0FF) in a cone away from the wire, very fast initial velocity (10-15 m/s), tiny size (0.02m), lifetime 0.1s, with 1-3 bursts per second randomly timed. Each burst should be accompanied by a brief blue flash light (OmniLight3D, range 1m, 0.05s duration). Add an electrical arc between two nearby wires (similar to Epic 36 spark trap but smaller and continuous).
- **Acceptance Criteria:**
  - [ ] Intermittent spark bursts from damaged wires
  - [ ] Blue-white fast particles in cone shape
  - [ ] Random timing (1-3 bursts per second)
  - [ ] Brief flash light with each burst
  - [ ] Small arc between nearby wires
  - [ ] Placed on Floor 3+ damaged areas

### Task 45.7: Corruption Spread Visual
- **Status:** TODO
- **Description:** Create an animated corruption spread effect that shows digital corruption growing across surfaces over time. Use animated Decal nodes that project corruption textures onto surfaces with a time-based reveal: the corruption texture has an alpha mask that expands outward from a seed point using a dissolve noise pattern, making the corruption appear to grow organically across the wall/floor. The growth speed is configurable (slow for atmospheric, fast for boss phase transitions). Corruption veins glow with the floor theme's corruption color (purple for Floor 4, red for Floor 5). Create CorruptionSpread.gd with `spread(speed: float, max_radius: float)` method.
- **Acceptance Criteria:**
  - [ ] Corruption grows outward from seed points
  - [ ] Dissolve noise pattern creates organic growth
  - [ ] Speed configurable for different contexts
  - [ ] Vein glow matches floor theme color
  - [ ] Works on walls and floors via Decal projection
  - [ ] CorruptionSpread.gd with configurable API

### Task 45.8: Holographic Display Flicker
- **Status:** TODO
- **Description:** Create a holographic display flicker effect for data terminals and information displays. The hologram shader should render a semi-transparent 3D object (simple geometric shapes: rotating cube, sphere, or data graph) with: scan line overlay (horizontal lines at 2px spacing), slight vertical jitter (random Y offset, 1-2px, every few frames), color in the terminal's emission color (teal by default), alpha oscillation (opacity varies 50-80% at 2-3Hz), and occasional full flicker (0% opacity for 1-2 frames, random interval 2-5 seconds). The display content should rotate slowly. Create HologramDisplay.tscn with configurable content mesh and color.
- **Acceptance Criteria:**
  - [ ] Semi-transparent 3D hologram rendering
  - [ ] Scan line overlay
  - [ ] Vertical jitter for instability
  - [ ] Color matches terminal emission
  - [ ] Occasional full flicker/dropout
  - [ ] HologramDisplay.tscn with configurable content

### Task 45.9: Data Stream Flow Effect
- **Status:** TODO
- **Description:** Create a data stream effect showing data flowing along dungeon walls, pipes, and circuit traces. Use a shader on a flat mesh strip placed along the path: the shader animates bright dots/dashes traveling along the strip in one direction (like data packets flowing through a network). Color: teal (#40C0C0) dots on a dark transparent background. Speed: 2-4 m/s flow rate. Dots should vary in brightness and size for organic feel. Place data stream strips along major circuit traces on walls, following pipe paths, and between connected terminals. The streams should be denser on Floor 2 and nearly absent on Floor 4-5.
- **Acceptance Criteria:**
  - [ ] Animated dots flowing along strip paths
  - [ ] Direction follows pipe/circuit paths
  - [ ] Teal color matching the dungeon aesthetic
  - [ ] Varying brightness and size for organic feel
  - [ ] Density varies by floor (more on Floor 2, less on 4-5)
  - [ ] Placed along major circuit traces and pipes

### Task 45.10: Ambient Dust Particles in Dungeon
- **Status:** TODO
- **Description:** Create ambient floating dust particles for dungeon rooms. Use GPUParticles3D with very small billboard quads (0.01-0.02m), warm gray color (#A0A0A0 at 20% opacity), extremely slow drift (0.02 m/s random direction), long lifetime (10-15s), and low emission rate (5-10 per second per room). The particles should be barely visible — a subtle atmospheric haze that adds depth when lit by light shafts. More particles in abandoned areas (Floor 3), fewer in clean areas (Floor 1). The dust should be lit by nearby light sources (additive blending works well). This is the dungeon equivalent of the town's dust motes.
- **Acceptance Criteria:**
  - [ ] Very small, slow-drifting particles
  - [ ] Barely visible except in light shafts
  - [ ] Additive blending catches nearby light
  - [ ] Density varies by floor cleanliness
  - [ ] Low emission rate (subtle, not distracting)
  - [ ] Adds atmospheric depth to rooms

### Task 45.11: Energy Conduit Pulse
- **Status:** TODO
- **Description:** Create a pulse effect for energy conduits running along dungeon walls and ceilings. The conduit is a thin tube mesh with emission material. The pulse is a bright spot that travels along the conduit: shader-based, using UV scroll to move a bright spot along the conduit's length, leaving a brief glow trail behind it. Speed: 2-3 m/s. Pulse interval: every 3-5 seconds. Color matches the floor theme (teal default, green Floor 2, etc.). The pulse should appear to flow between connected components (terminal to server rack, for example). Create ConduitPulse.gd that manages pulse timing and direction.
- **Acceptance Criteria:**
  - [ ] Bright spot travels along conduit mesh
  - [ ] Glow trail behind the pulse
  - [ ] 3-5 second pulse interval
  - [ ] Color matches floor theme
  - [ ] Flows between connected components
  - [ ] ConduitPulse.gd manages timing

### Task 45.12: Warning Light Beacon
- **Status:** TODO
- **Description:** Create a rotating warning light effect for hazardous areas (near boss doors, damaged zones, restricted areas). Model a small beacon unit (0.1m cylinder on the wall or ceiling). The beacon has a colored lens that rotates, casting a sweeping beam. Implement with a SpotLight3D rotating via AnimationPlayer (360 degrees over 2 seconds). The light color indicates danger level: yellow for caution, orange for danger, red for critical. Add a lens flare particle at the beacon source (bright point that flashes as the lens faces the camera). Place beacons near the boss approach corridor (red), near hazard zones (orange), and near locked doors (yellow).
- **Acceptance Criteria:**
  - [ ] Rotating beacon with sweeping light beam
  - [ ] Color-coded by danger level
  - [ ] Lens flare when facing camera
  - [ ] 2-second rotation period
  - [ ] Placed near boss doors, hazards, locked areas
  - [ ] Visible and atmospheric from gameplay distance

### Task 45.13: Broken Screen Static
- **Status:** TODO
- **Description:** Create a static/noise effect for broken terminal screens and monitors (Floor 3+). On damaged terminals, replace the normal screen content with: animated static noise (rapid random pixel noise shader), occasional brief image fragments (1-2 frames of the original screen content flashing through the static), and color banding (horizontal bands of shifted color). The static should be rendered as an emission shader so the broken screen still casts light (flickering, unstable light matching the static pattern). Create BrokenScreen.gd that can be applied to any terminal to convert it from functional to broken state.
- **Acceptance Criteria:**
  - [ ] Animated static noise on screen surface
  - [ ] Occasional image fragments flash through
  - [ ] Color banding for instability feel
  - [ ] Screen still emits unstable light
  - [ ] BrokenScreen.gd converts functional to broken
  - [ ] Applied to terminals on Floor 3+

### Task 45.14: Floor-Specific Environment VFX Sets
- **Status:** TODO
- **Description:** Configure which environment VFX are active on each floor. Floor 1: clean — data streams active, conduit pulses active, no sparks/steam, minimal dust, no corruption. Floor 2: data-heavy — digital rain active, extra data streams, all conduits pulsing, hologram displays active. Floor 3: decayed — steam vents active, electrical sparks, broken screens, heavy dust, dripping water particles, some data streams flickering/broken. Floor 4: corrupted — corruption spread active, glitch particles, most screens broken, sparks, degraded data streams. Floor 5: consumed — maximum corruption, red pulsing, minimal tech effects (all systems dead), organic particles. Create a FloorVFXConfig resource.
- **Acceptance Criteria:**
  - [ ] VFX set defined per floor
  - [ ] Floor 1 is clean and functional
  - [ ] Floor 3 shows decay and failure
  - [ ] Floor 5 is corrupted and organic
  - [ ] FloorVFXConfig resource per floor
  - [ ] Progressive degradation tells the story

### Task 45.15: VFX LOD and Distance Culling
- **Status:** TODO
- **Description:** Implement LOD and distance culling for all environment VFX. Configure visibility ranges: steam vents visible to 15m, sparks to 10m, data streams to 20m, corruption to 25m, hologram displays to 12m, dust motes to 8m. Effects beyond their range should fade out (not pop). Effects in rooms the player isn't in should be paused entirely (not just invisible — stop GPU computation). Implement a VFXCuller.gd that manages active/inactive state based on player distance and room occupancy. This is critical because environment VFX are persistent and would accumulate cost across the entire dungeon.
- **Acceptance Criteria:**
  - [ ] Visibility ranges per VFX type
  - [ ] Fade out at range (not pop)
  - [ ] Effects in non-player rooms paused
  - [ ] VFXCuller.gd manages active states
  - [ ] GPU cost only for visible effects
  - [ ] Smooth fade transitions at range

### Task 45.16: Environment VFX Interaction with Player
- **Status:** TODO
- **Description:** Add subtle interactions between environment VFX and the player. When the player walks through steam: steam particles briefly scatter away from the player (add repulsion force from player position). When the player walks through a digital rain plane: rain characters briefly change to player-related data. When the player is near sparking wires: occasional stray spark lands on the player (tiny spark particle on character). When the player stands on corruption: small corruption particles rise from their feet. These micro-interactions make the environment feel reactive and alive.
- **Acceptance Criteria:**
  - [ ] Steam scatters when player walks through
  - [ ] Digital rain reacts to player proximity
  - [ ] Stray sparks occasionally land on player
  - [ ] Corruption rises from player's feet on corrupt ground
  - [ ] Interactions are subtle (enhancement, not distraction)
  - [ ] All interactions performant

### Task 45.17: VFX Audio Integration Hooks
- **Status:** TODO
- **Description:** Add audio hooks for all environment VFX. Emit EventBus signals: `env_steam_vent(position: Vector3, intensity: float)`, `env_spark_burst(position: Vector3)`, `env_corruption_pulse(position: Vector3)`, `env_conduit_pulse(position: Vector3, direction: Vector3)`, `env_screen_static(position: Vector3)`, `env_data_rain_ambient(active: bool)`. These signals allow the spatial audio system to play appropriate sounds at the VFX positions. Steam vents should be continuous (signal on start/stop), sparks should be per-burst, corruption should pulse with the heartbeat.
- **Acceptance Criteria:**
  - [ ] Audio signals for all VFX types
  - [ ] Position data for spatial audio
  - [ ] Continuous vs. burst signal types
  - [ ] Signals emitted at correct times
  - [ ] Signals follow project conventions
  - [ ] All environment VFX have audio hooks

### Task 45.18: VFX Quality Settings Integration
- **Status:** TODO
- **Description:** Integrate all environment VFX with the VFX quality settings from Epic 44. At High: all effects at full particle count and shader complexity. At Medium: reduce particle counts by 40%, disable screen-space effects on hologram flicker, simplify steam turbulence, reduce data stream density. At Low: further reduce particles to 25%, disable digital rain shader (replace with simple particle columns), disable corruption spread animation (static decals instead), disable ambient dust. Ensure the dungeon still looks atmospheric at Low quality — remove detail but keep the mood.
- **Acceptance Criteria:**
  - [ ] All env VFX respect quality settings
  - [ ] High: full effects as designed
  - [ ] Medium: reduced but atmospheric
  - [ ] Low: minimal but mood-preserving
  - [ ] Quality transitions are smooth
  - [ ] Dungeon atmosphere maintained at all quality levels

### Task 45.19: Performance Profiling
- **Status:** TODO
- **Description:** Profile all environment VFX combined on the most demanding floor (Floor 3 with steam, sparks, dust, broken screens, data streams, and conduit pulses in a single room). Measure total GPU cost at each quality level. Target: High under 2ms, Medium under 1.5ms, Low under 0.5ms. Verify VFX culling properly deactivates effects in non-visible rooms. Test with 3 rooms visible simultaneously (corridors between rooms). Fix any GPU cost spikes.
- **Acceptance Criteria:**
  - [ ] Most demanding floor profiled
  - [ ] High: under 2ms total
  - [ ] Medium: under 1.5ms
  - [ ] Low: under 0.5ms
  - [ ] Culling verified for non-visible rooms
  - [ ] 3-room visibility tested

### Task 45.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture screenshots and videos of all environment VFX: dungeon fog with light shafts, digital rain, portal vortex, crystal growth, steam vents, electrical sparks, corruption spread, hologram flicker, data streams, and conduit pulses. Show effects on different floor themes. Record video of player walking through a VFX-rich dungeon corridor. Save to `_bmad-output/visual-overhaul/screenshots/epic-45/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All VFX types captured
  - [ ] Floor theme variations shown
  - [ ] Video of VFX-rich corridor walk
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 31-34** (Dungeon environment) — Dungeon geometry for VFX placement
- **Epic 33** (Dungeon Lighting) — Light integration
- **Epic 44** (Combat VFX) — VFX pool and quality systems

## Notes

- Environment VFX are the "texture" of the dungeon experience — they fill the space between combat moments
- Digital rain is iconic and immediately communicates "you're inside a computer"
- Performance management is critical — these effects are always running, unlike combat VFX
- VFX culling is the #1 performance strategy — don't render what the player can't see
- Floor-specific VFX sets make each floor feel distinctly different
