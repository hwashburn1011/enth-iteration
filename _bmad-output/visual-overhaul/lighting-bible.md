# Lighting Bible — Enth: Iteration V3

Reference document for cinematographers, level designers, and trailer
artists. Each setup is rendered against the same hero figure
(`_art_source/world/lighting_bible/`) so it's easy to compare and pick
the right tone for a shot.

All lights are Cycles units (W). Energy values assume the V3 plinth
scale (subject is roughly 2m tall on a 1.2m radius plinth).

---

## 01 — Cinematic Sunset (DEFAULT HERO)

![](../_art_source/world/lighting_bible/v3_lighting_01_cinematic_sunset.png)

The default warm-key + cool-fill + warm-rim cinematic setup used for
all V3 hero renders. Use this for trailer beauty shots and Steam page
key art.

| Light | Type | Energy | Color | Position | Size |
|-------|------|--------|-------|----------|------|
| Key   | Area | 1500   | (1.0, 0.78, 0.45) warm | (4, -5, 5) | 5 |
| Fill  | Area | 350    | (0.45, 0.55, 0.95) cool | (-4, 4, 4) | 5 |
| Rim   | Area | 700    | (1.0, 0.65, 0.30) warm | (0, 6, 3) | 4 |

**When to use:** beauty shots, Steam page hero, intro cinematics,
character portraits.

---

## 02 — Cool Morning

![](../_art_source/world/lighting_bible/v3_lighting_02_cool_morning.png)

Inverted color temperature: cool key, warm fill, cyan rim. Reads as
early dawn or post-rain ambiance.

| Light | Type | Energy | Color | Position | Size |
|-------|------|--------|-------|----------|------|
| Key   | Area | 1300   | (0.55, 0.75, 1.0) cool | (4, -5, 5) | 5 |
| Fill  | Area | 250    | (1.0, 0.88, 0.65) warm | (-4, 4, 4) | 5 |
| Rim   | Area | 400    | (0.40, 0.85, 1.0) cyan | (0, 6, 4) | 5 |

**When to use:** morning town shots, sage's garden, fishing dock,
contemplative cutscenes.

---

## 03 — Dramatic Top Spot

![](../_art_source/world/lighting_bible/v3_lighting_03_dramatic_top_spot.png)

Single 4500W spot from directly above creates harsh contrast and
sculpts shadows around the eyes. Reads as interrogation or pivotal
revelation moment.

| Light | Type | Energy | Color | Position | Spot Size |
|-------|------|--------|-------|----------|-----------|
| Key   | Spot | 4500   | (1.0, 0.95, 0.85) | (0, 0.5, 7) | 50° |

**When to use:** boss reveal, climactic plot beat, "the chosen one" moment.

---

## 04 — Low-Key Noir

![](../_art_source/world/lighting_bible/v3_lighting_04_low_key_noir.png)

Single side spot, no fill. Half the figure goes deep shadow. Heavy
contrast for tension and mystery.

| Light | Type | Energy | Color | Position | Spot Size |
|-------|------|--------|-------|----------|-----------|
| Key   | Spot | 1800   | (1.0, 0.96, 0.88) | (4, -3, 3.5) | 60° |

**When to use:** detective dialogue, betrayal scene, alley-way
ambush, sage's study night-time.

---

## 05 — Backlit Silhouette

![](../_art_source/world/lighting_bible/v3_lighting_05_backlit_silhouette.png)

Strong 4000W warm rim from behind, dim 100W cool front. Subject reads
as silhouette w/ glowing rim. Iconic trailer "approaching from the light"
shot.

| Light | Type | Energy | Color | Position | Size |
|-------|------|--------|-------|----------|------|
| Rim   | Area | 4000   | (1.0, 0.85, 0.55) warm | (0, 6, 5) | 6 |
| Front | Area | 100    | (0.55, 0.65, 0.95) cool | (0, -7, 2) | 4 |

**When to use:** trailer reveal shot, mysterious newcomer entrance,
sunset farewell.

---

## 06 — Bright Daylight

![](../_art_source/world/lighting_bible/v3_lighting_06_bright_daylight.png)

Hosek-Wilkie procedural sun at 55° elevation + soft sky fill. Reads
as outdoor noon. Use for wilderness, town daytime, farming scenes.

| Light | Type | Energy | Color | Notes |
|-------|------|--------|-------|-------|
| Sun   | Sun  | 5.0    | (1.0, 0.96, 0.88) | 55° elevation, 140° azimuth, 2° angle |
| Fill  | Area | 600    | (0.65, 0.78, 1.0) | (-5, 5, 6), size 8 |
| World | Sky  | n/a    | Hosek-Wilkie 2.0 turbidity | Procedural sky |

**When to use:** wilderness exploration, town daytime, farming, fishing.

---

## 07 — Cool Corridor

![](../_art_source/world/lighting_bible/v3_lighting_07_cool_corridor.png)

Cyan spot from far end + cool fill + warm side accent. The standard
Server Room dungeon biome look.

| Light | Type | Energy | Color | Position | Notes |
|-------|------|--------|-------|----------|-------|
| Key   | Spot | 2500   | (0.40, 0.85, 1.0) cyan | (0, -7, 5) | 70° spot |
| Fill  | Area | 600    | (0.30, 0.65, 1.0) cool | (-5, 0, 3) | size 5 |
| Accent| Area | 300    | (1.0, 0.55, 0.20) warm | (5, 0, 2) | size 4 |

**When to use:** Server Room corridors, sci-fi interiors, neon-lit
dungeon segments.

---

## 08 — Three-Color Split

![](../_art_source/world/lighting_bible/v3_lighting_08_three_color_split.png)

Red key + cyan fill + magenta rim. Wraps the figure in 3 distinct
colors per surface direction. High-energy reveal.

| Light | Type | Energy | Color | Position |
|-------|------|--------|-------|----------|
| Key   | Area | 1500   | (1.0, 0.30, 0.20) red | (4, -5, 4) size 5 |
| Fill  | Area | 1200   | (0.30, 0.85, 1.0) cyan | (-4, -3, 4) size 5 |
| Rim   | Area | 1000   | (0.95, 0.30, 0.95) magenta | (0, 6, 4) size 5 |

**When to use:** trailer cut, boss arena reveal, key art for ability
unlock screens, character ability VFX moments.

---

## 09 — Soft Overcast

![](../_art_source/world/lighting_bible/v3_lighting_09_soft_overcast.png)

3 large soft area lights with grey-blue world background. Almost no
hard shadows. Use for product-shot style turntables, item icons,
inventory previews.

| Light | Type | Energy | Color | Position | Size |
|-------|------|--------|-------|----------|------|
| Top   | Area | 1800   | (1.0, 1.0, 1.0) | (0, 0, 8) | 14 |
| Side L| Area | 600    | (0.95, 0.95, 1.0) | (-8, 0, 5) | 12 |
| Side R| Area | 600    | (1.0, 0.96, 0.88) | (8, 0, 5) | 12 |

**When to use:** item turntables, store page screenshots, asset
showcase grids, technical reference shots.

---

## Conventions

- All key lights are area lights (size ≥4) at 30°+ elevation unless
  specified otherwise.
- Color temperature follows the warm/cool split: key warm + fill cool
  is the cinematic default; flip both for "morning."
- Rim lights are smaller (size 4-6) and positioned behind the subject
  to separate them from the background.
- Spot lights are reserved for dramatic single-source moments
  (#03 top spot, #04 noir, #07 corridor).
- World volumetrics are NOT used here — see V3-15 lesson; do volumetrics
  only on simple corridor scenes (V3-13 server room is the proven case).

## How to use this bible in code

```gdscript
# In Godot, set up your level lights to mirror these presets
# by name. The CinematicLighting autoload exposes:
CinematicLighting.apply_preset("cinematic_sunset")
CinematicLighting.apply_preset("backlit_silhouette")
```

A future task can wire that autoload up; for now this doc is the
canonical source for trailer / hero render lighting decisions.
