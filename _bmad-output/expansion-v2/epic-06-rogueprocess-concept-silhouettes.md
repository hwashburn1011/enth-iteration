---
name: Epic 06 — RogueProcess Concept Silhouettes
description: 6 detailed pose specifications for the photoreal RogueProcess — drives the modeling, rigging, and animation passes
epic: 06
created: 2026-04-09
---

# RogueProcess Concept Silhouettes — 6 Pose Specifications

These are the 6 reference poses every later Epic 06 task must support.
The RogueProcess has a rigid skeleton (unlike the soft-body MemoryLeak)
but with one critical difference from the GlitchBug: NO LEGS. The body
floats above a hover_anchor bone with thrusters where the legs would be.

## Body coordinate system

- Origin at the ground center beneath the body
- +Y = forward (the direction the head faces)
- +Z = up
- +X = body's right
- All distances in meters

## Body parts (22-bone rig per Epic 06 task 14)

| Bone | Purpose | Default position |
|---|---|---|
| root | World transform | (0, 0, 0) |
| hover_anchor | Floating offset bone (animates the bob) | (0, 0, 0.45) |
| spine_01 | Lower torso | (0, 0, 0.85) |
| chest | Upper torso | (0, 0, 1.20) |
| neck | Connector | (0, 0, 1.45) |
| head | Head plate | (0, 0, 1.55) |
| sensor.PR | Primary right optical sensor (jitter bone) | head + (0.05, 0.08, 0.04) |
| sensor.PL | Primary left optical sensor | head + (-0.05, 0.08, 0.04) |
| sensor.AR | Auxiliary right (smaller, "wrong" eye) | head + (0.08, 0.05, 0.07) |
| sensor.AL | Auxiliary left | head + (-0.08, 0.05, 0.07) |
| sensor.A2 | Forehead auxiliary | head + (0, 0.07, 0.10) |
| antenna.R | Asymmetric antenna (only one side) | head + (0.10, 0, 0.12) |
| shoulder.R | Right shoulder pivot | chest + (0.30, 0, 0.05) |
| shoulder.L | Left shoulder pivot | chest + (-0.30, 0, 0.05) |
| upperarm.R | Right upperarm | shoulder.R + (0.10, 0, -0.05) |
| upperarm.L | Left upperarm | shoulder.L + (-0.10, 0, -0.05) |
| forearm.R | Right forearm | upperarm.R + (0, 0, -0.30) |
| forearm.L | Left forearm | upperarm.L + (0, 0, -0.30) |
| hand_claw.R | Right hand-claw | forearm.R + (0, 0, -0.30) |
| hand_claw.L | Left hand-claw | forearm.L + (0, 0, -0.30) |
| thruster.R | Right thruster nozzle (under hip) | hover_anchor + (0.12, 0, -0.20) |
| thruster.L | Left thruster nozzle | hover_anchor + (-0.12, 0, -0.20) |
| back_exhaust | Back-mounted secondary thruster | chest + (0, -0.20, 0.05) |

The "no legs" silhouette is achieved by having NO bones below
hover_anchor besides the thrusters. The body fades into thruster
glow particles instead of legs.

---

## Pose 1 — HOVER IDLE

> **Reads as:** A floating sentinel scanning the room. Calm, almost
> indifferent. The thing in the corner you almost don't notice until
> its head locks onto you.

- **hover_anchor**: bobs slowly up 0.05m and back over 90 frames
- **spine_01**: no offset
- **chest**: no offset
- **neck**: no offset
- **head**: slow scanning yaw — rotates ±25° around Z over 60 frames,
  pause 30 frames at each extreme, repeat
- **sensor.PR / PL**: dim cyan emission, slow 0.5Hz pulse
- **sensor.AR / AL / A2**: very dim cyan emission, no pulse (these
  are the "wrong" extra eyes — always lit but never strobed)
- **antenna.R**: vertical, slight lateral micro-jitter every 40 frames
- **shoulder.R / L**: slightly forward — arms hang in a "ready" position
- **upperarm.R / L**: pitch +5° (arms hang slightly forward of body)
- **forearm.R / L**: pitch -10° (small inward bend at the elbow)
- **hand_claw.R / L**: relaxed, claws closed
- **thruster.R / L**: steady warm glow, slow flicker

**Silhouette envelope:** vertical humanoid torso ~1.9m tall, no legs
visible — the body fades into thruster glow at z=0.45m. From above,
the head's slow scan rotation is the only obvious motion.

**Silhouette test:** at 64×64 px, the body reads as a person standing
(shoulders + head + torso) but with NO legs — instead a soft pillar
of warm orange light below. The visible difference from a generic
robot silhouette is the asymmetric antenna sticking from one side
of the head and the soft thruster pillar where legs would be.

---

## Pose 2 — COMBAT IDLE

> **Reads as:** Has noticed the player. Locked on. Arms half-raised.
> Sensor color shifted to red. Faster bob — the body is keyed up.

- **hover_anchor**: bobs faster, 0.08m amplitude over 60 frames
- **spine_01**: no offset
- **chest**: pitch -3° (slight forward lean toward target)
- **neck**: no offset
- **head**: LOCKED on target — yaw and pitch track the player every
  frame, no idle scanning
- **sensor.PR / PL**: BRIGHT RED emission, 2Hz strobe (the threat tell)
- **sensor.AR / AL / A2**: dim cyan still (the wrong eyes never change
  color — that's part of the wrongness)
- **antenna.R**: micro-jitter at 8Hz (much faster than idle)
- **shoulder.R / L**: pitch -10° (raised slightly, ready position)
- **upperarm.R / L**: yaw outward 15° (elbows out from body)
- **forearm.R / L**: pitch -45° (forearms half-raised)
- **hand_claw.R / L**: claws OPEN — fingers spread, ready to attack
- **thruster.R / L**: brighter glow

**Silhouette envelope:** body 0.10m higher than idle (from the
faster bob peak), head clearly tilted toward the player, arms
forming a wider silhouette than idle, thruster glow brighter.

**Silhouette test:** at 64×64, distinguishable from idle by the
arms-out shoulder width (~0.85m vs idle 0.65m) and the head's
forward lean. The red sensor strobe is what makes the silhouette
read as DANGEROUS at any range.

---

## Pose 3 — CHARGE FIRE

> **Reads as:** Right hand-claw extends forward in a targeting
> gesture. Energy gathering at the claw tip. Body recoils slightly
> as if anticipating the recoil. Head locked rigid.

- **hover_anchor**: held steady (no bob during charge — the unit is
  locked in firing position)
- **spine_01**: pitch +5° (slight back lean from anticipated recoil)
- **chest**: pitch +3°
- **neck**: pitch -8° (head pulled forward, looking down the arm)
- **head**: locked on target, pitch follows the arm
- **sensor.PR / PL**: PEAK RED, 6Hz strobe — full alert
- **antenna.R**: rigid, no jitter (locked state)
- **shoulder.R**: yaw -5° (slight inward to align with the arm extension)
- **shoulder.L**: yaw +10° (counter-balance, pulled back)
- **upperarm.R**: pitch -90° (arm fully extended forward)
- **upperarm.L**: pitch +30° (left arm pulled back behind body for
  counter-balance, like an old-school dueling pose)
- **forearm.R**: pitch 0° (straight extension)
- **forearm.L**: pitch -60° (bent back)
- **hand_claw.R**: fingers SPREAD, pointing forward, energy gathered
  at the centroid of the open claw — the visible "muzzle" of the shot
- **hand_claw.L**: closed at hip
- **thruster.R / L**: dimmed (the unit is using power to charge
  the shot, less for hovering — visible drop in thruster glow)

**Silhouette envelope:** body forms a horizontal "T" — right arm
extended forward at shoulder height, left arm tucked back, body
slightly back. Total reach from body center to hand_claw.R is ~0.95m.

**Silhouette test:** at 64×64, the extended arm is the dominant
visual element — clearly different from any other pose. The dimmed
thrusters are a subtle background tell.

---

## Pose 4 — MELEE SWIPE

> **Reads as:** Wide claw swipe with one arm, body twisted to follow
> through. Fast, committed, scary.

- **hover_anchor**: drops 0.10m (the body lunges forward and down
  during the swipe)
- **spine_01**: rotation Z +15° (body twists with the swing)
- **chest**: rotation Z +20°
- **neck**: rotation Z +10°
- **head**: rotation Z -10° (head stays locked on target while
  body twists — the eye contact is held through the swipe)
- **sensor.PR / PL**: BRIGHT RED
- **antenna.R**: trailing whip from the body twist
- **shoulder.R**: yaw +25° (right arm sweeps across body)
- **upperarm.R**: pitch -45°, yaw -90° (across-body forward swipe)
- **forearm.R**: pitch -30°, fully extended
- **hand_claw.R**: SPREAD WIDE — fingers fully extended for maximum
  reach + visible sharp tips
- **shoulder.L**: yaw -10°, pulled back as counter-balance
- **upperarm.L**: pitch +20°, behind body
- **thruster.R / L**: brief flare during the lunge (visible thrust burst)

**Silhouette envelope:** body twisted ~20° around vertical axis,
right arm extended in a wide horizontal arc across the front of the
body. Total horizontal extent ~1.4m at peak swipe.

**Silhouette test:** at 64×64, the arm is now horizontal (vs Pose 3's
forward extension). The body twist is visible as the asymmetric
shoulder line.

---

## Pose 5 — TELEPORT IN

> **Reads as:** Materializing in mid-air. Body fully assembled but
> surrounded by particle effects. Sensors at peak brightness as the
> "boot up" tell. The first frame the player sees a new RogueProcess
> spawn into the room.

- **hover_anchor**: at default position, no bob (frozen in spawn moment)
- **spine_01**: straight upright, no offset
- **chest**: straight upright
- **neck**: no offset
- **head**: pitch +10° (head looking SLIGHTLY DOWN at where the
  player was last detected — like the unit already knew where the
  player would be when it materialized)
- **sensor.PR / PL**: PEAK BRIGHTNESS WHITE → fade to combat red over
  the materialization (16 frames)
- **sensor.AR / AL / A2**: PEAK BRIGHTNESS WHITE → fade to dim cyan
  (only this pose lights the auxiliary sensors brightly — the wrong
  eyes are visible during the spawn for an extra moment of horror)
- **antenna.R**: rigid
- **shoulder.R / L**: combat-ready pose, identical to Pose 2
- **upperarm.R / L**: combat-ready pose
- **forearm.R / L**: combat-ready pose
- **hand_claw.R / L**: claws open
- **thruster.R / L**: bright IGNITION pulse — full brightness at the
  spawn moment, particles flaring outward, then settling to combat
  brightness over 12 frames

**Silhouette envelope:** identical to Combat Idle, but the silhouette
is partially obscured by spawn particle effects so it READS as
"unclear, threatening, materializing."

**Silhouette test:** at 64×64, the all-sensors-bright moment is
distinct from any other pose because of the auxiliary eyes lighting
up. Players watching for spawn cues will learn to count the lit
sensors as the "spawn warning."

---

## Pose 6 — CATASTROPHIC DEATH

> **Reads as:** System failure. Sparks along all joints. Sensors
> flickering. Body slowly losing hover and dropping to the ground
> with the dead weight of a metal corpse.

Three sub-frames within this pose:

### Sub-pose 6a — Spark cascade (frame 0-30)
- **hover_anchor**: still at hover height, no bob (frozen mid-fall)
- **spine_01**: pitch -5° (body starting to slump)
- **chest**: pitch -8°
- **neck**: pitch +5° (head lolling forward)
- **head**: pitch +15° (chin dropping)
- **sensor.PR / PL**: ERRATIC FLICKER red → dim → red → off → red
- **sensor.AR / AL / A2**: FLICKER cyan → off → flash → off
- **antenna.R**: drops to 30° below vertical (mechanical failure)
- **shoulder.R / L**: drop -10° (arms going limp)
- **upperarm.R / L**: pitch +30° (arms hanging forward)
- **forearm.R / L**: pitch +60° (arms folded forward)
- **hand_claw.R / L**: claws CLOSING involuntarily as power fails
- **thruster.R / L**: SPUTTER — alternating bright/off/bright/off
  flicker, dimming overall
- Visible sparks at every joint, particularly shoulders and neck

### Sub-pose 6b — Slow drop (frame 30-60)
- **hover_anchor**: drops from 0.45m to 0.0m over 30 frames with
  ease-in (gravity overcoming the failing thrusters)
- **spine_01**: pitch -15°
- **chest**: pitch -20°
- **head**: pitch +25° (chin on chest)
- **sensors**: all OFF
- **antenna.R**: dropped fully to side
- **shoulders / arms**: continue limp
- **thruster.R / L**: completely off — no glow, no particles

### Sub-pose 6c — Thump (frame 60-84)
- **hover_anchor**: at 0.0 (touchdown)
- **spine_01**: pitch -25°
- **chest**: pitch -35° (body bowed forward)
- **head**: pitch +35° (face down)
- **shoulders**: drop further as body settles into a slumped pose
- **arms**: dangle in front of the body
- **thrusters**: cold dark metal
- One final sensor FLICKER on frame 70 — a single dim red blink as
  the last flicker of consciousness — then permanently off

The total death sequence is 84 frames (~1.4s at 60fps). The slow
drop is what differentiates "machine death" from "organic death" —
no curl-up, no crumple, just gravity pulling the body down.

**Silhouette test:** the dead RogueProcess sits on the ground in a
defeated humanoid slump. The body is now visible as a SHORTER vertical
silhouette than the hover idle (because the hover offset is gone).
The clear "no longer hovering" read is the death confirmation.

---

## Pose differentiation summary

| Pose | Body axis | Arms | Sensors | Hover state |
|---|---|---|---|---|
| 1 Hover Idle | Vertical, slight bob | Hanging | Cyan slow pulse | Steady |
| 2 Combat Idle | Vertical, faster bob | Half-raised | Red strobe | Faster bob |
| 3 Charge Fire | Vertical, locked | T-pose extended | Red peak | Frozen |
| 4 Melee Swipe | Twisted 20° | Arc swiping | Red peak | Lunge drop |
| 5 Teleport In | Vertical, frozen | Combat-ready | All bright (incl. aux) | Igniting |
| 6 Death | Slumped | Limp | Flickering then off | Dropping |

## How later Epic 06 tasks use these poses

- Task 14 (rig 22 bones): matches the bone list above
- Task 15 (hover idle): plays Pose 1 with the bob loop
- Task 16 (combat hover idle): plays Pose 2 with the faster bob
- Task 17 (strafe L/R): Pose 2 with horizontal translation
- Task 18 (dash forward): brief Pose 2 → Pose 3 transition with
  large forward translation
- Task 19 (teleport in/out): Pose 5
- Task 20 (ranged charge + fire): Pose 2 → Pose 3 → Pose 2
- Task 21 (melee swipe): Pose 2 → Pose 4 → Pose 2
- Task 22 (hit reactions): Pose 2 with brief lateral translation
  drift (no recoil pose — knockback is weightless because the body
  is hovering)
- Task 23 (death): Pose 1 or 2 → Pose 6a → 6b → 6c

## Anti-patterns

- **Don't pose the head straight forward.** Even in idle, the head
  should be at a slight scanning angle. A perfectly straight head
  reads as "static asset" not "active surveillance."
- **Don't make the auxiliary sensors brighter than the primaries.**
  The wrong eyes should be DIM and constant — not strobed and not
  dominant. The wrongness is subtle, not flashy.
- **Don't bend the body at the waist.** The spine_01 / chest are
  the only torso bones — there's no flex point in the lower torso.
  The body is rigid; it tilts as a unit.
- **Don't have the arms at perfect rest position.** Even hover idle
  has a slight forward arm pitch. Perfect rest reads as "sleeping
  asset" not "active sentinel."
- **Don't hide the thruster glow under the body.** The warm pillar
  of light below the torso is the species silhouette signature —
  if you put a long coat or armor skirt that covers it, you've
  broken the silhouette.
