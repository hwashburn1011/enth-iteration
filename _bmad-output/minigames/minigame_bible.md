---
name: Mini-Games & Puzzles Bible
description: 8 distinct minigames with rewards, difficulty tiers, world placement, mastery system
date: 2026-04-09
status: design + data complete
---

# Mini-Games Bible

## Philosophy

Mini-games provide **break-the-loop variety** between combat and crafting.
Each one is short (30-90 seconds), has clear win/lose state, awards
materials/lore/cosmetics, and is themed to the simulation fiction.

Inspired by:
- Stardew Valley (fishing, mining, cooking variety)
- Persona (mini-games as social activities)
- Hollow Knight (lore-locked puzzles)

## The 8 Minigames

### 1. Terminal Hacking — Sequence Puzzle
**Theme:** Match a glowing pattern of code symbols before time runs out
**Skill:** Memory + reaction
**Duration:** 20-40 seconds
**Reward:** Cache Crystal, Pure Code material, lore tablets
**Difficulty tiers:** Easy (4 symbols), Normal (6), Hard (8), Expert (10)
**Where:** Hacking terminals scattered in dungeons
**Failure:** Alarm triggers, spawns extra enemies

### 2. Memory Match — Lore Unlock
**Theme:** Reveal pairs of memory tiles to match icons
**Skill:** Pure memory
**Duration:** 60-90 seconds
**Reward:** Lore tablet (NPC backstory), Memory Glass material
**Difficulty tiers:** 4 pairs / 8 / 12 / 16
**Where:** Memory crystals in Memory Vaults biome
**Failure:** Timer runs out, no penalty

### 3. Code Compile — Logic Puzzle
**Theme:** Drag operation blocks into the right order to satisfy a target output
**Skill:** Reading + logic
**Duration:** 60-180 seconds
**Reward:** Algorithm Stone material, recipe unlock chance
**Difficulty tiers:** 3 ops / 5 / 7 / 10
**Where:** Code consoles in story rooms
**Failure:** Hint button reveals one piece (limited uses)

### 4. Data Sort — Timed Categorization
**Theme:** Sort falling data packets into the right bins (red/blue/green/etc)
**Skill:** Reaction + categorization
**Duration:** 60 seconds
**Reward:** Bit Fragment, Wire materials by score
**Difficulty tiers:** 3 bins / 4 / 5 / 6
**Where:** Sorting terminals in Server Room biome
**Failure:** Misses count against score, threshold to win

### 5. Fishing — Rhythm Balance (already shipped Epic 35)
**Theme:** Hold the catch zone over the fish icon for cumulative seconds
**Skill:** Timing + reaction
**Duration:** 20-60 seconds per catch
**Reward:** Fish + linked materials (drops vary by fish rarity)
**Difficulty tiers:** Calm / Erratic / Sinker / Dasher (fish behavior)
**Where:** Fishing spots in town Docks + wilderness
**Failure:** Fish escapes, no penalty

### 6. Cooking — Resource Management
**Theme:** Add ingredients to a pot in the right order, watch heat, stir at intervals
**Skill:** Multitasking + timing
**Duration:** 60-120 seconds
**Reward:** Cooked food (better than raw crops), recipe discovery
**Difficulty tiers:** 2 ingredients / 3 / 4 / 5
**Where:** Cooking station in town Cache Tavern
**Failure:** Burnt food, partial ingredient refund

### 7. Lockpicking — Precision Click
**Theme:** Stop a moving cursor inside narrow target zones (1-3 zones per lock)
**Skill:** Click timing
**Duration:** 10-30 seconds per lock
**Reward:** Locked container contents (usually gold + 1 random item)
**Difficulty tiers:** Wide zone / Narrow / Very Narrow / Moving zone
**Where:** Locked containers in dungeons + secret rooms
**Failure:** Lock break (1 attempt per lock)

### 8. Music Sync — Rhythm Match
**Theme:** Press correct keys in time with a scrolling note track
**Skill:** Rhythm
**Duration:** 60-180 seconds (one song)
**Reward:** NPC affinity bonus (Sync NPC), music tracks for jukebox
**Difficulty tiers:** Easy / Normal / Hard / Master
**Where:** Music station in Sync's lounge
**Failure:** Score below threshold, can retry instantly

## Difficulty tiers

Every minigame has 4 tiers. Higher tiers = better rewards:
- **Easy:** baseline reward
- **Normal:** ×1.5 reward
- **Hard:** ×2.0 reward + chance for rare drop
- **Expert:** ×3.0 reward + guaranteed rare drop

Player must complete a tier to unlock the next.

## Mastery system

Each minigame has a "Mastery Level" (1-10) that goes up with successful
completions. Mastery levels unlock:
- Level 3: practice mode (no penalty, no reward)
- Level 5: cosmetic unlock (minigame-themed decoration)
- Level 8: title ("Master Hacker", etc)
- Level 10: hidden quest unlock + legendary reward

## Statistics tracker

Per-minigame stats tracked:
- Total attempts
- Success rate
- Best time / score
- Mastery level
- Streak (consecutive wins)

## Save data

- minigame_id → { attempts: int, successes: int, best_score: int, mastery_level: int, streak: int, current_difficulty: int }
- minigame_unlocked: Array[StringName]

## Achievements

- "First Mastery" — reach mastery level 1 in any minigame
- "Master of All" — reach mastery level 5 in all 8 minigames
- "Perfectionist" — complete a minigame on Expert without failure
- "Streaker" — 10 consecutive wins on any minigame
- "Polymath" — complete every minigame at Hard or higher

## Files

- `_bmad-output/minigames/minigame_bible.md` — this file
- `scripts/systems/minigame_database.gd` — all 8 minigame metadata
- `scripts/components/minigame_component.gd` — player progress + mastery
- `scripts/systems/minigames/terminal_hacking.gd` — minigame 1
- `scripts/systems/minigames/memory_match.gd` — minigame 2
- `scripts/systems/minigames/code_compile.gd` — minigame 3
- `scripts/systems/minigames/data_sort.gd` — minigame 4
- `scripts/systems/minigames/cooking.gd` — minigame 6
- `scripts/systems/minigames/lockpicking.gd` — minigame 7
- `scripts/systems/minigames/music_sync.gd` — minigame 8
