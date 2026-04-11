---
epic: 47
title: "Shader Effects"
phase: 8 — VFX & Particles
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 47: Shader Effects

## Overview

Create reusable shader effects: dissolve shader for death/spawn, hologram shader for NPCs in dungeons, damage flash (white flash on hit), outline shader for entity highlighting, glitch shader for corruption, heat distortion, chromatic aberration for boss damage, and scan line overlay for digital world feel. These shaders are the visual building blocks used across multiple game systems.

## Success Criteria

- Each shader is reusable as a ShaderMaterial .tres resource
- Shaders have exposed uniforms for easy customization
- Dissolve effect works on any mesh for death/spawn
- Hologram shader creates convincing semi-transparent projection
- Damage flash provides instant hit feedback on any entity
- Outline shader clearly highlights selected/interactive entities
- All shaders maintain 60fps when applied to multiple entities simultaneously
- Shader library documented with usage guide

---

## Tasks

### Task 47.1: Dissolve Shader — Death/Spawn Effect
- **Status:** TODO
- **Description:** Create a dissolve shader (`res://shaders/dissolve.gdshader`) that transitions a mesh from solid to dissolved using a noise pattern. Uniforms: `dissolve_amount` (0.0 = solid, 1.0 = fully dissolved), `dissolve_color` (Color, default bright teal #40C0C0 — the dissolve edge glows this color), `edge_width` (float, default 0.05 — width of the glowing edge), `noise_scale` (float, default 5.0 — controls dissolve pattern size). The shader uses a noise texture to determine dissolve order: areas above the dissolve threshold become transparent, areas near the threshold glow with dissolve_color. For death: animate dissolve_amount from 0 to 1 over 0.5-0.8s. For spawn: animate from 1 to 0. Create a companion DissolveEffect.gd that applies to any MeshInstance3D.
- **Acceptance Criteria:**
  - [ ] Noise-based dissolve pattern
  - [ ] Glowing edge at dissolve boundary
  - [ ] Configurable color, edge width, noise scale
  - [ ] Works on any mesh (characters, props)
  - [ ] DissolveEffect.gd applies with dissolve/appear methods
  - [ ] Smooth animation from solid to dissolved

### Task 47.2: Dissolve Shader — Direction Variants
- **Status:** TODO
- **Description:** Extend the dissolve shader with directional variants. Add a `dissolve_direction` uniform (Vector3) that biases the dissolve to start from one direction. For bottom-up dissolve (spawn): set direction to (0, -1, 0) so the entity appears from feet to head. For hit-point dissolve (death): set direction toward the hit position so dissolution radiates from the final hit. For radial dissolve (portal entry): set direction based on distance from center. Implement by modifying the noise threshold with a directional gradient: `adjusted_threshold = noise + dot(world_position_normalized, dissolve_direction) * direction_bias`. The direction_bias uniform (0.0-1.0) controls how much direction influences the pattern.
- **Acceptance Criteria:**
  - [ ] Directional dissolve (bottom-up, from hit point, radial)
  - [ ] dissolve_direction uniform controls direction
  - [ ] direction_bias controls influence strength
  - [ ] Combined with noise for organic edge
  - [ ] Works for death, spawn, and portal transitions
  - [ ] Direction variants feel natural per context

### Task 47.3: Hologram Shader
- **Status:** TODO
- **Description:** Create a hologram shader (`res://shaders/hologram.gdshader`) for displaying NPCs and objects as holographic projections in the dungeon. The shader should: render the base texture with a blue-teal tint (#40C0C0 multiply), apply horizontal scan lines (alternating rows at 2px spacing, 10% darker), add a fresnel-based edge glow (brighter at glancing angles), include vertical jitter (random Y offset, ±1px, every 3-5 frames), add flicker (alpha oscillation 0.6-0.9 at 3Hz), and occasional brief signal dropout (alpha 0.0 for 1-2 frames every 3-7 seconds). The hologram should be semi-transparent (base alpha 0.7). Create HologramMaterial.tres with default settings.
- **Acceptance Criteria:**
  - [ ] Blue-teal color tint
  - [ ] Horizontal scan lines
  - [ ] Fresnel edge glow
  - [ ] Vertical jitter and alpha flicker
  - [ ] Occasional signal dropout
  - [ ] Semi-transparent (alpha 0.7 base)

### Task 47.4: Damage Flash Shader — White Hit Flash
- **Status:** TODO
- **Description:** Create a damage flash shader (`res://shaders/damage_flash.gdshader`) that briefly turns a mesh white when hit. This is the most fundamental hit feedback in action games. The shader mixes between the normal texture and pure white based on a `flash_amount` uniform (0.0 = normal, 1.0 = pure white). On hit: set flash_amount to 1.0, then tween back to 0.0 over 0.1 seconds. The flash should affect the entire mesh uniformly. Create a variant that flashes in a configurable color (red for fire damage, blue for ice, purple for corruption). Implement DamageFlash.gd that provides `flash(color: Color, duration: float)` — call it on any entity with a MeshInstance3D.
- **Acceptance Criteria:**
  - [ ] White flash on hit (full mesh)
  - [ ] flash_amount uniform for smooth transition
  - [ ] 0.1s duration for brief, punchy feedback
  - [ ] Configurable flash color for damage types
  - [ ] DamageFlash.gd with flash() API
  - [ ] Works on any entity mesh

### Task 47.5: Outline Shader — Entity Highlight
- **Status:** TODO
- **Description:** Create an outline shader (`res://shaders/outline.gdshader`) that draws a colored outline around a mesh for highlighting selected, interactive, or important entities. Implement using the inverted hull method: in a second pass, render the mesh with front-face culling and slight scale-up (vertex extrusion along normals by `outline_width` uniform, default 0.02m), in a solid `outline_color` (default teal #40C0C0). The outline should: be visible from any angle, have configurable width and color, support pulsing (outline_width oscillates between min and max at 1Hz for "interactive" indication), and work on both simple and complex meshes. Create OutlineEffect.gd with `set_outline(color, width, pulse)`.
- **Acceptance Criteria:**
  - [ ] Inverted hull outline around mesh
  - [ ] Configurable color and width
  - [ ] Pulse mode for interactive indication
  - [ ] Visible from any camera angle
  - [ ] Works on simple and complex meshes
  - [ ] OutlineEffect.gd with clean API

### Task 47.6: Glitch Shader — Corruption Effect
- **Status:** TODO
- **Description:** Create a glitch shader (`res://shaders/glitch.gdshader`) that makes a mesh appear to be corrupting/glitching. Effects: vertex displacement (random offset on Y axis, amplitude controlled by `glitch_intensity`), UV distortion (texture coordinates shift randomly for 1-2 frames periodically), color channel separation (RGB channels offset independently), pixel block displacement (rectangular sections of the mesh render at wrong positions), and alpha flicker (sections become transparent randomly). The `glitch_intensity` uniform (0.0-1.0) scales all effects. At 0.1 = subtle instability, at 0.5 = clearly glitching, at 1.0 = barely recognizable. Create GlitchEffect.gd with set_intensity().
- **Acceptance Criteria:**
  - [ ] Vertex displacement creates geometric instability
  - [ ] UV distortion shifts texture randomly
  - [ ] Color channel separation (RGB split)
  - [ ] Pixel block displacement
  - [ ] glitch_intensity scales all effects
  - [ ] GlitchEffect.gd with set_intensity() API

### Task 47.7: Heat Distortion Shader
- **Status:** TODO
- **Description:** Create a screen-space heat distortion shader (`res://shaders/heat_distortion.gdshader`) that warps the view behind a mesh to simulate rising heat. Apply to a transparent mesh placed above heat sources (forge, fire vents, explosions). The shader samples SCREEN_TEXTURE with UV offset based on: scrolling noise (upward direction, 1-2 m/s), sine wave horizontal wobble (low frequency), and a mask that fades the effect from bottom (strong) to top (none). Uniforms: `distortion_strength` (default 0.01), `scroll_speed` (default 1.0), `wobble_frequency` (default 2.0). The effect should be barely visible when looking for it — subliminal rather than obvious.
- **Acceptance Criteria:**
  - [ ] Screen-space view warping
  - [ ] Upward-scrolling noise displacement
  - [ ] Horizontal sine wobble
  - [ ] Fades from strong at bottom to none at top
  - [ ] Configurable strength and speed
  - [ ] Subliminal effect (not obvious)

### Task 47.8: Chromatic Aberration Shader
- **Status:** TODO
- **Description:** Create a screen-space chromatic aberration shader (`res://shaders/chromatic_aberration.gdshader`) that splits RGB channels for dramatic emphasis moments (boss damage phases, entering corrupted zones, critical game events). The shader offsets the red channel sampling position by `aberration_amount` pixels to the left and the blue channel by the same amount to the right, while green stays centered. The offset increases from screen center to edges (radial aberration). Uniforms: `aberration_amount` (0.0-0.01, measured in UV space), `radial_falloff` (0.0 = uniform, 1.0 = only at edges). Integrate with the post-process stack so it can be enabled/disabled smoothly.
- **Acceptance Criteria:**
  - [ ] RGB channel offset (red left, blue right)
  - [ ] Radial falloff (stronger at edges)
  - [ ] Configurable amount and falloff
  - [ ] Integrates with post-process stack
  - [ ] Smooth enable/disable (tween aberration_amount)
  - [ ] Used for boss phases and corruption

### Task 47.9: Scan Line Overlay Shader
- **Status:** TODO
- **Description:** Create a screen-space scan line overlay shader (`res://shaders/scan_lines.gdshader`) that adds horizontal lines across the entire screen for a CRT/digital world feel. The shader draws semi-transparent dark lines at regular pixel intervals. Uniforms: `line_spacing` (default 2px — every other row is darker), `line_opacity` (default 0.05 — very subtle), `scroll_speed` (default 0.0 — static lines, but can scroll slowly for active effect), `curve` (0.0 = straight lines, 1.0 = slight CRT barrel distortion). The overlay should be extremely subtle at default settings — the player shouldn't consciously notice it but should feel the digital atmosphere. Provide a setting to disable completely.
- **Acceptance Criteria:**
  - [ ] Horizontal scan lines at configurable spacing
  - [ ] Very subtle at default (0.05 opacity)
  - [ ] Optional slow scroll for active effect
  - [ ] Optional CRT barrel distortion
  - [ ] Setting to disable completely
  - [ ] Adds digital atmosphere subconsciously

### Task 47.10: Shield/Barrier Shader
- **Status:** TODO
- **Description:** Create a shader for defensive shields and barriers (`res://shaders/shield.gdshader`) that renders a semi-transparent force field on a sphere or dome mesh. Effects: hex pattern grid visible on the surface (hex tiles with bright edges, dark interiors), fresnel rim glow (brighter at edges), ripple effect at hit points (when the shield takes damage, a ripple radiates from the impact position), and color indicating shield health (blue at full, amber at half, red at critical). Uniforms: `shield_color`, `hit_position` (Vector3, for ripple), `hit_time` (float, for ripple animation), `shield_health` (0.0-1.0 for color interpolation). Create ShieldEffect.gd managing hit ripple timing.
- **Acceptance Criteria:**
  - [ ] Hex pattern grid on surface
  - [ ] Fresnel rim glow
  - [ ] Ripple from hit position
  - [ ] Color indicates shield health
  - [ ] Configurable color and health
  - [ ] ShieldEffect.gd manages hit ripples

### Task 47.11: Freeze/Slow Shader
- **Status:** TODO
- **Description:** Create a shader that visually represents a frozen or slowed state (`res://shaders/freeze.gdshader`). Applied to meshes of entities affected by the Throttled status effect. Effects: blue-white color overlay (lerp base color toward ice blue #80C0FF by `freeze_amount`), surface frost pattern (noise-based white patches that grow from edges), and vertex displacement reducing to zero (mesh stops animating — the shader locks vertices in place when freeze_amount = 1.0). Intermediate amounts (Throttled): lighter blue tint, minimal frost, slowed animation. Full freeze: solid ice-blue, full frost, static pose.
- **Acceptance Criteria:**
  - [ ] Blue-white color overlay proportional to freeze_amount
  - [ ] Frost pattern growing from edges
  - [ ] Vertex lock at full freeze
  - [ ] Partial effect for Throttled status
  - [ ] Configurable freeze_amount (0.0-1.0)
  - [ ] Visual clearly communicates "slowed/frozen"

### Task 47.12: Energy Shield Bubble
- **Status:** TODO
- **Description:** Create a transparent energy bubble effect for area shields and protective abilities. Use a sphere mesh with the shield shader (Task 47.10) but scaled to encompass an area rather than a single entity. Additional effects for the bubble: interior tinting (everything inside has a subtle color tint matching the shield color), particles flowing along the interior surface (small dots orbiting inside), and a distortion at the shell boundary (subtle screen-space refraction). The bubble should be clearly visible as a protected zone without obscuring gameplay inside it. Create EnergyBubble.tscn as a reusable scene.
- **Acceptance Criteria:**
  - [ ] Transparent sphere with shield shader
  - [ ] Interior color tint
  - [ ] Particles orbiting inside
  - [ ] Distortion at shell boundary
  - [ ] Clearly visible without obscuring interior
  - [ ] EnergyBubble.tscn reusable component

### Task 47.13: Overclocked/Speed Boost Shader
- **Status:** TODO
- **Description:** Create a shader for the Overclocked buff state (`res://shaders/overclocked.gdshader`). Effects: yellow-gold color boost (increase saturation and brightness by 20%), speed lines radiating from the character (vertex-based particles stretching backward from the mesh, or a post-process effect), electric spark overlay (small bright spots flickering across the mesh surface, mapped using noise), and a subtle motion trail (previous frame's mesh position rendered at reduced opacity behind the current position). The effect should make the entity feel supercharged and fast.
- **Acceptance Criteria:**
  - [ ] Yellow-gold color enhancement
  - [ ] Speed lines or motion streaks
  - [ ] Electric spark overlay
  - [ ] Subtle motion trail
  - [ ] Entity feels supercharged
  - [ ] Overclocked is visually exciting

### Task 47.14: Data Reconstruction Shader
- **Status:** TODO
- **Description:** Create a shader for the digital reconstruction/materialization effect used in spawn animations, teleportation, and portal entry/exit. The mesh assembles from pixel blocks: the shader divides the mesh surface into a grid of rectangular blocks using UV coordinates. Each block appears independently based on a `reconstruct_progress` uniform (0.0 = scattered blocks, 1.0 = fully assembled). Blocks start at random positions around the target location and snap into their correct position as progress increases. Each block has a brief glow when it snaps into place. This creates the iconic "beaming in" digital assembly effect.
- **Acceptance Criteria:**
  - [ ] Mesh divided into rectangular blocks
  - [ ] Blocks assemble from scattered to correct positions
  - [ ] reconstruct_progress uniform controls assembly
  - [ ] Glow on each block as it snaps in place
  - [ ] Reverse for disassembly (portal exit, despawn)
  - [ ] Iconic digital materialization feel

### Task 47.15: Shader Material Library Organization
- **Status:** TODO
- **Description:** Organize all shaders into a clean library structure. Save all .gdshader files to `res://shaders/` with consistent naming. Create pre-configured ShaderMaterial .tres resources for common use cases in `res://assets/materials/shaders/`: dissolve_teal.tres, dissolve_red.tres, hologram_default.tres, damage_flash_white.tres, outline_teal.tres, outline_gold.tres, glitch_subtle.tres, glitch_heavy.tres, etc. Document each shader's uniforms, intended use, and performance notes in a comment block at the top of each .gdshader file.
- **Acceptance Criteria:**
  - [ ] All shaders in res://shaders/
  - [ ] Pre-configured .tres materials in res://assets/materials/shaders/
  - [ ] Common variants pre-configured
  - [ ] Documentation comments in each shader
  - [ ] Uniform descriptions with ranges
  - [ ] Organized and easy to find

### Task 47.16: Shader Combination Testing
- **Status:** TODO
- **Description:** Test combinations of shaders that may be active simultaneously on the same entity or in the same scene. Test: dissolve + damage flash (dying while being hit), hologram + glitch (corrupted NPC), outline + damage flash (highlighted enemy taking damage), multiple outlined entities visible at once, chromatic aberration + scan lines + glitch (all post-process active), heat distortion + volumetric fog. Verify no visual artifacts, z-fighting, or rendering order issues. Verify combined shader cost stays within budget. Fix any combination issues found.
- **Acceptance Criteria:**
  - [ ] All likely shader combinations tested
  - [ ] No visual artifacts from combinations
  - [ ] No z-fighting or render order issues
  - [ ] Combined cost within budget
  - [ ] Problematic combinations fixed
  - [ ] Combination matrix documented

### Task 47.17: Shader Performance Benchmarks
- **Status:** TODO
- **Description:** Benchmark each shader individually and in combination. For each shader: measure GPU cost when applied to 1 entity, 5 entities, and 10 entities simultaneously. Screen-space shaders (chromatic aberration, scan lines, heat distortion): measure at 1080p and 1440p. Target per-shader costs: dissolve <0.1ms per entity, hologram <0.1ms, damage flash <0.05ms, outline <0.1ms, glitch <0.1ms, screen-space shaders <0.3ms each. If any shader exceeds budget: optimize (simplify noise calculations, reduce texture samples, use lower-quality fallbacks).
- **Acceptance Criteria:**
  - [ ] Each shader benchmarked at 1/5/10 entities
  - [ ] Screen-space shaders at 1080p and 1440p
  - [ ] All shaders within target costs
  - [ ] Optimizations applied where needed
  - [ ] Benchmark results documented
  - [ ] 60fps with maximum shader usage

### Task 47.18: Shader Quality Settings
- **Status:** TODO
- **Description:** Integrate all shaders with the VFX quality system. At High: all shader effects at full quality. At Medium: simplify noise calculations (use fewer octaves), reduce scan line resolution, disable screen-space refraction effects, simplify hologram (remove jitter). At Low: further simplify (outline becomes a simple color tint instead of hull extrusion, dissolve uses linear fade instead of noise pattern, disable chromatic aberration and scan lines). Ensure shaders still communicate their intended information at Low quality (damage flash still flashes, outline still highlights).
- **Acceptance Criteria:**
  - [ ] High: full shader quality
  - [ ] Medium: simplified but recognizable
  - [ ] Low: minimal but functional
  - [ ] Shaders still communicate intent at Low
  - [ ] Quality setting applied to all shaders
  - [ ] Performance targets met at each level

### Task 47.19: Shader Usage Guide
- **Status:** TODO
- **Description:** Create an internal reference guide documenting the complete shader library. For each shader: file path, description, all uniforms with type/range/default, intended use cases, performance cost, quality level variations, companion .gd script API, and visual example. Include a "shader cookbook" section with common recipes: "how to make an enemy dissolve on death", "how to highlight an interactive object", "how to add hologram to a dungeon NPC", etc. The guide ensures any developer can use the shader library correctly without reading shader code.
- **Acceptance Criteria:**
  - [ ] Every shader documented with full details
  - [ ] Uniforms listed with types, ranges, defaults
  - [ ] Use cases described per shader
  - [ ] Performance costs noted
  - [ ] Cookbook with common recipes
  - [ ] Guide is practical and developer-friendly

### Task 47.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture visual demonstrations of every shader effect: dissolve (death and spawn), hologram (NPC in dungeon), damage flash (enemy hit), outline (entity highlight), glitch (corruption), heat distortion (forge), chromatic aberration (boss phase), scan lines (subtle overlay), shield (hit ripple), freeze (throttled status), overclocked (speed buff), and data reconstruction (portal entry). Create before/after pairs showing entities with and without shaders. Save to `_bmad-output/visual-overhaul/screenshots/epic-47/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Every shader effect demonstrated
  - [ ] Before/after pairs for each
  - [ ] Shader combinations shown
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 44** (Combat VFX) — VFX quality system
- **Epic 45** (Environment VFX) — Environmental shader contexts

## Notes

- Shaders are reusable building blocks — invest in making them configurable and well-documented
- The dissolve shader is used more than any other — it handles death, spawn, portal, and more
- Damage flash is the most important feedback shader — it MUST be fast (under 0.05ms)
- Test shaders on actual game entities, not isolated test meshes — the real models have varying complexity
- Screen-space shaders accumulate — each one is cheap, but 5 active simultaneously can be expensive
