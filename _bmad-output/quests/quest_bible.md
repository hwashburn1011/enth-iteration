---
name: Quest System v2 Bible
description: 5 quest categories, 40 main quests across 9 iterations, 60 side quests, daily generator, hidden quests
date: 2026-04-09
status: design + data complete
---

# Quest System v2 Bible

## Categories

| Type | Count | Source | Repeatable | Reward Tier |
|---|---|---|---|---|
| **Main** | 40 | story progression | no | story flag + huge XP + class unlock |
| **Side** | 60 | NPC dialogue | no | XP + materials + rare drops |
| **Daily** | 10 templates | town board, randomized | yes | small XP + currency |
| **Hidden** | 15 | exploration triggers | no | unique items + lore |
| **Faction** | 40 (Epic 39) | faction quartermaster | partly | faction reputation |

## Quest structure

Each quest has:
- **id** — unique StringName
- **type** — main/side/daily/hidden/faction
- **title** — short display name
- **description** — flavor text shown in journal
- **objectives** — array of objective entries (kill, gather, talk, deliver, explore)
- **rewards** — XP, gold, items, faction rep, story flags
- **prerequisites** — quest IDs that must be complete first
- **giver_npc_id** — who gives it (optional for hidden quests)
- **iteration_lock** — minimum iteration to be available

## Objective types

- **kill** — kill N enemies of a tag (e.g. "kill 5 GlitchBugs")
- **gather** — collect N material/items
- **deliver** — bring item to NPC
- **talk** — have a conversation with specific NPC
- **explore** — reach a specific location/room
- **fish** — catch N fish (specific or any)
- **craft** — craft N items at a station
- **defeat_boss** — kill a specific boss
- **survive** — survive N waves/floors

## Reward types

- **xp** — combat experience
- **gathering_xp** — gathering experience
- **gold** — compute crystals
- **items** — list of {item_id, count}
- **faction_rep** — {faction_id, amount}
- **story_flag** — sets a global story flag for branching dialogue
- **module_unlock** — unlocks a specific ability module
- **recipe_unlock** — unlocks a crafting recipe

## Main story arc (40 quests across 9 iterations)

The main quest line is the spine of the game. Each iteration has 4-5
main quests culminating in a boss kill or major story beat.

### Iteration 1 — Awakening (5 quests)
1. **Boot Sequence** — wake up, find your bearings in town (tutorial)
2. **First Steps** — meet the Sage, learn about the Compaction
3. **The First Floor** — clear floor 1 of the Server Room dungeon
4. **A Familiar Stranger** — meet your first recruitable NPC
5. **Compaction Gate** — defeat the Corrupted Compiler boss for the first time

### Iteration 2 — Recognition (5 quests)
6. **Echoes** — Sage reveals the iteration loop
7. **Lost and Found** — recover items left from a previous iteration
8. **The Other Side** — explore the Memory Vaults biome
9. **Reflection** — meet the Reflection NPC, unlock respec
10. **Second Compaction** — defeat the Compiler again, with new dialogue

### Iteration 3 — Class & Companions (5 quests)
11. **Specialization** — choose your class via Reflection
12. **Companion Search** — find your first companion in the Wilds
13. **Faction Introduction** — first contact with one of 4 factions
14. **The Glitch** — encounter the corrupted enemies
15. **Iteration Three** — boss with new phase

### Iteration 4 — Town Bonds (5 quests)
16. **Friend Indeed** — reach Friend tier with any NPC
17. **The Greenhouse** — unlock greenhouse and rare crops
18. **Workshop Awakened** — upgrade a crafting station to tier 2
19. **A Personal Favor** — first personal quest from a Confidant
20. **Iteration Four** — boss with arena-changing mechanic

### Iteration 5 — Deeper Truth (5 quests)
21. **The Sage's Memory** — Sage shares hidden lore
22. **The User's Mark** — discover the User's seal in dungeon depths
23. **Faction Path** — commit to a faction line
24. **The Architect** — unlock the Architect outfit set
25. **Iteration Five** — boss with multi-phase reveal

### Iteration 6 — Crisis (5 quests)
26. **Town Under Siege** — defend town in a crisis event
27. **The Compaction Heart** — find the first Compaction Heart
28. **Aegis Trial** — protect an NPC for a full dungeon run
29. **The Lost NPC** — find and recruit a hidden NPC
30. **Iteration Six** — boss with party fight (companion required)

### Iteration 7 — Convergence (5 quests)
31. **The Weave** — discover how iterations are linked
32. **Memorial** — visit the Iteration Memorial, place a name
33. **The Final Faction** — meet the 4th faction representative
34. **Old Friends** — talk to every NPC at Bond tier
35. **Iteration Seven** — boss with environmental story beat

### Iteration 8 — The Truth (5 quests)
36. **The User Speaks** — first direct contact
37. **Compaction Choice** — choose a path that affects ending
38. **The Last Companion** — final companion recruitment
39. **The Sage's Last Lesson** — sage reveals everything
40. **Iteration Eight** — penultimate boss

### Iteration 9 — End / New Beginning (5 quests)
41-45. Reserved for the finale arc — story design TBD.
(For prototype: iteration 9 quest line is a single 5-step climax)

## Side quests (60)

Distributed across NPCs:
- Each named NPC offers 5 side quests across the game
- 12 NPCs × 5 = 60 side quests total
- Themes vary by NPC role: Forge gives crafting fetch, Lab gives experiment quests, Sentinel gives combat trials, etc.

## Daily quest templates (10)

Generated each morning at the town board:
1. **Bring 5 X material** to NPC Y
2. **Kill N enemies** of type T in dungeon
3. **Catch N fish** of any type
4. **Plant N crops** in town
5. **Deliver letter** from NPC A to NPC B
6. **Defeat boss with Z constraint** (no items, etc.)
7. **Reach floor N** of any dungeon
8. **Sell N items** to merchants
9. **Talk to N NPCs** in one day
10. **Spend N gold** in shops

Daily completion grants 25 XP + small currency. Streak bonus at 7 days.

## Hidden quests (15)

Triggered by exploration, not given by NPCs:
- **The Lost Page** — find a torn book page in 5 different locations
- **The Singing Wall** — interact with a specific dungeon wall when nearby a music player
- **The Shadow Self** — defeat your own Iteration Echo enemy
- **The Whispering Crystal** — investigate the strange crystal in the cave sub-area
- ... 11 more

## Quest log UI

- **All** tab: every active quest
- **Main** tab: just main story
- **Side** tab: NPC side quests
- **Daily** tab: daily board quests
- **Faction** tab: faction quests
- **Completed** tab: quest history

Filters:
- By NPC giver
- By region/zone
- By reward type

Sort options:
- Alphabetical
- By giver
- By date accepted
- By estimated difficulty

## HUD tracker widget

Top-right of screen, can pin up to 3 quests. Shows:
- Quest title
- Current objective progress (e.g. "Kill 3/5 GlitchBugs")
- Distance to objective marker (if applicable)

## Quest objective markers

In-world markers tied to objectives:
- Kill quests: outline enemies of the right tag in red
- Gather: highlight gather nodes in green
- Talk/deliver: place a quest marker over NPC's head
- Explore: minimap waypoint pulse

## Quest abandonment / failure

Most quests can be abandoned from the journal (returns to giver, no penalty).
Some quests have **failure conditions**:
- Time-limited (must complete in N days)
- Don't damage NPC X
- Don't kill enemy Y type during this quest

Failure resets the quest to "available" but with reduced reward.

## Quest chains

Some quests have prerequisites:
- "Specialization" requires "Boot Sequence" complete
- Personal quests require Confidant tier with the giver
- Late iteration quests require previous iteration quests

The quest log shows locked quests with their unlock requirements.

## Cinematic triggers

Major story beats trigger cinematics (Epic 49):
- All main story quest completions
- First boss kill (any iteration)
- Personal quest completions at high affinity
- Hidden quest discoveries

## Save data

- active_quests: { quest_id → { progress: Dict, accepted_day: int } }
- completed_quests: Array[StringName]
- failed_quests: Array[StringName]
- daily_quests_today: Array[Dict]
- daily_streak: int
- pinned_quests: Array[StringName]

## Achievements

- "First Quest" — complete any quest
- "Hero of Iteration N" — complete all main quests in iteration N
- "Side Hustle" — complete 30 side quests
- "Detective" — find 5 hidden quests
- "Daily Grinder" — 30-day daily quest streak
- "Completionist" — complete every quest in the game

## Files

- `_bmad-output/quests/quest_bible.md` — this file
- `scripts/resources/quest.gd` — quest data resource
- `scripts/resources/quest_objective.gd` — single objective
- `scripts/systems/quest_database.gd` — quest catalog
- `scripts/components/quest_component.gd` — player quest state
- `scripts/ui/quest_log_v2.gd` — full quest log UI
- `scripts/ui/quest_tracker_hud.gd` — pinned quest HUD widget
