---
name: Crafting System Bible
description: 20 materials, 85 recipes, 4 station types, gathering + drop sources, station upgrades
date: 2026-04-09
status: design + data complete
---

# Crafting System Bible

## Philosophy

Crafting is a **second progression curve** parallel to loot drops. Loot
gives you a chance at any item. Crafting lets you target a specific item
at the cost of materials. Both routes should feel valid; neither should
trivialize the other.

**Core loop:**
1. Run dungeons → enemies drop materials, gather nodes appear in rooms
2. Return to town → take materials to crafting stations
3. Craft target items using known recipes
4. Discover new recipes from drops, NPCs, or quests
5. Repeat with bigger goals

## Stations

4 distinct stations, each in a different town district:

| Station | District | Recipes | Theme |
|---|---|---|---|
| **Forge** | Workshop | modules, chips | metal + heat |
| **Lab** | Workshop | prompts, alchemy | bubbling beakers |
| **Loom** | Market | cosmetics, dyes | fabric + thread |
| **Compiler** | Commons | protocols, cores | terminal + holograms |

Each station has 3 upgrade tiers unlocked through progression:
- **Tier 1** (start): basic recipes, +0% efficiency
- **Tier 2** (iteration 3): rare recipes, -10% material cost
- **Tier 3** (iteration 6): legendary recipes, -20% cost + 10% bonus output chance

## Materials (20)

### Common (5)
1. **Bit Fragment** — basic data dust, drops from any enemy
2. **Wire** — copper-equivalent, drops from electronic enemies
3. **Patch** — fabric-equivalent, gathered from town and dungeon scrap
4. **Cache Crystal** — small storage gem, gathered from crystal nodes
5. **Bytewood** — wood-equivalent, gathered from digital trees

### Uncommon (5)
6. **Compiled Steel** — refined metal, smelted from Wire + Bit Fragment
7. **Memory Glass** — translucent panel, gathered from Memory Vaults
8. **Server Coil** — electrical component, drops from RogueProcess
9. **Dyed Thread** — colored fabric, made at Loom from Patch + dye
10. **Algorithm Stone** — geometric crystal, drops from Compiler enemies

### Rare (5)
11. **Quantum Shard** — high-energy crystal, drops from elite enemies
12. **Iteration Echo** — temporal residue, dropped from late-game bosses
13. **Pure Code** — ultra-refined data, made by combining Bit Fragments
14. **Voidsteel** — corrupted metal, gathered from Corrupted Wilds
15. **Dream Silk** — legendary fabric, dropped from rare dungeon spawns

### Legendary (5)
16. **Sage's Tear** — wisdom crystal, gifted by AI Sage at high affinity
17. **Boss Soul** — essence from Corrupted Compiler, 1 per kill
18. **The User's Seal** — narrative drop, 1 per iteration
19. **Glitch Core** — corruption in physical form, dropped from Glitch sets
20. **Compaction Heart** — drops from cleared compaction portals, 1 per portal

## Recipes (85 total)

### Module recipes (30)
- 8 Compiler modules (Pattern Lock, Recompile, Logic Bomb, etc.)
  Each requires 2-5 materials from common + uncommon tiers, plus 1 rare for late-game ones
- 8 Daemon modules (similar costing)
- 8 Kernel modules (similar costing)
- 6 Universal modules (cheaper, common materials)

### Prompt recipes (20)
Consumables — buffs, healing, utility. All craftable at the Lab.
- Healing Prompt (50 HP) — 2 Patch + 1 Bit Fragment
- Greater Healing Prompt (150 HP) — 3 Patch + 2 Memory Glass
- Compute Surge — 2 Wire + 1 Cache Crystal
- Damage Boost (30s +25%) — 3 Bit Fragment + 1 Quantum Shard
- ...15 more

### Chip recipes (15)
Stat-boosting chips that go in equipment slots. Crafted at the Forge.
- Power Chip (+5% damage) — 2 Wire + 1 Bit Fragment
- Vitality Chip (+10 HP) — 2 Patch + 1 Cache Crystal
- ...13 more

### Protocol recipes (10)
Passive abilities, crafted at the Compiler station.
- "Auto-Heal" protocol — 5 Memory Glass + 2 Pure Code
- "Loot Magnet" protocol — 3 Algorithm Stone + 1 Quantum Shard
- ...8 more

### Cosmetic recipes (10)
Dye colors, outfit pieces, decoration items. Crafted at the Loom.
- "Crimson Dye" — 2 Patch + 1 Voidsteel
- "Compiler Boots" — 5 Compiled Steel + 3 Dyed Thread
- ...8 more

## Recipe discovery

Recipes are NOT all available from the start. Discovery sources:

1. **Starter set:** ~20 basic recipes available immediately
2. **Drop discovery:** killing certain enemies drops "recipe scroll" items
3. **NPC dialogue:** raising NPC affinity unlocks their craft recipes
4. **Quest reward:** main story quests grant 5+ recipe unlocks
5. **Exploration:** secret rooms in dungeons hide rare recipe scrolls

Total reachable recipes scale roughly with player progression — by iteration
6, ~70/85 recipes should be accessible.

## Crafting flow

1. Player approaches crafting station, presses interact
2. Station UI opens showing all known recipes for that station type
3. Player filters/searches for desired recipe
4. UI shows ingredients required + ingredients in inventory
5. If sufficient: "Craft" button enabled
6. Click craft → 2-second animation + VFX
7. Item appears in inventory, materials are deducted
8. Crit chance for bonus output (e.g. 2 items instead of 1) at higher station tiers

## Crafting failures

To keep things forgiving but interesting:
- **Common/Uncommon recipes:** never fail
- **Rare recipes:** 5% fail chance, refunds 50% materials
- **Legendary recipes:** 15% fail chance, refunds 25% materials
- Failures show a unique VFX (smoke + sad chime)
- Each failure increases the next attempt's success by 10% ("focused crafting")

## Material gathering

### From enemies
- Common materials: any enemy on death
- Uncommon: elite enemies only
- Rare: bosses and rare spawns
- Legendary: scripted drops (story flags)

### From environment
- **Ore deposits** in dungeons — interact with pickaxe (any tool)
- **Wood/herb nodes** in wilderness — interact with hand
- **Crystal nodes** in vaults — interact with ability cast
- **Salvage piles** in town — daily refresh, free

### From fishing
- Fishing spots in town Docks — variable yields, see Epic 35
- Some materials only obtainable via fishing

## Save data

- Known recipes: list of recipe_ids
- Discovered materials: tracking which have been seen for the bestiary
- Station tier per station (1, 2, or 3)
- Craft history (for achievements)

## Achievements

- "First Craft" — craft any item
- "Master Smith" — craft 50 items
- "Grand Compiler" — discover all 85 recipes
- "Legendary Hands" — craft a legendary item
- "Stockpile" — collect 100 of any material
- "Self-Made" — clear iteration 3 using only crafted gear

## Files

- `_bmad-output/crafting/crafting_bible.md` — this file
- `scripts/items/material_item.gd` — material resource
- `scripts/resources/recipe.gd` — recipe definition
- `scripts/components/crafting_component.gd` — player crafting state
- `scripts/systems/recipe_database.gd` — all 85 recipe definitions
- `scripts/systems/material_database.gd` — all 20 material definitions
- `scripts/systems/crafting_station.gd` — station node script
- `scripts/ui/crafting_ui.gd` — station UI scene
