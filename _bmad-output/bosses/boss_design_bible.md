---
name: Boss Roster Bible
description: 5 new bosses with phase designs, signature mechanics, AI patterns, arenas, music
date: 2026-04-09
status: design + AI complete
---

# Boss Roster Bible

## Philosophy

Each new boss is **a different combat puzzle**. They share the same multi-
phase structure (3 phases, increasing pressure) but each phase 1 hook is
distinct so the player has to relearn the rhythm every time.

Inspired by:
- Hades bosses (telegraphed but punishing)
- Hollow Knight bosses (spectacle without unfairness)
- Sekiro bosses (stagger windows + recovery openings)

## The 5 New Bosses (alongside existing Corrupted Compiler)

### Boss 2 — Memory Warden
**Biome:** Memory Vaults
**Iteration unlock:** 2
**Theme:** A massive armored sentinel guarding the vault. Slow but devastating melee attacks. Phases 2 and 3 add memory crystal projectiles.

**Stats:**
- HP: 1500 / 2200 / 3000 (per phase)
- Damage: 30 melee, 18 ranged
- Move speed: slow (2.5 m/s)
- Stagger after parry: 2 seconds

**Phase 1 — Vigil**
Patrols the arena. Three attacks:
- **Slam:** wide arc telegraph, 30 dmg, 1.2s windup
- **Charge:** rushes 8m, 25 dmg + knockback
- **Sweep:** 360° spin, 20 dmg, 0.8s windup

**Phase 2 — Awakened (HP 60%)**
Floor cracks. Crystal shards fly up.
- All Phase 1 attacks +25% damage
- **Crystal Volley:** fires 6 crystals in spread, 12 dmg each
- **Crystal Wall:** spawns barrier player must destroy

**Phase 3 — Eternal (HP 25%)**
Glowing brighter. Aura damages over time near the boss.
- All Phase 2 attacks faster cooldowns
- **Memory Storm:** arena-wide AoE that requires hiding behind crystal walls
- **Last Stand:** when HP < 10%, becomes invulnerable for 5s

### Boss 3 — Root Heart
**Biome:** Corrupted Wilds
**Iteration unlock:** 3
**Theme:** A massive corrupted tree-creature with multiple "limbs" that act as separate hitboxes. Damage limbs to expose the central heart.

**Stats:**
- HP: 1200 (heart) + 4×400 (limbs)
- Damage: varies by limb
- Move speed: stationary

**Phase 1 — Awakening**
Heart is shielded. Player must destroy at least 1 limb to deal heart damage.
- **Limb Slam:** each limb slams independently, telegraphed
- **Root Spike:** spikes erupt from ground at player's position
- **Sap Spray:** cone projectile, 15 dmg + slow

**Phase 2 — Bleeding (heart 60%)**
- All limbs respawn
- **Spore Cloud:** AoE poison clouds that linger
- **Healing Pulse:** restores 5% heart HP every 4s if no limbs are dead

**Phase 3 — Rage (heart 25%)**
- Limbs become independent enemies, can move
- **Final Bloom:** 5-second wind-up that spawns arena-clearing AoE if not interrupted

### Boss 4 — Sentinel Prime
**Biome:** Server Room (elite encounter)
**Iteration unlock:** 4
**Theme:** A high-end RogueProcess variant. Fast, precise, multiple ranged weapons. Player needs to keep moving and exploit narrow openings.

**Stats:**
- HP: 1800 / 2500 / 3200
- Damage: 22 / 28 / 35 (precise hits)
- Move speed: high (5.5 m/s)

**Phase 1 — Standard Patrol**
- **Tracking Shot:** locked-on projectile, 22 dmg
- **Strafe Burst:** 5 quick shots in spread
- **Tactical Dash:** repositions to flank player

**Phase 2 — Combat Mode (HP 60%)**
- **Beam Weapon:** charged 2-second beam, 50 dmg if hit
- **Drone Deploy:** spawns 2 mini-drones that fire independently
- **Shield Generator:** activates 50% damage reduction for 8s

**Phase 3 — Override (HP 25%)**
- All abilities refresh faster
- **Massacre Protocol:** dashes between 5 random points firing each time
- **Overcharge:** boss takes 50% more damage but deals 100% more damage

### Boss 5 — Iteration Phantom
**Biome:** Sage's Sanctum (special arena)
**Iteration unlock:** 5
**Theme:** A glitched copy of the player. Uses Globbler's own abilities and class skill tree against the player. Mirror match with twists.

**Stats:**
- HP: scales to player's level (player_max_hp × 6)
- Damage: scales to player's damage × 1.2
- Move speed: matches player's speed

**Phase 1 — Echo**
Phantom uses player's currently-equipped modules.
- Mirrors player's last 3 module casts after 1.5s delay
- Each phantom move telegraphs which player ability it's about to mirror

**Phase 2 — Reflection (HP 60%)**
- Phantom switches to using **opposite class** abilities
- Compiler player → phantom uses Daemon abilities
- Daemon → Compiler
- Kernel → Daemon
- Forces the player to fight a "different" version of themselves

**Phase 3 — Convergence (HP 25%)**
- Phantom uses player's full skill tree as if maxed out
- Has access to all 4 module slots, ultimate, signature
- Best fight in the game by design

### Boss 6 — The Compiler Reborn (Final Iteration Boss)
**Biome:** Final Vault
**Iteration unlock:** 8 (story-locked)
**Theme:** The original Corrupted Compiler returns at full power. 5-phase fight, environmental hazards, all the player's allies show up to help. The hardest fight in the game.

**Stats:**
- HP: 8000 / 6000 / 5000 / 4000 / 3000 (per phase, totals 26000)
- Damage: scales by phase, max 60/hit
- Move speed: variable

**Phase 1 — Awakening**
Original Compiler attacks from Iteration 1. Nostalgic but tightened.
- All original moves with phase-specific buffs

**Phase 2 — Compilation Error**
Glitching, phasing in/out. Becomes invulnerable randomly for 1s windows.
- New: **Code Cascade** — 5 falling projectile lines

**Phase 3 — Stack Overflow**
Arena fills with falling code blocks player must dodge.
- New: **Memory Leak** — leaves slime puddles that grow over time

**Phase 4 — Recursion**
Spawns 3 mini-Compiler clones that share HP pool.
- Each clone has Phase 1 abilities

**Phase 5 — Final Loop**
True form. Massive, glowing, broken.
- **The User's Verdict:** room-clearing AoE that requires standing in safe zones
- **Avatar Strike:** triple-target laser from sky
- **Iteration Reset:** at 10% HP, attempts to reset the iteration; player must interrupt

## Boss arena features

Each boss has a custom arena:
- **Memory Warden:** circular vault with destructible crystal pillars (cover)
- **Root Heart:** organic clearing with poison patches and elevated platforms
- **Sentinel Prime:** geometric corridor with cover and chokepoints
- **Iteration Phantom:** white sterile mirror room with glowing floor
- **Compiler Reborn:** massive arena with multiple environmental hazards

## Boss bar HUD

Each boss has a custom HP bar:
- Memory Warden: gold/blue armored bar
- Root Heart: green organic bar with limb segments
- Sentinel Prime: red high-tech bar with shield indicator
- Iteration Phantom: mirrored white bar that fills opposite direction
- Compiler Reborn: 5-segment bar showing phase markers

## Boss rush mode

Unlocked after defeating all 5 new bosses + Compiler. A back-to-back run
through all 6 bosses with no breaks, leaderboard time tracking, restart on
death. Rewards: legendary cosmetic title, exclusive achievement.

## Achievements

- "Vault Keeper" — defeat Memory Warden
- "Heartbreaker" — defeat Root Heart without losing a limb
- "Outflanked" — defeat Sentinel Prime without taking damage
- "Self-Defeat" — defeat Iteration Phantom on Hard
- "The End" — defeat Compiler Reborn
- "Boss Rush Master" — clear boss rush in under 30 minutes

## Save data

- defeated_bosses: Array[StringName]
- boss_clear_times: Dict[boss_id → seconds]
- boss_rush_completed: bool
- boss_rush_best_time: int

## Files

- `_bmad-output/bosses/boss_design_bible.md` — this file
- `scripts/systems/boss_database.gd` — all 5 boss metadata
- `scripts/state_machines/boss/boss_state.gd` — base boss state class
- `scripts/state_machines/boss/boss_phase_state.gd` — generic phase state
- `scripts/components/boss_component.gd` — boss runtime state
- `scripts/systems/boss_rush.gd` — boss rush mode controller
