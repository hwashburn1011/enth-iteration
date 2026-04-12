# Enth: Iteration — Post-V1 Round 6 Top 50 Backlog

> Rounds 1-5 (250 items) complete. Core gameplay is solid. Round 6 focuses on **release polish**, **missing UI screens**, **input rebinding**, **town music wiring**, and **export readiness**.

## Epic Z — Release UI (10 items)

1. **Credits screen** — scrolling credits with team/tool attribution after demo end
2. **Credits button in main menu** — wire credits scene from MainMenu
3. **Wire town music per iteration** — call AudioSceneWiring.wire_town_music in town._ready
4. **Wire boss music crossfade** — fade dungeon ambient → boss track on boss arena enter
5. **Main menu background animation** — subtle particle drift on MainMenu scene
6. **Main menu version label** — show "v1.3.0" build tag in corner
7. **Quit confirmation dialog** — "Are you sure?" before quitting to desktop
8. **Return to main menu from pause** — wire pause menu "Main Menu" button with save
9. **New Game confirmation** — warn about overwriting existing save
10. **Continue button grayed when no save** — disable Continue if no save file exists

## Epic AA — Input Rebinding (10 items)

11. **Key rebind panel UI** — list all actions with current binding + "Press key" capture
12. **Key rebind capture mode** — modal input listener that records next keypress
13. **Key rebind persistence** — save/load custom bindings to user://keybinds.cfg
14. **Key rebind reset to defaults** — restore project.godot default bindings
15. **Gamepad rebind support** — same capture flow for joypad buttons
16. **Rebind conflict detection** — warn if two actions share the same key
17. **Mouse sensitivity slider wiring** — wire existing stub into actual camera sensitivity
18. **Invert Y-axis toggle** — add checkbox in settings, wire to camera script
19. **Fullscreen/windowed toggle** — add dropdown in settings, wire to DisplayServer
20. **VSync toggle** — add checkbox in settings, wire to DisplayServer

## Epic AB — Scene Transition & Flow (10 items)

21. **Scene fade on dungeon enter** — use AudioSceneWiring.create_scene_fade on portal click
22. **Scene fade on town return** — fade when returning from dungeon
23. **Scene fade on death** — fade to black before death screen
24. **Loading screen integration** — show LoadingScreen.tscn during scene changes
25. **Pause menu skill tree button** — wire SkillTreePanel.new() from pause menu
26. **Pause menu bestiary button** — wire bestiary screen from pause menu
27. **Pause menu statistics button** — wire HudWidgets.populate_stats_panel from pause
28. **Inventory set bonus display** — show active set bonuses in inventory panel
29. **Vendor tier 2 items display** — show tier 2 items with special rarity border
30. **Death screen iteration context** — show current iteration on death screen

## Epic AC — Combat Feel & Enemy Behavior (10 items)

31. **Firewall Guardian projectile spawning** — fire data packet projectile from attack state
32. **Null Pointer teleport implementation** — blink behind player in chase state
33. **Buffer Overflow death telegraph** — pulsing glow + screen edge warning before explosion
34. **Stack Crawler body follow** — segment meshes trail the head with lerp delay
35. **Syntax Error clone VFX** — glitch distortion effect when spawning clone
36. **Lifesteal trigger in attack hit** — call PassiveEffectRuntime.apply_lifesteal on damage dealt
37. **Thorns trigger in hurtbox** — call PassiveEffectRuntime.apply_thorns when player takes damage
38. **Set bonus dash reset wiring** — check dash_reset_on_kill meta on enemy_defeated
39. **Set bonus move speed wiring** — read set_bonus_move_speed meta in player movement
40. **Set bonus ability damage wiring** — read set_bonus_ability_damage in module damage calc

## Epic AD — Export & Final Polish (10 items)

41. **Run headless smoke test** — verify all 10 checks pass
42. **Add smoke test: credits scene loads** — verify credits .tscn instantiates
43. **Add smoke test: main menu scene loads** — verify MainMenu .tscn instantiates
44. **Clean up stale remote branches** — delete any leftover feature branches
45. **Verify Windows export builds** — test export preset produces working .exe
46. **Update project version in project.godot** — set config/version to "1.4.0"
47. **Update CLAUDE.md with R6 additions** — document new screens and systems
48. **Create GitHub release** — gh release create v1.4.0-release with changelog
49. **Mark Round 6 backlog complete** — update this file with all [x] checkboxes
50. **Tag v1.4.0-release** — git tag the release-ready milestone
