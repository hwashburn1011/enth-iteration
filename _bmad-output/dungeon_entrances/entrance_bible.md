---
name: Multiple Dungeon Entrances Bible
description: 4 dungeon portals with thematic identity, unlock conditions, biome selection, clear tracking
date: 2026-04-09
status: design + system complete; portal monuments + VFX deferred to Blender
---

# Dungeon Entrances Bible

## Philosophy

The 4 dungeon biomes need **distinct, memorable entrances** that telegraph
their identity before the player enters. Each portal feels like a different
threshold:

- **Server Room** — cold blue tech, cables, hum
- **Memory Vaults** — gold archaic, sealed doors, choral hum
- **Corrupted Wilds** — organic + glitched, pulsing roots
- **Final Vault** — locked, mysterious, story-gated

Inspired by:
- Hades' chamber entrances (each with unique presentation)
- Dark Souls bonfires (a clear "save and travel here" marker)
- Stardew Valley's mine entrance (consistent in-world location)

## The 4 Entrances

### 1. Server Room Portal
**Location:** Wilderness clearing east of town, beyond the workshop district
**Visual theme:** Dark monolith with blue cable lights, low hum SFX
**Unlock:** From start of game (iteration 1)
**Difficulty:** ★ → ★★★★★ (5 floors)
**Recommended level:** 1+
**Lore plaque:** "All processes begin here. All processes return."

### 2. Memory Vaults Portal
**Location:** Mirror Lake side, accessible via wilderness path
**Visual theme:** Gold archway with sealed crystal door, choral whispers
**Unlock:** Iteration 2 main quest
**Difficulty:** ★★ → ★★★★★ (5 floors)
**Recommended level:** 8+
**Lore plaque:** "What the system forgets, the vault remembers."

### 3. Corrupted Wilds Portal
**Location:** Hidden cave area, deeper wilderness
**Visual theme:** Organic + digital fusion, pulsing roots, sickly green glow
**Unlock:** Iteration 3 main quest after meeting first glitch enemy
**Difficulty:** ★★★ → ★★★★★ (5 floors)
**Recommended level:** 15+
**Lore plaque:** "Where the rot meets the code."

### 4. Final Vault Portal
**Location:** Town center, hidden until story-revealed
**Visual theme:** Locked obsidian door with shifting glyphs
**Unlock:** Iteration 8 main quest
**Difficulty:** ★★★★★ (final boss + 5 floors)
**Recommended level:** 30+
**Lore plaque:** "The final question. The final answer."

## Selection UI

Player approaches a portal → interact prompt appears → confirm dialog shows:
- Biome name + lore plaque
- Recommended level + difficulty stars
- Cleared count tracker
- Boss defeated trophy (if applicable)
- Currently equipped class + ult
- "Enter" / "Cancel" buttons

Alternative: open the **Dungeon Selection Map** from town to see all 4
entrances at once with their unlock states.

## Daily-bonus rotating biome

Each in-game day (real time UTC, persists across sessions), one biome is
chosen as the "daily bonus" entrance. Clearing a floor in this biome grants:
- +50% XP from that run
- +25% material drops
- 1 daily token

The bonus rotates through the 4 biomes in order, with a small RNG to keep
players guessing. Visible in the dungeon selection map with a sun icon.

## Cleared count tracker

Each entrance tracks:
- `total_clears` — how many times the player has cleared this biome
- `boss_defeats` — how many times the biome's boss has been killed
- `best_clear_time_seconds` — fastest run for the leaderboard
- `last_cleared_iteration` — story flag for once-per-iteration rewards

## Story-locked entrances

Entrances 2-4 are **hidden by default**:
- Server Room: visible from start, walkable approach path exists
- Memory Vaults: revealed at iteration 2, approach path appears in wilderness
- Corrupted Wilds: revealed at iteration 3, hidden cave entrance opens
- Final Vault: revealed at iteration 8, town center stones rearrange

Each reveal triggers a small in-engine cinematic (handled by Epic 49).

## Save data

- discovered_entrances: Array[StringName]
- entrance_clear_counts: { entrance_id → int }
- entrance_boss_defeats: { entrance_id → int }
- entrance_best_times: { entrance_id → int seconds }
- daily_bonus_biome: StringName
- last_daily_bonus_date: String (YYYY-MM-DD)

## Achievements

- "Threshold" — discover any dungeon entrance
- "Open All Doors" — discover all 4 entrances
- "First Clear" — clear any biome floor 5
- "Biome Master" — clear all 4 biomes' floor 5
- "Speedrunner" — clear floor 5 in under 10 minutes

## Files

- `_bmad-output/dungeon_entrances/entrance_bible.md` — this file
- `scripts/systems/dungeon_entrance_database.gd` — 4 entrance definitions
- `scripts/components/dungeon_entrance_node.gd` — interactable entrance scene component
- `scripts/autoloads/dungeon_entrance_manager.gd` — global entrance state + daily bonus
- `scripts/ui/dungeon_selection_ui.gd` — portal selection screen
