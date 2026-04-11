# Enth: Iteration Shader Bible

Authoritative reference for every shader in `assets/shaders/`. Each entry covers
purpose, key uniforms, where it's used in-game, and performance budget.

All shaders target the **Forward+ renderer** in Godot 4.4 on midspec hardware
(GTX 1060 / RX 580 class). Avoid double-sampled screen textures inside loops.

---

## Material Shaders (apply to MeshInstance3D)

### water_pbr.gdshader
**Purpose:** PBR water surface with dual normal scroll, depth fade, shore foam, flow direction map.
**Key uniforms:** `deep_color`, `shallow_color`, `wave_speed`, `depth_fade_distance`, `foam_distance`.
**Used in:** Town Docks district, dungeon flooded rooms, ponds, lakes.
**Cost:** Medium — uses depth + screen texture sampling. ~4 ms/frame on full-screen plane.

### water_river_flow.gdshader
**Purpose:** Directional river water using Tom Forsyth flow mapping. Phase-blended normal scroll prevents UV stretching, plus shore foam, rapids whitewater, refraction, caustics, and vertex ripple displacement.
**Key uniforms:** `flow_speed`, `flow_strength`, `rapids_threshold`, `caustic_intensity`, `shore_foam_distance`, `ripple_amplitude`.
**Flow map encoding:** RG = local flow direction, B = local flow speed multiplier, A = rapids/turbulence amount.
**Used in:** Wilderness river (Epic 23), any directional waterway.
**Cost:** Medium-high — flow mapping doubles normal samples vs `water_pbr`. ~3 ms on GTX 1060 at 1080p for a 200m river plane. Use a single mesh per river; do not stack planes.

### glitch_displacement.gdshader
**Purpose:** Vertex displacement bands + chromatic aberration + horizontal color shift bands.
**Key uniforms:** `glitch_intensity`, `glitch_speed`, `band_count`, `chromatic_offset`.
**Used in:** Corrupted enemies, glitch storm weather, Iteration Echo enemy, ghost variant.
**Cost:** Low. Single texture sample with offset reads.

### hologram.gdshader
**Purpose:** Scanlines + fresnel edge glow + flicker for projected entities.
**Key uniforms:** `hologram_color`, `scanline_count`, `fresnel_power`, `flicker_speed`.
**Used in:** AI Sage projection, lore terminals, holographic NPCs, dungeon UI projections.
**Cost:** Low. No texture samples.

### dissolve.gdshader
**Purpose:** Death/respawn dissolve with edge emissive and 3 noise mask variants.
**Key uniforms:** `dissolve` (drive 0->1), `edge_width`, `edge_color`, `noise_variant`.
**Used in:** All enemy deaths, respawn cinematics, Globbler ghost form.
**Cost:** Low. Single noise texture sample.

### force_field_bubble.gdshader
**Purpose:** Hexagonal energy bubble + impact ripples + pulsing.
**Key uniforms:** `field_color`, `hex_scale`, `impact_intensity`, `is_shield`.
**Used in:** Player shield bubble, boss force fields, enemy spawn shields, level-up burst.
**Cost:** Low. Procedural pattern, no textures.

### portal_swirl.gdshader
**Purpose:** Spiraling portal with radial falloff for compaction portals.
**Key uniforms:** `portal_color_inner`, `swirl_strength`, `band_count`, `falloff_power`.
**Used in:** Compaction portals (1-6), iteration reset transitions, dungeon entrances.
**Cost:** Low. Pure procedural.

### laser_beam.gdshader
**Purpose:** Hot core + outer glow + scrolling energy flow for beams.
**Key uniforms:** `core_color`, `outer_color`, `core_width`, `scroll_speed`.
**Used in:** Boss laser attacks, RogueProcess ranged, charge attack beams.
**Cost:** Low. Procedural only.

### chain_lightning.gdshader
**Purpose:** Jagged lightning bolt with bright core + halo + flicker.
**Key uniforms:** `core_color`, `outer_color`, `jaggedness`, `flicker_speed`.
**Used in:** Lightning ability VFX, electric enemy attacks, storm weather flashes.
**Cost:** Low. Hash-based jitter only.

### fire_particle.gdshader
**Purpose:** Single billboard fire with 3-color gradient by noise.
**Key uniforms:** `hot_color`, `mid_color`, `cool_color`, `intensity`.
**Used in:** Forge district, fire ability VFX, burn status, boss arena hazards.
**Cost:** Very low. One texture sample.

### dissolve_overlay_status.gdshader
**Purpose:** Parameterized status overlay (poison/burn/wet/ice). Switch via `effect_type`.
**Key uniforms:** `effect_type` (0-4), `effect_intensity`, `noise_texture`.
**Used in:** All status effects on enemies and player. One shader, four behaviors.
**Cost:** Low. One texture sample plus arithmetic.

### vertex_wind.gdshader
**Purpose:** Foliage sway driven by `wind_direction`. Y-weighted so trunks barely move.
**Key uniforms:** `wind_strength`, `wind_speed`, `weight_curve`, `alpha_cutoff`.
**Used in:** All vegetation in town/wilderness, leaf cards, grass scatter.
**Cost:** Very low. Vertex-only computation.

### vertex_wobble_slime.gdshader
**Purpose:** Jelly displacement + scrolling inner data + fresnel translucency for slimes.
**Key uniforms:** `wobble_amplitude`, `inner_color`, `scroll_speed`, `subsurface_scale`.
**Used in:** MemoryLeak family, healing prompts, water-element enemies.
**Cost:** Low.

### snow_accumulation.gdshader
**Purpose:** Snow on upward-facing world normals. Sparkle for top surfaces.
**Key uniforms:** `snow_amount`, `snow_threshold`, `snow_blend_softness`.
**Used in:** Cold biome variants, winter seasonal town overlay.
**Cost:** Low.

### rain_wetness.gdshader
**Purpose:** Drops roughness on upward-facing surfaces during rain.
**Key uniforms:** `wetness` (0-1), `wet_roughness`, `dark_tint_amount`.
**Used in:** Town props during rain weather, dungeon flooded rooms.
**Cost:** Low.

### cloth_simulation.gdshader
**Purpose:** Vertex sway for cloth (no real physics) — anchored top, free bottom.
**Key uniforms:** `wind_dir`, `wind_strength`, `anchor_y`, `falloff`.
**Used in:** Architect set cape, town banners, hanging laundry, sage robes.
**Cost:** Very low. Vertex-only.

### hair_card.gdshader
**Purpose:** Layered alpha-cutout hair strips with anisotropic highlight.
**Key uniforms:** `hair_color`, `highlight_color`, `anisotropy`, `ao_root`.
**Used in:** NPCs with hair (Forge, Bit, Render).
**Cost:** Low.

### subsurface_skin.gdshader
**Purpose:** Wrapped diffuse + warm edge translucency for skin/skin-like materials.
**Key uniforms:** `sss_color`, `sss_strength`, `sss_wrap`, `backlight_strength`.
**Used in:** Globbler skin variants, organic enemies, sage skin.
**Cost:** Low.

### emissive_pulse.gdshader
**Purpose:** Sin-wave pulse on emission strength. Driven by texture mask.
**Key uniforms:** `pulse_speed`, `pulse_min`, `pulse_max`, `emission_mask`.
**Used in:** Globbler circuit traces, charging weapons, ability cooldown indicators.
**Cost:** Very low.

### refraction_glass.gdshader
**Purpose:** Real screen-texture refraction for glass/crystal/chest core windows.
**Key uniforms:** `tint`, `ior_strength`, `roughness`, `fresnel_power`.
**Used in:** Globbler chest core window, vault crystals, town greenhouse glass.
**Cost:** Medium. Screen texture sample.

### toon_ramp.gdshader
**Purpose:** Cell-shaded quantized lighting via 1D ramp texture.
**Key uniforms:** `ramp_texture`, `light_direction`, `rim_strength`.
**Used in:** Stylized cosmetic outfit overrides, alternate art mode.
**Cost:** Low.

### dust_smoke_particles.gdshader
**Purpose:** Soft alpha billboards for dust + smoke. Tune softness/opacity for either.
**Key uniforms:** `base_color`, `softness`, `opacity`, `emission_strength`.
**Used in:** Footstep dust, explosion smoke, ambient dungeon haze.
**Cost:** Very low.

### energy_aura.gdshader
**Purpose:** Soft glowing aura sphere/ellipsoid surrounding entities.
**Key uniforms:** `aura_inner`, `aura_outer`, `falloff`, `pulse_speed`.
**Used in:** Charge windup, OVERCLOCKED state, transformation cinematics.
**Cost:** Low.

### mind_control_swirl.gdshader
**Purpose:** Spiraling charm/dominate visual.
**Key uniforms:** `swirl_color`, `swirl_density`, `swirl_speed`.
**Used in:** Charmed enemies (future Charm ability), narrative dominate moments.
**Cost:** Low.

### water_caustics.gdshader
**Purpose:** Animated caustic web pattern for submerged ground.
**Key uniforms:** `caustic_color`, `scale`, `speed`, `intensity`, `contrast`.
**Used in:** Underwater dungeon rooms, Docks river bed.
**Cost:** Low.

### rim_light.gdshader
**Purpose:** Per-outfit fresnel rim emission for gameplay-distance readability.
**Key uniforms:** `rim_color`, `rim_strength`, `rim_falloff`.
**Used in:** All outfit pieces (mixed in via material chain).
**Cost:** Very low.

### equipment_outline.gdshader
**Purpose:** Inverted-hull outline for equipped pieces with fresnel falloff.
**Key uniforms:** `outline_color`, `outline_width`, `outline_pulse_speed`.
**Used in:** Hover-highlighted gear in inventory, set bonus indicator.
**Cost:** Very low.

---

## Post-Process Shaders (apply to CanvasItem fullscreen)

### post_outline.gdshader
**Purpose:** Depth + normal edge detection for cel-shaded outlines.
**Key uniforms:** `outline_color`, `depth_threshold`, `normal_threshold`, `outline_thickness`.
**Used in:** Optional toon mode toggle.
**Cost:** Medium. 5+ depth/normal samples per pixel.

### damage_vignette.gdshader
**Purpose:** Pulsing red rim on damage.
**Key uniforms:** `intensity`, `radius`, `softness`, `pulse_speed`.
**Used in:** HUD damage feedback overlay.
**Cost:** Very low.

### slow_mo_distortion.gdshader
**Purpose:** Blue tint + chromatic aberration + vignette for slow-mo state.
**Key uniforms:** `intensity`, `chromatic_amount`, `vignette_strength`.
**Used in:** Boss kill cam, hitstop emphasis on big crits.
**Cost:** Low.

### crit_chromatic_flash.gdshader
**Purpose:** Brief one-shot zoom + chromatic flash on crits.
**Key uniforms:** `intensity` (animate 1->0), `zoom_amount`.
**Used in:** Critical hit feedback.
**Cost:** Low.

### damage_number_outline.gdshader
**Purpose:** 1px outline + drop shadow for damage number labels.
**Key uniforms:** `outline_color`, `shadow_offset`, `outline_thickness`.
**Used in:** All floating combat numbers.
**Cost:** Very low.

---

## Performance Budget

| Tier | Per-frame budget | Examples |
|---|---|---|
| Material (always-on) | <0.5 ms total | water, glass, skin, slime |
| Material (per-effect) | <0.2 ms each | dissolve, glitch, status overlay |
| Post-process (always-on) | <1.0 ms | damage vignette |
| Post-process (transient) | <2.0 ms briefly | slow-mo, crit flash |

## Naming Conventions

- Material shaders: `<purpose>.gdshader`
- Post-process: `post_<purpose>.gdshader` or `<effect>_distortion.gdshader`
- All uniforms with `hint_range` for editor scrubbing
- All colors with `: source_color` for sRGB correctness
- All texture uniforms with explicit `: hint_*` annotations

## Hot-Reload Support

All shaders are loaded via `load("res://assets/shaders/...")` so editing the
.gdshader file in the editor triggers automatic recompilation in running scenes.
The `ShaderHotReload` autoload (Task 49) watches the directory and re-applies
materials when files change on disk.
