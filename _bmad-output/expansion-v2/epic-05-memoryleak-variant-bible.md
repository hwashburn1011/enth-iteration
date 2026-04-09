---
name: Epic 05 — MemoryLeak Variant Bible
description: Per-variant design rules for all MemoryLeak subspecies — drives all future variant work in Epic 05 and beyond
epic: 05
created: 2026-04-09
---

# MemoryLeak Variant Bible

## Purpose

Same role as the GlitchBug variant bible (epic-04-glitchbug-variant-bible.md)
but for the MemoryLeak family. Drives all future MemoryLeak variants —
elemental swaps, size variants, elites, queen, environmental subspecies.

Depends on:
- `epic-05-memoryleak-references.md` — design pillars
- `epic-05-memoryleak-concept-silhouettes.md` — base shapes

## What stays the same across ALL variants

These are the **inviolable** family traits.

1. **Silhouette signature**: tall vertical irregular blob, NO face,
   NO joints, NO legs. Wider sagging base + narrower upper "intent"
   bulge. The silhouette must fail the "spider/teardrop/sphere" tests
   from the references doc.

2. **Material story**: refractive translucent gel + visible internal
   data. The body MUST be at least 50% transparent and you MUST be
   able to see fragments of code/glyphs drifting inside it. Even cold
   variants where the body is "frozen" should have data fragments
   suspended like insects in amber.

3. **Animation language**: macro slow + micro jiggle. Body movement
   is viscous and dragging. Surface always has the vertex wobble
   shader running. Both halves of this contrast are required — a
   variant that moves quickly OR a variant that's perfectly still
   would break the species feel.

4. **No face, no eyes**: the intent bulge is NEVER decorated with
   eye pits, mouth lines, or any face features. The bulge is a
   directional indicator only.

5. **Hotspot nodes for telegraphs**: every variant uses the cluster
   of bright dots at the front of the intent bulge as the attack
   wind-up indicator. The color of the hotspots changes per variant
   (matches the elemental theme), the placement and timing don't.

6. **Base rig**: 12 control bones from task 14. Variants do NOT add
   bones. They scale the rig (size variants) or change which bones
   carry which weights (e.g. tendril-heavy variants have stretchier
   tendril bones, but the bone count is the same).

## What CHANGES per variant

### Knob 1: Variant element + tint hue

The default green is the species baseline ("data leak"). Variants
swap to other elemental themes:

| Element | Body tint | Internal data color | Hotspot color | Used by |
|---|---|---|---|---|
| Data (default) | Acid green 0.20/0.85/0.45 | Pale white-cyan | Red 1.0/0.10/0.05 | base MemoryLeak |
| Cold | Ice blue 0.45/0.85/1.05 | White | Blue-white 0.7/0.95/1.0 | Cold variant |
| Acid | Lime yellow 0.85/1.0/0.20 | Black | Bright yellow | Acid Tox variant |
| Fire | Orange 1.0/0.55/0.10 | Black-red | Yellow-white | Fire variant |
| Void | Deep purple 0.30/0.05/0.55 | Pale violet | Magenta | Void variant |
| Plasma | Pink-cyan rim shifting | Cyan | White | Plasma elite |
| Royal | Gold-emerald | Emerald + gold flecks | Gold | Cosmetic post-launch |

The variant just swaps the gel_refraction.gdshader uniforms
(tint_color, internal_data_color, rim_color) and the LeakPuddle
slick_color, BubblingFoamEmitter bubble_color, AbsorbLightField
tint_color, etc — all already exposed.

### Knob 2: Body scale tier

| Variant | Body width | Body height | Bone scale | Tri budget |
|---|---|---|---|---|
| Drip (small) | 0.6 m | 0.7 m | 0.5× | 1.5K LOD0 |
| Leak (standard) | 1.2 m | 1.4 m | 1.0× | 3K LOD0 |
| Flood (large) | 2.4 m | 2.8 m | 2.0× | 4.5K LOD0 |
| Ocean (boss) | 4.8 m | 5.6 m | 4.0× | 6K LOD0 + queen-only meshes |

Larger tiers have more visible internal data fragments at higher
density to keep the surface from looking under-detailed at scale.

### Knob 3: Movement speed multiplier

The MemoryLeak's tempo is part of its identity. Variant overrides:

| Variant | Speed mult | Why |
|---|---|---|
| Drip | 1.4× | Smaller body moves faster |
| Standard Leak | 1.0× | Baseline viscous tempo |
| Flood | 0.7× | Heavier body drags slower |
| Ocean | 0.5× | Boss-tier slow-but-inevitable |
| Acid | 1.1× | Slightly more aggressive |
| Cold | 0.6× | Sluggish, slow, but applies frost on hit |
| Plasma | 1.5× | Fastest variant — high-pressure state |
| Royal | 1.0× | Cosmetic, no behavior change |

### Knob 4: Tendril count

Most variants use the single tendril whip from the base rig. Some
elite variants get more:

| Variant | Tendril count | Notes |
|---|---|---|
| Standard | 1 | The base rig |
| Plasma elite | 2 (one each side) | Alternating whips |
| Ocean boss | 3 (front + 2 side) | Cycling whip pattern, can chain combos |
| Acid | 1 + drip-spit | The acid variant adds a ranged spit attack instead of a second tendril |

Adding tendrils means duplicating the tendril_01-tendril_03 chain in
the rig with weight painting. Bone count stays at 12 + 3 per extra
tendril.

### Knob 5: Internal data pattern

The visible code stream inside the body has a procedural texture
pattern that distinguishes variants:

| Variant | Pattern |
|---|---|
| Standard | Hex bytes + occasional function preambles |
| Cold | Frozen "blue screen of death" character grid |
| Acid | Garbled symbol noise — looks corrupted |
| Fire | Stack overflow patterns + repeated `0xDEADBEEF` |
| Void | Empty space with sparse text fragments — feels barely there |
| Plasma | Animated waveforms |
| Royal | Decorated text scrolls + symbol art |
| Boss (Ocean) | Recognizable "boot sequence" text running on a loop |

### Knob 6: Special attack

Each variant has ONE distinguishing attack beyond the base whip + spit:

| Variant | Special |
|---|---|
| Standard | None — just whip + spit |
| Drip | Cluster jump (small drips burst toward player) |
| Cold | Frost burst — applies freeze stacks in radius |
| Acid | Acid puddle spit (creates a SlowZone with damage) |
| Fire | Self-immolation (sets self on fire for X seconds, damaging contact) |
| Void | Dimensional pull (drags player toward leak) |
| Plasma | Chain lightning between tendrils |
| Ocean | Wave summon (pushes player, summons drips) |
| Royal | Cosmetic only |

### Knob 7: Aura strength

Per the AbsorbLightField component, elite variants get a stronger
absorb effect:

| Variant | absorb_strength | field_radius_m |
|---|---|---|
| Standard | 0.50 | 1.8 |
| Drip | 0.30 | 1.2 |
| Flood | 0.65 | 2.6 |
| Ocean | 0.85 | 4.0 |
| Plasma elite | 0.75 | 2.4 |
| Cold | 0.40 | 2.0 |

Boss-tier Ocean variant should absorb so much light that the dungeon
arena visibly darkens when it spawns. This is part of the boss intro
beat.

### Knob 8: Death style

| Variant | Death visual |
|---|---|
| Standard | Collapse + drain into puddle (base shape 6) |
| Cold | Crystallizes solid then shatters into ice fragments |
| Fire | Briefly reignites then burns out into ash decal |
| Void | Implodes into a tiny black point that vanishes |
| Plasma | Discharges chain lightning to nearby allies as it dies |
| Acid | Collapses into a 2x size acid puddle that lingers as a hazard |
| Ocean | 3-stage death: tendrils detach, body collapses, puddle drains slowly over 10s |

## Per-variant Resource files

Following the same pattern as GlitchBug, MemoryLeak variants live at:
`res://data/enemies/variants/memoryleak_<variant>.tres`

Using the existing EnemyVariant Resource (scripts/resources/enemy_variant.gd)
which is generic across all enemy families. The MemoryLeak-specific
fields beyond the standard schema:
- crack_color_a/b → tint_color and internal_data_color
- pattern_overlay → drives the internal data pattern selection
- aura_intensity / aura_radius → drives AbsorbLightField
- has_pack_leader_aura → false for most leaks (they're individuals,
  not pack hunters)
- leaves_footstep_decal → true for variants with persistent slow trails
- applies_status_effect → set to &"freeze" for Cold, &"poison" for Acid, etc

## Variant launch list

### Launch (in Epic 05)
1. **MemoryLeak Standard** — base species, acid green
2. **MemoryLeak Cold** — ice blue, slows on hit, can be frozen further
3. **MemoryLeak Acid** — lime yellow, drops acid puddles, applies poison
4. **MemoryLeak Fire** — orange, self-immolates when angered
5. **MemoryLeak Void** — deep purple, pulls player

### Size variants (also Epic 05)
6. **Drip** — 0.5× scale, fast, weak, swarm in 4-6
7. **Flood** — 2× scale, slow, hard-hitting
8. **Ocean** — 4× scale, mid-boss tier, 3 tendrils, wave attacks

### Post-launch
9. **Plasma elite** — pink-cyan, 2 tendrils, chain lightning
10. **Royal** — gold/emerald cosmetic
11. **Spectral** — phases through walls (post-launch parallel of GlitchBug Spectral)
12. **Tar** — cooled tarry variant — slower than cold, deeper slow

## Validation checklist

Before merging a new MemoryLeak variant, verify:

- [ ] At 64×64 px silhouette, the variant is recognizable as a
      MemoryLeak (passes the species silhouette test)
- [ ] At 64×64 px silhouette, the variant is distinguishable from at
      least 2 other variants by silhouette outline alone (size variants
      are typically distinguished by overall scale)
- [ ] The body is at least 50% transparent and you can see internal
      data fragments through the surface
- [ ] The variant has NO face, NO eyes, NO mouth
- [ ] The variant uses the same 12-bone rig (or 12 + N for variants
      with extra tendrils)
- [ ] The hotspot node cluster fires from the front of the intent
      bulge during attack wind-ups
- [ ] The death sequence collapses into a puddle, sub-shape 6 pattern
      (no "vanish in a flash" deaths — every leak leaves a body)
- [ ] The variant's gel shader tint matches the variant identity color
- [ ] The variant's LeakPuddle slick_color matches the body tint
- [ ] If the variant has the freeze status hookup, it uses
      FreezeStatus component with shatter_multiplier configured
- [ ] If the variant has the absorb-corpse mechanic, it uses
      LeakAbsorbController with appropriate hp_per_absorb
- [ ] The variant's gel feels viscous in motion (no fast movement
      profile)

## Anti-patterns specific to MemoryLeak variants

- **Don't make a "solid" variant.** Even crystallized cold variants
  must show internal data through their surface — full opacity breaks
  the species rule.
- **Don't add wings or limbs that aren't tendrils.** The MemoryLeak
  is a body + tendrils, never a body + wings + tail.
- **Don't make a variant that's faster than the GlitchBug.** The
  MemoryLeak is the SLOW horror of the bestiary; if a variant
  out-paces a GlitchBug it has broken the bestiary tempo distinction.
- **Don't put a face on it.** No matter how cute it would be.
- **Don't add cubes or hard angles.** Even crystallized cold variants
  use rounded organic crystal shapes, never geometric prisms.
- **Don't make a variant that doesn't leave a corpse.** Every leak
  death must produce a puddle — that's the species identity at the
  death moment.

## Cross-pollination matrix

Like GlitchBug, MemoryLeak variants cross-pollinate scale × element
without per-cross asset authoring. The variant Resource is the only
thing needed to instantiate a "Cold Drip" or "Fire Ocean" — the
existing knob system handles it.

```
MEMORYLEAK family
├── Acid green   — Standard      (data leak baseline)
├── Ice blue     — Cold          (slow, freeze)
├── Lime yellow  — Acid          (puddle, poison)
├── Orange       — Fire          (self-immolate)
├── Deep purple  — Void          (pull)
├── Pink-cyan    — Plasma elite  (chain lightning)
├── Gold-emerald — Royal         (cosmetic post-launch)
└── SCALES
    ├── 0.5×  Drip             (small, swarm)
    ├── 1.0×  Standard Leak
    ├── 2.0×  Flood            (large)
    └── 4.0×  Ocean            (mid-boss)
```

A "Cold Ocean" would be a 4× scale ice-blue mid-boss with frost burst
and 3 tendrils. A "Fire Drip" would be a 0.5× orange swarm enemy
that ignites near the player. The variant Resource carries all the
deltas.

## Bestiary integration

The MemoryLeak's design contrasts intentionally with the GlitchBug's
across every axis (see epic-05-memoryleak-references.md "What MUST be
different from the GlitchBug" table). When adding a new variant,
double-check that the contrast still holds — a Cold MemoryLeak should
still feel like a leak, not like a Cold GlitchBug. The contrast axes
are inviolable across the bestiary, so Cold variants of different
species should differ on body type / silhouette / locomotion style
even though they share an element.
