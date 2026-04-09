---
name: Epic 04 — GlitchBug Reference Bible
description: Reference brief and design pillars for the photoreal GlitchBug remake
epic: 04
created: 2026-04-09
---

# GlitchBug Reference Bible

## What this document is

The brief that all subsequent Epic 04 modeling, sculpting, texturing,
rigging, and animation tasks must conform to. If a frame doesn't reinforce
one of the pillars below, redo it.

## The one-line pitch

> *"A predatory carapace insect made of fragmented code — beautiful at
> stillness, terrifying in motion, unmistakable in silhouette."*

## Design pillars (the only 5 things that matter)

1. **Silhouette priority: low triangle, wide mandibles, 6 splayed legs.**
   Read at 64×64 px. If it looks like a generic spider or beetle at that
   resolution, the silhouette is wrong. The defining features are
   (a) horizontal mandible spread roughly 1.4× the body width, (b) 6
   legs in three pairs splayed wide rather than tucked, (c) a low
   crouched body slung between the legs (NOT raised on stilts).

2. **Material story: hard chitin + soft glitch.**
   90% of the surface is dark, hard, edge-worn chitin plates with
   subsurface depth and a faint iridescent oil-slick sheen. The remaining
   10% is glitch — emissive cyan/magenta seam-cracks that pulse and
   crawl, exposed wing membranes that look like animated source code,
   and corrupted fragmenting edge-loops that drift away from the body
   like RGB artifacts on broken hardware.

3. **Animation language: jitter at micro scale, smooth at macro.**
   Body movement is slow, deliberate, weighty. Limb movement is
   sub-frame jittery — antennae and mandibles twitch, joints snap
   between poses with no in-between, eyes scan abruptly. The contrast
   between the macro smoothness and the micro jitter is the visual
   signature. A bug that looked smoothly insect-like would be generic
   horror; this one feels actively glitched.

4. **Color hierarchy at gameplay distance.**
   Player must see (a) BODY (dark chitin, ~98% of pixels), (b) THREAT
   (mandible inner faces and active claw tips, glow red), (c) WEAKNESS
   (the soft underbelly seam between thoracic plates, glows cyan when
   exposed during attack windups). Three layers, 3-second readability
   test from 6m camera distance.

5. **One unmistakable cliché embraced: it's an insect with sharp things.**
   Don't try to make this not-an-insect. Lean into the bug archetype
   100%. The novelty is in the digital corruption layer on TOP of a
   classic insect, not in being an alien creature.

## Reference families (descriptive — author each in Blender or replace with photoref later)

### Real-world insect anchors
- **Atlas beetle (Chalcosoma atlas)**: source for the hard segmented
  carapace and mandible asymmetry. Note the shoulder ridges where the
  thorax meets the abdomen — that's the seam where our cyan weakness
  glow emerges.
- **Ground beetle (Carabidae)**: source for the leg posture (wide
  splay, strong femur ridge, bent tibiae touching ground). Reference
  for how an insect distributes weight on 6 legs.
- **Mantis (Mantodea)**: source for the upper-leg "raptorial" posture
  reused on the front pair as primary attack arms. Inner serrated
  edge is where the red threat color lives.
- **Stag beetle (Lucanus cervus)**: mandible reference. Massive,
  elaborate, grotesque, with internal teeth visible from above.
- **Cicada nymph emerging**: source for the translucent membrane
  shader on the visible wings folded under elytra.

### Glitch / digital corruption anchors
- **CRT scanline tear artifacts**: horizontal RGB bleed offset on an
  otherwise stable image. The carapace gets thin scanline streaks
  that read as motion-blur even when the bug is still.
- **JPEG block compression breakdown**: 8×8 pixel block boundaries
  becoming visible. Apply to specific carapace plates as if those
  regions are "lower bitrate." Most visible at the elytra ridge.
- **Frame-skip ghost trails**: 2-3 frames of residual position
  trailing the moving body. Translates to a tendril-shader that drifts
  vertices behind fast joint motion.
- **Datamosh "I-frame missing" texture wrap**: when video glitches,
  pixels from a previous frame stretch across new geometry. Apply this
  to the soft underbelly so it looks like the rest of the body is
  "loading in" over older frame data.
- **Demoscene plasma fields**: sinusoidal color cycling on the wing
  membranes — reads as the only "alive" pixel area on an otherwise
  hardware-dead creature.

### Mood / lighting anchors
- **Hades enemies (Supergiant)**: high-contrast rim lighting on
  silhouettes against dark backgrounds. Validate every GlitchBug
  render with: can I see the silhouette unambiguously against pitch
  black with only a single rim?
- **Dark Souls Capra Demon arena lighting**: warm key + blue rim.
  GlitchBug should read at this lighting level.
- **Cyberpunk 2077 enemy overlays**: subtle hologram seams on
  enemies' edges. Our cyan crack lines should feel similarly diegetic.

### Anti-references (NOT this)
- Anything cartoon-eyed. No googly bug eyes. Eyes are 4 black holes
  in the head plate with cyan internal glow seen through the holes.
- Anything stylized with thick black outlines. The corruption visual
  should come from the shader, not from line art.
- Anything six-legged that walks like a horse. The 6-leg gait must
  read as alternating tripod (3 legs ground / 3 legs lifting) for
  movement and as splayed-low for standing.
- Generic "spider on plate" silhouette. Body must be wider than tall
  and the leg span horizontal, not vertical.

## Material zones (must be addressable as separate vertex groups for the texture pass)

| Zone | Coverage | Hue | Material | Notes |
|---|---|---|---|---|
| Carapace plates | 60% | Near-black with deep purple sheen | StandardMaterial3D, metallic 0.65, roughness 0.25, subtle anisotropy | The hero surface — must catch a rim light |
| Carapace plate edges | 5% | Iridescent oil-slick gradient | Same material with extra rim Fresnel | Where edge wear lives |
| Underbelly seam | 3% | Cyan emissive 2.5 | Emissive shader | The weakness point |
| Mandible inner | 4% | Red emissive 1.8 with serration shadow | Emissive + curvature darkening | Threat color |
| Antennae | 2% | Black chitin with cyan tip pulse | Standard + animated emission | The "scanner" — pulses 0.5Hz idle, 3Hz aggro |
| Eye pits | 1% | Pure black void with internal cyan glow | Backface emission trick | 4 unblinking pits, NOT lenses |
| Leg joints | 8% | Slightly lighter than carapace | Standard metallic 0.55 | Edge-wear here is critical for "lived in" feel |
| Leg shafts | 12% | Carapace base | Standard | Sub-segmentation visible at close range |
| Wing membrane | 4% | Iridescent translucent + animated code overlay | Emissive transmission | Only visible in attack-rear-up pose |
| Glitch seam cracks | 1% | Magenta emissive 4.0 | Emissive only | Crawls along plate seams over time |

## Silhouette pose targets (pick one for each task that needs a pose)

1. **Idle stand** — body low, legs splayed, mandibles relaxed slightly open, antennae drooped
2. **Alert** — body raised 30%, mandibles wide open, antennae erect and twitching
3. **Aggro rear** — front legs raised mantis-style, head pointed up at player, wing case partially raised exposing cyan underbelly
4. **Lunge mid-air** — body fully extended forward, all legs trailing back, mandibles closing
5. **Bite** — body driven down, mandibles fully closed, weight on all 6 legs
6. **Death curl** — legs tucked under, body upside-down, dissolving into magenta pixel fragments

## Motion timing reference

| State | Frame count | Notes |
|---|---|---|
| Idle blink/twitch | 60 fps loop, twitch every 30-40 frames | Antennae micro-jitter every 6 frames |
| Walk gait | 24 fps loop, alternating tripod | 12 frames per full step |
| Run gait | 16 fps loop, same alternating pattern | Faster + lower body |
| Aggro rear-up | 30 frames anticipation + 5 frames snap into pose | Hold the rear-up for 60 frames |
| Lunge | 8 frames windup + 4 frames extension + 12 frames recovery | Snappy |
| Bite | 6 frames close + 4 frames hold | The hold is where damage applies |
| Hit reaction | 8 frames recoil + 12 frames recovery | Small directional knockback |
| Death | 24 frames legs curl + 60 frames slow drop + 30 frames dissolve | Long enough to register a kill |

## Dimensional targets

- **Body length** (head plate to abdomen tip): 1.4 m
- **Leg span** (left tibia tip to right tibia tip at standing): 2.2 m
- **Body height** at standing (ground to top of carapace): 0.55 m
- **Aggro rear height** (ground to top of head when reared): 1.6 m
- **Triangle budget**: 4,000 tris for LOD0, 1,500 for LOD1, 600 for LOD2

## Production schedule for Epic 04

This bible drives tasks 2–50:
- Task 2 (concept sketches) → use the 6 silhouette targets above
- Tasks 3–6 (sculpting) → match the material zones and dimensional targets
- Task 7 (retopo) → hit the 4K tri budget
- Task 8 (UV) → carapace gets the highest-density UV island
- Tasks 9–13 (texturing) → use the material zone table
- Task 14 (rig) → 24 bones; 1 root + 1 hips + 4 spine/abdomen + 1 head
  + 2 mandibles + 2 antennae + 6 leg upper + 6 leg lower + 1 abdomen tip
- Tasks 15–23 (animation) → match the motion timing reference
- Tasks 24–25 (color/size variants) → the material zones above are
  the per-variant override points
- Tasks 26–29 (polish/validation) → run the 64×64 silhouette test
- Task 30 (hero shot) → use the lighting anchors above

## The 90-second trailer test for the GlitchBug

> "Cut to a dark dungeon corridor. A single GlitchBug rears up from
> the floor, mandibles snap wide, magenta crack lines pulse along the
> carapace, the cyan underbelly seam strobes once. Camera is on the
> player's eye line. Two seconds. Cut away. Did the audience just
> learn this thing is dangerous, this thing is alive, and this thing
> is corrupted?"

If yes, you've hit the bar. If anything in those 2 seconds reads as
"insect doll" instead of "predator carapace + corrupted code," go
back to whichever pillar broke and fix it.
