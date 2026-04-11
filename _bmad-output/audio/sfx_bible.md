---
name: SFX Library Bible
description: 150+ sound effects across player/combat/enemy/boss/UI/world categories with pooling and 3D spatialization
date: 2026-04-09
status: design + manager complete; audio production pending
---

# SFX Library Bible

## Philosophy

SFX in Enth fall into 3 audio buses:
- **SFX_World** (3D spatialized): footsteps, hits, environment ambient
- **SFX_Combat** (3D spatialized): attacks, damage, death, abilities
- **SFX_UI** (2D non-spatial): menu sounds, inventory, level-up

Every sound has:
- An ID referenced in code
- A pool size (concurrent plays)
- A volume offset
- A pitch randomization range (for variety)
- A spatial flag (3D vs 2D)

The SFXManager autoload provides a unified `play_sfx(id, position?)` API
that handles pooling, prioritization, and spatialization automatically.

## Sound categories (150+ total)

### Player movement (24)
- Footsteps grass / stone / metal / wood / water (×4 each = 20)
- Jump
- Land
- Dash
- Crouch

### Player damage / state (8)
- Damaged ×3 (light/medium/heavy)
- Death
- Level up
- Potion drink
- Heal pulse
- Shield up

### Combat — basic attacks (8)
- Swing ×3 (combo 1/2/3)
- Hit ×3 (light/medium/crit)
- Charged release
- Charged hit

### Combat — modules (40)
40 module sounds, one per module from Epic 33. Each has:
- Cast cue
- Hit / impact (where applicable)

### Enemies (33+)
Per enemy type: aggro / attack / hit / death = 4 sounds
- GlitchBug ×4
- MemoryLeak ×4
- RogueProcess ×4
- 8 new enemies × 4 = 32
- Plus elite/variant sound differentiations

### Bosses (30+)
Per boss: intro roar + 4 attack cues + phase transition + death
- 6 bosses × 6 sounds = 36

### UI (20)
- Button hover
- Button click
- Menu open
- Menu close
- Tab switch
- Inventory open / close
- Item pickup / drop / equip / unequip
- Item drop on ground
- Gold pickup
- XP pickup
- Skill tree allocate
- Quest accept / complete / fail
- Level up jingle (UI)
- Achievement unlock

### World ambient (15+)
- Door open / close
- Chest open
- Crystal shimmer
- Water splash
- Wind gust (loop)
- Fire crackle (loop)
- Birdsong (loop, town)
- Cricket (loop, night)
- Server hum (loop, dungeon)
- Glitch crackle (loop, corrupted biome)
- Memory chime (loop, vault)

## Pooling

Each SFX has a pool size (default 4). When more concurrent plays are
requested than available pool slots, the oldest playing instance is
recycled. Critical sounds (player damage, boss attacks) get higher
priority and won't be interrupted.

Pool sizes by category:
- Footsteps: 8 (multiple feet, multiple players, fast cadence)
- Combat hits: 6
- UI: 4
- Ambient loops: 1 each
- Damage cues: 4
- Death cues: 2

## Spatial audio

3D sounds use `AudioStreamPlayer3D` with attenuation curves:
- **Close** (< 5m): full volume
- **Medium** (5-15m): linear falloff
- **Far** (> 15m): silenced

UI sounds use `AudioStreamPlayer2D` (no falloff).

## Pitch randomization

Most sounds have a small pitch random range (e.g. 0.95-1.05) so repeated
plays don't sound robotic. Footsteps use a wider range (0.9-1.1).

## Volume balance

SFX volumes are controlled via:
- Per-sound volume offset (in database)
- `AccessibilitySettings.sfx_volume` (0-100%)
- `AccessibilitySettings.master_volume` (0-100%)
- Audio bus mixing (SFX_World, SFX_Combat, SFX_UI)

## Files

- `_bmad-output/audio/sfx_bible.md` — this file
- `scripts/systems/sfx_database.gd` — 150+ SFX metadata
- `scripts/autoloads/sfx_manager.gd` — global SFX controller with pooling
