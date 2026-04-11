---
name: Module Library Expansion Bible
description: 40 ability modules across Compiler/Daemon/Kernel/Universal/Ultimate categories
date: 2026-04-09
status: design + data complete
---

# Module Library — 40 Active Abilities

## Categories

| Category | Count | Cooldown | Cost | Notes |
|---|---|---|---|---|
| Compiler-class | 8 | 4-15s | 10-30 | balanced range/control |
| Daemon-class | 8 | 3-12s | 8-25 | mobility + crit |
| Kernel-class | 8 | 5-18s | 12-35 | tank + AoE |
| Universal | 8 | varies | varies | any-class utility |
| Ultimate | 8 | 60-120s | 60-150 | run-defining big abilities |

## Slot system

- Player has **4 active module slots** at all times
- 3 starting modules from class kit + 1 free slot
- Universal modules can go in any slot
- Ultimate modules consume their slot for the entire run (no swap mid-dungeon)

## Rarity

Modules drop in 4 rarity tiers:
- **Common (white):** flat baseline values, no extras
- **Rare (blue):** +15% damage/area/duration, 1 affix
- **Epic (purple):** +30% values, 2 affixes
- **Legendary (orange):** +50% values, 3 affixes + unique flavor effect

Affixes are rolled from `AffixDatabase` (existing system) and can include:
- "Reduces cooldown by 15%"
- "Costs no compute on the first cast"
- "Crits cause an explosion"
- "Refunds 50% cost on enemy hit"

## VFX hooks

Each module references a VFX scene from `assets/vfx/modules/<module_id>.tscn`.
The ability spawns this scene and plays it on activation. VFX uses the
shader library (Epic 20):
- Beams: laser_beam.gdshader
- Bursts: portal_swirl.gdshader (mini)
- Statuses: dissolve_overlay_status.gdshader
- Auras: energy_aura.gdshader

## Animation hooks

Modules trigger one of these AnimationTree triggers on the Globbler rig:
- `ability_small` (8 frames) — utility / projectile
- `ability_medium` (12 frames) — burst / aoe
- `ability_ultimate` (24 frames) — full body commit

## Module list

### Compiler (8) — Balanced control + utility

1. **Pattern Lock** [starting] — freeze 1 target 1.5s, 15c, 4s CD
2. **Recompile** — teleport + glyph detonation, 25c, 8s CD, 35dmg
3. **Logic Bomb** — sequential ring of explosions, 80c, 60s CD, 200dmg
4. **Iterative Mend** — heal 30 HP over 3s, 20c, 12s CD
5. **Stack Trace** — mark enemy, all attacks reveal weakness +15% dmg, 12c, 6s CD
6. **Garbage Collect** — destroy ground hazards in 5m, 18c, 10s CD
7. **Memory Allocate** — temporary +30 max HP for 8s, 25c, 15s CD
8. **Branch Predict** — 2s of perfect dodges (autododge), 30c, 18s CD

### Daemon (8) — Mobility + lethality

1. **Phase Strike** [starting] — instant teleport-stab, 15c, 5s CD, 22dmg
2. **Hunter's Mark** — mark target +30% dmg from Daemon, 12c, 5s CD
3. **Smoke Veil** — 2s invisibility, 30c, 12s CD
4. **Shadow Clone** — split into 3 clones for 4s, 35c, 20s CD
5. **Massacre Protocol** — 4s execute mode, 100c, 90s CD
6. **Acid Splash** — projectile leaves poison pool, 18c, 8s CD, 15dmg+5dot
7. **Backstep** — short backwards dash + 2 daggers thrown, 14c, 6s CD
8. **Bleed Out** — apply 8s bleed, lethal at 20% HP, 22c, 10s CD

### Kernel (8) — Tank + crowd control

1. **Bulwark** [starting] — sustained +50% defense, 0c sustained
2. **Gravity Well** — pull enemies in 4m, 20c, 8s CD
3. **Thunder Strike** — slow-charge AoE slam, 40c, 12s CD, 60dmg
4. **Aegis Protocol** — bubble blocks 3 attacks per ally in 5m, 35c, 12s CD
5. **Overclock Reactor** — 5s invuln + 200% dmg ultimate, 150c, 120s CD
6. **Earthquake** — radial knockdown 6m, 30c, 14s CD, 30dmg+stun
7. **Thorn Aegis** — reflects 50% melee damage for 5s, 25c, 16s CD
8. **Iron Will** — break all CC + 80% defense for 3s, 20c, 25s CD

### Universal (8) — Any-class utility

1. **Healing Prompt** — instant heal 50 HP, 15c, 20s CD
2. **Compute Surge** — refill 50 compute over 3s, 0c, 30s CD
3. **Translocate** — short teleport to cursor, 18c, 10s CD
4. **Provoke** — taunt enemies in 6m, 12c, 15s CD
5. **Time Dilate** — slow nearby enemies 50% for 3s, 25c, 18s CD
6. **Decoy Daemon** — spawn distraction puppet, 22c, 20s CD
7. **Repair Kit** — restore item durability and clean wear, 20c, 60s CD
8. **Module Combust** — destroy worst module for full HP/compute refill, 0c, once per run

### Ultimate (8) — Run-defining choices

1. **The Compiler's Last Word** — 10s of automatic Pattern Lock on every enemy in sight, 150c, 120s CD
2. **Daemon Storm** — 5s of self-controlled multi-shadow strikes, 120c, 100s CD
3. **Wall of Walls** — Kernel becomes immobile but reflects all damage for 8s, 100c, 90s CD
4. **System Reset** — refill all HP/compute and refresh all cooldowns, 0c, once per dungeon
5. **Iteration Echo** — clone Globbler from 5s ago to fight beside you for 10s, 140c, 120s CD
6. **Glitch Explosion** — Globbler bursts into corruption, 800 dmg in 8m radius, kills self for 1s respawn, 0c, once per dungeon
7. **Memory Banking** — banks current HP/compute, refunds on next death, 60c, once per run
8. **Compaction Forecast** — reveals next 3 floors' room types and elite locations, 50c, once per floor

## Balance philosophy

- **Common modules** roughly equivalent in raw power
- **Build identity** comes from synergies (e.g. Hunter's Mark + Massacre Protocol)
- **Universal modules** are slot tax — taking one means giving up a class slot
- **Ultimates** are once-per-fight or once-per-dungeon to avoid spam
- **Cost vs cooldown:** high-cost low-CD = continuous threat, low-cost high-CD = burst windows

## Testing matrix

Each module is tested for:
- Damage/cost ratio within 20% of category average
- VFX visible at gameplay distance
- SFX cue distinct from other modules
- Animation matches commitment (small/medium/big)
- Loot drop balance (rares 60%, epics 30%, legendaries 10% in normal)
