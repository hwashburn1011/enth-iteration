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
4. Model Initiate set (head visor, chest plate, gloves, boots) low poly clean
5. Texture Initiate set with neutral palette
6. [x] Design "Patcher" uncommon set — utility/repair theme
7. Model + texture Patcher set
8. [x] Design "Compiler" rare set — ornate, geometric
9. Model + texture Compiler set with emissive accents
10. [x] Design "Kernel" epic set — sleek warrior aesthetic
11. Model + texture Kernel set with anim'd glow shader
12. [x] Design "Architect" legendary set — heroic silhouette
13. Model + texture Architect set with cape/mantle that simulates
14. [x] Design "Glitch" cursed/unique set — broken digital corruption look
15. Model + texture Glitch set with shader distortion
16. [x] Design "Cozy" town/social set — non-combat outfit
17. Model + texture Cozy set
18. [x] Design "Boss Reward" iconic set — drops from Compiler boss
19. Model + texture Boss Reward set
20. [x] Build mix-and-match material system so any helmet works with any chest
21. [x] Create dye system: 16 color variants per slot
22. [x] Add per-slot wear/dirt slider that increases with damage taken
23. [x] Hook up equipment preview in inventory screen (3D rotating model)
24. [x] Create paper-doll UI showing equipped silhouette
25. [x] Implement set-bonus visual: matched set glows softly
26. [x] Add rarity-tier vfx halo on equipped legendary items
27. Validate all 8 sets animate correctly with all anims from Epic 01
28. Validate clipping at extreme poses (charged attack, dash, death)
29. Polish weight painting on attachments
30. Add subtle physics on cape, antenna, loose straps
31. [x] Create equipment pickup world model variants (small props on ground)
32. [x] Create equipment drop sparkle/aura colored by rarity
33. [x] Build wardrobe NPC in town that previews outfits
34. [x] Add transmog system: visual one set, stats from another
35. [x] Hook transmog into save data
36. [x] Create "first equip" cinematic flash for new gear
37. Render marketing turntable of all 8 sets
38. [x] Stress test: equip/unequip 50 times, check for memory leaks
39. Verify no z-fighting on overlapping plates
40. [x] Add soft outline on equipped pieces for readability
41. [x] Tune metallic values per set so they read at gameplay distance
42. [x] Add fresnel rim light contribution per outfit
43. Validate all sets in 5 lighting environments
44. [x] Add equipment slot icons to UI matching set art
45. [x] Build "outfit favorites" save slot system (3 saved looks)
46. Create the Globbler portrait used in dialogue boxes (high-res render of new model)
47. Generate variant portraits per outfit
48. Animate portrait subtle motion (breathing, blink) as a Sprite2D atlas
49. [x] Hook portrait into dialogue UI
50. Commit `epic-02: outfits & equipment viz complete`

---

## Epic 03 — Globbler Animation Library Deep Pass

**Goal:** Triple the animation count beyond Epic 01 — every micro-expression a player might see.

1. Animate "look around" head turn variations ×4
2. Animate "wave" hello gesture
3. Animate "thumbs up" affirmation
4. Animate "shake head no"
5. Animate "shrug" uncertain
6. Animate "point" directional gesture
7. Animate "facepalm"
8. Animate "laugh" full body
9. Animate "cry" sad sequence
10. Animate "anger" stomp + fist clench
11. Animate "fear" recoil + hands up
12. Animate "thinking" hand on chin
13. Animate "salute"
14. Animate "dance 1" cozy bop
15. Animate "dance 2" victory shuffle
16. Animate "sleep" curled up
17. Animate "wake up" yawn + stretch
18. Animate "eat" prompt consume
19. Animate "drink" healing prompt
20. Animate "read" hold up data tablet
21. Animate "write" jotting notes
22. Animate "craft" hands working
23. Animate "fish" idle with rod
24. Animate "farm" planting/harvest
25. Animate "build" hammering
26. Animate "dig" shovel
27. Animate "swim" water surface
28. Animate "swim under" submerged
29. Animate "climb" ladder
30. Animate "vault" over obstacle
31. Animate "slide" under obstacle
32. Animate "carry heavy"
33. Animate "push" object
34. Animate "pull" object
35. Animate "throw" projectile
36. Animate "kick" attack
37. Animate "block" defensive stance
38. Animate "parry" successful counter
39. Animate "dodge roll" alt to dash
40. Animate "execute finisher" cinematic kill
41. Animate "mounted ride" if pets get implemented
42. Animate "petting pet" affection
43. Animate "high five" with NPC
44. Animate "hug" emotional moment
45. Animate "fall from height" extended fall
46. Animate "land hard" with stumble
47. Animate "sneak" crouched walk
48. Animate "trip" comedic stumble
49. Build emote wheel UI exposing 12 of these as player-triggered
50. Commit `epic-03: animation library deep pass complete`

---

## Epic 04 — GlitchBug Enemy: Photoreal Detail Pass

**Goal:** Make the most-fought enemy a hero asset.

1. Reference: collect insect/glitch/digital corruption refs
2. Concept sketch 6 pose silhouettes
3. Sculpt high-poly carapace with surface detail
4. Add chitin plate breakup with edge wear
5. Sculpt 6 leg variants with joint detail
6. Sculpt mandibles + sensors
7. Retopo to 4K tris
8. UV unwrap with carapace on high-res patch
9. Bake normal/AO/curvature/cavity
10. Paint base color: dark insectoid base + glitch accent stripes
11. Add iridescent shader pass on carapace
12. Add emissive crawling glitch pattern
13. Build subsurface for translucent wing membranes
14. Rig with 24 bones including individual leg IK
15. Animate idle (twitchy, twitchy, look around)
16. Animate walk (6-leg gait)
17. Animate run (faster gait)
18. Animate aggro (rear up, hiss)
19. Animate attack lunge
20. Animate attack bite
21. Animate hit reaction
22. Animate death (legs curl, dissolve)
23. Animate death variant 2 (explode into glitch fragments)
24. Build 4 color variants (red venom, blue cold, green tox, purple elite)
25. Build size variants (small swarm, normal, large alpha)
26. Add per-variant unique vfx auras
27. Implement queen/elite GlitchBug visual upgrade
28. Polish material readability at gameplay zoom
29. Validate silhouette is unique vs other enemies
30. Render hero shot for trailer
31. Optimize: LOD0/LOD1/LOD2 set up
32. Decimate LOD2 to ~800 tris for distant
33. Tune skinning to avoid weird leg joints
34. Add ground contact ground decals
35. Add footstep dust particles per leg
36. Hook leg-IK foot placement to terrain
37. Validate animation transitions in Godot AnimTree
38. Add custom shader: glitch displacement on hit
39. Add "scared" backpedal anim when low HP
40. Add group call/summon animation
41. Add corpse persistence (lays on ground 10s before fade)
42. Tune attack telegraph readability
43. Add wing flap loop (idle ambient flutter)
44. Validate against 5 lighting setups
45. Add per-variant SFX hooks
46. Build spawn-from-egg variant intro
47. Build "pack leader" buff aura visual
48. Add "infested" environmental decal under pack groups
49. Document the GlitchBug bible for future variants
50. Commit `epic-04: GlitchBug AAA pass complete`

---

## Epic 05 — MemoryLeak Enemy: Photoreal Detail Pass

1. Reference: collect amorphous blob/slime/water/data refs
2. Concept 6 silhouette variants emphasizing flow/blob shape
3. Sculpt blob base form with internal "data" visible through translucency
4. Sculpt surface ripples and bubbles
5. Sculpt drip tendrils
6. Retopo to 3K tris with subdivision support
7. UV unwrap as cylindrical projection
8. Bake normal/AO/curvature
9. Paint base translucent shader (refraction-style)
10. Add internal "code stream" texture animated via UV scroll
11. Add subsurface scatter for inner glow
12. Build vertex-shader wobble for jelly motion
13. Add reactive ripples on hit (shader)
14. Rig with 12 bones for tendril control
15. Animate idle (slow pulse breath)
16. Animate move (drag/ooze across ground)
17. Animate attack (extend tendril whip)
18. Animate ranged spit attack
19. Animate hit reaction (jiggle wave)
20. Animate death (collapse into puddle, drain)
21. Animate split (spawns 2 smaller leaks)
22. Build 4 color variants (acid green, ice blue, fire orange, void purple)
23. Build size tiers (drip / leak / flood / ocean)
24. Validate vertex jelly shader at all sizes
25. Add ground puddle decal that grows over time
26. Add bubbling foam particles
27. Add splat particles on hit
28. Add absorb-light shader (darkens nearby area)
29. Implement leak-trail system (leaves slick on ground that slows player)
30. Add reflective surface shader
31. Validate readability vs other enemies
32. Build LOD chain
33. Tune shader cost on mobile-spec hardware
34. Add "engorged" elite variant with internal data churn
35. Add "starved" weak variant with thin form
36. Implement merge mechanic: 2 leaks combine into bigger threat
37. Animate merge sequence
38. Add absorb-corpse mechanic: leak grows by eating other enemies
39. Animate absorb sequence
40. Add custom death-puddle that lingers as hazard
41. Hook environment puddles to slow player movement
42. Add "boss tier" giant leak variant for mid-boss
43. Render hero shot for trailer
44. Add ambient SFX hooks (gurgle, drip)
45. Validate against 5 lighting environments
46. Polish vertex animation seams
47. Add per-variant glow color matching element
48. Add "freezing" status: leak crystallizes
49. Document MemoryLeak bible
50. Commit `epic-05: MemoryLeak AAA pass complete`

---

## Epic 06 — RogueProcess Enemy: Photoreal Detail Pass

1. Reference: rogue AI / drone / spectral entity refs
2. Concept 6 silhouettes with humanoid-but-wrong feel
3. Sculpt floating torso with no legs
4. Sculpt face with multiple eyes
5. Sculpt hand-claws
6. Sculpt back exhaust thrusters
7. Retopo to 3.5K tris
8. UV unwrap
9. Bake normal/AO/curvature/cavity
10. Paint base color: cold metallic + bright "alert" highlights
11. Add emissive eye + thruster glow
12. Build floating motion vertex shader (bobs in place)
13. Add holographic skin shader option
14. Rig with 22 bones
15. Animate hover idle
16. Animate combat hover idle (more aggressive)
17. Animate strafe L/R
18. Animate dash forward
19. Animate teleport in/out
20. Animate ranged attack charge + fire
21. Animate melee swipe
22. Animate hit reactions (knockback feels weightless)
23. Animate death (catastrophic shutdown, sparks, crash)
24. Build 4 archetype variants: scout, gunner, brute, hacker
25. Texture each archetype distinctively
26. Add archetype-specific weapons mounted on body
27. Add hover trail particles
28. Add thruster heat distortion shader
29. Build holographic damage flash
30. Build LOD chain
31. Add "alert" voice line trigger animation
32. Add "command" gesture for spawning minions
33. Add "shielded" variant with bubble shield
34. Build elite "Sentinel" miniboss variant
35. Animate Sentinel intro
36. Add Sentinel unique attack pattern animations
37. Render hero shots
38. Validate readability and silhouette
39. Polish material hierarchy
40. Tune emissive levels under 5 lighting setups
41. Add scanning eye-laser idle behavior
42. Add interrogation pose for story moments
43. Add "captured" defeated variant for cutscene use
44. Build hover IK so the unit stays above terrain
45. Add reactive lean during strafe
46. Validate AnimTree transitions
47. Hook variant-specific SFX
48. Document RogueProcess bible
49. Add per-archetype pickup/drop animation
50. Commit `epic-06: RogueProcess AAA pass complete`

---

## Epic 07 — Corrupted Compiler Boss: Trailer-Grade Pass

1. Reference: collect 25 boss design references (Hades bosses, Sea of Stars, Diablo finals)
2. Re-concept boss with 3 phase forms documented
3. Sculpt phase 1 form: ordered, geometric, "compiler at work"
4. Sculpt phase 2 form: glitching, fragmenting
5. Sculpt phase 3 form: full corruption, chaotic
6. Build kit-bash modular parts so phases share geometry
7. Retopo all forms with shared UV layout where possible
8. Bake high-poly detail to game mesh
9. Paint phase 1 textures (clean, crisp)
10. Paint phase 2 textures (glitching, color-shifted)
11. Paint phase 3 textures (corrupted, broken, emissive cracks)
12. Build emissive transition shader between phases
13. Add tessellated displacement on key surfaces
14. Build 50-bone rig with face, multiple arms, core, ground tethers
15. Animate phase 1 idle (imposing presence)
16. Animate phase 1 attack 1 (slam)
17. Animate phase 1 attack 2 (sweep beam)
18. Animate phase 1 attack 3 (summon adds)
19. Animate phase 1 → 2 transition (cracks open, roar)
20. Animate phase 2 idle (twitchy, glitching)
21. Animate phase 2 attack 1 (multi-projectile barrage)
22. Animate phase 2 attack 2 (teleport strike)
23. Animate phase 2 attack 3 (arena hazard spawn)
24. Animate phase 2 → 3 transition (full corruption ascent)
25. Animate phase 3 idle (massive, breathing)
26. Animate phase 3 attack 1 (arena-wide AoE)
27. Animate phase 3 attack 2 (chase laser)
28. Animate phase 3 attack 3 (gravity well)
29. Animate phase 3 ultimate (room-clearing, must dodge)
30. Animate hit reactions
31. Animate stagger when broken
32. Animate death sequence: 8-second cinematic collapse
33. Build dust + debris particles for slams
34. Build telegraph VFX per attack
35. Build phase-transition full-screen flash
36. Build boss intro cinematic camera move
37. Build outro: boss collapses, chest spawns
38. Add "low HP" rage visual: emissive intensifies
39. Add per-phase ambient SFX hook
40. Validate against arena lighting (built in Epic 17)
41. Optimize: LOD chain, draw distance
42. Test under sustained combat (3-min full fight)
43. Polish skinning at extreme poses
44. Add custom hitstop curve per attack hit
45. Add boss-bar phase markers in HUD
46. Render hero shot from below-up angle
47. Render trailer-quality dramatic angle
48. Capture full fight playthrough video
49. Build boss-defeat statue prop for town display
50. Commit `epic-07: Compiler boss AAA pass complete`

---

## Epic 08 — New Enemy Roster (8 New Enemies)

1. Design Crash Daemon — fast charging melee. Concept sketch.
2. Sculpt + texture + rig + animate Crash Daemon (full pipeline)
3. Polish Crash Daemon to ship quality
4. Design Null Pointer — invisible/teleport ranged. Concept sketch.
5. Sculpt + texture + rig + animate Null Pointer
6. Polish Null Pointer
7. Design Stack Overflow — towers vertically, shoots downward. Concept.
8. Sculpt + texture + rig + animate Stack Overflow
9. Polish Stack Overflow
10. Design Race Condition — splits constantly. Concept.
11. Sculpt + texture + rig + animate Race Condition
12. Polish Race Condition
13. Design Deadlock — immobile turret with chain attack. Concept.
14. Sculpt + texture + rig + animate Deadlock
15. Polish Deadlock
16. Design Buffer Overflow — bloats and explodes. Concept.
17. Sculpt + texture + rig + animate Buffer Overflow
18. Polish Buffer Overflow
19. Design Phantom Cache — appears/disappears, drops loot when killed quickly. Concept.
20. Sculpt + texture + rig + animate Phantom Cache
21. Polish Phantom Cache
22. Design Iteration Echo — clone of player. Concept.
23. Sculpt + texture + rig + animate Iteration Echo (uses player skeleton)
24. Polish Iteration Echo
25. Each enemy: build 3 elite variants (color + scale + buff)
26. Each enemy: write AI behavior brief
27. Implement Crash Daemon AI in StateMachine
28. Implement Null Pointer AI
29. Implement Stack Overflow AI
30. Implement Race Condition AI
31. Implement Deadlock AI
32. Implement Buffer Overflow AI
33. Implement Phantom Cache AI
34. Implement Iteration Echo AI
35. Tune damage/HP balance for each across 5 floor tiers
36. Add unique drop tables per enemy
37. Add unique death VFX per enemy
38. Add unique hit SFX hooks per enemy
39. Build enemy bestiary UI screen
40. Populate bestiary with hero renders
41. Add encounter design notes to bestiary entries
42. Add lore flavor text per enemy
43. Validate readability of all 8 silhouettes side by side
44. Validate at min/max draw distance
45. Add aggro range tuning per type
46. Add group composition presets (e.g. 2 GlitchBug + 1 Deadlock)
47. Hook into spawner system
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

1. Audit current lighting setup across all scenes
2. Define PBR material baseline (correct albedo ranges, metallic 0/1, roughness varied)
3. Re-validate every existing material against PBR baseline
4. Set up Reflection Probes per major area
5. Bake lightmaps for town
6. Bake lightmaps per dungeon biome
7. Build day-night cycle lighting curves
8. Set up directional sun light with cascade shadows
9. Tune shadow distance and bias
10. Build SSAO settings per environment
11. Build SSR settings for water + reflective floors
12. Tune SDFGI for indirect bounce
13. Build volumetric fog per environment preset
14. Set up godray volumetrics for sun shafts
15. Tune bloom thresholds per environment
16. Tune tonemapper (Filmic) per environment
17. Set up color grading LUTs per environment
18. Build "danger" lighting state for combat rooms
19. Build "safe" lighting state for hubs
20. Build "story" lighting state for cinematic moments
21. Add light flicker components for ambience
22. Add light pulse components for reactive states
23. Build emissive intensity tuning system
24. Add area lights for windows/lamps
25. Tune indoor lighting for tavern/forge/archive interiors
26. Build firefly/data-mote particle ambient lights
27. Add light cookies for window patterns
28. Validate every scene under 5 environment presets
29. Test perf budget for SDFGI on midspec hardware
30. Build fallback lighting profile for low-end
31. Add dynamic time-of-day in town
32. Add weather darkening modifier
33. Validate shadow softness on character
34. Tune subsurface light contribution on Globbler
35. Add per-material rim light contribution
36. Build skybox per environment (town day, town night, dungeon)
37. Add cloud layer to town sky
38. Build aurora-style sky for late-game iterations
39. Validate sky reflection in water
40. Build "iteration shift" lighting transition for narrative beats
41. Render hero lighting comparison shots (before/after)
42. Tune final intensity ratios so nothing blows out
43. Validate readability of player in all lighting
44. Validate readability of enemies in all lighting
45. Validate UI legibility in all lighting
46. Add light pollution glow over town visible from wilderness
47. Add ambient bird/insect spawners tied to time of day
48. Performance-profile final lighting cost
49. Document lighting bible
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

1. Design district 1: Residential District (homes, gardens, quiet)
2. Design district 2: Market District (shops, stalls, busy)
3. Design district 3: Commons District (tavern, archive, social)
4. Design district 4: Workshop District (forge, lab, industrial)
5. Design district 5: Docks District (water edge, boats, exotic goods)
6. Block out Residential District layout (4x larger than current town)
7. Block out Market District layout
8. Block out Commons District layout
9. Block out Workshop District layout
10. Block out Docks District layout
11. Place hero buildings from Epic 11 in their districts
12. Populate with modular fillers from Epic 12
13. Build paths connecting districts
14. Build district-archway entry markers
15. Add district-specific ambient SFX
16. Add district-specific particle ambient
17. Add district-specific NPC residents
18. Add district name signage
19. Build district map UI
20. Hook fast-travel between districts
21. Add district-specific lighting profile
22. Add district-specific music
23. Validate scale: walk time across town is 2-3 minutes
24. Validate readability of district boundaries
25. Add district-specific quest hubs
26. Build Residential gardens with farm patches
27. Build Market stall props with rotating inventory
28. Build Commons gathering plaza with benches
29. Build Workshop active forge with VFX
30. Build Docks with water, boats, fishing spots
31. Add water shader to Docks
32. Add boat dock interaction
33. Add district-specific weather variations
34. Add district-specific day/night transitions
35. Build connecting bridges between districts
36. Build elevation changes (Workshop is on a hill, Docks at sea level)
37. Validate navmesh across full town
38. Optimize draw calls per district
39. Bake lightmaps per district
40. Add ambient wildlife per district
41. Place all 12 NPCs in their home districts
42. Add district-specific lore objects
43. Build town hall central plaza connecting all districts
44. Add fountains, statues, monuments
45. Add seasonal decoration support
46. Validate full town walking tour
47. Render aerial overview shot of full town
48. Render hero shots per district
49. Document town bible
50. Commit `epic-21: 5 town districts complete`

---

## Epic 22 — Town Sub-Areas & Hidden Spots

1. Design sub-area 1: Outskirts (transition to wilderness)
2. Design sub-area 2: Cliffs (overlook the world)
3. Design sub-area 3: Hidden Cave (secret quest hub)
4. Design sub-area 4: Sage's Garden (private)
5. Design sub-area 5: Iteration Memorial (somber)
6. Design sub-area 6: Underground Lounge
7. Design sub-area 7: Tower Top
8. Design sub-area 8: Old Ruins (pre-game lore)
9. Build Outskirts terrain + foliage
10. Build Cliffs with view skybox
11. Build Hidden Cave interior
12. Build Sage's Garden with unique flora
13. Build Memorial with cenotaph
14. Build Underground Lounge interior
15. Build Tower Top with rooftop view
16. Build Old Ruins
17. Add unique props per sub-area
18. Add unique lighting per sub-area
19. Add unique ambient SFX per sub-area
20. Hide entrances behind exploration puzzles
21. Add discovery reward (new Module per sub-area)
22. Hook story moments to sub-areas
23. Add NPCs that only appear in sub-areas
24. Add sub-area to map after discovery
25. Add fast-travel waypoints
26. Validate scale and walk distances
27. Add per-area secret collectibles
28. Add sub-area lore tablets
29. Add atmospheric particles per area
30. Tune lighting per area
31. Render hero shot per sub-area
32. Hook ambient music per sub-area
33. Add wildlife spawners per area
34. Add reactive day/night cycle elements
35. Validate navmesh
36. Bake lighting
37. Optimize draw calls
38. Add weather response per area
39. Add cinematic camera spots
40. Hook discovery achievement
41. Build hidden quest hooks
42. Add per-area visual signature element
43. Validate readability
44. Add sub-area names with discovery cinematic
45. Build seasonal variants if applicable
46. Add ambient creature variants
47. Add unique Cache Sprite spawn per area
48. Test all sub-areas in single play session
49. Document sub-area bible
50. Commit `epic-22: town sub-areas complete`

---

## Epic 23 — Open Wilderness Zone (Between Town & Dungeons)

1. Design wilderness zone: river, forest, ruins, dungeon entrances
2. Build heightmap terrain at large scale
3. Sculpt river course
4. Build river water with flow shader
5. Sculpt cliff walls
6. Place forest vegetation density
7. Build clearing variants ×6
8. Build ruin prop set
9. Place ruin clusters
10. Build wilderness path network
11. Add path signposts
12. Place wilderness NPC encounters
13. Add wilderness wildlife (passive critters)
14. Add wilderness enemy spawns (overworld combat)
15. Build wilderness ambient SFX (wind, water, leaves)
16. Build wilderness ambient music
17. Add weather variation
18. Add day/night cycle
19. Build hidden grove side area
20. Build hidden lake side area
21. Build hidden cave side area
22. Place dungeon entrances ×4 (one per biome)
23. Build dungeon entrance hero monuments
24. Add fast-travel waypoints
25. Build wilderness map UI
26. Add discovery rewards per landmark
27. Hook story trigger zones
28. Build wilderness shrine that provides buffs
29. Build resource gathering nodes (for crafting)
30. Add fishing spots
31. Add foraging spots
32. Build campsite prop with rest function
33. Add ambient bird/insect spawners
34. Add ground decals for wear
35. Validate scale: 5x current dungeon room size
36. Optimize draw calls + LODs
37. Bake lighting
38. Add lighting variation per region
39. Add fog volume per region
40. Add weather particles
41. Add wind direction variance
42. Validate navmesh on slopes and around obstacles
43. Add cinematic camera reveal shots
44. Render hero shots
45. Hook wilderness encounter system
46. Add reactive enemy alerts
47. Add wandering NPC events
48. Test wilderness traversal end-to-end
49. Document wilderness bible
50. Commit `epic-23: wilderness zone complete`

---

## Epic 24 — Multiple Dungeon Entrances & Biome Selection

1. Design entrance 1: Server Room portal (cold tech)
2. Design entrance 2: Memory Vaults portal (gold archaic)
3. Design entrance 3: Corrupted Wilds portal (organic)
4. Design entrance 4: Final Vault portal (locked till conditions)
5. Build entrance 1 monument + portal VFX
6. Build entrance 2 monument + portal VFX
7. Build entrance 3 monument + portal VFX
8. Build entrance 4 monument + portal VFX
9. Hook entrance scene transitions
10. Add entrance lore plaques
11. Add entrance difficulty indicator
12. Add entrance recommended-level UI
13. Add entrance chosen-biome confirmation
14. Add per-entrance loading screen art
15. Build dungeon selection map screen
16. Hook dungeon selection to FloorManager
17. Add daily-bonus rotating biome
18. Add story-locked entrance reveals
19. Add visual "this entrance has been cleared" markers
20. Add cleared-count tracker per entrance
21. Add boss-defeated trophy at each entrance
22. Add per-entrance music sting
23. Add per-entrance ambient particles
24. Validate readability
25. Add entrance interaction prompt
26. Hook to fast-travel from town
27. Validate all 4 entrances transition properly
28. Build entrance "first time" cinematic per biome
29. Build entrance "return" idle cinematic
30. Add entrance NPC guide/warden
31. Add ambient SFX per entrance
32. Polish entrance lighting
33. Render hero shot per entrance
34. Validate against navmesh
35. Add entrance day/night appearance variation
36. Add entrance weather response
37. Add discovery reward for finding each
38. Add achievement for finding all
39. Add entrance signpost lore
40. Add per-entrance approach path
41. Add entrance flag/banner decor
42. Add entrance reflection probe
43. Build entrance secret unlock condition
44. Validate scene transitions don't crash
45. Test all entrances in one session
46. Hook map fast-travel
47. Add entrance audio sting
48. Polish entrance VFX
49. Document entrance bible
50. Commit `epic-24: multiple dungeon entrances complete`

---

## Epic 25 — Town Hub Expansion: Underground & Vertical

1. Design underground lounge concept
2. Build underground lounge scene
3. Add lounge furniture props
4. Build lounge bar interactive
5. Build lounge stage for music
6. Add lounge NPCs
7. Hook lounge dialogue
8. Build tower top scene
9. Build tower spiral staircase
10. Build tower observation deck
11. Add tower telescope interaction
12. Build tower ambient lighting
13. Build sage's tower study room
14. Build sage's library
15. Add archive crystal interactions
16. Build training arena hub area
17. Add target dummies
18. Add training reset functionality
19. Build farm plot area
20. Add planting interaction
21. Add harvesting interaction
22. Build fishing dock at water
23. Add fishing rod prop + animation
24. Build cooking station
25. Add cooking interaction
26. Build crafting workshop area
27. Add crafting station interactions
28. Build pet hutch area
29. Add pet feeding interaction
30. Build memorial gallery
31. Add iteration memorial plaques
32. Build trophy display hall
33. Add trophy mount points
34. Build wardrobe room
35. Add wardrobe interaction
36. Build "hub of mysteries" room with secrets
37. Add hidden door puzzles
38. Build hidden treasure room
39. Add new fast-travel points
40. Validate all hub additions tie to systems
41. Render hero shots per area
42. Optimize draw calls
43. Bake lighting
44. Hook ambient SFX
45. Hook ambient music transitions
46. Validate navmesh throughout
47. Test full hub traversal
48. Add map markers for new areas
49. Document hub expansion bible
50. Commit `epic-25: hub expansion complete`

---

## Epic 26 — Day/Night Cycle System

1. Design day/night cycle: 24 minutes real-time = 1 in-game day
2. Build sun directional light orbit animation
3. Build moon directional light alternate
4. Build skybox interpolation between presets
5. Build dawn skybox preset
6. Build noon skybox preset
7. Build dusk skybox preset
8. Build night skybox preset
9. Build night with moon variant
10. Build cloudy variant
11. Build storm variant
12. Hook lighting tint to time
13. Hook fog density to time
14. Hook ambient SFX shift to time
15. Hook NPC schedules to time
16. Hook enemy spawn variation to time
17. Build "night enemies" stronger at night
18. Hook player buffs to time of day
19. Build star particle layer for night
20. Build moon position animation
21. Build light cookie clouds drifting
22. Add ambient bird SFX in day
23. Add ambient cricket SFX at night
24. Build window-light flicker on at dusk
25. Build street lamp light on at dusk
26. Build NPC bedtime animations
27. Build NPC wake-up animations
28. Hook quest gating to time of day
29. Build "sleep till morning" interaction
30. Add "sleep till night" interaction
31. Build pause-time menu option
32. Add time UI clock display
33. Add day counter display
34. Hook save system to persist time
35. Build time-of-day skip cinematic
36. Validate lighting transitions are smooth
37. Validate perf with continuous time updates
38. Build time-locked content (some NPCs only visible at certain hours)
39. Add daily reset triggers
40. Hook daily quests
41. Build night-only enemies
42. Build night-only loot
43. Render time-of-day comparison shots
44. Validate against all environments
45. Add time sync between scenes
46. Hook EventBus signals for time events
47. Add cinematic dawn breaking sequence
48. Add cinematic sunset sequence
49. Document day/night bible
50. Commit `epic-26: day/night cycle complete`

---

## Epic 27 — Weather System

1. Design weather types: clear, cloudy, rain, storm, fog, glitch storm
2. Build clear preset
3. Build cloudy preset
4. Build rain preset with particle system
5. Build rain shader (wet ground)
6. Build rain ripple decals
7. Build storm preset (rain + wind + lightning)
8. Build lightning flash post-process
9. Build fog preset with dense volumetric
10. Build glitch storm preset (digital corruption visual)
11. Build wind direction system
12. Hook foliage wind shader to wind direction
13. Hook particle drift to wind direction
14. Build wind audio variation
15. Build rain audio loop
16. Build thunder SFX random triggers
17. Build storm SFX bed
18. Build glitch storm SFX
19. Build weather transition system (smooth interpolation)
20. Hook weather to time of day patterns
21. Build per-zone weather defaults
22. Build per-iteration weather changes (later iterations have more glitch storms)
23. Add weather UI indicator
24. Hook weather to combat (rain affects fire damage, etc)
25. Add weather-locked content
26. Add reactive NPC dialogue about weather
27. Add NPC indoor refuge during storms
28. Build umbrella prop / accessory
29. Build cloak weather wear visual
30. Hook player wet/dry shader
31. Add puddles forming during rain
32. Add fog draw distance reduction
33. Build sun shafts during clear weather
34. Build rainbow after rain rare event
35. Add weather particle perf budget
36. Build low-spec fallback weather
37. Validate weather under day and night
38. Add seasonal weather patterns
39. Hook fishing bonus during certain weather
40. Add weather radar UI for predictions
41. Validate weather doesn't break combat readability
42. Render weather showcase shots
43. Add reactive enemy behaviors per weather
44. Hook weather to save state
45. Add cinematic storm rolling in
46. Validate transitions are smooth
47. Add ambient lightning for storms
48. Document weather bible
49. Performance test all weather types
50. Commit `epic-27: weather system complete`

---

## Epic 28 — World Map & Fast Travel

1. Design world map UI layout
2. Sketch hand-drawn map style reference
3. Render world map background art
4. Build map UI scene with pan/zoom
5. Add region markers
6. Add fast-travel point markers
7. Add quest markers
8. Add player current-position marker
9. Add visited/unvisited fog of war
10. Hook map open/close keybind
11. Add map legend
12. Add region detail tooltips
13. Add fast-travel confirmation dialog
14. Build fast-travel cinematic transition
15. Hook to actual scene loading
16. Add map state save/load
17. Add discovery animations when new region found
18. Add hand-drawn style icons for landmarks
19. Add region name typography
20. Build animated map elements (waving flags, smoke)
21. Add per-region weather indicator on map
22. Add NPC location markers
23. Add quest objective markers
24. Build mini-map HUD overlay
25. Hook mini-map to player position
26. Add mini-map north indicator
27. Add mini-map enemy radar
28. Add mini-map interactable highlights
29. Build "compass" heading display
30. Add waypoint placement system
31. Hook waypoint navigation arrow
32. Build map filtering options
33. Add map note placement (player annotations)
34. Save player notes
35. Add region completion percentages
36. Add achievement indicators on map
37. Add lore unlock markers
38. Add hidden room discovery markers
39. Polish map illustration art
40. Add map music sting
41. Validate map UX with 30+ markers
42. Add scrollbar for marker list
43. Build search filter for markers
44. Add per-iteration map evolution (revealed details)
45. Render hero shot of full discovered map
46. Validate against all zones
47. Hook map to controller navigation
48. Add tutorial for first-time map open
49. Document map bible
50. Commit `epic-28: world map & fast travel complete`

---

## Epic 29 — Procedural Dungeon Generation v2

1. Audit current dungeon generation approach
2. Design v2: hand-crafted "anchor" rooms + procedural connectors
3. Build room library per biome with metadata tags
4. Build connector library per biome
5. Build generation algorithm: pick anchors, weave connectors, validate
6. Add seed system for reproducible runs
7. Build navmesh stitching across generated layouts
8. Add room rotation/mirror for variety
9. Add room density tuning per floor
10. Add encounter density tuning per floor
11. Add loot density tuning per floor
12. Build room tag system: combat, loot, story, secret, elite, boss
13. Hook generation to biome selection
14. Validate every generated layout has a path to boss
15. Add fail-safe regenerate if invalid
16. Build secret room placement (5% chance per layout)
17. Build elite room placement (1 per floor)
18. Build loot room placement (1 per floor)
19. Build story room placement (1 per floor)
20. Build environmental hazard placement
21. Build prop placement variation
22. Add ambient enemy patrol patterns
23. Add destructible object placement
24. Add lore object placement
25. Build lighting placement based on room tag
26. Add reflection probe placement
27. Validate perf with full generation
28. Build minimap from generated layout
29. Hook minimap to player exploration
30. Reveal map as player walks
31. Add room name labels
32. Add room transition fades
33. Add per-floor difficulty escalation
34. Validate all 4 biomes generate properly
35. Build "themed" generation for special story floors
36. Add room enter/exit triggers
37. Hook EventBus signals for room events
38. Validate save/load mid-run
39. Add cinematic for first time entering a new biome
40. Add per-room ambient SFX
41. Add per-room particle accents
42. Polish room transitions
43. Validate navmesh on dynamic layouts
44. Add ambient creature spawners per biome
45. Test 50 generated runs for stability
46. Build seed-share system (share generated runs)
47. Document generation bible
48. Render gallery of varied generated layouts
49. Optimize draw calls per generated room
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

1. Design cinematic bible: in-engine vs prerendered
2. Design opening cinematic (Globbler awakens)
3. Design iteration 1 → 2 transition
4. Design iteration 2 → 3 transition
5. Design iteration 3 → 4 transition
6. Design iteration 4 → 5 transition
7. Design iteration 5 → 6 transition
8. Design iteration 6 → 7 transition
9. Design iteration 7 → 8 transition
10. Design iteration 8 → 9 transition
11. Design final ending cinematic
12. Build cinematic camera system
13. Build cinematic dolly tracks
14. Build cinematic camera shake
15. Build cinematic depth of field
16. Build cinematic letterbox bars
17. Build cinematic timeline tool
18. Implement opening cinematic in-engine
19. Implement iteration 1 → 2 transition
20. Implement iteration 2 → 3
21. Implement iteration 3 → 4
22. Implement iteration 4 → 5
23. Implement iteration 5 → 6
24. Implement iteration 6 → 7
25. Implement iteration 7 → 8
26. Implement iteration 8 → 9
27. Implement final ending
28. Add cinematic skip option
29. Hook cinematics to story flags
30. Add cinematic save/restore
31. Add subtitle support
32. Add cinematic music sync
33. Add cinematic SFX hooks
34. Polish opening cinematic
35. Polish closing cinematic
36. Build "first compaction" cinematic
37. Build "first boss kill" cinematic
38. Build "town arrival" cinematic
39. Build NPC recruit cinematics ×6
40. Build affinity max cinematics
41. Build death cinematic dramatization
42. Build secret discovery cinematics
43. Validate cinematics on multiple aspect ratios
44. Render cinematic showcase reel
45. Add post-credits scene
46. Hook to achievement system
47. Test full cinematic playback
48. Optimize cinematic playback perf
49. Document cinematic bible
50. Commit `epic-49: cinematics complete`

---

## Epic 50 — Steam Launch Prep

1. Set up Steamworks partner account
2. Reserve App ID
3. Build Steam store page draft
4. Write store description short
5. Write store description long
6. Capture 8 screenshots from best gameplay
7. Capture 8 screenshots from best environments
8. Capture 8 screenshots from best combat
9. Capture 8 screenshots from best NPCs
10. Capture 4 hero screenshots for store header
11. Build store page tags
12. Build store page categories
13. Define system requirements
14. Build trailer storyboard (90 seconds)
15. Capture trailer footage in-engine
16. Cut trailer rough edit
17. Polish trailer with music
18. Add trailer text overlays
19. Render final trailer
20. Upload trailer to YouTube
21. Build Steam page video embed
22. Define achievements (50 achievements)
23. Implement achievement system in code
24. Hook achievements to gameplay events
25. Implement Steam achievement API
26. Add achievement unlock notification UI
27. Test all achievements unlock
28. Build trading cards (5 cards)
29. Build badges (1 + 5 levels)
30. Build emoticons (5)
31. Build profile backgrounds (3)
32. Build community items
33. Configure cloud saves
34. Test cloud save sync
35. Build language placeholder for localization
36. Set up demo build branch
37. Set up release build branch
38. Configure auto-updates
39. Build EULA / privacy policy text
40. Build credits scene in game
41. Add Steam overlay support
42. Test Steam overlay
43. Configure controller config templates
44. Submit for Steam review
45. Set up release date placeholder
46. Build wishlist marketing email draft
47. Set up Twitter/Bluesky/Discord placeholder
48. Build press kit (logo, screenshots, fact sheet)
49. Build dev blog post draft
50. Commit `epic-50: Steam launch prep complete`

---

## Progress Tracking

Mark each epic when complete:

- [ ] Epic 01 — Globbler Hero Character: AAA Remake
- [ ] Epic 02 — Globbler Outfits & Equipment Visualization
- [ ] Epic 03 — Globbler Animation Library Deep Pass
- [ ] Epic 04 — GlitchBug Enemy: Photoreal Detail Pass
- [ ] Epic 05 — MemoryLeak Enemy: Photoreal Detail Pass
- [ ] Epic 06 — RogueProcess Enemy: Photoreal Detail Pass
- [ ] Epic 07 — Corrupted Compiler Boss: Trailer-Grade Pass
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
- [ ] Epic 23 — Open Wilderness Zone
- [ ] Epic 24 — Multiple Dungeon Entrances
- [ ] Epic 25 — Town Hub Expansion: Underground & Vertical
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
