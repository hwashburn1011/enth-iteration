# Enth: Iteration — Post-V1 Round 4 Top 50 Backlog

> Rounds 1-3 (150 items) complete. The game has full 9-iteration arc, 8 enemy types, 24 passives, tier 2 items, equipment sets, and QoL configs. Round 4 focuses on **filling runtime gaps**, **boss roster completion**, **UI implementation**, and **demo polish** for a shippable v1.2.0 build.

## Epic P — Boss Roster Completion (10 items)

1. **Iteration 6 boss definition** — add boss_database entry for DECOMPRESSION biome boss
2. **Iteration 7 boss definition** — FRAGMENTATION biome boss with glitch-clone mechanics
3. **Iteration 9 boss definition** — ORIGIN final boss with multi-phase transcendence fight
4. **Boss variant scaling for iter 7-9** — extend boss variant table with harder modifiers
5. **Boss arena intro for new bosses** — extend cinematic intro to reference new boss names
6. **Boss loot tables for iter 6-9** — create loot_table .tres for 4 new bosses
7. **Boss death VFX per iteration** — distinct death dissolve colors matching biome palette
8. **Boss health bar iteration tint** — tint boss HP bar accent to match biome color
9. **Boss desperation phase for iter 7-9** — extend CombatDepthV2 desperation triggers
10. **Boss music crossfade** — smooth transition from dungeon ambient to boss_music on arena enter

## Epic Q — UI Runtime Implementation (10 items)

11. **Loading screen scene** — create LoadingScreen.tscn matching LoadingScreen.gd expectations
12. **Damage log panel** — scrolling combat log Control in HUD showing last 10 events
13. **Statistics panel scene** — pause menu sub-panel displaying QoLRuntime.get_play_statistics()
14. **Auto-save indicator HUD element** — floppy disk icon that flashes on save_game()
15. **Inventory rarity border rendering** — wire QoLRuntime.RARITY_BORDER_COLORS into inventory slots
16. **Equipment comparison tooltip** — show +/- stat diffs on vendor/loot item hover
17. **Respec confirmation dialog** — gold cost preview + confirm/cancel for passive/stat respec
18. **Set bonus HUD indicator** — small icon strip showing active equipment set bonuses
19. **Font size settings integration** — wire font scale into settings panel dropdown
20. **Skill tree button in pause menu** — wire SkillTreePanel open from pause menu

## Epic R — Enemy & XP Wiring (10 items)

21. **Wire 5 new enemy XP rewards** — add firewall_guardian/buffer_overflow/null_pointer/stack_crawler/syntax_error to level_component XP table
22. **New enemy tutorial hints** — TutorialManager entries for first encounter with each new type
23. **Firewall Guardian projectile attack** — implement ranged projectile in attack state
24. **Null Pointer teleport behavior** — implement blink-behind-player in chase/attack states
25. **Buffer Overflow visual warning** — pulsing glow intensifies as HP drops (explosion telegraph)
26. **Stack Crawler segment animation** — body segments follow head with slight delay
27. **Syntax Error clone limit display** — show remaining clone count above enemy
28. **New enemy loot tables** — create loot_table .tres for 5 new enemy types
29. **Enemy bestiary data** — descriptions + stats for pause menu bestiary panel
30. **Enemy kill counter per type** — track and display per-type kill counts in statistics

## Epic S — Audio & Scene Polish (10 items)

31. **Create placeholder SFX stubs** — .wav files for footstep, heartbeat, victory, dialogue_type, pickup
32. **Wire footstep SFX to player** — call AudioVisualWiring.should_play_footstep in player _physics_process
33. **Wire heartbeat to HUD** — call get_heartbeat_state, tint vignette, play SFX
34. **Wire victory fanfare to room clear** — call play_victory_fanfare on all_enemies_defeated
35. **Wire dialogue typing to DialoguePanel** — play type SFX every N characters during text reveal
36. **Wire item pickup flash to player** — call flash_pickup on item_collected EventBus signal
37. **Per-iteration dungeon ambient music** — wire AudioVisualPolish.DUNGEON_AMBIENT_BY_ITER in dungeon _ready
38. **Per-iteration town music** — wire AudioVisualPolish.TOWN_MUSIC_BY_ITER in town _ready
39. **Menu hover SFX** — play MENU_HOVER_SFX on button focus_entered across all menus
40. **Scene transition fade overlay** — black ColorRect fade-out/fade-in on scene changes

## Epic T — Demo Polish & Release Prep (10 items)

41. **Headless smoke test validation** — run smoke test, fix any failures from R4 changes
42. **Gold autopickup runtime wiring** — call QoLRuntime.check_gold_autopickup in player _physics_process
43. **Gamepad input wiring on startup** — call QoLRuntime.wire_gamepad_inputs in GameManager _ready
44. **New game+ flow validation** — verify newgame_plus.gd works end-to-end after iteration 9
45. **Save file migration guard** — handle loading old saves missing new R4 fields gracefully
46. **Demo end trigger update** — should_trigger_demo_end gates on iteration 9 (not 6)
47. **Performance audit** — check particle counts and cull distances for 5 new enemy types
48. **Push_warning/push_error triage** — grep and resolve any new warnings from R4 code
49. **Update GDD with R4 additions** — document new enemies, bosses, items in game design doc
50. **Tag v1.2.0-demo** — git tag the shippable demo milestone
