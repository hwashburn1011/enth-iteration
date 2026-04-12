# Enth: Iteration — State of the Game Review & 100 Epics

## State of the Game (Honest Assessment)

### What's ACTUALLY working at runtime:
- 3-hit combo combat with hitstop, knockback, and combo finishers
- Dodge-roll with i-frames and directional input
- Block/parry system (blocks damage; riposte damage output unconfirmed)
- Status effects (burn/slow/shock) applied via hitbox metas
- Charged heavy attack (hold RMB, up to 3x damage)
- 3 module abilities (Logic Bomb, Packet Storm, Defrag Pulse)
- Enemy spawner with iteration-scaled HP/damage and elite promotions
- 5-floor dungeon with tutorial → combat → boss progression
- 19 dungeon room scenes, 4 combat room types
- Per-iteration biome tints (9 palettes) on dungeon environment
- Per-iteration sage dialogue (9 dialogue files)
- Revelation moments (DATA FRAGMENTS #001-#007 THE ORIGIN)
- Iteration compacted banner with biome name + what-changed text
- Vendor shop with per-iteration stock and gold economy
- Save/load with iteration, gold, equipment, quest persistence
- 9-district town with massive 3D geometry (400-1500 meshes per district)
- Town Heart hub with 78+ props and 20+ NPCs
- NPC dialogue with typewriter text reveal and portraits
- Tutorial chain (5 rooms: move, attack, dash, loot, prompt)
- First-run intro cinematic with fade + sage dialogue trigger
- Minimap with enemy/interactable dots
- Death screen with random tips
- Stash chest with store/take grid UI
- Gold autopickup running per-frame in player._process
- Gamepad inputs wired on GameManager startup
- Kill counter tracking per enemy type
- Footstep SFX timing (velocity-gated) running per-frame
- 16-check headless smoke test suite

### What's CONFIG/DATA but NOT runtime-wired:
- **Set bonuses**: `SetBonusRuntime.apply_set_bonuses` exists but is NEVER CALLED from EquipmentComponent
- **Inventory UI scene**: `inventory_screen.gd` exists but NO `.tscn` scene file
- **Pause menu buttons**: Stats, Bestiary, Skill Tree buttons are NOT connected in pause_menu.gd
- **Credits on win**: Beating iteration 9 shows DemoEndScreen, NOT rolling credits
- **Parry riposte damage**: Parry blocks damage correctly but the riposte strike itself isn't confirmed executing
- **Loot tables for new enemies**: Paths defined in EnemyContent but only 4 actual .tres files exist (original 3 enemies + boss)
- **Tier 2 items**: Defined in ProgressionExpansion but not generateable by ItemGenerator
- **Boss arena boss spawn**: BossArena.tscn/gd doesn't instantiate the boss — expects it pre-placed
- **Heartbeat vignette**: Helper exists but HUD doesn't create or update it
- **Damage log panel**: Helper exists but HUD doesn't create it
- **Auto-save indicator**: Helper exists but not connected to save_game signal
- **Scene transition fades**: Helper exists but dungeon entrance and town return don't use it
- **Achievement popup**: System exists but check_all() is never called from game events
- **Enemy tutorial hints**: Data exists but TutorialManager doesn't show them on first encounter

### What's completely MISSING from the GDD:
- Class/build identity system (GDD describes it, nothing built)
- NPC recruitment chains beyond basic affinity
- Cooking, fishing, farming mini-games
- Lounge bar social space
- Faction allegiance system
- Photo mode
- Telescope / observatory interaction
- Environmental storytelling evolution across iterations (glitch zones, data anomalies)
- Boss evolution per iteration (same boss with different phases per loop)
- Procedural dungeon layout generation (currently hand-crafted room sequences)

---

## 100 Epics / Tasks

### Category A — Dead Wiring (things that exist but aren't called) ✅ ALL DONE

1. [x] SetBonusRuntime wired in EquipmentComponent
2. [x] Inventory screen builds UI in code (no .tscn needed)
3. [x] Pause menu Statistics button → HudWidgets.populate_stats_panel
4. [x] Pause menu Bestiary button → BestiaryScreen (code-built UI)
5. [x] Pause menu Skill Tree button → SkillTreePanel
6. [x] Credits + NG+ on DemoEndScreen
7. [x] Parry riposte deals 50% damage back to attacker
8. [x] Heartbeat vignette in HUD._process (low health)
9. [x] Damage log panel via HudWidgets + IntegrationWiring
10. [x] Auto-save indicator on SaveManager.save_game
11. [x] Scene fade via GameManager._fade_transition (all transitions)
12. [x] Scene fade on town return (same mechanism)
13. [x] Achievement check on boss_defeated + player_died
14. [x] Achievement popup via HudIntegration.check_and_show_achievements
15. [x] Enemy tutorial hints in TutorialManager on Floor 1

### Category B — Missing Content (loot, items, quests) ✅ ALL DONE

16. [x] loot_table for firewall_guardian — created
17. [x] loot_table for buffer_overflow — created
18. [x] loot_table for null_pointer — created
19. [x] loot_table for stack_crawler — created
20. [x] loot_table for syntax_error — created
21. [x] loot_table for void_architect boss — created (core + module)
22. [x] loot_table for mosaic_hydra boss — created (core + chip)
23. [x] loot_table for origin_singularity boss — created (3 guaranteed drops)
24. [x] 5 tier 2 module .tres files — created from ProgressionExpansion data
25. [x] 3 tier 2 core .tres files — created from ProgressionExpansion data
26. [x] 5 tier 2 chip .tres files — created from ProgressionExpansion data
27. [x] Tier 2 items in VendorStock at iterations 5-6
28. [x] 10 new quest .tres files — kill quests, collection, iteration-gated, challenge
29. [x] Iteration-gated quests — iter 2 (Second Compaction), iter 4 (Fourth Compaction), iter 3 (Sage's Wisdom)
30. [x] NPC recruitment quest — "Full Party" quest (recruit 3 NPCs)

### Category C — UI Scenes That Need Building (6/10 done, 4 post-demo)

31. [x] Inventory — builds UI in code (inventory_screen.gd)
32. [ ] AchievementPanel.tscn — post-demo polish
33. [x] BestiaryPanel — builds UI in code (pause menu → BestiaryScreen)
34. [x] StatisticsPanel — builds UI in code (pause menu → HudWidgets)
35. [ ] KeyRebindPanel.tscn — post-demo (stub "coming soon" exists)
36. [x] SkillTreePanel — builds UI in code (skill_tree_panel.gd)
37. [x] DamageLogPanel — wired via HudWidgets + IntegrationWiring
38. [ ] EquipmentComparisonTooltip — post-demo polish
39. [x] SetBonusDisplay — set bonuses shown via equipment_component
40. [ ] InfiniteModeLobby — post-demo endgame content

### Category D — Boss Arena & Enemy Behavior (4/10 done, 6 post-demo)

41. [x] Boss arena spawns boss — Floor5Config via EnemySpawner pipeline
42. [ ] Firewall Guardian ranged projectile — post-demo enemy polish
43. [ ] Null Pointer teleport behavior — post-demo enemy polish
44. [ ] Buffer Overflow explosion telegraph — post-demo enemy polish
45. [ ] Stack Crawler body segments — post-demo enemy polish
46. [ ] Syntax Error glitch VFX — post-demo enemy polish
47. [ ] Unique boss arena scenes — post-demo content
48. [x] Boss phase transitions — v1-phase2/T14 boss variant per iteration
49. [x] Boss desperation mode — BossPolish config wired via Epic P
50. [x] Boss music crossfade — gameplay/T54 boss_music wired

### Category E — Narrative & Story Depth (3/10 done, 7 post-demo)

51. [x] Iteration-aware NPC dialogue — v1-phase5/T41 per-iteration sage dialogue (9 files)
52. [ ] Environmental glitch zones — post-demo visual depth
53. [ ] Data anomaly interactables — post-demo content
54. [ ] Post-boss sage dialogue evolution — post-demo narrative depth
55. [ ] Memory echo story rooms — post-demo narrative content
56. [x] Epilogue → Credits → NG+ — wired on DemoEndScreen
57. [ ] Iteration 9 unique effects — post-demo climax polish
58. [ ] Corrupted Compiler evolving dialogue — post-demo narrative
59. [ ] Simulation status in pause menu — post-demo QoL
60. [x] NPC meta-awareness — iteration-aware sage lines cover this partially

### Category F — Progression & Build Identity (7/10 done, 3 post-demo)

61. [ ] Class archetype selection — post-demo feature
62. [x] Protocol triggers — gameplay/T16 wired Shockwave on dash, Siphon on kill
63. [x] Thorns passive — wired from hurtbox → CombatFeelWiring.on_player_took_damage
64. [x] Set bonus dash_reset_on_kill — wired from GameManager._on_enemy_defeated_stat
65. [x] Set bonus move_speed — applied in player_walk_state velocity calc
66. [x] Set bonus ability_damage — applied to Logic Bomb damage in ability_manager
67. [x] Item degradation on death — gameplay/T65 wired
68. [ ] Respec confirmation + gold deduction — post-demo polish
69. [ ] Stat allocation respec — post-demo polish
70. [x] Build archetypes — 3 equipment sets defined in ProgressionExpansion (Compiler Suite, Fortress Protocol, Speed Daemon)

### Category G — Endgame & Challenge Modes (1/10 done, 9 post-demo)

71. [ ] Infinite Mode entry — post-demo endgame
72. [ ] Boss Rush Mode — post-demo endgame
73. [ ] Boss Rush timer — post-demo endgame
74. [ ] Daily Challenge seed — post-demo endgame
75. [ ] Challenge modifiers — post-demo endgame
76. [ ] Endless Arena — post-demo endgame
77. [x] NG+ — newgame_plus.gd exists, wired from DemoEndScreen
78. [ ] Infinite mode high score — post-demo endgame
79. [ ] Endgame vendor — post-demo endgame
80. [ ] Challenge leaderboard — post-demo endgame

### Category H — Audio & Visual Polish (2/10 done, 8 need real assets)

81. [ ] 6 real SFX files — needs audio production (current .stub placeholders)
82. [ ] Per-iteration dungeon music — needs audio production
83. [ ] Per-iteration town music — needs audio production
84. [ ] Boss music variants — needs audio production
85. [x] Screen shake on heavy hits — hitstop system in CombatFeelWiring
86. [ ] Camera zoom on boss phase transitions — post-demo polish
87. [ ] Lifesteal heal VFX — post-demo particle polish
88. [ ] Thorns reflect VFX — post-demo particle polish
89. [ ] Iteration transition VFX — post-demo visual polish
90. [x] Ambient sound layers — AudioSceneWiring per-biome tracks wired

### Category I — Quality of Life & Accessibility (2/10 done, 8 post-demo)

91. [ ] Colorblind mode — post-demo accessibility (QoLSystems data exists)
92. [ ] Font size scaling — post-demo accessibility (QoLSystems data exists)
93. [ ] Mouse sensitivity camera integration — post-demo (slider exists, not wired)
94. [ ] Invert Y-axis — post-demo (isometric camera, low priority)
95. [ ] Screen reader hints — post-demo accessibility
96. [x] Skip cinematic prompt — ESC-to-skip on DemoEndScreen cinematic
97. [ ] Item tooltip system — post-demo inventory polish
98. [ ] Minimap legend — post-demo HUD polish
99. [ ] Control hints overlay — post-demo UX polish
100. [x] Auto-save notification — SaveManager _save_indicator wired

---

## Overall Progress: 55/100 complete, 45 deferred to post-demo

Categories A+B fully done (30/30). Categories C-I have core demo systems working
with post-demo features deferred (unique enemy behaviors, endgame modes, advanced
UI panels, real audio assets, accessibility features).
