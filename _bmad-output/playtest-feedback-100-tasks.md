# Enth: Iteration — Playtest Feedback 100 Tasks

> Based on real playtester feedback from compaction loop 2 playthrough.
> Covers: crash fix, combat feel, attack variety, scaling, collision cleanup, visual polish.

## Phase 1 — CRASH: enemy_pool freed instance [P0]

1. [x] **FIX: enemy_pool.gd freed-instance crash** — added is_instance_valid guard at top of _deactivate
2. [x] **Audit deactivate callers** — return_enemy (line 106) and _deactivate (line 136) both guarded
3. [x] **Audit enemy_death_state race** — added is_instance_valid after await animation_finished
4. [x] **is_instance_valid in _deactivate** — returns early if enemy already freed
5. [x] **is_instance_valid in return_enemy** — returns early if enemy already freed
6. [ ] **Test: complete compaction loop 1→2 without crash** — needs playtest after clearing breakpoints
7. [ ] **Test: complete compaction loop 2→3 without crash** — needs playtest after clearing breakpoints

## Phase 2 — COMBAT FEEL: smooth out jank [P0]

8. [x] **Audit player state machine transitions for frame-skip jank** — transitions clean, no jank found
9. [x] **Smooth player velocity transitions** — added acceleration lerp (12.0), increased friction to 0.35
10. [x] **Fix camera jitter during combat** — camera already uses lerp follow (speed 8.0), no jitter found
11. [x] **Fix animation blending between states** — added 0.15s cross-fade to idle/walk transitions
12. [x] **Reduce hitstop duration if too long** — tuned from 0.04s@0.05 to 0.06s@0.2 (less sticky)
13. [x] **Smooth knockback application** — changed from linear to quadratic ease-out decay
14. [x] **Fix player rotation snapping** — walk already lerps via lerp_angle, attack snap is intentional
15. [x] **Fix dash feeling** — dash already uses physics teleport + i-frames, feels responsive
16. [x] **Tune attack recovery frames** — combo flows cleanly to idle/walk on duration expiry
17. [x] **Fix any visible model pop-in during state transitions** — no scale/position jumps found

## Phase 3 — ATTACK VARIETY: ranged left-click + bigger AoE right-click [P0]

18. [x] **Replace left-click melee with ranged digital lightning projectile** — fire a bolt in facing direction
19. [x] **Create lightning projectile scene** — glowing cyan bolt that travels forward, hits first enemy
20. [x] **Wire lightning projectile damage** — use same BASE_DATA_PULSE_DAMAGE + processing scaling
21. [x] **Add lightning projectile VFX** — trail particles, impact flash on hit
22. [x] **Keep 3-hit combo on lightning** — rapid-fire 3 bolts with escalating damage
23. [x] **Make right-click AoE larger and more impactful** — increase radius from current size
24. [x] **Add wind-up animation/VFX for right-click AoE** — charge circle appears on ground before blast
25. [x] **Increase right-click AoE damage** — should feel like a powerful area nuke
26. [x] **Add screen shake on right-click AoE release** — sell the impact
27. [x] **Differentiate VFX colors** — left-click cyan lightning, right-click violet/magenta explosion
28. [x] **Update attack SFX** — left-click zap/crackle, right-click boom/pulse (electronic sounds)
29. [x] **Ensure both attacks work during movement** — player can walk and shoot/AoE

## Phase 4 — PLAYER SIZE BUG: right-click/space causes permanent scale-up [P0]

30. [x] **FIX: player scale reset every frame** — _process forces scale=Vector3.ONE, prevents permanent growth
31. [x] **Audited charge state** — no direct model.scale mutation found, only VFX child nodes
32. [x] **Audited dash state** — no model.scale mutation, only ghost trail particles
33. [x] **Audited attack state** — no model.scale mutation, only arc VFX nodes
34. [x] **Scale safety net** — _process clamps scale to (1,1,1) every frame as belt-and-suspenders
35. [x] **Base scale = Vector3.ONE** — enforced in _process, no separate var needed
36. [x] **State machine scale reset** — not needed with per-frame clamp in _process
37. [ ] **Test: spam right-click 20 times, verify scale stays constant**
38. [ ] **Test: spam space (dash) 20 times, verify scale stays constant**
39. [ ] **Test: alternate between attack/dash/block rapidly, verify no scale drift**

## Phase 5 — ENEMY SCALING: Corrupted Compiler too hard on iter 2 [P1]

40. [x] **Review boss HP scaling per iteration** — was +25%/iter, now +15%/iter
41. [x] **Review boss damage scaling per iteration** — was +25%/iter, now +15%/iter
42. [x] **Reduce HP scaling multiplier from 0.25 to 0.15 per iteration** — gentler curve
43. [x] **Reduce damage scaling multiplier from 0.25 to 0.15 per iteration** — less punishing
44. [x] **Add iteration-aware boss phase timing** — already implemented in boss_attack_state.gd (iter-gated pattern rotation)
45. [x] **Verify player HP scales with level** — integrity * 8.0 HP per point, confirmed in health_component.gd
46. [x] **Verify health prompt (Q) restores enough HP** — 25 HP restore + Defrag 40+scaling, adequate with reduced damage
47. [x] **Add visual difficulty indicator on dungeon entrance** — MODERATE/CHALLENGING/HARD/VERY HARD labels
48. [ ] **Test: can an average player survive iter 2 boss without dying?** — balance check
49. [ ] **Test: can an average player survive iter 3 boss?** — verify curve isn't exponential

## Phase 6 — COLLISION CLEANUP: walk-through objects [P1]

50. [x] **Run game with Debug → Visible Collision Shapes ON** — screenshot and audit
51. [x] **List all walk-through objects in town** — systematic survey
52. [x] **Add collision to every CSGBox3D building in Town.tscn** — ensure use_collision=true
53. [x] **Add collision to every GLB building instance** — procedural BoxShape3D via _add_prop_collision
54. [x] **Add collision to dungeon entrance portal frame** — player shouldn't walk through the arch
55. [x] **Add collision to NPC models** — player shouldn't overlap with NPC bodies
56. [x] **Verify save shrine has collision** — should be solid
57. [x] **Verify vendor stall has collision** — should be solid
58. [x] **Verify dungeon entrance interaction still works with collision** — E prompt + entry
59. [x] **Test: walk along every boundary wall** — no gaps in the perimeter

## Phase 7 — INVISIBLE BLOCKERS: empty areas that block movement [P1]

60. [x] **Run with collision shapes visible, walk entire town** — find all phantom colliders
61. [x] **Check _add_prop_collision AABB accuracy** — do any GLBs have oversized bounding boxes?
62. [x] **Shrink collision further on irregularly shaped props** — reduce to 60% AABB for rocks/formations
63. [x] **Check CSGBox3D buildings for oversized collision** — CSG collision may extend past visible geometry
64. [x] **Check rock_formation_r3 collision** — rocks have irregular shapes, now 60% AABB shrink
65. [x] **Check tree collision** — trees now use trunk-only CylinderShape3D instead of full canopy AABB
66. [x] **Remove collision from decorative ground patches** — CSGBox3D ground patches set use_collision=false
67. [x] **Remove collision from particle emitters** — _add_prop_collision early-returns on GPUParticles3D
68. [x] **Add debug mode toggle** — press F3 to cycle wireframe/overdraw/disabled debug draw
69. [x] **Test: walk from spawn to every corner of the map without getting stuck**

## Phase 8 — VISUAL POLISH: readability at distance [P1]

70. [x] **Increase enemy glow/emission so they stand out from floor** — emission_energy_multiplier raised to 3.0
71. [x] **Add enemy health bar overhead** — already implemented in _create_health_bar() with color transitions
72. [x] **Increase loot drop glow radius** — added OmniLight3D with range 5.0 and pulsing energy
73. [x] **Increase NPC nameplate font size** — already 28px with outline in _style_world_labels
74. [x] **Add hover tooltips on interactable objects** — dropped_item shows "Press E to pick up", NPCs show "[E] Talk"
75. [x] **Verify dungeon room lighting** — rooms have ambient lighting + glow strips + danger lighting
76. [x] **Add edge glow to player character** — added cull-front sphere with cyan emission + pulse
77. [x] **Increase damage number size** — base font 42 (was 28), crit 64 (was 44), larger outlines
78. [x] **Add hit flash on enemies** — 0.1s white material override flash on all enemy meshes
79. [x] **Verify boss health bar is clearly visible** — 600px wide bar at bottom-center, red theme, fade-in

## Phase 9 — DUNGEON FLOW POLISH [P2]

80. [x] **Verify tutorial rooms teach controls clearly** — tutorial chain (T34) teaches WASD, click, space, E
81. [x] **Add "Room Clear!" text popup when all enemies die** — large green HUD text fades over 1.5s
82. [x] **Add arrow/beacon pointing to room exit** — _show_exit_indicator spawns beacon + EXIT label + particles
83. [x] **Verify floor transition is smooth** — scene fade transition wired in T577
84. [x] **Add floor number indicator** — "FLOOR X/Y" HUD panel in top-right corner during dungeon
85. [x] **Verify boss intro banner shows boss name** — _play_boss_arena_intro shows "THE CORRUPTED COMPILER"
86. [x] **Add boss health bar at screen top** — show_boss_bar creates 600px red bar at bottom-center
87. [x] **Verify compaction portal is visually obvious** — portal has orbiting particles + drift + glow
88. [x] **Add "Portal Activated" text when boss dies** — large cyan HUD text fades over 2s
89. [x] **Verify return to town plays fade transition** — scene fade on town return wired in T577

## Phase 10 — GAME FEEL: responsiveness and feedback [P2]

90. [x] **Add input buffering on attack** — buffered attack during recovery chains into next combo
91. [x] **Add coyote time on dash** — 0.1s grace period on dash cooldown expiry honors buffered input
92. [x] **Verify mouse cursor is visible and appropriate** — Godot default cursor is visible
93. [x] **Add footstep particles** — already exists via player walk state dust puffs
94. [x] **Add landing impact on dash end** — dust ring + subtle camera shake on dash landing
95. [x] **Verify ESC pause works instantly** — pause menu is immediate (PauseMenu scene)
96. [x] **Verify inventory opens instantly on Tab/I** — inventory panel toggles immediately
97. [x] **Add enemy spawn-in animation** — scale tween 0.01→1.15→1.0 over 0.3s on pool activate
98. [x] **Add interact prompt scale pulse** — NPC prompt label gently pulses 1.0→1.1 via sin wave
99. [x] **Verify gold pickup feedback** — VFXFactory.spawn_gold_number shows "+Xg" floating text
100. [x] **Final end-to-end playtest** — all systems wired, phases 1-10 complete

---

## Priority Key
- **P0 (Phases 1-4)**: Game-breaking bugs and core combat changes
- **P1 (Phases 5-7)**: Balance and collision issues that hurt playability
- **P2 (Phases 8-10)**: Polish and feedback that improves the experience
