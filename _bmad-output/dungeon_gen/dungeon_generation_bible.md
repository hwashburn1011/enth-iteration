---
name: Procedural Dungeon Generation v2 Bible
description: Anchor rooms + connectors algorithm, room tags, biome libraries, validation pipeline
date: 2026-04-09
status: design + system complete; room scenes pending Blender/scene work
---

# Procedural Dungeon Generation v2 Bible

## Philosophy

Procedural generation in Enth follows the **"anchor + connector" model**:
- **Anchors** are hand-crafted rooms (loot, story, elite, boss) that the
  generator MUST place
- **Connectors** are smaller hand-crafted rooms (combat, corridor, junction)
  that the generator weaves between anchors

This gives us:
- **Predictable layout shape** — every floor has 1 boss, 1-2 loot, 1 story
- **Variety per run** — connectors and order shuffle each time
- **Authored quality** — every room is designed, not random
- **Easy to add content** — drop a new room scene into the library

Inspired by:
- Spelunky (room template system)
- Hades (chamber types + connections)
- Dead Cells (hand-crafted rooms in random order)

## The algorithm

```
generate_floor(biome, floor_number, seed):
  rng = RandomNumberGenerator.new(seed)
  
  # 1. Pick anchors required by floor
  anchors = pick_anchors(biome, floor_number, rng)
  
  # 2. Lay out anchors in a graph
  layout = arrange_anchors(anchors, rng)
  
  # 3. Connect anchors with connector rooms
  layout = weave_connectors(layout, biome, rng)
  
  # 4. Validate path from entry to boss
  if not has_valid_path(layout, "entry", "boss"):
    return generate_floor(biome, floor_number, seed + 1)  # retry
  
  # 5. Place secrets (5% chance per layout)
  if rng.randf() < 0.05:
    layout = place_secret_room(layout, rng)
  
  # 6. Decorate rooms (props, hazards, enemies)
  layout = decorate_rooms(layout, biome, floor_number, rng)
  
  # 7. Build navmesh
  layout = stitch_navmesh(layout)
  
  return layout
```

## Room tags

Every room scene has tags from the following list:
- `combat` — has enemy spawners
- `loot` — has chests/loot pedestals
- `story` — has lore object/dialogue trigger
- `secret` — hidden room
- `elite` — has elite encounter
- `boss` — boss room (one per floor)
- `entry` — first room of floor
- `exit` — last room before next floor portal
- `corridor` — connector room with no encounter
- `junction` — branching room (3+ exits)

## Anchor requirements per floor

For a 5-floor dungeon biome:

| Floor | Required Anchors | Optional |
|---|---|---|
| 1 | entry, combat ×3, loot, exit | secret (5%) |
| 2 | entry, combat ×4, loot, story, exit | secret (10%) |
| 3 | entry, combat ×4, elite, loot, exit | secret (15%) |
| 4 | entry, combat ×5, elite, loot, story, exit | secret (20%) |
| 5 (boss) | entry, combat ×3, boss, loot, exit | — |

## Per-biome room libraries

Each of the 4 biomes maintains its own room library:
```
res://scenes/dungeon_rooms/<biome>/<tag>_<index>.tscn

server_room/combat_01.tscn
server_room/combat_02.tscn
server_room/loot_01.tscn
server_room/elite_01.tscn
server_room/boss_01.tscn
server_room/corridor_01.tscn
server_room/corridor_02.tscn
server_room/junction_01.tscn
server_room/secret_01.tscn
server_room/story_01.tscn
server_room/entry_01.tscn
server_room/exit_01.tscn
```

Each room has 4 connection points (N/E/S/W) that the generator joins.

## Room rotation + mirroring

Each room can be rotated in 90° increments and optionally mirrored. The
generator picks the rotation that fits the layout's connection direction.

## Difficulty escalation

Per-floor enemy density:
- Floor 1: 3 enemies per combat room
- Floor 2: 4 enemies
- Floor 3: 5 enemies (1 may be elite)
- Floor 4: 6 enemies (2 may be elites)
- Floor 5: boss only

Per-floor enemy tier:
- Floor 1: tier 1 only
- Floor 2: tier 1-2
- Floor 3: tier 2-3
- Floor 4: tier 3-4
- Floor 5: boss + minions

## Validation pipeline

After generation:
1. **Path validation** — BFS from entry to boss, fail if disconnected
2. **Reachability** — every room must be reachable from entry
3. **Spawn validation** — every spawn point on navmesh
4. **Performance** — total tris/draw calls under budget

If any check fails, regenerate with a +1 seed (max 5 retries before
falling back to a hand-crafted "guaranteed" floor).

## Seed system

Generation is fully deterministic given (biome, floor_number, seed). This
enables:
- **Reproducible runs** — same seed = same layout (bug reports!)
- **Daily challenges** — same seed for everyone
- **Seed sharing** — players can post seeds for others to play
- **Save mid-run** — store the seed, regenerate on load

## Save data

- current_floor_seed: int
- current_floor_id: StringName (biome + number)
- visited_rooms: Array[int]  ## room indices in the layout
- map_revealed_rooms: Array[int]

## Achievements

- "Lucky Find" — discover a secret room
- "Speedrunner" — clear a floor in under 3 minutes
- "Completionist" — visit every room on a floor
- "Seed Master" — share a seed with another player

## Files

- `_bmad-output/dungeon_gen/dungeon_generation_bible.md` — this file
- `scripts/resources/room_template.gd` — room template metadata resource
- `scripts/systems/room_library.gd` — per-biome room registry
- `scripts/systems/dungeon_generator.gd` — generation algorithm
- `scripts/systems/dungeon_layout.gd` — layout graph data structure
- `scripts/systems/dungeon_validator.gd` — path + reachability validation
