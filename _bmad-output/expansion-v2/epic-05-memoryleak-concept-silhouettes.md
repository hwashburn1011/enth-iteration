---
name: Epic 05 — MemoryLeak Concept Silhouettes
description: 6 detailed body shape configurations for the photoreal MemoryLeak — drives the modeling, rigging, and animation passes
epic: 05
created: 2026-04-09
---

# MemoryLeak Concept Silhouettes — 6 Body Shape Specifications

These are the 6 reference body configurations every later Epic 05 task
must support. Unlike the GlitchBug (which has rigid skeletal poses), the
MemoryLeak is a soft body — these shapes are control-bone targets rather
than fixed joint angles.

## Body coordinate system

- Origin at the ground center beneath the body's lowest point
- +Y = forward (the direction the "intent bulge" leans toward)
- +Z = up
- +X = body's right
- All distances in meters
- Body parts are scaled along percentages of the base body width/height

## Body parts (control bones — 12 total per Epic 05 task 14)

| Bone | Purpose | Default position |
|---|---|---|
| root | World transform | (0, 0, 0) |
| base | The wider sagging bottom mass | (0, 0, 0.20) |
| spine_01 | Lower body section | (0, 0, 0.45) |
| spine_02 | Mid body | (0, 0, 0.75) |
| spine_03 | Upper body | (0, 0, 1.05) |
| intent | The leaning upper bulge | (0, 0, 1.30) |
| tendril_01 | Front-facing whip arm — root joint | (0, 0.10, 0.85) |
| tendril_02 | Tendril mid joint | tendril_01 + (0, 0.40, 0.20) |
| tendril_03 | Tendril tip | tendril_02 + (0, 0.40, 0.20) |
| hotspot_anchor | Where attack node clusters spawn | (0, 0.05, 1.10) |
| drip_anchor_R | Drip droplet spawn point | (+0.40, 0, 0.05) |
| drip_anchor_L | Drip droplet spawn point | (-0.40, 0, 0.05) |

## Body part dimensions at the IDLE base shape

| Body section | Width (X) | Depth (Y) | Height (Z) | Notes |
|---|---|---|---|---|
| base mass | 1.20 m | 1.10 m | 0.40 m | Wider than tall — sagging |
| spine_01 envelope | 1.10 m | 1.00 m | 0.30 m | Slightly narrower as it rises |
| spine_02 envelope | 0.95 m | 0.90 m | 0.30 m | Continues narrowing |
| spine_03 envelope | 0.80 m | 0.75 m | 0.25 m | The "shoulder" region |
| intent envelope | 0.65 m | 0.65 m | 0.30 m | The bulge — the "head" without being a head |

The body uses a chain of metaballs / soft mesh sections at each spine
control bone. Vertex weight blending is what produces the smooth taper
between sections. There are no hard joint creases.

---

## Shape 1 — IDLE BLOB

> **Reads as:** A wide irregular mass at rest. Slowly breathing in the
> sense that the surface ripples constantly but the body shape barely
> moves. The thing in the corner of the room.

**Control bone offsets from rest** (deltas, not absolute positions):

- **base**: scale Y+10% (slightly elongated front-back), no offset
- **spine_01**: no offset
- **spine_02**: small drift +X+0.03 then back over 90 frames (sway)
- **spine_03**: opposite drift -X+0.03 (counter-sway)
- **intent**: small Z+0.05 lift then back (vertical pulse, breath)
- **tendril**: tucked against body — tendril_03 = tendril_01 + (0, 0.05, 0)
- **hotspot_anchor**: no offset, hotspot nodes hidden
- **drip_anchor_R/L**: emit 1 drip per 4 seconds

**Shape envelope:** wide horizontal blob, intent bulge centered above
the body (not leaning yet). Total height ~1.4 m. Total width ~1.2 m.
Visible internal data drifts upward through the body at idle speed.

**Silhouette test:** asymmetric vertical irregular blob, wider at base.
At 64×64 px, distinguishable from a sphere by the asymmetric base sag
and from a teardrop by the lack of a pointy top.

---

## Shape 2 — ALERT LEAN

> **Reads as:** Just noticed the player. Intent bulge tilts toward
> them. Body still hasn't moved its base — the lean is the only sign
> something changed. The "I see you" body language.

- **base**: no offset
- **spine_01**: no offset (base of body still planted)
- **spine_02**: lean +Y+0.10 (mid section starts to tilt forward)
- **spine_03**: lean +Y+0.20 (upper section tilts more)
- **intent**: lean +Y+0.35, and tilt rotation around X by +20° (the
  bulge points forward at the player)
- **tendril**: still tucked but tendril_03 drifts +Y+0.10 (tracking)
- **hotspot_anchor**: no offset, hotspot nodes show 3 dim red dots at
  the front of the intent bulge
- **drip_anchor**: same drip rate

**Shape envelope:** the body is now a vertical question-mark shape.
Base is symmetric, mid leans forward, intent is way forward and tilted.
Total height ~1.5 m. Visible from above, the body forms a "J" shape.

**Silhouette test:** distinguishable from idle by the obvious
forward lean of the upper body. At 64×64, the asymmetry between top
and bottom should be the clearest visual signal.

---

## Shape 3 — AGGRO EXTEND

> **Reads as:** Maximum threat display. Body elongates upward as if
> stretching to be seen. Hotspot nodes are bright. About to attack.

- **base**: scale Z+30% (base lifts off the ground slightly), scale
  Y-10% (gets narrower in depth as mass flows upward)
- **spine_01**: lift +Z+0.20
- **spine_02**: lift +Z+0.40 + lean +Y+0.15
- **spine_03**: lift +Z+0.55 + lean +Y+0.25
- **intent**: lift +Z+0.65 + lean +Y+0.40 + tilt -10° (the bulge is
  above and pointing slightly down at the player from height)
- **tendril**: still tucked, ready to whip
- **hotspot_anchor**: 5 bright red dots clustered at the front of intent
- **drip_anchor**: drip rate triples — the leak is "boiling"

**Shape envelope:** body elongates from 1.4 m → 2.1 m tall. Width
shrinks from 1.2 → 1.0 m as mass flows upward. The base has a thin
"neck" connecting it to the elevated upper body — this is the
"engorged with intent" pose. Visible internal data swirls upward
into the intent bulge.

**Silhouette test:** body is now a vertical column ~2× the player's
height. Base is wider than spine_02 which is the narrowest point.
At 64×64, this is clearly different from both idle and alert by being
TALLER than wide.

---

## Shape 4 — TENDRIL WHIP

> **Reads as:** Single tendril whips out from the body to strike.
> Body anchored. The tendril is the "arm" extension of the leak.

- **base**: scale X-10% (body recoils inward as it expels the tendril)
- **spine_01**: drift -Y-0.05 (recoil)
- **spine_02**: drift -Y-0.05
- **spine_03**: drift -Y-0.05
- **intent**: drift -Y-0.05 (whole body slightly back)
- **tendril_01**: extend +Y+0.20 (tendril root pushes forward)
- **tendril_02**: extend +Y+1.20 (mid tendril snaps out)
- **tendril_03**: extend +Y+2.40 (tip is 3.5m from body center —
  the maximum reach)
- **hotspot_anchor**: hotspot nodes flash white at the moment of strike
  then return to red for the recover

**Shape envelope:** the body is a vertical irregular mass with a
single thin appendage shooting forward. Tendril width starts at
~0.20 m at root, tapers to 0.04 m at tip. The tendril looks like a
viscous fluid stream that has been launched from the body and is in
the process of being pulled back by surface tension.

**Silhouette test:** at 64×64, the tendril must be visible as a
distinct line element extending from the body. The body itself
should still read as a slime mass, not become unrecognizable from
the appendage.

---

## Shape 5 — SPIT WINDUP

> **Reads as:** Internal pressure building. Hotspot nodes cluster
> at the front of the intent bulge. The body holds still while the
> interior visibly churns. Then the shot fires.

- **base**: scale +5% (body inflates slightly from internal pressure)
- **spine_01**: scale +5%
- **spine_02**: scale +5%
- **spine_03**: scale +5%
- **intent**: scale +15% + small forward tilt — the front of the
  intent bulge is the launch point
- **tendril**: tucked against body
- **hotspot_anchor**: 8 bright red nodes form a tight cluster at the
  forward face of the intent bulge — they're the visible "barrel"
  of the shot

**Internal motion:** the visible code stream texture inside the body
should accelerate dramatically during the windup, all flowing toward
the hotspot cluster. Players should be able to see the body LOADING
the shot from the inside.

**Shape envelope:** uniformly inflated by 5-15% with a slight forward
asymmetry. Hotspot nodes form an obvious target marker. Total body
height ~1.6 m, width ~1.3 m.

**Silhouette test:** subtle differences from idle, but the hotspot
nodes (which contribute to silhouette via emission halo) make the
front of the body brighter and shift the silhouette's center of mass
forward.

---

## Shape 6 — DEATH DRAIN

> **Reads as:** Defeated. Body collapses downward, sagging into a
> flat puddle. Internal data drains out and dissipates. The "you
> killed it slowly" reward moment.

Three sub-frames within this shape (interpolated by the death
animation):

### Sub-shape 6a — Collapse start (frame 0-12 of death)
- **base**: spread X+15%, Y+15% (body widens as it loses structure)
- **spine_01**: drop Z-0.10
- **spine_02**: drop Z-0.20
- **spine_03**: drop Z-0.30
- **intent**: drop Z-0.40, sag forward (the bulge falls)
- **tendril**: drops, sags
- **hotspot_anchor**: nodes flicker erratically then go dark

### Sub-shape 6b — Puddle (frame 30-90)
- **base**: spread X+50%, Y+50%, scale Z-70% (very flat, very wide)
- **spine_01**: scale Z-90% (almost gone)
- **spine_02**: scale Z-95%
- **spine_03**: scale Z-95%
- **intent**: scale Z-90%, drop into the puddle plane
- All bones are now within ~0.10 m of ground level
- Visible internal data has stopped moving — fragmented into static
  blocks like a frozen video frame

### Sub-shape 6c — Drain out (frame 90-120)
- The puddle slowly evaporates: alpha goes from 0.6 → 0.0
- Internal data text fades to black
- Final state: nothing, dissolved decal absorbs into ground

**Shape envelope:** transitions from 1.4 m tall blob to 0.10 m tall
flat puddle ~1.8 m × 1.8 m wide. The transition timing is the read.
Sub-frame timing: 12 frames collapse + 60 frames puddle hold + 30
frames drain = 102 frames total (the timing reference doc says 60+90+30
but those numbers were the estimate before the sub-shapes were
defined; this updated breakdown is canonical).

**Silhouette test:** the final puddle is almost invisible from above
— a flat irregular dark patch on the ground. From player camera angle
it should clearly read as "this was something, now it's nothing."

---

## Shape envelope rules (for the rig)

The MemoryLeak rig uses **soft body deformation** rather than rigid
skinning:

1. Each control bone has a falloff radius. Vertices within the
   radius are weighted by a smooth Gauss curve so deformation is
   continuous, not segmented.
2. Falloff radii overlap by ~30% so adjacent bones blend smoothly.
3. The BASE bone has a special "ground stick" constraint — its
   bottom vertices are pinned to the ground plane unless the death
   sequence is active.
4. The TENDRIL chain has stretch IK — the tendril can elongate to
   3.5m without breaking the mesh because vertices interpolate along
   the bone chain length.
5. Vertex shader wobble (Epic 05 task 12) runs ON TOP of the bone
   deformation — it adds high-frequency surface displacement that
   makes the gel skin feel alive even when the bones are static.

## How later Epic 05 tasks use these shapes

- **Task 14 (rig 12 bones)**: matches the bone list and falloff rules above
- **Task 15 (idle pulse breath)**: cycles between shape 1 variants
- **Task 16 (drag move)**: shape 1 → shape 2 transition while root translates
- **Task 17 (tendril whip)**: shape 2 → shape 4 → shape 2 transition
- **Task 18 (spit attack)**: shape 2 → shape 5 → shape 5+release
- **Task 19 (hit reaction)**: shape 1 with brief inflation pulse
- **Task 20 (death)**: shape 1 → shape 6a → 6b → 6c sequence
- **Task 21 (split)**: see Epic 05 task 21 spec — uses two shape-1 instances
- **Task 24 (validate vertex jelly at all sizes)**: scales body envelope
  3× and verifies the wobble shader still reads
- **Task 31 (validate vs other enemies)**: distinct from GlitchBug shapes
  — this is what makes the validation easy

## Anti-patterns specific to MemoryLeak shapes

- **Don't pose the body symmetrically.** Even idle should have asymmetric
  base sag — perfect symmetry reads as "model asset" not "living blob."
- **Don't snap-pose between shapes.** The transitions are part of
  the character. A snap from idle to alert lean breaks the viscous feel.
- **Don't have the tendril extend straight.** Even at peak whip
  extension, the tendril should curve slightly under its own weight.
- **Don't fully retract the body during death.** The puddle should
  remain visible until the drain phase — the player should be able
  to see what they killed.
