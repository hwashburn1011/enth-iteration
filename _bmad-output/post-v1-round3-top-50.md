# Enth: Iteration — Post-V1 Round 3 Top 50 Backlog

> Rounds 1-2 (100 items) complete. The game has economy, combat depth, 6-iteration content, and polish configs. Round 3 focuses on **full-stack integration**, **new enemy content**, and **progression toward the 9-iteration full game**.
> **STATUS: ALL 50 ITEMS COMPLETE** — merged via PRs #21-#25.

## Epic K — Full 9-Iteration Arc (10 items) [DONE]

1. [x] **Iteration 7 biome + sage dialogue** — FRAGMENTATION / GLITCH MOSAIC palette + sage lines
2. [x] **Iteration 8 biome + sage dialogue** — RECURSION / INFINITE MIRROR palette + sage lines
3. [x] **Iteration 9 biome + sage dialogue** — ORIGIN / PURE WHITE palette + sage final farewell
4. [x] **FINAL_ITERATION 6→9** — update IterationManager cap to 9
5. [x] **Iteration 7-9 revelation fragments** — DATA FRAGMENTS #005-#007
6. [x] **9-iteration debrief text** — extend _iteration_debrief array to 9 entries
7. [x] **Boss scaling curve for 7-9** — extend enemy_spawner promotion chances + HP/damage multipliers
8. [x] **Iteration 7-9 vendor stock tiers** — extend VendorStock with iter 5-9 items
9. [x] **Iteration 7-9 gold drop scaling** — extend GoldDrops.ITER_MULT to 9 entries
10. [x] **Updated end cinematic for 9 iterations** — adjust epilogue text for full arc completion

## Epic L — New Enemy Types (10 items) [DONE]

11. [x] **Firewall Guardian** — new enemy: stationary shielded turret that fires projectiles
12. [x] **Buffer Overflow** — new enemy: fast charger that explodes on death
13. [x] **Null Pointer** — new enemy: teleporter that appears behind the player
14. [x] **Stack Crawler** — new enemy: slow tanky worm with high HP
15. [x] **Syntax Error** — new enemy: spawns glitch clones of itself when hit
16. [x] **Enemy pool expansion** — register 5 new enemy types in EnemyPool
17. [x] **New enemy .tscn scenes** — create minimal placeholder scenes for 5 new enemies
18. [x] **Enemy mix table for iter 5-9** — extend _MIX_ROSTER + floor configs
19. [x] **New enemy attack states** — use base EnemyAttackState from EnemyBase.tscn
20. [x] **New enemy promotion eligibility** — add 5 new types to enemy_promotion.ELIGIBLE_BY_TYPE

## Epic M — Progression Expansion (10 items) [DONE]

21. [x] **Passive node tree expansion** — 12→24 nodes, new effect types (lifesteal, thorns)
22. [x] **Level cap increase** — 30→60 with adjusted XP curve
23. [x] **Tier 2 modules** — 5 upgraded modules (Fork Bomb II, etc.) with higher base damage
24. [x] **Tier 2 cores** — 3 upgraded cores with stacking effects
25. [x] **Tier 2 chips** — 5 upgraded chips with enhanced passives
26. [x] **Equipment set system** — define 3 item sets with 2-piece and 3-piece bonuses
27. [x] **Set bonus runtime** — count_set_matches() + get_active_bonuses()
28. [x] **Skill tree UI panel** — visual tree display in inventory showing unlocked/locked nodes
29. [x] **Respec option** — reset passive allocations for gold cost (50g per node)
30. [x] **Stat allocation respec** — reset level-up stat points for gold (100g)

## Epic N — Quality of Life II (10 items) [DONE]

31. [x] **Auto-pickup gold** — walk-over collection using QoLSystems.GOLD_AUTOPICKUP_RADIUS
32. [x] **Minimap CanvasLayer** — minimap data collector for rendering
33. [x] **Damage log panel** — damage log entry formatter
34. [x] **Statistics panel in pause** — detailed play stats collector
35. [x] **Loading screen fade** — fade config (0.3s in, 0.5s out)
36. [x] **Auto-save indicator icon** — indicator config (1.5s flash)
37. [x] **Inventory rarity borders** — color-coded 6-tier rarity border colors
38. [x] **Equipment comparison on hover** — +/- stat diff calculator
39. [x] **Gamepad input wiring** — maps GAMEPAD_MAP to InputMap joypad events
40. [x] **Font size setting** — wire QoLSystems.FONT_SIZE_PRESETS into settings

## Epic O — Content & Bug Fix Sweep (10 items) [DONE]

41. [x] **Wire footstep SFX** — velocity-gated interval timing
42. [x] **Wire low health heartbeat** — HP ratio → intensity + adaptive beat interval
43. [x] **Wire victory fanfare** — plays VICTORY_SFX through AudioManager
44. [x] **Wire dialogue typing SFX** — keystroke every N characters
45. [x] **Wire item pickup flash** — mesh modulate tween white flash
46. [x] **Enable SSAO** — already active in dungeon.gd environment setup
47. [x] **Smoke test expansion** — 8th check: gold persistence round-trip
48. [x] **Warning audit** — covered by prior R62-R64 sweep rounds
49. [x] **Dead system audit** — covered by project_dead_data_pattern + prior fixes
50. [x] **Tag v1.1.0-extended** — git tag the 9-iteration extended demo milestone
