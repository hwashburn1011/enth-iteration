# Enth: Iteration — Post-V1 Top 50 Backlog

> The V1 demo (50 tasks across 6 phases) is complete. This list captures the next 50 highest-impact items for expanding the demo into a full game experience, organized by priority epic.

## Epic A — Vendor & Economy (10 items)

1. **Vendor shop UI** — full buy/sell panel with item previews, stat comparisons, and gold tracking
2. **Vendor rotating stock** — curated item pool per iteration, refreshed on each town return
3. **Gold/currency system** — enemies drop currency, containers yield gold, economy loop closes
4. **Item sell value scaling** — rarity + affixes determine sell price, legendary sells for meaningful gold
5. **Vendor buy-back** — last 5 sold items recoverable at same price for a short window
6. **Stash chest** — persistent cross-run storage with grid UI, separate from inventory
7. **Item comparison tooltip** — hover over shop/loot item shows +/- vs equipped piece
8. **Crafting station stub** — NPC with a "coming soon" panel + 1 functional recipe (combine 3 common → 1 rare)
9. **Set bonus preview** — UI hint when player holds 2/3 pieces of a set (even before sets are fully implemented)
10. **Price scaling per iteration** — vendor prices increase with iteration so gold retains value

## Epic B — NPC & Town Life (10 items)

11. **NPC affinity system activation** — wire the existing affinity_changed signal into gameplay rewards (stat buffs, unique dialogue)
12. **NPC recruitment chains** — Cache Sprite and VillagerR3 require quest completion before appearing in town
13. **NPC gift system** — give items to NPCs for affinity gain, each NPC has preferred item types
14. **Villager dialogue expansion** — 3+ dialogue sets per NPC based on iteration + affinity tier
15. **Town visual progression** — small environment changes each iteration (new lanterns, repaired structures, flowers)
16. **Main menu scene** — proper title screen with New Game / Continue / Settings / Quit instead of straight-to-town
17. **New Game+ mode** — after V1 demo end, option to restart with passive bonuses carried over
18. **NPC schedule system** — NPCs move to different spots at different times (day/night stub)
19. **Town ambient sound layers** — iteration-specific ambience (calm at iter 1, tense at iter 4)
20. **Mailbox system** — NPCs leave letters after affinity milestones, read via an inbox UI

## Epic C — Combat Depth II (10 items)

21. **Charged heavy attack** — hold RMB for a slow, high-damage charged swing with unique hitbox
22. **Dodge-roll alternative** — hold direction + dash becomes a roll with different i-frame timing
23. **Enemy attack patterns v2** — each enemy gets a 2nd and 3rd attack pattern at higher iterations
24. **Boss phase 4** — Corrupted Compiler gets a desperation phase at <15% HP on iteration 4
25. **Environmental hazards** — dungeon rooms with floor traps, moving walls, or timed damage zones
26. **Summon companion** — new module that summons a temporary combat drone ally
27. **Weapon types** — introduce 2-3 weapon categories (fast/balanced/heavy) with different combo chains
28. **Critical hit VFX overhaul** — screen flash, time stop 0.1s, unique particle burst on crit kills
29. **Elite enemy affixes** — glowing/shielded/regenerating modifiers on elite spawns beyond promotions
30. **Parry riposte attack** — successful parry enables a free counter-attack with guaranteed crit

## Epic D — Dungeon Variety (10 items)

31. **Trap rooms** — 2 new room types with spike plates, laser grids, or falling debris
32. **Puzzle rooms** — switch-based door puzzles requiring enemies to stand on pressure plates
33. **Secret rooms** — 10% chance per floor of a hidden room with bonus loot
34. **Mini-boss pool expansion** — 3 additional mini-boss archetypes beyond the current elite system
35. **Floor 4 and 5** — extend dungeon depth to 5 floors for iterations 3+
36. **Room layout randomization** — procedural furniture/obstacle placement within existing room templates
37. **Dungeon modifiers** — per-run mutators (e.g. "No Healing", "+50% enemy speed", "Double Loot")
38. **Rest room** — mid-dungeon heal shrine that costs gold or compute to use
39. **Lore terminals** — interactable data terminals in dungeon that reveal fragments of Project Enth backstory
40. **Boss arena variant** — iteration 3-4 boss fight happens in a different arena layout

## Epic E — Systems & QoL (10 items)

41. **Minimap** — small corner minimap showing room layout, player position, exit markers
42. **Damage log** — scrolling combat log panel (togglable) showing last 10 damage/heal events
43. **Auto-pickup for gold** — walk-over collection for currency without pressing E
44. **Item rarity filter** — inventory/loot option to auto-ignore common items after iteration 2
45. **Screenshot mode** — hide HUD, free camera, depth-of-field toggle for photo captures
46. **Accessibility: font size options** — 3 font size presets (small/medium/large) in settings
47. **Accessibility: colorblind mode** — alternative color palette for damage numbers, status effects, UI
48. **Skip cinematic** — press any key to skip intro/death/end cinematics after seeing them once
49. **Statistics panel** — detailed play stats page (total damage dealt, enemies per type, deaths per iteration)
50. **Gamepad support** — map all actions to Xbox/PS controller layout, UI navigation with D-pad
