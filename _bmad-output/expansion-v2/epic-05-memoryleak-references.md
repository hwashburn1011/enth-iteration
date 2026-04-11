---
name: Epic 05 — MemoryLeak Reference Bible
description: Reference brief and design pillars for the photoreal MemoryLeak remake
epic: 05
created: 2026-04-09
---

# MemoryLeak Reference Bible

## What this document is

Same role as the GlitchBug reference bible (epic-04-glitchbug-references.md)
but for the MemoryLeak family. Drives all Epic 05 tasks 2-50. The two
enemies must share NO surface visual language so the player learns to
read them as distinct threats.

## The one-line pitch

> *"A semi-translucent data slime that drags itself across the ground,
> always growing, always leaking. The thing in the corner of the room
> you absolutely should not let touch you."*

## Design pillars (the only 5 things that matter)

1. **Silhouette priority: shapeless mass with intent.**
   Read at 64×64 px. Where the GlitchBug is a sharp horizontal triangle,
   the MemoryLeak is a vertical irregular blob — taller than wide, no
   distinct head, no legs, no joints. The defining traits at thumbnail
   scale are: an elongated upper bulge (the "intent" mass that leans
   toward whatever it's chasing), and a wider sagging base puddling
   outward from gravity. If at any silhouette scale this looks like a
   sphere or a teardrop with a face, the silhouette is wrong.

2. **Material story: refractive translucency + visible internal data.**
   The whole body is semi-transparent. Through the surface you should
   be able to see fragments of "code" — animated text glyphs, hex
   numbers, and packet diagrams drifting and tumbling inside the body
   like fish in a jellyfish. The outer surface is gel-like with subtle
   refraction. NOT glass. NOT water. A specific in-between like industrial
   acrylic resin holding live data.

3. **Animation language: macro slow + micro jiggle.**
   Body movement is slow, viscous, dragging. Surface movement is
   constant high-frequency jiggle from the vertex wobble shader so even
   when standing still the silhouette pulses like a held drop of mercury.
   The contrast between the macro stillness and the micro jiggle is
   the visual signature. A blob that was rigidly still would feel dead;
   one that flapped wildly would feel cartoonish. Hold the line in
   between.

4. **Color hierarchy at gameplay distance.**
   Player must see (a) BODY (translucent acid green or variant color,
   ~80% of pixels), (b) INTERNAL CODE (white/cyan glyphs animating
   inside the body, very subtle but always present — 10% of pixels at
   most), (c) HOTSPOTS (pulsing red nodes when the leak is about to
   attack — clusters of bright dots that grow as wind-up progresses).
   Three layers. The hotspots are the readability key for telegraphs.

5. **One unmistakable cliché embraced: it's a slime that leaks.**
   Don't try to make this not-a-slime. Lean into the slime archetype
   100%. The novelty is that the slime is made of computer data
   instead of actual liquid. Every visual decision should reinforce
   "slime + digital" — never "alien creature" or "elemental spirit."

## Reference families

### Real-world fluid anchors
- **Mercury droplet**: source for the surface tension behavior — the
  outer skin holds the shape but the interior moves freely. The way
  mercury bobs and re-merges is exactly the MemoryLeak's idle motion.
- **Lava lamp wax in oil**: source for the slow internal drift of the
  data fragments. The interior code text drifts at the same speed as
  lava lamp blobs — dreamy, never urgent.
- **Cytoplasm under microscope**: source for the visible internal
  structures suspended in a translucent medium. The code glyphs are
  the MemoryLeak's "organelles."
- **Ferrofluid spike test**: source for how the surface behaves when
  the leak is hit — a brief outward fingering of small spikes before
  retracting back to smooth.
- **Drip honey on a spoon**: source for the trailing droplets the
  leak leaves on the ground as it moves. Each drop falls, persists
  briefly, and either rejoins the parent or evaporates.

### Digital data anchors
- **Hex editor view**: source for the internal code fragment glyphs.
  Streams of `0xCAFEBABE` style hex sequences drifting through the
  body interior, occasionally aligning into recognizable patterns
  (function preambles, file magic numbers, etc) for the player who
  squints.
- **Corrupted memory dump**: source for the variant's "engorged"
  state — when the leak is full it should look like the interior is
  packed with garbage data, hash patterns, and overflowing bracket
  structures.
- **Blue screen of death character art**: source for the death
  state — when the leak dies, the internal data flashes through the
  classic "fatal exception" pattern before the body collapses.
- **Stack trace text**: source for the leak's "voice" — when it
  attacks it briefly displays a function call name in its body,
  so the player can see what API call is killing them. Subtle joke
  for tech-aware players, not required for the gameplay to work.
- **PNG corruption tear pattern**: source for the leak's hit
  reaction surface — when struck, the surface gets a brief
  block-aligned tear that resolves over 200ms.

### Mood / lighting anchors
- **Hollow Knight Crystal Peak crystals**: high-translucency lit
  objects with internal glow that lights nearby surfaces. The
  MemoryLeak should cast a colored glow on the ground around it.
- **Inside (Playdead) the underwater girl scene**: how a translucent
  body refracts the light passing through it without becoming glassy.
- **Half-Life Alyx headcrab body translucency**: the right balance
  of "you can see inside" without making the form unreadable.

### Anti-references (NOT this)
- Anything with a face. The MemoryLeak has NO face. The "intent"
  upper bulge is just a bulge — never put eyes or mouths on it.
- Anything that looks viscous like food. No syrup, no cake batter,
  no jelly. The body must read as "data given form," not "edible."
- Anything that splashes when it moves. Splashing makes it feel like
  liquid; the MemoryLeak is gel — it sags and drags, it doesn't splash.
- Anything cube-y or geometric. The MemoryLeak is the antidote to the
  GlitchBug's hard plates — keep it organic and flowing always.
- Anything with hard edges. Even when the leak takes damage, the
  surface ripples but never fractures.

## Material zones

| Zone | Coverage | Material | Notes |
|---|---|---|---|
| Outer gel skin | 75% | Refraction shader, IOR 1.35, alpha 0.65, subsurface lerp | The hero surface |
| Surface ripples | 5% | Same as outer with bumped normals | Ferrofluid micro-spikes from hit |
| Internal code stream | 12% | Animated UV-scroll texture overlay | Visible through outer skin |
| Hotspot nodes | 3% | Emissive red 3.5 spheres | Attack telegraph clusters |
| Drip droplets | 2% | Same as outer skin, smaller scale | Fall and persist briefly |
| Glow rim | 2% | Fresnel emissive matching variant color | Outer halo |
| Ground decal | n/a | Absorbing dark patch under the body | Shadow that ALSO darkens the ground (the "absorb light" shader from task 28) |

## Silhouette pose targets

These are NOT poses in the rigid sense — the leak doesn't have fixed
joints. They are body shape configurations the rig must support.

1. **Idle blob** — wide base, low intent bulge, gentle sway
2. **Alert lean** — intent bulge tilted in player's direction, base spreads slightly
3. **Aggro extend** — intent bulge stretches forward and up, body elongates ~1.5x vertical
4. **Tendril whip** — single tendril extends outward like a whip-arm to strike
5. **Spit windup** — internal pressure visible, hotspot nodes cluster at the front
6. **Death drain** — body collapses downward, sagging into a flat puddle
7. **Split** — body bisects into 2 smaller blobs (Epic 05 task 21)
8. **Engorged** — body 2x scale, surface bulging from internal pressure (variant)

## Motion timing reference

| State | Frame count | Notes |
|---|---|---|
| Idle pulse | 90-frame loop, 1 full breathe-out | Vertex wobble continuous on top |
| Drag movement | 30-frame loop, slow ground crawl | Body trails 0.3m behind animation root |
| Tendril whip windup | 12 frames | Hotspot nodes brighten over the windup |
| Tendril whip strike | 4 frames | Snap forward |
| Tendril whip recover | 18 frames | Slow viscous return |
| Spit windup | 24 frames | Hotspots cluster |
| Spit release | 6 frames | Pressure burst |
| Hit reaction | 12 frames | Jiggle wave + brief block tear |
| Death drain | 60 frames body collapse + 90 frames puddle linger + 30 frames absorb out | Long enough to read as "I killed it slowly" |
| Split | 30 frames body pinches + 6 frames separate + 24 frames each new body settles | One-shot |

## Dimensional targets

- **Idle body**: 1.2 m wide, 1.4 m tall (vertical-leaning irregular blob)
- **Aggro extend**: 1.0 m wide, 2.1 m tall (stretches up)
- **Tendril extend reach**: 3.5 m from body center
- **Drip body**: 0.6 m wide, 0.7 m tall (small variant)
- **Flood body**: 2.8 m wide, 3.2 m tall (large variant)
- **Triangle budget**: 3,000 tris LOD0, 1,200 LOD1, 500 LOD2
- **Bone budget**: 12 bones (per task 14) — 1 root + 1 base + 4 spine
  + 4 tendril control + 2 hotspot anchor

## The 90-second trailer test for the MemoryLeak

> "Cut to a flooded server room corridor. A MemoryLeak slowly drags
> itself across the floor toward camera. Internal data text drifts
> through its translucent body. As it gets close, hotspot red nodes
> cluster at the front and the body extends upward into a tendril.
> Cut away. Did the audience just learn this thing is alive, made
> of data, and dangerous?"

If yes, we hit the bar. If anything in those 2 seconds reads as
"slime monster" without the "made of data" layer, the internal code
stream needs to be more prominent.

## What MUST be different from the GlitchBug

For the bestiary to feel coherent, every enemy in Epics 04-08 must
read as a distinct category. The MemoryLeak vs GlitchBug must contrast on:

| Axis | GlitchBug | MemoryLeak |
|---|---|---|
| Body type | Hard chitin shell | Soft translucent gel |
| Silhouette | Wide horizontal | Tall vertical |
| Locomotion | 6-leg gait | Drag/ooze |
| Interaction model | Lunge + bite | Tendril whip + spit |
| Animation tempo | Sharp jitter | Slow viscous |
| Color identity | Dark with cyan/magenta cracks | Bright translucent + internal data |
| Eye treatment | 4 eye pits | NO face, NO eyes |
| Death style | Curl up + dissolve fragments | Collapse + drain into puddle |
| Threat tell | Mandible spread | Hotspot node clusters |
| Surface behavior on hit | Shader fragments | Surface ripples + block tear |

If any new variant blurs any of these contrasts, that variant has
broken the bestiary distinction rule and should be redesigned.
