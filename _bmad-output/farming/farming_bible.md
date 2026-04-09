---
name: Farming & Gathering Bible
description: 20 crops, 15 fish, forage system, fishing minigame, gathering skill progression
date: 2026-04-09
status: design + data complete
---

# Farming & Gathering Bible

## Philosophy

Farming and gathering are **opt-in cozy systems** that:
- Generate materials needed for crafting (Epic 34)
- Reward time investment without demanding it
- Give the player something to do in town between dungeon runs
- Tie into the day/night cycle (Epic 26) and weather (Epic 27)

If you skip farming entirely, you can still beat the game — you just buy
materials from shops or grind them from drops. Farming makes the
crafting/cooking economy 30-50% cheaper to maintain.

## Farm plots

Each plot is a 1×1 tile in the farm patch areas (town + greenhouse).
States:
1. **Untilled** — barren ground, can be tilled
2. **Tilled** — ready for seed
3. **Planted** — seed dropped, growth timer started
4. **Watered** — boosts growth speed by 30%
5. **Mature** — ready to harvest
6. **Withered** — neglected for 3 in-game days, must be re-tilled

Growth time = `crop.base_growth_days × (0.7 if watered else 1.0)`. Most
crops mature in 2-4 in-game days = 8-16 real minutes.

## Tools

Bound to interaction context — using "interact" on a plot fires the right
tool automatically:

| Tool | Used for | Tiers |
|---|---|---|
| Hoe | Tilling untilled ground | basic / iron / quantum |
| Watering Can | Watering planted plots | basic / large / cloud |
| Scythe | Harvesting mature crops | basic / iron / quantum |
| Fishing Rod | Fishing at fishing spots | basic / glassrod / void |

Tool tiers reduce action time and durability cost. Upgrade at the Forge
crafting station.

## Crops (20)

### Common (8) — basic seed shop stock
1. **Bytewheat** — 2 days, → flour for cooking + Bit Fragment material
2. **Datacarrot** — 2 days, → +5 max HP food
3. **Cachepea** — 2 days, → +5 compute food
4. **Pingberry** — 3 days, → +5% speed buff (30s)
5. **Patchcotton** — 3 days, → Patch material
6. **Logleaf** — 2 days, → Bytewood material
7. **Clockmint** — 3 days, → cooldown reduction buff
8. **Sleeppoppy** — 3 days, → restores compute over time

### Uncommon (6) — discovered through quests
9. **Refactorradish** — 4 days, → +10% damage 60s
10. **Threadflax** — 4 days, → Dyed Thread material
11. **Glowmoss** — 4 days, → Memory Glass material
12. **Stardust Sprout** — 5 days, → unique cooking ingredient
13. **Iron Onion** — 4 days, → +20% defense 60s
14. **Pixel Pumpkin** — 5 days, → seasonal decoration item

### Rare (4) — greenhouse only
15. **Sage's Mint** — 6 days, → temporary affinity boost with NPCs
16. **Quantum Bean** — 6 days, → restores 100 HP instantly
17. **Iteration Lily** — 7 days, → reveals iteration secrets when consumed
18. **Voidpepper** — 6 days, → Voidsteel material chance

### Legendary (2) — story-locked
19. **Heart Fruit** — 10 days, → Sage's Tear material chance
20. **Compaction Rose** — 10 days, → Compaction Heart fragment

## Seed economy

- Common seeds: 5 compute crystals each from Harvest NPC
- Uncommon: 25 cc, locked behind affinity 2 with Harvest
- Rare: 100 cc, only at greenhouse, affinity 4 with Harvest
- Legendary: not for sale — found in dungeons or quest rewards
- Crops drop 1-3 of their seed back when harvested (no infinite multiplication on rares)

## Fertilizer

Optional boost item crafted at the Lab from Patch + crop scraps:
- **Basic Fertilizer:** -30% growth time
- **Quality Fertilizer:** -30% growth time + 1 quality tier (chance for "Silver" or "Gold" version of crop)
- **Glitch Fertilizer:** doubled output, but 20% wither chance

## Crop quality tiers

Most crops harvest at **Standard** quality. With Quality Fertilizer or
high gathering skill, crops can reach:
- **Silver** (×1.5 stat values)
- **Gold** (×2.0 stat values, can be used in legendary recipes)

## Orchard

Permanent fruit trees planted in dedicated orchard plots. Trees take
15-20 in-game days to mature, then produce 3-5 fruits every 3 days
forever. Fruits include:
- Bytefruit (basic)
- Sageberry (rare)
- Iteration Apple (legendary, story-gated)

## Wild foraging

Spawns in the wilderness zone (Epic 23) at gather nodes that respawn
every in-game day:
- **Wild herbs** → various crop drops
- **Mushroom clusters** → cooking ingredients
- **Crystal nodes** → Cache Crystal / Memory Glass
- **Fallen wood** → Bytewood

## Fishing

15 fish types caught at fishing spots in town Docks + wilderness river.
Each spot has its own fish pool weighted by rarity and time of day.

### Fish list
1. **Bit Minnow** (common, day) — Bit Fragment + small heal food
2. **Wire Eel** (common, night) — Wire material
3. **Cache Carp** (common, day) — Cache Crystal
4. **Datafin** (common, dawn/dusk) — Bit Fragment
5. **Patchsalmon** (common, day) — Patch material
6. **Memory Trout** (uncommon, day) — Memory Glass
7. **Server Squid** (uncommon, night) — Server Coil
8. **Quantum Crab** (uncommon, dusk) — Quantum Shard chance
9. **Algorithm Octopus** (uncommon, night) — Algorithm Stone
10. **Voidshark** (rare, night, storm only) — Voidsteel
11. **Dream Whale** (rare, full moon only) — Dream Silk
12. **Compiled Tuna** (rare, day, sunny only) — Compiled Steel chance
13. **Iteration Pike** (rare, dawn) — Iteration Echo chance
14. **Sage's Goldfish** (legendary, dawn, only at sage's pond) — Sage's Tear chance
15. **The User's Salmon** (legendary, story unlock) — Once-per-iteration

### Fishing minigame

Simple bar-balancing rhythm game (Stardew Valley style):
1. Cast → wait for bite (random 2-8 seconds)
2. Bite indicator appears → press interact within 1 second to hook
3. Vertical bar appears with fish icon moving up/down inside
4. Player holds a "catch zone" indicator over the fish icon for 5 cumulative seconds
5. Different fish have different escape behaviors (calm/erratic/sinker/dasher)
6. Failure on hook miss or timeout (~30 seconds)
7. Higher rod tier = larger catch zone

## Hunting

Passive wildlife in wilderness drops materials when killed:
- **Data Bunnies** → Bit Fragment + Patch
- **Pixel Deer** → Bytewood + Patchcotton
- **Crystal Wolves** → Cache Crystal + Quantum Shard
- **Memory Owls** (night only) → Memory Glass + rare drops

Hunting uses normal combat — no separate system, just a tagged enemy
group.

## Gathering skill

Each gathering action grants gathering XP:
- Tilling: 1 xp
- Watering: 1 xp
- Harvesting: 5 xp (×quality tier)
- Foraging: 3 xp
- Fishing catch: 5-15 xp (by rarity)
- Hunting kill: 10 xp

Gathering levels (separate from combat level):
- **Level 5:** +5% growth speed on all crops
- **Level 10:** Quality fertilizer effect doubled
- **Level 15:** 10% chance to harvest 2 instead of 1
- **Level 20:** Catch zone in fishing minigame +25%
- **Level 25:** Rare drops 50% more common
- **Level 30:** Legendary crops can be planted in regular plots
- **Level 50:** Title "Harvest Master" + cosmetic outfit unlock

## Save data

- Plot states: array of {position, state, crop_id, planted_at, watered_until}
- Tool tiers and durability
- Gathering skill XP + level
- Fish bestiary (which species caught at least once)
- Forage node respawn timers
- Greenhouse unlock state

## Achievements

- "First Harvest" — harvest any crop
- "Green Thumb" — harvest 100 crops
- "Diversifier" — grow all 20 crop types
- "Master Angler" — catch all 15 fish
- "Sage's Friend" — catch a Sage's Goldfish
- "Self-Sufficient" — go a full iteration without buying materials

## Files

- `_bmad-output/farming/farming_bible.md` — this file
- `scripts/items/seed_item.gd` — seed item resource
- `scripts/items/crop_item.gd` — harvested crop resource
- `scripts/systems/crop_database.gd` — all 20 crops
- `scripts/systems/fish_database.gd` — all 15 fish
- `scripts/systems/farm_plot.gd` — single plot state machine
- `scripts/components/farming_component.gd` — gathering skill XP + state
- `scripts/systems/fishing_minigame.gd` — fishing rhythm game
- `scripts/ui/farming_hud.gd` — gathering tracker UI
