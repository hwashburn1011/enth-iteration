# Enth: Iteration — Post-V1 Round 8 Top 50 Backlog (FINAL ROUND)

> Rounds 1-7 (350 items) complete. 455 scripts, 44 scenes, 13-check smoke suite, 5 milestone tags. Round 8 is the **final polish round** — closing the last integration gaps, hardening save/load, and ensuring every wired system actually connects end-to-end.

## Epic AJ — Save/Load Hardening (10 items)

1. **Save achievement data in SaveManager** — wire AchievementSystem.to_save_data into save pipeline
2. **Load achievement data in SaveManager** — wire AchievementSystem.from_save_data on load
3. **Save infinite mode high score** — persist ChallengeContent high score through save
4. **Save key rebindings on quit** — auto-save keybinds.cfg when game exits
5. **Save kill counters per enemy type** — persist EnemyContent kill counts via GameManager metas
6. **Save passive lifesteal/thorns metas** — ensure passive effect metas round-trip through save
7. **Graceful load of pre-R8 saves** — default missing fields to safe values
8. **Save file version header** — add "save_version": 8 field for future migration
9. **Corrupt save recovery** — if JSON parse fails, load backup instead of crashing
10. **Auto-backup before overwrite** — rotate save_backup_1 before writing new save

## Epic AK — HUD Integration (10 items)

11. **Wire heartbeat vignette in HUD** — create ColorRect + call wire_heartbeat per frame
12. **Wire damage log in HUD** — create damage log panel and feed enemy_defeated events
13. **Wire auto-save indicator in HUD** — flash on SaveManager.save_game signal
14. **Wire achievement popup** — show banner when AchievementSystem.check_all returns newly unlocked
15. **Wire statistics panel in pause** — add "Statistics" button that populates stats panel
16. **Wire skill tree in pause** — add "Skill Tree" button that opens SkillTreePanel
17. **Wire bestiary in pause** — add "Bestiary" button that opens bestiary screen
18. **Wire key rebind in settings** — replace "coming soon" stub with KeyRebindPanel
19. **Wire credits in main menu** — add "Credits" button that loads CreditsScreen
20. **Wire quit dialog from pause** — replace direct quit with ReleaseUI.show_quit_dialog

## Epic AL — Combat Integration (10 items)

21. **Wire lifesteal on attack hit** — connect _on_damage_dealt to CombatFeelWiring.on_player_dealt_damage
22. **Wire thorns on player hurt** — connect hurtbox to CombatFeelWiring.on_player_took_damage
23. **Wire dash reset on kill** — connect enemy_defeated to CombatFeelWiring.check_dash_reset_on_kill
24. **Wire move speed bonus** — read set_bonus_move_speed in player movement calculation
25. **Wire ability damage bonus** — read set_bonus_ability_damage in module damage calculation
26. **Wire set bonuses on equip change** — call SetBonusRuntime.apply_set_bonuses after equip/unequip
27. **Check achievements on key events** — call AchievementSystem.check_all after boss kill, level up, death
28. **Wire enemy tutorial hints** — show EnemyContent hint on first encounter with new type
29. **Wire scene fade on dungeon enter** — use CombatFeelWiring.fade_to_scene for portal
30. **Wire scene fade on town return** — use CombatFeelWiring.fade_to_scene for return

## Epic AM — Content Validation (10 items)

31. **Smoke test: achievement system save/load** — round-trip test
32. **Smoke test: vendor stock iter 9** — verify stock returns items at iteration 9
33. **Smoke test: gold drop scaling iter 9** — verify ITER_MULT[8] returns 4.2
34. **Smoke test: passive node "all" key** — verify Final Optimization applies to 4 stats
35. **Smoke test: enemy XP rewards complete** — verify all 8 types have XP in level_component
36. **Smoke test: revelation fragments 7-9** — verify has_revelation returns true for 7,8,9
37. **Smoke test: sage dialogue iter 9** — verify dialogue file exists
38. **Smoke test: credits screen class** — verify CreditsScreen class is loadable
39. **Smoke test: key rebind panel class** — verify KeyRebindPanel class is loadable
40. **Run full 18+ check suite** — verify all existing + new checks pass

## Epic AN — Final Release (10 items)

41. **Delete .claude/scheduled_tasks.lock** — clean up cron artifacts
42. **Clean stale remote branches** — verify no leftover feature branches
43. **Update R8 backlog as complete** — mark all [x]
44. **Update MEMORY.md** — document 400 items across 8 rounds
45. **Bump project version to 1.6.0** — update project.godot
46. **Create changelog** — summarize all 8 rounds in one document
47. **GitHub release v1.6.0-final** — gh release create with changelog
48. **Tag v1.6.0-final** — final git tag
49. **Final summary commit** — 400 items, 8 rounds, project complete
50. **Mark this as the FINAL backlog** — no more rounds needed
