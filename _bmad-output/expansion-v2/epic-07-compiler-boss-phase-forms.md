---
name: Epic 07 — Compiler Boss Phase Forms
description: Per-phase silhouette specs, attack patterns, transition triggers, and bone budget for the Corrupted Compiler 3-phase boss
epic: 07
created: 2026-04-09
---

# Corrupted Compiler — 3 Phase Forms

## Phase 1 — "Compiler at Work" (HP 100% → 66%)

### Silhouette
- **Height:** 4.0m (Globbler is 1.5m)
- **Width:** 3.0m at shoulders, 2.0m at base
- **Pose:** Symmetric, T-pose neutral. Both shoulder pairs spread evenly.
- **Footprint:** Circular base 2m diameter, anchored to ground. Cannot
  walk — only rotates around its base axis.

### Geometry breakdown
- **Lower base:** 1.2m tall cylindrical column with 4 ground-tether
  attachment points spaced 90deg around. The column has 8 vertical fins
  for cooling (server-rack reference).
- **Mid torso:** 1.5m tall rectangular slab with 6 horizontal panel
  divisions. Each panel has cyan LED accents along the seam. The chest
  has a recessed circular cavity 0.4m wide containing the **CORE**.
- **Shoulder cluster:** 2 shoulder pairs stacked vertically. Upper pair
  at 3.2m, lower pair at 2.5m. Each shoulder has a chrome ball joint.
- **Arms (4 total):** Each arm is a 4-segment articulated chain ending
  in a 3-finger chrome manipulator hand. Total arm length 1.8m fully
  extended.
- **Head:** A small antenna cluster at 4.0m. NOT a face — the face is
  the chest core. The head houses processing antennas only.

### Material
- Body: gunmetal panels (#1A1F26) with chrome trim (#D8DCE6)
- LEDs: cyan (#00F2F2) at strength 5.0
- Core: deep cyan recessed glow (#0095CC) at strength 8.0
- Tethers: cyan cables (#0095CC) at strength 4.0

### Attacks
1. **Ground Slam (close, 4.0s windup)** — One arm raises high, slams
   down. Impact zone is a 4m circle directly in front. Damage 30. Wave
   ripples outward causing aftershock damage 15 in 6m circle 0.3s after
   impact.

2. **Sweep Beam (medium, 3.0s windup)** — Core charges visibly with
   cyan light, then fires a horizontal beam that sweeps 180deg in front
   of the boss over 1.2s. Damage 25 + brief stun. Cleared by jumping or
   getting behind cover.

3. **Summon Adds (mid-fight, 5.0s windup)** — Boss raises both upper
   arms, opens 4 panel sections on torso. 4 RogueProcess Scout add
   spawn from the panels and drop to the arena floor. Cooldown 30s.

### Transition trigger
HP drops to 66% → triggers Phase 1 → 2 transition animation. During the
transition the boss is INVULNERABLE for 4 seconds.

---

## Phase 2 — "Glitching, Fragmenting" (HP 66% → 33%)

### Silhouette
- **Height:** 6.0m (was 4.0m — boss has grown taller as panels burst open)
- **Width:** 4.0m at shoulders. Right shoulder is shattered and 1.5m of
  debris floats in a halo around it.
- **Pose:** Slightly hunched, asymmetric. Right side damaged, left side
  intact but wired with crackling magenta energy.
- **New geometry:**
  - **Floating debris halo:** 12 chunks of body fragment orbiting at
    1-2m radius, slowly rotating
  - **2 new arms:** Phase 2 grows 2 additional arms from the back, made
    of damaged chrome with magenta cracks. These arms are partially
    fragmented — visible chunks missing from the elbow + wrist
  - **Exposed core:** The chest core is now visibly EXPOSED. The recess
    panel has shattered. Magenta energy leaks from the surrounding cracks

### Material
- Body: phase-1 gunmetal + magenta cracks (#FF1AD9) at strength 6.0
- Cracks pulse in time with the core
- RGB channel split applied via shader: red and blue chromatic aberration
  baked into the body texture sample
- Floating debris uses a glitchy displacement shader (vertices jitter)

### Attacks
1. **Multi-projectile barrage (1.0s windup)** — 6 of the new arms each
   fire a magenta projectile in a spread pattern. Each projectile travels
   in a slight curve toward Globbler's last known position. Damage 12
   per hit. Cooldown 8s.

2. **Teleport Strike (instant)** — Boss disappears in a glitch flash,
   reappears 5m closer to Globbler with one arm slamming. Damage 35
   on hit. Cooldown 12s.

3. **Arena Hazard Spawn (4.0s windup)** — Boss raises both upper arms.
   3 magenta hazard zones (1.5m radius each) appear at random arena
   positions. After 1.5s they explode dealing 25 damage to anyone inside.
   Cooldown 18s.

### Transition trigger
HP drops to 33% → triggers Phase 2 → 3 transition. INVULNERABLE 5 seconds.
The transition involves the floating debris halo collapsing INWARD into
the body and reforming as the data arms.

---

## Phase 3 — "Full Corruption" (HP 33% → 0%)

### Silhouette
- **Height:** 9.0m (massive — camera must back out)
- **Width:** 5.0m at shoulders + 1.5m on each side from data arm extensions
- **Pose:** Asymmetric, twisted, terrifying. Body slightly leans
  forward toward the player as if straining against the tethers.
- **New geometry:**
  - **8 arms:** 4 are the corrupted versions of phase 1's chrome arms
    (now dark crimson with thick magenta cracks). 4 are pure cyan ENERGY
    arms made of vertex-deformed translucent geometry — they don't have
    fixed length, they extend on demand
  - **Open chest cavity:** The torso is torn open at chest level
    revealing the bright white-cyan emissive HEART core, suspended in
    the cavity by 4 thin energy strands
  - **Code rivulets:** Visible ASCII characters scrolling across every
    surface of the body. Implemented as a code-stream texture sample
    in the corrupted body shader
  - **Tether strain:** The ground tethers are now CRIMSON and visibly
    straining. They pulse and flicker. The boss is fighting them.

### Material
- Body: dark corrupted (#0F0510) + crimson cracks (#FF1A0A) at strength 8.0
- Heart core: white-cyan (#FFFFFF + #00FFEE rim) at strength 15.0
- Code rivulets: black ASCII text on bright cyan background
- Energy arms: pure cyan transparent fresnel-rim shader
- Tethers: crimson straining (#FF1A0A) at strength 5.0

### Attacks
1. **Arena-Wide AoE (5.0s windup)** — Boss raises ALL 8 arms. Floor
   pattern indicators show the safe zones (only 30% of arena floor is
   safe). Whole arena explodes dealing 50 damage to anyone outside the
   safe zone. Cooldown 30s.

2. **Chase Laser (continuous, 8s duration)** — Boss locks one of the
   energy arms onto Globbler. The arm tracks Globbler with a continuous
   beam that slowly rotates to follow. Damage 5/sec while in beam.
   Stops when Globbler breaks line of sight using cover pillars.

3. **Gravity Well (3.0s windup)** — Boss creates a black sphere at a
   random arena position. Sphere PULLS Globbler toward it with strong
   force. After 2s the sphere collapses dealing 60 damage in a 4m circle.
   Cooldown 25s.

### Phase 3 ULTIMATE
**Room-clearing pulse (10.0s windup, used at 10% HP)**
- Boss raises ALL 8 arms in slow synchronized movement
- The floor of the arena lights up with concentric circles
- Heart core bulges, brightens to 30.0 emission
- Player has 3.0s of dodge window after the windup completes
- Pulse expands outward at 8m/s clearing the entire arena
- Damage 80 (one-shots Globbler unless dodged behind a cover pillar
  with the cover pillar facing the boss)
- After ultimate, boss is staggered for 3.0s — the kill window

### Death sequence (8s cinematic)
1. **0.0s** — Boss takes killing blow. ALL emission flashes white.
2. **1.0s** — All 4 chrome arms break off and fall. Debris halo collapses.
3. **2.5s** — Energy arms dissipate into particles.
4. **4.0s** — Heart core ruptures with a final pulse.
5. **5.5s** — Tethers snap audibly. Body falls forward.
6. **7.0s** — Body hits arena floor with massive dust impact.
7. **8.0s** — Final crackle, then silence. Loot chest spawns.

---

## Bone budget per phase

| Bone group | P1 | P2 | P3 |
|---|---|---|---|
| Base + tethers | 8 | 8 | 8 |
| Spine (lower/mid/upper) | 3 | 3 | 3 |
| Neck + head | 2 | 2 | 2 |
| Chest core | 1 | 1 | 1 |
| Arms (4 segments × 4 arms) | 16 | — | — |
| Arms (4 × 4 + 4 × 4 fragmented) | — | 32 | — |
| Arms (8 × 4) — incl 4 energy | — | — | 32 |
| Floating debris (halo) | — | 12 | — |
| Heart cavity strands | — | — | 4 |
| **Total** | **30** | **58** | **50** |

The MAXIMUM bone count is 58 (phase 2), well within the 50-bone task spec
limit when we strip the orbital debris into a separate non-bone-driven
particle system. Final rig: **50 unified bones** with the debris driven
by GPUParticles instead of bones.

---

## Phase transition triggers

| Trigger | At HP | Duration | Boss state |
|---|---|---|---|
| P1 → P2 | 66% | 4s | INVULNERABLE |
| P2 → P3 | 33% | 5s | INVULNERABLE |
| P3 ultimate | 10% | 10s windup | INVULNERABLE during windup |

## Cross-phase bone re-use rule

The bones for phase 1 are a SUBSET of phase 2 which is a SUBSET of phase 3.
This means animation curves authored for phase 1 can be re-used in phase
2/3 for the same bones. Additive arm bone curves layered on top.

## What this means for the Blender file structure

```
Compiler_Boss_Master.blend
├── Armature_Compiler (50 bones, all phases)
├── Compiler_P1 collection
│   ├── compiler_p1_lower_base
│   ├── compiler_p1_mid_torso
│   ├── compiler_p1_chest_core
│   ├── compiler_p1_shoulder_cluster
│   ├── compiler_p1_arm_R1, _R2, _L1, _L2 (4 arms)
│   └── compiler_p1_head
├── Compiler_P2 collection (P1 base + extras)
│   ├── compiler_p2_cracked_overlay
│   ├── compiler_p2_arm_R3, _L3 (2 new arms)
│   ├── compiler_p2_floating_debris_anchors (12 mounts)
│   └── compiler_p2_exposed_core
└── Compiler_P3 collection (P2 base + extras)
    ├── compiler_p3_corrupted_overlay
    ├── compiler_p3_data_arm_R1, _R2, _L1, _L2 (4 energy arms)
    ├── compiler_p3_open_chest
    └── compiler_p3_heart_core
```
