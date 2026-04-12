# Enth: Iteration — Post-V1 Round 7 Top 50 Backlog

> Rounds 1-6 (300 items) complete. All systems have data + helpers but several lack the final call-site wiring into the game loop. Round 7 focuses on **closing wiring gaps**, **achievements**, **challenge content**, and **final integration**.

## Epic AE — Game Loop Wiring (10 items)

1. **Wire gold autopickup in player _physics_process** — add IntegrationWiring.wire_gold_autopickup call
2. **Wire gamepad inputs in GameManager._ready** — add IntegrationWiring.wire_gamepad_on_startup call
3. **Wire kill counter in EventBus.enemy_defeated** — connect IntegrationWiring.on_enemy_defeated_count
4. **Wire lifesteal in player attack hit** — connect CombatFeelWiring.on_player_dealt_damage
5. **Wire thorns in player hurtbox** — connect CombatFeelWiring.on_player_took_damage
6. **Wire dash reset on kill** — connect CombatFeelWiring.check_dash_reset_on_kill on enemy_defeated
7. **Wire set bonuses on equip** — call SetBonusRuntime.apply_set_bonuses from EquipmentComponent
8. **Wire footstep SFX in player** — add AudioSceneWiring.wire_footstep per-frame call
9. **Wire heartbeat in HUD** — add AudioSceneWiring.wire_heartbeat per-frame call
10. **Wire menu hover SFX** — call AudioSceneWiring.wire_menu_hover on all menu buttons

## Epic AF — Achievement System (10 items)

11. **Achievement database** — define 20 achievements with id, name, description, condition
12. **Achievement tracker** — runtime check against conditions on relevant events
13. **Achievement unlock notification** — banner popup when achievement earned
14. **Achievement persistence** — save/load unlocked achievements via SaveManager
15. **Achievement panel in pause** — list all achievements with locked/unlocked state
16. **Boss kill achievements** — "Defeat X boss" for each of the 8 bosses
17. **Iteration milestone achievements** — "Reach iteration N" for 3, 6, 9
18. **Kill count achievements** — "Defeat 100/500/1000 enemies"
19. **Gold milestones** — "Accumulate 100/500/1000 gold"
20. **Completionist achievement** — "Unlock all other achievements"

## Epic AG — Challenge & Endgame Content (10 items)

21. **Daily challenge seed** — rotate seed daily for infinite mode leaderboard
22. **Challenge modifiers** — 6 modifiers (glass cannon, no heal, fast enemies, etc.)
23. **Challenge reward scaling** — bonus gold/XP for completing with modifiers active
24. **Infinite mode floor counter HUD** — show current floor in infinite mode
25. **Infinite mode high score persistence** — save best floor reached
26. **Infinite mode leaderboard display** — show top 5 runs in pause menu
27. **Boss rush mode** — fight all 8 bosses in sequence
28. **Boss rush timer** — speedrun clock with per-boss splits
29. **Boss rush rewards** — unique cosmetic outfit for completion
30. **Endless arena mode** — survive waves of increasing difficulty

## Epic AH — Content Completeness (10 items)

31. **Verify all 9 sage dialogues load** — automated test
32. **Verify all 9 biome tints render** — automated test
33. **Verify all 8 boss database entries** — already covered by smoke test
34. **Verify all 9 revelation fragments play** — automated test
35. **Verify vendor stock scales through 9 iterations** — automated test
36. **Verify gold drops scale through 9 iterations** — automated test
37. **Verify promotion chances scale through 9 iterations** — automated test
38. **Verify enemy mix uses extended roster at iter 5+** — automated test
39. **Verify passive node tree has 24 entries** — automated test
40. **Verify level cap is 60** — automated test

## Epic AI — Final Release (10 items)

41. **Run full smoke test suite** — all checks pass
42. **Clean stale remote branches** — git push origin --delete for any leftovers
43. **Delete .claude/scheduled_tasks.lock** — clean up scheduled task artifacts
44. **Final git status clean** — no untracked files except .mcp.json and art sources
45. **Update MEMORY.md with R7 status** — document completion of all rounds
46. **Update project.godot version to 1.5.0** — bump version
47. **Create GitHub release with changelog** — gh release create v1.5.0-final
48. **Mark Round 7 backlog complete** — all [x] checked
49. **Tag v1.5.0-final** — git tag the final milestone
50. **Summary commit** — document 350 total items across 7 rounds
