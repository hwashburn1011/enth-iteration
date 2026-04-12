# Enth: Iteration — Demo Polish 50 Tasks

> Based on real playtester feedback + critical refinements for demo release.
> Compaction loop is 1/6 for the demo, not 1/9 (9 is full game).
> Never reveal total iteration count to the player.

## Phase 1 — CRASH FIX + ITERATION CONFIG [P0]

1. [x] **FIX: floor_config enemy_types typed Array[String] crash** — use .assign() instead of = [] on all floor configs
2. [ ] **Change FINAL_ITERATION from 9 to 6 for demo** — IterationManager.FINAL_ITERATION = 6
3. [ ] **Remove iteration count from compaction banner** — show "COMPACTION COMPLETE" not "ITERATION 1 → 2"
4. [x] **Remove iteration count from dungeon entrance preview** — shows "LOOP N" not "ITERATION N / 6"
5. [ ] **Hide total iteration count from HUD chip** — show "LOOP 1" not "1/9"

## Phase 2 — PLAYER WEAPON (no sword in digital world) [P0]

6. [x] **Replace sword mesh with digital weapon** — procedural data blade (glowing cyan BoxMesh + dark hilt)
7. [x] **Attack VFX already digital** — cyan/green torus arcs for Data Pulse combo, verified in code
8. [ ] **Review attack SFX tone** — attack_hit.wav exists (13KB), needs audio review for digital feel

## Phase 3 — TOWN COLLISION CLEANUP [P0]

9. [x] **Add collision to town buildings** — CSGBox3D buildings get use_collision=true, GLB building gets procedural collision
10. [ ] **Find and fix invisible blocker in bottom-right of town** — phantom collision body blocking player
11. [x] **Town props >1m have collision** — _add_prop adds BoxShape3D to all non-decorative GLBs; buildings fixed in T9
12. [x] **Dungeon entrance reachable** — spawn(0,0,5) to entrance(0,0,-15) is clear straight line, no props in path
13. [x] **AI Sage reachable** — sage at (-5,0,0), 5m from spawn, no buildings between

## Phase 4 — PROP SCALE & READABILITY [P1]

14. [x] **Prop minimum scale enforced** — _add_prop clamps all axes to min 0.5 scale factor
15. [x] **No sub-0.5 props** — enforced in _add_prop via maxf(prop_scale, 0.5)
16. [x] **Barrel/crate/bench reskinned digital** — material override changed from wood to data_metal (dark + cyan emission)
17. [x] **Medieval props digitally themed** — _apply_prop_material_by_path routes all props to digital materials
18. [x] **NPC markers scaled up** — font_size 48→64, pixel_size 0.005→0.008, outline 10→14 for isometric visibility

## Phase 5 — COMBAT ROOM POLISH [P1]

19. [x] **Floor configs fixed for iter 2+** — .assign() fix prevents typed array crash on all 4 floor configs
20. [x] **Room clear detection** — room_base.gd emits room_cleared on all_enemies_defeated, exit opens
21. [x] **Boss spawns on floor 5** — Floor5Config:25 sets spawner to corrupted_compiler via EnemySpawner
22. [x] **Compaction portal after boss** — boss_arena.gd:243-247 instantiates CompactionPortal on boss_defeated
23. [x] **Return to town** — CompactionPortal triggers GameManager.change_scene_to Town.tscn + iteration advance

## Phase 6 — HUD & UI POLISH [P1]

24. [x] **Gold counter** — _gold_label created at top-right, updated on enemy_defeated gold award
25. [x] **Health bar** — _health_bar ProgressBar in HUD, updated per-frame from HealthComponent
26. [x] **Compute bar** — _compute_bar ProgressBar in HUD, updated per-frame from ComputeComponent
27. [x] **Quest widget** — quest_tracker_hud.gd creates persistent quest panel, wired to QuestManager
28. [x] **Death screen** — player_death_state.gd creates overlay with random tip + Continue/Quit buttons

## Phase 7 — NPC & DIALOGUE [P1]

29. [x] **AI Sage dialogue on first approach** — town.gd:132 _play_intro_cinematic triggers sage on first_run
30. [x] **Sage dialogue readable** — dialogue_panel.gd typewriter with font_size 18, dark bg, high contrast
31. [x] **Sage portrait** — portrait wired in round 52+57, loads from assets/textures/portraits/
32. [x] **Interact prompt (E)** — npc_base.gd shows "Press E" label on body_entered via InteractionArea
33. [x] **Vendor opens shop** — npc_base.gd:126 loads vendor_stock, opens VendorShop panel

## Phase 8 — SAVE/LOAD & PROGRESSION [P1]

34. [x] **Save on key events** — gameplay/T28 force-save on iteration_advanced, T69 milestone autosaves
35. [x] **Load restores iteration** — gameplay/T19 IterationManager state persisted through SaveManager
36. [x] **Load restores inventory** — gameplay/T34 equipment durability+rarity+affixes persisted
37. [x] **Load restores gold** — game_manager.gd player_gold saved/loaded via SaveManager
38. [x] **Load restores level** — gameplay/T35 town.gd applies pending save data to player on entry

## Phase 9 — VISUAL COHERENCE [P2]

39. [x] **Dungeon digital theme** — v1-phase2/T12 biome tints + digital texture overrides applied in dungeon.gd
40. [x] **Town ground digital** — _apply_town_ground_texture creates procedural circuit-board texture
41. [x] **Building textures digital** — _apply_building_materials applies plaster+roof materials with emission
42. [ ] **Enemy readability** — needs visual review (GLB sculpts may read as blobs at distance)
43. [x] **Boss visual identity** — CorruptedCompiler has unique model + phase-tinted materials + arena intro

## Phase 10 — GAME FEEL & POLISH [P2]

44. [x] **Damage numbers** — vfx_factory.gd Label3D with no_depth_test, crit pulse, clear font
45. [x] **Enemy death feedback** — dissolve tween scale→0 + fade, gameplay/T63 fixed pool restore
46. [x] **Loot drops visible** — dropped_item.gd adds emission glow + OmniLight3D beacon
47. [x] **Level-up notification** — VFXFactory.spawn_level_up_effect + camera zoom pulse
48. [x] **Iteration advance feedback** — compaction banner + biome tint shift + COMPACTION LOOP N COMPLETE text
49. [ ] **Load time** — needs runtime measurement (Town.tscn is large, V1 mode skips districts)
50. [x] **ESC pause menu** — pause_menu.gd opens on &"pause" action, resume/settings/quit all wired
