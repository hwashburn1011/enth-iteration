# Enth: Iteration — Post-V1 Round 3 Top 50 Backlog

> Rounds 1-2 (100 items) complete. The game has economy, combat depth, 6-iteration content, and polish configs. Round 3 focuses on **full-stack integration**, **new enemy content**, and **progression toward the 9-iteration full game**.

## Epic K — Full 9-Iteration Arc (10 items)

1. **Iteration 7 biome + sage dialogue** — FRAGMENTATION / GLITCH MOSAIC palette + sage lines
2. **Iteration 8 biome + sage dialogue** — RECURSION / INFINITE MIRROR palette + sage lines
3. **Iteration 9 biome + sage dialogue** — ORIGIN / PURE WHITE palette + sage final farewell
4. **FINAL_ITERATION 6→9** — update IterationManager cap to 9
5. **Iteration 7-9 revelation fragments** — DATA FRAGMENTS #005-#007
6. **9-iteration debrief text** — extend _iteration_debrief array to 9 entries
7. **Boss scaling curve for 7-9** — extend enemy_spawner promotion chances + HP/damage multipliers
8. **Iteration 7-9 vendor stock tiers** — extend VendorStock with iter 5-9 items
9. **Iteration 7-9 gold drop scaling** — extend GoldDrops.ITER_MULT to 9 entries
10. **Updated end cinematic for 9 iterations** — adjust epilogue text for full arc completion

## Epic L — New Enemy Types (10 items)

11. **Firewall Guardian** — new enemy: stationary shielded turret that fires projectiles
12. **Buffer Overflow** — new enemy: fast charger that explodes on death
13. **Null Pointer** — new enemy: teleporter that appears behind the player
14. **Stack Crawler** — new enemy: slow tanky worm with high HP
15. **Syntax Error** — new enemy: spawns glitch clones of itself when hit
16. **Enemy pool expansion** — register 5 new enemy types in EnemyPool
17. **New enemy .tscn scenes** — create minimal placeholder scenes for 5 new enemies
18. **Enemy mix table for iter 5-9** — extend _MIX_ROSTER + floor configs
19. **New enemy attack states** — create attack state scripts for 5 new enemy types
20. **New enemy promotion eligibility** — add 5 new types to enemy_promotion.ELIGIBLE_BY_TYPE

## Epic M — Progression Expansion (10 items)

21. **Passive node tree expansion** — 12→24 nodes, new effect types (lifesteal, thorns)
22. **Level cap increase** — 36→60 with adjusted XP curve
23. **Tier 2 modules** — 5 upgraded modules (Fork Bomb II, etc.) with higher base damage
24. **Tier 2 cores** — 3 upgraded cores with stacking effects
25. **Tier 2 chips** — 5 upgraded chips with enhanced passives
26. **Equipment set system** — define 3 item sets with 2-piece and 3-piece bonuses
27. **Set bonus runtime** — EquipmentComponent checks for set matches, applies bonuses
28. **Skill tree UI panel** — visual tree display in inventory showing unlocked/locked nodes
29. **Respec option** — reset passive allocations for gold cost (50g per node)
30. **Stat allocation respec** — reset level-up stat points for gold (100g)

## Epic N — Quality of Life II (10 items)

31. **Auto-pickup gold** — walk-over collection using QoLSystems.GOLD_AUTOPICKUP_RADIUS
32. **Minimap CanvasLayer** — implement the minimap using QoLSystems.MINIMAP_* config
33. **Damage log panel** — togglable scrolling combat log in HUD
34. **Statistics panel in pause** — detailed play stats accessible from pause menu
35. **Loading screen fade** — proper scene transition with loading spinner overlay
36. **Auto-save indicator icon** — small floppy disk icon flashes when save triggers
37. **Inventory rarity borders** — color-coded slot borders based on equipped item rarity
38. **Equipment comparison on hover** — show +/- stats when hovering vendor/loot items
39. **Gamepad input wiring** — add joypad events to project.godot input map
40. **Font size setting** — wire QoLSystems.FONT_SIZE_PRESETS into settings panel

## Epic O — Content & Bug Fix Sweep (10 items)

41. **Wire footstep SFX** — per-frame movement check, play AudioVisualPolish.FOOTSTEP_SFX
42. **Wire low health heartbeat** — HUD reads HP ratio, pulses vignette + heartbeat SFX
43. **Wire victory fanfare** — play AudioVisualPolish.VICTORY_SFX on all_enemies_defeated
44. **Wire dialogue typing SFX** — DialoguePanel plays keystroke every N characters
45. **Wire item pickup flash** — player mesh white flash on item_collected
46. **Enable SSAO** — set rendering/environment/ssao/enabled in project.godot
47. **Smoke test expansion** — add 8th check: gold persistence round-trip
48. **Warning audit** — grep for remaining push_warning/push_error and triage
49. **Dead system audit** — identify any remaining dead-data scripts not tagged V1-out
50. **Tag v1.1.0-extended** — git tag the 9-iteration extended demo milestone
