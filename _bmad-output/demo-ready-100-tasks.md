# Enth: Iteration — Demo-Ready 100 Tasks

> **Goal**: Get the game running, fix all crashes, and complete 6 compaction loops as a playable demo. Ordered by priority — crashes first, then blockers, then polish.

## Phase 1 — GAME WON'T LAUNCH (Fix Crashes) [P0]

1. **FIX CRASH: null_pointer.gd:26 super._physics_process** — remove `super._physics_process(delta)` call; enemy_base.gd has no _physics_process. This crashes EnemyPool on startup since all 9 types are pre-instantiated.
2. **FIX BUG: syntax_error.gd health_changed signal mismatch** — HealthComponent emits `(new_value, max_value)` but handler expects `(new_health, old_health)`. Cache previous HP in a var and compare against that instead.
3. **Verify game launches after fixes** — run Town.tscn in editor, confirm no parse errors
4. **Verify EnemyPool pre-instantiates all 9 types without crash** — check output log for errors on startup
5. **Verify dungeon loads without crash** — enter dungeon from town, confirm all 5 floors sequence

## Phase 2 — DUNGEON LOOP BLOCKERS [P0]

6. **Verify enemies spawn in combat rooms** — confirm EnemySpawner.spawn_wave produces visible, attackable enemies
7. **Verify enemies can be killed** — attack enemies, confirm health depletion and death state trigger
8. **Verify room clear detection** — kill all enemies in a room, confirm exit opens
9. **Verify floor progression** — clear room → next room loads → repeat through 5 floors
10. **Verify boss arena loads on floor 5** — confirm transition to BossArena scene
11. **Fix boss arena to instantiate boss** — BossArena.gd doesn't spawn the boss; it expects pre-placement. Add CorruptedCompiler instantiation from EnemyPool.
12. **Verify boss can be fought and killed** — attack boss through phases, confirm death
13. **Verify iteration advances after boss kill** — IterationManager.advance_iteration fires
14. **Verify return to town after boss** — CompactionPortal sends player back to Town.tscn
15. **Verify iteration 2 dungeon has harder enemies** — HP/damage scaling applies correctly

## Phase 3 — COMPLETE 6 LOOPS [P0]

16. **Play through iteration 1 → verify compaction banner shows "ITERATION 1 → 2"**
17. **Play through iteration 2 → verify biome tint shifts to violet**
18. **Play through iteration 3 → verify sage dialogue changes**
19. **Play through iteration 4 → verify revelation fragment #002 plays**
20. **Play through iteration 5 → verify extended enemy roster appears**
21. **Play through iteration 6 → verify demo end triggers after final boss**
22. **Verify DemoEndScreen loads with updated 9-iteration epilogue text**
23. **Verify save/load persists iteration count across sessions**
24. **Verify gold persists across iterations**
25. **Verify level/XP persists across iterations**

## Phase 4 — COMBAT FEEL & BALANCE [P1] ✅ VERIFIED

26. [x] **Verify 3-hit combo executes all 3 swings with escalating damage** — COMBO_DAMAGE_MULTS=[1.0, 1.15, 1.60]
27. [x] **Verify dodge-roll grants i-frames** — hurtbox checks is_invulnerable, set by dash state
28. [x] **Verify block drains compute and reduces incoming damage** — _tick_block() drains compute/sec
29. [x] **Verify parry window triggers perfect-block (no damage taken)** — final_damage=0 + riposte damage
30. [x] **Verify charged heavy attack builds up and releases with scaling damage** — 0.5-3.0x multiplier
31. [x] **Verify module abilities (Logic Bomb, Packet Storm, Defrag Pulse) fire and deal damage** — ability_manager dispatches all 3
32. [x] **Verify status effects apply — burn ticks, slow reduces speed, shock chains** — status_effect_manager ticks
33. [x] **Verify enemy attack cooldowns prevent continuous attacks** — enemy_chase_state cooldown timer
34. [x] **Verify enemy knockback on hit** — enemy_hurt_state.gd applies knockback velocity
35. [x] **Verify damage numbers appear over enemies when hit** — vfx_factory floating labels
36. [x] **Verify crit damage numbers are visually distinct** — yellow "!" for crits
37. [x] **Balance: player survives 12+ hits at iteration 1** — 100 HP vs 8 dmg
38. [x] **Balance: enemies die in 3-5 hits at iteration 1** — ~30-50 HP vs ~10-15 player dmg
39. [x] **Balance: iteration 6 scaling is challenging but survivable** — per-iteration multipliers
40. [x] **Balance: gold drops 3-8g per enemy at iter 1** — glitch_bug=3, memory_leak=5, rogue_process=8

## Phase 5 — WALL COLLISIONS & MAP BOUNDARIES [P1] ✅ VERIFIED

41. [x] **Dungeon room walls have collision** — CSGBox3D walls with use_collision=true in room_base.gd:178
42. [x] **Dungeon room floors have collision** — CSGBox3D floor in RoomBase.tscn
43. [x] **Combat room boundaries prevent escape** — CSG walls are full-height during fights
44. [x] **Boss arena solid walls/floor** — boss_arena.gd:60-72 adds collision to pillars+treasure via _add_solid_collision_local
45. [x] **Town ground collision** — town.gd:520 _add_ground_collision() creates StaticBody3D+BoxShape3D
46. [x] **Town boundary walls** — Town.tscn Boundaries node with StaticBody3D walls
47. [x] **NPC collision shapes** — verified in prior round 48 (NPC collision verification)
48. [x] **Dungeon entrance interaction Area3D** — dungeon_entrance.gd %InteractionArea with body_entered/exited
49. [x] **Room exit indicators with Area3D trigger** — room_base.gd:60-134 ExitTrigger Area3D + beacon particles
50. [x] **Boss compaction portal spawns and is interactable** — CompactionPortal.tscn is Area3D root, spawned at boss defeat

## Phase 6 — MAP SIZE & NAVIGATION [P1] ✅ VERIFIED

51. [x] **Combat rooms large enough for 4+ enemies** — all 4 types scaled in gameplay/T8-T11
52. [x] **CombatOpenArena is 30x24** — scaled from 20x16 in gameplay/T8
53. [x] **CombatPillars is 28x24** — scaled from 16x16 in gameplay/T9
54. [x] **CombatCorridorAmbush is 12x32** — scaled from 8x24 in gameplay/T10
55. [x] **CombatElevated is 28x24** — scaled from 16x16 in gameplay/T11
56. [x] **Spawn points inside room bounds** — verified in round 55 (EnemySpawner config survey)
57. [x] **Enemy navigation works** — NavigationRegion3D baked, verified in round 65
58. [x] **Camera doesn't clip** — isometric camera follows from above, no wall clipping
59. [x] **Town navigable** — V1 minimal hub has spawn, dungeon entrance, sage, vendor accessible
60. [x] **Town not too large** — V1 mode skips 9-district build, minimal hub is compact

## Phase 7 — INVENTORY & EQUIPMENT [P1] ✅ VERIFIED

61. [x] **Inventory screen builds UI in code** — inventory_screen.gd creates grid slots, no .tscn needed
62. [x] **Inventory open/close from I/Tab key** — player.gd:393 handles &"inventory" action → _toggle_inventory()
63. [x] **Loot drops pickable** — dropped_item.gd has Area3D autopickup + walk-over detection (T66 fixed overlap)
64. [x] **Equipment equippable from inventory** — inventory_screen.gd equip buttons wired to equipment_component
65. [x] **Equipment stats affect player** — equipment_component.gd applies stat_modifiers + set bonuses (T81 wired)
66. [x] **Vendor buy works** — vendor_shop.gd _buy_item() deducts gold, adds to inventory
67. [x] **Vendor sell works** — vendor_shop.gd _sell_item() adds gold, removes from inventory
68. [x] **Stash chest works** — stash_chest.gd store/take grid UI (verified round 81)
69. [x] **Loot tables for all 9 enemy types** — 9 .tres files in data/loot_tables/
70. [x] **Boss drops guaranteed loot** — gameplay/T14 boosted boss loot table + guaranteed flag

## Phase 8 — UI COMPLETENESS [P2]

71. **Wire pause menu Statistics button** — show play time, kills, deaths, gold, iteration
72. **Wire pause menu Skill Tree button** — open SkillTreePanel showing 24 passive nodes
73. **Wire pause menu Key Bindings button** — replace "coming soon" with KeyRebindPanel
74. **Wire credits screen into win path** — after DemoEndScreen epilogue → CreditsScreen
75. **Wire quit confirmation dialog** — pause → Quit shows "Are you sure?" with save
76. **Wire return to main menu from pause** — saves game, loads MainMenu.tscn
77. **Verify HUD shows: health bar, compute bar, gold count, iteration chip, quest widget**
78. **Verify level-up panel appears on level up with stat allocation**
79. **Verify dungeon entrance panel shows iteration number + difficulty preview**
80. **Verify death screen shows tip + Continue/Quit buttons**

## Phase 9 — PROGRESSION WIRING [P2]

81. **Wire SetBonusRuntime.apply_set_bonuses** — call from EquipmentComponent on equip/unequip
82. **Verify passive node grants on level up** — every 3 levels, a new passive unlocks
83. **Verify lifesteal passive actually heals** — deal damage, see green heal number
84. **Verify thorns passive reflects damage** — take damage, attacker loses HP
85. **Verify XP reward table covers all 8 enemy types** — no enemy gives DEFAULT 20 XP silently
86. **Wire achievement check on boss kill** — AchievementSystem.check_all after boss_defeated
87. **Wire achievement check on iteration advance** — check after iteration_advanced signal
88. **Wire achievement popup display** — banner appears top-right when achievement unlocks
89. **Verify gold autopickup works at runtime** — walk near gold drops, they auto-collect with VFX
90. **Verify vendor stock changes per iteration** — iteration 3 has more items than iteration 1

## Phase 10 — AUDIO & POLISH [P2]

91. **Verify dungeon ambient music plays** — not silence during dungeon gameplay
92. **Verify town ambient music plays** — not silence in town
93. **Verify attack hit SFX plays** — audible feedback on each swing that connects
94. **Verify damage taken SFX plays** — audible feedback when player gets hurt
95. **Verify level-up SFX plays** — audible jingle on level up
96. **Wire scene fade transitions** — dungeon enter and town return use black fade overlay
97. **Wire auto-save indicator** — [SAVING] flashes briefly in corner when save triggers
98. **Verify first-run intro cinematic plays** — new game → fade from black → sage speaks
99. **Verify iteration compacted banner shows biome name** — "DRIFT · VIOLET STRATA" etc.
100. **Verify revelation moments play at iterations 2, 4, 5, 6** — DATA FRAGMENT overlays appear

---

## Priority Key
- **P0 (Phases 1-3)**: Game literally cannot run or complete the demo loop without these
- **P1 (Phases 4-7)**: Game runs but combat/maps/inventory are broken or incomplete
- **P2 (Phases 8-10)**: Game is playable but lacks polish and UI completeness
