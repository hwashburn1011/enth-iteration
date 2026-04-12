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

## Phase 4 — COMBAT FEEL & BALANCE [P1]

26. **Verify 3-hit combo executes all 3 swings with escalating damage**
27. **Verify dodge-roll grants i-frames (player doesn't take damage during roll)**
28. **Verify block drains compute and reduces incoming damage**
29. **Verify parry window triggers perfect-block (no damage taken)**
30. **Verify charged heavy attack builds up and releases with scaling damage**
31. **Verify module abilities (Logic Bomb, Packet Storm, Defrag Pulse) fire and deal damage**
32. **Verify status effects apply — burn ticks, slow reduces speed, shock chains**
33. **Verify enemy attack cooldowns prevent continuous attacks**
34. **Verify enemy knockback on hit (visual feedback that you're hitting them)**
35. **Verify damage numbers appear over enemies when hit**
36. **Verify crit damage numbers are visually distinct (larger, different color)**
37. **Balance: verify player doesn't die in 1-2 hits at iteration 1**
38. **Balance: verify enemies don't feel like damage sponges at iteration 1**
39. **Balance: verify iteration 6 enemies are challenging but not impossible**
40. **Balance: verify gold drops feel rewarding (3-8g per enemy at iter 1)**

## Phase 5 — WALL COLLISIONS & MAP BOUNDARIES [P1]

41. **Verify dungeon room walls have collision shapes** — player can't walk through walls
42. **Verify dungeon room floors have collision** — player doesn't fall through ground
43. **Verify combat room boundaries prevent player from leaving during fights**
44. **Verify boss arena has solid walls/floor/boundaries**
45. **Verify town ground collision — player walks on ground, not through it**
46. **Verify town boundary walls — player can't walk off the edge of the world**
47. **Verify NPC collision shapes — player can't walk through NPCs**
48. **Verify dungeon entrance portal has interaction area that works**
49. **Verify room exit indicators are visible and trigger correctly**
50. **Verify boss compaction portal spawns and is interactable after boss kill**

## Phase 6 — MAP SIZE & NAVIGATION [P1]

51. **Audit combat room sizes** — verify rooms are large enough for 4+ enemies + player to move freely
52. **Verify CombatOpenArena is 30x24 (not 20x16)** — confirm prior scaling commit applied
53. **Verify CombatPillars is 28x24 with spread pillars** — confirm prior scaling commit
54. **Verify CombatCorridorAmbush is 12x32** — confirm prior scaling
55. **Verify CombatElevated is 28x24** — confirm prior scaling
56. **Verify spawn points are inside room bounds** — enemies don't spawn outside walls
57. **Verify enemy navigation doesn't get stuck on room geometry**
58. **Verify player camera doesn't clip through walls in tight corridors**
59. **Verify town is navigable — player can reach dungeon entrance, sage, vendor, stash**
60. **Verify town isn't so large that it takes forever to traverse** — fast-travel or smaller hub option

## Phase 7 — INVENTORY & EQUIPMENT [P1]

61. **Create Inventory.tscn scene file** — inventory_screen.gd exists without a scene
62. **Wire inventory open/close from pause menu or I key**
63. **Verify loot drops from enemies are pickable** — walk over item, it enters inventory
64. **Verify equipment can be equipped from inventory** — select item, equip to slot
65. **Verify equipment stats affect player** — equipping a +3 processing chip raises processing
66. **Verify vendor buy transaction works** — click buy, gold deducted, item added
67. **Verify vendor sell transaction works** — click sell, gold added, item removed
68. **Verify stash chest store/take works** — items transfer between inventory and stash
69. **Create loot tables for 5 new enemy types** — firewall_guardian, buffer_overflow, null_pointer, stack_crawler, syntax_error
70. **Verify boss drops guaranteed loot on death**

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
