---
name: Epic 18 — Boss Sanctum Bible
description: Design pillars + arena spec for the Boss Sanctum / Final Vault biome
epic: 18
created: 2026-04-09
---

# Boss Sanctum / Final Vault — Design Bible

## Vibe / mood
The cathedral where the Compiler boss lives. A massive 25m radius circular
arena with soaring pillars, processional entry, central altar/sculpture,
and god-ray volumetric lighting from above. This is where the trailer cut
happens. Every pixel needs to read as a HERO LOCATION.

## 5 design pillars

1. **Imposing arena scale** — 25m radius minimum, 12m ceiling height,
   the boss at 9m tall must still feel scale-appropriate
2. **Central focal point** — every camera angle should naturally lead
   to the central altar/sculpture where the boss spawns
3. **Cinematic lighting** — god rays from ceiling vents, floating light
   fixtures, multiple color presets per phase
4. **Processional entry** — the player walks down a grand corridor
   lined with statues before reaching the arena, building anticipation
5. **Audience presence** — recruited NPC silhouettes watching from the
   outer balcony, providing emotional weight

## Arena geometry

- **Floor**: 25m radius circular dais at z=0, dark stone with cyan
  energy inlay forming concentric rings
- **Center altar**: 4m × 4m raised platform at z=0.5, the boss spawn point
- **Pillars**: 8 massive pillars at 22m radius spaced 45° apart, each 12m
  tall with cyan accent crowns
- **Walls**: outer ring wall at 25m radius extends from z=0 to z=12, with
  6 archway openings revealing the skybox backdrop
- **Ceiling**: domed ceiling with 4 ceiling vents emitting god rays
- **Throne backdrop**: massive sculptural wall behind the boss spawn at
  z=15-25 in the back semicircle, with floating chrome geometry forming
  abstract simulation imagery

## Hero props

- **central_altar**: raised platform with cyan energy floor decal
- **pillar_v1..8**: 8 unique pillar variants
- **throne_backdrop**: massive sculptural wall
- **lining_statue_v1..6**: 6 procession statues for the entry corridor
- **floating_fixture_v1..4**: 4 floating chrome light fixtures
- **trophy_alcove**: alcoves for past boss trophies
- **chest_pedestal**: where the loot chest spawns after defeat

## Lighting profiles

| Phase | Ambient | Key | Accent | Mood |
|---|---|---|---|---|
| Entry | warm gold 0.30/0.20/0.10 at 0.40 | gold processional sconces | cyan from arena | anticipation |
| Phase 1 | cool blue 0.05/0.10/0.18 at 0.50 | cyan from pillars | blue god rays | imposing |
| Phase 2 | magenta-cyan 0.25/0.05/0.30 at 0.45 | magenta from cracks | strobe phase transitions | unstable |
| Phase 3 | crimson 0.30/0.05/0.05 at 0.40 | crimson from corruption | flickering | climactic |
| Defeat | warm sunrise 0.85/0.65/0.30 at 0.85 | gold sunrise from openings | warm bloom | catharsis |

## Anti-patterns

- ❌ Cluttered arena floor (the boss needs space to attack)
- ❌ Repeating pillar shapes (every pillar is unique)
- ❌ Visible ceiling fixtures during boss fight (stay above the camera)
- ❌ Bright lighting during phase 1 (let the cyan accents pop against dark)
- ❌ No skybox backdrop (the archways must show distant simulation imagery)
