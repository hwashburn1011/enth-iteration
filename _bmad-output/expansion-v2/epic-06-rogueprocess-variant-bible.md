---
name: Epic 06 — RogueProcess Variant Bible
description: Per-variant design rules for all RogueProcess archetypes — drives variant work in Epic 06 and beyond
epic: 06
created: 2026-04-09
---

# RogueProcess Variant Bible

## Purpose

Same role as the GlitchBug + MemoryLeak variant bibles. Drives all
RogueProcess archetypes — Scout, Gunner, Brute, Hacker, the Sentinel
miniboss, and any post-launch additions.

## What stays the same across ALL archetypes

These are inviolable family traits.

1. **Silhouette signature**: floating humanoid TORSO with NO legs.
   The body fades into thruster glow at ~0.45m above the ground. The
   2 antenna asymmetry (only one side) is preserved across all
   archetypes — never both, never zero.

2. **Material story**: cold polished metal + bright alert emission.
   No organic surfaces, no warm hues on the body itself (the warm
   thruster glow is allowed because it's particles + light, not body
   surface).

3. **Animation language**: floats then snaps. Idle bob is smooth,
   attack/aggro transitions snap with no anticipation. The float
   tempo + snap action contrast is the species signature.

4. **4-6 lensed sensors with primary/auxiliary distinction**: every
   archetype has 2 large primary optical sensors that strobe between
   cyan (scanning) and red (combat) AND smaller dim auxiliary sensors
   that always glow at low intensity (the wrongness factor — too
   many eyes for a humanoid).

5. **Smooth featureless lower face plate**: no mouth on any archetype.
   The face plate is always a smooth gunmetal panel below the sensors.

6. **Same 22-bone rig**: variants don't add bones. Archetype-specific
   weapons and accessories are MESH attachments to existing bones, not
   new skeletal joints.

## What CHANGES per archetype

### Knob 1: Body proportions

Each archetype has slightly different body proportions to match its
combat role:

| Archetype | Body width | Body height | Shoulder span | Notes |
|---|---|---|---|---|
| Scout | 0.85x | 0.95x | 0.85x | slimmer for surveillance role |
| Standard | 1.0x | 1.0x | 1.0x | baseline |
| Gunner | 1.10x | 1.0x | 1.25x | wider shoulders for cannon mounts |
| Brute | 1.20x | 1.10x | 1.20x | bulkier all over |
| Hacker | 0.90x | 1.0x | 0.90x | slender, taller-feeling |
| Sentinel | 1.30x | 1.20x | 1.30x | mini-boss tier |

### Knob 2: Weapon mount meshes

Each archetype has unique weapon meshes parented to existing bones:

| Archetype | Weapon mesh | Mounted at | Effect |
|---|---|---|---|
| Scout | Single antenna sensor | extra antenna bone | enhanced detection range |
| Gunner | Twin shoulder cannons | shoulder.R/L | replaces hand-claw attack with ranged |
| Brute | Blade-claws on both hands | hand_claw.R/L | +50% melee damage |
| Hacker | Hovering aux device | back_exhaust | applies status effects via cyan beam |
| Sentinel | Quad sensor array on head | head | applies "marked" debuff via gaze |

### Knob 3: Sensor count + arrangement

| Archetype | Primary sensors | Auxiliary sensors | Notes |
|---|---|---|---|
| Scout | 2 | 2 | minimum sensor count (4 total) — sleek surveillance |
| Standard | 2 | 3 | reference baseline (5 total) |
| Gunner | 2 | 2 | minimum (4) — focused on targeting |
| Brute | 2 | 4 | wider spread (6) — more peripheral awareness |
| Hacker | 2 | 4 | wider spread (6) — needs to see status info |
| Sentinel | 2 | 6 | maximum spread (8) — total surveillance, the wrongness peaks here |

### Knob 4: Alert color

The cyan→red sensor strobe is the species default. Variant archetypes
shift the alert color to match their faction:

| Archetype | Idle scan color | Combat alert color |
|---|---|---|
| Scout | cyan 0.0/0.95/0.95 | yellow 1.0/0.85/0.05 (warning, not red) |
| Standard | cyan | red 1.0/0.10/0.05 |
| Gunner | cyan | red |
| Brute | cyan | crimson 0.85/0.05/0.05 (deeper red) |
| Hacker | cyan | magenta 1.0/0.10/0.85 |
| Sentinel | white 0.95/0.95/1.0 | cyan-white pulsing (both colors at once — boss tier) |

### Knob 5: Hover height

| Archetype | Hover altitude | Notes |
|---|---|---|
| Scout | 0.55m | slightly higher — better vantage point |
| Standard | 0.45m | baseline |
| Gunner | 0.40m | slightly lower — more stable cannon platform |
| Brute | 0.35m | lowest — heavy body sags |
| Hacker | 0.55m | higher — out of melee reach |
| Sentinel | 0.65m | highest, looks down at the player |

### Knob 6: Stat modifiers

| Archetype | HP | Damage | Speed | Aggro |
|---|---|---|---|---|
| Scout | 0.7x | 0.5x | 1.4x | 1.5x |
| Standard | 1.0x | 1.0x | 1.0x | 1.0x |
| Gunner | 0.9x | 1.4x | 0.8x | 1.2x |
| Brute | 1.8x | 1.5x | 0.7x | 1.0x |
| Hacker | 0.8x | 0.8x | 1.0x | 1.3x |
| Sentinel | 5.0x | 2.5x | 0.6x | 2.0x |

### Knob 7: Special behavior

| Archetype | Special |
|---|---|
| Scout | Calls reinforcements when player spotted (broadcasts position to nearby allies) |
| Standard | None — baseline ranged + melee |
| Gunner | Twin-shot ranged attack (2 projectiles per fire) |
| Brute | Charge attack — dashes through player, knockback |
| Hacker | Applies "hacked" debuff: player abilities go on extended cooldown |
| Sentinel | Boss-tier: spawns Scout reinforcements every 30s during fight |

### Knob 8: Aura

Per the PackLeaderAura component, only the Sentinel + Hacker get auras:

| Archetype | aura_intensity | aura_radius |
|---|---|---|
| Scout | none | — |
| Standard | none | — |
| Gunner | none | — |
| Brute | none | — |
| Hacker | 1.5 | 3.0m (the "support" aura buffs nearby allies' fire rate) |
| Sentinel | 3.5 | 4.5m (the boss-tier aura) |

## Per-variant Resource files

Following the same EnemyVariant Resource pattern:
`res://data/enemies/variants/rogueprocess_<archetype>.tres`

Schema fields used:
- variant_id, display_name, base_enemy_id = &"rogueprocess"
- body_scale (driven by Knob 1 width/height average)
- crack_color_a/b mapped to idle_scan_color and combat_alert_color
  from Knob 4 (the routing in VariantBodyUpgrade pushes these into
  the holographic_damage_flash + carapace shaders)
- hp_mult, damage_mult, speed_mult, aggro_radius_mult from Knob 6
- has_pack_leader_aura true for Hacker + Sentinel
- aura_intensity, aura_radius from Knob 8
- pattern_overlay used for archetype-specific decorations
- applies_status_effect: Hacker = &"hacked", Sentinel = &"marked"

## Variant launch list

Launch (in Epic 06):
1. **RogueProcess Standard** — base archetype
2. **RogueProcess Scout** — surveillance, calls reinforcements
3. **RogueProcess Gunner** — twin shoulder cannons
4. **RogueProcess Brute** — melee charger, blade-claws
5. **RogueProcess Hacker** — debuffer, support aura

Mid-boss:
6. **RogueProcess Sentinel** — boss-tier with quad sensor array

Post-launch:
7. **RogueProcess Phantom** — phase variant (post-launch, related to GlitchBug Spectral)
8. **RogueProcess Royal** — gold-trim cosmetic

## Validation checklist

- [ ] At 64×64 px silhouette, the variant is recognizable as a
      RogueProcess (humanoid torso + thruster pillar + asymmetric
      antenna)
- [ ] At 64×64 px silhouette, the variant is distinguishable from
      at least 2 other archetypes by silhouette outline alone
      (shoulder span, hover height, weapon mount)
- [ ] The variant has NO leg geometry below hover_anchor
- [ ] The variant has NO mouth, NO smile, NO friendly face
- [ ] The variant has 4-8 lensed sensors with at least 2 primary
      and at least 2 auxiliary (the "wrongness" minimum)
- [ ] One asymmetric antenna is present (right OR left side, not
      both, not zero)
- [ ] The variant uses the same 22-bone rig (or 22 + extra mount
      bones for shoulder cannons / aux devices)
- [ ] The combat alert sensor color is distinct from idle cyan
- [ ] The thruster glow remains visible (no covering coat or skirt
      that hides the warm pillar of light below the torso)
- [ ] The hit reaction uses holographic_damage_flash.gdshader (not
      the GlitchBug's enemy_hit_glitch fragmentation — RogueProcess
      hits should glitch as a hologram, not fragment)

## Anti-patterns specific to RogueProcess archetypes

- **Don't add legs.** Even mechanical legs. The "no legs" silhouette
  is the species defining trait. The thruster pillar is the visual
  replacement.
- **Don't add a mouth.** The smooth lower face plate is the
  uncanny-valley trigger.
- **Don't make a friendly archetype.** Even the Scout (which has the
  yellow-warning instead of red-combat alert) should still trigger
  threat response. No cute, no helpful, no companion.
- **Don't make both antennae.** The asymmetric single antenna is the
  species "this is wrong" tell. Adding a second one makes it look
  symmetric and balanced — which destroys the uncanny effect.
- **Don't put the hit_glitch shader on the RogueProcess.** Use the
  holographic_damage_flash shader instead. The fragmentation effect
  is the GlitchBug's hit reaction — the RogueProcess hits read as
  hologram flicker because it's a machine, not an organism.

## Cross-pollination matrix

Like the other species, RogueProcess archetypes can cross-pollinate
with elemental hues (post-launch). A "Hacker Scout" would be a
Scout-proportions body with the Hacker's hovering aux device + magenta
combat color + reinforcement-call special behavior. The variant
Resource carries the deltas; no per-cross asset authoring needed
beyond the unique weapon mount meshes which are added once per
archetype family.
