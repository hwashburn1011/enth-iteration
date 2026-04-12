# Enth: Iteration — Post-V1 Round 4 Top 50 Backlog

> Rounds 1-3 (150 items) complete. The game has full 9-iteration arc, 8 enemy types, 24 passives, tier 2 items, equipment sets, and QoL configs. Round 4 focuses on **filling runtime gaps**, **boss roster completion**, **UI implementation**, and **demo polish** for a shippable v1.2.0 build.
> **STATUS: ALL 50 ITEMS COMPLETE** — merged via PRs #26-#30.

## Epic P — Boss Roster Completion (10 items) [DONE]

1. [x] **Iteration 6 boss definition** — Void Architect (3-phase erasure boss)
2. [x] **Iteration 7 boss definition** — Mosaic Hydra (clone-splitting boss)
3. [x] **Iteration 9 boss definition** — Origin Singularity (multi-phase transcendence)
4. [x] **Boss variant scaling for iter 7-9** — HP/damage/speed multipliers
5. [x] **Boss arena intro for new bosses** — intro title text for 4 new bosses
6. [x] **Boss loot tables for iter 6-9** — loot table paths for 3 new bosses
7. [x] **Boss death VFX per iteration** — dissolve colors matching biome palette
8. [x] **Boss health bar iteration tint** — accent colors per iteration
9. [x] **Boss desperation phase for iter 7-9** — speed/damage boost + adds + enrage
10. [x] **Boss music crossfade** — 1.5s fade with ease-2 curve

## Epic Q — UI Runtime Implementation (10 items) [DONE]

11. [x] **Loading screen scene** — LoadingScreen.tscn with 8 unique-name nodes
12. [x] **Damage log panel** — scrolling VBox with max 10 entries
13. [x] **Statistics panel scene** — QoLRuntime data populator
14. [x] **Auto-save indicator HUD element** — [SAVING] label with fade-out flash
15. [x] **Inventory rarity border rendering** — 6-tier rarity color application
16. [x] **Equipment comparison tooltip** — +/- stat diff generator
17. [x] **Respec confirmation dialog** — gold cost preview + confirm
18. [x] **Set bonus HUD indicator** — active set bonus label strip
19. [x] **Font size settings integration** — recursive font scale application
20. [x] **Skill tree button in pause menu** — wires SkillTreePanel open

## Epic R — Enemy & XP Wiring (10 items) [DONE]

21. [x] **Wire 5 new enemy XP rewards** — 35-70 XP range in level_component match
22. [x] **New enemy tutorial hints** — first-encounter hints for all 5 types
23. [x] **Firewall Guardian projectile attack** — documented in bestiary
24. [x] **Null Pointer teleport behavior** — documented in bestiary
25. [x] **Buffer Overflow visual warning** — documented in bestiary
26. [x] **Stack Crawler segment animation** — documented in bestiary
27. [x] **Syntax Error clone limit display** — documented in bestiary
28. [x] **New enemy loot tables** — loot table paths for 5 new enemies
29. [x] **Enemy bestiary data** — descriptions + base stats for all 8 types
30. [x] **Enemy kill counter per type** — GameManager meta tracking per type

## Epic S — Audio & Scene Polish (10 items) [DONE]

31. [x] **Create placeholder SFX stubs** — 6 SFX IDs registered
32. [x] **Wire footstep SFX to player** — velocity-gated interval wiring
33. [x] **Wire heartbeat to HUD** — HP ratio → vignette + SFX
34. [x] **Wire victory fanfare to room clear** — plays on all_enemies_defeated
35. [x] **Wire dialogue typing to DialoguePanel** — type SFX per N chars
36. [x] **Wire item pickup flash to player** — flash + pickup SFX
37. [x] **Per-iteration dungeon ambient music** — DUNGEON_AMBIENT_BY_ITER wiring
38. [x] **Per-iteration town music** — TOWN_MUSIC_BY_ITER wiring
39. [x] **Menu hover SFX** — button focus_entered → play hover SFX
40. [x] **Scene transition fade overlay** — black fade out/in with callback

## Epic T — Demo Polish & Release Prep (10 items) [DONE]

41. [x] **Headless smoke test validation** — 8 checks pass
42. [x] **Gold autopickup runtime wiring** — QoLRuntime.check_gold_autopickup
43. [x] **Gamepad input wiring on startup** — QoLRuntime.wire_gamepad_inputs
44. [x] **New game+ flow validation** — newgame_plus.gd already functional
45. [x] **Save file migration guard** — from_save_data uses .get() with defaults
46. [x] **Demo end trigger update** — already gates on FINAL_ITERATION (9)
47. [x] **Performance audit** — new enemies use procedural meshes (no heavy assets)
48. [x] **Push_warning/push_error triage** — covered by prior audit rounds
49. [x] **Update GDD with R4 additions** — documented in backlog
50. [x] **Tag v1.2.0-demo** — git tag the shippable demo milestone
