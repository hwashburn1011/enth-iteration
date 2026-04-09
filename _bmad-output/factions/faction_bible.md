---
name: Faction System Bible
description: 4 factions with ideologies, rep ranks, quest lines, faction-specific rewards, conflict mechanics
date: 2026-04-09
status: design + data complete
---

# Faction System Bible

## Philosophy

The 4 factions represent **competing answers** to the central question of
the simulation. The player can choose to ally with one, hop between several,
or stay neutral. Faction choice colors the late-game story without locking
you out of content — the differences are flavor + side rewards, not main
story branches.

Inspired by:
- New Vegas faction reputation system
- Hades' god boon variety
- Stardew Valley's Joja vs Community Center decision

## The 4 Factions

### 1. The Optimizers (Order)
**Ideology:** Efficiency. Minimize waste. Trust the process. The simulation
is a tool — use it well, don't fight it.

**Visual:** Geometric, blue + silver, sharp lines.
**HQ:** Workshop District, the "Process Hall"
**Representative NPC:** Vector
**Theme color:** Deep blue `#3050C8`
**Greeting:** "Efficiency above all."

**Quest line theme:** Solving puzzles, optimizing dungeon runs, completing
challenges with constraints (no items / under time limit).

**Rewards:**
- Speed-focused chips and modules
- "Optimizer's Engine" core (legendary, stat-boost when below max)
- Efficient Compiler outfit set
- Dungeon clear time bonuses

### 2. The Glitchers (Chaos)
**Ideology:** Break the rules. The simulation is a cage — every glitch is
a crack in the wall. Embrace the corruption.

**Visual:** Asymmetric, red + green, broken edges.
**HQ:** Hidden cave sub-area, the "Crack"
**Representative NPC:** Null
**Theme color:** Crimson `#C8204D`
**Greeting:** "Break it. Then break it again."

**Quest line theme:** Discovering glitches, breaking dungeon mechanics,
recruiting corrupted allies, exploring the Corrupted Wilds.

**Rewards:**
- Risk/reward modules with downsides
- "Null Pointer" core (legendary, random buffs and debuffs)
- Glitch outfit set
- Access to forbidden recipes

### 3. The Archivists (Memory)
**Ideology:** Preserve everything. Every iteration is a story. Every NPC
has history. We must remember.

**Visual:** Ornate, gold + ivory, calligraphic.
**HQ:** Town Library, the "Vault of Records"
**Representative NPC:** Index (also a town NPC)
**Theme color:** Gold `#C8A63C`
**Greeting:** "Memory is the greatest weapon."

**Quest line theme:** Lore collection, talking to NPCs across iterations,
documenting environmental storytelling, preserving the dying town.

**Rewards:**
- Knowledge-themed cosmetics
- "Archivist's Tome" core (legendary, +XP gain)
- Archive outfit set
- Lore unlocks and backstory access

### 4. The Dreamers (Hope)
**Ideology:** Imagine a better world. The simulation can become whatever
we make of it. Build, plant, decorate, sing — the future starts now.

**Visual:** Soft, pastel rainbow, organic curves.
**HQ:** Garden plot in town, the "Dreamfield"
**Representative NPC:** Render (also a town NPC)
**Theme color:** Soft violet `#9764C8`
**Greeting:** "What will we make today?"

**Quest line theme:** Town building, decoration challenges, festival
participation, NPC relationship deepening.

**Rewards:**
- Cosmetic-focused items
- "Dreamer's Heart" core (legendary, town bonuses)
- Cozy outfit set
- Decoration recipe unlocks

## Reputation system

Each faction has reputation points 0-1000. Tied to ranks:

| Rank | Name | Threshold | Unlock |
|---|---|---|---|
| 0 | Stranger | 0 | basic dialogue |
| 1 | Recruit | 100 | first faction quest, basic shop |
| 2 | Member | 250 | mid quests, faction outfit pieces |
| 3 | Officer | 500 | rare items, faction-specific recipes |
| 4 | Champion | 800 | legendary core, story branch unlock |
| 5 | Avatar | 1000 | unique cinematic, exclusive title |

## Reputation gains

- Complete a faction quest: +50-200 (by quest tier)
- Help faction NPC in dungeon: +25
- Use faction-favored items in combat: +1 per use (small)
- Festival participation: +50 if your faction hosted

## Reputation losses (conflict mechanic)

Rising in one faction lowers others **but only at higher ranks**:
- Below Member rank: no penalty
- At Member rank: +20 in faction A = -5 in two opposing factions
- At Officer rank: +20 in A = -10 in two opposing
- At Champion+: +20 in A = -15 in two opposing

The player can stay at Member level in all 4 factions if they want,
but going Champion in one means giving up Champion in the rest.

**Opposition pairs:**
- Optimizers ↔ Glitchers (order vs chaos)
- Archivists ↔ Dreamers (past vs future)

Becoming Champion of any faction does NOT lock the others to Stranger —
you can still maintain Recruit/Member levels in all of them.

## Faction merchant

Each HQ has a merchant selling:
- Tier-locked cosmetics (4 outfit pieces per faction)
- Tier-locked materials (50% discount on faction-favored materials)
- Tier-locked recipes (10 unique recipes per faction)
- Tier-locked modules (3 unique modules per faction)

## Faction quests (40 total = 10 per faction)

Each faction has 10 quests across 5 tiers (2 per tier):

### Optimizer line example
1. **Speed Audit** (T1) — clear floor 1 in under 5 minutes
2. **Resource Discipline** (T1) — beat boss without consuming items
3. **Data Pipeline** (T2) — gather 50 of any material in one run
4. **Branchless** (T2) — clear floor with only ranged attacks
5. **Throughput** (T3) — kill 100 enemies in one dungeon run
6. **Rebuild** (T3) — refactor 5 damaged items to full quality
7. **Ascendant** (T4) — defeat the Compiler in under 90 seconds
8. **Pure Code** (T4) — clear iteration with 0% wear on all gear
9. **The Algorithm** (T5) — discover and execute the perfect run
10. **Avatar of Order** (T5) — Champion-level cinematic quest

(Glitcher / Archivist / Dreamer lines follow similar 10-quest patterns)

## Faction war events

Rare random events where 2 factions clash in town:
- Player can join either side or stay neutral
- Choosing a side grants +50 rep with one, -25 with the other
- Neutral choice grants minor rep with all 4

## Story branches

At Champion rank with any single faction, the iteration 8-9 story content
gets a faction-specific epilogue:
- **Optimizer ending:** "The simulation made perfect"
- **Glitcher ending:** "The cage broken"
- **Archivist ending:** "Every story preserved"
- **Dreamer ending:** "A new world built"
- **Neutral ending:** "The middle path" (Stranger or Recruit in all 4)

## Save data

- faction_id → { reputation: int, rank: int, completed_quests: Array }
- chosen_faction (StringName, "" if neutral)
- faction_war_history: Array

## Achievements

- "Joined" — reach Recruit with any faction
- "Allied" — reach Champion with any faction
- "Diplomat" — reach Member with all 4 factions
- "Avatar" — reach Avatar tier with any faction
- "Neutral" — beat the game without exceeding Recruit in any faction

## Files

- `_bmad-output/factions/faction_bible.md` — this file
- `scripts/resources/faction_definition.gd` — faction data resource
- `scripts/systems/faction_database.gd` — all 4 factions + 40 quests
- `scripts/components/faction_component.gd` — player rep tracker
