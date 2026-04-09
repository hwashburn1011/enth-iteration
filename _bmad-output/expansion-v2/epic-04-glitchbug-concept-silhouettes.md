---
name: Epic 04 — GlitchBug Concept Silhouettes
description: 6 detailed pose specifications for the photoreal GlitchBug remake — drives the modeling and rigging passes
epic: 04
created: 2026-04-09
---

# GlitchBug Concept Silhouettes — 6 Pose Specifications

These are the 6 reference poses every later Epic 04 task must support.
Each is specified to the level of body-part position and rotation so a
modeler can blockout the rig and pose it exactly without further design
ambiguity.

## Body coordinate system

- Origin at the ground center beneath the body's pelvis joint
- +Y = forward (head direction)
- +Z = up
- +X = the body's right side (its own anatomical right)
- All angles are degrees, all positions are meters
- "Pitch" rotates around the body-relative X axis
- "Yaw" rotates around the body-relative Z axis
- "Roll" rotates around the body-relative Y axis

## Body parts (referenced in every pose)

| Part | Default position | Notes |
|---|---|---|
| pelvis | (0, 0, 0.40) | Body weight center |
| thorax | (0, 0.20, 0.50) | Forward of pelvis, slightly higher |
| head | (0, 0.65, 0.42) | At end of thorax |
| mandible.R / .L | head + (±0.32, 0.30, 0) | Symmetric horns |
| antenna.R / .L | head + (±0.10, 0.20, 0.13) | Tall thin |
| abdomen | (0, -0.40, 0.36) | Behind pelvis |
| leg.F.R / .F.L | pelvis + (±0.42, 0.35, 0) | Front raptorial pair |
| leg.M.R / .M.L | pelvis + (±0.45, 0.05, 0) | Mid pair |
| leg.R.R / .R.L | pelvis + (±0.42, -0.35, 0) | Rear (longest) pair |
| wing.case | thorax + (0, -0.05, 0.25) | Hard elytra cover |
| wing.membrane.R / .L | hidden under wing.case at rest | Translucent |

Each leg has 3 segments: coxa→femur (upper), tibia (lower), tarsus
(foot tip). Standing leg pose has the foot tip touching ground at the
splay distance.

---

## Pose 1 — IDLE STAND

> **Reads as:** A predator at rest. Low. Wide. Patient. Could spring at
> any moment without telegraphing.

- **pelvis**: position (0, 0, 0.40), rotation (0, 0, 0)
- **thorax**: pitch +5° (slight downward tilt of the front)
- **head**: pitch +8° (looking slightly down — scanning the floor)
- **mandible.R**: yaw -10° (slightly open, ~20° spread total)
- **mandible.L**: yaw +10°
- **antenna.R**: pitch +5°, droop -15° from vertical
- **antenna.L**: pitch +5°, droop -15° from vertical
- **abdomen**: pitch +0°, hanging level
- **leg.F.R**: coxa yaw +60°, femur pitch -10° (foot at +0.85 X, ground)
- **leg.F.L**: mirror
- **leg.M.R**: coxa yaw +85°, femur pitch -5° (foot at +1.10 X, ground)
- **leg.M.L**: mirror
- **leg.R.R**: coxa yaw +110°, femur pitch -8° (foot at +0.95 X, -0.7 Y, ground)
- **leg.R.L**: mirror
- **wing.case**: closed flat against thorax
- **wing.membrane**: hidden

**Silhouette test:** body should read as a wide horizontal oval with 6
splayed legs forming a low, broad triangle. Mandible spread is ~1.2× the
body width — slightly open. Antennae droop forward and down.

---

## Pose 2 — ALERT

> **Reads as:** Just noticed the player. Body raised, scanning, mandibles
> wide. The "I see you" pose.

- **pelvis**: position (0, 0, 0.55) — RAISED 15cm from idle
- **thorax**: pitch -5° (tilted slightly UP — head higher than thorax)
- **head**: pitch -15° (looking forward and slightly up)
- **mandible.R**: yaw -25° (FULLY OPEN, 50° total spread)
- **mandible.L**: yaw +25°
- **antenna.R**: pitch -10°, ERECT vertical, slight twitch +/- 5°
- **antenna.L**: pitch -10°, ERECT vertical, slight twitch +/- 5°
- **abdomen**: pitch -5° (tucked up slightly)
- **leg.F.R**: coxa yaw +55°, femur pitch -25° (legs stiffen straighter)
- **leg.F.L**: mirror
- **leg.M.R**: coxa yaw +85°, femur pitch -15° (slightly compressed to push body up)
- **leg.M.L**: mirror
- **leg.R.R**: coxa yaw +105°, femur pitch -20°
- **leg.R.L**: mirror
- **wing.case**: still closed but the elytra ridge is visibly tense
- **wing.membrane**: hidden

**Silhouette test:** body sits 30% higher than idle. Mandibles spread
1.6× body width. Antennae read as two vertical exclamation marks rising
from the head. Visibly different silhouette from idle even at 64×64.

---

## Pose 3 — AGGRO REAR-UP

> **Reads as:** Maximum threat display. Front legs raised mantis-style.
> Wing case partially open exposing the cyan underbelly seam. The pose
> a player should learn to fear within 2 seconds of seeing it.

- **pelvis**: position (0, 0, 0.55)
- **thorax**: pitch -45° (the front of the body is tilted UP sharply)
- **head**: pitch -50° (looking nearly straight up at the player)
- **mandible.R**: yaw -30° (full spread)
- **mandible.L**: yaw +30°
- **antenna.R**: pitch -25°, erect+forward
- **antenna.L**: pitch -25°, erect+forward
- **abdomen**: pitch -20° (lifting with the body)
- **leg.F.R**: coxa yaw +30°, femur pitch -110° — RAISED OVERHEAD,
  raptorial folded position with tibia bent back toward femur (see
  "raptorial fold" below)
- **leg.F.L**: mirror
- **leg.M.R**: coxa yaw +85°, femur pitch -35° (planted, supporting weight)
- **leg.M.L**: mirror
- **leg.R.R**: coxa yaw +95°, femur pitch -50° (planted, bracing back)
- **leg.R.L**: mirror
- **wing.case**: HALF-OPEN — elytra raised 60° from closed position,
  exposing the wing membranes underneath AND the cyan underbelly seam
  along the thorax-abdomen joint
- **wing.membrane.R / .L**: visible, partially extended, iridescent

**Raptorial fold for front legs**: femur points up, tibia bent ~120°
back toward femur so the foot tip is roughly even with the femur joint.
This is the mantis "praying" pose — the loaded position before a strike.

**Silhouette test:** the body forms a vertical "Y" — front legs up,
abdomen down. Read at 64×64 as: low triangle becomes a vertical lance.
The cyan glow strip along the thorax-abdomen seam should be the brightest
pixel in the frame.

---

## Pose 4 — LUNGE MID-AIR

> **Reads as:** Committed. Airborne. Body fully extended forward like an
> arrow. The frame between aggro-rear and bite contact.

- **pelvis**: position (0, +0.40, 0.50) — pelvis displaced FORWARD 40cm
  from rest (the bug has moved with the lunge)
- **thorax**: pitch +20° (whole body tilted nose-down for the dive)
- **head**: pitch +25° (ahead of the body, leading the strike)
- **mandible.R**: yaw -28° (open, about to bite)
- **mandible.L**: yaw +28°
- **antenna.R**: pitch +35° (swept BACK by the wind of motion)
- **antenna.L**: pitch +35°
- **abdomen**: pitch +25° (tucked up tight to body for streamlining)
- **leg.F.R**: coxa yaw +45°, femur pitch +20° — extended FORWARD
  (the raptorial position swung forward, ready for the impact grab)
- **leg.F.L**: mirror
- **leg.M.R**: coxa yaw +90°, femur pitch +60° — TRAILING BACK
- **leg.M.L**: mirror
- **leg.R.R**: coxa yaw +130°, femur pitch +75° — TRAILING FAR BACK,
  almost horizontal behind body (no ground contact, the bug is airborne)
- **leg.R.L**: mirror
- **wing.case**: open 30°, providing a small surface for the lunge
- **wing.membrane.R / .L**: extended, blurred motion

**Silhouette test:** the body forms a forward-pointing arrow. All 6
legs trail BEHIND the body. No ground contact. The 90s trailer cut
should use this pose — it's the most kinetic.

---

## Pose 5 — BITE

> **Reads as:** Contact frame. Mandibles closed, body weight driven
> down through all 6 legs. The damage frame.

- **pelvis**: position (0, +0.40, 0.32) — DROPPED 8cm from rest
  (body has slammed down post-lunge)
- **thorax**: pitch +15° (front of body lower than rear)
- **head**: pitch +30° (driving down into the target)
- **mandible.R**: yaw -3° (CLOSED, only ~6° open)
- **mandible.L**: yaw +3°
- **antenna.R**: pitch +20° (still swept back from the impact)
- **antenna.L**: pitch +20°
- **abdomen**: pitch +10° (level with body)
- **leg.F.R**: coxa yaw +70°, femur pitch +5° — splayed forward+ground,
  weight on
- **leg.F.L**: mirror
- **leg.M.R**: coxa yaw +90°, femur pitch +0° — straight out, weight on
- **leg.M.L**: mirror
- **leg.R.R**: coxa yaw +115°, femur pitch -5° — splayed back+ground
- **leg.R.L**: mirror
- **wing.case**: closed
- **wing.membrane**: hidden

**Silhouette test:** all 6 legs touch ground in a wide tripod brace.
Body is the lowest of all 6 poses — head almost at ground level.
Mandibles closed read as a spike pointing forward. Damage hitbox is the
mandible tip.

---

## Pose 6 — DEATH CURL

> **Reads as:** Defeated. Inverted. Pre-dissolve. The player's reward
> moment.

- **pelvis**: position (0, 0, 0.20) — body has fallen, sitting on its
  carapace top with the underbelly facing UP
- **thorax**: pitch +180° (rolled onto its back)
- **head**: pitch +160° (head turned away, lifeless)
- **mandible.R**: yaw -5° (slack, slightly open)
- **mandible.L**: yaw +5°
- **antenna.R**: pitch +180°, dangling
- **antenna.L**: pitch +180°, dangling
- **abdomen**: pitch +180° (curled in toward the underside)
- **leg.F.R**: coxa yaw +20°, femur pitch -160°, tibia bent 130° —
  ALL 6 LEGS curled inward toward the upturned underbelly, like a
  dead spider
- **leg.F.L**: mirror
- **leg.M.R**: coxa yaw +30°, femur pitch -150°, tibia bent 140°
- **leg.M.L**: mirror
- **leg.R.R**: coxa yaw +40°, femur pitch -140°, tibia bent 120°
- **leg.R.L**: mirror
- **wing.case**: cracked open at multiple seams (death damage)
- **wing.membrane**: visible, with the magenta dissolve fragments
  detaching and drifting upward

**Silhouette test:** the body forms an inverted half-dome with all 6
legs sticking up like dead-spider lines. This is the universally-read
"dead bug" silhouette. The dissolve fragments crawling upward through
the magenta seams are what tell the player this is a CORRUPTED creature
dying, not just a regular bug.

---

## Production checklist for these 6 poses

- [ ] Each pose must be buildable from the same rig (no per-pose mesh
      authoring)
- [ ] Each pose must read at 64×64 px against a flat background as a
      different silhouette from all 5 others
- [ ] Each pose must be a single keyframe — no in-between poses count
      against this set
- [ ] These 6 are the BASE poses; tasks 15-23 will animate transitions
      between them with the timing spec from the reference bible

## How later Epic 04 tasks use these silhouettes

- **Task 14 (rig 24 bones)**: ensure every joint listed above
  (coxa/femur/tibia/tarsus per leg, head/mandible/antenna pitches) is
  individually controllable
- **Tasks 15-18**: idle = pose 1, walk = transitions between pose 1
  variants with leg cycle, run = pose 1 with faster cycle, aggro =
  transition to pose 3
- **Task 19**: lunge = transition from pose 3 → pose 4 → pose 5
- **Task 20**: bite = transition from pose 5 with tighter mandible
  closure cycle
- **Task 21 (hit reaction)**: pose 1 with body recoil away from hit
  direction
- **Task 22 (death)**: transition from pose 1 to pose 6 over ~24
  frames + 60 frames hold + 30 frames dissolve
