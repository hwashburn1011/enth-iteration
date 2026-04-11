---
name: Pet System Bible
description: 8 pets with passive bonuses, hatching, happiness, evolution, hutch town area
date: 2026-04-09
status: design + data complete
---

# Pet System Bible

## Philosophy

Pets are **persistent passive companions** — smaller and simpler than the
companions in Epic 40. They follow you everywhere (town and dungeons), have
no AI combat behavior, but grant **stat bonuses** that scale with their
happiness level.

Inspired by:
- World of Warcraft battle pets (collection appeal)
- Stardew Valley dog/cat (affection-based bonuses)
- Pokemon Egg hatching (anticipation loop)

The player can have **1 active pet at a time** but can collect all 8.
Pets are stored in the **Pet Hutch** building in the town Residential
District. Switching pets is free at the hutch.

## Pet acquisition

3 sources:
1. **Egg drops** from elite enemies and bosses (random, common eggs)
2. **NPC gifts** at high affinity (specific guaranteed pets)
3. **Quest rewards** for hidden / story quests (legendary pets)

Eggs go to the inventory and **hatch over real-time** based on type:
- Common eggs: 5 minutes
- Uncommon: 15 minutes
- Rare: 30 minutes
- Legendary: 60 minutes

Eggs hatch even when the game is paused. The Sage's Pond is the hatching
incubator (visit to speed up hatching by 50%).

## Happiness system

Each pet has a happiness value 0-100:
- **Petting interaction:** +5 happiness, max 1/day
- **Feeding treats:** +10 happiness per treat, max 3/day
- **Carrying in dungeon (return alive):** +15 happiness
- **Daily decay:** -2 happiness if not interacted with

Happiness tiers grant escalating stat bonuses:
| Range | Tier | Stat boost |
|---|---|---|
| 0-25 | Sad | None |
| 26-50 | Content | small bonus |
| 51-75 | Happy | medium bonus |
| 76-100 | Devoted | large bonus + secondary |

## The 8 Pets

### 1. Data Sprite — Caster
**Type:** Floating wisp, magical / mystic
**Acquisition:** Hatches from common egg (Server Room boss drop)
**Stat bonus:** +max compute (5/10/15/20 by tier), Devoted: +10% ability damage
**Personality:** Curious, playful, hovers around Globbler's head
**Ability proc:** 5% chance on cast to refund 50% compute

### 2. Patch Dog — Loyal Melee
**Type:** Quadruped fluffy creature, dog-equivalent
**Acquisition:** Gift from Harvest at Friend tier
**Stat bonus:** +HP (10/20/30/40 by tier), Devoted: +5% defense
**Personality:** Loyal, barks at enemies, sits next to Globbler
**Ability proc:** Bark when enemies appear, 10% taunt for 1 second

### 3. Bit Cat — Stealthy
**Type:** Quadruped sleek, cat-equivalent
**Acquisition:** Common egg (Memory Vaults drop)
**Stat bonus:** +crit chance (1/2/3/4% by tier), Devoted: +20% movement speed
**Personality:** Aloof, naps a lot, occasionally walks ahead
**Ability proc:** First strike from stealth: +25% damage

### 4. Bug Buddy — Corrupted
**Type:** Glitching insectoid
**Acquisition:** Quest reward from Glitcher faction
**Stat bonus:** +damage (3/6/9/12% by tier), Devoted: +15% to corrupted enemies
**Personality:** Twitchy, glitches in/out of view
**Ability proc:** 5% chance on hit to apply Glitch debuff (target attacks self)

### 5. Memory Owl — Intelligent
**Type:** Floating bird with optical sensors
**Acquisition:** Gift from Index at Confidant tier
**Stat bonus:** +XP gain (5/10/15/20% by tier), Devoted: +1 affinity per gift
**Personality:** Wise, occasionally hoots lore tidbits
**Ability proc:** Reveals 1 hidden chest per dungeon

### 6. Cache Mouse — Gathering
**Type:** Small scurrying mouse
**Acquisition:** Common egg (drop from Forge enemies)
**Stat bonus:** +loot magnetism (1m/2m/3m/4m radius), Devoted: +25% material drop chance
**Personality:** Skittish, scurries to grab dropped items
**Ability proc:** 10% chance to find a free common material per kill

### 7. Echo Bird — Flying
**Type:** Bird with iteration-echo trail
**Acquisition:** Hidden quest (Iteration Memorial)
**Stat bonus:** +1/2/3/4 dash charges, Devoted: +1s dash invuln
**Personality:** Distant, soars above, lands occasionally
**Ability proc:** 5% chance on dash to refund cooldown

### 8. Crystal Fox — Rare Legendary
**Type:** Crystalline 4-legged creature
**Acquisition:** Boss reward from final iteration boss
**Stat bonus:** +all stats (1/2/3/4% by tier), Devoted: chance to revive on death
**Personality:** Majestic, glows softly, walks gracefully beside Globbler
**Ability proc:** Once per dungeon, prevents lethal damage and grants 3s invuln

## Evolution variants

After hatching, pets stay in their base form. At max happiness (Devoted)
**and** completing their pet quest, they unlock an "Evolved" cosmetic
form with brighter colors and a particle aura. Same stats, just visual.

## Pet hutch (town building)

Located in the Residential District. Contains:
- **Hatching pedestal:** drop egg here to start hatch timer
- **Pet inventory racks:** view all owned pets
- **Pet bed:** active pet rests here when player is in dungeons
- **Treat dispenser:** spend compute crystals to buy treats
- **Bond display:** shows happiness levels of all pets
- **Renaming station:** customize pet names

## Save data

- pet_id → { owned: bool, happiness: int, name: String, last_pet_day: int,
  last_fed_day: int, evolved: bool, completed_quest: bool }
- active_pet_id: StringName ("" if none)
- hatching_eggs: Array of { egg_id, hatch_at_unix_time }

## Achievements

- "First Friend" — hatch your first pet
- "Pet Collector" — own 4 pets
- "Master Trainer" — own all 8 pets
- "Devoted" — reach max happiness with any pet
- "Evolutionist" — unlock the evolved form of any pet
- "True Bond" — reach Devoted with all 8 pets

## Files

- `_bmad-output/pets/pet_bible.md` — this file
- `scripts/systems/pet_database.gd` — all 8 pet definitions
- `scripts/components/pet_component.gd` — player pet state
- `scripts/items/pet_egg_item.gd` — egg item that hatches over time
