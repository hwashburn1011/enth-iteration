---
epic: 15
title: "Enemy Shared VFX"
phase: 3
status: TODO
priority: high
estimated_hours: 50
dependencies: [1, 2, 5]
---

# Epic 15: Enemy Shared VFX

## Overview

Create the shared visual effects system used by all enemies in Enth: Iteration. These VFX are universal -- every enemy type (GlitchBug, MemoryLeak, RogueProcess, Corrupted Compiler, and future enemies) uses the same spawn, death, hit reaction, aggro, status, damage number, and health bar systems. This creates visual consistency across the combat experience and reduces per-enemy VFX workload. All effects are built using Godot's GPUParticles3D, shaders, and UI overlay systems.

**Design Philosophy:** The simulation/digital theme permeates all VFX. Enemies do not bleed -- they glitch, scatter into pixels, and dissolve into data fragments. Spawn effects look like digital assembly. Hit reactions are electric/static flashes. Status effects overlay digital corruption patterns. This reinforces the "crumbling computer simulation" narrative at every combat interaction.

**Quality Target:** VFX should be readable at isometric camera distance, satisfying to trigger, and performant with 10+ enemies on screen simultaneously. Particle budgets must account for worst-case scenarios (full room of enemies all dying at once).

## Success Criteria

- [ ] Spawn materialization effect works on all enemy types
- [ ] Death dissolution effect (pixel scatter) works on all enemy types
- [ ] Hit reaction flash is immediate and satisfying
- [ ] Aggro indicator clearly communicates enemy awareness state
- [ ] Status effect overlays are distinct and readable
- [ ] Damage numbers display cleanly and stack properly
- [ ] Health bars are clear and consistent across enemy sizes
- [ ] All effects perform well with 10+ enemies active

---

## Tasks

### Task 15.1: VFX Architecture and Shared Scene Design
**Status:** TODO
**Description:** Design the technical architecture for the shared VFX system. Create a base VFX controller script (`enemy_vfx_controller.gd`) that attaches to every enemy scene as a child node. This controller manages all shared VFX by listening to EventBus signals: `enemy_spawned`, `enemy_hit`, `enemy_died`, `enemy_aggro_changed`, `enemy_status_applied`, `enemy_status_removed`. The controller instantiates VFX scenes from a preloaded dictionary, positions them relative to the enemy mesh, and manages their lifecycle (auto-queue-free after effect completes). Design the VFX scene hierarchy: each effect is a standalone PackedScene containing particles, meshes, shaders, and an AnimationPlayer for timing. Document the API for triggering each effect type.
**Acceptance Criteria:**
- `enemy_vfx_controller.gd` script designed with EventBus integration
- VFX scene dictionary maps effect names to PackedScene paths
- Each VFX is a self-contained scene with auto-cleanup
- API documented: spawn, death, hit, aggro, status, damage_number, health_bar
- Architecture supports arbitrary enemy mesh sizes (scales to bounds)
- Static typed GDScript following project conventions

### Task 15.2: Spawn Materialization -- Digital Assembly Effect
**Status:** TODO
**Description:** Create the spawn materialization VFX scene. When an enemy spawns, it should appear to be digitally assembled from scattered data. Effect sequence (1.5 seconds): Phase 1 (0-0.5s): a vertical column of bright cyan particles (#00DDFF) swirls upward from the spawn point, forming a rough silhouette outline. Phase 2 (0.5-1.0s): horizontal scan lines sweep from bottom to top, "filling in" the enemy mesh (achieved via a shader that reveals the mesh using a Y-axis dissolve in reverse). Phase 3 (1.0-1.5s): final pixel pop -- small square particles burst outward as the mesh fully solidifies, accompanied by a brief bright flash. The enemy mesh should be invisible during Phase 1, partially visible during Phase 2, and fully visible at Phase 3 completion.
**Acceptance Criteria:**
- 1.5-second spawn sequence with 3 distinct visual phases
- Cyan particle column forms enemy silhouette shape
- Scan-line mesh reveal shader works with arbitrary enemy meshes
- Final pixel burst and flash mark completion
- Enemy transitions from invisible to fully visible during the effect
- Effect scales to enemy mesh bounds automatically

### Task 15.3: Spawn Materialization -- Dissolve Shader
**Status:** TODO
**Description:** Write the dissolve/reveal shader used during spawn materialization. Create a Godot shader (`spawn_dissolve.gdshader`) that takes a `reveal_progress` uniform (0.0 = fully invisible, 1.0 = fully visible). The shader uses the vertex world Y position to determine visibility: pixels below the current reveal threshold are visible, pixels above are transparent. At the boundary edge, add a 0.05m glow band in bright cyan that moves upward with the reveal line (simulating the scan-line). Add a noise texture sampling to the reveal threshold so the edge is not perfectly straight but has a digital-noise jagged pattern. The reveal_progress is animated from 0.0 to 1.0 over the Phase 2 duration (0.5s) by the VFX controller's AnimationPlayer.
**Acceptance Criteria:**
- Shader reveals mesh from bottom to top based on `reveal_progress` uniform
- Cyan glow band at the reveal boundary edge
- Noise texture creates jagged digital edge (not a clean horizontal line)
- Works with any enemy mesh material (applied as overlay or next pass)
- AnimationPlayer drives reveal_progress from 0 to 1 over 0.5s
- Shader is performant (no per-fragment texture lookups beyond noise sample)

### Task 15.4: Death Dissolution -- Pixel Scatter Effect
**Status:** TODO
**Description:** Create the death dissolution VFX scene. When an enemy dies, its mesh dissolves into scattered pixel particles. Effect sequence (2 seconds): Phase 1 (0-0.3s): enemy mesh flashes white twice (hit flash shader, 2 rapid pulses), freezes in death pose. Phase 2 (0.3-1.5s): mesh dissolves from top to bottom (reverse of spawn reveal) while GPUParticles3D emit small square pixel particles from the dissolving surface. Pixel particles inherit the enemy's color palette (red for GlitchBug, green for MemoryLeak, blue for RogueProcess -- passed as a color parameter). Particles scatter outward and downward with gravity, fading to transparent over their 1-second lifetime. Phase 3 (1.5-2.0s): final particles fade out, small data fragment text particles ("0x00", "NULL", "ERR") drift upward briefly.
**Acceptance Criteria:**
- 2-second death sequence with white flash, dissolve, and particle scatter
- Dissolve shader works top-to-bottom (reverse of spawn)
- Pixel particles colored per-enemy type (color parameter)
- Particles scatter with gravity and fade
- Data fragment text particles as final touch
- Effect auto-cleans all particles and frees resources on completion

### Task 15.5: Death Dissolution -- Dissolve Shader
**Status:** TODO
**Description:** Create or extend the dissolve shader for death dissolution (`death_dissolve.gdshader`). This shader dissolves the mesh from top to bottom: `dissolve_progress` uniform (0.0 = fully visible, 1.0 = fully dissolved). At the dissolve edge, add a bright emission band (color parameterized to match enemy type) that is wider than the spawn version (0.1m band) for more dramatic effect. Add a secondary noise pattern that creates pixel-block breakup at the dissolve edge -- instead of a smooth fade, chunks of the mesh should disappear in rectangular blocks (sample a low-resolution blocky noise texture). Below the dissolve edge, add a subtle screen-space distortion effect (optional, via SCREEN_TEXTURE if available) to suggest digital corruption. Animate from 0 to 1 over 1.2 seconds.
**Acceptance Criteria:**
- Top-to-bottom dissolve driven by `dissolve_progress` uniform
- Wide emission band at dissolve edge (color parameterized)
- Blocky/pixelated noise pattern for digital breakup aesthetic
- Chunks disappear in rectangular blocks, not smooth fade
- Animates over 1.2 seconds via AnimationPlayer
- Compatible with all enemy mesh materials

### Task 15.6: Hit Reaction Flash -- Shader and Timing
**Status:** TODO
**Description:** Create the hit reaction visual that plays every time an enemy takes damage. This is a critical game-feel element -- it must be immediate and satisfying. Create a shader (`hit_flash.gdshader`) that overrides the mesh albedo with pure white for a brief moment. The flash sequence: frame 0 -- damage received, mesh turns white; frame 2 -- mesh returns to normal; frame 4 -- mesh flashes white again (second pulse); frame 6 -- returns to normal permanently. This double-pulse pattern (at 60fps: ~33ms white, ~33ms normal, ~33ms white, done) creates a snappier feel than a single flash. The shader uses a `flash_intensity` uniform animated by the VFX controller. Also add a brief particle burst: 8-12 small spark particles emitting from the hit point in a hemisphere pattern, colored cyan/white.
**Acceptance Criteria:**
- Double-pulse white flash completes in ~100ms total
- Flash is instant and synchronizes with the damage frame
- Spark particle burst of 8-12 particles at hit point
- Flash shader works with all enemy materials (override albedo)
- `flash_intensity` uniform driven by VFX controller
- Hit reaction is satisfying and immediately readable at camera distance

### Task 15.7: Hit Reaction -- Knockback and Squash-Stretch
**Status:** TODO
**Description:** Complement the hit flash with physical reaction polish. When hit, the enemy should exhibit a brief squash-stretch: on the damage frame, scale the enemy mesh to 110% X / 90% Y (squash) over 2 frames, then bounce to 95% X / 105% Y (stretch) over 3 frames, then return to 100% over 3 frames. This 8-frame squash-stretch cycle adds physicality to hits. Additionally, apply a brief knockback: translate the enemy 0.05-0.1m away from the damage source over 4 frames, then let the AI movement system resume control. The VFX controller should expose a `hit_direction` parameter (Vector3) so the squash-stretch orients toward the damage source. These physical reactions combine with the flash and sparks for complete hit feedback.
**Acceptance Criteria:**
- Squash-stretch cycle on hit (110%/90% to 95%/105% to 100%) over 8 frames
- Squash direction orients toward damage source
- Brief knockback (0.05-0.1m) away from damage source
- Knockback transitions smoothly back to AI movement
- Combined with flash + sparks creates satisfying hit feel
- Works on all enemy types regardless of size

### Task 15.8: Aggro Indicator -- Detection to Combat Transition
**Status:** TODO
**Description:** Create the visual indicator that communicates when an enemy detects the player and transitions from passive to aggressive. Design a "!" alert icon system: when aggro triggers, a stylized exclamation mark icon appears above the enemy's head, scales up from 0% to 120% over 6 frames (overshoot), then settles to 100% over 4 frames, holds for 0.5 seconds, then fades out. The icon should be a 2D sprite rendered in 3D space (Billboard mode) so it always faces the camera. Color: bright red (#FF3333) with a slight glow. Simultaneously, emit a brief ring of particles expanding outward from the enemy (red pulse wave, 0.3 seconds) to catch the player's peripheral attention. The aggro indicator should also play when an enemy calls for reinforcements (different color -- yellow #FFAA00).
**Acceptance Criteria:**
- "!" icon appears above enemy on aggro trigger
- Scale animation with overshoot (0 -> 120% -> 100%)
- Billboard rendering (always faces camera)
- Red color for standard aggro, yellow for reinforcement call
- Expanding particle ring for peripheral attention
- Fade-out after 0.5 second hold
- Works at any enemy height (auto-positions above mesh bounds)

### Task 15.9: Aggro Indicator -- Leash Return and De-aggro
**Status:** TODO
**Description:** Create visual feedback for when an enemy disengages. When an enemy hits its leash distance and returns to patrol, show a "?" icon (same billboard system as the "!" but with a question mark) in yellow (#FFAA00) to communicate confusion/loss of target. The icon appears, holds for 0.3 seconds, then fades. Additionally, create a subtle "mode shift" VFX: when transitioning from aggro back to passive, the enemy's emission/glow (if any) should dim briefly (via a tween on emission energy: current -> 30% -> current over 1 second). Add a small particle puff (grey data fragments) as the enemy "forgets" the player. These de-aggro visuals help the player understand enemy leash behavior without reading AI code.
**Acceptance Criteria:**
- "?" icon on de-aggro with billboard rendering
- Yellow color distinguishes from red aggro icon
- Emission dim/restore tween over 1 second
- Grey particle puff on de-aggro trigger
- Clearly communicates "enemy lost interest" to the player
- Helps player learn leash distance intuitively

### Task 15.10: Status Effect Overlay -- Corrupted
**Status:** TODO
**Description:** Create the visual overlay for the "Corrupted" status effect (damage over time). When applied, overlay a shader effect on the enemy mesh: dark purple (#440066) scanline bands that scroll vertically across the mesh surface (moving upward at ~0.5m/s). The bands should be semi-transparent (30% opacity) so the enemy's base texture remains visible. Add a continuous particle emitter: small purple pixel particles dripping downward from the enemy (8-10 particles/second, lifetime 0.5s, gravity-affected). The overlay shader should pulse in intensity (between 20% and 40% opacity) on a 2-second cycle to suggest ongoing damage. When the status expires, the overlay fades out over 0.3 seconds and particles stop emitting.
**Acceptance Criteria:**
- Purple scanline overlay scrolls vertically across enemy mesh
- Semi-transparent (20-40% opacity pulsing) over base texture
- Purple pixel particles drip downward continuously during effect
- Overlay fades in on application (0.2s) and fades out on expiry (0.3s)
- Visually distinct from other status effects
- Does not obscure enemy silhouette or base color identification

### Task 15.11: Status Effect Overlay -- Fragmented
**Status:** TODO
**Description:** Create the overlay for "Fragmented" status (defense debuff). Visual concept: the enemy appears to be breaking apart. Shader effect: add small displacement offsets to UV coordinates in a block pattern, making parts of the texture appear shifted (like a glitched JPEG). Use a blocky noise texture to drive UV offset: blocks shift by 0.01-0.03 in UV space, creating visible texture misalignment. The displacement should animate (blocks shuffle every 0.5 seconds to new positions). Add particle effect: small angular mesh fragments (tiny cubes or triangular shards) orbit slowly around the enemy (8-10 fragments, 1m orbit radius, 4-second orbit period). Fragments are grey (#888888) with slight emission. Overall impression: "this enemy's data integrity is compromised."
**Acceptance Criteria:**
- UV displacement creates visible texture fragmentation/glitch
- Block-pattern displacement, not smooth distortion
- Displacement shuffles every 0.5 seconds
- Orbiting fragment particles surround the enemy
- Grey angular fragments with emission
- Clearly reads as "structurally weakened" at camera distance
- Fades in/out cleanly on application/expiry

### Task 15.12: Status Effect Overlay -- Throttled
**Status:** TODO
**Description:** Create the overlay for "Throttled" status (movement/attack speed debuff). Visual concept: the enemy is being speed-limited. Shader effect: apply a blue-shift color tint (#0044AA at 15% blend) across the entire mesh, plus horizontal "bandwidth bars" -- thin animated horizontal lines scrolling across the mesh surface at varying speeds (some fast, some slow, suggesting throttled data flow). Add a chain-link particle ring: small linked segments forming a visible "restraint" ring around the enemy at waist height, slowly rotating. The ring uses a simple torus mesh with a chain-link texture. Optionally add a speed-trail reduction: if the enemy has any movement trails, they should be suppressed while Throttled.
**Acceptance Criteria:**
- Blue-shift color tint at 15% blend
- Horizontal bandwidth bars scrolling at varying speeds
- Chain-link restraint ring particle at waist height
- Visual clearly communicates "slowed" at camera distance
- Fades in/out cleanly
- Does not conflict with Corrupted or Fragmented overlays visually

### Task 15.13: Status Effect Overlay -- Overclocked and Segfault
**Status:** TODO
**Description:** Create overlays for the remaining two status effects. **Overclocked** (buff -- increased stats): bright warm glow overlay -- add an additive color layer (#FF8800 at 10% blend) across the mesh, plus fast-moving upward particle streams (small bright orange sparks rising rapidly, suggesting excess energy). Add a subtle size increase (102% scale) while active. **Segfault** (stun/interrupt): the most dramatic overlay -- the enemy's mesh freezes and displays a "crash screen" effect. Apply a red-shift tint (#FF0000 at 20%), freeze all animation playback, and display a rotating "ERROR" text sprite above the head (same billboard system as aggro icons). Add brief static-noise particle burst on application. The stun should be immediately obvious.
**Acceptance Criteria:**
- Overclocked: warm orange glow + rising spark particles + slight size increase
- Segfault: red tint + animation freeze + "ERROR" billboard + static burst
- Both overlays distinct from each other and from Corrupted/Fragmented/Throttled
- Segfault is the most visually dramatic (stun must be obvious)
- Overclocked communicates "buffed/dangerous" clearly
- All 5 status effects can theoretically coexist visually without becoming unreadable

### Task 15.14: Damage Numbers -- Font and Style System
**Status:** TODO
**Description:** Create the floating damage number system. Damage numbers should appear at the hit point, float upward, and fade out. Design the visual style: numbers use the game's sci-fi font (or a dedicated damage font if available), rendered as 3D billboard Label3D nodes. Normal damage: white text, moderate size. Critical damage: larger text, yellow (#FFDD00) with a brief scale-up animation (150% to 100%). Healing: green (#44DD44) with a "+" prefix. Each number spawns at the hit point, rises 0.5m over 0.8 seconds, and fades from full opacity to 0 over that duration. Add a slight random horizontal offset (-0.1 to +0.1m) to prevent perfect stacking when multiple hits land simultaneously.
**Acceptance Criteria:**
- Damage numbers appear at hit point as billboard Label3D
- Float upward 0.5m over 0.8 seconds with fade-out
- Normal damage: white, standard size
- Critical damage: yellow, 150% scale animation
- Healing: green with "+" prefix
- Random horizontal offset prevents stacking
- Numbers are readable at isometric camera distance

### Task 15.15: Damage Numbers -- Stacking and Performance
**Status:** TODO
**Description:** Handle the edge cases for damage number performance and readability. When multiple damage numbers spawn in quick succession (e.g., rapid-fire attacks, AoE hitting multiple enemies), implement: (1) vertical stacking -- each subsequent number spawns 0.15m higher than the previous one if spawned within 0.3s, preventing overlap. (2) Number pooling -- pre-instantiate 20 Label3D nodes in an object pool, recycle them instead of instantiating/freeing on every hit. (3) Frame budget -- if more than 10 damage numbers would be visible simultaneously, start recycling the oldest ones early. (4) Combine rapid identical hits -- if the same damage value hits the same target within 0.1s, combine into a single larger number with a "xN" suffix instead of spawning N separate numbers.
**Acceptance Criteria:**
- Vertical stacking prevents number overlap during rapid hits
- Object pool of 20 Label3D nodes (no runtime instantiation)
- Frame budget caps visible numbers at 10 (recycles oldest)
- Rapid identical hits combine with "xN" suffix
- No performance spikes during AoE scenarios with many enemies
- System handles worst case: 10 enemies hit simultaneously

### Task 15.16: Enemy Health Bars -- Design and Positioning
**Status:** TODO
**Description:** Create the enemy health bar system. Each enemy displays a health bar above its head when damaged. Design: a thin horizontal bar (0.4m wide x 0.04m tall for standard enemies, 0.8m x 0.06m for bosses) with a dark background fill (#1A1A1A), colored health fill (red-to-green gradient based on HP percentage: green > 60%, yellow 30-60%, red < 30%), and a thin white border (1px). The bar is a billboard (always faces camera) positioned 0.2m above the enemy's mesh bounding box top. Add a "damage lag" effect: when HP drops, the health fill snaps to the new value immediately but a lighter "lag bar" (same color at 50% opacity) slides down to match over 0.5 seconds. Health bars appear on first damage and fade out 3 seconds after last damage if the enemy returns to full HP.
**Acceptance Criteria:**
- Health bar appears above enemy on first damage
- Color transitions: green > yellow > red based on HP %
- Damage lag effect (light bar slides to match over 0.5s)
- Billboard rendering always facing camera
- Auto-positions above mesh bounds regardless of enemy size
- Fades out 3 seconds after combat ends (if enemy returns to full HP)
- Boss health bars are larger than standard enemy bars

### Task 15.17: Enemy Health Bars -- Boss Variant
**Status:** TODO
**Description:** Create a special boss health bar that displays at the bottom of the screen (not above the boss). This is a wide horizontal bar spanning 60% of the screen width, positioned at the bottom. Design: dark metallic frame border (matching the HUD style from Epic 40), boss name text above the bar (e.g., "CORRUPTED COMPILER"), phase markers (small diamond icons at 66% and 33% positions indicating phase transition thresholds), and a chunky health fill with the same color gradient system. Add a subtle pulsing glow around the bar frame when the boss is below 30% HP (enrage warning). The boss health bar appears when the boss fight begins (boss room entry) and persists until the boss dies. It should not conflict with the player's HUD bars.
**Acceptance Criteria:**
- Wide bar at screen bottom (60% screen width)
- Boss name text above the bar
- Phase markers at 66% and 33% thresholds
- Metallic frame matching HUD style
- Pulsing glow below 30% HP (enrage warning)
- Appears on boss fight start, persists until boss death
- Does not overlap or conflict with player HUD elements

### Task 15.18: VFX Controller Integration Script
**Status:** TODO
**Description:** Implement the `enemy_vfx_controller.gd` script designed in Task 15.1. The script should: extend Node3D, preload all VFX scenes on `_ready()`, connect to EventBus signals for the parent enemy, expose configuration variables (`@export var enemy_color: Color`, `@export var enemy_size: float`), and implement handler functions: `_on_spawned()`, `_on_hit(damage, hit_point, is_critical)`, `_on_died()`, `_on_aggro_changed(is_aggro)`, `_on_status_changed(status_name, is_applied)`. Each handler instantiates the appropriate VFX scene, configures it (position, color, scale), and starts it. Include object pool management for frequently spawned effects (hit flash, damage numbers). Add a `cleanup()` method that frees all active VFX when the enemy is queue_free'd.
**Acceptance Criteria:**
- Script follows static-typed GDScript conventions
- All EventBus signal connections established
- Configuration exports for enemy-specific color and size
- Handler functions for all VFX types implemented
- Object pooling for hit flash and damage numbers
- Cleanup method prevents orphaned VFX nodes
- push_error() for invalid VFX requests, push_warning() for pool exhaustion

### Task 15.19: Performance Profiling and Optimization
**Status:** TODO
**Description:** Profile the complete VFX system under stress conditions. Set up a test scenario: spawn 10 enemies in a single room, trigger aggro on all simultaneously, have them take rapid damage, apply status effects, and kill them all in quick succession. Profile using Godot's built-in profiler: check GPU particle draw calls, shader compilation stalls (first-time compilation), CPU overhead from VFX controller scripts, and memory usage from pooled objects. Optimization targets: < 2ms total VFX CPU overhead per frame, < 500 draw calls from VFX particles, zero GC spikes from VFX instantiation (pools must work). Fix any issues found: reduce particle counts, simplify shaders, increase pool sizes, or add LOD (disable certain VFX when enemy count is high).
**Acceptance Criteria:**
- Stress test with 10 enemies running all VFX types simultaneously
- CPU overhead < 2ms per frame for VFX system
- No GC spikes from VFX instantiation
- No shader compilation stalls (pre-warm shaders on scene load)
- Draw call budget reasonable (< 500 from VFX)
- Performance targets met at 1080p on mid-range hardware

### Task 15.20: Visual Consistency Pass and Documentation
**Status:** TODO
**Description:** Final pass to ensure all shared VFX work correctly and consistently across all enemy types. Test each effect on: GlitchBug (small, fast), MemoryLeak (medium, ground-level), RogueProcess (medium, floating), and a placeholder large enemy (boss scale). Verify: spawn effect scales to mesh bounds, death dissolve works top-to-bottom regardless of enemy height, hit flash is visible on all enemy color schemes (white flash must read against red, green, and blue base colors), aggro icon positions correctly above varying heights, status overlays layer correctly, damage numbers are readable against all backgrounds, health bars scale and position correctly. Document any per-enemy adjustments needed. Create a visual reference sheet (screenshots of each effect on each enemy type) for the project documentation.
**Acceptance Criteria:**
- All VFX tested on all 4 enemy types (small/medium/floating/large)
- Spawn and death effects scale correctly to enemy mesh bounds
- Hit flash visible on all enemy color schemes
- Aggro icons position correctly regardless of enemy height
- Status overlays work on all enemy materials
- Damage numbers readable against all backgrounds
- Visual reference screenshots captured for documentation

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Shader and material conventions
- **Epic 2** (Visual Style Guide): Color palette and VFX style direction
- **Epic 5** (Combat System Fixes): Damage pipeline and EventBus signals
- **Epic 11-14** (Enemy Models): VFX must work with all enemy mesh types

## Notes

- The dissolve shader is reusable for spawn and death (forward vs. reverse direction)
- Object pooling is critical for damage numbers -- do not instantiate/free per hit
- Status effect overlays must be designed to coexist -- a Corrupted + Throttled enemy should look like both, not a visual mess
- Consider using a shader uber-system where status overlays are toggleable uniforms on a single shared shader
- The "!" aggro indicator is one of the most important game-feel elements -- it must feel snappy and informative
- Boss health bar design should be coordinated with Epic 40 (HUD Redesign) for consistent UI frame style
