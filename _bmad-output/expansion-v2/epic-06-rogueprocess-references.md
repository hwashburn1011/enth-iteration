---
name: Epic 06 — RogueProcess Reference Bible
description: Reference brief and design pillars for the photoreal RogueProcess remake
epic: 06
created: 2026-04-09
---

# RogueProcess Reference Bible

## What this document is

Same role as the GlitchBug (Epic 04) and MemoryLeak (Epic 05) bibles
but for the RogueProcess family. The RogueProcess is the third
"category" of the bestiary — distinct from the GlitchBug (hard chitin
crawler) and the MemoryLeak (soft translucent ooze).

## The one-line pitch

> *"A floating humanoid drone with too many eyes and no legs. The
> machine that's been watching you longer than you realized."*

## Design pillars

1. **Silhouette priority: floating humanoid wrong-ness.**
   Read at 64×64 px. Where the GlitchBug is a horizontal triangle and
   the MemoryLeak is a vertical irregular blob, the RogueProcess is
   an upright humanoid TORSO that floats with no legs visible. The
   defining traits at thumbnail scale are: (a) a clear humanoid
   shoulder + head silhouette, (b) NO legs — the body fades into
   thruster smoke or just hovers above the ground, (c) the head is
   subtly wrong (more eyes than expected, too thin a neck, off-center
   antenna). The wrongness is what triggers the uncanny valley
   response — players should briefly read it as "person" before their
   brain catches the deviation.

2. **Material story: cold polished metal + bright alert emission.**
   Inverse of the MemoryLeak. The body is hard, polished, brushed
   metal — chrome and gunmetal panels with sharp edges. The emission
   is bright and clean, not soft and smoky: optical sensor eyes,
   thruster glow, and warning LEDs that strobe when the unit is in
   combat. The cleanliness is the threat: this is the well-maintained
   killing machine in a dungeon full of corrupted, decaying things.

3. **Animation language: floats then snaps.**
   Body movement is smooth, weightless, and slow — pure hover
   physics. Then in combat, attacks SNAP into position with no
   anticipation, like a security turret rotating to lock-on. The
   contrast between the smooth hover and the snap-targeting is the
   visual signature. A RogueProcess that moved smoothly always would
   feel like a friendly robot; one that snapped always would feel
   like a generic enemy. The combination is unique.

4. **Color hierarchy at gameplay distance.**
   Player must see (a) BODY (cold metallic gray, ~75% of pixels),
   (b) ALERT (single bright color — typically cyan for scanning, red
   when committed to attack — 15% of pixels), (c) THRUSTER GLOW (warm
   orange-yellow at the base where legs would be, 10% of pixels). The
   alert color shift from cyan → red is the readable telegraph that
   the player must learn: cyan means scanning, red means firing in
   ~1 second.

5. **One unmistakable cliché embraced: it's a security drone.**
   Don't try to make this not-a-drone. Lean into the security drone
   archetype 100%. Think Black Mirror dog, Half-Life 2 scanner,
   Death Star probe droid. The novelty is in the humanoid TORSO
   instead of the usual drone sphere — that's what makes it memorable.

## Reference families

### Real-world drone / robot anchors
- **Boston Dynamics Atlas with no legs**: imagine the Atlas humanoid
  but the body ends at the hip with thrusters where the legs would
  start. Source for the rigid upright torso posture and the way the
  shoulders move when targeting.
- **Black Mirror "Metalhead" dog**: source for the cold methodical
  scanning behavior and the unrelenting tracking lock-on feel.
- **Half-Life 2 city scanner**: source for the floating hover physics
  and the camera-flash idle behavior. The lit-up "eye" before
  triggering an attack is the same telegraph mechanic.
- **Death Star probe droid**: source for the silhouette of a humanoid
  upper body with mechanical limbs/sensors below.
- **Surveillance camera in a corner**: source for the unblinking
  steady scan motion. The RogueProcess head moves like a CCTV camera,
  not like a human head.

### Wrongness anchors (the "too many eyes" feel)
- **Spider eyes on a face**: source for the eye placement — 4 to 6
  optical sensors arranged across the head plate, not in human
  positions. Two of them are larger "primary" optics; the others
  are smaller "auxiliary" sensors that ALSO glow but at lower
  intensity. The asymmetry triggers the uncanny valley.
- **Mannequin face**: source for the deliberately featureless lower
  face — no mouth, no nose, just a smooth metal plate where a
  human's mouth would be. This is what makes the head read as
  "machine pretending to be human" rather than "robot."
- **Insectoid antennae on a humanoid head**: source for the off-center
  sensor antenna jutting from one side of the head, never both. The
  asymmetry is intentional.
- **Nightcrawler from X-Men teleport effect**: source for the
  teleport-in/out animation visual.

### Mood / lighting anchors
- **Subnautica Warper**: how a humanoid floating entity reads under
  water-blue ambient lighting. The Warper's calm-then-violent timing
  is exactly the RogueProcess's float-then-snap pattern.
- **Dishonored Tallboy**: a tall humanoid figure that uses leg-replacement
  technology — source for how to handle the "no legs" silhouette in
  a way that still reads as bipedal upper body.
- **Cyberpunk 2077 Adam Smasher reveal lighting**: cold blue + harsh
  white rim, the opposite of warm dungeon lighting.

### Anti-references
- **Anything cute or friendly.** No googly eyes, no rounded forms,
  no curves that suggest "cuddly robot." The RogueProcess should
  trigger threat response from frame 1.
- **Anything with visible legs.** Even mechanical legs. The "no legs"
  silhouette is the species defining trait.
- **Anything that bleeds.** The RogueProcess takes damage by sparking,
  losing armor plates, and exposing internal circuitry — not by
  bleeding. This is the bestiary's machine archetype.
- **Anything with an obvious mouth.** No grilles that look like
  smiling teeth, no speaker holes that look like a mouth shape. The
  lack of mouth is what makes it uncanny.
- **Anything organic.** No fleshy seams, no breathing motion, no
  warmth in the color palette. The RogueProcess is the antithesis
  of the MemoryLeak's organic translucency.

## Material zones

| Zone | Coverage | Hue | Material | Notes |
|---|---|---|---|---|
| Main armor plates | 50% | Brushed gunmetal 0.20 gray | Metallic 0.85 / Roughness 0.30 | The hero surface |
| Chest emblem | 5% | Polished chrome 0.85 | Metallic 1.0 / Roughness 0.05 | Reflects environment |
| Optical sensor primary | 4% | Cyan/red strobe | Emissive 4.0 | The eye telegraph |
| Optical sensor auxiliary | 4% | Cyan dim | Emissive 1.5 | The "wrong" extra eyes |
| Lower face plate | 3% | Smooth gunmetal | Metallic 0.85 / Roughness 0.10 | Featureless |
| Antenna asymmetric | 2% | Black with cyan tip | Emissive tip pulse | One side only |
| Joint exposed circuits | 5% | Dark with cyan trace lines | Emissive 1.0 | Visible in shoulder/elbow gaps |
| Thruster nozzle | 5% | Charred metal + bright glow | Emissive 3.5 warm | Where legs would be |
| Thruster glow plume | 8% | Orange-yellow gradient | Additive shader | Soft pillar of light below |
| Hand claws | 4% | Polished chrome with sharp edges | Metallic 1.0 / Roughness 0.05 | The melee weapons |
| Damage decal — armor crack | 5% | Black with cyan circuitry showing | Standard | Reveals on hit |
| Holographic skin overlay | 5% | Variant — see archetype rules | Holographic shader | Optional layer (task 13) |

## Silhouette pose targets

1. **Hover idle** — torso upright, head slowly scanning side-to-side, arms relaxed at sides, thruster glow steady
2. **Combat idle** — head locked on player, arms slightly raised in ready position, thruster glow brighter, optical sensors strobed to alert color
3. **Charge fire** — one arm extended forward with hand-claw projecting energy, head locked, body tilts slightly back from recoil anticipation
4. **Melee swipe** — one arm extended in a wide claw swipe, body twisted to follow through, head still locked on target
5. **Teleport in** — body materializing, surrounded by particles, optical sensors bright as the "boot up" tell
6. **Catastrophic death** — body sparks visibly along all joints, optical sensors flicker erratically, thruster sputters, body slowly drops with gravity overcoming hover

## Motion timing reference

| State | Frame count | Notes |
|---|---|---|
| Hover idle bob | 90-frame loop | Slow vertical sin wave, 0.05m amplitude |
| Combat hover | 60-frame loop | Faster bob, 0.08m amplitude, head twitches |
| Strafe L/R | 30-frame loop | Translates while bobbing, head holds target |
| Dash forward | 12 frames | Anticipation 4f + accel 4f + arrival 4f |
| Teleport in | 24 frames | Materialize over 18f + settle 6f |
| Teleport out | 12 frames | Pre-flicker 4f + dissolve 8f |
| Ranged charge | 30 frames | Slow build with rising whine SFX hook |
| Ranged fire | 4 frames | Snap release |
| Melee swipe | 16 frames | Wind 4f + strike 4f + recover 8f |
| Hit reaction | 16 frames | Knockback drift, no anticipation (weightless) |
| Death | 60 frames sparks + 30 frames slow drop + 24 frames thump | The drop is what sells "machine vs. organism" |

## Dimensional targets

- **Body height** (top of head to bottom of thruster nozzle): 1.9 m
- **Shoulder width**: 0.65 m
- **Body depth** (front to back): 0.40 m
- **Hover height** (thruster nozzle to ground): 0.45 m
- **Triangle budget**: 3.5 K LOD0, 1.4 K LOD1, 600 LOD2
- **Bone budget**: 22 bones (per task 14) — root + hover_anchor + spine
  + chest + neck + head + 4 sensor jitters + 2 antenna + 2 shoulder
  + 2 upperarm + 2 forearm + 2 hand + 2 thruster + back_exhaust

## The 90-second trailer test

> "Cut to a sterile server room. A RogueProcess hovers in the
> doorway, head slowly scanning. Cyan optical sensors sweep the
> room. Camera lingers on the head — too many eyes. The sensors
> snap red. Cut. Did the audience just learn this is a hunting
> machine, this is uncanny, this is about to attack?"

## What MUST be different from the GlitchBug AND MemoryLeak

The bestiary distinction table now has 3 columns:

| Axis | GlitchBug | MemoryLeak | RogueProcess |
|---|---|---|---|
| Body type | Hard chitin shell | Soft translucent gel | Hard polished metal |
| Silhouette | Wide horizontal | Tall vertical irregular | Tall vertical humanoid |
| Locomotion | 6-leg gait | Drag/ooze | Floating hover |
| Interaction model | Lunge + bite | Tendril whip + spit | Ranged charge + claw |
| Animation tempo | Sharp jitter | Slow viscous | Smooth then snap |
| Color identity | Dark with cyan/magenta cracks | Bright translucent + data | Cold metallic + alert strobe |
| Eye treatment | 4 eye pits, no lenses | None, no face | 4-6 lensed sensors, "too many" |
| Mouth treatment | Mandibles | None | Smooth featureless plate |
| Death style | Curl + dissolve fragments | Collapse + drain | Spark + slow drop with gravity |
| Threat tell | Mandible spread | Hotspot node clusters | Sensor color shift cyan→red |
| Surface on hit | Shader fragments | Surface ripples | Spark bursts + armor crack reveal |
| Dominant emotion | Predator | Body horror | Surveillance dread |

The RogueProcess fills the "machine watching you" emotional slot of
the bestiary. GlitchBug = "thing that hunts you," MemoryLeak = "thing
that consumes you," RogueProcess = "thing that has been observing
you longer than you realized."

## Archetype variants (Epic 06 task 24)

The 4 archetypes for the launch are differentiated by silhouette
modifications and weapon mounts:

1. **Scout** — slimmer body, single antenna, fast movement, light
   damage. Emphasis on the surveillance role.
2. **Gunner** — wider shoulders with mounted shoulder cannons, slower,
   ranged-only. Emphasis on the firepower role.
3. **Brute** — bulkier body with chest plates, blade-claws on both
   hands, melee-focused. Emphasis on the bodyguard role.
4. **Hacker** — slender with extra antennae and a hovering aux
   device, applies status effects via cyan beam. Emphasis on the
   support/disabler role.

All 4 share the same 22-bone rig and the same animation set; the
differences are in body mesh proportions (parented to different rig
bones with extra geometry attached) and weapon mount meshes.
