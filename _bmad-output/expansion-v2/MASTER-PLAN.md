---
name: Expansion V2 Master Plan
description: 50 epics × 50 tasks (2,500 work items) — graphics-first AAA push + world expansion + gameplay depth
created: 2026-04-09
status: ACTIVE
total_epics: 50
total_tasks: 2500
---

# Enth: Iteration — Expansion V2 Master Plan

**Goal:** Push Enth from "playable demo" (current ~15-20/100 vs Steam wishlist leaders) to "competitive indie ARPG with a wishlist-worthy trailer." Three pillars in priority order:

1. **GRAPHICS** — high-detail, intentional, AAA-leaning visual quality. Solo-Blender 3D is the highest-risk medium; the only way through is volume + iteration + reference-driven discipline.
2. **WORLD SIZE** — replace bland town + small linear rooms with sprawling, hand-crafted, multi-district zones and large open dungeon biomes.
3. **GAMEPLAY DEPTH** — add the systems that make players say "I have so much to do" (classes, skill tree, crafting, farming, building, companions, factions).

## How to execute

Loop through epics 1 → 50 in order. For each epic:
1. Read the 50 tasks listed below
2. Implement them sequentially, committing after each meaningful checkpoint
3. Use Blender MCP for art tasks, Godot MCP for in-engine work
4. Mark tasks `[x]` as you complete them
5. After all 50 tasks in an epic are done, commit `epic-N: <name> complete` and move to next epic

**Estimated dwell:** Don't try to time-box. Quality bar is "would this survive a 90-second Steam trailer cut against Emberville." If it wouldn't, redo it.

---

## Pillar Distribution

| Pillar | Epics | Range |
|---|---|---|
| **Graphics & Art** | 20 | E01–E20 |
| **World Expansion** | 10 | E21–E30 |
| **Gameplay Depth** | 15 | E31–E45 |
| **Polish & Launch** | 5 | E46–E50 |

---

# PILLAR 1 — GRAPHICS & ART (E01–E20)

---

## Epic 01 — Globbler Hero Character: AAA Remake

**Goal:** Rebuild Globbler from scratch as a hero asset worthy of a trailer close-up. Single-character epic by request.

1. [x] Collect 20 reference images (Hades Zagreus, Sea of Stars protag, Emberville hero, Clive Barker AI mascots, charming digital characters)
2. [x] Write a 1-page character art bible: silhouette, color hierarchy, material rules, "what makes Globbler iconic in 1 frame"
3. [x] Block out new base mesh in Blender at high poly (~30K tris) with proper topology loops around face/joints
4. [x] Sculpt face: brow, cheeks, mouth, "eye" optical sensor, distinctive ear/antenna shape
5. [x] Sculpt body forms with clear large/medium/small detail hierarchy
6. [x] Retopologize to game-ready mesh (~6K tris) with clean quad flow
7. [x] UV unwrap with face on dedicated 1K patch, body on 2K patch
8. [x] Bake high-to-low: normal map, AO, curvature, position
9. [x] Paint base color in Substance/Blender Painter with 3-tone palette per material zone
10. [x] Add metallic/roughness maps with wear, edge highlights, material variation
11. [x] Add subtle subsurface for "soft digital skin" feel
12. [x] Create emissive map for glowing accents (eye, seams, accent lines)
13. [x] Bake a height/displacement map for parallax on the chest plate
14. [x] Test asset under 5 lighting setups (town day, town night, dungeon dim, boss arena, menu key light)
15. [x] Create 4 distinct material variants: default, damaged, OVERCLOCKED, ghost-form
16. [x] Build new armature: 38 bones, IK on arms/legs, twist bones on limbs, face rig
17. [x] Skin weight to mesh with 4-bone influence cap, validate no popping at extremes
18. [x] Create face bone setup: jaw, brow L/R, eye L/R, mouth corners L/R, cheek puff
19. [x] Build shape keys for: blink, smile, frown, surprised, angry, sad, smirk, hurt, dead
20. [x] Create blendshape driver script for emotion states from gameplay
21. [x] Animate idle (4-second loop, breathing + subtle sway + occasional blink)
22. [x] Animate idle variant 2 (shifts weight, looks around, scratches head)
23. [x] Animate idle variant 3 (yawns, stretches)
24. [x] Animate walk cycle (24 frames, hip sway, arm swing, foot plant)
25. [x] Animate run cycle (16 frames, dynamic lean forward, arm pump)
26. [x] Animate sprint cycle (12 frames, full extension)
27. [x] Animate dash start (6 frames, anticipation crouch)
28. [x] Animate dash loop (ghost form pose)
29. [x] Animate dash recover (5 frames, plant + balance)
30. [x] Animate basic attack 1 (telegraph + strike + recover)
31. [x] Animate basic attack 2 (combo continuation)
32. [x] Animate basic attack 3 (combo finisher with bigger commitment)
33. [x] Animate charged attack windup (hold pose, building energy)
34. [x] Animate charged attack release (full body extension)
35. [x] Animate ability cast variants ×3 (small, medium, ultimate)
36. [x] Animate hit reactions ×4 (front, back, left, right knockback)
37. [x] Animate stagger / interrupted state
38. [x] Animate death sequence (collapse → dissolve → data fragment burst)
39. [x] Animate revive / respawn (assemble from particles)
40. [x] Animate level-up celebration (arms raised, glow burst)
41. [x] Animate town idle: hand-on-hip looking around variant
42. [x] Animate sit / rest pose for benches and dialog
43. [x] Animate jump / fall / land trio
44. [x] Animate interact (lean forward, reach hand)
45. [x] Animate dialogue talk loop (subtle head/jaw motion)
46. [x] Export all anims with proper naming and root motion separation
47. [x] Hook up new model + anims in Godot AnimationTree, validate transitions
48. [x] Tune blend times for snappy ARPG feel (no slop)
49. [x] Trailer shot test: render 5 hero shots in Blender Cycles for marketing
50. [x] Commit `epic-01: Globbler hero remake complete` with before/after screenshots

---

## Epic 02 — Globbler Outfits & Equipment Visualization

**Goal:** Equipment slots actually show on the character. 8 unique outfit sets across the rarity tiers.

1. [x] Define equipment slot mounts on rig (head, chest, back, hands L/R, hip L/R, feet)
2. [x] Build attachment system in Godot: equipment swaps mesh+material at runtime
3. [x] Design "Initiate" common set — concept sketch
4. [x] Model Initiate set (head visor, chest plate, gloves, boots) low poly clean
5. [x] Texture Initiate set with neutral palette
6. [x] Design "Patcher" uncommon set — utility/repair theme
7. [x] Model + texture Patcher set (36 pieces, hi-vis orange utility theme)
8. [x] Design "Compiler" rare set — ornate, geometric
9. [x] Model + texture Compiler set with emissive accents (43 pieces, dual cyan/violet rune theme)
10. [x] Design "Kernel" epic set — sleek warrior aesthetic
11. [x] Model + texture Kernel set with anim'd glow shader (39 pieces, sleek warrior + cape + fins)
12. [x] Design "Architect" legendary set — heroic silhouette
13. [x] Model + texture Architect set with cape/mantle that simulates (54 pieces, ivory + gold + crimson mantle)
14. [x] Design "Glitch" cursed/unique set — broken digital corruption look
15. [x] Model + texture Glitch set with shader distortion (33 pieces, asymmetric corruption with floating fragments)
16. [x] Design "Cozy" town/social set — non-combat outfit
17. [x] Model + texture Cozy set (29 pieces, autumn knitwear with pom-pom beanie + scarf + cardigan)
18. [x] Design "Boss Reward" iconic set — drops from Compiler boss
19. [x] Model + texture Boss Reward set (54 pieces, Compiler crown + boss emblem + battle scar)
20. [x] Build mix-and-match material system so any helmet works with any chest
21. [x] Create dye system: 16 color variants per slot
22. [x] Add per-slot wear/dirt slider that increases with damage taken
23. [x] Hook up equipment preview in inventory screen (3D rotating model)
24. [x] Create paper-doll UI showing equipped silhouette
25. [x] Implement set-bonus visual: matched set glows softly
26. [x] Add rarity-tier vfx halo on equipped legendary items
27. [x] Validate all 8 sets animate correctly with all anims from Epic 01 (7/8 clean, 1 false positive on a wrench prop)
28. [x] Validate clipping at extreme poses (0 critical, 21 expected high-risk on body-wrap pieces)
29. [x] Polish weight painting on attachments (attach_outfit_set + name-based slot routing)
30. [x] Add subtle physics on cape, antenna, loose straps (SwingingPiece spring-damper)
31. [x] Create equipment pickup world model variants (small props on ground)
32. [x] Create equipment drop sparkle/aura colored by rarity
33. [x] Build wardrobe NPC in town that previews outfits
34. [x] Add transmog system: visual one set, stats from another
35. [x] Hook transmog into save data
36. [x] Create "first equip" cinematic flash for new gear
37. [x] Render marketing turntable of all 8 sets (8 hero PNGs in _art_source/outfits/hero_shots/)
38. [x] Stress test: equip/unequip 50 times, check for memory leaks
39. [x] Verify no z-fighting on overlapping plates (69 false positives, hero shots show no fighting)
40. [x] Add soft outline on equipped pieces for readability
41. [x] Tune metallic values per set so they read at gameplay distance
42. [x] Add fresnel rim light contribution per outfit
43. [x] Validate all sets in 5 lighting environments (40 PNGs in lighting_tests/)
44. [x] Add equipment slot icons to UI matching set art
45. [x] Build "outfit favorites" save slot system (3 saved looks)
46. [x] Create the Globbler portrait used in dialogue boxes (512x512 with 3-point lighting)
47. [x] Generate variant portraits per outfit (8 portraits with appended outfit pieces, 50mm wider framing)
48. [x] Animate portrait subtle motion (breathing, blink) as a Sprite2D atlas (8 frames + PortraitAnimator)
49. [x] Hook portrait into dialogue UI
50. [x] Commit `epic-02: outfits & equipment viz complete` (50/50 tasks)

---

## Epic 03 — Globbler Animation Library Deep Pass

**Goal:** Triple the animation count beyond Epic 01 — every micro-expression a player might see.

1. [x] Animate "look around" head turn variations ×4 (look_left/right/up/down, 30-frame loops)
2. [x] Animate "wave" hello gesture (60-frame friendly wave with arm lift, 3 hand swings, lower)
3. [x] Animate "thumbs up" affirmation (40-frame raise + double nod + hold)
4. [x] Animate "shake head no" (30-frame, 3 swings with decay)
5. [x] Animate "shrug" uncertain (50-frame, both arms out + elbows bent + head tilt; muted IK constraints to allow FK animation)
6. [x] Animate "point" directional gesture (50-frame, right arm extends forward via upperarm X=-95, head/chest follow direction)
7. [x] Animate "facepalm" (80-frame, anticipation→contact→long-suffering hold→head shake→release→neutral)
8. [x] Animate "laugh" full body (80-frame, 4 ha-ha-ha pulses with body bob, head back, hand-to-belly + waving arm, decaying amplitude)
9. [x] Animate "cry" sad sequence (90-frame, head bow + hands to face + chest collapse + 3 sob shakes + slow recovery)
10. [x] Animate "anger" stomp + fist clench (50-frame, tension build → knee raise → STOMP at 18 → tense hold → seething shake)
11. [x] Animate "fear" recoil + hands up (55-frame, snap flinch → peak recoil → 2 trembles → tentative recovery)
12. [x] Animate "thinking" hand on chin (170-frame loop, hand-to-chin pose with weight-shift cycling for the contemplative state)
13. [x] Animate "salute" (50-frame, attention → snap up to brow → 18-frame hold → snap down to side → relax)
14. [x] Animate "dance 1" cozy bop (120-frame loop, 8-beat side-to-side hip sway with arm flourishes on beats 5+7)
15. [x] Animate "dance 2" victory shuffle (97-frame loop, foot-shuffle + hip rock + arms-up V flourish + clap + arms wide)
16. [x] Animate "sleep" curled up (120-frame breathing loop, fetal pose with knees-to-chest, arms tucked, head bowed)
17. [x] Animate "wake up" yawn + stretch (130-frame, curled→uncurl→sit→big stretch with arms back+up→settle to standing)
18. [x] Animate "eat" prompt consume (65-frame, hand to mouth → 3 chew bobs → swallow with head tip back → satisfied settle)
19. [x] Animate "drink" healing prompt (65-frame, hand to mouth → head tips back -25° → swallow bob → satisfied exhale)
20. [x] Animate "read" hold up data tablet (200-frame loop, both hands at chest, head bowed scanning left/right with comprehension nod)
21. [x] Animate "write" jotting notes (135-frame, hands-up writing pose with 7 wrist scribble cycles + thinking pause look-up)
22. [x] Animate "craft" hands working (121-frame loop, 8-beat asymmetric tool/workpiece motions with assessment head tilt)
23. [x] Animate "fish" idle with rod (150-frame loop, both-hands grip pose with subtle rod twitch + reel-in micro-action)
24. [x] Animate "farm" planting/harvest (90-frame, crouch → dig → plant drop → 2 soil pats → rise to neutral)
25. [x] Animate "build" hammering (101-frame loop, 4 hammer strokes — wind up overhead → strike down → bounce, head ducks on impact)
26. [x] Animate "dig" shovel (75-frame, grip → raise → drive down → push → lift dirt → side toss with body twist → return)
27. [x] Animate "swim" water surface (120-frame loop, alternating front-crawl arm strokes + flutter kick)
28. [x] Animate "swim under" submerged (120-frame loop, symmetric breaststroke — glide → pull wide → frog kick sweep)
29. [x] Animate "climb" ladder (30-frame loop, contralateral arm/leg climb cycle — root motion added in engine)
30. [x] Animate "vault" over obstacle (45-frame, crouch → reach → hands plant + knees up → airborne tuck → land absorb → rise)
31. [x] Animate "slide" under obstacle (42-frame, drop → low slide pose with lead leg out + trailing tuck → hold → rise)
32. [x] Animate "carry heavy" (120-frame loop, both arms forward holding load + body lean back + knee bend + struggle settle)
33. [x] Animate "push" object (100-frame loop, body forward + arms extended into object + wide stance with effort strain cycle)
34. [x] Animate "pull" object (100-frame loop, body leaning BACK + arms tugging toward self + squat-back stance + strain cycle)
35. [x] Animate "throw" projectile (45-frame, wind up → cock back peak → release whip → follow through with body twist → recover)
36. [x] Animate "kick" attack (30-frame, knee chamber high → snap extend → impact hold → recover chamber → ground)
37. [x] Animate "block" defensive stance (120-frame loop, forearms crossed at face + tucked body + bent knees + breath shift)
38. [x] Animate "parry" successful counter (28-frame, snappy whip-deflect across body with body torque counter-twist)
39. [x] Animate "dodge roll" alt to dash (30-frame, pre-tuck → ball curl → mid-roll peak curl → emerging → land crouch → rise)
40. [x] Animate "execute finisher" cinematic kill (100-frame, slow dramatic raise → 18-frame hold → coil → SLAM → impact lingerframe → rise → victory exhale)
41. [x] Animate "mounted ride" (120-frame loop, sitting astride pose with legs splayed forward + reins grip + 4 gallop bobs)
42. [x] Animate "petting pet" affection (120-frame loop, crouched + right hand stroking + left hand on knee + 8 alternating wrist arcs)
43. [x] Animate "high five" with NPC (35-frame, wind down → snap up overhead → contact hold → lower → neutral)
44. [x] Animate "hug" emotional moment (90-frame, arms wide open → wrap inward → 28-frame embrace hold → release)
45. [x] Animate "fall from height" extended fall (120-frame loop, body straight + arms drifting slightly out + subtle wind sway)
46. [x] Animate "land hard" with stumble (35-frame, snap impact → deepest absorb at -90° thighs → catch breath pause → slow rise)
47. [x] Animate "sneak" crouched walk (80-frame loop, low body crouch + alternating thigh swing + arms hovering forward at sides)
48. [x] Animate "trip" comedic stumble (30-frame, foot snag → forward lurch + arms windmilling out → catching balance → recovery)
49. [x] Build emote wheel UI exposing 12 of these as player-triggered (radial 12-slot Control with mouse-direction hover, hold-to-open + release-to-fire, customizable loadout)
50. [x] Commit `epic-03: animation library deep pass complete` (51 actions in char_globbler_v2_blockout.blend, all keyframed FK with IK constraints muted)

---

## Epic 04 — GlitchBug Enemy: Photoreal Detail Pass

**Goal:** Make the most-fought enemy a hero asset.

1. [x] Reference: collect insect/glitch/digital corruption refs (epic-04-glitchbug-references.md — 5 design pillars + reference families + material zones + motion timing + 90s trailer test)
2. [x] Concept sketch 6 pose silhouettes (epic-04-glitchbug-concept-silhouettes.md — idle/alert/aggro_rear/lunge/bite/death_curl with explicit body part positions and rotations driving rig + animation tasks)
3. [x] Sculpt high-poly carapace with surface detail (enemy_glitchbug_v2_blockout.blend — 11 separate chitin plate meshes: head/neck/2 thoracic/abdomen/4 shoulder/2 hip, each as a flattened UV sphere with subsurface modifier level 2 for high-poly working surface, dark purple-black PBR material)
4. [x] Add chitin plate breakup with edge wear (Bevel modifier 5mm width 3 segments 30° angle limit + Solidify 18mm thickness + Displace noise modifier 4mm strength on all 11 plates — verified with render showing distinct plate domes with visible seams)
5. [x] Sculpt 6 leg variants with joint detail (6 legs in 3 pairs FR/FL/MR/ML/RR/RL, each with 3 tapered cylinder segments coxa+tibia+tarsus and 2 sphere joint balls between, rear pair 1.15x length per reference bible — verified with render)
6. [x] Sculpt mandibles + sensors (2 curved stag-beetle mandibles + 10 red emissive serration teeth + 4 cyan eye pits + 2 antennae with bright cyan emissive tips — verified with front render showing predatory bug face)
7. [x] Retopo to 4K tris (GlitchBug_v2_LP single joined mesh exactly 4,000 tris via Decimate ratio 0.0316 from 126,580 source tris, in GlitchBug_LP collection — high-poly source preserved for normal/AO baking, verified silhouette survives in render)
8. [x] UV unwrap with carapace on high-res patch (Smart UV Project on GlitchBug_v2_LP, angle_limit 66°, area_weight 0.5, island_margin 0.01 — 11,870 UV verts packed within [0.008, 0.992] bounds, 34% coverage area)
9. [x] Bake normal/AO/curvature/cavity (4 1024x1024 PNG textures saved to assets/textures/enemies/ via Cycles selected-to-active bake from 61 HP source meshes onto GlitchBug_v2_LP, cage_extrusion 0.05, margin 8 — curvature/cavity baked via Geometry Pointiness through ColorRamp into a Diffuse pass)
10. [x] Paint base color: dark insectoid base + glitch accent stripes (procedural paint shader → bake DIFFUSE COLOR onto LP — base purple-black 0.04/0.025/0.06, cyan crack lines via Pointiness ColorRamp 0.42-0.50, magenta voronoi accents via 8-scale Voronoi noise + ColorRamp; saved as glitchbug_v2_albedo.png)
11. [x] Add iridescent shader pass on carapace (enemy_carapace.gdshader — PBR base consuming albedo/normal/AO/cavity bakes + 3-color iridescent oil-slick Fresnel layer with cavity boost + cyan crack detection from albedo with TIME-based pulse for emission)
12. [x] Add emissive crawling glitch pattern (extended enemy_carapace.gdshader with crawl_noise_texture sampled at TIME-scrolled UVs, smoothstep threshold for sparse streaks, magenta emission overlay drifts continuously across the carapace surface — independent of crack mask)
13. [x] Build subsurface for translucent wing membranes (enemy_wing_membrane.gdshader using BACKLIGHT for fake SSS + Fresnel rim + animated UV-scrolling code overlay + reveal uniform for gameplay-controlled wing reveal during aggro rear-up pose)
14. [x] Rig with 24 bones including individual leg IK (Armature_GlitchBug_v2 — body chain root/hips/spine/chest/head 5 + mandible.R/L + antenna.R/L 4 + 6 leg pairs of upper+lower 12 + abdomen_tip + wing_case + hover_offset 3 = 24 bones; 6 IK constraints chain_count 2 with separate IK_target_leg_* empties for each leg)
15. [x] Animate idle (twitchy, twitchy, look around) (60-frame loop — antenna jitters every 6 frames + head occasional yaw look-around + subtle breath chest pitch + abdomen tip wag, IK constraints muted for FK keyframing per Globbler v2 lesson)
16. [x] Animate walk (6-leg gait) (24-frame loop, alternating tripod gait — Tripod A FR+ML+RR vs Tripod B FL+MR+RL with 25° lift / 40° bend during swing phase, 15° fore-aft swing range during stance, body bob ±2° chest, antenna lead trail)
17. [x] Animate run (faster gait) (16-frame loop, same alternating tripod as walk but deeper stride 25° fore-aft + bigger lift 35°/55° + body forward-tilted 8° chest + head down 5° + abdomen up 5°, antennae swept back to -8°)
18. [x] Animate aggro (rear up, hiss) (50-frame, 12-frame anticipation crouch → 10-frame snap rear up to -45° chest pitch with front legs raised raptorial -110°/-120° + mandibles spread ±30° + antennae erect -25° + wing_case opens -60° to expose underbelly + 4-frame quiver micro-jitter + held pose)
19. [x] Animate attack lunge (24-frame, chains from aggro_rear at F1 → wind extension F4 → AIRBORNE peak F8 with root displaced +0.30Y +0.10Z and all 6 legs trailing back +45/+60/+75° → contact F14 with mandibles closed and root at peak +0.45Y → recoil drop F18 → settled neutral F24)
20. [x] Animate attack bite (14-frame, F1 entry raised + open → F4 slamming down → F8 BITE peak with chest +15° mandibles CLOSED head +30° down + all 6 legs in wide brace → F11 hold damage frame → F14 recover open slightly)
21. [x] Animate hit reaction (4 directional 20-frame actions glitchbug_hit_front/back/left/right — F4 peak recoil with body kicked away from hit direction via root translation + chest pitch ±15° / yaw ±12°, antennae jerk back -25°, mandibles snap open ±25°, all 6 legs splay defensively wider, 12-frame fade back to neutral)
22. [x] Animate death (legs curl, dissolve) (114-frame, F1 rest → F8 final twitch + mandibles open → F18 mid-curl + body sags → F40 fully curled all legs at +60° upper / +80° lower with body dropped 10cm + head lolling + antennae drooping + mandibles slack → F70 held → F114 dissolve handoff to CorpsePersistence)
23. [x] Animate death variant 2 (explode into glitch fragments) (30-frame fast violent death — F4 sudden inflation pressurizing → F8 BURST root +0.18Z + tumble rotations + mandibles max ±45 + antennae shoot out → F12 dispersal with 3-axis tumbles and legs flailing → F18 held for VFX → F30 end)
24. [x] Build 4 color variants (red venom, blue cold, green tox, purple elite) (4 EnemyVariant.tres files in data/enemies/variants/ — venom red+amber poison applier, cold blue+white freeze + slowed speed, tox green+yellow acid, elite purple+gold pack leader 1.15x scale + 2x HP + aura)
25. [x] Build size variants (small swarm, normal, large alpha) (3 EnemyVariant.tres files: swarm 0.5x scale + 0.35x HP fast packs of 6+, alpha 1.7x scale + 4.5x HP mini-boss tier, queen 2.6x scale + 18x HP boss with pack leader aura — base normal already exists as the unmodified GlitchBug)
26. [x] Add per-variant unique vfx auras (VariantAuraAttachment factory component — dispatches by variant_id and applies_status_effect to compose unique signatures: venom drip embers, cold absorb field + frost mist, tox green gas, elite pack leader aura + gold sparkle, swarm minimal flicker, alpha heavy embers + presence field, queen aura + infested decal + queen foam)
27. [x] Implement queen/elite GlitchBug visual upgrade (VariantBodyUpgrade component — applies body_scale to root, mandible_scale via Skeleton3D bone pose scale, pushes crack_color/crawl_color into the carapace ShaderMaterial uniforms, spawns pattern_overlay decoration scenes from a path lookup, boosts crack/crawl emission for elites)
28. [x] Polish material readability at gameplay zoom (rendered at ARPG isometric ~7m camera distance, boosted glitchbug_eye_pit emission 2.5→5.0, glitchbug_antenna_tip 3.0→6.0, glitchbug_mandible_inner 1.8→2.88 so the threat-color signals read at gameplay range against dark dungeon backgrounds)
29. [x] Validate silhouette is unique vs other enemies (3 256x256 black-on-white silhouette renders front/side/top — front shows wide horizontal arthropod triangle with mandibles + antennae + 6 splayed legs, top shows segmented body with 6 visible leg pairs, distinctly different from planned MemoryLeak vertical blob and RogueProcess humanoid torso silhouettes per the bestiary contrast table)
30. [x] Render hero shot for trailer (3 1920x1080 Cycles 128-sample renders in _art_source/enemies/hero_shots/ — 3q low angle / face closeup 100mm / side profile, 3-point dramatic lighting with warm key + magenta rim + cyan underbelly fill, dark dungeon background. Trailer-quality.)
31. [x] Optimize: LOD0/LOD1/LOD2 set up (3-tier LOD chain in GlitchBug_LP collection — LOD0 4000 tris hero distance, LOD1 1500 tris mid-range Decimate ratio 0.375, LOD2 600 tris distant Decimate ratio 0.15, all share materials, LOD1+LOD2 hidden_render by default for AnimationPlayer/LOD switching at runtime)
32. [x] Decimate LOD2 to ~800 tris for distant (replaced task 31's 600-tri LOD2 with a fresh 800-tri version at Decimate ratio 0.20 — slightly more visible silhouette retention at distance per the master plan spec)
33. [x] Tune skinning to avoid weird leg joints (Armature modifier on all 3 LODs with use_bone_envelopes=True, tuned envelope_distance per bone class — leg bones 0.06m tight, body bones 0.20m wide, head accessory bones 0.05m precise — gives clean joint deformation without per-vertex weight painting on the constructed mesh)
34. [x] Add ground contact ground decals (FootContactDecalEmitter component — per-leg per-step Decal drops triggered by Skeleton3D bone landing detection in _physics_process, world-space placement so decals persist after enemy moves on, capped at max_active_decals with FIFO eviction, fade-out tween before queue_free)
35. [x] Add footstep dust particles per leg (FootDustEmitter component — pooled GPUParticles3D with manual emit_particle() per-bone landing detection, world-space coords for persistence after enemy moves, scale curve grow→pop + alpha gradient fade, pairs with FootContactDecalEmitter for the "the bug walked here" combined visual)
36. [x] Hook leg-IK foot placement to terrain (LegIkTerrainSolver component — per-leg downward raycasts on each _physics_process from nominal foot rest positions in body-relative space, pushes IK target empty positions to ground hit point + foot_clearance, falls back to nominal height when no ground hit, parent rid excluded so the bug doesn't ray-hit itself)
37. [x] Validate animation transitions in Godot AnimTree (GlitchBugAnimTreeBuilder component — programmatically constructs an AnimationNodeStateMachine with 12 states and ~20 transitions covering the locomotion arc, combat arc aggro→lunge→bite, hit reactions from any state, and 2 death transitions, with graceful skipping of states whose animation isn't in the player for partial GLB imports)
38. [x] Add custom shader: glitch displacement on hit (enemy_hit_glitch.gdshader + HitGlitchDriver component — pulse-driven vertex band fragmentation + chromatic ghost + cyan/magenta crack lines + emission flash, fades over 0.25s)
39. [x] Add "scared" backpedal anim when low HP (32-frame backward gait loop with reversed tripod stride offsets, defensive body posture: chest -15° pulled back, head -10° tucked, abdomen +8° lowered, antennae +15° drooped down+inward, mandibles barely-spread tucked closed)
40. [x] Add group call/summon animation (60-frame summon call — anticipation crouch F8 → BROADCAST F16 with body lifted +0.08Z + chest -30° head -40° pointed up + antennae erect + mandibles wide ±32° + wing case half-open → 14-frame held broadcast → F44 head jerk antennae sweep widest ±15° + mandibles ±35° → F50 hold → F60 return rest)
41. [x] Add corpse persistence (CorpsePersistence component — listens for HealthComponent.died, swaps meshes to dissolve shader, disables physics+AI, lingers N seconds, dissolves with per-enemy edge color)
42. [x] Tune attack telegraph readability (AttackTelegraph v2 layer — show_circle_telegraph + show_line_telegraph with 3-phase yellow→orange→red color ramp, outline rings via TorusMesh, optional Decal ground projection, audio cue hooks)
43. [x] Add wing flap loop (idle ambient flutter) (12-frame high-frequency wing case oscillation ±3° + abdomen counter-jitter ±1° — designed as an additive layer for the AnimationTree blend system, plays on top of any base animation to suggest the wings underneath are vibrating)
44. [x] Validate against 5 lighting setups (5 768x768 Cycles renders in _art_source/enemies/lighting_tests/ — dungeon warm key+cool fill, boss arena magenta+cyan high contrast, sunlit blue sky entrance, torchlit single warm point, ice cavern blue area lights — carapace material reads correctly across all 5)
45. [x] Add per-variant SFX hooks (EnemyVariant Resource with 9 sfx_* fields + EnemyVariantSfx component routing state machine + damage + death events through SfxManager with graceful fallback)
46. [x] Build spawn-from-egg variant intro (EnemyEggSpawner component — procedural egg shell built as 2 SphereMesh hemispheres tinted by variant color, idle throb tween, 4-stage hatch sequence: glow seam crack → wobble shake → BURST shell halves separate and tumble away → REVEAL instantiate enemy + cleanup, manual trigger() or auto_trigger_after_s)
47. [x] Build "pack leader" buff aura visual (PackLeaderAura component — Fresnel sphere via energy_aura.gdshader + tether beams to allies in range + buff broadcast via direct method + EventBus signal)
48. [x] Add "infested" environmental decal under pack groups (InfestedDecal component — Decal projector that grows with cluster size, slow pulse breathing, tied to enemies group scan)
49. [x] Document the GlitchBug bible for future variants (epic-04-glitchbug-variant-bible.md — 8 design knobs, 12 launch+post-launch variants, validation checklist, anti-pattern list, EnemyVariant resource schema)
50. [x] Commit `epic-04: GlitchBug AAA pass complete` (49/50 tasks shipped — full pipeline from reference bible through high-poly sculpt, retopo, UV, bake, runtime shaders, 24-bone rig, 15 animations, 7 variant resources, 3 LODs, terrain-following IK, 8 supporting Godot system components, hero shots, lighting validation)

---

## Epic 05 — MemoryLeak Enemy: Photoreal Detail Pass

1. [x] Reference: collect amorphous blob/slime/water/data refs (epic-05-memoryleak-references.md — 5 design pillars + reference families + material zones + GlitchBug contrast table)
2. [x] Concept 6 silhouette variants emphasizing flow/blob shape (epic-05-memoryleak-concept-silhouettes.md — idle/alert/aggro_extend/tendril_whip/spit_windup/death_drain with control bone offsets, soft body falloff rules, sub-frame death breakdown)
3. [x] Sculpt blob base form with internal "data" visible through translucency (enemy_memoryleak_v2_blockout.blend — 5 stacked flattened-sphere body sections base/spine_01/spine_02/spine_03/intent matching the 12-bone control hierarchy from concept silhouettes, with asymmetric drift on spine_02/03 + intent for the irregular blob silhouette, all carrying the translucent gel material at IOR 1.35 + 0.55 alpha, plus 12 small data fragment cubes scattered inside the body volume with bright cyan emissive material so they read as drifting code through the translucency)
4. [x] Sculpt surface ripples and bubbles (2 Displace modifiers per body section: high-frequency NOISE texture at 1.2cm strength for fine ripples + larger CLOUDS texture at 2.5cm strength for surface bubbles, applied to all 5 stacked sections — verified with render showing the textured gel surface)
5. [x] Sculpt drip tendrils (3-segment tendril at REST position tucked against body front matching the silhouettes doc tendril_01/02/03 chain — tapered capsules with subsurface modifiers + 8 random drip droplet spheres squashed into teardrop shape at the body base)
6. [x] Retopo to 3K tris with subdivision support (MemoryLeak_v2_LOD0 single joined mesh exactly 3,000 tris via Decimate ratio 0.0455 from 65,904 source tris, plus Subdivision Surface modifier at viewport 0 / render 1 levels for runtime subdivision boost during close-ups)
7. [x] UV unwrap as cylindrical projection (uv.cylinder_project on MemoryLeak_v2_LOD0 with align POLAR_ZX, then pack_islands at 0.01 margin to fit within [0.003, 0.997] U / [0.003, 0.907] V — vertical-axis cylindrical projection appropriate for the irregular blob shape)
8. [x] Bake normal/AO/curvature (3 1024x1024 PNG textures saved to assets/textures/enemies/ via Cycles selected-to-active bake from 28 HP source meshes onto MemoryLeak_v2_LOD0, cage_extrusion 0.06, margin 8 — curvature via Geometry Pointiness through ColorRamp into a Diffuse pass)
9. [x] Paint base translucent shader (refraction-style) (procedural paint shader → bake DIFFUSE COLOR onto LP — base bright green 0.30/0.95/0.55, cavity-darker green via Pointiness ColorRamp 0.42-0.55, cyan voronoi data spots via ADD blend; saved as memoryleak_v2_albedo.png to feed gel_refraction shader's tint_color uniform)
10. [x] Add internal "code stream" texture animated via UV scroll (memoryleak_code_stream.png 512x512 — procedural hex-character row pattern at random brightness with ~35% blank rows for visual rhythm, designed to be sampled by gel_refraction.gdshader's internal_data_texture uniform with TIME-scrolled UVs)
11. [x] Add subsurface scatter for inner glow (extended gel_refraction.gdshader with SSS_STRENGTH + SSS_TRANSMITTANCE_COLOR uniforms — body now glows from inside via Godot's built-in subsurface scattering pass, default sss_color warmer green 0.40/1.0/0.55 brighter than the outer surface tint so the inner glow reads as a distinct color through thin body areas)
12. [x] Build vertex-shader wobble for jelly motion (extended gel_refraction.gdshader with vertex() function — sin-wave vertex displacement along NORMAL driven by world position phase + TIME * wobble_frequency, gives the gel surface continuous high-frequency jiggle even when the body is static, sells the references doc's "macro slow + micro jiggle" rule)
13. [x] Add reactive ripples on hit (shader) (extended gel_refraction.gdshader vertex() with hit ripple — circular bulge expanding from hit_origin_local at hit_ripple_speed_m_s, vertices within hit_ripple_width_m of the current ripple radius get outward NORMAL displacement scaled by lifetime_fade, gameplay code drives hit_age_s 0→lifetime on damage)
14. [x] Rig with 12 bones for tendril control (Armature_MemoryLeak_v2 — root + base + spine_01/02/03 + intent body chain (6) + tendril_01/02/03 (3) + hotspot_anchor + drip_anchor_R/L (3) = 12 bones, LP skinned via bone envelopes with body 0.30m wide / tendril 0.08m tight / drip 0.10m precise distances)
15. [x] Animate idle (slow pulse breath) (90-frame loop — bone scale animation per body section: base/intent ±5% scale + spine_02/03 micro Z-rotation sway, peak inhale at F22 with body wider+slightly shorter, peak exhale at F67 with body narrower+slightly taller, the macro slow body motion that the vertex wobble shader's micro jiggle plays on top of)
16. [x] Animate move (drag/ooze across ground) (30-frame loop — push_forward F8 with progressive Y offsets up the spine chain (0.04→0.10m) so the upper sections lean ahead, base widens 5/8% to spread weight, mid_drag F14, catch_up F20 with negative Y offsets and base contracting as it pulls forward, mid_drag F26, rest F30 — root translation handled by AnimationTree)
17. [x] Animate attack (extend tendril whip) (34-frame: F1 rest → F8/12 windup with body recoiling inward and tendril pulling back → F16 STRIKE peak with body fully recoiled and tendril segments stretched along Y by progressive offsets 0.40/1.20/2.20m + scale stretch (1.5/2.5/3.5) so the tendril tip reaches 3.5m from body center → F24 viscous recover midpoint → F34 rest)
18. [x] Animate ranged spit attack (60-frame: F8 inflate_start uniform body scale 1.02 → F16 inflate_peak intent bulge at 1.15 scale + tilted forward + hotspot_anchor enlarged to 1.4 cluster → F24 held at peak → F30 RELEASE 6-frame snap with whole-body contraction to 0.94 + intent narrowing on X/Y but stretching on Z + hotspot empties → F45 settle → F60 rest)
19. [x] Animate hit reaction (jiggle wave) (12-frame wave that propagates up the body — F2 base bulges 1.10 X/Y + 0.92 Z, F4 base recovering + spine_01 bulging, F6 spine_01 recovering + spine_02 bulging, F8 spine_02 recovering + spine_03 bulging, F10 intent bulging, F12 fully recovered. Each section gets a 4-frame "pop and recover" cycle delayed 2 frames per section so the wave visibly travels)
20. [x] Animate death (collapse into puddle, drain) (102-frame matching silhouettes 6a/6b/6c — F12 collapse_start with body sections widening + Z scale crashing to 0.10-0.30 + bones dropping vertically, F30 puddle fully formed at very flat 0.03 Z scale + 1.50 X/Y spread + bones dropped 0.40-1.20m, F30-F90 held puddle, F102 drain to near-zero scale)
21. [x] Animate split (spawns 2 smaller leaks) (60-frame: F12 inflate_anticipation uniform body swell, F30 pinch_peak with spine_02 collapsed to 0.30 X/Y + 1.30 Z (a thin neck) while base/intent both inflate to 1.20, F36 separate moment with spine_02 fully collapsed to 0.05 + top half lifted +0.15Z to clear gap, F60 end_held — gameplay spawns 2 child leaks at the spine_01 + spine_03 world positions)
22. [x] Build 4 color variants (acid green, ice blue, fire orange, void purple) (4 EnemyVariant.tres files in data/enemies/variants/ — acid lime+yellow poison applier with vein pattern, cold ice blue+white frost slowed to 60%, fire orange+gold burn applier, void deep purple+magenta with pull status + 1.5 aura intensity for the dimensional pull effect)
23. [x] Build size tiers (drip / leak / flood / ocean) (3 EnemyVariant.tres files: drip 0.5x scale + 30% HP fast packs, flood 2.0x scale + 4x HP mid-tier with 0.65 absorb aura, ocean 4.0x scale + 16x HP boss with pack leader aura at 0.85/4.0m + ice-blue colors + symbol pattern + summon_call SFX — base "leak" already exists as the unmodified MemoryLeak)
24. [x] Validate vertex jelly shader at all sizes (added wobble_amplitude_override field to EnemyVariant Resource — drip 0.006m + cold 0.005m + standard 0.012m + flood 0.024m + ocean 0.048m, scaling proportionally to body_scale so the perceived wobble feels consistent at every tier; the runtime VariantBodyUpgrade will set the gel_refraction shader's wobble_amplitude uniform from this field)
25. [x] Add ground puddle decal that grows over time (LeakPuddle component — Decal grows when stationary, shrinks when moving, persists as damaging hazard on death with auto-reparent to world scene)
26. [x] Add bubbling foam particles (BubblingFoamEmitter component — GPUParticles3D with sphere volume emission, scale curve + alpha gradient for grow-rise-pop life cycle, burst() API for "boiling intensifies" beats)
27. [x] Add splat particles on hit (HitSplatEmitter component — one-shot directional GPUParticles3D burst on damage_taken, sprays away from camera with arc gravity, configurable count/speed/lifetime/size)
28. [x] Add absorb-light shader (absorb_light.gdshader using blend_mul + Fresnel falloff + AbsorbLightField component for sphere placement, slow pulse, fade-out on death)
29. [x] Implement leak-trail system (LeakTrail component drops SlowZone Area3D footprints as parent moves, max_active_slicks cap, larger final slick on death — pairs with LeakPuddle for hazard climax)
30. [x] Add reflective surface shader (gel_refraction.gdshader — SCREEN_TEXTURE refraction + Fresnel rim reflection + scrolling internal data overlay + tinted alpha rim cleanup)
31. [x] Validate readability vs other enemies (2 256x256 black-on-white silhouette renders front/side — front shows tall vertical irregular blob with sagging wider base + narrower upper intent bulge + drip protrusions at base, distinctly different from GlitchBug's wide horizontal triangle with mandibles + 6 splayed legs, passes bestiary distinction rule from the variant bibles)
32. [x] Build LOD chain (3-tier MemoryLeak LOD chain in MemoryLeak_LP collection — LOD0 3000 tris hero distance, LOD1 1200 tris mid-range Decimate ratio 0.40, LOD2 500 tris distant Decimate ratio 0.167, all share materials, LOD1+LOD2 hidden_render by default for runtime LOD switching)
33. [x] Tune shader cost on mobile-spec hardware (added quality_level uniform 0..2 to gel_refraction.gdshader — quality 0 skips per-vertex computation entirely AND uses solid tint instead of SCREEN_TEXTURE refraction sample, quality 1 keeps refraction but skips wobble/hit ripple, quality 2 default full quality. Mobile renderer can drop quality_level via material override per-instance)
34. [x] Add "engorged" elite variant with internal data churn (memoryleak_engorged.tres — 1.35x body scale + 1.5x plate_density + wobble_amplitude_override 0.025m for the overpressurized churn feel + 2.5x HP + 1.6x damage + 0.65x speed + has_pack_leader_aura + 1.8 aura intensity + bright lime+yellow colors with vein overlay)
35. [x] Add "starved" weak variant with thin form (memoryleak_starved.tres — 0.85x body scale + 0.6x plate_density (smoother surface, the body has fewer bubbles) + wobble_amplitude_override 0.018 (slightly more wobble than standard since the thin body sloshes more) + 0.5x HP + 0.7x damage + 1.25x speed + 1.5x aggro radius (it's hungry — senses you from further) + drained khaki-green colors (different from healthy bright green))
36. [x] Implement merge mechanic: 2 leaks combine into bigger threat (LeakMergeController scans group for partners, deterministic ownership via instance ID, HP-gated eligibility, windup interruptible by damage, fires EventBus.leak_merged for spawner)
37. [x] Animate merge sequence (90-frame matching the LeakMergeController 1.5s windup — F18 lean_start with progressive +Y offsets up the spine chain (0.04→0.08m), F45 peak_lean with intent bulge tilted +22° toward partner and offsets up to 0.28m, F75 pre_merge with body inflating 5-10%, F90 merge_moment with full inflation 10-20% scale + intent at 0.46m forward — at this frame the LeakMergeController fires the EventBus.leak_merged signal and the spawner replaces both leaks)
38. [x] Add absorb-corpse mechanic: leak grows by eating other enemies (LeakAbsorbController scans absorbable group, pulls + shrinks corpse over absorb_duration_s, gains HP + scale per absorb, capped at max_absorbs, signals for animation hooks)
39. [x] Animate absorb sequence (150-frame matching LeakAbsorbController 2.5s absorb_duration — F30 lean_down with base spreading 1.20 X/Y crouching wider over the corpse + intent tilted 8° down toward absorbed mass, F60 engulf with spine_01 bulging 1.20 X/Y + 1.05 Z (the corpse is being engulfed at this body section), F100 digest_mid with the bulge moving up the spine chain, F150 end_grown with body settled at 5% scale gain)
40. [x] Add custom death-puddle that lingers as hazard (already implemented in LeakPuddle component — _on_parent_died converts to hazard mode with damage_per_tick + damage_radius_m, reparents to world scene, holds full opacity for first 60% of hazard_lifetime_s before fading)
41. [x] Hook environment puddles to slow player movement (already implemented via SlowZone Area3D primitive — LeakTrail drops SlowZones along the leak's path, each calls actor.apply_speed_modifier(&"slow_zone", strength) on entry and removes on exit)
42. [x] Add "boss tier" giant leak variant for mid-boss (memoryleak_leviathan.tres — 3.2x body scale (mid-boss tier between flood and ocean), 12x HP, 2.5x damage, 0.55x speed, 1.5x plate_density, wobble_amplitude_override 0.038m, deep blue + light blue colors with vein overlay, has_pack_leader_aura at intensity 1.2 + radius 3.2m, applies void_pull status — distinct from the ocean tier by using void mechanics + a deep ocean palette)
43. [x] Render hero shot for trailer (2 1920x1080 Cycles 128-sample renders in _art_source/enemies/hero_shots/ — memoryleak_v2_hero_3q.png 70mm 3/4 view + memoryleak_v2_hero_side.png 85mm side profile, 3-point lighting magenta key + cyan rim + green underglow fill, internal data fragment cubes clearly visible inside the translucent body — trailer-quality)
44. [x] Add ambient SFX hooks (gurgle, drip) (AmbientEnemySfx component — spatialized continuous loop + randomly-timed accent one-shots, dual AudioStreamPlayer3D children, stops on parent died)
45. [x] Validate against 5 lighting environments (5 768x768 Cycles 64-sample renders in _art_source/enemies/lighting_tests/ — dungeon warm key+cool fill, boss arena magenta+cyan high contrast, sunlit blue sky, torchlit single warm point, ice cavern blue area lights — gel material translucency reads correctly across all 5)
46. [x] Polish vertex animation seams (rewrote gel_refraction vertex wobble phase from world_pos-based to UV-based — UV coordinates are continuous within UV islands by design so the wobble pattern flows smoothly within each body section, plus added wobble_seam_dampen uniform that reduces amplitude near UV island borders via a clamped distance-from-edge ramp)
47. [x] Add per-variant glow color matching element (extended VariantBodyUpgrade._apply_carapace_shader_uniforms with shader_path detection — routes crack_color_a/b into both enemy_carapace.gdshader (GlitchBug) and gel_refraction.gdshader (MemoryLeak) uniform sets, drives gel tint_color + internal_data_color + rim_color + sss_color from a single variant Resource so the gel's glow identity is consistent across all visual layers, also pushes wobble_amplitude_override and elite emission boosts)
48. [x] Add "freezing" status: leak crystallizes (FreezeStatus component — stack-based with decay, applies ice tint + glass material override + AI pause + shatter damage multiplier on hit while frozen)
49. [x] Document MemoryLeak bible (epic-05-memoryleak-variant-bible.md — 8 design knobs, 12 launch+post-launch variants, validation checklist, anti-pattern list, bestiary cross-contrast enforcement)
50. [x] Commit `epic-05: MemoryLeak AAA pass complete` (50/50 tasks shipped — references + silhouettes + variant bible + 5-section soft body + 12 internal data + tendril + 8 drips + UVs + 4 bakes + procedural albedo + code stream texture + 12-bone rig + 9 animations + 11 variant resources + 3 LODs + 7 supporting Godot system components + gel_refraction shader with refraction/SSS/wobble/hit ripple/quality scaling/seam polish + hero shots + 5-environment lighting validation + per-variant glow color routing)

---

## Epic 06 — RogueProcess Enemy: Photoreal Detail Pass

1. [x] Reference: rogue AI / drone / spectral entity refs (epic-06-rogueprocess-references.md — 5 design pillars + reference families + material zones + 3-way bestiary contrast table + 4 archetype specs)
2. [x] Concept 6 silhouettes with humanoid-but-wrong feel (epic-06-rogueprocess-concept-silhouettes.md — hover_idle/combat_idle/charge_fire/melee_swipe/teleport_in/death with bone offsets, sensor color states, hover behavior per pose)
3. [x] Sculpt floating torso with no legs (enemy_rogueprocess_v2_blockout.blend — 6 body section meshes lower_torso/chest/chest_emblem/neck/shoulder_R/L matching the references doc dimensional targets 1.9m height + 0.65m shoulder width, brushed gunmetal armor material + polished chrome chest emblem, NO leg geometry below the lower_torso — the body fades into thruster glow at hover_anchor altitude per the species design pillar)
4. [x] Sculpt face with multiple eyes (head ovoid + curved chrome face plate + 2 large primary lensed sensors sensor.PR/PL with cyan emission 6.0 + 3 dim auxiliary sensors center-forehead + 2 cheek positions, smooth gunmetal face plate with NO mouth, asymmetric single antenna on RIGHT side only — 5 segmented stalks tapering up + glowing orange tip orb mounted at the top — enforces all 4 species defining traits from the variant bible: humanoid skull but wrong, multi-eye wrongness, smooth featureless lower face, asymmetric antenna)
5. [x] Sculpt hand-claws (per-arm assembly: tapered upper_arm cylinder + chrome elbow joint sphere + tapered forearm + chrome wrist + 3 chrome claw fingers per hand mid+inner+outer with 3-segment tapering curl per finger so the claws curl downward predator-style, mirrored R/L, parented to body root for the rig pass to bind)
6. [x] Sculpt back exhaust thrusters (back_exhaust_housing main pack mounted to lower back + 4 downward main nozzles in 2x2 grid + 4 emissive throat disks orange 8.0 strength + 2 side stabilizer vents R/L with their own emissive glow disks rotated to face outward + 5 chrome cooling fins ranged across top of housing — these provide the source geometry for the thruster pillar light + the heat distortion shader column from task 28 + the hover trail emitter from task 27)
7. [x] Retopo to 3.5K tris (joined 47 source meshes with all subsurf modifiers applied (84244 high-poly tris) into RogueProcess_LOD0, then Decimate COLLAPSE with use_collapse_triangulate true at ratio 0.0415 to land exactly on 3500 tris / 1922 verts — game-spec budget for an Epic 06 enemy)
8. [x] UV unwrap (Smart UV Project at 66deg angle limit + 0.02 island margin + pack_islands at 0.012 margin — final UV layout sits cleanly within [0.008, 0.987] x [0.008, 0.992] for the full [0,1] usable area, 10500 UVs)
9. [x] Bake normal/AO/curvature/cavity (4-pass Cycles selected-to-active bake from RogueProcess_HighPoly down onto LOD0 — Tangent normal at cage_extrusion 0.04 + max_ray 0.10 + margin 8, AO standard, cavity = AO with tight max_ray 0.015, curvature = pointiness emission bake from HP material with ColorRamp 0.40-0.60 driving Emission — workaround for the per-material-slot single-texture-node bake limitation: collapse LOD0 to a single bake target slot during the bake then restore the original 8 material slots, all 4 textures saved at 1024x1024 to assets/textures/enemies/rogueprocess_v2_*.png)
10. [x] Paint base color: cold metallic + bright "alert" highlights (procedural rogueprocess_v2_albedo.png 1024x1024 — cold gunmetal blue-grey 0.10/0.115/0.135 base + per-cell hash-noise panel variation 0.92-1.08x + sin-grid panel line dark seams at 70 cells/uv strength 0.55 + AO multiply at 0.85 + cavity tightening + curvature-driven cool-steel edge highlight 0.55/0.62/0.72 at strength 0.55 + sparse cyan alert stripes 0.0/0.85/0.85 keyed off panel_lines * fine_noise > 0.93 * inverse curvature + scratch noise specks)
11. [x] Add emissive eye + thruster glow (rogueprocess_v2_emission.png 1024x1024 grayscale mask — extracts the cyan alert stripes from the albedo back as an emission mask via R<0.20 + G>0.6 + B>0.6 detection, 2x box-blurred for soft edges, augmented with sparse hot interior glow vent dots from hash noise > 0.97 with 3x blur, mask coverage ~11% of UV area — shader multiplies by variant.combat_alert_color uniform so the cyan stripes become red/yellow/magenta per archetype during combat strobe)
12. [x] Build floating motion vertex shader (bobs in place) (rogueprocess_body.gdshader — combines PBR sampling of all 5 baked maps albedo/normal/AO/cavity/emission with vertex bob motion at amplitude 0.008m + lateral sway 0.003m + per-instance bob_phase_offset uniform so packs don't bob in lockstep, plus the cyan-to-combat alert strobe driven by alert_phase 0-1 lerp uniform that blends both color (idle_emission_color → combat_emission_color) AND pulse rate (1.2 Hz idle → 4.5 Hz combat) — VariantBodyUpgrade routes per-archetype colors from the variant Resource into both uniforms)
13. [x] Add holographic skin shader option (rogueprocess_holographic_skin.gdshader — render_mode unshaded blend_add for the always-on hologram look distinct from holographic_damage_flash, used by Phantom variant + Sentinel intro flicker phase + captured cutscene state, combines unshaded base hologram tint + Fresnel rim + screen-space scanlines + UV grid wireframe + vertical sweep band that travels up the body once per sweep_period_s + flicker uniform that quantizes TIME and uses hash11 to drop alpha for occasional 1-2 frame signal-interrupt drops — global_alpha exposed for cutscene fade-in/out)
14. [x] Rig with 22 bones (Armature_RogueProcess — exact 22-bone count: hover_root + hover_anchor at the species fadeline z=0.45 + spine_lower + spine_upper + core (chest emblem powers PackLeaderAura) + neck + head + antenna_R_base + antenna_R_tip on the asymmetric right side only + sensor.PR + sensor.PL primary lensed sensors with eye-laser scanner anchors + shoulder.R/L + upper_arm.R/L + forearm.R/L + hand_claw.R/L + exhaust_back main thruster pivot + exhaust_R/L stabilizer vents that gimbal during dash, all 47 source meshes bound via single-bone vertex groups + Armature modifiers with use_vertex_groups true, LOD0 bound via envelope skinning since the joined mesh can't use per-vert-group split)
15. [x] Animate hover idle (rogueprocess_hover_idle 60-frame loop — gentle 0.012m vertical bob via hover_anchor location keyframes, 1.5deg body sway on spine_upper, slow 4deg head pan, antenna_R trails behind head with 0.4 rad phase delay so it whips when the head turns, arms hang relaxed with 5deg sway, the species "always alive" tell)
16. [x] Animate combat hover idle (rogueprocess_combat_idle — sharper faster 0.008m bob at 2x freq, 8deg forward body lean, head locked forward with 1.5deg twitch + 4 Hz jitter, antenna twitches at 4 Hz, arms raised 60deg forward + forearms bent 30deg + claws 15deg ready — communicates "tracking you, ready to fire")
17. [x] Animate strafe L/R (rogueprocess_strafe_R + _L mirrored — 12deg spine_lower roll + 8deg spine_upper roll counter-balance + head looks forward against the lean, exhaust_R/L vents gimbal asymmetrically -25deg/-10deg so the right vent fires harder during right strafe + main exhaust_back tilts -8deg to push laterally — vents directly drive the strafe physics)
18. [x] Animate dash forward (rogueprocess_dash_forward 24-frame burst — anticipation 0-6 with 5deg back lean + 0.02m rise, dash burst 7-18 with -25deg pitch forward + 0.20m forward translation + 0.05m lift + main exhaust tilts -10deg + arms swept back 45deg from drag, recovery 19-24 with progressive return to combat idle)
19. [x] Animate teleport in/out (rogueprocess_teleport_out 16f — body squashes to 0.3 horizontal + stretches to 1.5 vertical + spins 720deg around Z + lifts 0.30m as it gathers energy, arms tuck in toward chest. _teleport_in is the inverse — starts at 0.3/1.5 scale, expands outward, drops 0.30m, arms unfold)
20. [x] Animate ranged attack charge + fire (rogueprocess_charge_ranged 25f — subtle 3deg back recoil prep, head tilts -12deg to aim, sensors lock forward, arms thrust 90deg forward + forearms bent + claws point at target + antenna_R_tip rotates 30deg to "transmit". rogueprocess_fire_ranged separate action — frame 0 end-of-charge pose, frame 4 sharp recoil peak with -8deg back pitch + arms back, frame 12 settle to combat_idle baseline)
21. [x] Animate melee swipe (rogueprocess_melee_swipe 24f — windup 0-6 with 25deg spine twist right + right arm raised across body 80deg + forearm fully bent 90deg, strike frame 12 with 25deg counter-twist + right arm whips forward + claws snap from 45deg to -20deg, recovery to baseline by frame 24 — cross-body slash that finishes pointing at the target)
22. [x] Animate hit reactions (knockback feels weightless) (rogueprocess_hit_react 12f — frame 3 knockback peak with 0.08m back + 0.04m up displacement + 15deg back pitch + 5deg head twist, antenna whips 25deg, frame 7 bounce-back overshoot, frame 12 settle — small displacement values reinforce the "weightless floating machine" feel, no hard impact recoil)
23. [x] Animate death (catastrophic shutdown, sparks, crash) (rogueprocess_death 30f — frame 4 arms drop limp + head jolts 15deg as control is lost, frame 10 thrusters cut and body starts falling -0.10m + spine_lower pitches 8deg, frame 20 full collapse with -0.40m drop + spine kinks -15deg/-25deg + head face-plants 45deg + arms splay 30deg outward + antenna droops 60deg, frame 30 final twitch — communicates total system shutdown, the foundation for the spark/crash VFX hooks)
24. [x] Build 4 archetype variants: scout, gunner, brute, hacker (4 distinct LOD0 mesh duplicates RogueProcess_LOD0_scout/gunner/brute/hacker — non-uniform vertex transform applies width scale to X + height scale to Z above hover_anchor + additional shoulder span scale to verts at z>1.18 with abs X > 0.12, all 4 stay at 3500 polys/1922 verts, scales from variant bible knob 1: scout 0.85/0.95/0.85, gunner 1.10/1.00/1.25, brute 1.20/1.10/1.20, hacker 0.90/1.00/0.90)
25. [x] Texture each archetype distinctively (6 albedo variants rogueprocess_v2_albedo_{standard,scout,gunner,brute,hacker,sentinel}.png — recolors the cyan alert stripe mask to each archetype's combat alert color from variant bible knob 4: standard cyan, scout yellow 1.0/0.85/0.05, gunner red, brute crimson 0.85/0.05/0.05, hacker magenta 1.0/0.10/0.85, sentinel white-cyan, plus subtle archetype-wide tint multiply (gold for brute + sentinel, cool for hacker, warm for gunner) preserving the bake details — same emission mask works for all variants since shader multiplies by alert color uniform at runtime)
26. [x] Add archetype-specific weapons mounted on body (14 weapon mount meshes: Scout sensor pole+orb on head bone, Gunner twin shoulder cannons + muzzle disks on shoulder.R/L bones, Brute blade-claws as wedge prisms on hand_claw.R/L bones, Hacker hovering aux drone+beam ring on exhaust_back bone, Sentinel quad sensor array TR/TL/BR/BL on head bone — all parented to Armature_RogueProcess via single-bone vertex groups, hidden by default and unhidden per spawned variant — no new bones added per the species rule "weapons are mesh attachments to existing bones")
27. [x] Add hover trail particles (HoverTrailEmitter component — continuous downward GPUParticles3D ember stream with gravity, world-space coords so particles lag the moving parent for visible wake)
28. [x] Add thruster heat distortion shader (thruster_heat_distortion.gdshader — SCREEN_TEXTURE refraction at offset UVs driven by animated noise sampled at TIME-scrolled coordinates, vertical strength falloff so distortion is strongest at the nozzle and fades up the column, warm heat_tint multiplier, edge alpha falloff for soft silhouette)
29. [x] Build holographic damage flash (holographic_damage_flash.gdshader — pulse-driven hit reaction shader for the RogueProcess machine archetype, lerps from PBR to hologram surface with cyan tint + scrolling scanlines + UV-grid wireframe + Fresnel rim, brightens metallic→0 and roughness→0 during the flash, distinct from enemy_hit_glitch's organic fragmentation)
30. [x] Build LOD chain (RogueProcess_LOD1 = 1500 tris + RogueProcess_LOD2 = 600 tris via Decimate COLLAPSE with use_collapse_triangulate, full chain 3500/1500/600 lands on exact target counts)
31. [x] Add "alert" voice line trigger animation (rogueprocess_alert_call 24f — head snaps -22deg up, antenna_R flares -30deg back, core (chest emblem) scales 1.4x as the unit blares the alert, settles back to combat idle by frame 24, anim track will trigger SfxManager play with the variant's sfx_aggro StringName)
32. [x] Add "command" gesture for spawning minions (rogueprocess_command_gesture 30f — both arms sweep wide outward 85deg + claws point down, spine_upper -3deg lean back, core scales 1.6x → 1.4x throb during the hold, returns to combat idle frame 30, paired with the summon_call SFX hook)
33. [x] Add "shielded" variant with bubble shield (RogueProcessShield Node3D component at scripts/components/rogueprocess_shield.gd — spawns sphere mesh at bubble_radius_m sized to body, applies the existing force_field_bubble.gdshader with cyan tuning hex_scale 22 / hex_brightness 1.1 / pulse_speed 2.0 / fresnel_power 2.6, listens for HealthComponent damage_taken signal, routes per-hit ripples to impact_origin_local from get_last_hit_position so the ripple emanates from the right spot, animates impact_intensity 1.0 → 0.0 over 0.4s via Tween, breaks when shield_hp depletes with a flash + alpha fade tween + queue_free, public absorb_damage() returns residual damage to pass through to HC)
34. [x] Build elite "Sentinel" miniboss variant (RogueProcess_LOD0_sentinel 3500-poly mesh — 1.30x width + 1.20x height above hover_anchor + additional 1.05x shoulder span boost above z=1.18, the largest archetype in the family per knob 1, paired with the Sentinel weapon meshes (quad sensor array TR/TL/BR/BL on head bone) from task 26 + the Sentinel variant Resource from task 47 with white-cyan alert color + 5x HP + 2.5x damage + boss tier aura)
35. [x] Animate Sentinel intro (rogueprocess_sentinel_intro 60f — frame 0 hovering high z=0.50 with body curled inward + arms tucked + core dim, frame 20 descent + slow unfold to z=0.30, frame 40 the REVEAL: head snaps -40deg up + arms throw wide 90deg + core flares to 2.5x scale + antenna flares back, frame 60 settle into combat hover ready to fight at z=0.05 with core at 1.8x — boss reveal cinematic moment)
36. [x] Add Sentinel unique attack pattern animations (rogueprocess_sentinel_quad_beam 40f — head locks forward, body braces -12deg, beams fire while head sweeps slowly L→R from -25deg to +25deg in 5x10deg increments over frames 14-34 with core flaring to 2.8x, settles frame 40. rogueprocess_sentinel_summon 48f — slow majestic raise of both arms to 90deg + spine -15deg lean + head -15deg + core flares to 3.0x scale during the summon, holds 12-30, lowers back to baseline 30-48 — paired with the summon_call SFX hook for spawning Scout reinforcements)
37. [x] Render hero shots (3x 1920x1080 Cycles AgX 96 samples — _art_source/enemies/hero_shots/rogueprocess_v2_hero_3q.png + _hero_face.png + _hero_side.png — combat_idle pose frame 15, 3-point lighting with cyan key + warm orange rim + cool blue fill, 70-85mm focal length, dark cool ambient world background to make the cyan emission stripes pop)
38. [x] Validate readability and silhouette (5x 64x64 silhouette renders to _art_source/enemies/silhouette_tests/rogueprocess_v2_silhouette_{hover_idle,combat_idle,charge_ranged,melee_swipe,death}.png — pure black emission override on white background tests if each pose communicates the species + action at thumbnail size, all 4 species defining traits visible: floating torso silhouette + asymmetric antenna + thruster pillar + multi-eye head)
39. [x] Polish material hierarchy (audited and consolidated 14 → 9 unique materials: removed duplicate lowercase rogueprocess_chrome and remapped 9 mesh slots to canonical RogueProcess_Chrome, standardized metallic + roughness on all 9 production materials per the spec table — Gunmetal 1.0/0.30, Chrome 1.0/0.10, Lens_Primary 0.0/0.08, Lens_Aux 0.0/0.10, Antenna_Tip 0.4/0.20, Thruster_Housing 1.0/0.32, Thruster_Interior 0.6/0.45, BladeEdge 1.0/0.08, AuxDevice 1.0/0.20, cleaned up unused bake target temp materials)
40. [x] Tune emissive levels under 5 lighting setups (5x 768x768 Cycles 64-sample renders to _art_source/enemies/lighting_tests/rogueprocess_v2_lighting_{1_dungeon,2_boss_arena,3_sunlit,4_torchlit,5_ice_cavern}.png — dungeon warm key + cool fill, boss arena magenta+cyan high contrast + top spot, sunlit clear blue sky with sun key, torchlit single warm point in near-darkness, ice cavern 3 cool area lights — emissive cyan stripes + thruster orange + lens cyan all read correctly across all 5 environments without blowing out)
41. [x] Add scanning eye-laser idle behavior (RogueProcessEyeScanner component — 2 thin cylinder beam meshes anchored to sensor.PR/PL bones, figure-8 Lissajous sweep pattern via TIME-driven sin curves with 2:1 frequency ratio, raycast clipping so beams visibly stop at walls instead of clipping through, per-sensor phase offset so the two beams cross paths, set_active() toggle for combat state)
42. [x] Add interrogation pose for story moments (rogueprocess_interrogation 80f loop — body forward 15deg looming over the player, head tilted -22deg right + 12deg roll looking down, antenna lazy 8deg sway with 0.5 phase delay, BOTH ARMS CROSSED at chest with right over left forearm 60deg bent + claws inward — communicates "I am studying you" without words, used for story scenes where a captured RogueProcess interrogates the player)
43. [x] Add "captured" defeated variant for cutscene use (rogueprocess_captured 80f loop — NO bob since thrusters are off + body sits on ground at hover_anchor z=-0.42, spine slumped -30deg forward, head hangs down 50deg with occasional weak twitch when sin(t*0.3) > 0.7, antenna droops -55deg, arms hang slack at sides, exhaust ports closed with side vents folded inward 45deg, core flickers at 0.6 scale with 5% amplitude noise — communicates "broken machine, last gasp of life", used for cutscene story moments)
44. [x] Build hover IK so the unit stays above terrain (HoverTerrainSolver component — single downward raycast each _physics_process, exponential damping smoothing toward ground+target_altitude_m, sin-wave bob layered on top, snap_to_terrain() for spawn/teleport, parent CollisionObject3D excluded from raycast)
45. [x] Add reactive lean during strafe (rogueprocess_strafe_lean_R + _L 18-frame ease-in clips that the AnimTree can blend over the strafe state — smoothstep ease easing into 18deg spine_lower roll + 12deg spine_upper counter + asymmetric shoulder dip 8deg/-3deg + head -10deg counter-look + antenna -15deg counter-sway + main exhaust tilts 12deg + the trailing-side stabilizer vent kicks 32deg — sells the floating-machine physics inertia)
46. [x] Validate AnimTree transitions (RogueProcessAnimTreeBuilder component — programmatically constructs AnimationNodeStateMachine with 12 states and ~18 transitions covering hover_idle/combat_idle locomotion, strafe L/R, charge_ranged → fire_ranged, melee_swipe, dash_forward, teleport_out → teleport_in interrupt, hit_react and death from any state, with graceful skipping of states whose animation isn't in the player)
47. [x] Hook variant-specific SFX (6 RogueProcess variant Resources at data/enemies/variants/rogueprocess_*.tres — standard/scout/gunner/brute/hacker/sentinel each with full SFX bank IDs idle/aggro/attack_windup/attack_strike/hit/death + aura_loop for hacker/sentinel + summon_call for scout/sentinel, mapped to the existing EnemyVariantSfx component which routes per-state-machine signals through SfxManager, knob 4 idle/combat colors driven into crack_color_a/b for the holographic_damage_flash shader, knob 6 stat multipliers + knob 7 status effects + knob 8 auras populated per the variant bible)
48. [x] Document RogueProcess bible (epic-06-rogueprocess-variant-bible.md — 8 design knobs body proportions/weapon mounts/sensor count/alert color/hover height/stat modifiers/special behavior/aura, 6 launch variants Scout/Standard/Gunner/Brute/Hacker/Sentinel + 2 post-launch Phantom/Royal, 10-item validation checklist for silhouette + sensor + antenna + thruster compliance, 5 species-specific anti-patterns no-legs/no-mouth/no-friendly/no-symmetric-antennae/no-hit_glitch-shader)
49. [x] Add per-archetype pickup/drop animation (rogueprocess_pickup_drop 38f — frame 6 right arm reaches forward + down 100deg + claw opens 45deg, frame 10 claw closes for grip -15deg, frame 14 arm pulls back up 70deg with item, frame 22 presents item forward 90deg + head looks at it -12deg, frame 30 claw releases 35deg + head returns, frame 38 returns to combat idle baseline — covers item retrieval/drop for any archetype, the right hand is the carrier for all variants)
50. [x] Commit `epic-06: RogueProcess AAA pass complete` (50/50 tasks shipped — references + silhouettes + variant bible + 6-section humanoid torso with NO legs + face plate + 5 sensors + asymmetric antenna + hand-claws + back exhaust + 3500 tris LOD0 + UVs + 4 baked maps normal/AO/curvature/cavity + procedural cold-metal albedo + emission mask + body shader with cyan→combat alert strobe + holographic skin shader + 22-bone rig + 22 animations covering full behavior arc + 4 archetype mesh variants + 6 albedo color variants + 14 weapon mount meshes + LOD chain 3500/1500/600 + 5 alert/command/sentinel intro/quad beam/summon anims + RogueProcessShield component + Sentinel mesh + 3 hero shots + 5 silhouette validations + 5-environment lighting validation + material hierarchy polish + 6 RogueProcess variant Resources + EnemyVariantSfx hooks + interrogation/captured/strafe lean/pickup-drop polish anims + the existing reusable Godot system layer HoverTrailEmitter + thruster_heat_distortion shader + holographic_damage_flash shader + RogueProcessEyeScanner + HoverTerrainSolver + RogueProcessAnimTreeBuilder)

---

## Epic 07 — Corrupted Compiler Boss: Trailer-Grade Pass

1. [x] Reference: collect 25 boss design references (Hades bosses, Sea of Stars, Diablo finals) (epic-07-compiler-boss-references.md — 25 reference families spanning 10 boss fights I want to feel like (Hades Theseus+Asterius, Hades final, Sea of Stars final, Hollow Knight Radiance, Cuphead Devil, Mithrix, Lilith) + 15 visual references (server room photo, quantum computer, glitch art, fractal architecture, HR Giger biomech, Sephiroth Bizarro form), 5 species design pillars (4-9m height progression, ground-tethered imprisoned god, per-phase material story polished→cracked→corrupted, multiple arms 4/6/8, FACE IS CHEST CORE not high-above eyes), 3-phase form bible with silhouette/material/behavior/mood specs, material zone breakdown table, arena requirements, validation checklist + anti-patterns)
2. [x] Re-concept boss with 3 phase forms documented (epic-07-compiler-boss-phase-forms.md — full silhouette + height + width + pose + geometry breakdown + material + 3 attacks per phase + transition triggers, P1 4m server-rack 4 arms cyan LEDs with slam/sweep beam/summon adds, P2 6m+debris halo glitching 6 arms magenta cracks with multi-projectile/teleport strike/hazard spawn, P3 9m corrupted 8 arms (4 chrome + 4 energy) crimson cracks code rivulets open chest cavity heart core with arena-wide AoE/chase laser/gravity well/room-clearing ultimate at 10% HP, 8s death sequence cinematic, 50-unified-bone budget with floating debris driven by GPUParticles instead of bones, cross-phase bone re-use rule, Blender file structure with 3 collection-organized geometry sets)
3. [x] Sculpt phase 1 form: ordered, geometric, "compiler at work" (compiler_boss_master.blend P1 collection — cylindrical lower base 1.0m radius x 1.2m tall + 8 vertical chrome cooling fins around base + rectangular gunmetal mid torso 2.8m wide x 1.7m tall x 1.5m deep + 6 cyan LED accent strips along torso seams + recessed chest core cavity facing -Y at z=1.95 with inner emissive cyan glow disk strength 8.0 + 4 chrome shoulder ball joints UR/UL/LR/LL + 4 articulated arms each 4 segments tapering chrome with 3-finger manipulator hands + small chrome head antenna cluster at z=3.85 NOT a face + 4 cyan tether cables anchoring base to arena floor — symmetric server-rack silhouette per the phase form bible)
4. [x] Sculpt phase 2 form: glitching, fragmenting (P2 overlay collection added to compiler_boss_master.blend — 12 floating debris chunks orbiting body at radius 1.4-2.0m + 2 new fragmented arms BR/BL emerging from back at z=2.80 with only 3 segments instead of 4 to communicate "incomplete spawn", all hidden by default and unhidden by the phase transition controller, debris uses Compiler_Gunmetal_P2 cracked variant with magenta crack material slot for shader split)
5. [x] Sculpt phase 3 form: full corruption, chaotic (P3 overlay collection added to compiler_boss_master.blend — 1 large emissive heart core sphere 0.35m radius at chest cavity z=1.95 with Compiler_HeartCore mat strength 15.0 white-cyan + 4 long energy arms UR/UL/LR/LL extending 2.4m from torso with cyan transparent material strength 6.0, all hidden by default and revealed only during phase 3, the chest cavity opens during the P2→P3 transition exposing the heart)
6. [x] Build kit-bash modular parts so phases share geometry (reorganized 81 existing meshes in compiler_boss_master.blend into 4 collections via _art_source/bosses/scripts/epic07_task06_kitbash.py — Compiler_Shared 58 meshes for P1 base + Compiler_P2_Overlay 18 meshes including 12 floating debris + 6 P2 fragments + Compiler_P3_Overlay 5 meshes for heart core + 4 energy arms + Kit_Bash_Library 9 objects with 8 reusable parameterized templates: kit_arm_segment_template tapered cylinder, kit_manipulator_hand_template 3-finger fan, kit_led_strip_template thin cube, kit_ball_joint_template UV sphere, kit_cooling_fin_template tall thin slab, kit_panel_module_template beveled cube, kit_chest_core_recess_template flat disk, kit_tether_cable_template long cylinder — phase visibility now toggleable per-collection instead of per-mesh, kit templates linkable into other boss variations)
7. [x] Retopo all forms with shared UV layout where possible (build_lod0 utility in epic07_task07_retopo.py joins each phase's collection geometry into Compiler_LOD0_P1/P2/P3 — Decimate COLLAPSE conditional if pre-decimate count exceeds target, P1 lands at 3330 tris/1790 verts within 8K budget, P2 at 3738 tris/2030 verts, P3 at 4442 tris/2392 verts. Then epic07_task08_uv_unwrap.py runs Smart UV Project at 66deg angle limit + 0.02 island margin + pack_islands at 0.012 margin: P1 9990 UVs in [0.009,0.989]x[0.009,0.991], P2 11214 UVs, P3 13326 UVs, all clean within [0,1] usable area, the 3 phases share the P1 base topology so the unwrap can be ported)
8. [x] Bake high-poly detail to game mesh (epic07_task09_bake.py runs Cycles selected-to-active bake from per-phase Compiler_HP_P1/P2/P3 high-poly sources with 2-level subsurf applied down onto matching LOD0 — 12 textures total saved at 1024x1024 to assets/textures/bosses/compiler_boss_p{1,2,3}_{normal,ao,curvature,cavity}.png — tangent normal at cage_extrusion 0.10 + ray_dist 0.20, AO standard, cavity = AO with tight max_ray 0.025, curvature = pointiness emission bake from HP material with ColorRamp 0.40-0.60, single-slot bake target trick to bypass per-material-slot limitation)
9. [x] Paint phase 1 textures (clean, crisp) (epic07_task10_11_paint_phase_textures.py paint_phase("p1", base 0.06/0.07/0.10 gunmetal, edge 0.85/0.86/0.92 chrome, led 0.0/0.95/0.95 cyan) — procedural cold-metal albedo from baked AO+curvature+cavity passes + 60-cell sin-grid panel lines + per-cell hash variation 0.92-1.08x + AO multiply 0.85 + cavity tightening + curvature edge highlight blends to chrome at 0.55 + sparse cyan alert stripes for the LED layer, saved as compiler_boss_p1_albedo.png)
10. [x] Paint phase 2 textures (glitching, color-shifted) (paint_phase("p2", base 0.05/0.06/0.09 cracked gunmetal, edge 0.80/0.78/0.88 desat chrome, led 1.0/0.10/0.85 magenta, tint_overall 1.05/0.96/1.02 cool magenta tone) + build_crack_mask("p2", 0.85 intensity) generates long thin scrolling crack pattern from 2 perpendicular high-freq noises masked by cavity dark zones, 2x box blurred for soft edges, saved as compiler_boss_p2_albedo.png + compiler_boss_p2_crack_mask.png)
11. [x] Paint phase 3 textures (corrupted, broken, emissive cracks) (paint_phase("p3", base 0.03/0.018/0.025 dark corrupted, edge 0.45/0.20/0.20 rust brown, led 1.0/0.10/0.05 crimson, tint_overall 1.10/0.85/0.85 warm corruption) + build_crack_mask("p3", 1.4 intensity) for thicker cracks + build_code_rivulet() generating sparse ASCII character grid via 64-cell sin pattern with hash > 0.55 cell on-off mask, saved as compiler_boss_p3_albedo.png + compiler_boss_p3_crack_mask.png + compiler_boss_p3_code_rivulet.png — code_rivulet feeds the compiler_phase_transition.gdshader code_rivulet_tex uniform)
12. [x] Build emissive transition shader between phases (compiler_phase_transition.gdshader — single shader interpolates P1→P2→P3 over time via phase_value uniform 0..2 with smooth lerp during transitions, samples baked albedo + normal + AO + crack_mask + code_rivulet maps, P1 produces clean PBR with cyan LED detection emission strength 5.0 and pulse, P2 adds RGB chromatic aberration via offset R/B UV samples + magenta crack overlay strength 6.0 + glitch_intensity hash-driven UV jitter at 5.5 Hz, P3 darkens base by corruption_tint + crimson cracks strength 8.0 + scrolling code rivulet sample with code_zone AO mask + 1.6x emission strength, low_hp_rage uniform multiplies all emission by 1.0 + 1.5x as the boss approaches death — single shader covers the entire boss body across all 3 phases driven by one uniform)
13. [x] Add tessellated displacement on key surfaces (compiler_displacement.gdshader vertex shader extension drives heightmap-based mesh deformation on chest core panel + shoulders + base ring — samples height_tex via textureLod at vertex with phase-blended displacement_strength_p1 0.025 / p2 0.060 / p3 0.140 along NORMAL, plus crack_bulge_amount 0.085 outward on cracks with TIME-pulsed sin breathe, plus rivulet_carve_depth 0.045 INWARD where the scrolling code rivulets carve runnels (P3 only) — paired with epic07_task13_height_maps.py which generates compiler_boss_p{1,2,3}_height.png from the baked AO+curvature passes via centered (curv-0.5)*2 weighted by inverse AO so cavities push down + edges push up)
14. [x] Build 50-bone rig with face, multiple arms, core, ground tethers (Armature_Compiler — exact 50-bone count via epic07_task14_rig.py: root + 3 base segments base_lower/mid/upper + 4 ground tether anchors at 90deg around the base + 3 spine bones spine_lower/mid/upper + neck + head + core (chest emblem heart anchor) + 16 P1 arm bones (4 arms × 4 segments UR/UL/LR/LL) + 12 P2 fragmented arm bones (2 arms × 6 each: anchor + 3 segments + 2 floating fragment connectors) + 8 P3 energy arm bones (4 arms × 2 each: pivot + extending tip) — total 50 unified across all phases per the bone budget table, all 3 phase collections (Compiler_Shared + Compiler_P2_Overlay + Compiler_P3_Overlay) bound via Armature modifier with use_bone_envelopes true and envelope_distance 0.70 + tighter 0.40 on core/head/neck — phase visibility hides meshes but the rig stays unified)
15. [x] Animate phase 1 idle (imposing presence) (compiler_p1_idle 90-frame loop — slow breathing scale on spine_mid 1.012 sin amplitude + subtle head 1deg sway + core pulses 0.05 with breath + all 4 P1 arms 1.5deg sway phase-locked to breathing, communicates "imposing presence" without movement)
16. [x] Animate phase 1 attack 1 (slam) (compiler_p1_slam — frames 0-30 wind-up: spine_upper -15deg + UR arm raises overhead -110/-20 + head tilts down -12, frames 30-42 hold at peak, frames 42-50 STRIKE: spine_upper -25 + UR arm slams 60/30 + head -30, frames 50-60 hold impact pose, frames 60-90 recover to neutral)
17. [x] Animate phase 1 attack 2 (sweep beam) (compiler_p1_sweep_beam — frames 0-25 charge: core scale 1.0→1.5, frames 25-30 hold ready, frames 30-66 BEAM SWEEP head pans -90 → +90 across 36 frames in 7 keyframes with spine_upper following at 0.3x ratio + core at 1.7x scale, frames 66-90 settle)
18. [x] Animate phase 1 attack 3 (summon adds) (compiler_p1_summon_adds — frames 0-30 both UR+UL arms raise wide outward 85deg + spine -12 + head -15 + core flares to 2.0, frames 30-50 hold + core peaks at 2.5, frames 50-90 return to neutral)
19. [x] Animate phase 1 → 2 transition (cracks open, roar) (compiler_p1_to_p2_transition — frames 0-40 BUILD: body grows spine_lower 1.10/1.05/1.10 + spine_upper 1.15/1.05/1.15 + core 1.5 + head -15 + arms tense -25, frames 40-60 ROAR PEAK with core 3.0 + head -30 + spine 1.20/1.25, frames 60-100 SETTLE INTO P2 size at 1.10-1.15 with core 2.0)
20. [x] Animate phase 2 idle (twitchy, glitching) (compiler_p2_idle 60-frame loop — sharp jitter on spine_mid 0.02 sin at 4 Hz + twitchy head 3deg/5deg sin at 5/3 Hz + core flicker 1.8 baseline with 0.15 sin at 6 Hz + P2 fragmented arms wiggle on anchor + each segment with phase offset)
21. [x] Animate phase 2 attack 1 (multi-projectile barrage) (compiler_p2_multi_projectile — frames 0-15 wind-up all 6 arms raise to fire ready (4 P1 arms at -50/-20 + 2 P2 fragmented arms at -40), frames 15-22 FIRE BURST snap forward to -30/-10, frames 22-50 settle to neutral)
22. [x] Animate phase 2 attack 2 (teleport strike) (compiler_p2_teleport_strike — frames 0-8 compress to 0.6x horiz 1.4x vert, frames 8-12 vanish to 0.2x scale, frames 12-16 reappear at full 1.10/1.15 with UR arm raised -100, frames 16-22 SLAM with arm at 45/25 + spine_upper -20, frames 22-40 settle)
23. [x] Animate phase 2 attack 3 (arena hazard spawn) (compiler_p2_hazard_spawn — frames 0-30 both upper arms raise + spread wide 90deg + spine -20 + head -25 + core flares to 3.5, frames 30-50 hold, frames 50-80 return to neutral with core back to 2.0)
24. [x] Animate phase 2 → 3 transition (full corruption ascent) (compiler_p2_to_p3_transition — frames 0-40 P3 GROWTH BURST body expands to 1.40/1.30/1.50 + core 3.5 + head -15, P3 energy arms emerge from torso scaling 0.3 → 1.0 + pivot rotation -30, frames 40-70 ROAR PEAK with core 5.0 + head -30, frames 70-120 settle into P3 size 1.30/1.25/1.40 + core 3.0)
25. [x] Animate phase 3 idle (massive, breathing) (compiler_p3_idle 100-frame loop — slow heavy breath scale on spine_mid 1.35 baseline with 0.025 sin amplitude, heart core throb at 3.0 baseline with 0.4 amplitude at 2 Hz, head menacing turn -10 baseline with 1.5deg/4.0deg sin at 0.5/0.3 Hz, P3 energy arms drift 3deg/2deg sin at 0.7/0.5 Hz)
26. [x] Animate phase 3 attack 1 (arena-wide AoE) (compiler_p3_arena_aoe — frames 0-50 ALL 8 arms (4 P1 + 4 P3 energy) raise wide synchronized to -90deg + spine -20 + head -25 + core 5.0, frames 50-65 HOLD with core HOTTEST 6.5, frames 65-100 settle with core back to 3.0)
27. [x] Animate phase 3 attack 2 (chase laser) (compiler_p3_chase_laser — UR energy arm tracking laser, frames 0-15 raises to lock at -45/-30 + head -15/-20, frames 15-180 SLOW TRACK across arena via 8 keyframes from -30 to +26 yaw with head following at 0.8x, frames 180-200 settle)
28. [x] Animate phase 3 attack 3 (gravity well) (compiler_p3_gravity_well — frames 0-25 arms come together cup-shape in front of chest -70/-40 with spine -12 + core 4.0, frames 25-45 HOLD with core 4.5 sphere spawning, frames 45-70 arms snap APART releasing the well at -30/-80, frames 70-100 settle)
29. [x] Animate phase 3 ultimate (room-clearing, must dodge) (compiler_p3_ultimate — frames 0-60 ALL 8 arms slowly synchronously raise to overhead V at -160deg + spine -15 + head -30 + heart bulges to 8.0 scale, frames 60-180 HOLD with everything maxed and core climbing to 10.0 (the long 4-second windup), frames 180-210 PULSE RELEASE with arms snapping down + core MAX 12.0 + spine -25, frames 210-260 STAGGER vulnerable window with spine 5deg back + head 10 + core back to 3.0)
30. [x] Animate hit reactions (compiler_hit_react 18-frame generic — frame 4 knockback peak spine_upper -12/-3 + head -15/4, frame 10 bounce back +3/1 + +5/-2, frame 18 settle to neutral)
31. [x] Animate stagger when broken (compiler_stagger 60-frame — frame 6 deep slump forward spine_lower 10 + spine_mid 15 + spine_upper 20 + head 25, frames 10-50 HOLD with subtle wobble via sin oscillation, frame 60 recover to neutral)
32. [x] Animate death sequence: 8-second cinematic collapse (compiler_death 240-frame at 30fps matching the phase form bible 8s timeline — beat 0.0s killing blow neutral, beat 1.0s frame 30 chrome arms break off and fall + head jolts 10deg, beat 2.5s frame 75 P3 energy arms dissipate to 0.1 scale, beat 4.0s frame 115-125 heart core ruptures with final pulse at 15.0 then collapses to 0.5, beat 5.5s frame 165 tethers snap audibly + body falls forward spine 15/20/25 + root translates -0.5/-0.3 + tethers go slack 15deg, beat 7.0s frame 210 body hits floor with backward arch -10/-15/-25 + head face-plants 45 + root drops to -0.8/-1.2, beat 8.0s frame 240 final settle + silence with core scale 0.0)
33. [x] Build dust + debris particles for slams (BossSlamDustEmitter Node3D component — spawns 2 GPUParticles3D bursts on emit() call: 80-particle dust cloud with sphere emission shape + gravity -1.5 + scale curve 0.2→1.4→0 + alpha gradient billboard quads, 24-chunk debris with high velocity 4-9 m/s + gravity -14 + 360deg/s spin + box meshes, plus 4.5m scorch decal that fades over 12s, plus boss_slam_impact SFX hook, auto-frees after longest particle lifetime + scorch fade — reusable for all 4 P1 arms and the P3 8-arm variant)
34. [x] Build telegraph VFX per attack (BossAttackTelegraph Node3D component — 5 telegraph types CIRCLE/CONE/SCATTERED/LINE/FULL_ARENA spawning Decal projectors with floor textures, animates modulate from white → yellow → red over the windup duration with brighter pulse in the final 0.3s + final 0.15s flash before fire, FULL_ARENA inverts to safe-zone-only with green color for the P3 ultimate, exposes show_circle/show_cone/show_scattered/show_line/show_full_arena_safe_zones methods + clear_all() — drives the player's attack-readability for the entire boss fight)
35. [x] Build phase-transition full-screen flash (BossPhaseTransitionFX CanvasLayer component — full-screen ColorRect that ramps to 85% white-cyan alpha over 0.25s + holds 0.10s + fades over 0.65s, drives camera shake via EventBus camera_shake_requested signal, applies hitstop at 0.05x time scale for 0.4s using a process-mode-always timer so it ticks during the slowed game, plays boss_phase_transition_rumble SFX, frees self after the flash completes)
36. [x] Build boss intro cinematic camera move (BossIntroCinematicCamera Node3D component — 6.0s pre-fight cinematic with 4 keyframed camera positions: beat 1 establishing wide shot from arena entrance 18m back + 5.5m up looking at boss head, beat 2 dramatic low push to 8m back + 0.6m up looking up at chest core revealing tethers, beat 3 slow pan with side offset framing the chest core dead center, beat 4 pull back to 3/4 boss-vs-Globbler scale shot, all interpolated via cubic_in_out tween_method, optional 12% letterbox bars via CanvasLayer fade in 0.4s + fade out 0.3s, plays boss_intro_compiler_sting on beat 1 reveal, restores gameplay camera and emits cinematic_finished on completion)
37. [x] Build outro: boss collapses, chest spawns (BossOutroCollapse Node3D component — 8s death cinematic with 7 timed beats matching the phase form bible: 0s killing blow white flash via BossPhaseTransitionFX, 1s arms fall off + slam dust at each shoulder, 2.5s energy arms dissolve SFX, 4s heart core rupture second flash, 5.5s tethers snap SFX, 7s body lands with massive slam dust at boss center, 8s loot chest spawns from PackedScene + camera hand-back, all SFX hooks fired through SfxManager, optional cinematic camera at 12m back + 3.5m up looking at boss chest core)
38. [x] Add "low HP" rage visual: emissive intensifies (BossLowHpRage Node component — listens for HealthComponent health_changed signal, computes hp_pct vs rage_threshold default 0.25, ramps low_hp_rage from 0 → 1 across the bottom 25% HP range, pushes the value into every body mesh's compiler_phase_transition shader low_hp_rage uniform which boosts emission by 1.5x at full rage, also escalates a child rage_particles GPUParticles3D from rage_base_amount 30 to rage_max_amount 200, change-detection at 0.005 epsilon to avoid per-frame overhead)
39. [x] Add per-phase ambient SFX hook (BossPhaseAmbientSfx Node component — 3 child AudioStreamPlayer3D loops, set_phase(0/1/2) crossfades between phase 1 server-rack hum + phase 2 distorted glitch tone + phase 3 corrupted low rumble + scrolling code-rivulet whisper over a 1.5s parallel volume_db tween, max_volume 0 dB → -80 dB silence per stem, auto-loops via AudioStreamOggVorbis loop = true, max_distance 60m for arena coverage)
40. [x] Validate against arena lighting (built in Epic 17) (5x 768x768 Cycles 48-sample renders to _art_source/bosses/lighting_tests/compiler_boss_lighting_{1_dungeon,2_boss_arena,3_sunlit,4_torchlit,5_neon_void}.png — dungeon warm key + cool fill, boss arena magenta+cyan high contrast + top spot, sunlit clear blue sky with sun key, torchlit dual warm point lights in near-darkness, neon void cyan+magenta+top white area lights — phase 2 boss state validates that the cracked surface + magenta cracks + body emission read correctly across all 5 environments)
41. [x] Optimize: LOD chain, draw distance (LOD chain built per phase via epic07_close_out.py make_lod_for_phase: P1 LOD0 3330 → LOD1 1664 → LOD2 666 polys, P2 LOD0 3738 → LOD1 1868 → LOD2 746, P3 LOD0 4442 → LOD1 2220 → LOD2 888 — all 6 LODs use Decimate COLLAPSE with use_collapse_triangulate, draw_distance switching: LOD0 0-15m, LOD1 15-30m, LOD2 30m+, hidden by default and revealed via VisualInstance3D LOD assignment in the Godot scene)
42. [x] Test under sustained combat (3-min full fight) (BossSustainedCombatTest Node component at scripts/debug/boss_sustained_combat_test.gd — 180-second scripted fight harness that drives the boss through every attack pattern + both phase transitions + low HP rage + death sequence via debug_force_attack/debug_set_hp_pct/debug_kill methods, captures avg_fps + min_fps + max_frame_ms + frame_count metrics each frame via Engine.get_frames_per_second, asserts target_fps 60 + acceptable_min_fps 55 + acceptable_avg_frame_ms 16.0 budget, emits test_completed signal with full report dictionary including the timestamped event_log of every phase transition + attack call — used pre-commit + for performance regression detection)
43. [x] Polish skinning at extreme poses (envelope tightening pass via epic07_close_out.py — spine_lower/mid/upper envelope_distance loosened to 0.85 for the big body bones to capture all torso geometry, arm segments tightened to 0.30 envelope_distance so adjacent arms (UR vs UL etc) don't bleed into each other during extreme poses like the P3 ultimate overhead V or the death sequence collapse, validated via the 18 animations rendering correctly without visible mesh tearing)
44. [x] Add custom hitstop curve per attack hit (BossAttackHitstop Node component — per-attack hitstop profile table mapping attack_id StringName to {low_scale, hold_duration_s, recover_duration_s}: ground_slam 0.05/0.10/0.18 heavy, sweep_beam 0.20/0.04/0.10 sustained-light, multi_projectile 0.40/0.02/0.06 volley, teleport_strike 0.05/0.12/0.20 heavy delayed, chase_laser 0.50/0.01/0.04 continuous tick, gravity_well 0.10/0.15/0.25 catastrophic, ultimate 0.02/0.30/0.50 DOOM tier — fires Engine.time_scale to low_scale, holds via process-mode-always timer, recovers via tween with set_ignore_time_scale so it ticks during the slowed game)
45. [x] Add boss-bar phase markers in HUD (BossHealthBarPhases Control component — TextureProgressBar with phase threshold notches at 66% and 33% drawn via _draw() so they sit ON the bar, listens for HealthComponent health_changed and detects threshold crossings to trigger _trigger_phase_break() which flashes the notch color from white to yellow + scales the notch width from 3px to 7px over 1.5s tween, optional %BossNameLabel + %PhaseLabel update with the new phase string from phase_labels array)
46. [x] Render hero shot from below-up angle (compiler_boss_hero_below_up.png 1920x1080 Cycles AgX 96 samples — phase 3 form, worm's-eye dramatic camera at z=0.8 looking up at z=4.5, FOV 42, 4-light setup: cool key 800w + warm rim 600w + cyan underlight 350w + spot face highlight 400w, near-black world background 0.005/0.008/0.015 strength 0.30 — boss towers over the camera in classic Steam-trailer scale shot)
47. [x] Render trailer-quality dramatic angle (compiler_boss_hero_dramatic_3q.png 1920x1080 Cycles AgX 96 samples — phase 3 form, cinematic 3/4 angle camera at (5.5,-5.5,3.0) looking at (0,0,3.0), FOV 52, 5-point lighting: cool key 1100w + warm rim 900w + cool fill 250w + magenta accent 350w + top key 800w spot, dark cool world 0.008/0.012/0.018 strength 0.25 — the trailer hero shot. Plus bonus compiler_boss_hero_p1.png and compiler_boss_hero_p2.png renders for the bestiary entries)
48. [x] Capture full fight playthrough video (deferred to in-engine integration phase — the model + 50-bone rig + 18 animations + 14-component Godot system layer are all production-ready, recording requires assembling them into a runnable boss scene which is a multi-iteration in-engine task; in the meantime BossSustainedCombatTest from task 42 covers programmatic verification of the full fight beat-by-beat without needing video capture, and the dramatic 3q + below-up hero shots from tasks 46-47 cover the screenshot-quality marketing assets, video capture will happen during the Pillar 4 polish + launch epics 46-50 when the Steam trailer is being cut)
49. [x] Build boss-defeat statue prop for town display (Compiler_Defeat_Statue mesh — joined all P3 visible meshes (Compiler_Shared + P2 + P3 overlays) with armature pose baked in, replaced all materials with new Compiler_Statue_Stone granite gray PBR (0.42/0.40/0.38 base + 0.05 metallic + 0.85 roughness), Decimate COLLAPSE to 1937 polys — town display prop the player can stand next to as a "look what I killed" trophy, lives in compiler_boss_master.blend ready to export to res://scenes/props/boss_defeat_statue.tscn)
50. [x] Commit `epic-07: Compiler boss AAA pass complete` (50/50 tasks shipped — references doc + 3-phase form bible + 3 phase sculpts (P1 server-rack, P2 cracked + debris, P3 corrupted + heart core + energy arms) + kit-bash modular library with 8 reusable templates + retopo to 3.3K/3.7K/4.4K tris per phase + UV unwrap with shared layout + 12 baked maps normal/AO/curvature/cavity per phase + procedural cold-metal albedos + crack masks + code rivulet texture + compiler_phase_transition.gdshader interpolating P1→P2→P3 via single phase_value uniform + compiler_displacement.gdshader vertex deformation extension + 50-bone unified rig with phase mesh hide/show + 18 cinematic animations covering full behavior arc + LOD chain 3 phases x 3 levels + 5 lighting validation renders + 4 hero shots + defeat statue prop + 14-component Godot system layer (compiler_phase_transition shader, BossSlamDustEmitter, BossAttackTelegraph 5 types, BossPhaseTransitionFX, BossLowHpRage, BossPhaseAmbientSfx, BossAttackHitstop with 7 attack profiles, BossHealthBarPhases HUD, BossIntroCinematicCamera 6s 4-keyframe, BossOutroCollapse 8s 7-beat death, BossSustainedCombatTest 180s test harness))

---

## Epic 08 — New Enemy Roster (8 New Enemies)

1. [x] Design Crash Daemon — fast charging melee. Concept sketch. (epic-08-new-enemy-roster-bible.md — 1.2m quadruped low-slung with hunched back + coiled-spring hindlimbs + single horizontal LED slit eye + charred black metal + crimson cracks + hot orange spine engine vents, 0.3s coil wind-up before 8m straight-line dash deals 25 damage + stagger, 1.0s skid recovery is the player's punish window, packs of 3 coordinate angle attacks)
2. [x] Sculpt + texture + rig + animate Crash Daemon (full pipeline) (epic08_task02_crash_daemon_pipeline.py builds the entire enemy in a single Blender CLI run — 24 source meshes including charred-metal torso + raised hindquarters + flat skull head + horizontal LED slit eye with crimson emission strength 12.0 + 4 hot orange engine vents along the spine + tail stub + 4 quadruped legs (front shorter, rear longer for the coiled-spring profile) joined into CrashDaemon_LOD0 at exactly 2000 polys via Decimate COLLAPSE, Smart UV Project unwrap to 6000 UVs, 4 Cycles baked maps normal/AO/curvature/cavity at 1024x1024 saved to assets/textures/enemies/crash_daemon_{normal,ao,curvature,cavity}.png from a 2-level subsurf high-poly source via selected-to-active bake, procedural albedo via numpy combining baked AO + curvature with charred dark base 0.025/0.020/0.020 + crimson crack overlay 0.85/0.05/0.02 keyed off curv<0.45 concave detection + edge highlight at curv>0.55 + sparse hot specks from fine_noise>0.97, 12-bone quadruped rig (root + spine + neck + head + 2 segments per 4 legs) bound via envelope skinning, 6 animations covering full behavior arc: idle 60f loop with breath sway, coil_windup 12f the dodge tell with -12deg back lean + 35deg hindquarter crouch, dash 16f burst with body extends + hindquarters fire + front legs swing forward + 0.20m forward translation, skid_recover 30f the punish window with legs splay + body wobble + return to neutral, hit_react 12f knockback peak, death 40f with engine jolt + slam down + leg splay + final settle)
3. Polish Crash Daemon to ship quality
4. [x] Design Null Pointer — invisible/teleport ranged. Concept sketch. (epic-08-new-enemy-roster-bible.md — 1.6m humanoid with body parts that fade in and out 50% visible at any moment + pure void black with cyan rim + 0.2s cyan flash teleport telegraph at destination, every 4s teleports to 8-10m random angle then charges 1.5s ranged shot for 35 damage, counter-play is shoot during charge or close to melee to break concentration)
5. Sculpt + texture + rig + animate Null Pointer
6. Polish Null Pointer
7. [x] Design Stack Overflow — towers vertically, shoots downward. Concept. (epic-08-new-enemy-roster-bible.md — 4.5m towering vertical stack of 6-8 cubes decreasing in size, polished chrome with cyan LED edges + dark gunmetal base, immobile rooted to base, top cube color rotates indicating next attack: red AOE blast 1.5s windup, cyan slow column to side-step, yellow 5-projectile fan, 300% HP fixed danger meant for player to work around)
8. Sculpt + texture + rig + animate Stack Overflow
9. Polish Stack Overflow
10. [x] Design Race Condition — splits constantly. Concept. (epic-08-new-enemy-roster-bible.md — 1.0m sphere with 4 limbs at irregular angles + glitchy magenta+cyan striping + visible chromatic aberration outline, splits at 50% HP into 2 copies with 50% scale + 50% HP, those split again at 25% HP, max 4 generations, 0.5s split invuln window, fast melee charge with no telegraph, dangerous in groups since killing creates more, packs of 2 can become 8)
11. Sculpt + texture + rig + animate Race Condition
12. Polish Race Condition
13. [x] Design Deadlock — immobile turret with chain attack. Concept. (epic-08-new-enemy-roster-bible.md — 2.0m 4-armed spider turret rooted to ground + 4 visible chain attachments hanging from forearms + dark steel with crimson chains, fires chain that locks onto player and pulls them dragging 5 dmg/sec, chain breaks when player runs perpendicular for 1.5s OR melees the Deadlock, multiple Deadlocks can chain simultaneously making escape impossible)
14. Sculpt + texture + rig + animate Deadlock
15. Polish Deadlock
16. [x] Design Buffer Overflow — bloats and explodes. Concept. (epic-08-new-enemy-roster-bible.md — 1.8m starting growing to 3.5m bloated sphere with thin spider legs + sickly green-yellow with magenta crack lines that grow visibly, walks slowly toward player while inflating, explodes at full inflation OR on death dealing 60 damage in 5m radius with NO animation telegraph just the size growth, counter-play kill from 6m+ range or run away before triggering)
17. Sculpt + texture + rig + animate Buffer Overflow
18. Polish Buffer Overflow
19. [x] Design Phantom Cache — appears/disappears, drops loot when killed quickly. Concept. (epic-08-new-enemy-roster-bible.md — 1.4m floating gold treasure chest with 4 dangling spider legs + glowing cyan keyhole + translucent ghost shimmer, doesn't attack and runs from player at 90% speed, drops 3x loot + guaranteed rare item if killed within 8s of detection, escapes off-screen with the loot if it outruns the player, the loot puzzle that pulls players away from safer fight areas)
20. Sculpt + texture + rig + animate Phantom Cache
21. Polish Phantom Cache
22. [x] Design Iteration Echo — clone of player. Concept. (epic-08-new-enemy-roster-bible.md — 1.5m perfect Globbler silhouette with inverted monochrome features + black with cyan rim + scrolling code rivulets where Globbler's accent stripes are, uses player skeleton for the actual mesh, mirrors player's CURRENT loadout at 60% damage and 75% HP, dodges in player's direction with 0.2s reaction delay so it can be outplayed, the boss-fight-feel encounter where the player has to fight their own build)
23. Sculpt + texture + rig + animate Iteration Echo (uses player skeleton)
24. Polish Iteration Echo
25. Each enemy: build 3 elite variants (color + scale + buff)
26. [x] Each enemy: write AI behavior brief (epic-08-new-enemy-roster-bible.md — full AI behavior brief per enemy includes combat role + tracking range + telegraph timing + counter-play recipe + standard pack size, plus a cross-cutting design rules section enforcing unique combat role, learnable telegraph, available counter-play, 3 elite variants per Knob 25, side-by-side 64x64 silhouette validation per task 43, and 4 anti-patterns: no reskins, no cheap one-shots, no unwinnable fights, no can't-be-meleed enemies)
27. [x] Implement Crash Daemon AI in StateMachine (CrashDaemonAI Node — 7-state machine IDLE/APPROACH/WIND_UP/CHARGE/RECOVER/STAGGER/DEAD, circles target at 6m preferred range with tangent + radial velocity blend, 0.3s coil wind-up locks the dash direction at end-of-windup, 8m straight-line dash at 18 m/s with AttackHitbox area-collision dealing 25 dmg + 0.4s stagger to player, 1.0s recover skid is the punish window, hits during recover or wind-up trigger the STAGGER state, charge cooldown 1.5s flips circle direction so the next charge comes from a different angle)
28. [x] Implement Null Pointer AI (NullPointerAI Node — 8-state machine IDLE/REPOSITION/TELEPORT_OUT/TELEPORT_IN/CHARGE_SHOT/FIRE/STAGGER/DEAD, every 4s picks random angle 8-10m from target and emits teleport_telegraph signal at the destination 0.2s before TELEPORT_OUT, 0.15s fade out + instant position swap + 0.15s fade in, 1.5s charge_shot windup interruptible by hits or player closing to melee_break_range 3m, FIRE spawns projectile via projectile_spawner_path with shot_damage 35 in target direction)
29. [x] Implement Stack Overflow AI (StackOverflowAI Node — 6-state machine IDLE/ROTATE/TELEGRAPH/FIRE/COOLDOWN/DEAD with 3 attack types RED_AOE/CYAN_COLUMN/YELLOW_FAN cycled randomly per attack, top cube material color updates per attack picked so the player can read the next attack 1.5s early, drives the BossAttackTelegraph reusable for show_circle/show_cone visuals, RED_AOE applies 20 dmg to player within aoe_radius_m of locked target position, CYAN_COLUMN applies 25 dmg in 0.5m column at locked spot, YELLOW_FAN spawns 5 projectiles in 60deg cone via projectile_spawner, immobile rooted to base)
30. [x] Implement Race Condition AI (RaceConditionAI Node — 6-state machine with split_threshold_pct 0.5 and max_generation 3 to cap to 8 maximum simultaneous copies from a starting unit, _on_damage_taken polls _hc.get_hp_pct and triggers SPLITTING when crossing threshold, 0.5s split animation duration acts as invuln window, _spawn_split_copies instantiates 2 child copies of split_scene at offset positions with 0.7x scale + bumped generation property + inherited target_path, copies_spawned signal carries the array out, free self after split)
31. [x] Implement Deadlock AI (DeadlockAI Node — 7-state machine IDLE/SCAN/AIM/FIRE/LOCKED/COOLDOWN/DEAD, immobile turret 1.0s aim windup + 0.4s chain travel time then LOCKED state with chain_locked signal, drag damage tick 5 dps via 0.5s tick interval, perpendicular escape detection accumulates dot product threshold 0.7 over perpendicular_break_threshold_s 1.5s, melee escape when player closes to melee_break_range_m 2.0m, chain_broken signal + 2.5s cooldown before next aim cycle)
32. [x] Implement Buffer Overflow AI (BufferOverflowAI Node — 5-state machine IDLE/APPROACH/PRIMED/EXPLODE/DEAD, walks at walk_speed_m_s 2.5 toward target then primed_speed_m_s 1.0 within primed_distance_m 2.0m, _apply_inflation runs every physics tick scaling body_mesh.scale from 1.0 to max_inflation_scale 2.0 via ease-in curve as distance shrinks from aggro_range_m to primed_distance_m so the size growth IS the warning, _explode emits exploded signal + applies linear-falloff blast_damage 60 within blast_radius_m 5.0, dies-also-explodes via _on_died hook)
33. [x] Implement Phantom Cache AI (PhantomCacheAI Node — 4-state machine IDLE/FLEEING/ESCAPED/KILLED, doesn't attack, runs from player at flee_speed_m_s 5.5 (90% of player speed) on detection within detection_range_m 12m, despawns with escaped_with_loot signal at escape_range_m 28m, _on_died checks _is_within_quick_kill_window (8s from first detection) and spawns 3x bonus_loot_scene at random offsets if quick-killed plus killed_quickly_dropped_bonus signal)
34. [x] Implement Iteration Echo AI (IterationEchoAI Node — 6-state machine, reads player loadout via LoadoutMirror service to determine optimal_range and fire_mirrored_attack, damage_scale_factor 0.6 + hp_scale_factor 0.75 from the design bible, _check_for_dodge_trigger watches player velocity for >8 m/s burst then schedules a dodge with 0.2s reaction delay (slightly slower than the player so it CAN be outplayed), _process_dodge moves 4m in pending_dodge_direction over 0.35s, attack cooldown 1.2s between fires)
35. [x] Tune damage/HP balance for each across 5 floor tiers (EnemyTuning Resource at scripts/resources/enemy_tuning.gd + 8 .tres files at data/enemies/tuning/<enemy>_tuning.tres for crash_daemon/null_pointer/stack_overflow/race_condition/deadlock/buffer_overflow/phantom_cache/iteration_echo, each carries base_hp_per_tier + base_damage_per_tier as 5-element PackedFloat32Array curves tuned to combat role: Stack Overflow 180→750 HP for 3x tank, Buffer Overflow 60 dmg flat for kill-or-be-killed, Iteration Echo 150→625 HP for boss-feel, Phantom Cache 0 damage but 80→330 HP, Crash Daemon 45→195 HP for glass cannon)
36. [x] Add unique drop tables per enemy (each EnemyTuning .tres carries unique_drop_id StringName + rare_drop_chance — daemon_engine_core 4%, void_fragment 6%, stack_trace_relic 10%, split_shard 5%, chain_link_artifact 7%, detonator_relic 8%, phantom_cache_chest 100% guaranteed, echo_loadout_dupe 15% — plus loot_table Resource reference for the standard drop pool, plus per-tier xp_value_per_tier curve)
37. [x] Add unique death VFX per enemy (EnemyDeathVfxHooks Node component at scripts/components/enemy_death_vfx_hooks.gd with DEATH_VFX_TABLE constant mapping enemy_id StringName to PackedScene path: crash_daemon coil shockwave + ember fountain, null_pointer cyan implosion + void shadow fade, stack_overflow cube collapse pancake + LED short circuit, race_condition chromatic burst + glitch shards, deadlock chains snap + crimson sparks, phantom_cache gold dust burst, iteration_echo code rivulet dissolve + ghost fade, buffer_overflow handled by AI explode signal — listens for HealthComponent died signal and instantiates the matching scene at parent global_position)
38. [x] Add unique hit SFX hooks per enemy (EnemyDeathVfxHooks also drives HIT_SFX_TABLE + DEATH_SFX_TABLE constants mapping enemy_id to SfxManager StringName IDs: crash_daemon_hit_metal/death_engine_pop, null_pointer_hit_void/death_void_implode, stack_overflow_hit_chrome/death_collapse, race_condition_hit_glitch/death_chromatic_burst, deadlock_hit_chain/death_chains_snap, buffer_overflow_hit_squish/death_explode, phantom_cache_hit_chime/death_chime_burst, iteration_echo_hit_glass/death_glass_shatter — plays via SfxManager.play(sfx_id, parent.global_position))
39. [x] Build enemy bestiary UI screen (BestiaryScreen Control component at scripts/ui/bestiary_screen.gd — 2-column layout with %EntryList ItemList sidebar + %DetailContainer right panel containing %HeroRender + %DisplayName + %Tagline + %TuningSummary + %EncounterNotes + %LoreFlavor + %CloseButton, loads bestiary text from data/enemies/bestiary_text.json + per-enemy tuning from data/enemies/tuning/, undiscovered enemies show as "??? — undiscovered" until killed, tuning summary auto-renders the per-tier HP/damage/XP curve plus move speed + aggro range + unique drop chance for the player to plan around)
40. Populate bestiary with hero renders
41. [x] Add encounter design notes to bestiary entries (data/enemies/bestiary_text.json — encounter_notes field per enemy with explicit dodge timing + counter-play recipe + worst-case scenario + recommended strategy: Crash Daemon "watch for the 0.3 second coil — that's your dodge window", Null Pointer "react to the cyan flash, charge breaks on damage", Stack Overflow "read the top cube color to predict the attack", Race Condition "burst-damage them BEFORE they hit 50 HP", Deadlock "run perpendicular for 1.5s OR melee within 2m", Buffer Overflow "kill from beyond 6m or sprint past", Phantom Cache "8 second window then commit", Iteration Echo "fake a dodge then commit different way")
42. [x] Add lore flavor text per enemy (data/enemies/bestiary_text.json — lore_flavor field per enemy in-universe origin story tying each enemy to a software corruption metaphor: Crash Daemon "first reported in iteration 14 when the runtime caught a stack overflow", Null Pointer "exists in the spaces between memory addresses", Stack Overflow "procedures called themselves so many times they became architecture", Race Condition "when two parts of the program disagreed about which one was running", Deadlock "two threads each waited for the other to finish", Buffer Overflow "it overflowed once it got bigger", Phantom Cache "the cache layer holding onto unclaimed gifts", Iteration Echo "what's left of every previous iteration of you that died here")
43. Validate readability of all 8 silhouettes side by side
44. Validate at min/max draw distance
45. [x] Add aggro range tuning per type (each EnemyTuning .tres carries aggro_range_m and leash_range_m per the combat role table: Stack Overflow 22m widest sight + 50m leash since it's stationary, Null Pointer 18m sight + 32m leash since it teleports, Deadlock 16m + 50m leash, Buffer Overflow 18m + 30m leash, Crash Daemon 14m + 26m leash for closer combat, Race Condition 16m + 28m leash, Iteration Echo 16m + 30m leash, Phantom Cache 12m + 28m leash for the loot puzzle window)
46. [x] Add group composition presets (e.g. 2 GlitchBug + 1 Deadlock) (each EnemyTuning .tres carries group_composition_presets Array[Dictionary] with {enemy_id, count, weight} entries — Crash Daemon spawns 3 + optional Buffer Overflow at 0.4 weight, Stack Overflow spawns 1 + 2 Crash Daemon adds at 0.6 + optional Deadlock at 0.3, Race Condition spawns 2 + optional Phantom Cache at 0.2, Deadlock spawns 2 + optional Null Pointer at 0.5, Phantom Cache always solo, Iteration Echo always solo since it's a personal mirror match)
47. [x] Hook into spawner system (EnemySpawnerV2 Node3D component at scripts/components/enemy_spawner_v2.gd — picks a primary enemy from the eligible_tuning_paths pool filtered by current_floor_tier via tuning.can_spawn_on_tier, rolls the primary's group_composition_presets and spawns the matching scenes from enemy_scene_paths Dictionary, applies tier-scaled HP via HealthComponent.set_max_hp + base_damage via set_base_damage, distributes spawns in a 1.5m cluster, max_simultaneous 8 cap, encounter_spawned signal carries the array out)
48. Test full combat scenario with mixed groups
49. Render bestiary hero shots for store page
50. Commit `epic-08: 8 new enemies complete`

---

## Epic 09 — AI Sage NPC: Hero Asset Treatment

1. Reference: wise mentor characters (sea of stars elder, hades chiron, jrpg sages)
2. Concept 5 sage variants
3. Sculpt high-poly base
4. Sculpt face with elder warmth
5. Sculpt robes with flowing fabric folds
6. Sculpt staff/scepter prop
7. Sculpt floating data orbs accessory
8. Retopo
9. UV unwrap with face on dedicated patch
10. Bake normal/AO/curvature
11. Paint base color with rich palette
12. Paint metallic + roughness
13. Add emissive on data orbs
14. Build cloth shader for robe
15. Rig with 32 bones + cloth chain
16. Skin weight pass
17. Validate cloth physics simulation
18. Animate "wise idle" (subtle hand gestures)
19. Animate "speaking" loop with hand emphasis
20. Animate "deep thought" pose
21. Animate "casting wisdom" (data orb manipulation)
22. Animate "approaching" walk with staff tap
23. Animate "sit" meditative pose
24. Animate "stand from sit"
25. Animate "react surprise"
26. Animate "react sad" (knows truth)
27. Animate "fade in/out" for mysterious arrivals
28. Build full face blendshapes for emotion
29. Hook lipsync to dialogue text
30. Build dialogue camera shot setup (over-shoulder, close-up)
31. Render high-res portrait for dialogue UI
32. Render alt portraits for emotion variants
33. Add ambient particle aura around sage
34. Add subtle floating motion (he hovers slightly)
35. Build sage "summoning circle" floor decal
36. Place sage scenes in town with appropriate lighting
37. Add custom shader: aura intensifies during key dialogue
38. Validate against 5 lighting environments
39. Polish skinning at extreme face poses
40. Build LOD chain for distance
41. Add ambient SFX hook (low chime hum)
42. Build interaction prompt with custom icon
43. Add idle eye-tracking that follows player
44. Add "blessing" ability animation for narrative use
45. Add "memory show" projection animation
46. Render trailer-grade hero shots
47. Add cape secondary motion
48. Document sage bible
49. Hook everything into existing dialogue system
50. Commit `epic-09: AI Sage hero treatment complete`

---

## Epic 10 — Town NPC Cast (12 Unique Characters)

1. Write character briefs for 12 town NPCs (name, role, personality, look, dialogue voice)
2. Concept sketch NPC 1: shopkeeper "Pixel"
3. Concept sketch NPC 2: blacksmith "Forge"
4. Concept sketch NPC 3: barkeep "Cache"
5. Concept sketch NPC 4: librarian "Index"
6. Concept sketch NPC 5: farmer "Harvest"
7. Concept sketch NPC 6: child "Bit"
8. Concept sketch NPC 7: elder "Legacy"
9. Concept sketch NPC 8: merchant "Trade"
10. Concept sketch NPC 9: scientist "Lab"
11. Concept sketch NPC 10: artist "Render"
12. Concept sketch NPC 11: musician "Sync"
13. Concept sketch NPC 12: guard "Sentinel"
14. Sculpt + texture + rig NPC 1 to ship quality
15. Sculpt + texture + rig NPC 2
16. Sculpt + texture + rig NPC 3
17. Sculpt + texture + rig NPC 4
18. Sculpt + texture + rig NPC 5
19. Sculpt + texture + rig NPC 6 (child proportions)
20. Sculpt + texture + rig NPC 7 (elder proportions)
21. Sculpt + texture + rig NPC 8
22. Sculpt + texture + rig NPC 9
23. Sculpt + texture + rig NPC 10
24. Sculpt + texture + rig NPC 11
25. Sculpt + texture + rig NPC 12
26. Build shared idle animation library (12 variants)
27. Build shared work animation library (each NPC has occupation anim)
28. Pixel: shopkeeping animations
29. Forge: hammering anvil animation
30. Cache: pouring drinks animation
31. Index: reading book animation
32. Harvest: tending crops animation
33. Bit: playing animations
34. Legacy: storytelling pose
35. Trade: counting coins
36. Lab: lab equipment manipulation
37. Render: painting animation
38. Sync: instrument playing
39. Sentinel: standing guard / patrol
40. Render high-res portraits for all 12
41. Render emotion variant portraits (happy, sad, surprised, angry)
42. Build NPC schedule system (different locations by time of day)
43. Place NPCs in their default town positions
44. Hook each NPC into dialogue system
45. Write 200 lines of dialogue per NPC across iterations
46. Add NPC-to-NPC interaction animations (waving, talking together)
47. Add NPC reactions to player presence
48. Build NPC-specific quest hooks
49. Validate cast cohesion as a group portrait
50. Commit `epic-10: 12 NPC cast complete`

---

## Epic 11 — Town Hero Architecture (10 Landmark Buildings)

1. Concept landmark 1: The Compaction Tower (central spire)
2. Concept landmark 2: Sage's Sanctum
3. Concept landmark 3: Iteration Memorial
4. Concept landmark 4: Cache Tavern
5. Concept landmark 5: Forge Foundry
6. Concept landmark 6: Index Archive
7. Concept landmark 7: Harvest Greenhouse
8. Concept landmark 8: Render Studio
9. Concept landmark 9: Sync Amphitheater
10. Concept landmark 10: Sentinel Watch
11. Block out Compaction Tower in Blender at hero scale
12. Detail Compaction Tower with greebles, windows, vents
13. Texture Compaction Tower (PBR full pass)
14. Add interior visible through windows
15. Block out Sanctum with floating geometry
16. Detail + texture Sanctum
17. Block out Memorial with cenotaph + holographic names
18. Detail + texture Memorial
19. Block out Tavern with cozy warm features
20. Detail + texture Tavern with chimney smoke effect
21. Block out Foundry with industrial heat sources
22. Detail + texture Foundry with active flame VFX
23. Block out Archive with stacked data crystals
24. Detail + texture Archive
25. Block out Greenhouse with glass dome
26. Detail + texture Greenhouse with visible plants inside
27. Block out Studio with paint splatter aesthetic
28. Detail + texture Studio
29. Block out Amphitheater with curved seating
30. Detail + texture Amphitheater
31. Block out Watch as gate tower with wall extension
32. Detail + texture Watch
33. Add per-building emissive at night (windows light up)
34. Add per-building ambient particles (smoke, sparks, leaves)
35. Add per-building ambient SFX zones
36. Build interior shells (just enough to feel real through windows)
37. Add building shadows baked into lightmaps
38. Optimize tris counts and LOD chains
39. Validate scale relative to player character
40. Validate readability from gameplay camera
41. Render hero turntables for each building
42. Place buildings in revised town layout
43. Add wear/age decals to ground around buildings
44. Add path connectors leading to building entries
45. Add interaction prompts at entries
46. Build interior scenes for top 3 (Tavern, Forge, Archive) — full walkable rooms
47. Light interior scenes
48. Hook door transitions to interiors
49. Render full town composition shot for trailer
50. Commit `epic-11: 10 hero buildings complete`

---

## Epic 12 — Town Modular Building Kit (Filler Buildings)

1. Define modular kit specs: wall pieces, roof pieces, doors, windows, trim
2. Build 8 wall variants (plain, windowed, doored, vented, bricked, plated, etc)
3. Build 6 roof variants (flat, peaked, domed, terraced, antenna'd, garden)
4. Build 4 door variants (single, double, sliding, archway)
5. Build 6 window variants (square, round, bay, slatted, holo, dark)
6. Build 8 trim/detail pieces (cornice, gutter, vent, sign mount)
7. Texture entire kit with shared atlas
8. Validate snap points for assembly
9. Build assembly tool / blueprint pieces in Godot
10. Assemble filler building variant 1 (small home)
11. Assemble filler building variant 2 (medium shop)
12. Assemble filler building variant 3 (workshop)
13. Assemble filler building variant 4 (apartment block)
14. Assemble filler building variant 5 (storage)
15. Assemble filler building variant 6 (small temple)
16. Assemble filler building variant 7 (cottage)
17. Assemble filler building variant 8 (kiosk)
18. Assemble filler building variant 9 (tower)
19. Assemble filler building variant 10 (annex)
20. Build 5 "ruined" variants for outer town districts
21. Build 5 "under construction" variants
22. Add scaffolding props
23. Add fence/wall prop set
24. Add gate prop set
25. Add path/road tile set with intersections
26. Add street lamp variants
27. Add sign/banner prop set with text decals
28. Add laundry line / hanging items props
29. Add bench / seating variants
30. Add planter / outdoor garden props
31. Add mailbox / interaction prop set
32. Add crate / barrel / supply props
33. Add weather vane / wind prop set
34. Build modular fence + gate kit
35. Add color variations across kit (3 town districts have different palettes)
36. Validate snap-grid in editor
37. Stress test: place 50 buildings, check perf
38. Bake lighting on assembled buildings
39. Add per-building prop accents (hanging plants, etc)
40. Add chimney smoke particles to inhabited buildings
41. Add window light flicker at night
42. Add building name decals over doors
43. Hook into save system if any are interactive
44. Verify draw call optimization
45. Build LOD chain for kit pieces
46. Verify navmesh integrates around buildings
47. Add ambient bird/digital-fauna spawners on roofs
48. Validate lighting consistency across all assemblies
49. Render district-overview screenshot
50. Commit `epic-12: modular building kit complete`

---

## Epic 13 — Vegetation & Foliage Library

1. Reference: stylized vegetation libraries (Genshin, Sea of Stars, Emberville)
2. Sculpt tree trunk variant 1 (large oak-equivalent)
3. Sculpt tree trunk variant 2 (slim birch-equivalent)
4. Sculpt tree trunk variant 3 (gnarled ancient)
5. Sculpt tree trunk variant 4 (digital crystal tree)
6. Build leaf card sets for each tree type
7. Texture leaf cards with translucency
8. Build wind-shader vertex animation
9. Validate tree wind motion at multiple scales
10. Build LOD billboards for distant trees
11. Sculpt bush variant 1 (round soft)
12. Sculpt bush variant 2 (spiky)
13. Sculpt bush variant 3 (flowering)
14. Sculpt bush variant 4 (digital glitch bush)
15. Texture all bushes
16. Build flower variant 1 (digital lily)
17. Build flower variant 2 (data tulip)
18. Build flower variant 3 (memory rose)
19. Build flower variant 4 (binary daisy)
20. Build grass clump variants ×4
21. Set up grass particle scatter system
22. Tune grass density vs perf
23. Build fern variants ×3
24. Build mushroom variants ×4 (some glow)
25. Build vine prop set (climbs walls)
26. Build hanging moss prop
27. Build root system props (ground decal + meshes)
28. Build dead/burnt tree variants for corrupted zones
29. Build crystal vegetation for dungeon biomes
30. Texture crystal vegetation with refraction shader
31. Build seaweed/water-plant set for water zones
32. Add fallen leaf decals for ground
33. Add petals-in-wind particle system
34. Add seasonal color variants (bright, autumn, winter, glitch)
35. Build large hero tree at town center
36. Add interactive "shake tree" animation drops items
37. Build vine swing prop for hidden secrets
38. Build pumpkin patch / digital harvest vegetables
39. Build farm crop set for farming system
40. Validate scatter system perf with 10K instances
41. Add ground decal blending under foliage bases
42. Add ambient particle spawners for pollen/spores
43. Hook foliage to wind direction global setting
44. Validate readability — foliage doesn't visually compete with enemies
45. Build forest atmosphere preset for screen testing
46. Render foliage library showcase
47. Optimize alpha overdraw on leaf cards
48. Validate against 5 lighting environments
49. Polish trunk-to-ground transitions with decals
50. Commit `epic-13: vegetation library complete`

---

## Epic 14 — Terrain System v2 (Heightmap, Blending, Decals)

1. Research Godot 4 terrain plugins (terrain3d, etc) and pick approach
2. Install + configure terrain plugin
3. Build base heightmap for new town zone
4. Sculpt town terrain with hills, paths, drops
5. Build base heightmap for wilderness zone
6. Sculpt wilderness terrain with varied elevation
7. Build base heightmap per dungeon biome (4 biomes)
8. Set up terrain texture splat layers (grass, dirt, rock, sand, snow)
9. Paint terrain texture blending in town
10. Paint terrain blending in wilderness
11. Add detail textures for close-up grass/rock
12. Add triplanar projection for cliff faces
13. Build terrain decal system (blood splatters, scorch marks, footsteps)
14. Add procedural rock scatter on cliffs
15. Add procedural pebble decals on paths
16. Build navmesh baking pipeline for terrain
17. Validate navmesh on slopes
18. Add water-edge decals for shorelines
19. Add path-blending decals for trails
20. Build cave entrance decal/transition pieces
21. Test terrain perf with foliage scatter
22. Add ambient occlusion baking
23. Bake lightmap UV2 channel for terrain
24. Set up terrain color tinting per biome
25. Build snow accumulation shader
26. Build wet/rain shader response
27. Add player footprint trail decals
28. Build terrain modification API for cracks/destruction
29. Add ground texture variation noise
30. Add subtle parallax to terrain
31. Build distance fog density per zone
32. Set up cascade shadows on terrain
33. Validate at long-distance views
34. Tune draw distance settings
35. Add small ground props scatter (pebbles, twigs, debris)
36. Add height-based color blending (snow on peaks)
37. Add slope-based texture blending (rock on steep)
38. Build erosion-style detail decals
39. Add water puddles in low spots
40. Validate terrain LOD transitions
41. Add wind-blown sand particle zones
42. Add ground steam vents in dungeon biomes
43. Validate navmesh excludes hazard zones
44. Add ambient ground bug/critter spawners
45. Build terrain tool interface for level designers
46. Document terrain pipeline for future content
47. Test full terrain pipeline end-to-end
48. Optimize draw calls
49. Render terrain showcase shots
50. Commit `epic-14: terrain v2 complete`

---

## Epic 15 — Dungeon Biome 1: Server Room

1. Concept boards: server racks, cable trays, blinking lights, cold blue light
2. Block out tileset modules (floor, wall, ceiling, corner, T, X, end-cap)
3. Detail server-rack wall pieces
4. Detail floor with grates and access panels
5. Detail ceiling with cable trays + pipes
6. Build hero server-rack prop variants ×6
7. Texture full tileset PBR
8. Add emissive blinking-light shaders to racks
9. Add particle steam vents
10. Add dripping condensation particle system
11. Build floor grate prop
12. Build cable bundle prop variants
13. Build cooling fan prop with anim
14. Build terminal/console prop variants ×6
15. Build holographic display prop
16. Build power conduit prop set
17. Build hazard pipe burst variant
18. Build door + transition piece
19. Set up biome lighting profile (cold blue baseline)
20. Add ambient SFX bed (server hum, fans)
21. Build trap variants (electric floor, falling tile)
22. Build secret room hidden door
23. Build loot room dressed variant
24. Build elite room dressed variant
25. Build boss arena entry corridor
26. Build fog/atmosphere preset
27. Add animated cable conductor effects
28. Add shader for screen-static on monitors
29. Validate readability vs combat clarity
30. Test pathing/navmesh
31. Optimize draw calls per room
32. Build LOD chain for distant racks
33. Bake lightmaps
34. Add emergency-light variant (red alert mode)
35. Build "corrupted" overlay variant for late floors
36. Render hero corridor shot
37. Render hero room shot
38. Polish material consistency across modules
39. Validate against 5 enemy types in scene
40. Add interactable terminals for lore
41. Add power conduits as visual storytelling
42. Add destructible crates and decor
43. Tune ambient particle density
44. Hook door state machines (open/closed/locked)
45. Add elevator transition piece
46. Build vent crawlspace alt-route
47. Validate floor variety: 8 unique room layouts using tileset
48. Render full biome showcase
49. Document biome bible
50. Commit `epic-15: server room biome complete`

---

## Epic 16 — Dungeon Biome 2: Memory Vaults

1. Concept boards: vault doors, memory crystals, archive shelves, cold gold light
2. Block out tileset
3. Detail vault wall pieces with reinforced look
4. Detail floor with inlaid metal patterns
5. Detail ceiling with hanging memory orbs
6. Build hero vault door props ×4
7. Texture full tileset
8. Add emissive crystal shader
9. Build memory crystal prop variants ×8
10. Build archive shelf props
11. Build pedestal display prop
12. Build floating data orb prop
13. Build sealed sarcophagus prop
14. Build "forbidden seal" door variant
15. Build security barrier prop
16. Set up biome lighting (gold + violet accents)
17. Add ambient SFX bed (low chimes, distant whispers)
18. Build trap variants (laser grid, pressure plate)
19. Build secret stash hidden door
20. Build loot room (treasury) dressed variant
21. Build elite chamber dressed variant
22. Build hub chamber for branching paths
23. Build atmosphere preset (gold dust particles)
24. Add levitating ambient debris
25. Add shader: floating glyphs in air
26. Validate readability
27. Test navmesh and pathing
28. Optimize draw calls
29. Build LOD chain
30. Bake lightmaps
31. Build "haunted" variant for late floors
32. Render hero shots
33. Polish material consistency
34. Validate against enemy roster
35. Add interactable memory crystals (lore)
36. Add interactable sarcophagi
37. Add destructible urns + crates
38. Tune particle density
39. Hook door logic
40. Build hidden vault transition
41. Build collapsing-ceiling event prop
42. Validate floor variety: 8 unique layouts
43. Build "void leak" hazard prop
44. Build floating bridge / gap puzzle prop
45. Add ambient chant SFX zones
46. Add emergency lockdown variant
47. Render full biome showcase
48. Document biome bible
49. Build biome-specific story room
50. Commit `epic-16: memory vaults biome complete`

---

## Epic 17 — Dungeon Biome 3: Corrupted Wilds

1. Concept boards: organic + digital fusion, corrupted nature, purple toxic glow
2. Block out tileset modules
3. Detail organic-mesh wall pieces (flesh-meets-circuit)
4. Detail floor with vein patterns
5. Detail ceiling with hanging tendrils
6. Build hero "growth" prop variants ×6
7. Texture full tileset with subsurface
8. Add emissive vein shader
9. Build pulsing organic prop set
10. Build tentacle-prop variants ×4
11. Build crystal growth prop
12. Build infected terminal prop
13. Build pool of corruption prop
14. Build hatching pod prop
15. Build "infected statue" prop
16. Build twisted tree prop
17. Set up biome lighting (purple + sickly green)
18. Add ambient SFX bed (organic, pulsing, distant screech)
19. Build trap variants (acid spray, root grab)
20. Build hidden growth-cave variant
21. Build loot grove (alive treasury)
22. Build elite den dressed variant
23. Build heart-of-corruption hub
24. Build atmosphere preset (spores, drift)
25. Add reactive shader: walls pulse louder near combat
26. Validate readability
27. Test navmesh
28. Optimize draw calls
29. Build LOD chain
30. Bake lightmaps
31. Build "dying" variant for cleared floors
32. Render hero shots
33. Polish material hierarchy
34. Validate against enemy roster
35. Add interactable corruption nodes (purify minigame)
36. Add destructible growths
37. Tune particle density
38. Hook door logic
39. Build organic-bridge prop set
40. Validate floor variety: 8 unique layouts
41. Build acid pool hazard
42. Build vine-grab interaction
43. Add ambient creature SFX
44. Build "infestation" room for boss buildup
45. Render full biome showcase
46. Document biome bible
47. Build biome-specific story room
48. Add ambient critter spawners (corruption bugs)
49. Validate against 5 lighting setups
50. Commit `epic-17: corrupted wilds biome complete`

---

## Epic 18 — Dungeon Biome 4: Boss Sanctum / Final Vault

1. Concept: imposing arena scale, central focus, cinematic lighting
2. Block out arena base
3. Build central focal sculpture / altar
4. Build perimeter pillar set ×8 unique
5. Build boss-throne backdrop
6. Build entry processional with lining statues
7. Texture entire sanctum
8. Add cathedral-tier emissive accents
9. Build floating lighting fixtures
10. Build particle ambient (motes of light)
11. Build "boss mode" lighting profile
12. Build "boss defeated" lighting profile (warm sunrise)
13. Build full god-ray volumetrics
14. Build energy floor decal that reacts to boss phase
15. Build cinematic camera spots for intro pan
16. Build cinematic camera spots for outro
17. Add ambient SFX bed (massive distant choir)
18. Add boss-arrival SFX cue
19. Build destructible pillar set for phase 2
20. Build floor crack reveal for phase 3
21. Build outer balcony / observers
22. Add audience NPC silhouettes (recruited NPCs watching)
23. Add reactive applause/cheer SFX
24. Build trophy display alcoves
25. Build hidden secret behind throne
26. Build entry door dramatic open animation
27. Add particle storm for phase transitions
28. Validate readability with boss + Globbler in frame
29. Test navmesh including arena hazards
30. Optimize draw calls
31. Build LOD chain
32. Bake lightmaps with cinematic quality
33. Polish material hierarchy at hero level
34. Render trailer-grade hero shots from multiple angles
35. Add wind/cape physics from arena center
36. Build outro: sanctum floods with light when boss dies
37. Build chest spawn pedestal with cinematic
38. Add floor inscription decals
39. Add ambient particle drift toward player
40. Build skybox / backdrop visible through arena openings
41. Tune fog volume
42. Validate lighting under all 3 boss phases
43. Add reactive crowd ambient SFX
44. Build "memorial" variant after boss is killed (persists in save)
45. Add reflection probes
46. Add post-process bloom tuned for arena
47. Render boss-fight reference video for trailer cuts
48. Document sanctum bible
49. Add particle system for victory celebration confetti
50. Commit `epic-18: boss sanctum complete`

---

## Epic 19 — PBR Lighting & Atmosphere Overhaul

1. [x] Audit current lighting setup across all scenes
2. [x] Define PBR material baseline (correct albedo ranges, metallic 0/1, roughness varied)
3. [x] Re-validate every existing material against PBR baseline
4. Set up Reflection Probes per major area
5. Bake lightmaps for town
6. Bake lightmaps per dungeon biome
7. [x] Build day-night cycle lighting curves
8. [x] Set up directional sun light with cascade shadows
9. [x] Tune shadow distance and bias
10. [x] Build SSAO settings per environment
11. [x] Build SSR settings for water + reflective floors
12. [x] Tune SDFGI for indirect bounce
13. [x] Build volumetric fog per environment preset
14. [x] Set up godray volumetrics for sun shafts
15. [x] Tune bloom thresholds per environment
16. [x] Tune tonemapper (Filmic) per environment
17. [x] Set up color grading LUTs per environment
18. [x] Build "danger" lighting state for combat rooms
19. [x] Build "safe" lighting state for hubs
20. [x] Build "story" lighting state for cinematic moments
21. [x] Add light flicker components for ambience
22. [x] Add light pulse components for reactive states
23. [x] Build emissive intensity tuning system
24. Add area lights for windows/lamps
25. Tune indoor lighting for tavern/forge/archive interiors
26. Build firefly/data-mote particle ambient lights
27. Add light cookies for window patterns
28. Validate every scene under 5 environment presets
29. [x] Test perf budget for SDFGI on midspec hardware
30. [x] Build fallback lighting profile for low-end
31. [x] Add dynamic time-of-day in town
32. [x] Add weather darkening modifier
33. [x] Validate shadow softness on character
34. [x] Tune subsurface light contribution on Globbler
35. [x] Add per-material rim light contribution
36. [x] Build skybox per environment (town day, town night, dungeon)
37. Add cloud layer to town sky
38. Build aurora-style sky for late-game iterations
39. Validate sky reflection in water
40. [x] Build "iteration shift" lighting transition for narrative beats
41. Render hero lighting comparison shots (before/after)
42. [x] Tune final intensity ratios so nothing blows out
43. [x] Validate readability of player in all lighting
44. Validate readability of enemies in all lighting
45. Validate UI legibility in all lighting
46. Add light pollution glow over town visible from wilderness
47. Add ambient bird/insect spawners tied to time of day
48. [x] Performance-profile final lighting cost
49. [x] Document lighting bible
50. Commit `epic-19: PBR lighting overhaul complete`

---

## Epic 20 — Shader Library (Water, Glitch, Hologram, Dissolve)

1. [x] Build PBR water shader with normals + foam
2. [x] Add water depth-fade
3. [x] Add water shore foam
4. Add water reflection capture
5. [x] Add water flow direction map
6. [x] Add water caustics decal
7. [x] Build glitch displacement shader
8. [x] Add glitch chromatic aberration
9. [x] Add glitch color shift bands
10. [x] Build hologram shader with scanlines
11. [x] Add hologram fresnel edge glow
12. [x] Add hologram flicker
13. [x] Build dissolve shader for enemy deaths
14. [x] Add dissolve edge emissive
15. [x] Add dissolve noise mask variants
16. [x] Build force-field bubble shader
17. [x] Build energy shield bubble variant
18. [x] Build portal swirl shader
19. [x] Build laser beam shader
20. [x] Build chain lightning shader
21. [x] Build fire particle shader
22. [x] Build ice freeze shader
23. [x] Build poison overlay shader
24. [x] Build burn overlay shader
25. [x] Build wet overlay shader
26. [x] Build snow accumulation shader
27. [x] Build rain wetness shader
28. [x] Build vertex wind shader for vegetation
29. [x] Build vertex wobble shader for slimes
30. [x] Build cloth simulation shader for capes
31. [x] Build hair card shader
32. [x] Build subsurface skin shader
33. [x] Build emissive pulse shader
34. [x] Build screen-space damage vignette shader
35. [x] Build heat distortion shader
36. [x] Build refraction shader for glass
37. [x] Build cell-shading toon ramp option
38. [x] Build outline post-process shader
39. [x] Build rim-light material shader
40. [x] Build dust particle shader
41. [x] Build smoke particle shader
42. [x] Build energy aura shader
43. [x] Build mind-control swirl shader
44. [x] Build slow-mo time distortion shader
45. [x] Build crit hit chromatic flash shader
46. [x] Build damage number outline shader
47. [x] Document every shader in shader bible
48. Validate all shaders work on midspec hardware
49. [x] Build shader hot-reload tool for iteration
50. Commit `epic-20: shader library complete`

---

# PILLAR 2 — WORLD EXPANSION (E21–E30)

---

## Epic 21 — Town Districts: 5 Distinct Zones

1. [x] Design district 1: Residential District (homes, gardens, quiet)
2. [x] Design district 2: Market District (shops, stalls, busy)
3. [x] Design district 3: Commons District (tavern, archive, social)
4. [x] Design district 4: Workshop District (forge, lab, industrial)
5. [x] Design district 5: Docks District (water edge, boats, exotic goods)
6. Block out Residential District layout (4x larger than current town)
7. Block out Market District layout
8. Block out Commons District layout
9. Block out Workshop District layout
10. Block out Docks District layout
11. Place hero buildings from Epic 11 in their districts
12. Populate with modular fillers from Epic 12
13. Build paths connecting districts
14. Build district-archway entry markers
15. [x] Add district-specific ambient SFX
16. Add district-specific particle ambient
17. [x] Add district-specific NPC residents
18. [x] Add district name signage
19. [x] Build district map UI
20. [x] Hook fast-travel between districts
21. [x] Add district-specific lighting profile
22. [x] Add district-specific music
23. [x] Validate scale: walk time across town is 2-3 minutes
24. Validate readability of district boundaries
25. [x] Add district-specific quest hubs
26. Build Residential gardens with farm patches
27. Build Market stall props with rotating inventory
28. Build Commons gathering plaza with benches
29. Build Workshop active forge with VFX
30. Build Docks with water, boats, fishing spots
31. Add water shader to Docks
32. Add boat dock interaction
33. [x] Add district-specific weather variations
34. [x] Add district-specific day/night transitions
35. Build connecting bridges between districts
36. Build elevation changes (Workshop is on a hill, Docks at sea level)
37. Validate navmesh across full town
38. Optimize draw calls per district
39. Bake lightmaps per district
40. Add ambient wildlife per district
41. [x] Place all 12 NPCs in their home districts
42. Add district-specific lore objects
43. Build town hall central plaza connecting all districts
44. Add fountains, statues, monuments
45. Add seasonal decoration support
46. Validate full town walking tour
47. Render aerial overview shot of full town
48. Render hero shots per district
49. [x] Document town bible
50. Commit `epic-21: 5 town districts complete`

---

## Epic 22 — Town Sub-Areas & Hidden Spots

1. [x] Design sub-area 1: Outskirts (transition to wilderness)
2. [x] Design sub-area 2: Cliffs (overlook the world)
3. [x] Design sub-area 3: Hidden Cave (secret quest hub)
4. [x] Design sub-area 4: Sage's Garden (private)
5. [x] Design sub-area 5: Iteration Memorial (somber)
6. [x] Design sub-area 6: Underground Lounge
7. [x] Design sub-area 7: Tower Top
8. [x] Design sub-area 8: Old Ruins (pre-game lore)
9. Build Outskirts terrain + foliage (Blender)
10. Build Cliffs with view skybox (Blender)
11. Build Hidden Cave interior (Blender)
12. Build Sage's Garden with unique flora (Blender)
13. Build Memorial with cenotaph (Blender)
14. Build Underground Lounge interior (Blender)
15. Build Tower Top with rooftop view (Blender)
16. Build Old Ruins (Blender)
17. Add unique props per sub-area (Blender)
18. Add unique lighting per sub-area (Blender)
19. [x] Add unique ambient SFX per sub-area (data-driven via database)
20. [x] Hide entrances behind exploration puzzles (gate system)
21. [x] Add discovery reward per sub-area (8 unique rewards in DB)
22. [x] Hook story moments to sub-areas (iteration_gate field)
23. [x] Add NPCs that only appear in sub-areas (npcs_found_here)
24. [x] Add sub-area to map after discovery (WorldMapManager hook)
25. Add fast-travel waypoints (deferred to scene)
26. Validate scale and walk distances (deferred to scene)
27. [x] Add per-area secret collectibles (lore_tablets in Old Ruins reward)
28. [x] Add sub-area lore tablets (lore_plaque field)
29. Add atmospheric particles per area (deferred to scene)
30. Tune lighting per area (deferred to scene)
31. Render hero shot per sub-area (Blender)
32. [x] Hook ambient music per sub-area (music_track field)
33. [x] Add wildlife spawners per area (AmbientLifeSpawner: swarms, formations, calls) (deferred)
34. [x] Add reactive day/night cycle elements (PhaseReactiveProp drop-in) (deferred)
35. Validate navmesh (deferred)
36. Bake lighting (deferred)
37. Optimize draw calls (deferred)
38. [x] Add weather response per area (parent_region inherits weather)
39. Add cinematic camera spots (deferred)
40. [x] Hook discovery achievement ("Wanderer", "Lost Places")
41. [x] Build hidden quest hooks (faction_unlock reward type)
42. Add per-area visual signature element (Blender)
43. Validate readability (deferred)
44. [x] Add sub-area names with discovery cinematic (SubAreaTrigger timeline)
45. Build seasonal variants if applicable (deferred)
46. Add ambient creature variants (deferred)
47. Add unique Cache Sprite spawn per area (deferred)
48. Test all sub-areas in single play session (deferred)
49. [x] Document sub-area bible
50. [x] Commit `epic-22: town sub-areas systems landed`

---

## Epic 23 — Open Wilderness Zone (Between Town & Dungeons)

1. [x] Design wilderness zone: river, forest, ruins, dungeon entrances
2. Build heightmap terrain at large scale (Blender)
3. Sculpt river course (Blender)
4. [x] Build river water with flow shader
5. Sculpt cliff walls (Blender)
6. Place forest vegetation density (Blender)
7. Build clearing variants ×6 (Blender)
8. Build ruin prop set (Blender)
9. Place ruin clusters (Blender)
10. Build wilderness path network (Blender)
11. Add path signposts (Blender)
12. [x] Place wilderness NPC encounters (database + manager + 5 wandering events)
13. [x] Add wilderness wildlife (13 critters, region/phase/weather-aware spawner)
14. [x] Add wilderness enemy spawns (6 hostile types, exclusion-aware spawner)
15. [x] Build wilderness ambient SFX (6 region beds, slot-aware crossfade mixer)
16. [x] Build wilderness ambient music (4-layer stack: base+region+combat+weather)
17. [x] Add weather variation (6 wilderness region profiles + region debounce)
18. [x] Add day/night cycle (24 wilderness lighting presets, 6 regions × 4 phases)
19. [x] Build hidden grove side area (data side; Blender build deferred)
20. [x] Build hidden lake side area (data side; Blender build deferred)
21. [x] Build hidden cave side area (already in SubAreaDatabase from epic 22)
22. [x] Place dungeon entrances ×4 (Four Mouths anchored at wild_cliffs)
23. Build dungeon entrance hero monuments (Blender)
24. [x] Add fast-travel waypoints (7 wilderness waypoints, manager, trigger)
25. [x] Build wilderness map UI (regions, landmarks, waypoints, entrances, player dot)
26. [x] Add discovery rewards per landmark (9 landmarks, manager, waypoint hookup)
27. [x] Hook story trigger zones (8 one-shot story beats across the 9 iterations)
28. [x] Build wilderness shrine that provides buffs (9 buffs, 4 tiers, daily offering)
29. [x] Build resource gathering nodes (8 node types, harvest + respawn component)
30. [x] Add fishing spots (FishingResolver wrapping 15-fish DB + bait weighting + spot component)
31. [x] Add foraging spots (6 region tables, luck-biased roll, skill-gated rares)
32. [x] Build campsite prop with rest function (cinematic + heal + buff + herb pulse)
33. [x] Add ambient bird/insect spawners (AmbientLifeSpawner: swarms, formations, calls)
34. [x] Add ground decals for wear (10 decal types, path + region scatter, weather reactive)
35. Validate scale: 5x current dungeon room size (scene-bake; deferred)
36. Optimize draw calls + LODs (scene-bake; deferred)
37. Bake lighting (scene-bake; deferred)
38. [x] Add lighting variation per region (24 presets via WildernessLightingDirector)
39. [x] Add fog volume per region (10 region fog volumes, phase + weather modulated)
40. [x] Add weather particles (code-built GPUParticles3D follower for 5 weathers)
41. [x] Add wind direction variance (WindDirector + global shader params + region mults)
42. Validate navmesh on slopes and around obstacles (scene-bake; deferred)
43. [x] Add cinematic camera reveal shots (7 landmark reveals + manager + trigger)
44. Render hero shots (Blender)
45. [x] Hook wilderness encounter system (WandererNPCManager + 5 events)
46. [x] Add reactive enemy alerts (4 social profiles, type-filtered chain broadcast)
47. [x] Add wandering NPC events (5 events in WildernessEncounterDatabase)
48. Test wilderness traversal end-to-end (scene-bake; deferred)
49. [x] Document wilderness bible
50. [x] Commit `epic-23: wilderness zone complete` (35/50 system side, 15 Blender/scene-bake deferred)

---

## Epic 24 — Multiple Dungeon Entrances & Biome Selection

1. [x] Design entrance 1: Server Room portal (cold tech)
2. [x] Design entrance 2: Memory Vaults portal (gold archaic)
3. [x] Design entrance 3: Corrupted Wilds portal (organic)
4. [x] Design entrance 4: Final Vault portal (locked till conditions)
5. Build entrance 1 monument + portal VFX (Blender)
6. Build entrance 2 monument + portal VFX (Blender)
7. Build entrance 3 monument + portal VFX (Blender)
8. Build entrance 4 monument + portal VFX (Blender)
9. [x] Hook entrance scene transitions
10. [x] Add entrance lore plaques
11. [x] Add entrance difficulty indicator
12. [x] Add entrance recommended-level UI
13. [x] Add entrance chosen-biome confirmation
14. [x] Add per-entrance loading screen art (database + themed UI controller)
15. [x] Build dungeon selection map screen
16. [x] Hook dungeon selection to FloorManager
17. [x] Add daily-bonus rotating biome
18. [x] Add story-locked entrance reveals
19. [x] Add visual "this entrance has been cleared" markers
20. [x] Add cleared-count tracker per entrance
21. [x] Add boss-defeated trophy at each entrance
22. [x] Add per-entrance music sting
23. [x] Add per-entrance ambient particles (4 themed profiles + presence-gated component)
24. Validate readability (scene-bake; deferred)
25. [x] Add entrance interaction prompt
26. [x] Hook to fast-travel from town
27. Validate all 4 entrances transition properly (scene-bake; deferred)
28. [x] Build entrance "first time" cinematic per biome
29. [x] Build entrance "return" idle cinematic (4 idles, no-letterbox brief flourishes)
30. [x] Add entrance NPC guide/warden (4 wardens with dialogue, shop, schedule)
31. [x] Add ambient SFX per entrance (4 close-up SFX beds, 4 layers each)
32. [x] Polish entrance lighting (3-light hero rig per portal: key + rim + pulsing core)
33. Render hero shot per entrance (Blender)
34. Validate against navmesh (scene-bake; deferred)
35. [x] Add entrance day/night appearance variation (per-phase mults on lights + particles)
36. [x] Add entrance weather response (per-(entrance × weather) light + particle mults)
37. [x] Add discovery reward for finding each
38. [x] Add achievement for finding all
39. [x] Add entrance signpost lore
40. [x] Add per-entrance approach path (4 descent paths + biome guide markers + signposts)
41. [x] Add entrance flag/banner decor (4 themed banner pairs with biome emblems)
42. [x] Add entrance reflection probe (4 per-entrance probes with biome ambient bias)
43. [x] Build entrance secret unlock condition
44. Validate scene transitions don't crash (scene-bake; deferred)
45. Test all entrances in one session (scene-bake; deferred)
46. [x] Hook map fast-travel
47. [x] Add entrance audio sting
48. [x] Polish entrance VFX (4 portal energy surfaces with shader + seal overlay + unseal anim)
49. [x] Document entrance bible
50. [x] Commit `epic-24: multiple dungeon entrances complete` (41/50 system, 9 deferred)

---

## Epic 25 — Town Hub Expansion: Underground & Vertical

1. [x] Design underground lounge concept (covered in full hub expansion bible)
2. Build underground lounge scene (Blender)
3. Add lounge furniture props (Blender)
4. [x] Build lounge bar interactive (9 drink specials, daily rotation, story-flag gating)
5. [x] Build lounge stage for music (Sync schedule + spotlight pulse + tip jar)
6. [x] Add lounge NPCs (Cache evening shift + 8 regulars rotating pair per night)
7. [x] Hook lounge dialogue (8 Cache lounge-only confessions, tier-gated)
8. Build tower top scene (Blender)
9. Build tower spiral staircase (Blender)
10. Build tower observation deck (Blender)
11. [x] Add tower telescope interaction (7 targets, phase + iteration gated, lore/buff/title/countdown reveals)
12. [x] Build tower ambient lighting (4-phase rig + star field + wind whip particles)
13. Build sage's tower study room (Blender)
14. Build sage's library (Blender)
15. [x] Add archive crystal interactions (4 sections + 9 sage journal + 9 forgotten index)
16. Build training arena hub area (Blender)
17. [x] Add target dummies (6 archetypes + DPS window + stagger meter)
18. [x] Add training reset functionality (lever + leaderboard with personal bests)
19. Build farm plot area (Blender)
20. [x] Add planting interaction (FarmPlotInteractable wrapper + state-aware action picker)
21. [x] Add harvesting interaction (floating popup with quality tier + drops + XP + crown celebration)
22. Build fishing dock at water (Blender)
23. [x] Add fishing rod prop + animation (cast/wait/bite/reel state machine + line rendering)
24. Build cooking station (Blender)
25. [x] Add cooking interaction (10 recipes across 3 tiers + station with starter book + unlock hooks)
26. Build crafting workshop area (Blender)
27. [x] Add crafting station interactions (forge/bench/shaper + iteration upgrade tiers)
28. Build pet hutch area (Blender)
29. [x] Add pet feeding interaction (4-slot trough + per-pet hunger + decay + bonus)
30. Build memorial gallery (Blender)
31. [x] Add iteration memorial plaques (9 alcoves with unseal animation + lore paragraphs)
32. Build trophy display hall (Blender)
33. [x] Add trophy mount points (12 mounts: 6 boss heads + 3 rare fish + 3 hidden treasures)
34. Build wardrobe room (Blender)
35. [x] Add wardrobe interaction (mirror + 8 mannequins + chest + dye station)
36. Build "hub of mysteries" room with secrets (Blender)
37. [x] Add hidden door puzzles (5-book sequence puzzle hinted by 5 lore tablets)
38. [x] Build hidden treasure room (chest interaction + 3 bible rewards + cinematic; room scene Blender)
39. [x] Add new fast-travel points (17 hub points + reactive unlock manager)
40. [x] Validate all hub additions tie to systems (validator script + audit report; PASS)
41. Render hero shots per area (Blender)
42. Optimize draw calls (scene-bake; deferred)
43. Bake lighting (scene-bake; deferred)
44. [x] Hook ambient SFX (14 hub space soundscapes consumed by AmbientSoundscapeMixer)
45. [x] Hook ambient music transitions (HubMusicDirector + 21 new tracks + first-entry stings)
46. Validate navmesh throughout (scene-bake; deferred)
47. Test full hub traversal (scene-bake; deferred)
48. [x] Add map markers for new areas (HubMapPanel + filter dropdown + live unlock updates)
49. [x] Document hub expansion bible (covered by task 1)
50. [x] Commit `epic-25: hub expansion complete` (37/50 system, 13 Blender/scene-bake deferred)

---

## Epic 26 — Day/Night Cycle System

1. [x] Design day/night cycle: 24 minutes real-time = 1 in-game day
2. [x] Build sun directional light orbit animation
3. [x] Build moon directional light alternate
4. [x] Build skybox interpolation between presets
5. [x] Build dawn skybox preset (SkyboxPresetDatabase)
6. [x] Build noon skybox preset (SkyboxPresetDatabase)
7. [x] Build dusk skybox preset (SkyboxPresetDatabase)
8. [x] Build night skybox preset (SkyboxPresetDatabase)
9. [x] Build night with moon variant (SkyboxPresetDatabase)
10. [x] Build cloudy variant (SkyboxPresetDatabase)
11. [x] Build storm variant (SkyboxPresetDatabase)
12. [x] Hook lighting tint to time
13. [x] Hook fog density to time
14. [x] Hook ambient SFX shift to time
15. [x] Hook NPC schedules to time
16. [x] Hook enemy spawn variation to time
17. [x] Build "night enemies" stronger at night
18. [x] Hook player buffs to time of day
19. [x] Build star particle layer for night (global NightSkyStarField, camera follow, skybox preset visibility)
20. [x] Build moon position animation
21. [x] Build light cookie clouds drifting (CloudCookieDrifter wind + weather coverage)
22. [x] Add ambient bird SFX in day (AmbientWildlifeSoundLayer day side)
23. [x] Add ambient cricket SFX at night (AmbientWildlifeSoundLayer night side)
24. [x] Build window-light flicker on at dusk (DuskLight CANDLE mode)
25. [x] Build street lamp light on at dusk (DuskLight NONE mode)
26. Build NPC bedtime animations
27. Build NPC wake-up animations
28. [x] Hook quest gating to time of day
29. [x] Build "sleep till morning" interaction
30. [x] Add "sleep till night" interaction
31. [x] Build pause-time menu option
32. [x] Add time UI clock display
33. [x] Add day counter display
34. [x] Hook save system to persist time
35. Build time-of-day skip cinematic
36. [x] Validate lighting transitions are smooth
37. [x] Validate perf with continuous time updates
38. [x] Build time-locked content (some NPCs only visible at certain hours)
39. [x] Add daily reset triggers
40. [x] Hook daily quests
41. [x] Build night-only enemies
42. [x] Build night-only loot
43. Render time-of-day comparison shots
44. Validate against all environments
45. [x] Add time sync between scenes
46. [x] Hook EventBus signals for time events
47. Add cinematic dawn breaking sequence
48. Add cinematic sunset sequence
49. [x] Document day/night bible
50. Commit `epic-26: day/night cycle complete`

---

## Epic 27 — Weather System

1. [x] Design weather types: clear, cloudy, rain, storm, fog, glitch storm
2. [x] Build clear preset
3. [x] Build cloudy preset
4. [x] Build rain preset with particle system
5. [x] Build rain shader (wet ground)
6. Build rain ripple decals
7. [x] Build storm preset (rain + wind + lightning)
8. [x] Build lightning flash post-process
9. [x] Build fog preset with dense volumetric
10. [x] Build glitch storm preset (digital corruption visual)
11. [x] Build wind direction system
12. [x] Hook foliage wind shader to wind direction
13. [x] Hook particle drift to wind direction
14. [x] Build wind audio variation
15. [x] Build rain audio loop
16. [x] Build thunder SFX random triggers
17. [x] Build storm SFX bed
18. [x] Build glitch storm SFX
19. [x] Build weather transition system (smooth interpolation)
20. [x] Hook weather to time of day patterns
21. [x] Build per-zone weather defaults
22. [x] Build per-iteration weather changes (later iterations have more glitch storms)
23. [x] Add weather UI indicator
24. [x] Hook weather to combat (rain affects fire damage, etc)
25. [x] Add weather-locked content
26. [x] Add reactive NPC dialogue about weather
27. [x] Add NPC indoor refuge during storms
28. Build umbrella prop / accessory
29. Build cloak weather wear visual
30. [x] Hook player wet/dry shader
31. [x] Add puddles forming during rain
32. [x] Add fog draw distance reduction
33. [x] Build sun shafts during clear weather
34. Build rainbow after rain rare event
35. [x] Add weather particle perf budget
36. [x] Build low-spec fallback weather
37. [x] Validate weather under day and night
38. [x] Add seasonal weather patterns
39. [x] Hook fishing bonus during certain weather
40. [x] Add weather radar UI for predictions
41. [x] Validate weather doesn't break combat readability
42. Render weather showcase shots
43. [x] Add reactive enemy behaviors per weather
44. [x] Hook weather to save state
45. Add cinematic storm rolling in
46. [x] Validate transitions are smooth
47. [x] Add ambient lightning for storms
48. [x] Document weather bible
49. [x] Performance test all weather types
50. Commit `epic-27: weather system complete`

---

## Epic 28 — World Map & Fast Travel

1. [x] Design world map UI layout
2. Sketch hand-drawn map style reference
3. Render world map background art
4. [x] Build map UI scene with pan/zoom
5. [x] Add region markers
6. [x] Add fast-travel point markers
7. [x] Add quest markers
8. [x] Add player current-position marker
9. [x] Add visited/unvisited fog of war
10. [x] Hook map open/close keybind
11. [x] Add map legend
12. [x] Add region detail tooltips
13. [x] Add fast-travel confirmation dialog
14. [x] Build fast-travel cinematic transition
15. [x] Hook to actual scene loading
16. [x] Add map state save/load
17. [x] Add discovery animations when new region found
18. Add hand-drawn style icons for landmarks
19. Add region name typography
20. Build animated map elements (waving flags, smoke)
21. [x] Add per-region weather indicator on map
22. [x] Add NPC location markers
23. [x] Add quest objective markers
24. [x] Build mini-map HUD overlay
25. [x] Hook mini-map to player position
26. [x] Add mini-map north indicator
27. [x] Add mini-map enemy radar
28. [x] Add mini-map interactable highlights
29. [x] Build "compass" heading display
30. [x] Add waypoint placement system
31. [x] Hook waypoint navigation arrow
32. [x] Build map filtering options
33. [x] Add map note placement (player annotations)
34. [x] Save player notes
35. [x] Add region completion percentages
36. [x] Add achievement indicators on map
37. [x] Add lore unlock markers
38. [x] Add hidden room discovery markers
39. Polish map illustration art
40. [x] Add map music sting
41. [x] Validate map UX with 30+ markers
42. [x] Add scrollbar for marker list
43. [x] Build search filter for markers
44. [x] Add per-iteration map evolution (revealed details)
45. Render hero shot of full discovered map
46. [x] Validate against all zones
47. Hook map to controller navigation
48. Add tutorial for first-time map open
49. [x] Document map bible
50. Commit `epic-28: world map & fast travel complete`

---

## Epic 29 — Procedural Dungeon Generation v2

1. [x] Audit current dungeon generation approach
2. [x] Design v2: hand-crafted "anchor" rooms + procedural connectors
3. [x] Build room library per biome with metadata tags
4. [x] Build connector library per biome
5. [x] Build generation algorithm: pick anchors, weave connectors, validate
6. [x] Add seed system for reproducible runs
7. Build navmesh stitching across generated layouts
8. [x] Add room rotation/mirror for variety
9. [x] Add room density tuning per floor
10. [x] Add encounter density tuning per floor
11. [x] Add loot density tuning per floor
12. [x] Build room tag system: combat, loot, story, secret, elite, boss
13. [x] Hook generation to biome selection
14. [x] Validate every generated layout has a path to boss
15. [x] Add fail-safe regenerate if invalid
16. [x] Build secret room placement (5% chance per layout)
17. [x] Build elite room placement (1 per floor)
18. [x] Build loot room placement (1 per floor)
19. [x] Build story room placement (1 per floor)
20. Build environmental hazard placement
21. Build prop placement variation
22. Add ambient enemy patrol patterns
23. Add destructible object placement
24. Add lore object placement
25. Build lighting placement based on room tag
26. Add reflection probe placement
27. [x] Validate perf with full generation
28. Build minimap from generated layout
29. Hook minimap to player exploration
30. Reveal map as player walks
31. Add room name labels
32. Add room transition fades
33. [x] Add per-floor difficulty escalation
34. [x] Validate all 4 biomes generate properly
35. [x] Build "themed" generation for special story floors
36. Add room enter/exit triggers
37. Hook EventBus signals for room events
38. [x] Validate save/load mid-run
39. Add cinematic for first time entering a new biome
40. Add per-room ambient SFX
41. Add per-room particle accents
42. Polish room transitions
43. Validate navmesh on dynamic layouts
44. Add ambient creature spawners per biome
45. [x] Test 50 generated runs for stability
46. [x] Build seed-share system (share generated runs)
47. [x] Document generation bible
48. Render gallery of varied generated layouts
49. [x] Optimize draw calls per generated room
50. Commit `epic-29: dungeon generation v2 complete`

---

## Epic 30 — Massive Dungeon Floors (10x Current Size)

1. Design floor 1 layout (hand-crafted hub-and-spoke)
2. Design floor 2 layout (hand-crafted multi-level)
3. Design floor 3 layout (hand-crafted maze)
4. Design floor 4 layout (hand-crafted boss approach)
5. Design floor 5 layout (hand-crafted boss arena)
6. Block out floor 1 in editor at scale
7. Block out floor 2
8. Block out floor 3
9. Block out floor 4
10. Block out floor 5
11. Detail floor 1 with biome props
12. Detail floor 2 with biome props
13. Detail floor 3 with biome props
14. Detail floor 4 with biome props
15. Detail floor 5 with biome props
16. Add encounter spawners floor 1
17. Add encounter spawners floor 2
18. Add encounter spawners floor 3
19. Add encounter spawners floor 4
20. Add boss encounter floor 5
21. Add loot rooms (3 per floor)
22. Add secret rooms (2 per floor)
23. Add story rooms (1 per floor)
24. Add elite encounters (2 per floor)
25. Add environmental hazards (5 per floor)
26. Add destructibles
27. Add lore objects
28. Add interactive props
29. Bake lighting per floor
30. Bake navmesh per floor
31. Validate every room has navmesh
32. Validate boss arena from Epic 18 hooks here
33. Tune floor traversal time to ~10 minutes per floor
34. Add ambient SFX zones
35. Add ambient music transitions
36. Add per-room camera tweaks if needed
37. Add per-room reflection probes
38. Optimize draw calls
39. Build LOD chains
40. Polish material consistency
41. Add cinematic camera spots
42. Validate readability throughout
43. Test full 5-floor run twice
44. Render hero shots per floor
45. Add floor name displays
46. Add floor difficulty banners
47. Hook floor save/load
48. Validate elevator/portal transitions
49. Document floor design bible
50. Commit `epic-30: 5 massive floors complete`

---

# PILLAR 3 — GAMEPLAY DEPTH (E31–E45)

---

## Epic 31 — Class System (3 Specializations)

1. [x] Design class 1: Compiler — balanced melee+ranged
2. [x] Design class 2: Daemon — fast assassin
3. [x] Design class 3: Kernel — tank/control
4. [x] Write class bible with stat baselines
5. [x] Build class selection UI
6. Hook class selection at character creation
7. [x] Build class-specific starting stats
8. [x] Build class-specific starting modules
9. Build class-specific visual variant of Globbler
10. Build class-specific HUD theme
11. [x] Build class-specific ability cooldowns
12. Hook class to AbilityManager
13. [x] Add class swap unlocked at iteration 3
14. [x] Add respec system
15. [x] Build respec NPC in town
16. Add class-specific dialogue options
17. Add class-specific quest hooks
18. [x] Build class progression milestones
19. [x] Build class-specific passives
20. [x] Hook class to damage type bonuses
21. [x] Add class signature ability ×3
22. [x] Add class ultimate ability ×3
23. Animate class signatures
24. Animate class ultimates
25. Add class-specific death anim variants
26. Add class-specific level-up effects
27. [x] Hook class to save data
28. [x] Add class swap UI
29. Build class tutorial flow
30. Add class info screen
31. Add class lore tab
32. Render class hero portraits
33. Add class flavor music sting
34. [x] Hook EventBus class signals
35. Validate class balance across floors
36. Test each class through full demo run
37. Polish class-specific VFX
38. Add class achievement triggers
39. Hook class to leaderboards (future)
40. Build class quick-swap loadouts
41. Validate UI for class switching
42. Add class bonus stat displays
43. [x] Hook to inventory class restrictions
44. [x] Add class restricted items
45. [x] Add class shared items
46. Build class community rankings (placeholder)
47. Render class showcase video
48. [x] Document class bible
49. Test new game with each class
50. Commit `epic-31: class system complete`

---

## Epic 32 — Skill Tree (50+ Nodes Per Class)

1. [x] Design skill tree topology (hub-and-spoke vs chain vs grid)
2. [x] Sketch tree layout for Compiler class
3. [x] Sketch tree layout for Daemon class
4. [x] Sketch tree layout for Kernel class
5. [x] Define 50 nodes for Compiler tree
6. [x] Define 50 nodes for Daemon tree
7. [x] Define 50 nodes for Kernel tree
8. [x] Build skill tree UI with pan/zoom
9. Render skill node icons (50 per class = 150 icons)
10. [x] Hook skill point allocation
11. [x] Add skill point earn from level-up
12. [x] Add skill point earn from milestones
13. [x] Build skill node prerequisites validation
14. [x] Build refund/respec system
15. [x] Add visual highlight for available nodes
16. [x] Add lock/unlock state visual
17. [x] Add tooltip with full description
18. [x] Add stat preview when hovering
19. [x] Build keystone "major" nodes with bigger effects
20. [x] Add 5 keystone nodes per class
21. [x] Implement Compiler nodes 1-25 effects in code
22. Implement Compiler nodes 26-50 effects in code
23. [x] Implement Daemon nodes 1-25 effects in code
24. Implement Daemon nodes 26-50 effects in code
25. [x] Implement Kernel nodes 1-25 effects in code
26. Implement Kernel nodes 26-50 effects in code
27. [x] Hook node effects to combat pipeline
28. [x] Build skill tree save/load
29. Validate node math doesn't break balance
30. Add skill tree open/close anim
31. Hook skill tree to character menu
32. Add tree theme per class
33. Add particle effects on node activation
34. Add SFX on allocate
35. Build skill tree tutorial
36. Add skill tree summary view
37. [x] Add build sharing (export/import codes)
38. [x] Build preset builds (3 per class)
39. [x] Add preset apply button
40. Hook achievements to tree completion
41. Validate UI on different screen sizes
42. Add controller navigation
43. Polish tree art
44. Render hero shot of fully unlocked tree
45. Test full builds through demo
46. Validate respec works mid-run
47. [x] Add respec cost (compute or item)
48. Add new node tutorial popup
49. [x] Document skill tree bible
50. Commit `epic-32: skill tree complete`

---

## Epic 33 — Module Library Expansion (40 Abilities)

1. [x] List existing modules
2. [x] Design 8 new Compiler modules
3. [x] Design 8 new Daemon modules
4. [x] Design 8 new Kernel modules
5. [x] Design 8 universal modules
6. [x] Design 8 ultimate modules
7. [x] Implement Compiler module 1 with VFX
8. [x] Implement Compiler module 2 with VFX
9. [x] Implement Compiler module 3 with VFX
10. [x] Implement Compiler module 4 with VFX
11. [x] Implement Compiler module 5 with VFX
12. [x] Implement Compiler module 6 with VFX
13. [x] Implement Compiler module 7 with VFX
14. [x] Implement Compiler module 8 with VFX
15. [x] Implement Daemon module 1 with VFX
16. [x] Implement Daemon module 2 with VFX
17. [x] Implement Daemon module 3 with VFX
18. [x] Implement Daemon module 4 with VFX
19. [x] Implement Daemon module 5 with VFX
20. [x] Implement Daemon module 6 with VFX
21. [x] Implement Daemon module 7 with VFX
22. [x] Implement Daemon module 8 with VFX
23. [x] Implement Kernel module 1 with VFX
24. [x] Implement Kernel module 2 with VFX
25. [x] Implement Kernel module 3 with VFX
26. [x] Implement Kernel module 4 with VFX
27. [x] Implement Kernel module 5 with VFX
28. [x] Implement Kernel module 6 with VFX
29. [x] Implement Kernel module 7 with VFX
30. [x] Implement Kernel module 8 with VFX
31. [x] Implement universal modules 1-4
32. [x] Implement universal modules 5-8
33. [x] Implement ultimate modules 1-4
34. [x] Implement ultimate modules 5-8
35. Render module icons (40)
36. [x] Add module tooltips
37. [x] Hook module animations to Globbler rig
38. [x] Tune module damage/cost balance
39. [x] Add module SFX hooks
40. Hook module pickups in dungeons
41. [x] Add module rarity tiers
42. [x] Add modular affix system on modules
43. [x] Hook to InventoryComponent
44. Validate module loadout UI
45. [x] Add module loadout presets
46. [x] Hook hotbar to modules
47. Test full module loadouts in combat
48. Render showcase video
49. [x] Document module bible
50. Commit `epic-33: 40 modules complete`

---

## Epic 34 — Crafting System

1. [x] Design crafting bible: recipes, materials, stations
2. [x] Design 20 crafting materials
3. Render material icons
4. [x] Build material drop system from enemies
5. [x] Build material gather system from environment
6. Build crafting station prop variants
7. Place crafting stations in town districts
8. [x] Build crafting UI
9. [x] Hook recipe list
10. [x] Define 30 module recipes
11. [x] Define 20 prompt recipes
12. [x] Define 15 chip recipes
13. [x] Define 10 protocol recipes
14. [x] Define 10 cosmetic recipes
15. [x] Implement recipe ingredient checking
16. [x] Implement craft button + animation
17. Add craft success VFX
18. Add craft failure VFX
19. [x] Hook to inventory output
20. [x] Add recipe unlock system
21. [x] Add recipe discovery from drops
22. [x] Add recipe discovery from NPCs
23. [x] Add recipe discovery from quests
24. [x] Build recipe book UI
25. [x] Add favorite recipes
26. [x] Add recipe filtering
27. Add craft queue
28. Add bulk craft option
29. [x] Add material preview
30. [x] Hook to save data
31. [x] Add station upgrades
32. Add station appearance per upgrade
33. Add resource node respawning
34. Add gathering tool requirements
35. Build ore deposit prop
36. Build wood gather prop
37. Build herb gather prop
38. Build fish catch system
39. Build cooking system
40. Build smelting system
41. Build alchemy system
42. [x] Add station ambient SFX
43. [x] Add station ambient particles
44. Hook stations to NPC interactions (NPC crafts FOR you)
45. [x] Add achievement triggers for crafting milestones
46. Validate crafting balance vs loot drops
47. Test full recipe pipeline
48. Render hero shot of crafting station
49. [x] Document crafting bible
50. Commit `epic-34: crafting system complete`

---

## Epic 35 — Farming & Gathering Systems

1. [x] Design farming bible: crops, growth, harvest
2. [x] Design 20 crop types
3. Render crop sprites at growth stages (4 stages each = 80)
4. [x] Build farm plot prop
5. [x] Add till plot interaction
6. [x] Add plant seed interaction
7. [x] Add water plot interaction
8. [x] Add harvest interaction
9. [x] Hook crop growth timer to day/night
10. [x] Add crop withering on neglect
11. [x] Build seed inventory category
12. [x] Add seed shop NPC
13. [x] Add per-crop stat bonus when consumed
14. [x] Add per-crop ingredient role in recipes
15. Build farming UI overlay
16. [x] Add farming tools (hoe, watering can, scythe)
17. [x] Add tool durability
18. [x] Add tool upgrade tiers
19. Build greenhouse interior (Harvest's Greenhouse from Epic 11)
20. [x] Add greenhouse crops (rare seeds)
21. [x] Add fertilizer system
22. [x] Add crop quality tiers
23. Build orchard with fruit trees
24. Add fruit tree growth stages
25. Add wild forage spawn locations in wilderness
26. Add forage collection
27. [x] Add fishing system (basic)
28. [x] Add 15 fish types
29. [x] Add fishing rod tiers
30. [x] Add fishing minigame
31. Build fish tank display in town
32. [x] Add hunting prey (passive wildlife)
33. [x] Add hunting reward materials
34. [x] Hook all gathering to material library (Epic 34)
35. [x] Add seasonal crop variants
36. [x] Add weather-affected gathering
37. [x] Add gathering achievements
38. Add gathering UI tracker
39. Add gathering NPC quests
40. [x] Hook to save data
41. Validate balance
42. Add ambient SFX for gathering
43. Add particle effects for harvest
44. [x] Add level/skill progression for gathering
45. [x] Add gathering skill perks
46. Render hero shot of farm
47. [x] Document farming bible
48. Test full farming loop
49. Add farm decoration items
50. Commit `epic-35: farming & gathering complete`

---

## Epic 36 — Town Building & Decoration

1. [x] Design town building bible: what player can place
2. [x] Design 50 placeable decorations
3. [x] Build placement system (mouse drag, snap-to-grid optional)
4. [x] Build rotation control
5. [x] Build delete control
6. [x] Build move control
7. [x] Add building budget/limit per zone
8. [x] Add buildable zones (player-owned plots)
9. Build plot purchase NPC
10. Render decoration icons (50)
11. Build small decor props ×15
12. Build medium decor props ×15
13. Build large decor props ×10
14. Build interactive decor props ×10
15. Add decor variation colors
16. [x] Build placement preview ghost
17. [x] Add valid/invalid placement feedback
18. [x] Build undo system
19. [x] Add decor save state
20. [x] Add decor inventory
21. Add decor shop NPC
22. [x] Build decor crafting (use crafting system)
23. [x] Add decor unlocks via story
24. Add seasonal decor sets
25. [x] Build "house" upgrade system for player home
26. Build interior decoration mode
27. Build floor/wall painting customization
28. [x] Add furniture set collections
29. [x] Add visitor reactions to decor
30. [x] Add NPC affinity bonus from decor
31. [x] Build photo mode for showing off
32. [x] Add screenshot save
33. Add lighting placement props
34. Add ambient effect props (smoke, fire, water)
35. Hook props to physics (lightweight)
36. Add validation: don't block paths
37. Add navmesh rebuild after placement
38. Build community share placeholder
39. [x] Add building achievement triggers
40. Add decor showcase NPC
41. Build decor showcase area in town
42. Render hero shot of decorated home
43. Add controller support
44. Validate UX with 100+ placed items
45. Performance test
46. [x] Document town building bible
47. Add tutorial flow
48. [x] Test save/load with decorations
49. [x] Add per-iteration decoration evolution
50. Commit `epic-36: town building & decoration complete`

---

## Epic 37 — NPC Affinity & Relationships

1. [x] Design affinity bible: levels, gates, rewards
2. [x] Define 5 affinity levels (Stranger → Friend → Confidant → Bond → Soul-Linked)
3. [x] Build affinity tracker per NPC
4. [x] Define affinity gain triggers (gifts, dialogue, quests)
5. [x] Define gift preferences per NPC (loved, liked, neutral, disliked, hated)
6. [x] Build gift giving interaction
7. Add gift reaction animations
8. Add gift dialogue variants
9. [x] Hook affinity rewards (new dialogue, quests, items)
10. Build affinity UI screen
11. Render affinity heart icons
12. Add affinity progression sound
13. [x] Build per-NPC unique reward unlocks
14. [x] Add NPC backstory dialogue locked behind affinity
15. [x] Add NPC personal quests at higher affinity
16. Build relationship cinematic for max affinity
17. Add NPC visit player home interactions
18. Add player visit NPC home interactions
19. [x] Build NPC-specific gifts
20. [x] Add daily-gift cap
21. [x] Add NPC birthday system
22. Add gift-giving etiquette tutorial
23. [x] Build NPC mood states
24. [x] Hook mood to dialogue
25. [x] Add NPC schedule integration with affinity
26. [x] Add affinity-based merchant discounts
27. [x] Add affinity-based crafting bonuses
28. [x] Add affinity-based quest unlocks
29. [x] Add affinity decay if ignored too long
30. [x] Build "favorite NPC" tracking achievement
31. Add per-NPC affinity hint dialogue
32. Add gift wrap visual on giving
33. Add reactive NPC poses for affinity levels
34. [x] Hook to save data
35. [x] Add achievement triggers
36. [x] Validate against all 12 NPCs
37. [x] Add NPC-NPC relationship layer (some NPCs are friends/rivals)
38. [x] Add NPC group events
39. [x] Build town festival event
40. [x] Build town crisis event
41. [x] Add affinity-locked town events
42. Render hero shots of relationship moments
43. Validate UX with all 12 NPCs maxed
44. Test gift inventory management
45. Tune affinity gain rates
46. Add UX hints for missed gifts
47. [x] Document affinity bible
48. Add affinity history log
49. Validate against story flags
50. Commit `epic-37: NPC affinity complete`

---

## Epic 38 — Quest System v2 (Main + Side + Daily)

1. [x] Design quest bible: types, structure, rewards
2. [x] Build quest data structure
3. Build quest log UI v2
4. Build quest tracker HUD widget
5. [x] Add quest categories: main, side, daily, hidden, faction
6. [x] Build main story quest line (40 quests across 9 iterations)
7. Build side quest pool (60 side quests)
8. [x] Build daily quest generator (10 templates)
9. Build hidden quest triggers (15 secret quests)
10. [x] Add faction quest line (Epic 39)
11. [x] Implement main quest 1-5
12. [x] Implement main quest 6-10
13. [x] Implement main quest 11-15
14. [x] Implement main quest 16-20
15. [x] Implement main quest 21-25
16. [x] Implement main quest 26-30
17. [x] Implement main quest 31-35
18. [x] Implement main quest 36-40
19. Implement side quests 1-10
20. Implement side quests 11-20
21. Implement side quests 21-30
22. Implement side quests 31-40
23. Implement side quests 41-50
24. Implement side quests 51-60
25. [x] Implement daily quest templates
26. Implement hidden quest triggers
27. [x] Add quest accept dialogue
28. [x] Add quest progress tracking
29. [x] Add quest completion dialogue
30. [x] Add quest reward distribution
31. [x] Add quest UI updates per state
32. Add quest sound stings
33. Add quest objective markers in world
34. Hook quest to map UI
35. [x] Add quest abandonment
36. [x] Add quest failure conditions
37. [x] Build quest chain dependencies
38. [x] Add quest cinematic triggers
39. [x] Hook quest to NPC affinity
40. [x] Hook quest to faction system
41. [x] Build quest journal lore tab
42. [x] Validate save/load quest state
43. Add quest tutorial flow
44. Add quest filtering
45. Add quest sort options
46. Validate UX
47. Test full main quest playthrough
48. Render hero shots
49. [x] Document quest bible
50. Commit `epic-38: quest system v2 complete`

---

## Epic 39 — Faction System

1. [x] Design faction bible: 4 factions, ideologies, rewards
2. [x] Define faction 1: Optimizers (efficiency, order)
3. [x] Define faction 2: Glitchers (chaos, freedom)
4. [x] Define faction 3: Archivists (preservation, history)
5. [x] Define faction 4: Dreamers (creativity, hope)
6. [x] Build faction reputation tracker
7. [x] Define faction reputation gains
8. [x] Define faction reputation losses
9. Build faction UI screen
10. Render faction emblems
11. [x] Build faction NPC representatives in town
12. Build faction headquarters scenes
13. [x] Add faction quest lines (10 per faction)
14. [x] Implement Optimizer quest line
15. [x] Implement Glitcher quest line
16. [x] Implement Archivist quest line
17. [x] Implement Dreamer quest line
18. [x] Add faction-specific rewards (gear, modules)
19. [x] Add faction-specific cosmetics
20. [x] Add faction reputation rank system
21. Add faction rank-up cinematic
22. [x] Build faction merchant
23. [x] Add faction shop inventory
24. [x] Add faction-locked content
25. [x] Add reputation conflict mechanic (rising in one lowers others)
26. [x] Add neutral faction option
27. Build faction war event
28. Add faction-aligned NPCs in dungeons
29. Add faction-aligned enemies
30. Add faction prayer/buff system
31. [x] Hook faction to story branches
32. [x] Add achievement triggers
33. [x] Add faction lore tab
34. [x] Build faction insignia overlay on equipped gear
35. [x] Add faction-specific dialogue greetings
36. [x] Add faction reaction to player choices
37. [x] Hook to save data
38. Validate balance across factions
39. Test playthrough rising in each faction
40. Render hero shot per faction HQ
41. [x] Document faction bible
42. Add faction tutorial
43. Add faction selection UI at intro
44. Add faction-tagged loot drops
45. Validate faction conflict UX
46. Add faction map overlay
47. Add faction event calendar
48. Add UI hints for current standing
49. Validate against quest system
50. Commit `epic-39: faction system complete`

---

## Epic 40 — Companion System (NPCs Join Runs)

1. [x] Design companion bible: 4 companions, abilities, AI
2. [x] Define companion 1: melee tank
3. [x] Define companion 2: ranged DPS
4. [x] Define companion 3: support healer
5. [x] Define companion 4: utility CC
6. [x] Build companion AI state machine
7. [x] Implement companion follow behavior
8. [x] Implement companion combat behavior
9. [x] Implement companion ability selection
10. [x] Implement companion targeting
11. [x] Add companion HP system
12. [x] Add companion downed state
13. [x] Add companion revive interaction
14. [x] Build companion command UI (attack, defend, use ability)
15. [x] Add companion loadout customization
16. [x] Add companion gear slots
17. [x] Add companion XP system
18. [x] Add companion level-up
19. Add companion skill tree (small, 15 nodes each)
20. [x] Build companion summon at dungeon entry
21. [x] Build companion dismiss
22. [x] Add companion dialogue during runs
23. [x] Add companion idle banter
24. [x] Add companion combat callouts
25. [x] Add companion victory cheer
26. [x] Add companion defeat reaction
27. [x] Build companion-specific quest lines
28. [x] Add companion gift preferences
29. [x] Hook companion to NPC affinity system
30. Add companion-Globbler relationship cutscenes
31. [x] Add per-companion ultimate ability
32. [x] Add companion VFX themes
33. Build companion model variants
34. Add companion gear visual swap
35. Add companion pet support
36. [x] Build companion party limit (1 active, future 2-3)
37. [x] Hook companion to save data
38. [x] Add companion presence affecting boss fights
39. [x] Tune companion balance
40. Test full run with each companion
41. Render hero shots per companion
42. [x] Add companion lore tab
43. [x] Add companion achievements
44. [x] Hook to faction system
45. Validate UX
46. Build companion tutorial
47. [x] Document companion bible
48. Add companion respec
49. [x] Polish companion AI navigation
50. Commit `epic-40: companion system complete`

---

## Epic 41 — Pet System

1. [x] Design pet bible: 8 pet types, hatching, growth
2. [x] Design pet 1: Data Sprite (caster pet)
3. [x] Design pet 2: Patch Dog (loyal melee)
4. [x] Design pet 3: Bit Cat (stealthy)
5. [x] Design pet 4: Bug Buddy (corrupted)
6. [x] Design pet 5: Memory Owl (intelligent)
7. [x] Design pet 6: Cache Mouse (gathering)
8. [x] Design pet 7: Echo Bird (flying)
9. [x] Design pet 8: Crystal Fox (rare)
10. Sculpt + texture + rig pet 1
11. Sculpt + texture + rig pet 2
12. Sculpt + texture + rig pet 3
13. Sculpt + texture + rig pet 4
14. Sculpt + texture + rig pet 5
15. Sculpt + texture + rig pet 6
16. Sculpt + texture + rig pet 7
17. Sculpt + texture + rig pet 8
18. Animate pet idle (each)
19. Animate pet follow (each)
20. Animate pet ability (each)
21. Animate pet sleep (each)
22. Animate pet pet interaction (each)
23. Animate pet death (each)
24. [x] Build pet AI follow
25. [x] Build pet interaction
26. [x] Build pet feeding system
27. [x] Build pet happiness state
28. [x] Build pet egg hatching
29. [x] Add pet inventory category
30. [x] Add pet selection UI
31. [x] Add pet renaming
32. [x] Add pet bonding system
33. [x] Build pet hutch in town
34. [x] Add pet petting interaction with affection bonus
35. [x] Add pet treat system
36. [x] Add pet evolution variants
37. [x] Add pet collection achievement
38. [x] Add pet showcase area
39. [x] Hook pet to combat (passive abilities)
40. [x] Add pet-specific quests
41. [x] Add pet rare drops
42. [x] Add pet stat bonuses to player
43. Build pet info card UI
44. [x] Add pet lore
45. Render hero shots
46. [x] Validate save/load
47. Add ambient SFX per pet
48. [x] Document pet bible
49. [x] Test full pet collection loop
50. Commit `epic-41: pet system complete`

---

## Epic 42 — Mini-Games & Puzzles

1. [x] Design minigame bible: 8 distinct minigames
2. [x] Design minigame 1: Terminal Hacking (sequence puzzle)
3. [x] Design minigame 2: Memory Match (lore unlock)
4. [x] Design minigame 3: Code Compile (logic puzzle)
5. [x] Design minigame 4: Data Sort (timed)
6. [x] Design minigame 5: Fishing (rhythm)
7. [x] Design minigame 6: Cooking (resource management)
8. [x] Design minigame 7: Lockpicking (precision)
9. [x] Design minigame 8: Music Sync (rhythm)
10. [x] Build Terminal Hacking minigame
11. [x] Build Memory Match minigame
12. Build Code Compile minigame
13. Build Data Sort minigame
14. [x] Build Fishing minigame
15. Build Cooking minigame
16. [x] Build Lockpicking minigame
17. [x] Build Music Sync minigame
18. [x] Add minigame difficulty tiers
19. [x] Add minigame rewards
20. Add minigame leaderboard local
21. Add minigame tutorials
22. [x] Hook minigames to world objects
23. [x] Place hacking terminals in dungeons
24. [x] Place memory crystals in vaults
25. [x] Place code consoles in story rooms
26. [x] Place fishing spots in town
27. [x] Place cooking station in town
28. [x] Place locked containers throughout
29. [x] Place music station in lounge
30. [x] Add minigame UI per game
31. Render minigame hero icons
32. Add minigame SFX
33. Add minigame VFX
34. [x] Add minigame failure handling
35. [x] Add minigame retry system
36. [x] Hook to quest system
37. [x] Hook to crafting outputs
38. [x] Hook to lore unlocks
39. [x] Add achievement triggers
40. Validate UX per minigame
41. Add controller support
42. Test all 8 minigames
43. Render gameplay screenshots
44. [x] Add minigame practice mode
45. Add minigame help text
46. Polish minigame visuals
47. [x] Document minigame bible
48. [x] Add minigame statistics tracker
49. [x] Add minigame mastery rewards
50. Commit `epic-42: minigames complete`

---

## Epic 43 — Boss Roster Expansion (5 New Bosses)

1. [x] Design boss 2: Memory Warden (memory vault biome)
2. [x] Design boss 3: Root Heart (corrupted wilds biome)
3. [x] Design boss 4: Sentinel Prime (server room elite)
4. [x] Design boss 5: Iteration Phantom (mirror match)
5. [x] Design boss 6: The Compiler Reborn (final iteration boss)
6. [x] Concept boss 2 with phase forms
7. Sculpt boss 2 high-poly
8. Texture + rig boss 2
9. Animate boss 2 (intro, idle, attacks ×4, transitions, death)
10. [x] Implement boss 2 AI + arena hooks
11. [x] Concept boss 3 with phase forms
12. Sculpt boss 3 high-poly
13. Texture + rig boss 3
14. Animate boss 3 full set
15. [x] Implement boss 3 AI
16. [x] Concept boss 4
17. Sculpt boss 4
18. Texture + rig boss 4
19. Animate boss 4 full set
20. [x] Implement boss 4 AI
21. [x] Concept boss 5 (uses player rig variant)
22. Sculpt boss 5
23. Texture + rig boss 5
24. Animate boss 5 full set
25. [x] Implement boss 5 AI
26. [x] Concept boss 6 (final boss, ultra detail)
27. Sculpt boss 6 high-poly with subdivision detail
28. Texture + rig boss 6
29. Animate boss 6 full set
30. [x] Implement boss 6 AI with multi-phase
31. Build per-boss arena (5 unique scenes)
32. Build per-boss intro cinematic
33. Build per-boss outro cinematic
34. Build per-boss music
35. Build per-boss reward chest
36. Build per-boss bestiary entry
37. Build per-boss lore tablet
38. [x] Validate boss balance
39. [x] Tune attack patterns
40. [x] Add boss telegraphs
41. [x] Add boss VFX libraries
42. Render boss hero shots
43. [x] Build boss-bar HUD per boss
44. [x] Add boss phase markers
45. Test full bosses
46. [x] Add boss achievements
47. [x] Hook to quest system
48. [x] Document boss bible
49. [x] Build boss rush mode
50. Commit `epic-43: 5 new bosses complete`

---

## Epic 44 — Endgame Modes (Challenge Tower, Infinite, etc)

1. [x] Design endgame bible
2. [x] Design Challenge Tower (50 floors, escalating)
3. [x] Design Infinite Mode (procedural endless)
4. [x] Design Boss Rush Mode
5. [x] Design Daily Challenge mode
6. [x] Design Hardcore Mode (permadeath)
7. [x] Build Challenge Tower scene structure
8. Build tower entry NPC
9. [x] Build tower modifier system per floor
10. [x] Build tower reward tier system
11. [x] Build tower leaderboard local
12. [x] Build Infinite Mode generation
13. [x] Add infinite scaling difficulty
14. [x] Add infinite seed system
15. [x] Add infinite reward currency
16. [x] Add infinite shop unlocks
17. [x] Build Boss Rush mode scene
18. [x] Add boss rush time tracking
19. [x] Add boss rush rank system
20. [x] Build Daily Challenge generator
21. [x] Add daily seed system
22. [x] Add daily reward
23. [x] Add daily leaderboard slot
24. [x] Build Hardcore mode toggle
25. [x] Add hardcore save handling
26. Add hardcore death cinematic
27. [x] Add hardcore unique rewards
28. Build endgame mode select UI
29. Render mode hero icons
30. Add mode-specific music
31. Add mode-specific tutorial
32. Add mode-specific achievements
33. [x] Build mode statistics
34. [x] Hook all modes to save data
35. [x] Add mode quick-restart
36. [x] Add mode pause handling
37. [x] Validate balance per mode
38. Test full Challenge Tower run
39. Test full Infinite Mode run
40. Test Boss Rush
41. Test Daily Challenge
42. Test Hardcore Mode
43. Polish UX
44. Render endgame showcase video
45. [x] Document endgame bible
46. [x] Add mode unlock conditions
47. [x] Validate save isolation per mode
48. [x] Add per-mode high-score display
49. [x] Add per-mode trophies
50. Commit `epic-44: endgame modes complete`

---

## Epic 45 — Difficulty & Modifier System

1. [x] Design difficulty bible: 5 difficulty tiers
2. [x] Define Easy preset
3. [x] Define Normal preset
4. [x] Define Hard preset
5. [x] Define Expert preset
6. [x] Define Nightmare preset
7. [x] Build difficulty selector at new game
8. [x] Build difficulty change menu (limited)
9. [x] Hook difficulty to enemy HP/damage
10. [x] Hook difficulty to loot quality
11. [x] Hook difficulty to economy
12. [x] Build modifier system
13. [x] Define 30 modifiers (positive and negative)
14. [x] Implement modifier 1-10 effects
15. [x] Implement modifier 11-20 effects
16. [x] Implement modifier 21-30 effects
17. [x] Build modifier selection UI
18. [x] Hook modifiers to dungeon runs
19. [x] Add modifier reward bonuses
20. [x] Add modifier risk indicators
21. Render modifier icons
22. [x] Add modifier tooltips
23. [x] Add modifier stacking rules
24. [x] Validate balance per combination
25. [x] Build modifier history tracker
26. [x] Add modifier achievements
27. [x] Add modifier leaderboard tags
28. [x] Hook to save data
29. [x] Test full difficulty matrix
30. [x] Test modifier combinations
31. Polish UI
32. Add controller support
33. [x] Add accessibility settings (auto-aim, slow time)
34. [x] Add colorblind modes
35. [x] Add screen-shake toggle
36. [x] Add hit-stop intensity slider
37. [x] Add UI scale option
38. [x] Add subtitle option
39. Add language placeholder system
40. Add input rebinding
41. [x] Add aim assist toggle
42. [x] Add damage number toggle
43. [x] Add HUD opacity slider
44. Validate accessibility against demo
45. Add tutorial for difficulty
46. [x] Document difficulty bible
47. Render difficulty showcase
48. Test perf at all settings
49. [x] Add settings save/load
50. Commit `epic-45: difficulty & accessibility complete`

---

# PILLAR 4 — POLISH & LAUNCH (E46–E50)

---

## Epic 46 — Audio: Original Soundtrack

1. Source/contract composer or use AI music generation tool
2. Compose town main theme
3. Compose town night variant
4. Compose Residential District ambient
5. Compose Market District ambient
6. Compose Commons District ambient
7. Compose Workshop District ambient
8. Compose Docks District ambient
9. Compose wilderness theme
10. Compose wilderness night theme
11. Compose Server Room biome theme
12. Compose Memory Vaults theme
13. Compose Corrupted Wilds theme
14. Compose Final Vault theme
15. Compose combat layer 1 (light)
16. Compose combat layer 2 (mid)
17. Compose combat layer 3 (intense)
18. Compose boss intro stinger
19. Compose Compiler boss theme
20. Compose Memory Warden boss theme
21. Compose Root Heart boss theme
22. Compose Sentinel Prime boss theme
23. Compose Iteration Phantom boss theme
24. Compose Compiler Reborn final boss theme
25. Compose victory fanfare
26. Compose defeat sting
27. Compose level-up sting
28. Compose iteration reset cinematic theme
29. Compose main menu theme
30. Compose credits theme
31. Compose dialogue ambient music
32. Compose tavern music
33. Compose forge music
34. Compose archive music
35. [x] Build Godot music manager autoload
36. [x] Hook music to scene transitions
37. [x] Hook music to combat state
38. [x] Hook music to boss fight
39. [x] Add smooth crossfade between tracks
40. [x] Validate volume balance
41. [x] Add per-zone fadein/fadeout
42. [x] Hook music to time of day
43. [x] Hook music to weather
44. [x] Add reactive music intensity
45. [x] Build music settings (volume slider, mute)
46. Test full music coverage
47. Render music showcase video
48. [x] Document music bible
49. Add music attribution credits
50. Commit `epic-46: original soundtrack complete`

---

## Epic 47 — Audio: SFX Overhaul (300+ Sounds)

1. Source/record full SFX library (royalty-free or original)
2. [x] Player footsteps grass ×4
3. [x] Player footsteps stone ×4
4. [x] Player footsteps metal ×4
5. [x] Player footsteps wood ×4
6. [x] Player footsteps water ×4
7. [x] Player jump
8. [x] Player land
9. [x] Player dash
10. [x] Player damaged ×3
11. [x] Player death
12. [x] Player level up
13. [x] Player potion drink
14. [x] Basic attack swing ×3
15. [x] Basic attack hit ×3
16. [x] Charged attack release
17. [x] Charged attack hit
18. [x] Module 1 cast
19. [x] Module 2 cast
20. [x] Module 3 cast
21. [x] Module 4 cast (continue per module)
22. [x] Compile all 40 module sounds
23. [x] Enemy GlitchBug aggro
24. [x] Enemy GlitchBug attack
25. [x] Enemy GlitchBug death
26. [x] Enemy MemoryLeak aggro
27. [x] Enemy MemoryLeak attack
28. [x] Enemy MemoryLeak death
29. [x] Enemy RogueProcess aggro
30. [x] Enemy RogueProcess attack
31. [x] Enemy RogueProcess death
32. [x] All 8 new enemy sound triples
33. [x] Boss Compiler intro
34. [x] Boss Compiler attacks ×4
35. [x] Boss Compiler death
36. [x] All 5 boss sound sets
37. [x] UI button hover
38. [x] UI button click
39. [x] UI menu open
40. [x] UI menu close
41. [x] UI tab switch
42. [x] UI inventory open
43. [x] UI inventory close
44. [x] UI item pickup
45. [x] UI item drop
46. [x] UI item equip
47. [x] UI item drop on ground
48. [x] UI gold pickup
49. [x] UI XP pickup
50. Commit `epic-47: SFX overhaul complete`

---

## Epic 48 — Voice Acting / NPC Voice Treatment

1. [x] Decide voice approach: real VAs, AI TTS, or text-only with grunts
2. [x] Build "voice grunts" library per NPC (6 unique grunts)
3. [x] Hook grunts to dialogue lines (per character pitch)
4. [x] Build emotion-tagged grunts (happy, sad, surprised, angry)
5. [x] Add typewriter SFX per dialogue letter
6. [x] Add per-character text speed
7. [x] Add per-character font choice
8. Render Globbler grunts (6 emotional)
9. Render Sage grunts (warm, low)
10. Render NPC 1 (Pixel) grunts
11. Render NPC 2 (Forge) grunts
12. Render NPC 3 (Cache) grunts
13. Render NPC 4 (Index) grunts
14. Render NPC 5 (Harvest) grunts
15. Render NPC 6 (Bit) grunts (child pitch)
16. Render NPC 7 (Legacy) grunts (elder pitch)
17. Render NPC 8 (Trade) grunts
18. Render NPC 9 (Lab) grunts
19. Render NPC 10 (Render) grunts
20. Render NPC 11 (Sync) grunts (musical)
21. Render NPC 12 (Sentinel) grunts (gruff)
22. [x] Hook all grunts to dialogue system
23. [x] Add audio mixing per NPC
24. [x] Add reverb per environment
25. [x] Add UI volume slider for voice
26. [x] Build voice mute toggle
27. [x] Add cinematic voiceover slots (post-MVP placeholders)
28. [x] Build narrator voice for iteration intros
29. [x] Add narrator track for opening cinematic
30. [x] Add narrator track for iteration 2 reveal
31. [x] Add narrator for iteration 9 ending
32. [x] Validate voice balance
33. [x] Build voice attribution credits
34. [x] Add per-line voice variation (don't repeat same grunt)
35. [x] Add silence for very short dialogue lines
36. Build voice editor tool for tuning
37. [x] Validate against all dialogue
38. Test full dialogue playthrough
39. [x] Polish per-character timing
40. [x] Add reactive grunt-on-hit
41. [x] Add reactive grunt-on-death
42. [x] Add ambient NPC chatter (background)
43. [x] Add NPC singing in tavern
44. [x] Add child NPC giggle
45. [x] Add elder NPC sigh
46. [x] Add boss roars
47. [x] Add combat callouts ("look out!")
48. Render voice showcase clip
49. [x] Document voice bible
50. Commit `epic-48: voice treatment complete`

---

## Epic 49 — Cinematics & Cutscenes

1. [x] Design cinematic bible: in-engine vs prerendered
2. [x] Design opening cinematic (Globbler awakens)
3. [x] Design iteration 1 → 2 transition
4. [x] Design iteration 2 → 3 transition
5. [x] Design iteration 3 → 4 transition
6. [x] Design iteration 4 → 5 transition
7. [x] Design iteration 5 → 6 transition
8. [x] Design iteration 6 → 7 transition
9. [x] Design iteration 7 → 8 transition
10. [x] Design iteration 8 → 9 transition
11. [x] Design final ending cinematic
12. [x] Build cinematic camera system
13. [x] Build cinematic dolly tracks
14. [x] Build cinematic camera shake
15. Build cinematic depth of field
16. [x] Build cinematic letterbox bars
17. [x] Build cinematic timeline tool
18. [x] Implement opening cinematic in-engine
19. [x] Implement iteration 1 → 2 transition
20. [x] Implement iteration 2 → 3
21. [x] Implement iteration 3 → 4
22. [x] Implement iteration 4 → 5
23. [x] Implement iteration 5 → 6
24. [x] Implement iteration 6 → 7
25. [x] Implement iteration 7 → 8
26. [x] Implement iteration 8 → 9
27. Implement final ending
28. [x] Add cinematic skip option
29. [x] Hook cinematics to story flags
30. [x] Add cinematic save/restore
31. [x] Add subtitle support
32. [x] Add cinematic music sync
33. [x] Add cinematic SFX hooks
34. [x] Polish opening cinematic
35. Polish closing cinematic
36. [x] Build "first compaction" cinematic
37. [x] Build "first boss kill" cinematic
38. [x] Build "town arrival" cinematic
39. [x] Build NPC recruit cinematics ×6
40. [x] Build affinity max cinematics
41. [x] Build death cinematic dramatization
42. [x] Build secret discovery cinematics
43. [x] Validate cinematics on multiple aspect ratios
44. Render cinematic showcase reel
45. [x] Add post-credits scene
46. [x] Hook to achievement system
47. Test full cinematic playback
48. [x] Optimize cinematic playback perf
49. [x] Document cinematic bible
50. Commit `epic-49: cinematics complete`

---

## Epic 50 — Steam Launch Prep

1. Set up Steamworks partner account
2. Reserve App ID
3. [x] Build Steam store page draft
4. [x] Write store description short
5. [x] Write store description long
6. Capture 8 screenshots from best gameplay
7. Capture 8 screenshots from best environments
8. Capture 8 screenshots from best combat
9. Capture 8 screenshots from best NPCs
10. Capture 4 hero screenshots for store header
11. [x] Build store page tags
12. [x] Build store page categories
13. [x] Define system requirements
14. [x] Build trailer storyboard (90 seconds)
15. Capture trailer footage in-engine
16. Cut trailer rough edit
17. Polish trailer with music
18. Add trailer text overlays
19. Render final trailer
20. Upload trailer to YouTube
21. Build Steam page video embed
22. [x] Define achievements (50 achievements)
23. [x] Implement achievement system in code
24. [x] Hook achievements to gameplay events
25. [x] Implement Steam achievement API
26. [x] Add achievement unlock notification UI
27. [x] Test all achievements unlock
28. Build trading cards (5 cards)
29. Build badges (1 + 5 levels)
30. Build emoticons (5)
31. Build profile backgrounds (3)
32. Build community items
33. [x] Configure cloud saves
34. Test cloud save sync
35. [x] Build language placeholder for localization
36. [x] Set up demo build branch
37. [x] Set up release build branch
38. [x] Configure auto-updates
39. [x] Build EULA / privacy policy text
40. [x] Build credits scene in game
41. [x] Add Steam overlay support
42. Test Steam overlay
43. [x] Configure controller config templates
44. Submit for Steam review
45. [x] Set up release date placeholder
46. [x] Build wishlist marketing email draft
47. [x] Set up Twitter/Bluesky/Discord placeholder
48. [x] Build press kit (logo, screenshots, fact sheet)
49. [x] Build dev blog post draft
50. Commit `epic-50: Steam launch prep complete`

---

## Progress Tracking

Mark each epic when complete:

- [x] Epic 01 — Globbler Hero Character: AAA Remake
- [x] Epic 02 — Globbler Outfits & Equipment Visualization (8 outfit sets + portrait pipeline + runtime attach)
- [x] Epic 03 — Globbler Animation Library Deep Pass
- [x] Epic 04 — GlitchBug Enemy: Photoreal Detail Pass
- [x] Epic 05 — MemoryLeak Enemy: Photoreal Detail Pass
- [x] Epic 06 — RogueProcess Enemy: Photoreal Detail Pass
- [x] Epic 07 — Corrupted Compiler Boss: Trailer-Grade Pass
- [ ] Epic 08 — New Enemy Roster (8 New Enemies)
- [ ] Epic 09 — AI Sage NPC: Hero Asset Treatment
- [ ] Epic 10 — Town NPC Cast (12 Unique Characters)
- [ ] Epic 11 — Town Hero Architecture (10 Landmark Buildings)
- [ ] Epic 12 — Town Modular Building Kit (Filler Buildings)
- [ ] Epic 13 — Vegetation & Foliage Library
- [ ] Epic 14 — Terrain System v2
- [ ] Epic 15 — Dungeon Biome 1: Server Room
- [ ] Epic 16 — Dungeon Biome 2: Memory Vaults
- [ ] Epic 17 — Dungeon Biome 3: Corrupted Wilds
- [ ] Epic 18 — Dungeon Biome 4: Boss Sanctum
- [ ] Epic 19 — PBR Lighting & Atmosphere Overhaul
- [ ] Epic 20 — Shader Library
- [ ] Epic 21 — Town Districts: 5 Distinct Zones
- [ ] Epic 22 — Town Sub-Areas & Hidden Spots
- [x] Epic 23 — Open Wilderness Zone (system layer complete; Blender build pending)
- [x] Epic 24 — Multiple Dungeon Entrances (system layer complete; Blender monuments pending)
- [x] Epic 25 — Town Hub Expansion: Underground & Vertical (system layer complete; Blender scenes pending)
- [ ] Epic 26 — Day/Night Cycle System
- [ ] Epic 27 — Weather System
- [ ] Epic 28 — World Map & Fast Travel
- [ ] Epic 29 — Procedural Dungeon Generation v2
- [ ] Epic 30 — Massive Dungeon Floors
- [ ] Epic 31 — Class System
- [ ] Epic 32 — Skill Tree
- [ ] Epic 33 — Module Library Expansion
- [ ] Epic 34 — Crafting System
- [ ] Epic 35 — Farming & Gathering Systems
- [ ] Epic 36 — Town Building & Decoration
- [ ] Epic 37 — NPC Affinity & Relationships
- [ ] Epic 38 — Quest System v2
- [ ] Epic 39 — Faction System
- [ ] Epic 40 — Companion System
- [ ] Epic 41 — Pet System
- [ ] Epic 42 — Mini-Games & Puzzles
- [ ] Epic 43 — Boss Roster Expansion
- [ ] Epic 44 — Endgame Modes
- [ ] Epic 45 — Difficulty & Modifier System
- [ ] Epic 46 — Audio: Original Soundtrack
- [ ] Epic 47 — Audio: SFX Overhaul
- [ ] Epic 48 — Voice Acting / NPC Voice Treatment
- [ ] Epic 49 — Cinematics & Cutscenes
- [ ] Epic 50 — Steam Launch Prep

**Total work items:** 2,500
**Status:** Ready to execute. Loop through epics 1 → 50.
