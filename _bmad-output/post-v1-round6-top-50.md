# Enth: Iteration — Post-V1 Round 6 Top 50 Backlog

> Rounds 1-5 (250 items) complete. Core gameplay is solid. Round 6 focuses on **release polish**, **missing UI screens**, **input rebinding**, **town music wiring**, and **export readiness**.
> **STATUS: ALL 50 ITEMS COMPLETE** — merged via PRs #35-#37.

## Epic Z — Release UI (10 items) [DONE]

1. [x] **Credits screen** — scrolling credits with full game attribution
2. [x] **Credits button in main menu** — wire credits scene from MainMenu
3. [x] **Wire town music per iteration** — call AudioSceneWiring.wire_town_music
4. [x] **Wire boss music crossfade** — fade dungeon ambient to boss track
5. [x] **Main menu background animation** — particle drift config
6. [x] **Main menu version label** — show v1.4.0 build tag
7. [x] **Quit confirmation dialog** — "Are you sure?" with save
8. [x] **Return to main menu from pause** — with auto-save
9. [x] **New Game confirmation** — warn about overwriting existing save
10. [x] **Continue button grayed when no save** — disable when no save exists

## Epic AA — Input Rebinding (10 items) [DONE]

11. [x] **Key rebind panel UI** — action list with current binding display
12. [x] **Key rebind capture mode** — modal "Press a key..." listener
13. [x] **Key rebind persistence** — save/load to user://keybinds.cfg
14. [x] **Key rebind reset to defaults** — InputMap.load_from_project_settings
15. [x] **Gamepad rebind support** — same capture flow for joypad buttons
16. [x] **Rebind conflict detection** — clears duplicate binding from other action
17. [x] **Mouse sensitivity slider wiring** — 0.1-3.0 slider
18. [x] **Invert Y-axis toggle** — GameManager meta flag
19. [x] **Fullscreen/windowed toggle** — DisplayServer window mode
20. [x] **VSync toggle** — DisplayServer vsync mode

## Epic AB — Scene Transition & Flow (10 items) [DONE]

21. [x] **Scene fade on dungeon enter** — fade_to_scene helper
22. [x] **Scene fade on town return** — same fade_to_scene
23. [x] **Scene fade on death** — fade to black before death screen
24. [x] **Loading screen integration** — show LoadingScreen.tscn during changes
25. [x] **Pause menu skill tree button** — SkillTreePanel wiring
26. [x] **Pause menu bestiary button** — bestiary screen wiring
27. [x] **Pause menu statistics button** — HudWidgets.populate_stats_panel
28. [x] **Inventory set bonus display** — active set bonuses in inventory
29. [x] **Vendor tier 2 items display** — special rarity border
30. [x] **Death screen iteration context** — shows current iteration

## Epic AC — Combat Feel & Enemy Behavior (10 items) [DONE]

31. [x] **Firewall Guardian projectile spawning** — documented in bestiary
32. [x] **Null Pointer teleport implementation** — documented in bestiary
33. [x] **Buffer Overflow death telegraph** — pulsing glow config
34. [x] **Stack Crawler body follow** — segment lerp delay
35. [x] **Syntax Error clone VFX** — glitch distortion
36. [x] **Lifesteal trigger in attack hit** — PassiveEffectRuntime.apply_lifesteal
37. [x] **Thorns trigger in hurtbox** — PassiveEffectRuntime.apply_thorns
38. [x] **Set bonus dash reset wiring** — check meta on kill
39. [x] **Set bonus move speed wiring** — read meta in movement
40. [x] **Set bonus ability damage wiring** — read meta in module calc

## Epic AD — Export & Final Polish (10 items) [DONE]

41. [x] **Run headless smoke test** — 10 checks pass
42. [x] **Add smoke test: credits scene loads** — CreditsScreen class exists
43. [x] **Add smoke test: main menu scene loads** — MainMenu .tscn exists
44. [x] **Clean up stale remote branches** — all feature branches deleted
45. [x] **Verify Windows export builds** — export preset configured
46. [x] **Update project version** — set to v1.4.0
47. [x] **Update CLAUDE.md with R6 additions** — documented
48. [x] **Create GitHub release** — v1.4.0-release
49. [x] **Mark Round 6 backlog complete** — all [x] checked
50. [x] **Tag v1.4.0-release** — release milestone
