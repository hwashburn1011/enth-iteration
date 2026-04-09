---
name: Epic 09 — AI Sage NPC References
description: Reference families + 5 sage concept variants + design pillars for the AI Sage hero NPC asset
epic: 09
created: 2026-04-09
---

# AI Sage — Reference + Design Document

## Why this character matters

The AI Sage is the player's mentor figure. He's the in-universe voice that
explains the simulation, the iterations, and Globbler's purpose. The
player will see him in EVERY iteration, in cutscenes, in dialogue, in
the iteration-end memory unlocks. He needs to be:

1. **Instantly readable as a wise mentor** — silhouette communicates
   "old, wise, slightly otherworldly" before any dialogue plays
2. **Photoreal compared to current art** — this is a HERO asset, treated
   with the same care as Globbler himself
3. **In-universe** — he's an AI fragment from the original simulation,
   not a typical fantasy wizard. Robes are MORE digital than fabric.
4. **Emotionally legible** — his face shows wisdom + sorrow (he knows
   what's coming and can't stop it)

## Reference families (15 total)

### Mentor character archetypes
1. **Sea of Stars — Elder Mir** — warm wise mentor with subtle humor
2. **Hades — Chiron** — old, dignified, slightly weathered
3. **The Last Story — Lowell** — knows more than he says
4. **Final Fantasy XIV — Louisoix** — robes + staff + presence
5. **Hollow Knight — White Lady** — radiates importance through stillness
6. **Octopath Traveler — Z'aanta** — old wanderer with wise eyes
7. **Bastion — Rucks** — narrator energy, knows the whole story

### Visual reference families
8. **Eastern temple monk photography** — cloth fold reference
9. **Renaissance paintings of saints** — robe + halo composition
10. **Bjorn Hurri concept art for elders** — face geometry reference
11. **Glowing data streams in modern UI** — the in-universe "robe" texture
12. **Holographic projections (sci-fi)** — partial transparency cues
13. **Ancient calligraphy on cloth** — symbol overlay for the robes
14. **Bioluminescent jellyfish** — the aura particle reference
15. **NASA Voyager golden record imagery** — the in-universe artifact feel

## 5 design pillars (inviolable)

1. **The Sage is OLDER than Globbler in proportions.** Where Globbler
   is chunky and youthful, the Sage is taller (1.85m vs 1.5m) and his
   limbs are longer relative to his body. Posture is slightly stooped.

2. **The robes are DIGITAL not fabric.** They drape like cloth but their
   texture is scrolling code, calligraphy symbols, and faint geometric
   patterns. The "fabric" is structured data rendered as garment.

3. **The face shows WARMTH and SORROW simultaneously.** Soft eyes with
   crow's feet from smiling, but a slight downturn at the mouth. He
   knows what Globbler is going through and what's coming.

4. **The Sage HOVERS slightly.** His feet do not touch the ground —
   they float ~5cm above it. This is the "I am not entirely here"
   visual cue that he's a memory of an AI fragment.

5. **Floating data orbs accompany the Sage.** 3-5 small glowing spheres
   that orbit slowly around his head and shoulders. They are his
   "thoughts made visible" — they brighten when he speaks and dim when
   he listens.

## 5 sage variants (concept exploration)

The final design will pick one. These are the 5 directions:

### Variant 1 — "Classic Mentor" (chosen baseline)
- Tall hooded figure in long robes
- Hood up, face partially shadowed
- Long staff with a single data crystal at the top
- 4 floating data orbs around his head
- Material: deep teal robes with cyan accent embroidery + chrome staff
- The "default" mentor look with one in-universe twist (the orbs)

### Variant 2 — "Hollow Authority"
- Robes are completely empty inside — no body, just structured fabric
  held up by floating data
- Two glowing eye-points in the void of the hood
- Staff is more like a tuning fork — two prongs with arcing energy
- Mood: more ominous, more mysterious
- Reject reason: too scary for a mentor figure

### Variant 3 — "Glitched Hologram"
- The Sage is visibly a HOLOGRAM with scan lines + RGB chromatic split
- Solid form with translucent edges
- No staff — gestures with bare hands that leave brief data trails
- Mood: clearly inhuman, a recording playing back
- Reject reason: too cold, doesn't feel like a person

### Variant 4 — "Crystalline Elder"
- Body is made of nested crystalline shells with light passing through
- Long beard of light strands
- Floats in a meditation pose, never walks
- Mood: too alien — the player needs to relate to him
- Reject reason: harder to animate dialogue + doesn't feel grounded

### Variant 5 — "Digital Monk"
- Wears more practical layered robes (think kung fu monk)
- Bald head with circuit-pattern tattoos
- No staff — uses his hands
- Mood: more modest, less imposing
- Reject reason: doesn't have the "important figure" presence the
  story needs

## CHOSEN: Variant 1 — Classic Mentor

The final asset will be Variant 1 with these locked details:
- **Height:** 1.85m
- **Hood:** up at all times (face visible from below)
- **Staff:** long chrome rod with cyan data crystal at the top
- **Orbs:** 4 floating data spheres at chest, shoulder R, shoulder L, behind head
- **Robe color:** deep teal #0E4053 with cyan accent embroidery
- **Staff material:** chrome with cyan emissive crystal
- **Hover height:** 5cm above ground
- **Aura:** subtle cyan particle field, intensifies during dialogue

## Material zones

| Zone | Material | Notes |
|---|---|---|
| Robe outer | teal cloth + scrolling code overlay | The hero material |
| Robe inner | dark void | Visible in deep folds |
| Hood | teal cloth | Always shadows the face |
| Skin (face) | warm flesh | Soft, slightly aged |
| Eyes | warm cyan | Glow softly |
| Hair (beard) | light grey | Long but neat |
| Staff body | chrome | Polished |
| Staff crystal | cyan emissive | The light source |
| Data orbs | cyan emissive | Pure light |

## Validation checklist

- [ ] At 64x64 silhouette, the Sage reads as "tall hooded mentor with staff"
- [ ] Player can see his face clearly when standing 2m in front
- [ ] Robes flow naturally during walk + gesture animations
- [ ] Hover height is consistent across all animations
- [ ] Orbs orbit smoothly without intersecting body geometry
- [ ] Aura particle density scales with dialogue importance
- [ ] Face shows warmth + sorrow simultaneously in idle pose

## Anti-patterns

- **No fully visible face.** The hood always casts a partial shadow
  over the upper face — keeps the mystery.
- **No bright colors on robes.** Teal + cyan only. No reds, no golds.
  This isn't a king, he's a ghost mentor.
- **No fast movements.** Even his "react surprise" should be slow and
  contemplative. He has all the time in the world.
- **No combat poses.** He never fights. The closest he gets is the
  "casting wisdom" pose where he raises a hand toward the orbs.
- **No grounded feet.** He hovers. Always.
