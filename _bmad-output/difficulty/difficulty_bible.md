---
name: Difficulty & Accessibility Bible
description: 5 difficulty tiers, 30 modifiers, full accessibility settings catalog
date: 2026-04-09
status: design + data complete
---

# Difficulty & Accessibility Bible

## Philosophy

Difficulty in Enth is about **letting every player find their fit**. The
default Normal tier is the designed experience. Easy lets newer players
enjoy the story. Hard/Expert/Nightmare reward mastery with cosmetics and
titles.

Modifiers go on top of difficulty: opt-in challenges that change run
shape (e.g. "no prompts allowed"). Players can stack modifiers for greater
risk and proportionally greater reward.

## 5 Difficulty Tiers

| Tier | Name | Enemy HP | Enemy Dmg | Loot Quality | Economy | Notes |
|---|---|---|---|---|---|---|
| 0 | Easy | 0.7× | 0.6× | 1.2× | 1.5× | Forgiving — story-focused |
| 1 | Normal | 1.0× | 1.0× | 1.0× | 1.0× | Designed experience |
| 2 | Hard | 1.4× | 1.3× | 1.1× | 0.9× | Mastery start |
| 3 | Expert | 1.8× | 1.6× | 1.25× | 0.8× | Tight resource management |
| 4 | Nightmare | 2.5× | 2.0× | 1.5× | 0.7× | Death Wish equivalent |

**Switching:** difficulty can be changed mid-game from the pause menu, but
**only downward** (Hard → Normal is fine, Normal → Hard is locked between
iterations to prevent cheese). Players who finish on Hard+ get a tag on
their save file.

**Achievements scale with difficulty.** Beating boss X on Easy gives the
basic achievement. Beating it on Nightmare gives the title achievement.

## 30 Modifiers

Modifiers are opt-in challenges selected at dungeon entry. They stack —
each adds its reward bonus to the run.

### Negative (player handicap) — 20 modifiers

1. **No Prompts** — Cannot use prompt items. +25% reward
2. **Glass Cannon** — All damage doubled (player + enemies). +30% reward
3. **One Shot** — One HP. +200% reward
4. **No Dash** — Dash disabled. +30% reward
5. **No Modules** — Only basic attacks allowed. +50% reward
6. **No Compute** — Compute regen disabled, max compute 50%. +25% reward
7. **No Healing** — Healing items have no effect. +35% reward
8. **No Pickups** — Items don't drop. +50% reward
9. **Time Limit** — Floor must be cleared in 5 minutes. +20% reward
10. **No Companions** — Companion slot disabled. +20% reward
11. **No Pets** — Pet slot disabled. +10% reward
12. **Half Stats** — Player stats reduced 50%. +30% reward
13. **No Cooldown Reduction** — All cooldowns ×2. +25% reward
14. **Friendly Fire** — Companion abilities damage you. +15% reward
15. **Visible Shadows** — Enemies visible only in line of sight. +20% reward
16. **Slow Movement** — Move speed -30%. +15% reward
17. **Frail Equipment** — Equipment durability ×3 loss rate. +15% reward
18. **No Status Resist** — All status durations ×2. +10% reward
19. **Locked Doors** — Doors require lockpicking. +10% reward
20. **Reflect Damage** — Boss reflects 25% of damage to you. +20% reward (boss fights only)

### Positive (enemy handicap) — 5 modifiers

These don't grant rewards — they're for accessibility:
21. **Rookie Mode** — Enemies have 50% HP
22. **Defensive Aura** — Player takes 25% less damage
23. **Generous Loot** — All drops doubled
24. **Quick Recharge** — Cooldowns ×0.7
25. **Resurrection** — Revive once on death

### Mixed (random / chaos) — 5 modifiers

26. **Random Modifiers** — A new random modifier each floor. +30% reward
27. **Mystery Loot** — All drops are random tier. +15% reward
28. **Lottery Stats** — Stats randomized at floor start. +25% reward
29. **Modifier Roulette** — Modifier swaps every 30 seconds. +50% reward
30. **The Compiler's Dare** — Random buff and random debuff each floor. +40% reward

## Modifier stacking rules

- Up to **5 negative modifiers** can be active at once
- Positive (accessibility) modifiers don't count toward the limit
- Stacking 3+ negatives gives **escalating bonus** (×1.1 for 3, ×1.25 for 4, ×1.5 for 5)
- Some modifiers are mutually exclusive (e.g. "No Modules" + "No Cooldown Reduction" — pointless)

## Reward bonuses

When modifiers are active, reward bonuses apply to:
- XP gain
- Gold drops
- Material drops
- Cosmetic drop chance
- Faction reputation gain

The total bonus is the **sum of individual modifier bonuses ×stacking multiplier**.

## Achievements

- **"Complete on Easy"** — finish main story on Easy
- **"Complete on Normal"** — finish main story on Normal
- **"Complete on Hard"** — finish main story on Hard
- **"Complete on Expert"** — finish main story on Expert
- **"Complete on Nightmare"** — finish main story on Nightmare
- **"Modifier Maverick"** — clear a dungeon with 5+ negative modifiers
- **"Iron Will"** — clear an iteration with 5 stacked modifiers
- **"Death Wish"** — clear Boss Rush with all negative modifiers

# Accessibility

Enth supports a comprehensive accessibility menu accessible from the main
menu and pause menu. All settings can be changed mid-game.

## Visual

- **Colorblind modes:** None / Protanopia / Deuteranopia / Tritanopia
  - Re-tints HP bars, status effects, faction colors, damage numbers
- **High contrast UI** — toggle for thicker borders + bigger fonts
- **UI scale** — 0.8× / 1.0× / 1.2× / 1.5× / 2.0×
- **HUD opacity** — 0% (off) to 100%
- **Screen shake** — 0% / 25% / 50% / 75% / 100%
- **Damage numbers** — Off / Numbers only / Numbers + crit highlights
- **Hit-stop intensity** — 0% / 25% / 50% / 75% / 100% / 150%

## Audio

- **Master volume** — 0-100%
- **Music volume** — 0-100%
- **SFX volume** — 0-100%
- **Voice/grunt volume** — 0-100%
- **Subtitles** — On/Off
- **Subtitle size** — Small / Medium / Large / XL
- **Subtitle background** — None / Outline / Box

## Input

- **Aim assist** — Off / Light / Medium / Strong (controller only)
- **Auto-aim toggle** — Off / Lock-on hold / Lock-on toggle
- **Slow time on aim** — Off / 50% / 25% (slows time when aiming abilities)
- **Input rebinding** — Full keyboard + controller remap
- **Hold-to-toggle** — Replace hold inputs with toggle inputs

## Gameplay

- **Difficulty** — Easy / Normal / Hard / Expert / Nightmare (see above)
- **Permanent positive modifiers** — apply Rookie Mode / Defensive Aura / etc. across all runs
- **Skip cinematics** — Off / On
- **Auto-pause on focus loss** — Off / On
- **Tutorial reminders** — Off / Once / Always

## Save/load

All settings saved to `user://settings.cfg`. Loaded at game start.

## Files

- `_bmad-output/difficulty/difficulty_bible.md` — this file
- `scripts/systems/difficulty_database.gd` — 5 difficulty tiers + 30 modifiers
- `scripts/components/difficulty_component.gd` — active difficulty + modifiers
- `scripts/autoloads/accessibility_settings.gd` — global accessibility autoload
