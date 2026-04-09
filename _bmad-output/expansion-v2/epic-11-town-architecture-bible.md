---
name: Epic 11 — Town Hero Architecture Bible
description: 10 landmark building concepts + per-building design knobs for the Town Architecture epic
epic: 11
created: 2026-04-09
---

# Town Hero Architecture Bible

## Why this matters

The town silhouette is the player's mental anchor for "home." 10
distinct landmark buildings each with a clear visual identity. When
the camera pulls back over the town, the player should be able to name
every building from its silhouette.

## Architectural cohesion rules

All 10 buildings share these traits so they look like one settlement:

1. **Same material palette** — warm cream stone walls + dark teal
   roof tiles + chrome trim + cyan accent windows. Per-building
   accent colors break the monotony.
2. **Same scale grid** — buildings range from 6m to 18m tall, all on
   a 1m floor grid so paths connect cleanly.
3. **Same in-universe energy lines** — every building has at least
   one cyan emission line running along a roof edge or door frame
   (the "structured data" hint that this is still a simulation).
4. **Same scale anchor** — Globbler at 1.5m tall is the reference;
   doors are 2.0m tall on every building, windows 0.9m wide.
5. **Same wear pattern** — chrome trim has the same edge highlight,
   stone has the same crack noise, glass has the same fingerprint
   reflection — per-shader, not per-building.

## The 10 landmark buildings

### Building 1 — The Compaction Tower
- **Role:** Central spire visible from anywhere in town
- **Height:** 18m (the tallest)
- **Footprint:** 4m × 4m square base, narrows to 1.5m at top
- **Silhouette:** Cylindrical tower with 3 wider observation rings
  at 6m, 12m, 16m. Antenna spire at the top. Red blinking light at
  the very top (the in-universe simulation status indicator).
- **Material:** Cream stone base + chrome ring trim + dark teal cap
- **Distinguishing tell:** TALL. The only 18m structure in town.

### Building 2 — Sage's Sanctum
- **Role:** The AI Sage's home — where Globbler can find him at night
- **Height:** 6m
- **Footprint:** 5m × 5m circular dome
- **Silhouette:** Low circular dome with floating geometric shapes
  orbiting above (the "data structures rendered" feel)
- **Material:** White marble + cyan emissive seams
- **Distinguishing tell:** Floating chunks above it

### Building 3 — Iteration Memorial
- **Role:** Cenotaph honoring past iterations of the simulation
- **Height:** 4m
- **Footprint:** 6m × 3m rectangle
- **Silhouette:** Low pedestal with 9 vertical stelae (one per
  iteration) plus a central holographic projection plinth
- **Material:** Dark stone + cyan holographic text projection
- **Distinguishing tell:** 9 stelae in a row + the projection plinth

### Building 4 — Cache Tavern
- **Role:** The town's social hub, run by Cache the barkeep
- **Height:** 7m
- **Footprint:** 8m × 6m rectangular
- **Silhouette:** Cozy cottage shape with peaked roof + chimney
  emitting smoke
- **Material:** Warm cream stone + dark teal peaked roof + warm
  yellow window light
- **Distinguishing tell:** The chimney smoke + warm window glow

### Building 5 — Forge Foundry
- **Role:** Forge's workshop — where weapons are crafted
- **Height:** 8m
- **Footprint:** 7m × 7m square
- **Silhouette:** Industrial brick building with smokestack and a
  large open archway at the front (so the forge is visible inside)
- **Material:** Brick walls + iron trim + glowing orange forge
  visible through the open arch
- **Distinguishing tell:** The smokestack + visible orange flame
  from the front

### Building 6 — Index Archive
- **Role:** The library — Index keeps the town records here
- **Height:** 9m
- **Footprint:** 6m × 8m rectangular
- **Silhouette:** Tall narrow building with stacked data crystal
  shelves visible through tall windows
- **Material:** Cream stone + dark teal trim + cyan crystal shelves
  inside
- **Distinguishing tell:** The tall crystal-filled windows

### Building 7 — Harvest Greenhouse
- **Role:** Where Harvest grows the town's crops
- **Height:** 5m
- **Footprint:** 8m × 12m long rectangle
- **Silhouette:** Glass dome over a long rectangular base — like a
  Victorian greenhouse
- **Material:** Chrome frame + clear glass panels + green plants
  visible inside
- **Distinguishing tell:** Glass dome + visible interior plants

### Building 8 — Render Studio
- **Role:** Render's painting studio
- **Height:** 6m
- **Footprint:** 5m × 5m
- **Silhouette:** Square building with a slanted glass skylight
  roof + paint stains visible on the lower wall
- **Material:** Cream stone + multi-colored paint splatter accent
- **Distinguishing tell:** Slanted glass skylight + paint splatters

### Building 9 — Sync Amphitheater
- **Role:** Where Sync plays music for the town
- **Height:** 4m
- **Footprint:** 10m diameter circular
- **Silhouette:** Open-air semicircular amphitheater with curved
  stone seating + small stage in the center
- **Material:** Cream stone + chrome stage rail + cyan stage lights
- **Distinguishing tell:** Open semicircle of curved seats

### Building 10 — Sentinel Watch
- **Role:** Sentinel's gate tower at the town entrance
- **Height:** 12m
- **Footprint:** 3m × 3m square base
- **Silhouette:** Square watchtower with battlements + extending wall
  sections going outward 8m on each side, large arched gate at the
  base for the town entrance
- **Material:** Dark stone + chrome trim + cyan visor-slit window
- **Distinguishing tell:** The arched gate at the bottom

## Per-building design knobs (parameterized for the pipeline)

| ID | Name | Height | Width | Depth | Shape | Roof | Accent color | Special feature |
|---|---|---|---|---|---|---|---|---|
| compaction_tower | Compaction Tower | 18.0 | 4.0 | 4.0 | tower | spire | cyan | observation rings + red top light |
| sages_sanctum | Sage's Sanctum | 6.0 | 5.0 | 5.0 | dome | dome | cyan | floating chunks above |
| iteration_memorial | Iteration Memorial | 4.0 | 6.0 | 3.0 | rectangle | flat | white | 9 stelae + projection plinth |
| cache_tavern | Cache Tavern | 7.0 | 8.0 | 6.0 | cottage | peaked | warm yellow | chimney smoke |
| forge_foundry | Forge Foundry | 8.0 | 7.0 | 7.0 | brick | flat | orange | smokestack + open arch |
| index_archive | Index Archive | 9.0 | 6.0 | 8.0 | tall | flat | cyan | tall crystal windows |
| harvest_greenhouse | Harvest Greenhouse | 5.0 | 8.0 | 12.0 | greenhouse | dome | green | visible plants inside |
| render_studio | Render Studio | 6.0 | 5.0 | 5.0 | rectangle | slanted_glass | magenta | paint splatters |
| sync_amphitheater | Sync Amphitheater | 4.0 | 10.0 | 10.0 | circular | open | cyan | curved seating |
| sentinel_watch | Sentinel Watch | 12.0 | 3.0 | 3.0 | tower | battlements | cyan | gate arch + wall extensions |

## Anti-patterns

- ❌ Identical roof shapes — every building must have a distinct roofline
- ❌ Buildings under 4m tall (they get lost in the foliage)
- ❌ No emission accents — every building needs at least one cyan accent
- ❌ Inconsistent material palette — share the cream/teal/chrome base
- ❌ Door height varies (always 2.0m for player scale anchoring)
