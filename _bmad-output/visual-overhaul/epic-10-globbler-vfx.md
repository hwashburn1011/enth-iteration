---
epic_id: 10
title: "Epic 10: Globbler VFX Integration"
phase: 4
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 10: Globbler VFX Integration

## Overview
Create and integrate all visual effects for Globbler's actions — attack trails, dash afterimages, footstep dust, impact rings, charge energy, healing particles, and level-up celebrations. Each VFX is built in Godot using GPUParticles3D, mesh-based geometry, and shaders, following the style guide's rule of simple shapes with gradient textures. These effects are the final polish layer that transforms functional animations into satisfying, juicy gameplay moments that players feel in their bones.

## Success Criteria
- Every player action has appropriate visual feedback (no "silent" actions)
- VFX are color-coded according to the accent palette (cyan for player, green for heal, gold for level-up)
- Particle counts stay within performance budgets (max 50 particles per effect, 60fps on GTX 1060)
- Effects are synchronized to animation events and feel tightly connected to character movement

## Tasks

### Task 10.01: Create Attack Swing Trail Mesh and Material
**Status:** TODO
**Description:** Build a mesh-based swing trail for the primary attack. Model a thin crescent arc mesh in Blender (or construct via ImmediateMesh in Godot): a curved plane 0.8m wide, 0.15m tall, with 8 segments along the arc for smooth curvature. The arc follows the path of Globbler's arm swing. Create a gradient texture for the trail: solid cyan (#00FFDD) at the leading edge, fading to transparent at the trailing edge and at both tips. Apply as a ShaderMaterial with additive blending, emission enabled (energy 2.0), and alpha based on the gradient texture. The trail mesh is a child of the character and rotated to match the swing arc via animation keyframes.
**Acceptance Criteria:**
- Trail mesh is a smooth crescent arc matching the attack animation's swing path
- Gradient fades from solid cyan to transparent, creating a clean speed-line look
- Additive blending makes the trail glow against any background

### Task 10.02: Animate Attack Swing Trail Timing
**Status:** TODO
**Description:** Synchronize the swing trail with the attack animation using animation method calls or a dedicated AnimationPlayer track. The trail should appear at attack frame 3 (swing start) with scale 0.0 → 1.0 over 1 frame (instant appear). During the swing (frames 3-6), the trail rotates with the arm, following the arc path. At frame 6 (swing end), the trail begins fading: scale stays at 1.0 but opacity decreases from 1.0 to 0.0 over 4 frames (0.13s fade). The trail mesh is disabled (visible = false) after fully faded. Use a Tween node or shader TIME parameter for the fade animation to keep it decoupled from the AnimationPlayer.
**Acceptance Criteria:**
- Trail appears instantly at swing start and is gone within 0.2s of swing end
- Trail rotation matches the arm's arc path during the swing
- Fade-out is smooth and doesn't leave visual artifacts

### Task 10.03: Create Charge Release Burst Trail
**Status:** TODO
**Description:** Build a larger, more dramatic swing trail for the charge attack release. Use the same crescent arc mesh but scaled 1.5x wider and with a different texture: brighter cyan center (#00FFFF) with a white-hot core (#FFFFFF) along the leading edge, creating a more intense energy feel. Add a secondary ring mesh (a torus with 0.4m radius) that expands outward from the swing origin at the moment of release (scale 0.0 → 2.0 over 0.2s, then fade). The ring uses the same cyan with additive blending. Together, the larger trail + expanding ring communicate "this attack is much stronger than normal."
**Acceptance Criteria:**
- Charge trail is visibly larger and brighter than the primary attack trail
- Expanding ring adds a "shockwave" feel to the release
- Both elements combined clearly communicate "charged/powerful attack"

### Task 10.04: Create Dash Afterimage System
**Status:** TODO
**Description:** Implement a dash afterimage effect that leaves 3-4 ghosted copies of Globbler along the dash path. When the dash starts (frame 0), spawn a MeshInstance3D copy of Globbler's current mesh at the current position. Apply a ShaderMaterial that: sets the albedo to a flat teal (#00CCAA at 50% opacity), enables transparency (alpha blend), disables shadows, and fades the alpha from 0.5 to 0.0 over 0.3s via a shader TIME parameter. Spawn additional copies at frames 2, 4, and 6 of the 8-frame dash. Each copy is an independent node that fades and self-destructs (queue_free) after 0.3s. Maximum 4 afterimages at once.
**Acceptance Criteria:**
- 3-4 ghosted copies appear along the dash trajectory
- Each ghost is a flat-colored semi-transparent version of Globbler (not full-detail textured)
- Ghosts fade out smoothly and self-destruct, leaving no orphan nodes

### Task 10.05: Create Dash Afterimage Shader
**Status:** TODO
**Description:** Write the shader for dash afterimages (`assets/shaders/afterimage.gdshader`). The shader: (1) Uses a uniform `color` (default cyan #00CCAA), (2) Uses a uniform `spawn_time` set to TIME when the ghost is created, (3) Calculates age as `TIME - spawn_time`, (4) Sets alpha to `max(0.0, 0.5 - age * 1.67)` (fades from 0.5 to 0.0 over 0.3s), (5) Applies a slight upward vertex offset based on age (`VERTEX.y += age * 0.1`) so ghosts subtly drift upward as they fade (ethereal feel), (6) Disables depth writing for correct transparency sorting, (7) Uses additive or alpha blend rendering mode.
**Acceptance Criteria:**
- Shader fades alpha from 0.5 to 0.0 over 0.3 seconds based on spawn time
- Subtle upward drift adds an ethereal, dissolving quality to the afterimages
- Shader is self-contained with uniforms for easy customization (color, fade speed)

### Task 10.06: Create Footstep Dust Particle System
**Status:** TODO
**Description:** Build a GPUParticles3D system for footstep dust puffs. Particle configuration: amount 8, one-shot mode, lifetime 0.4s, emit sphere radius 0.05m. Direction: upward (Y+) with slight random spread (15 degrees). Initial velocity: 0.5 m/s upward. Gravity: 1.0 downward (particles rise then fall). Scale: start 0.05m, end 0.0m (shrink to nothing). Color: start #B0A090 (warm dust color matching the ground palette) at opacity 0.6, end same color at opacity 0.0. Material: Billboard particles using a simple soft circle texture (32x32 white circle with soft edges). The system is triggered by the footstep animation events from Epic 09 Task 09.17.
**Acceptance Criteria:**
- 8 dust particles puff upward from each footstep, then shrink and fade
- Particle color matches the warm ground palette (not grey, not white)
- One-shot emission fires exactly when the foot contacts the ground

### Task 10.07: Create Surface-Adaptive Footstep Particles
**Status:** TODO
**Description:** Extend the footstep system to change particle appearance based on the surface material beneath the character. Detect surface via raycast downward from each foot position, reading the surface's physics material or group. Surface variants: grass — green-brown (#7A9A6A) particles with upward scatter, stone — grey (#9A9A9A) particles with minimal height (chips, not puffs), dirt — brown (#8A6A4A) particles (standard dust puff), wood — tiny wood-tone (#AA8A6A) particles with horizontal scatter, water/puddle — blue (#4A8ABA) splash particles with more velocity. Each variant reuses the same GPUParticles3D node but swaps the process material's color gradient.
**Acceptance Criteria:**
- At least 4 surface types produce visually distinct footstep particles
- Surface detection correctly identifies the material type via raycast
- Color and behavior differences are noticeable and match the surface expectation

### Task 10.08: Create Dash Landing Impact Ring
**Status:** TODO
**Description:** Build an impact effect for the moment Globbler lands from a dash (dash animation frame 7-8). The effect is a ring that expands outward from the landing point. Implementation: a torus mesh (major radius starting at 0.1m, minor radius 0.03m) with a shader that expands the major radius from 0.1 to 0.6m over 0.3s while fading opacity from 0.8 to 0.0. Color: warm dust (#B0A090) with slight cyan tint (#88BBAA) to indicate energy. Combine with a burst of 12 dust particles emitting radially outward at ground level (ring-shaped emission). The combined effect looks like a small energy-infused dust explosion.
**Acceptance Criteria:**
- Expanding ring and radial dust burst fire at the dash landing moment
- Ring expands from small to ~0.6m radius and fades within 0.3s
- Combined effect communicates "energetic landing" with both geometry and particles

### Task 10.09: Create Charge Energy Buildup Particles
**Status:** TODO
**Description:** Build the particle system for the charge attack's energy buildup phase (plays during `attack_charge_loop`). Use GPUParticles3D with 20 particles, continuous emission, lifetime 0.8s. Particles spawn in a sphere (radius 1.0m) around Globbler and converge TOWARD the character center (negative radial velocity, -2.0 m/s). This creates the "energy gathering inward" effect. Particle appearance: small glowing orbs (0.03m scale), color cyan (#00FFDD) with emission energy 3.0, billboard mode. Add a secondary system with 5 larger particles orbiting the character (achieved via a ring emitter with tangential velocity) for a swirling energy look.
**Acceptance Criteria:**
- Inward-converging particles create a visible "gathering energy" effect
- 5 orbiting particles add a swirling secondary layer
- Combined effect intensifies the longer the charge is held (via increasing emission rate or brightness)

### Task 10.10: Create Charge Screen Distortion Effect
**Status:** TODO
**Description:** Add a subtle screen distortion during the charge buildup using a post-processing shader or a viewport-space effect. Implementation: a MeshInstance3D sphere (radius 1.5m) around Globbler with a shader that reads the screen texture and applies radial distortion (pixels pull toward the character center). Distortion intensity starts at 0.0 and increases to 0.02 over the charge duration via a shader uniform controlled by the charge script. The distortion should be subtle — just enough to feel "something powerful is happening" without causing motion sickness. Reset to 0.0 immediately on charge release.
**Acceptance Criteria:**
- Screen distortion is perceptible but subtle (0.02 max intensity)
- Distortion increases gradually during charge hold
- Distortion resets instantly on charge release (no lingering warp)

### Task 10.11: Create Charge Release Energy Burst
**Status:** TODO
**Description:** Build the energy burst VFX for the charge attack release moment. Three simultaneous effects: (1) Expanding ring — a bright cyan torus that scales from 0.3m to 3.0m radius over 0.3s with fade (stronger than the dash ring), emission energy 4.0. (2) Particle burst — 30 particles exploding outward from character center in all directions, speed 5.0 m/s, lifetime 0.4s, shrinking from 0.06m to 0.0, color transitioning from white (#FFFFFF) to cyan (#00FFDD). (3) Screen flash — a brief full-screen white overlay (CanvasLayer with ColorRect) that flashes from 30% opacity to 0% over 0.1s. All three fire simultaneously at the charge release animation event.
**Acceptance Criteria:**
- Three-layer burst (ring + particles + flash) creates a powerful release moment
- Total effect duration is under 0.4s so it doesn't obscure gameplay
- Screen flash is brief (0.1s) and subtle (30% max opacity) — not blinding

### Task 10.12: Create Heal Effect — Rising Particles
**Status:** TODO
**Description:** Build the healing VFX that plays when the player uses a health item or receives healing. GPUParticles3D configuration: 15 particles, one-shot, lifetime 1.0s. Emission shape: cylinder (radius 0.3m, height 0.1m) at character feet. Direction: upward (Y+), velocity 1.0 m/s. Particles are small crosses or plus-sign shaped (use a 64x64 texture of a soft-edged + shape). Color: bright green (#00FF88) with emission energy 2.0, fading to transparent over lifetime. Scale: 0.04m constant (no shrink, just fade). Add a gentle spiral motion by combining upward velocity with slight tangential velocity (0.3 m/s) for an elegant swirling rise.
**Acceptance Criteria:**
- Green plus-shaped particles rise from feet to above head level over 1 second
- Spiral motion adds elegance to the rising particle path
- Effect color (#00FF88 green) is immediately distinct from combat effects (cyan)

### Task 10.13: Create Heal Effect — Pulse Ring
**Status:** TODO
**Description:** Add a pulse ring that accompanies the healing particles. A horizontal torus mesh at Globbler's feet that pulses outward: scale from 0.2m to 0.8m radius over 0.5s, then fade out. Color: green (#00FF88) with emission energy 2.0, alpha fading from 0.6 to 0.0. The ring pulses twice (two sequential rings, second starting 0.3s after the first) for a heartbeat-like rhythm that reinforces the "life restored" feeling. Each ring is a separate Tween sequence on a shared mesh instance (or two mesh instances staggered in time).
**Acceptance Criteria:**
- Two sequential pulse rings expand outward with a 0.3s delay between them
- Heartbeat rhythm (pulse-pulse-rest) communicates "life/health" intuitively
- Green color matches the rising particles for a cohesive healing effect

### Task 10.14: Create Level-Up Celebration — Golden Particle Fountain
**Status:** TODO
**Description:** Build the primary level-up VFX: a fountain of golden particles erupting upward from Globbler. GPUParticles3D configuration: 40 particles, one-shot, lifetime 1.5s. Emission: point source at character center. Direction: upward with wide cone spread (45 degrees). Initial velocity: 4.0 m/s upward (particles should shoot up 1.5-2m above the character). Gravity: 3.0 (particles arc up then fall back down in a fountain shape). Color: gold (#FFD700) transitioning to warm orange (#FF9A3A) over lifetime, emission energy 3.0. Scale: start 0.05m, end 0.02m. Trail: enable particle trails (4 frames) for comet-tail streaks. The effect should feel extravagant and celebratory.
**Acceptance Criteria:**
- Golden particles fountain upward and arc back down in a satisfying spray
- Trail effect creates comet-like streaks for added spectacle
- Total particle count (40) stays within performance budget

### Task 10.15: Create Level-Up Celebration — Expanding Ring
**Status:** TODO
**Description:** Add a dramatic expanding ring to the level-up effect. This is similar to the charge release ring but gold-colored and larger. A torus mesh that expands from 0.3m to 4.0m radius over 0.6s, with gold color (#FFD700), emission energy 5.0 (very bright), alpha fading from 0.8 to 0.0. The ring should leave a brief "afterglow" at its final radius: a second, dimmer ring (emission 1.0) that appears at 4.0m radius and fades over an additional 0.5s. Combine this with a 0.3s screen flash using gold tint (#FFD700 at 20% opacity).
**Acceptance Criteria:**
- Gold ring expands dramatically to 4.0m radius over 0.6s
- Afterglow ring adds a lingering moment of celebration
- Screen flash is gold-tinted and brief, not white like the combat flash

### Task 10.16: Create Level-Up Celebration — Text Pop
**Status:** TODO
**Description:** Display a "LEVEL UP!" text effect synchronized with the level-up VFX. Spawn a Label3D (billboard mode) above Globbler's head at Y+2.0m. Text: "LEVEL UP!" in the UI font, gold color (#FFD700) with black outline (2px). Animation: the label scales from 0.0 to 1.2 over 0.15s (overshoot), settles to 1.0 at 0.25s, holds for 1.0s, then fades out over 0.5s. The label rises slowly (Y velocity 0.3 m/s) during the hold and fade phases. Use a Tween for the scale/fade animation rather than AnimationPlayer for simplicity. Queue_free the label after fade completes.
**Acceptance Criteria:**
- "LEVEL UP!" text appears with a satisfying scale-pop animation
- Gold color with black outline is readable against all background types
- Text rises and fades cleanly, self-destructing after the effect completes

### Task 10.17: Create VFX Manager Script
**Status:** TODO
**Description:** Build a centralized VFX manager script (`scripts/managers/vfx_manager.gd`) that handles spawning and pooling of all VFX. The manager provides functions: `spawn_attack_trail(position, rotation)`, `spawn_dash_afterimage(mesh, position)`, `spawn_footstep(position, surface_type)`, `spawn_impact_ring(position)`, `spawn_charge_particles(character_node)`, `spawn_burst(position)`, `spawn_heal(position)`, `spawn_level_up(position)`. Each function either instantiates a new effect scene or retrieves one from a pool. Implement simple object pooling: pre-instantiate 5 of each common effect (footsteps, afterimages) and recycle them. Connect the manager to EventBus signals for decoupled triggering.
**Acceptance Criteria:**
- VFX manager provides a clean API for all effect types
- Object pooling prevents allocation spikes during combat (pre-allocated common effects)
- Manager connects to EventBus signals so any system can trigger VFX without direct references

### Task 10.18: Connect All VFX to Animation Events
**Status:** TODO
**Description:** Wire up every VFX to its corresponding animation event or gameplay trigger. Attack trail: triggered by animation method call at attack frame 3. Dash afterimage: triggered by animation method calls at dash frames 0, 2, 4, 6. Footstep dust: triggered by footstep animation events (walk/run foot contacts). Landing impact: triggered by dash end event (frame 7). Charge particles: started by charge_start event, stopped by charge_release event. Energy burst: triggered by charge_release event. Heal particles: triggered by EventBus `player_healed` signal. Level-up effects: triggered by EventBus `player_leveled_up` signal. Verify each connection by playing through all actions and confirming VFX fire at the correct moments.
**Acceptance Criteria:**
- Every VFX fires at the exact moment it should, synchronized to animation or gameplay events
- No VFX fires late, early, or at the wrong position
- All connections use either animation method calls or EventBus signals (no polling or timer-based triggers)

### Task 10.19: Performance Profile All VFX
**Status:** TODO
**Description:** Run a performance test with all VFX active simultaneously (worst-case scenario) and measure the impact. Test scene: 5 enemies in combat with the player, player using all abilities (attack, charge, dash, heal). Monitor with Godot's Debugger > Monitors: track FPS, draw calls, vertex count, and particle count. Targets: maintain 60fps on a GTX 1060 equivalent, total particle count under 200 at any moment, total draw calls under 150. If any VFX exceeds its budget, reduce particle counts, simplify meshes, or shorten lifetimes. Document the performance baseline for future reference.
**Acceptance Criteria:**
- 60fps maintained during worst-case scenario (5 enemies, all VFX active)
- Total simultaneous particle count stays under 200
- Performance baseline numbers are documented for regression testing

### Task 10.20: Conduct Full VFX Integration Play-Test
**Status:** TODO
**Description:** Perform a comprehensive play-through testing every VFX in real gameplay context. Walk through town (verify footstep dust on different surfaces), enter dungeon (verify footsteps change on stone), engage enemies (verify attack trails, hit effects), take damage (verify screen shake + flash), use dash (verify afterimages + landing ring), hold charge attack (verify buildup particles + screen distortion), release charge (verify burst effects), use healing item (verify green particles + pulse ring), level up (verify fountain + ring + text). Rate each effect on a 1-5 scale for: timing accuracy, visual appeal, performance impact, and gameplay readability. Fix any effects scoring below 3.
**Acceptance Criteria:**
- Every VFX type fires correctly during actual gameplay
- All effects score at least 3/5 on timing, appeal, performance, and readability
- No VFX obscures important gameplay information (enemy positions, attack telegraphs)

## Dependencies
- Epic 05 (Combat System Fixes) for the damage pipeline and hitbox system that triggers combat VFX
- Epic 06 (Globbler Character Model) for the mesh used by the afterimage system
- Epic 09 (Globbler Animations) for the animation events that trigger VFX timing
- Epic 02 (Visual Style Guide v3) for VFX color palette and particle count budgets

## Notes
- VFX should enhance gameplay readability, never obscure it — if an effect makes the game harder to read, reduce it
- All VFX use the accent color palette: cyan for player actions, green for healing, gold for rewards, red for damage
- GPUParticles3D is preferred over CPUParticles3D for consistency and performance on most hardware
- Mesh-based effects (trails, rings) render more consistently than particles for specific shapes
- Screen-space effects (flash, distortion) should have user-accessible intensity settings for accessibility
- Object pooling is important for effects that fire frequently (footsteps, afterimages) but not for rare events (level-up)
