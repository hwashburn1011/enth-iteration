# Enth: Iteration — Post-V1 Round 5 Top 50 Backlog

> Rounds 1-4 (200 items) complete. Many systems have config data but no runtime consumers. Round 5 focuses on **wiring configs into live gameplay**, **passive effect runtime**, **tier 2 item generation**, and **audio integration**.

## Epic U — Passive Effect Runtime (10 items)

1. **Wire lifesteal passive** — _grant_passive handles "lifesteal" effect_type, heals % of damage dealt
2. **Wire thorns passive** — _grant_passive handles "thorns" effect_type, reflects % damage to attackers
3. **Wire "all" stat effect_key** — Final Optimization applies amount to all 4 stats
4. **Lifesteal VFX** — green heal number floats when lifesteal triggers
5. **Thorns VFX** — red reflect number floats when thorns triggers
6. **Passive effect persistence** — lifesteal/thorns values saved and loaded correctly
7. **Passive effect stacking** — multiple lifesteal/thorns nodes stack additively
8. **Passive tooltip in skill tree** — show current lifesteal/thorns % in SkillTreePanel
9. **Passive effect HUD indicator** — small icon showing active lifesteal/thorns
10. **Passive effect balance pass** — verify lifesteal 3%+5% and thorns 8%+15% feel right at level 60

## Epic V — Equipment Set & Tier 2 Runtime (10 items)

11. **Wire set bonuses at equip time** — EquipmentComponent calls get_active_bonuses on equip/unequip
12. **Set bonus stat application** — "stat" type bonuses add to stats_component
13. **Set bonus crit application** — "crit" type bonuses add to passive_crit_bonus meta
14. **Set bonus thorns application** — "thorns" type bonus adds to thorns meta
15. **Set bonus move speed application** — "move_speed" type modifies player move_speed
16. **Set bonus dash reset on kill** — "dash_reset_on_kill" resets dash cooldown on enemy kill
17. **Tier 2 item generation** — ItemGenerator recognizes tier 2 item_ids from ProgressionExpansion
18. **Tier 2 items in loot tables** — boss loot tables include tier 2 items at iter 7+
19. **Tier 2 items in vendor stock** — VendorStock includes tier 2 items at appropriate iterations
20. **Set bonus tooltip in inventory** — show active set bonuses on equipped item hover

## Epic W — Audio Integration (10 items)

21. **Wire footstep in player _physics_process** — call AudioSceneWiring.wire_footstep per frame
22. **Wire heartbeat in HUD _process** — call wire_heartbeat with player HP ratio
23. **Wire dungeon music per iteration** — call wire_dungeon_music in dungeon._ready
24. **Wire town music per iteration** — call wire_town_music in town._ready
25. **Wire victory fanfare on room clear** — connect EventBus.all_enemies_defeated
26. **Wire dialogue typing in DialoguePanel** — call wire_dialogue_type per character
27. **Wire pickup flash on item collected** — connect EventBus.item_collected
28. **Wire menu hover across all menus** — call wire_menu_hover on pause/inventory/vendor buttons
29. **Wire boss music crossfade** — fade from dungeon ambient to boss track on arena enter
30. **Create silent placeholder .wav files** — 6 minimal .wav stubs so AudioManager doesn't warn

## Epic X — Gold & Gamepad Startup Wiring (10 items)

31. **Wire gold autopickup in player** — call QoLRuntime.check_gold_autopickup in _physics_process
32. **Wire gamepad inputs on startup** — call QoLRuntime.wire_gamepad_inputs in GameManager._ready
33. **Gold pickup VFX** — floating "+Xg" number on autopickup (reuse VFXFactory.spawn_gold_number)
34. **Gold autopickup radius visualization** — subtle circle pulse when gold is nearby
35. **Damage log wiring in HUD** — create damage log panel and feed it combat events
36. **Statistics panel in pause menu** — wire HudWidgets.populate_stats_panel into pause menu
37. **Auto-save indicator wiring** — flash [SAVING] on SaveManager.save_game calls
38. **Rarity border wiring in inventory** — apply_rarity_border to each inventory slot
39. **Equipment comparison wiring** — show comparison tooltip on vendor/loot item hover
40. **Font size setting in options** — wire font scale dropdown into settings panel

## Epic Y — Integration Testing & Polish (10 items)

41. **Headless smoke test with R5 changes** — run full 8-check suite, fix any failures
42. **Add smoke test: passive node round-trip** — save/load passive allocations
43. **Add smoke test: new enemy pool** — verify all 8 enemy types instantiate from pool
44. **Add smoke test: boss database count** — assert BossDatabase.count() == 8
45. **Wire kill counter into enemy death** — call EnemyContent.increment_kill_count on defeat
46. **Kill counter in statistics panel** — show per-type kills in stats
47. **Respec runtime wiring** — respec button in SkillTreePanel deducts gold and resets passives
48. **New game+ iteration 9 test** — verify NG+ from iteration 9 resets to 1
49. **Clean up stale branches on remote** — delete any leftover feature branches
50. **Tag v1.3.0-integrated** — git tag the fully-integrated milestone
