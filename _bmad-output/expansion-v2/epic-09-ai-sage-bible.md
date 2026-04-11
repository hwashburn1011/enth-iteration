---
name: Epic 09 — AI Sage Bible
description: Final design + asset reference for the AI Sage NPC. Lock state of the hero asset for downstream story + dialogue work.
epic: 09
created: 2026-04-09
---

# AI Sage Bible

## Identity

- **Name:** The Sage (no proper name — he's an AI fragment, not a person)
- **Role:** Mentor figure who explains the simulation to Globbler
- **Voice:** Calm, contemplative, knows more than he says
- **Tone:** Warmth + sorrow simultaneously
- **Function:** Appears in cutscenes, dialogue at iteration boundaries,
  and key story moments

## Locked design (chosen Variant 1 — Classic Mentor)

- **Height:** 1.85m
- **Hover offset:** 5cm above ground (always)
- **Robes:** Deep teal #0E4053 with cyan accent embroidery + scrolling
  ASCII code overlay (the in-universe "structured data" cloth)
- **Hood:** Up at all times — face partially visible from below
- **Skin:** Warm flesh, slightly aged
- **Eyes:** Warm cyan glow at emission strength 6.0
- **Beard:** Long grey, hangs from chin, neat
- **Staff:** 2.10m chrome rod + cyan crystal at top (emission 12.0)
- **Data orbs:** 4 floating cyan spheres (emission 10.0) at:
  - Front-up at z=2.00
  - Right shoulder z=1.80
  - Left shoulder z=1.80
  - Back z=1.95

## Material zones (locked)

| Zone | Material | Metallic | Roughness | Emission |
|---|---|---|---|---|
| Robe outer | Sage_RobeOuter | 0.0 | 0.65 | — |
| Robe inner | Sage_RobeInner | 0.0 | 0.85 | — |
| Skin | Sage_Skin | 0.0 | 0.55 | — |
| Eyes | Sage_Eye | 0.0 | 0.10 | cyan 6.0 |
| Beard | Sage_Beard | 0.0 | 0.85 | — |
| Staff body | Sage_Staff | 1.0 | 0.10 | — |
| Staff crystal | Sage_Crystal | 0.0 | 0.05 | cyan 12.0 |
| Data orbs | Sage_DataOrb | 0.0 | 0.05 | cyan 10.0 |

## Asset spec

- **Source file:** `_art_source/characters/ai_sage.blend`
- **Pipeline script:** `_art_source/characters/scripts/epic09_ai_sage_pipeline.py`
- **Close-out script:** `_art_source/characters/scripts/epic09_close_out.py`
- **Rig:** Armature_AISage, 32 bones (root + hover_anchor + hips + spine
  + chest + neck + head + beard + shoulder/arm/hand R+L + 4 cloth chain
  bones + hood + 3 staff bones + 4 orb bones + leg bones)
- **LOD chain:** LOD0 3500 / LOD1 1750 / LOD2 700 polys
- **Textures:** ai_sage_normal/ao/curvature/cavity/albedo at 1024x1024
- **Shape keys (face):** smile, frown, sad, surprise, blink, wisdom

## Animation library (13 actions)

1. `ai_sage_wise_idle` 120f loop — slow contemplative breath, hover bob, orb orbits
2. `ai_sage_speaking` 60f loop — head nods, hand gestures, ORBS BRIGHTEN
3. `ai_sage_deep_thought` 90f loop — head down, hand to chin, ORBS DIM
4. `ai_sage_casting_wisdom` 50f — arm raises, orbs converge to 2.0x scale
5. `ai_sage_approach_walk` 40f loop — staff tap on ground, cloth follows
6. `ai_sage_sit_meditative` 60f loop — folded legs and arms
7. `ai_sage_stand_from_sit` 24f — rising sequence
8. `ai_sage_react_surprise` 30f — slow contemplative head snap (no fast moves)
9. `ai_sage_react_sad` 40f — head sinks, hand to face (knows what's coming)
10. `ai_sage_fade_in_out` 24f — scale ramp for mysterious arrivals
11. `ai_sage_blessing` 60f — both arms wide, all 4 orbs flare to 2.5x
12. `ai_sage_memory_show` 50f — staff raised overhead, crystal flares to 2.5x
13. `ai_sage_cape_secondary` 40f loop — cloth chain sway with phase offsets

## Component layer

- **AISageNPC component** (scripts/components/ai_sage_npc.gd) — drives
  hover motion, eye-tracking (head bone follows player at 8m), aura
  particle system, dialogue intensity uniform, interaction prompt
  range detection, dialogue system hookup
- **SageSummoningCircle component** (scripts/components/sage_summoning_circle.gd)
  — 3m radius cyan magic circle decal that fades in when Sage appears
  + slow-rotates while present + fades out when he leaves
- **ai_sage_robe.gdshader** — PBR base + Fresnel cyan rim + scrolling
  code overlay + dialogue_intensity uniform that brightens emission

## Hero shots (`_art_source/characters/hero_shots/`)

- `ai_sage_hero_3q.png` — 1920x1080 cinematic 3/4 angle
- `ai_sage_hero_side.png` — 1920x1080 profile
- `ai_sage_hero_belowup.png` — 1920x1080 worm's-eye dramatic

## Portraits (`assets/textures/portraits/`)

- `ai_sage_portrait.png` — 512x768 dialogue UI portrait (neutral)
- `ai_sage_portrait_smile.png` — emotion variant
- `ai_sage_portrait_sad.png` — emotion variant
- `ai_sage_portrait_surprise.png` — emotion variant
- `ai_sage_portrait_wisdom.png` — emotion variant

## Lighting validation (`_art_source/characters/lighting_tests/`)

5x 768x768 renders confirming the Sage reads correctly across:
- Town day (sun)
- Town dusk (warm key + cool fill)
- Dialogue intimate (close 2-light)
- Mystical void (cyan + magenta + top)
- Cinematic hero (full 4-light + spot)

## Anti-patterns enforced

- ❌ Fully visible face (hood always casts a partial shadow)
- ❌ Bright colors on robes (teal + cyan only — no reds, no golds)
- ❌ Fast movements (even react_surprise is slow contemplative)
- ❌ Combat poses (he never fights)
- ❌ Grounded feet (hover offset baked into the rig + shader)

## Cross-system integration

- **DialogueManager hookup:** AISageNPC.start_dialogue() + .end_dialogue()
- **EventBus signals:** interact_prompt_shown, interact_prompt_hidden,
  dialogue_started, dialogue_ended
- **SfxManager hook:** &"ai_sage_chime_hum" looping ambient
- **HUD integration:** interact_prompt_shown listener spawns the
  custom Sage interaction icon
