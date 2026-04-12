# Enth: Iteration — Playtest Feedback 100 Tasks

> Based on real playtester feedback from compaction loop 2 playthrough.
> Covers: crash fix, combat feel, attack variety, scaling, collision cleanup, visual polish.

## Phase 1 — CRASH: enemy_pool freed instance [P0]

1. [ ] **FIX: enemy_pool.gd:141 "Left operand of 'is' is a previously freed instance"** — _deactivate called on already-freed enemy; add is_instance_valid guard
2. [ ] **Audit all enemy_pool deactivate callers** — ensure no double-free path exists
3. [ ] **Audit enemy_death_state for pool-return race** — death anim may free before pool reclaims
4. [ ] **Add is_instance_valid check in EnemyPool._deactivate** before accessing enemy properties
5. [ ] **Add is_instance_valid check in EnemyPool._on_enemy_defeated** before pool return
6. [ ] **Test: complete compaction loop 1→2 without crash** — verify fix survives full playthrough
7. [ ] **Test: complete compaction loop 2→3 without crash** — verify at higher iteration scaling

## Phase 2 — COMBAT FEEL: smooth out jank [P0]

8. [ ] **Audit player state machine transitions for frame-skip jank** — idle→walk→attack→idle should be seamless
9. [ ] **Smooth player velocity transitions** — no instant stop/start, add acceleration/deceleration curves
10. [ ] **Fix camera jitter during combat** — isometric camera should track smoothly, not snap
11. [ ] **Fix animation blending between states** — no T-pose frames between idle/walk/attack
12. [ ] **Reduce hitstop duration if too long** — currently may freeze combat feel; tune to 0.03-0.05s
13. [ ] **Smooth knockback application** — enemy knockback should ease-out, not teleport
14. [ ] **Fix player rotation snapping** — facing direction should lerp smoothly, not instant flip
15. [ ] **Fix dash feeling** — dash should feel responsive and smooth, not teleport-like
16. [ ] **Tune attack recovery frames** — player should return to idle cleanly after combo
17. [ ] **Fix any visible model pop-in during state transitions** — scale/position shouldn't jump

## Phase 3 — ATTACK VARIETY: ranged left-click + bigger AoE right-click [P0]

18. [ ] **Replace left-click melee with ranged digital lightning projectile** — fire a bolt in facing direction
19. [ ] **Create lightning projectile scene** — glowing cyan bolt that travels forward, hits first enemy
20. [ ] **Wire lightning projectile damage** — use same BASE_DATA_PULSE_DAMAGE + processing scaling
21. [ ] **Add lightning projectile VFX** — trail particles, impact flash on hit
22. [ ] **Keep 3-hit combo on lightning** — rapid-fire 3 bolts with escalating damage
23. [ ] **Make right-click AoE larger and more impactful** — increase radius from current size
24. [ ] **Add wind-up animation/VFX for right-click AoE** — charge circle appears on ground before blast
25. [ ] **Increase right-click AoE damage** — should feel like a powerful area nuke
26. [ ] **Add screen shake on right-click AoE release** — sell the impact
27. [ ] **Differentiate VFX colors** — left-click cyan lightning, right-click violet/magenta explosion
28. [ ] **Update attack SFX** — left-click zap/crackle, right-click boom/pulse (electronic sounds)
29. [ ] **Ensure both attacks work during movement** — player can walk and shoot/AoE

## Phase 4 — PLAYER SIZE BUG: right-click/space causes permanent scale-up [P0]

30. [ ] **FIX: player grows on right-click and never shrinks back** — find scale mutation in charge/block state
31. [ ] **Audit player_charge_state.gd for scale changes** — charge VFX may scale model up without restoring
32. [ ] **Audit player_dash_state.gd for scale changes** — dash transparent flash may modify scale
33. [ ] **Audit player_block_state.gd for scale changes** — block shield VFX may scale model
34. [ ] **Add scale restore in _exit() of all player states** — ensure model.scale always returns to base
35. [ ] **Store base model scale on player _ready()** — reference value for reset
36. [ ] **Force scale reset on state machine transition** — safety net in state_machine.gd
37. [ ] **Test: spam right-click 20 times, verify scale stays constant**
38. [ ] **Test: spam space (dash) 20 times, verify scale stays constant**
39. [ ] **Test: alternate between attack/dash/block rapidly, verify no scale drift**

## Phase 5 — ENEMY SCALING: Corrupted Compiler too hard on iter 2 [P1]

40. [ ] **Review boss HP scaling per iteration** — may be too aggressive (current +25%/iter)
41. [ ] **Review boss damage scaling per iteration** — player may die too fast on iter 2+
42. [ ] **Reduce HP scaling multiplier from 0.25 to 0.15 per iteration** — gentler curve
43. [ ] **Reduce damage scaling multiplier from 0.25 to 0.15 per iteration** — less punishing
44. [ ] **Add iteration-aware boss phase timing** — boss shouldn't speed up attack patterns on iter 2
45. [ ] **Verify player HP scales with level** — integrity stat should give meaningful HP boost
46. [ ] **Verify health prompt (Q) restores enough HP** — healing should keep pace with damage
47. [ ] **Add visual difficulty indicator on dungeon entrance** — "Moderate" / "Hard" / "Very Hard"
48. [ ] **Test: can an average player survive iter 2 boss without dying?** — balance check
49. [ ] **Test: can an average player survive iter 3 boss?** — verify curve isn't exponential

## Phase 6 — COLLISION CLEANUP: walk-through objects [P1]

50. [ ] **Run game with Debug → Visible Collision Shapes ON** — screenshot and audit
51. [ ] **List all walk-through objects in town** — systematic survey
52. [ ] **Add collision to every CSGBox3D building in Town.tscn** — ensure use_collision=true
53. [ ] **Add collision to every GLB building instance** — procedural BoxShape3D via _add_prop_collision
54. [ ] **Add collision to dungeon entrance portal frame** — player shouldn't walk through the arch
55. [ ] **Add collision to NPC models** — player shouldn't overlap with NPC bodies
56. [ ] **Verify save shrine has collision** — should be solid
57. [ ] **Verify vendor stall has collision** — should be solid
58. [ ] **Verify dungeon entrance interaction still works with collision** — E prompt + entry
59. [ ] **Test: walk along every boundary wall** — no gaps in the perimeter

## Phase 7 — INVISIBLE BLOCKERS: empty areas that block movement [P1]

60. [ ] **Run with collision shapes visible, walk entire town** — find all phantom colliders
61. [ ] **Check _add_prop_collision AABB accuracy** — do any GLBs have oversized bounding boxes?
62. [ ] **Shrink collision further on irregularly shaped props** — reduce to 70% AABB if needed
63. [ ] **Check CSGBox3D buildings for oversized collision** — CSG collision may extend past visible geometry
64. [ ] **Check rock_formation_r3 collision** — rocks have irregular shapes, AABB may be huge
65. [ ] **Check tree collision** — CSG canopy collision may block walking under trees
66. [ ] **Remove collision from decorative ground patches** — CSGBox3D ground patches shouldn't block
67. [ ] **Remove collision from particle emitters** — data motes/ambient particles shouldn't collide
68. [ ] **Add debug mode toggle** — press F3 to show/hide collision shapes at runtime
69. [ ] **Test: walk from spawn to every corner of the map without getting stuck**

## Phase 8 — VISUAL POLISH: readability at distance [P1]

70. [ ] **Increase enemy glow/emission so they stand out from floor** — enemies should pop visually
71. [ ] **Add enemy health bar overhead** — small red bar above each enemy for HP feedback
72. [ ] **Increase loot drop glow radius** — items on ground should be unmissable
73. [ ] **Increase NPC nameplate font size** — names should be readable from isometric distance
74. [ ] **Add hover tooltips on interactable objects** — "Press E to interact" text
75. [ ] **Verify dungeon room lighting** — rooms shouldn't be too dark to see enemies
76. [ ] **Add edge glow to player character** — Globbler should always be visible
77. [ ] **Increase damage number size** — currently may be hard to read during combat
78. [ ] **Add hit flash on enemies** — brief white flash when enemy takes damage
79. [ ] **Verify boss health bar is clearly visible** — large bar at top of screen during boss fight

## Phase 9 — DUNGEON FLOW POLISH [P2]

80. [ ] **Verify tutorial rooms teach controls clearly** — new player knows WASD, click, space, E
81. [ ] **Add "Room Clear!" text popup when all enemies die** — feedback before exit opens
82. [ ] **Add arrow/beacon pointing to room exit** — player shouldn't get lost looking for the door
83. [ ] **Verify floor transition is smooth** — no black screen hang between floors
84. [ ] **Add floor number indicator** — "FLOOR 2/5" in corner during dungeon
85. [ ] **Verify boss intro banner shows boss name** — "CORRUPTED COMPILER" title card
86. [ ] **Add boss health bar at screen top** — large, clearly visible during fight
87. [ ] **Verify compaction portal is visually obvious** — glowing, pulsing, hard to miss
88. [ ] **Add "Portal Activated" text when boss dies** — tell player where to go
89. [ ] **Verify return to town plays fade transition** — not an abrupt cut

## Phase 10 — GAME FEEL: responsiveness and feedback [P2]

90. [ ] **Add input buffering on attack** — queued clicks during recovery should chain
91. [ ] **Add coyote time on dash** — small grace period for dash input
92. [ ] **Verify mouse cursor is visible and appropriate** — not default OS cursor
93. [ ] **Add footstep particles** — small dust puffs when walking
94. [ ] **Add landing impact on dash end** — small screen shake or dust
95. [ ] **Verify ESC pause works instantly** — no delay on pause menu
96. [ ] **Verify inventory opens instantly on Tab/I** — no lag
97. [ ] **Add enemy spawn-in animation** — enemies fade/teleport in, not just appear
98. [ ] **Add interact prompt scale pulse** — E prompt gently pulses to draw attention
99. [ ] **Verify gold pickup feedback** — "+3g" text floats up when gold collected
100. [ ] **Final end-to-end playtest** — new game → town → dungeon → boss → compaction → repeat, no crashes

---

## Priority Key
- **P0 (Phases 1-4)**: Game-breaking bugs and core combat changes
- **P1 (Phases 5-7)**: Balance and collision issues that hurt playability
- **P2 (Phases 8-10)**: Polish and feedback that improves the experience
