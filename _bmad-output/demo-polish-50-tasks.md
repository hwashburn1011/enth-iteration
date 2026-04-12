# Enth: Iteration — Demo Polish 50 Tasks

> Based on real playtester feedback + critical refinements for demo release.
> Compaction loop is 1/6 for the demo, not 1/9 (9 is full game).
> Never reveal total iteration count to the player.

## Phase 1 — CRASH FIX + ITERATION CONFIG [P0]

1. [x] **FIX: floor_config enemy_types typed Array[String] crash** — use .assign() instead of = [] on all floor configs
2. [ ] **Change FINAL_ITERATION from 9 to 6 for demo** — IterationManager.FINAL_ITERATION = 6
3. [ ] **Remove iteration count from compaction banner** — show "COMPACTION COMPLETE" not "ITERATION 1 → 2"
4. [ ] **Remove iteration count from dungeon entrance preview** — show difficulty tier, not raw number out of total
5. [ ] **Hide total iteration count from HUD chip** — show "LOOP 1" not "1/9"

## Phase 2 — PLAYER WEAPON (no sword in digital world) [P0]

6. [ ] **Replace sword mesh with digital weapon** — data blade / energy pulse emitter, not medieval sword
7. [ ] **Update attack VFX to match digital theme** — cyan/violet energy slash, not metal swing arc
8. [ ] **Update attack SFX concept** — electronic zap/pulse, not metal clang (stub if no audio file)

## Phase 3 — TOWN COLLISION CLEANUP [P0]

9. [ ] **Audit town for walk-through objects** — tent and other props missing collision; add StaticBody3D
10. [ ] **Find and fix invisible blocker in bottom-right of town** — phantom collision body blocking player
11. [ ] **Survey all town props >1m for missing collision** — anything large enough to look solid needs a body
12. [ ] **Verify dungeon entrance is reachable** — no invisible blockers between spawn and dungeon portal
13. [ ] **Verify AI Sage NPC is reachable** — walk from spawn to sage without getting stuck

## Phase 4 — PROP SCALE & READABILITY [P1]

14. [ ] **Audit town props for scale** — identify objects too small to read at isometric distance
15. [ ] **Scale up tiny props to minimum 0.5m** — anything under 0.5m is invisible from camera height
16. [ ] **Remove or replace random/out-of-place objects** — objects that don't fit the digital/AI theme
17. [ ] **Replace medieval-themed props** — anything looking like fantasy (tents, torches, wooden items) needs digital reskin
18. [ ] **Ensure NPC markers (! and ?) are visible** — scale up if too small at isometric zoom

## Phase 5 — COMBAT ROOM POLISH [P1]

19. [ ] **Verify all 5 floors load without errors after compaction** — play through iter 1 → iter 2 dungeon
20. [ ] **Verify room clear detection works on every room type** — kill all enemies, door opens
21. [ ] **Verify boss spawns on floor 5** — CorruptedCompiler appears via EnemySpawner
22. [ ] **Verify compaction portal appears after boss death** — portal spawns and is interactable
23. [ ] **Verify return to town after portal** — player lands in town, iteration advanced

## Phase 6 — HUD & UI POLISH [P1]

24. [ ] **Gold counter visible and updating** — kills award gold, shown on HUD
25. [ ] **Health bar visible and responsive** — damage reduces bar, heal restores
26. [ ] **Compute bar visible** — abilities drain compute, regen refills
27. [ ] **Quest widget shows active quest** — "The Compaction Loop" visible
28. [ ] **Death screen shows Continue + Quit** — not just black screen

## Phase 7 — NPC & DIALOGUE [P1]

29. [ ] **AI Sage dialogue triggers on first approach** — intro cinematic leads to sage
30. [ ] **Sage dialogue text is readable** — font size, contrast, typewriter speed OK
31. [ ] **Sage portrait displays** — portrait image shows in dialogue panel
32. [ ] **Interact prompt (E) appears near NPCs** — player knows to press E
33. [ ] **Vendor NPC opens shop** — talk to vendor, buy/sell panel appears

## Phase 8 — SAVE/LOAD & PROGRESSION [P1]

34. [ ] **Save triggers on key events** — boss kill, iteration advance, town entry
35. [ ] **Load game restores iteration** — quit and reload, same iteration number
36. [ ] **Load game restores inventory** — equipment persists across sessions
37. [ ] **Load game restores gold** — gold amount survives restart
38. [ ] **Load game restores level** — XP and level persist

## Phase 9 — VISUAL COHERENCE [P2]

39. [ ] **Dungeon environment matches digital theme** — no medieval textures remaining
40. [ ] **Town ground texture is digital/tech** — not grass or dirt looking
41. [ ] **Building textures are digital/tech** — circuit board / data stream aesthetic
42. [ ] **Enemies visually read as digital threats** — glitch bugs look like bugs, not blobs
43. [ ] **Boss has clear visual identity** — Corrupted Compiler looks imposing and distinct

## Phase 10 — GAME FEEL & POLISH [P2]

44. [ ] **Damage numbers readable** — clear font, sufficient size, not overlapping
45. [ ] **Enemy death feedback clear** — dissolve/fade, not just disappear
46. [ ] **Loot drops visible on ground** — glow or particle so player can see them
47. [ ] **Level-up notification clear** — player knows they leveled up
48. [ ] **Iteration advance feedback clear** — biome shift + banner makes the loop feel meaningful
49. [ ] **Main menu → New Game → Town loads in <5s** — no excessive load time
50. [ ] **ESC pause menu works mid-combat** — resume, settings, quit all functional
