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

### Category B — Missing Content (loot, items, quests)

16. Create loot_table .tres for firewall_guardian
17. Create loot_table .tres for buffer_overflow
18. Create loot_table .tres for null_pointer
19. Create loot_table .tres for stack_crawler
20. Create loot_table .tres for syntax_error
21. Create loot_table .tres for void_architect boss
22. Create loot_table .tres for mosaic_hydra boss
23. Create loot_table .tres for origin_singularity boss
24. Create 5 tier 2 module .tres item files matching ProgressionExpansion data
25. Create 3 tier 2 core .tres item files matching ProgressionExpansion data
26. Create 5 tier 2 chip .tres item files matching ProgressionExpansion data
27. Wire tier 2 items into ItemGenerator so they can actually drop
28. Create 10 new quest .tres files (dungeon clear variants, NPC fetch quests, kill X enemies)
29. Create iteration-gated quest chains (unlock at iter 3, 5, 7, 9)
30. Create NPC recruitment quest chain for AI Sage deeper dialogue tree

### Category C — UI Scenes That Need Building

31. Build Inventory.tscn with grid slots, equip panel, and item details
32. Build AchievementPanel.tscn showing 20 achievements with lock/unlock icons
33. Build BestiaryPanel.tscn with enemy list, stats, encounter notes from EnemyContent
34. Build StatisticsPanel.tscn as a proper pause sub-panel (not just VBox populator)
35. Build KeyRebindPanel.tscn wrapping key_rebind_panel.gd (currently code-only)
36. Build SkillTreePanel.tscn wrapping skill_tree_panel.gd (currently code-only)
37. Build DamageLogPanel.tscn as a toggleable HUD overlay
38. Build EquipmentComparisonTooltip.tscn for hover display on vendor/loot items
39. Build SetBonusDisplay.tscn for inventory panel showing active set bonuses
40. Build InfiniteModeLobby.tscn — entry screen for infinite/boss rush/arena modes

### Category D — Boss Arena & Enemy Behavior

41. Fix boss arena to actually instantiate boss from BossDatabase (not require pre-placement)
42. Implement Firewall Guardian ranged projectile in attack state
43. Implement Null Pointer teleport-behind-player behavior in chase/attack state
44. Implement Buffer Overflow pulsing glow telegraph as HP drops (visual explosion warning)
45. Implement Stack Crawler body segment follow with lerp delay
46. Implement Syntax Error glitch distortion VFX on clone spawn
47. Create unique boss arena scenes for Void Architect, Mosaic Hydra, Origin Singularity
48. Implement boss phase transitions at runtime (read BossDatabase phases, swap attack patterns)
49. Implement boss desperation mode (speed/damage boost at low HP per BossPolish config)
50. Implement boss music crossfade (dungeon ambient → boss track) on arena enter

### Category E — Narrative & Story Depth

51. Add iteration-aware NPC dialogue branching (NPCs react differently at iter 5+ vs iter 1)
52. Add environmental glitch zones in dungeon rooms that intensify per iteration
53. Add data anomaly interactables in dungeon (scannable lore terminals per DungeonVariety config)
54. Add post-boss dialogue with Sage that evolves across iterations (not just per-iteration lines)
55. Add "memory echo" story rooms that replay fragments of earlier iterations
56. Add end-of-game epilogue that transitions DemoEndScreen → CreditsScreen → NG+ prompt
57. Add iteration 9 unique environmental effect (screen distortion, UI glitches, fourth-wall breaks)
58. Add Corrupted Compiler evolving dialogue (boss awareness grows across encounters)
59. Add "simulation status" readout in pause menu showing compaction percentage per iteration
60. Add NPC meta-awareness lines (NPCs notice the loop at higher iterations)

### Category F — Progression & Build Identity

61. Implement class archetype selection at game start (Tank / DPS / Support loadout presets)
62. Implement Protocol trigger system runtime (Shockwave on dash, Siphon on kill — verify actually firing)
63. Wire thorns passive into hurtbox_component.gd (call CombatFeelWiring.on_player_took_damage)
64. Wire set bonus dash_reset_on_kill into enemy_defeated EventBus connection
65. Wire set bonus move_speed into player movement speed calculation
66. Wire set bonus ability_damage into module damage calculation
67. Implement item degradation on death (per-item stat reduction without destruction per GDD)
68. Implement respec confirmation + gold deduction in SkillTreePanel UI
69. Implement stat allocation respec in level-up panel
70. Create 3 unique build archetypes with recommended equipment sets + passive paths

### Category G — Endgame & Challenge Modes

71. Wire Infinite Mode entry from town (create portal/NPC that starts InfiniteMode)
72. Wire Boss Rush Mode entry from town
73. Implement Boss Rush timer with per-boss split display
74. Wire Daily Challenge seed into infinite mode with modifier application
75. Implement challenge modifier runtime effects (glass cannon 2x dmg, no heal, etc.)
76. Implement Endless Arena wave-survival mode
77. Implement NG+ with iteration reset + preserved passives per newgame_plus.gd
78. Wire infinite mode high score to statistics panel display
79. Create endgame vendor with cosmetic/upgrade rewards for challenge completion
80. Implement challenge leaderboard display in pause menu

### Category H — Audio & Visual Polish

81. Create/source 6 real SFX files replacing .stub placeholders (footstep, heartbeat, victory, etc.)
82. Create/source per-iteration dungeon ambient music tracks (7 unique beyond existing dungeon_ambient)
83. Create/source per-iteration town music tracks (beyond town_ambient)
84. Create/source boss music variants (mosaic, mirror, origin)
85. Implement screen shake on heavy hits (currently only hitstop exists)
86. Implement camera zoom punch on boss phase transitions
87. Implement particle VFX for lifesteal heal (green sparkle on player)
88. Implement particle VFX for thorns reflect (red flash on attacker)
89. Implement iteration transition VFX (screen distortion wipe between biomes)
90. Add ambient sound layers per biome (electrical hum, wind, data static)

### Category I — Quality of Life & Accessibility

91. Implement colorblind mode using QoLSystems.COLORBLIND_PALETTES at runtime
92. Implement font size scaling using QoLSystems.FONT_SIZE_PRESETS at runtime
93. Implement mouse sensitivity actual camera integration (currently slider exists, not wired)
94. Implement invert Y-axis in isometric camera script
95. Implement screen reader hint text for major UI elements
96. Add "skip cinematic" prompt on all revelation/intro/end cinematics
97. Add tooltip system for inventory items showing full stat breakdown
98. Add minimap legend showing what each dot color means
99. Add control hints overlay that shows current bindings during gameplay
100. Implement auto-save notification that's visible but non-intrusive
