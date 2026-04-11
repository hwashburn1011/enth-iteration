---
name: Epic 15 — Server Room Biome Bible
description: Design pillars + tileset spec + room layouts for the Server Room dungeon biome
epic: 15
created: 2026-04-09
---

# Server Room Biome — Design Bible

## Vibe / mood
A cold-blue server farm, the inside of the simulation's hardware. Endless
rows of server racks, blinking lights, condensation drips, ambient hum.
The player is walking through the literal bones of the simulation.

## 5 design pillars

1. **Cold blue baseline lighting** — every room is lit from blue point
   sources (server LEDs) with subtle red emergency lights. No warm tones
   except in the boss arena entry.
2. **Modular 4m × 4m tile grid** — every wall, floor, ceiling piece is
   sized to a 4m grid for clean snap assembly.
3. **Vertical stratification** — floor (grates), wall (server racks),
   ceiling (cable trays + pipes) — every room reads its layers clearly.
4. **In-universe storytelling props** — terminals show actual scrolling
   code, conduits glow when power is flowing, holographic displays
   project the simulation's status indicators.
5. **8 distinct room layouts** — using the same tile kit, the dungeon
   generator can produce 8 visually different rooms (corridor, junction,
   dead-end, loot, elite, boss-entry, secret, vent-route).

## Tileset (modular)

| Module | Size | Purpose |
|---|---|---|
| floor_grate | 4×4×0.10 | Standard walkable floor with grate texture |
| wall_server | 4×3×0.30 | Wall with server-rack slots facing into room |
| wall_pipe | 4×3×0.30 | Wall with vertical pipes |
| wall_blank | 4×3×0.30 | Plain support wall |
| ceiling_cable | 4×4×0.10 | Ceiling with cable tray running across |
| ceiling_pipe | 4×4×0.10 | Ceiling with pipe network |
| corner_inside | 0.30×0.30×3 | Inside corner trim |
| corner_outside | 0.30×0.30×3 | Outside corner trim |
| t_junction | 4×4×3 | T-shape wall junction |
| x_junction | 4×4×3 | 4-way wall junction |
| end_cap | 4×4×3 | Wall end cap with door slot |
| door | 2.0×2.5×0.10 | Standard door |

## Hero props (each spawn-able as room dressing)

- **server_rack_v1..6**: 6 visual variants with different LED colors
  (cyan, blue, red emergency, yellow warning, green ok, white standby)
- **terminal_v1..6**: 6 console variants with scrolling code text
- **holo_display**: floating cyan hologram of simulation status
- **cooling_fan**: animated rotating fan
- **floor_grate_dropdown**: removable grate for vent routes
- **cable_bundle_v1..3**: 3 variants of hanging cable bundles
- **power_conduit**: glowing emissive pipe segment
- **steam_vent**: anchor point for steam particle emitter

## Lighting profile

- **Ambient**: cool blue 0.10/0.20/0.35 at 0.30 strength
- **Key lights**: blue point lights at 4m above each server rack
- **Fill**: cyan rim from cable trays
- **Emergency mode**: red point lights replace blue at corruption level

## Room layouts (8 unique)

1. **corridor** — straight 4×16m hallway with server racks both sides
2. **junction_t** — T-intersection with central terminal
3. **dead_end** — small 4×4m alcove with loot crate
4. **loot_room** — 8×8m room with 4 server racks + holographic display
5. **elite_room** — 12×8m arena with cooling fans + steam vents
6. **boss_entry** — 8×16m corridor with progressive lighting buildup
7. **secret_room** — 4×4m hidden room behind a floor grate
8. **vent_route** — narrow 2×8m crawlspace tunnel

## Anti-patterns

- ❌ Warm lighting except at boss entry
- ❌ Visible plants or vegetation (the server room is dead tech, not alive)
- ❌ Open ceilings (always cable trays + pipes overhead)
- ❌ Wood materials (everything is metal/chrome/cyan)
