---
name: PBR Lighting & Atmosphere Bible
description: 5 environment presets, PBR baseline, dynamic light components, performance budgets
date: 2026-04-09
status: design + components complete; lightmap baking pending Blender + scene work
---

# PBR Lighting Bible

## Philosophy

Lighting in Enth is the **silent storyteller**. The town reads warm and
inviting because the sun is golden and the windows glow soft amber. The
dungeon reads tense because the lights are cold blue with hard shadows.
The boss arena reads dramatic because there are 8 spotlights aimed at one
spot. None of these things are explained — the lighting just makes you
feel it.

Inspired by:
- Sea of Stars (warm/cool place identity)
- Hades (dramatic boss lighting)
- Hollow Knight (moody atmospheric layers)

## PBR baseline rules

Every material in the game must obey:
- **Albedo:** values in 0.04-0.85 range (no pure black, no pure white)
- **Metallic:** binary — 0 (dielectric) or 1 (metal)
- **Roughness:** varied per material — never flat 0 or flat 1
- **Emission:** only on glowing things (not "fake light")
- **Normal:** baked from high-poly when available

Audit done at material registration time. The MaterialAuditor utility
checks every material in the project against these rules and warns about
violations.

## 5 Environment Presets

Each preset is a complete WorldEnvironment configuration plus light
intensities. The EnvironmentManager autoload swaps them on zone enter.

### town_day
- **Sun:** warm gold (#FFE9B0), 3.5 energy
- **Sky:** procedural blue gradient
- **Ambient:** soft warm
- **Fog:** off
- **Bloom:** 0.4 threshold, 0.4 intensity
- **Tonemap:** Filmic
- **SSAO:** subtle (0.4 strength)
- **SDFGI:** on (cascade 0)
- **Color grade:** warm LUT (sage green tint)

### town_night
- **Sun:** off
- **Moon:** cool blue (#7090C0), 1.2 energy
- **Sky:** dark blue + stars
- **Ambient:** very low
- **Fog:** light blue volumetric (0.02 density)
- **Bloom:** 0.6 threshold, 0.6 intensity (windows pop)
- **Tonemap:** Filmic
- **SSAO:** stronger (0.6 strength)
- **SDFGI:** on
- **Color grade:** night LUT (blue-violet tint)

### dungeon_dim
- **Sun:** off
- **Ambient lights:** point lights baked into rooms
- **Sky:** black
- **Fog:** dense gray volumetric (0.08 density)
- **Bloom:** 0.5 threshold, 0.5 intensity
- **Tonemap:** Filmic
- **SSAO:** strong (0.8 strength)
- **SDFGI:** off (use baked GI)
- **Color grade:** dungeon LUT (cold cyan tint)

### boss_arena
- **Sun/key light:** dramatic warm (#FF8050), 5.0 energy, narrow
- **Fill:** cool counterpoint (#5070FF), 1.5 energy
- **Sky:** dramatic gradient
- **Fog:** thin red volumetric (0.03 density)
- **Bloom:** 0.3 threshold, 0.8 intensity (lens flare)
- **Tonemap:** Filmic
- **SSAO:** strong (0.7 strength)
- **SDFGI:** off
- **Color grade:** boss LUT (high contrast warm)
- **Godrays:** enabled

### menu_key
- **Key light:** clean white (#F5F5FF), 4.0 energy
- **Fill:** soft cool, 1.0 energy
- **Sky:** solid dark (#0A0C12)
- **Fog:** off
- **Bloom:** 0.5 threshold, 0.5 intensity
- **Tonemap:** Filmic
- **SSAO:** subtle
- **SDFGI:** on
- **Color grade:** neutral LUT

## Lighting state machine (dynamic)

Within a single zone, the lighting can shift between **states**:
- **safe** — exploration default
- **danger** — combat triggered, lights dim 30%, color shifts cooler
- **story** — cinematic moments, lights focus on speaker
- **boss** — boss arena override

Transitions: smooth tween over 0.8s default. The LightingStateController
autoload manages this.

## Dynamic light components

### LightFlickerComponent
Attach to any Light3D. Adds candle/torch flicker behavior:
- Random energy variation in [base × 0.85, base × 1.0]
- Random color tint shift (subtle warm <-> cool)
- Configurable frequency
- Optional "out" probability (briefly snaps to 10% energy)

### LightPulseComponent
Attach to any Light3D. Sin-wave energy pulse:
- Configurable amplitude + frequency
- Used for: charging weapons, ability indicators, glowing crystals
- Synced with audio cue if `sync_to_beat` enabled

## Performance budget

Per-frame lighting budget on midspec hardware (GTX 1060):
- Direct lights: 8 max active
- Shadow casters: 4 max
- SDFGI cascades: 0-1 (off in dungeons)
- SSAO samples: 8 (medium)
- SSR samples: 32 (only on water/reflective floors)
- Volumetric fog: 64 samples max
- Reflection probes: 2 max in view

Fallback profile for low-end hardware:
- All shadows off except sun
- SDFGI off
- SSAO half samples
- Volumetric fog off
- Bloom off

## Files

- `_bmad-output/lighting/lighting_bible.md` — this file
- `scripts/resources/environment_preset.gd` — preset resource
- `scripts/systems/environment_database.gd` — 5 presets registry
- `scripts/autoloads/environment_manager.gd` — global env switcher
- `scripts/autoloads/lighting_state_controller.gd` — safe/danger/story/boss states
- `scripts/components/light_flicker_component.gd` — candle/torch flicker
- `scripts/components/light_pulse_component.gd` — sin-wave pulse
- `scripts/utils/material_auditor.gd` — PBR baseline validator
