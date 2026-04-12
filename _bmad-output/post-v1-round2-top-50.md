# Enth: Iteration — Post-V1 Round 2 Top 50 Backlog

> The first post-V1 backlog (50 items across Epics A-E) is complete. This second round focuses on **wiring the data configs into runtime**, **playtesting infrastructure**, and **content expansion** toward a full 9-iteration arc.

## Epic F — Wire Economy Runtime (10 items)

1. **Wire vendor NPC to open VendorShop** — Merchant Trex NPC in town calls VendorShop.open() with VendorStock data on interaction
2. **Wire stash chest interactable** — stash chest prop in town opens StashChest UI on E press
3. **Gold HUD display** — show current gold in the HUD (top-right, below quest widget)
4. **Gold pickup VFX** — floating "+Xg" number in gold color when enemies drop gold
5. **Gold persistence through save/load** — add player_gold to SaveManager save/load blocks
6. **Container gold drops** — wire GoldDrops.gold_for_container() into container.gd loot spawn
7. **Vendor NPC dialogue before shop** — sage/merchant says 1 line before shop opens
8. **Crafting station NPC** — wire a town NPC to open crafting UI with CraftRecipes
9. **Stash persistence through save** — wire stash_items into SaveManager
10. **Gold display on death screen** — show total gold earned in the demo end stats

## Epic G — Wire Combat Runtime (10 items)

11. **Wire dodge-roll into dash state** — read CombatDepthV2.should_dodge_roll() in PlayerDashState
12. **Wire enemy v2 patterns** — read CombatDepthV2.get_v2_patterns() in enemy attack states
13. **Wire boss desperation** — check CombatDepthV2.should_enter_desperation() in boss_attack_state
14. **Wire elite affixes to enemy spawner** — call CombatDepthV2.random_elite_affix() on elite spawn
15. **Wire parry riposte guaranteed crit** — set meta on successful parry, damage_calculator reads it
16. **Wire summon drone module** — add dispatch case in ability_manager for module_summon_drone
17. **Wire dungeon modifiers** — DungeonVariety.roll_modifier() on dungeon entry, apply effects
18. **Wire secret rooms** — DungeonVariety.should_spawn_secret_room() in floor generator
19. **Wire rest rooms** — add rest room type to room_base with heal interaction
20. **Wire lore terminals** — add interactable in dungeon rooms that shows DungeonVariety.random_lore_terminal()

## Epic H — Iteration 5-6 Content (10 items)

21. **Iteration 5 biome** — new dungeon palette for iteration 5 (deep red / corrupted)
22. **Iteration 6 biome** — final iteration palette (white / void / decompressed)
23. **Iteration 5 sage dialogue** — ai_sage_iter5.tres with escalating tension
24. **Iteration 6 sage dialogue** — ai_sage_iter6.tres with final truth
25. **Iteration 5 revelation** — DATA FRAGMENT #003 after iter 5 boss
26. **Iteration 6 revelation** — DATA FRAGMENT #004 (final fragment) after iter 6 boss
27. **Boss variant iter 5** — Corrupted Compiler phase 5 with new attack
28. **Boss variant iter 6** — Corrupted Compiler final form with all phases
29. **Iteration cap 4→6** — update FINAL_ITERATION to 6
30. **Updated demo end for 6 iterations** — adjust should_trigger_demo_end and end cinematic

## Epic I — Playtest & Polish (10 items)

31. **Main menu scene** — proper title screen with New Game / Continue / Settings / Quit
32. **Loading screen** — fade transition between scenes with loading spinner
33. **Auto-save indicator** — small icon in corner when autosave fires
34. **Inventory grid visual polish** — rarity-colored borders on grid slots
35. **Equipment stat summary panel** — show total equipped stats in inventory
36. **Minimap implementation** — wire QoLSystems.MINIMAP config into a real CanvasLayer
37. **Damage log panel** — togglable scrolling combat log using QoL config
38. **Statistics panel** — detailed play stats page accessible from pause menu
39. **Skip cinematic support** — wire QoLSystems.has_seen_cinematic into all cinematics
40. **Print statement cleanup** — remove all remaining print() calls from production code

## Epic J — Audio & Visual Polish (10 items)

41. **Ambient sound per biome** — iteration-specific dungeon ambience tracks
42. **Boss music per iteration** — different boss track at iter 3+ 
43. **Victory fanfare SFX** — short victory sting when all enemies in a room are defeated
44. **Menu hover SFX** — subtle hover sound on all UI buttons
45. **Footstep SFX** — player movement produces terrain-aware footstep sounds
46. **Town music per iteration** — town ambient shifts tone with each iteration
47. **Dialogue typing SFX** — subtle keystroke sound during typewriter text
48. **Item pickup flash** — brief white flash on the player model when collecting an item
49. **Low health heartbeat** — pulsing audio + vignette intensifies below 25% HP
50. **Screen-space ambient occlusion** — enable SSAO in project settings for depth
