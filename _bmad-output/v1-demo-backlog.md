# Enth: Iteration — V1 Demo Backlog

> **V1 demo goal**: A 5-10 hour playable slice that delivers the core compaction-loop fantasy across **4-6 iterations**, with enough mechanical depth to keep the dungeon runs varied and a story arc that resolves at the final iteration. This is **not** the full game — it's the vertical slice that proves the loop is fun and the narrative hook lands.

## What V1 *is*

- Globbler wakes inside the simulation, finds a minimal hub, descends into the Compaction Loop dungeon, dies / clears, returns, and watches the world shift each iteration.
- 4-6 iterations forming a complete narrative arc (intro → revelation → climax → resolution).
- 5-10 hours of dungeon content with enough enemy / loot / build variety to stay fresh.
- Tightly polished combat, save/load, and progression — the systems sweep (T1-T69) is largely done.

## What V1 *is not*

The following are explicitly **deferred to post-V1** and should NOT block the demo:

- Town building / district expansion (the 9 districts + 78-prop Town Heart). Cut to a single small hub.
- NPC affinity progression, recruitment chains, dialogue trees beyond essential intro/outro lines.
- Cooking, lounge bar, fishing, farming, faction subsystems, photo mode, hardcore mode, telescope, wilderness shrines (~12 dead systems in `scripts/systems/`).
- The full 9-iteration arc — collapse to 4-6.
- Crafting, set bonuses, large item catalogs (V1 ships with a curated 15-25 items, not 100+).
- Cosmetic district mutations beyond the dungeon biome shifts.

## Scope ground rules

1. **Hub scope**: one town scene with ~6 functional spots (spawn, save shrine, vendor, dungeon entrance, sage NPC, tutorial trainer). Everything else cut from the V1 build.
2. **Iteration count**: 4 minimum, 6 maximum. Each iteration unlocks one new mechanic + one story beat + one boss variant.
3. **Hour target**: 5-10h. Validate by playtest, not theory.
4. **Quality bar**: combat must feel like the hit-confirm/dash polish promises (T2-T4); progression must feel earned, not handed out.

---

## Phase 0 — Playability blockers (this week)

The game must be playable end-to-end before any new work lands.

1. **Player can't move on new game** — spawn marker overlaps Town Heart Beacon collision, capsule jams. Move marker, shrink beacon collision, or push player up at spawn. *Critical.*
2. **Mouse wheel zoom** — `isometric_camera.gd` has no scroll handler. Add `zoom_in_step` / `zoom_out_step` actions, clamp 8m-22m, smooth lerp. *S, 1 day.*
3. **Smoke-test the play loop end-to-end** — write a `gametest/` scripted run that does new-game → walk → fight → loot → die → respawn → enter dungeon → die → repeat. CI catches future regressions like the cylinder shape crash.
4. **Verify T68 / T69 carry state** — manual test: level to 5 in town, enter dungeon, confirm level, equipment, inventory all present.
5. **Camera collision** — don't clip through walls. Spring-arm the isometric camera against terrain.
6. **Fix the 5 d9 baseline warnings** — shadowed `floor`, `len`, `sign`; confusable `rb`, `brass`. Trivial cleanup so the warning bar can become an error gate.

## Phase 1 — V1 scope freeze & cut (week 1)

Decide what's in vs. out and remove the dead weight so the team isn't maintaining systems V1 doesn't ship.

7. **Audit `scripts/systems/`** — list every script and tag in/out for V1. Cut or feature-flag the 12 dead systems (cooking, lounge_bar, fishing, farming, faction_subsystems, hardcore_mode, photo_mode, tower_telescope, wilderness_shrine, lounge_stage, campsite, ai_sage_npc social).
8. **Town simplification** — fork a `town_v1.tscn` that ships only: spawn, sage, save shrine, vendor, dungeon entrance, training dummy, 1-2 ambient props. Park the 9-district build for post-V1.
9. **Iteration cap to 4-6** — `IterationManager.FINAL_ITERATION = 4` (or 6) for V1. Update HUD chip + difficulty preview text.
10. **Update GDD + epics doc** — mark which existing epics ship in V1 and which are post-V1. Keep the work, label the scope.

## Phase 2 — Compact loop tightening (weeks 2-3)  ✅ DONE

The dungeon → boss → return → iterate cycle has to feel tight and rewarding.

11. **Floor pacing** — current floors are 4-7 rooms each. Validate by stopwatch: a full dungeon clear should be 25-40 minutes at iteration 1, growing to 60-90 minutes by iteration 6. _(deferred — needs human playtest, not code)_
12. ✅ **Per-iteration biome shift** — each iteration repaints the dungeon with a different palette + ambient effect (cyan → violet → amber → red). Cheap, high impact.
13. ✅ **Per-iteration enemy mix** — each iteration unlocks one new enemy type or variant. By iteration 6 the player faces all 4-6 enemy archetypes.
14. ✅ **Boss variant per iteration** — Corrupted Compiler grows new attack patterns each loop, not just HP. At iteration 4-6 it's mechanically distinct from iteration 1.
15. ✅ **Mid-floor mini-boss** — one elite encounter per dungeon at floor 3, distinct from the floor 5 final boss. Art exists; encounter doesn't.
16. ✅ **Iteration debrief screen** — after each compaction, show "what changed" — new enemies, new dungeon palette, new dialogue line from the sage, stat / loot summary.
17. ✅ **Boss arena cinematic intro** — drop-in shot, name banner, music sting. Makes each iteration's boss feel like an event.
18. ✅ **Post-iteration save shrine** — explicit "rest" interaction in town between runs that recovers HP/compute and locks in the autosave. Currently respawn does this implicitly.
19. ✅ **Compaction portal polish** — the final-floor portal needs better VFX + an audible cue. It's the moment the loop closes; it should land.

## Phase 3 — Combat & build depth (weeks 3-5)  ✅ DONE

5-10 hours of dungeon needs more than 3 enemies and 4 modules.

20. ✅ **Enemy roster expansion** — 5 runtime promotions (Charger/Shielder/Sniper/Bomber/Summoner) overlay the 3 base enemies → 8 archetypes. Promotion chance scales with iteration (12%/22%/35%).
21. ✅ **Mixed-type combat rooms** — floor 2 + floor 3 configs now mix 2 enemy types per room.
22. ✅ **Status effects** — corrupted (DoT), throttled (slow), fragmented (damage amp). Enemy attacks tag metas; hurtbox routes to StatusEffectManager.
23. ✅ **Player-side debuff icons** — HUD strip with tinted chips per effect, timers, anchored top-left.
24. ✅ **Light combo system** — 3-hit chain with COMBO_DAMAGE_MULTS [1.0, 1.15, 1.60], scaled hitboxes, finisher applies fragmented.
25. ✅ **Block or parry** — hold F to block (80% reduction, 8 compute/s drain, 30% move slow), 0.18s parry window for counter.
26. ✅ **Skill tree / passive nodes** — 12-node flat rotation granted every 3 levels. Stat, crit, dash_cd, compute_on_kill effect types. Persisted through save/load.
27. ✅ **Module roster expansion** — 5 new modules (Fork Bomb, Garbage Collect, Recursion, Deadlock, Refactor) + dispatch in ability_manager.
28. ✅ **Core roster expansion** — 3 new cores with compute_on_kill, dash_cd_reduction, extra_crit_chance. Consumer hooks wired.
29. ✅ **Chip roster expansion** — 5 new chips with passive_id lookup. Kinetic dash damage, parry counterstrike, bandwidth booster, etc.
30. ✅ **Loot affix tier widening** — RARITY_MULTIPLIERS [1.0, 1.25, 1.6, 2.5], AFFIX_COUNTS scaled, AFFIX_VALUE_MULT for legendary.
31. ✅ **Hit reactions** — enemy stagger with STUN_DURATION 0.5s, FLASH_DURATION 0.16s, procedural lean + squash via _apply_stagger.
32. ✅ **Boss telegraph polish** — v2 circle/line telegraphs, arena circles, _play_telegraph_cue audio routing.

## Phase 4 — Onboarding & UX (weeks 4-5, parallel)  ✅ DONE

Without these the player won't survive long enough to discover Phase 3 depth.

33. ✅ **First-run intro cinematic** — fade from black, camera zoom reveal (18→8), "THE COMPACTION LOOP / Iteration 1" title card, then auto-trigger sage dialogue.
34. ✅ **Tutorial chain** — auto-advancing hint sequence after sage intro: WASD → LMB → Space → E → Q → "Enter the Compaction Loop". Wired via TutorialManager.
35. ✅ **Active quest HUD widget** — top-right panel showing quest name + current objective, updates live via quest_updated signal.
36. ✅ **Objective markers** — floating "!" (yellow) on quest-relevant NPCs, "?" (cyan) on NPCs with unread dialogue. Bobs, updates on quest progress.
37. ✅ **Pause menu controls list** — scrollable "Controls" panel with 12 key bindings (WASD, LMB/RMB, Space, F, E, Q, 1-4, Tab, J, Esc, wheel).
38. ✅ **Settings menu** — zoom speed slider (0.5-3.0) + stub key rebind. Volume sliders + fullscreen already existed.
39. ✅ **Death screen** — "SYSTEM FAILURE" with random gameplay tip (8 tips) + "Continue" button. Player must click to respawn.
40. ✅ **Damage numbers polish** — no_depth_test + fixed_size for readability, crit scale pulse (1.4x overshoot), larger crit font + warm outline.

## Phase 5 — Story beats & narrative payload (weeks 5-7)

The compact loop has to *mean* something.

41. **Per-iteration sage dialogue** — sage speaks a different scripted line set at the start of each iteration, hinting at what's wrong with the simulation.
42. **Per-iteration revelation moment** — at iterations 2, 4, 6 the world drops a piece of lore (data shard, glitch room, environmental story). Three hand-built moments.
43. **Final iteration climax** — the last iteration ends with a boss fight that resolves the V1 narrative hook. Doesn't have to be the full game's ending — leave room for the post-V1 arc.
44. **End-of-V1 cinematic** — 60 seconds. Globbler reaches the truth at the end of iteration 4-6, screen-to-credits with a teaser for what's next.
45. **Dialogue portrait passes** — 3-4 expressions per major NPC (currently most have 1). Even simple alternates make conversations feel alive.

## Phase 6 — V1 ship polish (weeks 6-8)

46. **Performance pass** — town + dungeon at <16ms frame time on integrated GPU baseline. Particle counts down, cull distances tightened.
47. **Audio mix** — master/music/SFX/voice levels balanced. Currently combat SFX clip the music.
48. **Save backup integrity** — verify the 3-backup rotation actually rotates and recovers. Adversarial test: kill the main save, force a restore.
49. **CI smoke test** — Phase 0 item 3 graduates to a CI gate. Every PR must pass the scripted play loop.
50. **V1 demo build pipeline** — single-script export to Windows + Linux from `gameplay/v1-demo` branch. Tag `v1.0.0-demo` when ready.

---

## Working order

- **Now**: Phase 0 in full (this week)
- **Next**: Phase 1 cut decisions (week 1) — locks scope so nothing else gets built that has to be cut later
- **Then in parallel**:
  - Phase 2 (compact loop tightening) — single owner
  - Phase 3 (combat/build depth) — single owner
  - Phase 4 (UX/onboarding) — single owner
- **Late**: Phase 5 (story beats) once the loop is fun
- **Ship**: Phase 6 polish & demo build

Each task ships as its own branch + PR, merged via `gh pr merge`. No more direct-to-main pushes.

## Out of V1 scope (post-demo backlog)

Tracked separately so they don't pollute the V1 burndown:

- Full 9-district town build + 9-iteration arc
- NPC recruitment + affinity reward chains
- Cooking / lounge / fishing / farming / faction subsystems
- Stash chest + cross-run storage
- Vendor rotating stock + shop UI
- Town building progression (visible growth per iteration)
- Hidden lore notes / collectible system
- Set bonuses + item fusion crafting
- Skill tree expansion past 10-15 nodes
- Photo mode, hardcore mode, telescope, wilderness shrines
- Boss rush, daily challenges, leaderboards
