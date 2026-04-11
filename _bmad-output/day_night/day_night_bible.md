---
name: Day/Night Cycle Bible
description: 24-minute real-time day, 4 time-of-day phases, NPC schedules, time-locked content
date: 2026-04-09
status: design + system complete; lighting hookup pending in-engine validation
---

# Day/Night Cycle Bible

## Philosophy

Time of day is the **breath of the world**. NPCs sleep at night, the
market opens at dawn, certain enemies only spawn under moonlight, certain
fish only bite at dusk. The cycle gives the player rhythm and a reason
to return at different times.

Inspired by:
- Stardew Valley (NPC schedules + farming clock)
- Majora's Mask (hour-by-hour scripting)
- The Long Dark (hard time pressure)

Enth is closer to Stardew — time is meaningful but never punishing.
There's no failing because time ran out.

## Time scale

**24 in-game minutes = 1 in-game day**
- Each in-game hour = 1 real minute
- Player can pause time in town (no cost) or sleep to skip
- Combat freezes the clock (no Cinderella's pumpkin moments)
- Dungeons run on real time but with reduced clock speed (3x slower)

## 4 Time-of-day phases

| Phase | In-game hours | Real seconds | Sun angle | Mood |
|---|---|---|---|---|
| **Dawn** | 5:00-8:00 | 180s | 10° | hopeful, golden |
| **Day** | 8:00-18:00 | 600s | 50° | active, warm |
| **Dusk** | 18:00-21:00 | 180s | 5° | wistful, orange |
| **Night** | 21:00-5:00 | 480s | -45° (moon) | quiet, blue |

Total: 1440 in-game minutes = 1440 real seconds = 24 minutes.

Each phase blends smoothly into the next over the last 2 in-game minutes
of the phase, so there's no abrupt jump.

## Skybox interpolation

The skybox uses 5 calibrated colors per phase (horizon top + horizon bottom
+ ground + sun color + moon color) and tweens between them based on the
current normalized time of the phase.

## NPC schedules

Each NPC has a schedule with stops at different in-game hours:
```
Pixel:
  06:00 → wake up at home
  07:00 → walk to shop
  08:00-18:00 → at shop
  18:30 → walk to tavern
  19:00-22:00 → at tavern
  22:30 → walk home
  23:00 → sleep
```

The NPCScheduleController autoload manages all 12 NPCs and ticks their
positions on the world clock.

## Enemy spawn variation

Some enemies are time-of-day exclusive:
- **Day-only:** Pixel Daemon (basic)
- **Night-only:** Memory Owl (passive prey), Crystal Wolf (hunter), Voidshark (combat)
- **Twilight-only:** Quantum Crab (rare)

Spawning systems query the DayNightController for the current phase.

## Time-of-day buffs

The player gets subtle buffs based on the time:
- **Dawn:** +10% XP gain (starting strong)
- **Day:** normal
- **Dusk:** +10% gold from drops (golden hour)
- **Night:** +10% crit chance (under cover of darkness)

These are gentle nudges, not gameplay-defining.

## Sleep interactions

Two sleep options at the player home:
- **Sleep till morning** — skips to 06:00 the next day, no penalty
- **Sleep till night** — skips to 21:00 same day, no penalty

Both regen HP/compute fully + advance the in-game day counter for daily
quest reset purposes.

## Time-locked content

Some game elements only appear at specific times:
- **Sage's Goldfish** — only catchable at dawn
- **Memorial visit** — only meaningful between dusk and dawn
- **Glitch storm event** — only triggers at night
- **Daily challenge reset** — at UTC midnight (real time, not in-game)

## UI clock display

Top-left of HUD: a small clock showing in-game hour + day counter.
- Sun/moon icon based on phase
- "Day 12, 14:30" format
- Hover to see remaining time until next phase

Player can disable the clock from accessibility settings if it feels
intrusive.

## Save data

- current_in_game_minute: float (0-1439)
- current_day: int
- last_sleep_day: int
- time_paused: bool

## Achievements

- "Night Owl" — be active during 5 nights
- "Dawn Patrol" — catch a Sage's Goldfish at dawn
- "Insomniac" — go 3 in-game days without sleeping
- "Schedule Keeper" — visit each NPC at their scheduled location

## Files

- `_bmad-output/day_night/day_night_bible.md` — this file
- `scripts/autoloads/day_night_controller.gd` — global clock + phase tracking
- `scripts/systems/npc_schedule.gd` — per-NPC schedule data + lookup
- `scripts/ui/clock_display.gd` — HUD clock widget
- `scripts/systems/sleep_interaction.gd` — sleep till morning/night handler
