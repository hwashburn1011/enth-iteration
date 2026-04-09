---
name: Companion System Bible
description: 4 companions with role specialization, AI state machine, party mechanics, gear, leveling
date: 2026-04-09
status: design + data complete
---

# Companion System Bible

## Philosophy

Companions are **NPCs that physically join you in dungeons** — not pets,
not summons, but full party members with their own AI, gear, leveling, and
personality. Designed in the spirit of:
- Hades' god boons (each companion is a different playstyle multiplier)
- Pillars of Eternity / Baldur's Gate party AI
- Stardew Valley's NPC companions in the mines

The player has **1 companion slot active at a time** (party limit 1+1 for
prototype). Companions are recruited through main story quests, not random
drops, so each one is a known character with story weight.

## The 4 Companions

### 1. Patch — The Tank
**Role:** Melee absorbs damage, taunts enemies, protects Globbler.
**Recruited:** Iteration 3 main quest "Companion Search"
**Personality:** Stoic, reliable, dry humor. Talks about weight + endurance.
**Color tag:** Steel gray + amber
**Loadout:** Heavy melee, defensive abilities, low DPS, high HP

**Stats baseline:**
- HP: 250
- Damage: 8/hit (slow attacks)
- Defense: 1.5×
- Speed: 3.5

**Signature ability:** "Ironclad" — for 5s, taunts all nearby enemies and reduces incoming damage by 50%
**Ultimate:** "Phalanx" — root in place, become invulnerable for 8s, reflect 30% damage

### 2. Ping — The Ranged DPS
**Role:** Stays back, fires precision shots at high-priority targets.
**Recruited:** Iteration 4 side quest from Lab
**Personality:** Cheerful, talkative, makes a lot of jokes. Gets nervous in melee.
**Color tag:** Bright yellow + black
**Loadout:** Long-range projectiles, kiting, glass cannon

**Stats baseline:**
- HP: 100
- Damage: 25/hit (ranged)
- Defense: 0.7×
- Speed: 5.5

**Signature ability:** "Marked Target" — designate one enemy, all of Ping's shots crit on it for 6s
**Ultimate:** "Overcharge Volley" — 3 seconds of unlimited rapid-fire crit shots

### 3. Mend — The Support Healer
**Role:** Healing AOE, buffs, status cleanse. Doesn't fight directly.
**Recruited:** Iteration 5 quest from Sage at Friend tier
**Personality:** Warm, empathetic, slightly anxious. Calls Globbler "friend" in dialog.
**Color tag:** Soft green + cream
**Loadout:** Heal pulses, shields, buff auras

**Stats baseline:**
- HP: 150
- Damage: 5/hit (rare)
- Defense: 1.0×
- Speed: 4.5

**Signature ability:** "Restoration Field" — 4s AOE that heals 8 HP/s and cleanses statuses
**Ultimate:** "Iteration Mend" — fully heal Globbler + remove all debuffs + grant 10s shield

### 4. Hex — The Utility CC
**Role:** Crowd control, debuffs, slowing fields, area denial.
**Recruited:** Iteration 6 quest from Glitcher faction
**Personality:** Mysterious, glitchy speech patterns. Loves chaos.
**Color tag:** Crimson + violet
**Loadout:** Stuns, slows, freeze, traps

**Stats baseline:**
- HP: 120
- Damage: 12/hit (medium)
- Defense: 0.85×
- Speed: 5.0

**Signature ability:** "Stutter Field" — 4s AOE that slows enemies 50% and applies random brief stuns
**Ultimate:** "Time Stop" — freezes all enemies in 8m radius for 4 seconds

## AI state machine

Each companion uses a 7-state machine:

```
                      ┌─────────┐
                      │  Idle   │
                      └────┬────┘
                           │ player moves / combat starts
                  ┌────────┴────────┐
                  │                 │
            ┌─────▼─────┐    ┌─────▼─────┐
            │  Follow   │    │  Combat   │
            └─────┬─────┘    └─────┬─────┘
                  │                 │
        ┌─────────┴───────┬─────────┼─────────┐
        │                 │         │         │
   ┌────▼────┐       ┌────▼────┐ ┌──▼───┐ ┌──▼─────┐
   │ Catchup │       │ Reposition│  Use │ │ Downed │
   └─────────┘       └──────────┘  Ability └────────┘
                                   └──────┘
```

States:
- **Idle:** Standing near player, ambient idle anim, occasional banter
- **Follow:** Player moved, companion follows at 2-4m offset
- **Catchup:** Player too far away, companion sprints to close gap
- **Combat:** Enemies in range, AI evaluates target priority
- **Reposition:** Adjusts position (kiting for ranged, flanking for melee)
- **UseAbility:** Casting an ability, can't move or attack
- **Downed:** HP reached 0, waiting for player revive (lasts 30s before forced retreat)

## Targeting priority

Companion picks targets by role:
- **Tank (Patch):** highest threat enemy, attacker of Globbler, then closest
- **Ranged (Ping):** lowest HP enemy first (execution), then highest damage threat
- **Healer (Mend):** doesn't target enemies — picks heal targets instead (Globbler if low, then companion)
- **CC (Hex):** elite enemies first, then groups for AOE control

## Companion gear

Each companion has 3 gear slots (vs Globbler's full 6+):
- **Weapon** — shapes their primary attack
- **Armor** — defense + HP bonus
- **Accessory** — utility / passive

Loot drops can be marked as "companion gear" — these auto-route to the
active companion's inventory.

## Companion XP & leveling

Companions earn 50% of the XP Globbler earns from kills they participated in.
They level independently from Globbler:
- 1-50 levels per companion
- Each level: +5% HP, +3% damage, +1 stat point to spend
- Key milestones unlock new abilities

## Companion skill tree (15 nodes per companion)

Smaller, faster trees compared to Globbler's 25-node trees:
- 5 stat ramps (small +X each, max 5 ranks)
- 5 utility nodes (binary unlocks)
- 5 keystones (major effects)

Each companion has their own theme and node names.

## Companion command UI

A small radial menu in the HUD:
- **Attack** — companion attacks the cursor target
- **Defend** — companion stays close to Globbler, doesn't engage unless attacked
- **Ability** — manually trigger companion's signature ability
- **Wait Here** — companion stays at current position
- **Follow** — default following behavior

Activated with a hold-to-open keybind (e.g. middle mouse button).

## Companion dialogue

Each companion has:
- **20+ idle banter lines** (random during exploration)
- **15+ combat callouts** (when ally takes damage, kills boss, etc.)
- **5 reaction-to-environment lines** (per dungeon biome)
- **3 quest-specific dialogue scenes** (recruitment, midgame, finale)

Banter is delivered via subtitle popup over their head, paused gameplay
for cinematic moments.

## Affinity integration

Companions hook into the NPC affinity system (Epic 37):
- Bringing a companion on a successful boss kill gives +50 affinity
- Letting a companion get downed gives -25 affinity
- Reviving a downed companion gives +25 affinity
- Each companion has their own gift preferences (overlaps NPC preferences)

## Faction tags

Each companion has a faction alignment:
- **Patch:** Optimizers
- **Ping:** Dreamers
- **Mend:** Archivists
- **Hex:** Glitchers

Bringing a companion grants a small (5%) bonus to that faction's quests.

## Save data

- companion_id → { level: int, xp: int, hp: int, equipped_gear: Dict, allocated_skills: Dict }
- active_companion: StringName ("" if none)
- companion_command_state: StringName

## Achievements

- "First Friend" — recruit any companion
- "Full Party" — recruit all 4 companions
- "Inseparable" — beat boss with same companion 5 times
- "Sole Survivor" — beat boss with companion downed
- "Best Friends Forever" — max-level any companion

## Files

- `_bmad-output/companions/companion_bible.md` — this file
- `scripts/resources/companion_definition.gd` — companion data resource
- `scripts/systems/companion_database.gd` — all 4 companions
- `scripts/components/companion_component.gd` — player-side companion state
- `scripts/state_machines/companion/companion_state.gd` — base state class
- `scripts/state_machines/companion/companion_idle_state.gd` — idle state
- `scripts/state_machines/companion/companion_follow_state.gd` — follow state
- `scripts/state_machines/companion/companion_combat_state.gd` — combat state
- `scripts/state_machines/companion/companion_downed_state.gd` — downed state
