---
name: Town Building & Decoration Bible
description: 50 placeable decorations, plot system, house upgrades, photo mode, community sharing
date: 2026-04-09
status: design + data complete
---

# Town Building & Decoration Bible

## Philosophy

Town building is a **creative outlet** that ties player effort to a personal,
visible space. Inspired by Stardew Valley's farm customization, Animal Crossing's
furniture placement, and Terraria's housing requirements.

The player isn't *required* to decorate. But for those who do, the system rewards
creativity with:
- NPC affinity bonuses from well-decorated rooms
- Achievement unlocks
- Photo-mode screenshot sharing
- "Compaction Persistence" — decorations carry across iteration resets

## What can be placed

50 decorations across 4 size categories:

| Category | Count | Examples | Grid footprint |
|---|---|---|---|
| Small | 15 | flower pot, lamp, mug, terminal | 1×1 |
| Medium | 15 | bookshelf, sofa, server rack, fountain | 2×2 |
| Large | 10 | statue, bed, holo-projector, fountain | 3×3 |
| Interactive | 10 | jukebox, training dummy, piano, pet bed | 2×2 |

All decorations have:
- **rarity tier** (common/uncommon/rare/legendary) drives visual quality
- **theme tag** (cozy/tech/glitch/ornate/natural) drives set bonuses
- **NPC affinity bonus** when placed in NPC home

## Plots

The player owns plots they can decorate. Plots are unlocked through progression:

| Plot | Unlock | Size | Notes |
|---|---|---|---|
| **Starter Home** | iteration 1 | small interior | 1 room, 16×16 grid |
| **Backyard** | iteration 2 | small exterior | 8×16 grid, outdoor only |
| **Workshop** | iteration 3 | medium interior | crafting bench area |
| **Garden Plot** | iteration 3 | medium exterior | farm + decor mix |
| **Town Square Patch** | iteration 5 | small public | visible to all NPCs |
| **Iteration Memorial** | iteration 7 | medium public | story-themed |
| **Sage's Annex** | iteration 9 | large interior | endgame reward |

## Placement system

### Rules
- Snap-to-grid by default (1×1 grid)
- Hold Alt for free placement
- Rotation in 90° increments (Q/E)
- Mouse wheel cycles through item variants
- Right-click cancels current placement
- Items can't overlap each other or block walkable paths

### UI
- Hotbar shows currently equipped placement item
- Grid overlay appears when in placement mode (toggle with G)
- Ghost preview at cursor — green if valid, red if invalid
- Press B to enter build mode, B again to exit

### Save data
- Plot id → Array of placed item entries
- Each entry: { item_id, position, rotation, variant_index }
- Decorations carry across iteration resets (compaction-persistent)

## Decoration list (50)

### Small (15)
1. Flower Pot — 1 patch, 1 bytewood
2. Data Lamp — 1 wire, 1 cache crystal
3. Coffee Mug — 2 bit fragment
4. Terminal — 2 wire, 1 server coil
5. Plant Sprout — 1 patch
6. Bit Sculpture — 2 algorithm stone
7. Cache Cube — 3 cache crystal
8. Glow Mushroom — 2 glowmoss
9. Tiny Statue — 1 compiled steel
10. Tea Set — 2 patch
11. Code Scroll — 1 dyed thread
12. Wind Chime — 2 cache crystal
13. Memory Ball — 1 memory glass
14. Nightlight — 1 wire, 2 cache crystal
15. Crystal Cluster — 3 cache crystal

### Medium (15)
16. Bookshelf — 5 bytewood, 2 patch
17. Cozy Sofa — 4 patch, 2 dyed thread
18. Server Rack — 3 wire, 2 server coil
19. Coffee Table — 3 bytewood
20. Tech Desk — 3 compiled steel, 1 server coil
21. Wardrobe — 4 bytewood, 2 patch
22. Decor Plant — 2 logleaf, 1 patch
23. Dining Table — 4 bytewood, 1 dyed thread
24. Workbench — 3 compiled steel
25. Display Case — 3 memory glass
26. Tatami Mat — 4 patch, 1 dyed thread
27. Mini Forge — 2 compiled steel, 1 quantum shard
28. Garden Bench — 3 bytewood, 1 patch
29. Music Player — 2 server coil, 1 dyed thread
30. Holo Globe — 2 memory glass, 1 algorithm stone

### Large (10)
31. Stone Statue — 5 compiled steel
32. Player Bed — 5 patch, 3 bytewood, 1 dyed thread
33. Holo-Projector — 4 memory glass, 2 algorithm stone
34. Grand Fountain — 4 compiled steel, 2 quantum shard
35. Master Bookshelf — 8 bytewood, 4 patch
36. Iteration Monument — story unlock, 1 iteration echo
37. Compiler's Statue — story unlock, 1 boss soul
38. Sage's Tree — 5 logleaf, 1 sages tear
39. Throne — 5 compiled steel, 2 dream silk
40. Compaction Pillar — 1 compaction heart

### Interactive (10)
41. Jukebox — plays music in radius — 3 server coil, 1 quantum shard
42. Training Dummy — practice attacks — 4 compiled steel
43. Piano — playable mini-instrument — 5 bytewood, 2 dyed thread
44. Pet Bed — pet sleeps here — 3 patch
45. Mini Garden — auto-grows decor crops — 4 logleaf, 2 patch
46. Crafting Workbench Mini — small crafting station — 3 compiled steel
47. Storage Chest — extra inventory — 4 bytewood, 2 wire
48. Mirror — change cosmetics — 3 memory glass
49. Telescope — daily lore drop — 2 memory glass, 1 quantum shard
50. Compaction Shrine — story interactions — 1 sages tear

## Theme set bonuses

When 5+ decorations of the same theme are placed in the same plot:
- **Cozy:** NPCs visit more often (+50% visit rate)
- **Tech:** -10% crafting cost in this plot's stations
- **Glitch:** small chance to spawn glitch sprite NPCs
- **Ornate:** +1 affinity gain per dialogue with NPCs in this plot
- **Natural:** crops in adjacent plots grow 10% faster

## Photo mode

Press F9 in town to enter photo mode:
- Free camera (WASD + mouse)
- Hide HUD toggle
- Time of day slider
- Filter selection (4 LUTs)
- Aspect ratio selection (16:9, 1:1, vertical)
- Save screenshot to user://photos/
- Optional caption + sharing prompt

## NPC affinity bonus

When NPCs visit a decorated plot (or live in it), they gain bonus affinity:
- 1 affinity per 5 decorations placed
- +2 bonus if a theme set bonus is active
- Caps at 10 bonus affinity per visit

## Iteration evolution

Decorations carry across iteration resets but **change appearance** subtly:
- Iteration 1: clean and new
- Iteration 3: subtle wear, vines/dust
- Iteration 5: visible age, glitch artifacts
- Iteration 9: corruption mixed in (tells the world's story)

## Achievements

- "First Brick" — place any decoration
- "Interior Designer" — place 50 decorations
- "Maximalist" — place 200 decorations
- "Themed" — activate any theme set bonus
- "Photographer" — save 10 photos
- "Master Builder" — place every decoration type

## Files

- `_bmad-output/town_building/town_building_bible.md` — this file
- `scripts/items/decoration_item.gd` — decoration resource
- `scripts/systems/decoration_database.gd` — all 50 decorations
- `scripts/systems/decoration_placer.gd` — placement system
- `scripts/systems/buildable_plot.gd` — plot ownership/save state
- `scripts/components/photo_mode.gd` — photo mode controller
- `scripts/ui/decoration_ui.gd` — placement UI
