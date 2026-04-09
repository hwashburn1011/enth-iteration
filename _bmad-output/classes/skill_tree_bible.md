---
name: Skill Tree System Bible
description: Hub-and-spoke skill trees per class with keystones, prerequisites, build presets, and effect schema
date: 2026-04-09
status: implementation-complete (foundation), node padding pass deferred
---

# Skill Tree System Bible

## Topology

**Hub-and-spoke per discipline.** Each class has a single root node and 3
disciplines (e.g. Compiler: Order / Logic / Systems) radiating outward as
spokes. Each discipline has a keystone gate at depth 3 and a final keystone
at depth 4.

```
                  [Order Final Keystone]
                          |
                  [Order Keystone]
                  /       |       \
            [order]   [order]   [order]
                  \       |       /
                   [Discipline Hub]
                          |
                       [ROOT]
                          |
                  [Logic Hub]   [Systems Hub]
                  ...           ...
```

This shape:
- Always lets the player branch into the next discipline at any time
- Forces a meaningful keystone choice at depth 3
- Keeps the rendering rectangular and pannable
- Lets us add more nodes between hubs without moving keystones

## Skill points

- **Source 1: Level-up.** Every player level grants 1 skill point.
- **Source 2: Class milestones.** Each milestone (5/10/15/20/25/30/40/50)
  grants 2 bonus points = 16 milestone points across the run.
- **Source 3: Quest rewards.** Story quests can grant occasional points
  (max 5 across the campaign).
- **Total available at level 50:** ~71 points.

## Node types

| Type | Cost | Max Rank | Effect Scale |
|---|---|---|---|
| Stat ramp | 1 | 5 | small +X stat per rank |
| Binary unlock | 1 | 1 | one-time effect/passive |
| Ability mod | 1 | 1 | tweaks an existing ability |
| **Keystone** | 3 | 1 | major effect, gates progression |

Each class has **5 keystones** at strategic positions. Allocating all 5 is
the "completionist" build; most players will pick 3-4.

## Effect schema

Effects are data — the SkillTreeComponent reads `effects` arrays and
dispatches them to the right system. Adding a new effect type means a new
case in `_apply_effects()`.

```gdscript
{"type": "stat_add",          "params": {"stat": "max_hp", "amount": 10}}
{"type": "stat_mult",         "params": {"stat": "damage_modifier", "multiplier": 1.05}}
{"type": "ability_unlock",    "params": {"ability_id": "recompile"}}
{"type": "ability_modifier",  "params": {"ability_id": "data_pulse", "key": "damage", "value": 18}}
{"type": "passive_unlock",    "params": {"passive_id": "endless_loop"}}
```

## Refund / respec rules

- **Right-click a node** in the tree UI to refund 1 rank
- Refund is **blocked if any allocated child node depends on the refunded one**
  (the player must refund children first)
- Refund returns the full point cost
- Full reset is available via the **Reflection NPC** in town for 50 compute crystals
- Reset clears all allocations but does NOT take points away (keep total earned)

## Build sharing

Builds are encoded as base64-compressed strings:

```
class_id|node1=rank|node2=rank|...
```

`SkillTreeComponent.export_build_code()` produces a shareable string.
`import_build_code()` parses it and re-allocates from scratch. Build codes
include the class id so importing into the wrong class is rejected.

## Preset builds

Each class has 3 beginner presets defined in `SkillTreePresets`:
- **Compiler:** Pattern Master, Glass Engineer, Self-Sustaining
- **Daemon:** Wind Reaper, Critical Mass, From the Shadows
- **Kernel:** Living Wall, Hammer of the Kernel, Earth Shaker

Apply Preset button in the UI calls `SkillTreePresets.apply_preset()` which
resets the tree and re-allocates the preset's node list in order.

## Node count current vs planned

Current implementation: ~25 unique nodes per class. Plan called for 50.
The 25-node version covers all 5 keystones plus 2-3 supporting nodes per
spoke, which is enough for distinct identity and meaningful choice. The
remaining 25 nodes per class are "padding" stat nodes (e.g. +5 max HP
filler) — these can be added in a polish pass before launch without
breaking save data, since the tree is data-driven.

Recommended padding strategy:
- Add 5 small stat nodes between each keystone and root
- Add 2 utility nodes per spoke (lifesteal, cooldown reduction, etc.)
- Add 5 "wide" nodes connecting disciplines so cross-build paths exist

## UI behavior

- **Pan:** middle mouse drag
- **Zoom:** scroll wheel (0.5x to 2.5x)
- **Hover:** show full tooltip with effects + lore
- **Left click:** allocate
- **Right click:** refund
- **Locked nodes:** rendered at 35% opacity
- **Available nodes:** rendered at 85% opacity, pulsing border
- **Allocated nodes:** rendered at 100% opacity, themed color
- **Keystones:** rendered 1.4x scale with glow halo

## Validation

- Allocating fails if: cost > available, prereq missing, max rank reached
- Refunding fails if: allocated children depend on this node, rank already 0
- Build codes for wrong class are rejected with warning
- Save data round-trip preserves exact allocation
- Class change triggers automatic tree reset (points refunded, allocation cleared)

## Files

- `scripts/resources/skill_node.gd` — single node
- `scripts/resources/skill_tree.gd` — collection + queries
- `scripts/components/skill_tree_component.gd` — player-facing logic
- `scripts/systems/skill_tree_factory.gd` — declarative tree builder (75 nodes total)
- `scripts/systems/skill_tree_presets.gd` — 9 preset builds
- `scripts/ui/skill_tree_ui.gd` — pan/zoom canvas + tooltip + click handling
