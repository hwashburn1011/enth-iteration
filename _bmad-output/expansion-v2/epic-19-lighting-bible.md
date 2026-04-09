---
name: Epic 19 — PBR Lighting & Atmosphere Bible
description: Locked lighting baseline for the Expansion V2 graphics overhaul
epic: 19
created: 2026-04-09
---

# PBR Lighting & Atmosphere Bible

## Why this matters
Lighting is the single biggest lever for "this game looks expensive vs cheap."
Hero models lit poorly look cheap. Cheap models lit well look expensive. The
Pillar 1 graphics overhaul lives or dies on this epic.

## PBR baseline
- **Albedo**: dark surfaces never below 0.02, bright surfaces never above 0.95
  (the PBR sweet spot)
- **Metallic**: always 0.0 OR 1.0, never in-between (the dielectric vs
  conductor rule)
- **Roughness**: never 0.0 (mirror) or 1.0 (lambert) — production sweet
  spot is 0.05-0.95
- **Emission**: HDR values 1.0-15.0 with bloom enabled. Below 1.0 doesn't
  bloom. Above 15.0 blows out

## 8 lighting presets (locked)
- TOWN_DAY: warm sun, blue sky ambient, low fog, SDFGI on
- TOWN_NIGHT: cool moon, fog up, glow boosted, SSR on for wet streets
- DUNGEON_DIM: cyan ambient, high fog, no sun, glow maxed
- BOSS_ARENA: cyan glow boosted to 1.15, dark base, SSR on
- MENU_KEY: hero key light from upper left, magenta accent
- DANGER_COMBAT: red ambient, fog density 0.022, no sun
- SAFE_HUB: warm ambient, low fog, SDFGI on, low intensity
- STORY_CINEMATIC: violet sun + warm ambient, glow 1.25 for dreamy feel

## Day-night cycle
- **Dawn**: 5:00-7:00 — sun rises from -10° to +20°, color #ffd9a0 → #fff5e0
- **Day**: 7:00-18:00 — sun at 50°, color #fff5e0
- **Dusk**: 18:00-20:00 — sun drops -10°, color shifts to #ff8060
- **Night**: 20:00-5:00 — sun replaced by moon at 30°, color #5070b0
- **Window lights** ramp up at 18:00, peak at 19:00, hold until 5:30

## Per-component cost budget
- SDFGI: 5ms (only enabled in town day/night + safe hub)
- SSR: 1.5ms (boss arena + town night only)
- SSAO: 0.8ms (everywhere, intensity tuned per env)
- Volumetric Fog: 1.2ms (everywhere)
- Bloom: 0.4ms (everywhere)
- Total budget: ~9ms additional, fits in 16.6ms (60 FPS) frame budget

## Validation pattern
Every scene must pass these tests:
1. Player Globbler is readable in all 8 presets
2. All 11 enemies are readable in all 8 presets
3. UI text remains legible in all 8 presets
4. No surface blows out (max pixel <0.95 sRGB)
5. No surface crushes black (min pixel >0.02 sRGB)

## Anti-patterns
- ❌ Sun directly behind camera (kills depth perception)
- ❌ Pure black ambient (loses character readability)
- ❌ Fog density above 0.030 (the camera can't see the boss)
- ❌ Glow intensity above 1.5 (UI text becomes illegible)
- ❌ Hard color palette switches (always tween over 1.5s)
