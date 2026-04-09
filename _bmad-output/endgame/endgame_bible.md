---
name: Endgame Modes Bible
description: 5 endgame modes (Challenge Tower, Infinite, Boss Rush, Daily, Hardcore) with unlocks, rewards, leaderboards
date: 2026-04-09
status: design + data complete
---

# Endgame Modes Bible

## Philosophy

Endgame modes give players reasons to keep playing after the 9-iteration
story is done. Each mode targets a different motivation:

- **Challenge Tower:** mastery — push through escalating floors
- **Infinite Mode:** experimentation — try wild builds with no story constraints
- **Boss Rush:** speedrunning — race the clock against all 6 bosses
- **Daily Challenge:** competition — same seed for everyone, leaderboard
- **Hardcore:** consequence — permadeath for the bold

All modes use **separate save slots** so progression in one doesn't pollute
the others.

## Mode 1 — Challenge Tower

50 floors of escalating difficulty. Each floor = 1 short dungeon room with
a specific challenge.

**Unlock:** Complete iteration 5 main quest line
**Floors:** 50
**Floor structure:**
- Floors 1-10: standard combat with light modifiers
- Floors 11-20: heavier modifiers, mini-boss every 5 floors
- Floors 21-30: dual modifiers, elite enemies
- Floors 31-40: triple modifiers, environmental hazards
- Floors 41-49: mini-bosses every 2 floors
- Floor 50: Tower Lord boss (unique to this mode)

**Modifier examples:**
- "No prompts allowed"
- "All damage doubled (yours and theirs)"
- "Enemies have 50% lifesteal"
- "Cooldowns x1.5"
- "Compute regen disabled"

**Rewards:**
- Per-floor: 100 gold + materials scaling with floor
- Floor 10: rare cosmetic
- Floor 25: epic outfit piece
- Floor 50: legendary core "Tower Lord's Resolve"

**Leaderboard:** highest floor reached, attempts, total time

## Mode 2 — Infinite Mode

Procedurally generated endless dungeon. Each "room" is a randomly chosen
prebuilt with random enemy mix. No story, no NPCs, just combat.

**Unlock:** Complete iteration 3 main quest line
**Generation:** seeded by daily UTC timestamp + run ID
**Difficulty scaling:** +5% enemy HP/damage per room cleared
**Currency:** "Infinity Crystals" — separate from main game gold
**Shop:** between every 5 rooms, spend Infinity Crystals on temporary buffs:
- Heal +20 HP
- +10% damage for next 5 rooms
- Free random module
- Reroll next room

**Rewards (carry to main game):**
- Every 50 rooms: rare material drop
- Every 100 rooms: epic cosmetic decoration
- Best score: title + cosmetic outfit override

**Leaderboard:** rooms cleared, highest streak, total kills

## Mode 3 — Boss Rush

(Already shipped in Epic 43 boss_rush.gd)

**Unlock:** Defeat all 6 bosses in main story
**Format:** All 6 bosses back-to-back, no breaks
**Failure:** Death restarts from boss 1
**Tracking:** total time, deaths
**Rewards:** title "Boss Slayer", legendary cosmetic

## Mode 4 — Daily Challenge

A unique dungeon run with the same seed for all players each day.
Encourages comparison + community.

**Unlock:** Complete iteration 1
**Reset:** every UTC midnight
**Format:** 5-floor mini-dungeon with daily-fixed:
- Class (forced, can't pick)
- Starting modules (forced)
- Modifier(s) (random selection)
- Final boss (random from pool)

**Rewards:**
- Complete: 50 Infinity Crystals + 1 daily token
- Top 100 (local): bonus cosmetic
- Streak 7 days: weekly bonus
- Streak 30 days: monthly title

**Leaderboard:** local-only for prototype, online deferred

## Mode 5 — Hardcore Mode

The full 9-iteration story but **death = permanent save deletion**.
For experienced players who want stakes.

**Unlock:** Complete the main story once on normal
**Save:** isolated hardcore_save.json
**Death cinematic:** unique "SYSTEM FAILURE - SAVE DELETED" sequence
**Rewards:**
- Each iteration cleared in hardcore: special tag on main game save
- Full clear: legendary "Iron Will" outfit override + title

## Mode unlocks

| Mode | Unlock condition |
|---|---|
| Challenge Tower | Complete iteration 5 |
| Infinite Mode | Complete iteration 3 |
| Boss Rush | Defeat all 6 bosses |
| Daily Challenge | Complete iteration 1 |
| Hardcore | Complete main story once |

## Save isolation

Each mode has its own save slot. Player can switch freely between modes
in the menu. Progress in one mode doesn't carry to another (except for
shared cosmetic unlocks).

## Achievements

- "Tower Climber" — reach floor 25 in Challenge Tower
- "Tower Lord" — defeat the Tower Lord (floor 50)
- "Infinite" — clear 100 rooms in Infinite Mode
- "Boss Slayer" — complete Boss Rush (Epic 43)
- "Daily Devotion" — complete 30 daily challenges
- "Iron Will" — beat the game in Hardcore Mode

## Files

- `_bmad-output/endgame/endgame_bible.md` — this file
- `scripts/systems/challenge_tower.gd` — Challenge Tower controller
- `scripts/systems/infinite_mode.gd` — Infinite Mode generator
- `scripts/systems/daily_challenge.gd` — Daily Challenge generator
- `scripts/systems/hardcore_mode.gd` — Hardcore Mode save handler
- `scripts/systems/endgame_modes.gd` — global endgame mode controller
