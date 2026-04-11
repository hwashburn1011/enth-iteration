---
name: Epic 16 — Memory Vaults Biome Bible
description: Design pillars + tileset spec + room layouts for the Memory Vaults dungeon biome
epic: 16
created: 2026-04-09
---

# Memory Vaults Biome — Design Bible

## Vibe / mood
A reverent, gilded archive of the simulation's memories. Cold gold light,
floating memory orbs, vault doors with ancient seals. Where the Server
Room is alive with hum and motion, the Vaults are ghostly silent — the
player feels they are intruding on something sacred.

## 5 design pillars

1. **Cold gold + violet baseline** — gold and violet emission accents
   instead of cyan/blue. Warm gold light still feels distant and reverent
   not cozy.
2. **Vault iconography** — every wall has at least one inlaid seal or
   inscription. Doors are massive reinforced blocks. The architecture
   communicates "important things behind these walls."
3. **Floating geometry everywhere** — memory orbs, levitating debris,
   floating glyphs in the air. The vaults rejected gravity at some point.
4. **Reverent silence** — ambient bed is low chimes + distant whispers,
   not the hum of the Server Room. Players should lower their voices.
5. **8 distinct room layouts** — vault corridor, hub chamber, treasury,
   sarcophagus chamber, elite chamber, boss entry, secret stash, story room.

## Tileset (modular 4m grid)

| Module | Size | Purpose |
|---|---|---|
| floor_inlaid | 4×4×0.10 | Walkable floor with inlaid metal pattern |
| wall_vault | 4×3×0.30 | Reinforced vault wall with seal |
| wall_archive | 4×3×0.30 | Archive shelf wall |
| wall_blank | 4×3×0.30 | Plain support wall |
| ceiling_orb | 4×4×0.10 | Ceiling with hanging memory orbs |
| ceiling_glyph | 4×4×0.10 | Ceiling with floating glyphs |
| corner_inside | 0.30×0.30×3 | Inside corner trim |
| corner_outside | 0.30×0.30×3 | Outside corner trim |
| t_junction | 4×4×3 | T wall junction |
| x_junction | 4×4×3 | 4-way wall junction |
| vault_door_blocker | 4×4×3 | Massive vault door end-cap |
| door | 2.5×3.0×0.20 | Standard reinforced door |

## Hero props

- **vault_door_v1..4**: 4 ornate vault door variants with seals
- **memory_crystal_v1..8**: 8 floating memory crystal variants in different colors
- **archive_shelf**: tall shelves with crystal inserts
- **pedestal_display**: prop pedestal for hero crystals
- **floating_data_orb**: levitating cyan orb
- **sealed_sarcophagus**: stone sarcophagus with cyan seal
- **forbidden_seal_door**: door with magical lockdown
- **security_barrier**: laser/light wall barrier

## Lighting profile

- **Ambient**: warm gold 0.30/0.22/0.10 at 0.25 strength (subdued)
- **Key**: gold point lights at 4m above each pedestal
- **Accent**: violet emission from memory crystals
- **Special**: shafts of warm light through small ceiling vents

## Anti-patterns

- ❌ Bright lighting (the vaults are dim and reverent)
- ❌ Mechanical hum (use chimes/whispers, not server fans)
- ❌ Cold blue palette (that's the Server Room)
- ❌ Open ceilings (always covered with orbs/glyphs)
- ❌ Combat-ready props in halls (props in halls are static, only chambers have combat)
