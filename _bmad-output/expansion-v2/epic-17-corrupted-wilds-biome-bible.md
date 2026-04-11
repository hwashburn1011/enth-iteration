---
name: Epic 17 — Corrupted Wilds Biome Bible
description: Design pillars + tileset spec + room layouts for the Corrupted Wilds dungeon biome
epic: 17
created: 2026-04-09
---

# Corrupted Wilds Biome — Design Bible

## Vibe / mood
Where the simulation has GROWN organic. Flesh meets circuit. Pulsing
walls of meat-tech, glowing veins, hanging tendrils, toxic purple light.
This is the simulation getting cancer. Players should feel uncomfortable.

## 5 design pillars

1. **Purple + sickly green baseline** — distinct from Server Room cyan
   and Memory Vaults gold. Toxic glow color identity.
2. **Organic + digital fusion** — every wall has both metal panels AND
   flesh-like veins. Neither pure nature nor pure tech.
3. **Pulsing motion** — walls breathe, tendrils sway, vein emission
   pulses. The biome is ALIVE in a way no other biome is.
4. **Asymmetric room layouts** — irregular walls, organic curves
   instead of square corners. Less grid-perfect than the other biomes.
5. **8 distinct room layouts** — corridor, chokepoint, loot grove,
   elite den, boss entry, hidden cave, hub, story room.

## Tileset (modular 4m grid, allows 1m offsets for organic curves)

| Module | Size | Purpose |
|---|---|---|
| floor_vein | 4×4×0.10 | Vein-patterned floor with pulse emission |
| wall_organic | 4×3×0.40 | Flesh-tech wall with vein detail |
| wall_tendril | 4×3×0.40 | Wall with hanging tendrils |
| wall_blank | 4×3×0.30 | Plain support wall |
| ceiling_tendril | 4×4×0.10 | Ceiling with hanging tentacles |
| ceiling_pod | 4×4×0.10 | Ceiling with hatching pods |
| corner_organic | 0.40×0.40×3 | Curved organic corner |
| t_junction | 4×4×3 | T wall junction |
| growth_door | 3×3×0.40 | Door grown from flesh |

## Hero props

- **growth_v1..6**: 6 organic growth variants in different sizes
- **tentacle_v1..4**: 4 hanging tentacle prop variants
- **crystal_growth**: corrupted crystal cluster
- **infected_terminal**: terminal corrupted with vein overgrowth
- **corruption_pool**: pool of toxic purple liquid
- **hatching_pod**: organic pod ready to spawn enemies
- **infected_statue**: statue corrupted by overgrowth
- **twisted_tree**: gnarled tree with vein bark

## Lighting profile

- **Ambient**: cool purple 0.20/0.10/0.30 at 0.20 strength
- **Key**: sickly green from corruption pools
- **Accent**: violet from veins + hatching pods
- **Pulse**: emission strength tied to global pulse_phase uniform

## Anti-patterns

- ❌ Bright clean lighting (this is a sick biome)
- ❌ Mechanical/clean materials (always flesh-tech fusion)
- ❌ Symmetric room layouts (organic curves preferred)
- ❌ Cold blue palette (that's the Server Room)
- ❌ Gold (that's the Memory Vaults)
