---
name: Class System Design Bible
description: 3 player classes — Compiler, Daemon, Kernel — with stat baselines, signature abilities, progression, and balance philosophy
date: 2026-04-09
status: design-complete
---

# Enth: Iteration — Class System Bible

## Philosophy

**Three classes, distinct identities, equal power level.** Each class plays the
same core combat loop but with a different *feel*: weight, range, tempo, and
risk tolerance. No class is "the best" — they unlock different routes through
the same content.

The class is chosen at character creation (Iteration 1) and can be **respec'd**
freely from Iteration 3 onward at the Reflection NPC in the town Workshop.

## Stat baselines (level 1)

| Stat        | Compiler | Daemon | Kernel |
|-------------|----------|--------|--------|
| Max HP      | 100      | 75     | 140    |
| Max Compute | 100      | 120    | 80     |
| Move Speed  | 4.5 m/s  | 6.0 m/s| 3.8 m/s|
| Crit Chance | 8%       | 15%    | 5%     |
| Damage Mod  | 1.0×     | 1.1×   | 0.9×   |
| Defense     | 1.0×     | 0.85×  | 1.25×  |
| Dash CD     | 1.5 s    | 1.0 s  | 2.5 s  |
| Charge Time | 0.6 s    | 0.4 s  | 0.9 s  |

## Class 1 — Compiler (Balanced)

**Theme:** The disciplined craftsman. Equal parts melee and ranged. Adapts to
any situation. The "default" class for new players who haven't decided what
they want to be.

**Color tag:** deep blue + silver
**Visual variant:** outfit_compiler skin variant (slightly bluer Globbler)
**HUD theme:** clean geometric panels, blue accents
**Music sting:** rising minor 3rd, harp + synth pad

**Starting modules:**
- Data Pulse (basic ranged) — 8 compute, 12 dmg
- Energy Burst (charged AoE) — 25 compute, 35 dmg
- Pattern Lock (utility freeze) — 15 compute, freezes target 1.5s

**Signature ability — "Recompile":**
Player teleports to a marked position, leaving a damaging glyph at the original
location that detonates after 0.5s. Cooldown 8s. Combines mobility, damage,
and zoning in one button.

**Ultimate — "Logic Bomb":**
Slam the ground, creating a 3-meter expanding ring of explosive runes that
sequentially fire over 1.2s. 200 dmg total in the ring. Cooldown 60s, costs
80 compute.

**Class passive:** Every successful Pattern Lock reduces all cooldowns by 1s.

**Damage type bonus:** +15% damage to "Order" enemies (Sentinels, Compilers).

**Iteration 3 unlock:** "Subroutine" — left/right click swap between melee
and ranged stance with no animation lock.

## Class 2 — Daemon (Assassin)

**Theme:** Fast, fragile, lethal. High crit, high mobility, low margin for error.
The class for players who want to feel quick on the trigger. Punishes mistakes.

**Color tag:** crimson + black
**Visual variant:** outfit_glitch-leaning skin variant (subtle red emissive)
**HUD theme:** angular, sharp, red accents, faster animations
**Music sting:** descending tritone, distorted synth lead

**Starting modules:**
- Phase Strike (instant teleport-stab) — 15 compute, 22 dmg, 5s CD
- Backstab Combo (3-hit melee) — 6 compute per hit
- Smoke Veil (invisibility 2s) — 30 compute, 12s CD

**Signature ability — "Hunter's Mark":**
Marks an enemy for 8s. Marked enemies take +30% damage from Daemon and
auto-crit on the next hit. Cooldown 5s.

**Ultimate — "Massacre Protocol":**
Daemon enters a dash-only state for 4s, all attacks instant-kill enemies under
20% HP and refresh on hit. Cooldown 90s, costs 100 compute.

**Class passive:** First strike on an enemy deals +50% damage and applies
"Bleed" (5 dmg/sec for 4s).

**Damage type bonus:** +20% damage to "Chaos" enemies (Glitch family, Crash
Daemon).

**Iteration 3 unlock:** "Vanish" — taking lethal damage triggers automatic
Smoke Veil and 2s invulnerability. 60s cooldown.

## Class 3 — Kernel (Tank/Control)

**Theme:** Slow, heavy, immovable. The class for players who want to feel
indestructible. Trades mobility for raw stopping power.

**Color tag:** indigo + gold
**Visual variant:** outfit_kernel skin variant (chunkier silhouette overlay)
**HUD theme:** thick borders, gold accents, slower animations
**Music sting:** brass-like synth, low octave drop

**Starting modules:**
- Bulwark (defensive stance, +50% defense, can't move) — 0 compute, sustained
- Gravity Well (pull AoE) — 20 compute, pulls enemies in 4m radius, 8s CD
- Thunder Strike (slow charge, big damage) — 40 compute, 60 dmg, 3s windup

**Signature ability — "Aegis Protocol":**
Generates a force field around the Kernel and allies in 5m radius. Blocks the
next 3 incoming attacks per target. Cooldown 12s. Visual: force_field_bubble
shader with blue tint.

**Ultimate — "Overclock Reactor":**
Kernel becomes invulnerable for 5s and gains +200% damage. All defensive
cooldowns refresh on use. After the 5s, Kernel takes 30% of damage prevented
during the duration. Cooldown 120s, costs 150 compute.

**Class passive:** Damage taken below 25% HP is reduced by 50%.

**Damage type bonus:** +25% damage to bosses.

**Iteration 3 unlock:** "Counter Stance" — successful blocks trigger an
automatic 15-dmg shockwave around the Kernel.

## Progression milestones

| Level | Compiler unlock | Daemon unlock | Kernel unlock |
|-------|-----------------|---------------|---------------|
| 1     | Starting kit    | Starting kit  | Starting kit  |
| 5     | Pattern Lock+ (2 targets) | Smoke Veil+ (3s) | Bulwark+ (60% def) |
| 10    | Recompile signature | Hunter's Mark signature | Aegis signature |
| 15    | Class passive   | Class passive | Class passive |
| 20    | Damage type bonus | Damage type bonus | Damage type bonus |
| 25    | Iteration 3 unlock available | Same | Same |
| 30    | Logic Bomb ultimate | Massacre Protocol ultimate | Overclock Reactor ultimate |
| 40    | Mastery passive (auto-cast Pattern Lock on crit) | Mastery passive (Hunter's Mark refunds compute) | Mastery passive (Aegis grants 50 compute on block) |
| 50    | Title: "The Architect" | Title: "The Reaper" | Title: "The Wall" |

## Class swap rules

- **Iterations 1-2:** locked to chosen class
- **Iteration 3+:** respec at Reflection NPC for 50 compute crystals
- **Respec resets:** skill tree, no level lost
- **Loadouts:** can save 3 class loadouts (compiler/daemon/kernel) and swap
  between them via the class menu

## Balance principles

1. **Equal time-to-kill** on a level-appropriate enemy:
   Compiler ~3s, Daemon ~2s if positioning correct (5s if exposed),
   Kernel ~4s but takes 60% less damage doing it.

2. **Class identity in 3 verbs:**
   - Compiler: think → cast → repeat
   - Daemon: dash → strike → vanish
   - Kernel: stand → block → punish

3. **No "trap" choices:** every class can clear every floor. Skill differences
   show up at the boss level, not in trash mob clearing.

## Class restricted items

- **Compiler-only:** "Logic Engine" core (ability damage +20%)
- **Daemon-only:** "Shadow Cloak" cape (1s extra Smoke Veil)
- **Kernel-only:** "Anchor Plates" boots (immovable on knockback)

Class-shared items account for 90% of the loot pool. Restrictions only on
class-defining cores and one cosmetic per class.

## Achievement triggers

- "First Compiler kill" — first boss kill as Compiler
- "First Reaper kill" — first boss kill as Daemon
- "First Wall kill" — first boss kill as Kernel
- "Trinity" — clear iteration 3 with all 3 classes
- "Specialist" — reach level 50 with any class
- "Renaissance" — reach level 30 with all 3 classes
