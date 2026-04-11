---
name: Epic 04 — GlitchBug Variant Bible
description: Per-variant design rules for all GlitchBug subspecies — drives all future variant work in Epic 04 and beyond
epic: 04
created: 2026-04-09
---

# GlitchBug Variant Bible

## Purpose

This document is the canonical rules-of-the-game for adding new GlitchBug
variants — color swaps, size variants, elites, queens, environmental
subspecies, season-pass cosmetics, anything that pulls on the base
GlitchBug rig and texture set.

The goal: a designer can hand this doc to a junior modeler and get a
new variant back in a day that **looks like it belongs in the same
family** as every other GlitchBug, without art-direction back-and-forth.

It depends on:
- `epic-04-glitchbug-references.md` — design pillars
- `epic-04-glitchbug-concept-silhouettes.md` — base poses

## What stays the same across ALL variants

These are the **inviolable** family traits. If you're tempted to break
one, you're making a different enemy, not a GlitchBug variant.

1. **Silhouette signature**: 6 splayed legs in 3 pairs, mandible spread
   ≥ 1.2× body width, body slung LOW between the legs (not raised on
   stilts), antennae as 2 vertical posts on the head plate.
2. **Material story**: hard chitin + soft glitch. The base material is
   always near-black with deep purple sheen; the glitch crack lines
   are always emissive.
3. **Animation language**: jitter at micro scale, smooth at macro.
   Every variant inherits the same antenna twitch + mandible micro-jitter
   timing from the reference bible.
4. **Eye pits, not eyes**: 4 black holes in the head plate with internal
   glow visible through them. NEVER use lensed eyes, NEVER use single
   compound eyes, NEVER use eye stalks.
5. **Mandible shape**: forward-curving stag-beetle pattern with internal
   teeth visible from above. The size and color of the teeth can change
   per-variant; the basic shape cannot.
6. **Base rig**: every variant rigs to the 24-bone rig from task 14.
   Variants do NOT add bones (size variants scale the rig; cosmetic
   variants only swap meshes/textures attached to existing bones).

## What CHANGES per variant

These are your design knobs. Pull as many as needed to differentiate
the variant; don't pull any you don't need.

### Knob 1: Crack color hue

The cyan/magenta default cracks are the species baseline. Variants get
a different glitch hue that signals their "type":

| Hue | Meaning | Used by |
|---|---|---|
| Cyan + magenta | Default / unmodified | base GlitchBug |
| Blood red + amber | Venom/toxic | Red Venom variant |
| Deep blue + ice white | Cold/slowing | Blue Cold variant |
| Lime green + yellow | Acid/corrosive | Green Tox variant |
| Royal purple + gold | Elite / mini-boss | Purple Elite variant |
| Pure white + pale cyan | Spectral / phase | Ghost variant (post-launch) |
| Black void + dim red | Cursed / debuff applier | Hex variant (post-launch) |

The hue swap happens via the shader's `crack_color_a` and `crack_color_b`
uniforms — no texture re-painting needed. Set both to match your
variant's identity color.

### Knob 2: Body scale

Three canonical scales used by tasks 25 (size variants):

| Variant | Body length | Leg span | Trianglecount adj |
|---|---|---|---|
| Swarm (small) | 0.7 m | 1.1 m | 0.5× — use LOD1 for swarm |
| Standard | 1.4 m | 2.2 m | full LOD0 |
| Alpha (large) | 2.4 m | 3.8 m | full LOD0 + extra plate detail |
| Queen (mini-boss) | 3.6 m | 5.6 m | LOD0 + queen-only meshes |

Body scale is achieved via uniform armature scale. Carapace plate edge
detail still has to *read*, so for Alpha and Queen, double the normal
map intensity to keep the surface from looking smooth at scale.

### Knob 3: Plate breakup density

The chitin plate breakup pattern (Epic 04 task 4) has a `density` slider
on the procedural plate generator. Variant rules:

| Variant | Plate density | Why |
|---|---|---|
| Standard | 1.0 baseline | balanced |
| Swarm | 0.7 | smoother body — they're smaller and don't need detail at distance |
| Alpha | 1.3 | denser plates so the larger surface still feels textured |
| Queen | 1.6 | maximum visual richness for the boss-tier visual |
| Elite (any color) | 1.4 | denser than standard but not as much as Queen |

### Knob 4: Mandible scale + serration

Mandibles are the species's threat indicator. Per-variant overrides:

| Variant | Mandible length | Serration count | Serration depth |
|---|---|---|---|
| Standard | 1.0× | 5 teeth per side | 0.04 m |
| Swarm | 0.85× | 3 teeth | 0.025 m |
| Alpha | 1.15× | 6 teeth | 0.05 m |
| Queen | 1.3× | 8 teeth + central tusks | 0.07 m |
| Venom (Red) | 1.0× | 5 teeth | 0.04 m + dripping vfx |
| Cold (Blue) | 1.0× | 5 teeth + frost crusts | 0.04 m |

### Knob 5: Carapace pattern overlay

The base carapace texture is solid dark plate. Variants can layer one
of these overlays on top:

- **Stripe**: horizontal lighter bands across the elytra (Standard)
- **Spot**: irregular darker spots on the dorsal carapace (Venom)
- **Frost**: white crystalline patches on cooler-color cracks (Cold)
- **Vein**: glowing colored veins under translucent plate edges (Tox)
- **Plate gold**: gold-leaf trim along plate edges (Queen, Elite)
- **Symbol**: elite-only — a single etched runic symbol on the dorsal
  carapace, identifies the elite type

Stack at most ONE pattern overlay per variant. Stacking two creates a
visual mush that breaks the silhouette test.

### Knob 6: Aura

Per the PackLeaderAura component (task 47), elite variants get an aura
sphere. Aura color matches the variant's crack hue, with intensity
based on rank:

| Rank | Aura intensity | Aura radius |
|---|---|---|
| Standard non-leader | none | — |
| Pack leader | 1.6 | 1.6 m |
| Elite | 2.4 | 2.0 m |
| Mini-boss (Alpha rank) | 3.2 | 2.6 m |
| Queen (boss) | 4.0 | 3.5 m |

### Knob 7: Wing membrane state

The wing membranes are visible only during the aggro rear-up pose
(see concept silhouettes doc). Per-variant rules:

- **Standard**: closed at rest, fully exposed during aggro
- **Swarm**: wing membranes vestigial — barely visible
- **Alpha / Queen**: wings can be displayed during idle as a passive
  intimidation pose at the cost of speed (Queen only)
- **Cold variant**: wings have frost crystals along the leading edge
- **Venom variant**: wings are slightly torn/ragged
- **Spectral variant** (post-launch): wings are translucent purple
  with internal motion-blur ghost trails

### Knob 8: Footstep effect

Each variant gets a unique footstep particle/decal hook:

| Variant | Footstep effect |
|---|---|
| Standard | Soft dust puff |
| Swarm | None (tiny, doesn't disturb ground) |
| Alpha | Heavier dust + small ground crack decal that fades in 3s |
| Queen | Ground crack decal that LINGERS (never fades during the fight) |
| Venom | Acid puddle decal that lingers 12s |
| Cold | Frost patch decal that lingers 8s + slow zone |
| Tox | Toxic gas puff |

## Per-variant data files

Each variant lives as a Resource file at:
`res://data/enemies/variants/glitchbug_<variant>.tres`

The Resource fields (using a future EnemyVariant resource class):

```gdscript
class_name EnemyVariant extends Resource
@export var variant_id: StringName
@export var display_name: String
@export var base_enemy_id: StringName  # &"glitchbug" for all GlitchBug variants

# Visual knobs
@export var body_scale: float = 1.0
@export var mandible_scale: float = 1.0
@export var plate_density: float = 1.0
@export var crack_color_a: Color
@export var crack_color_b: Color
@export var pattern_overlay: StringName  # &"stripe", &"spot", &"frost", ...
@export var aura_intensity: float = 0.0
@export var aura_radius: float = 0.0

# Stat modifiers (relative to base GlitchBug stats)
@export var hp_mult: float = 1.0
@export var damage_mult: float = 1.0
@export var speed_mult: float = 1.0
@export var aggro_radius_mult: float = 1.0

# Behavioral
@export var has_pack_leader_aura: bool = false
@export var leaves_footstep_decal: bool = false
@export var footstep_decal_path: String

# Loot
@export var loot_table_override: Resource
@export var xp_value_override: int = -1
```

## Variant launch list

These are the variants planned through season 2:

### Launch (in Epic 04)
1. **GlitchBug Standard** — base species, cyan + magenta
2. **GlitchBug Venom** — red + amber, drips acid, applies poison stack
3. **GlitchBug Cold** — blue + white, slows on hit, leaves frost
4. **GlitchBug Tox** — green + yellow, AoE toxic puff on death
5. **GlitchBug Elite** — purple + gold, larger, has pack leader aura

### Size variants (also in Epic 04)
6. **Swarm GlitchBug** — small, fast, weak, spawns in groups of 4-8
7. **Alpha GlitchBug** — large, slow, hard-hitting, mini-boss tier
8. **GlitchBug Queen** — boss-scale, drops rare loot, summons swarms

### Post-launch / season 1
9. **Spectral GlitchBug** — ghost variant, phases through walls
10. **Hex GlitchBug** — applies debuff aura, low HP, support role

### Post-launch / season 2
11. **Royal GlitchBug** — gold + emerald, drops cosmetic
12. **Plague GlitchBug** — environmental hazard variant

## Validation checklist for any new variant

Before merging a new GlitchBug variant, verify:

- [ ] At 64×64 px silhouette, the variant is recognizable as a
      GlitchBug (passes the species silhouette test)
- [ ] At 64×64 px silhouette, the variant is distinguishable from at
      least 2 other variants by silhouette outline alone
- [ ] The crack hue at 6m camera distance is the dominant single color
      cue identifying the variant
- [ ] All 6 base poses (idle/alert/aggro/lunge/bite/death) work with
      the variant's mesh + scale without clipping
- [ ] If the variant has an aura, the aura color matches the crack hue
- [ ] The variant's mandible spread silhouette is wider than its body
      width × 1.2
- [ ] None of the variant's overlays exceed ONE pattern overlay rule
- [ ] The variant's death dissolve uses the matching crack hue for the
      edge color (CorpsePersistence dissolve_edge_color)
- [ ] The variant's HitGlitchDriver pulse uses the matching crack hue
      for the impact emission

## Anti-patterns (DO NOT do these)

- **Don't add 8-leg variants.** That's a spider, not a GlitchBug.
- **Don't add wings that the variant flies with.** GlitchBugs are
  ground predators; the wings are display only.
- **Don't add a "blind" variant** — the eye pits are part of the
  species silhouette and should always be present (even if recessed).
- **Don't make the variant fundamentally cute or friendly.** Even the
  Queen mini-boss should read as an apex predator. GlitchBugs are
  the "enemy you fear" of the bestiary.
- **Don't add particle trails.** The crack pattern is the only
  glitch effect carried by the variant. Trail effects make them look
  like a different enemy family.
- **Don't add color hues in the green-lime range that AREN'T the Tox
  variant.** Lime green is a reserved identifier hue for Tox; using
  it elsewhere will confuse players.

## Variant family summary at-a-glance

```
GLITCHBUG family
├── Cyan/magenta — Standard         (base)
├── Red/amber    — Venom            (toxic)
├── Blue/white   — Cold             (slow)
├── Green/yellow — Tox              (acid)
├── Purple/gold  — Elite            (leader, +stats)
├── Gold/emerald — Royal            (cosmetic post-launch)
├── White/cyan   — Spectral         (phase, post-launch)
├── Black/red    — Hex              (debuff, post-launch)
└── SCALES
    ├── 0.5×   Swarm                (small, weak, packs of 6+)
    ├── 1.0×   Standard
    ├── 1.7×   Alpha                (mini-boss tier)
    └── 2.6×   Queen                (full boss)
```

Cross-pollinate scale and color: a "Cold Alpha" = blue/white at 1.7×.
A "Tox Queen" = green/yellow at 2.6×. The variant Resource file is
the only thing needed to instantiate the cross — no per-cross asset
authoring required, the existing knob system handles it.
