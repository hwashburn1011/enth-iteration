---
name: NPC Affinity & Relationships Bible
description: 5-tier affinity system, gift preferences, daily caps, mood states, NPC-NPC relationships, festivals
date: 2026-04-09
status: design + data complete
---

# NPC Affinity Bible

## Philosophy

Affinity is the **emotional progression curve** for every named NPC.
Inspired by Stardew Valley's heart system, but tied to Enth's iteration
narrative. Building affinity unlocks:
- New dialogue lines (lore + character backstory)
- Personal quests for that NPC
- Merchant discounts and crafting bonuses
- Eventually a max-affinity cinematic that affects the iteration story

You can ignore the system entirely and finish the game. But raising
affinity makes the world feel inhabited and gives the player a reason
to talk to the cast between dungeon runs.

## Affinity tiers

5 named levels, each with different reward density:

| Tier | Name | Range | Unlock |
|---|---|---|---|
| 0 | **Stranger** | 0-99 | starting state |
| 1 | **Friend** | 100-249 | 1 new dialogue arc, name learned |
| 2 | **Confidant** | 250-499 | personal quest unlock, gift preferences revealed |
| 3 | **Bond** | 500-799 | merchant discount 10%, NPC visits home, backstory cinematic |
| 4 | **Soul-Linked** | 800+ | iteration-specific cinematic, unique gear gift, NPC follows you in 1 dungeon |

Each tier unlocks at the threshold and shows an animated pop-up
("**Pixel** is now your **Friend**!"). Reaching Soul-Linked is permanent
across iteration resets — once earned, never lost.

## Affinity gain triggers

| Action | Affinity gained |
|---|---|
| First dialogue of day | +5 |
| Hand-in a personal quest | +50 |
| Give a "loved" gift | +30 (caps 1 per day per NPC) |
| Give a "liked" gift | +15 |
| Give a "neutral" gift | +3 |
| Give a "disliked" gift | -10 |
| Give a "hated" gift | -25 |
| Birthday gift (loved on birthday) | +75 |
| Complete a story quest involving NPC | +100 |
| Help during town crisis event | +25 each |

## Gift preferences

Each NPC has 5 preference categories:
- **Loved** (3-5 specific items): triggers cinematic reaction
- **Liked** (10-15 items): standard happy reaction
- **Neutral** (default): polite acknowledgment
- **Disliked** (5-10 items): mild offense reaction
- **Hated** (1-3 items): walks away upset

Item categories that map to preferences:
- Cooked food, raw crops, fish, materials, decorations, modules

Gift preferences are **hidden until Confidant tier** (250 affinity).
Before that, the player learns by trial and error or by discovering
preference hints in NPC dialogue.

## Daily caps

- **1 gift per NPC per day** (resets at in-game midnight)
- Loved gifts only count for the +30 bonus once per day
- This forces "depth over breadth" — you can't grind affinity by
  spamming items at every NPC

## NPC mood states

Each NPC has a daily mood that affects dialogue and gain rates:

| Mood | Gain modifier | Triggers |
|---|---|---|
| Happy | ×1.25 | recent gift, town event won, sunny weather |
| Neutral | ×1.0 | default |
| Tired | ×0.75 | late night, hard work day |
| Sad | ×0.5 | recent loss event, rainy weather, missed birthday |
| Angry | ×0.25 | hated gift recently, NPC dispute |

Mood resets each in-game day or via player action.

## NPC schedule integration

NPCs have schedules (Epic 10) — they're at different town locations at
different times. Affinity determines:
- Which schedule they follow (Stranger NPCs are more public; Soul-Linked
  visit player home more often)
- Which dialogue lines are available (locked-by-affinity gates)
- Whether they greet player by name

## Affinity decay

If an NPC isn't talked to for **5 in-game days**, their affinity decays
by 5 points per day until they hit the next-lower tier floor. Decay
stops at the floor of the current tier (so you can't lose a tier from
neglect, only the buffer above the floor).

This is gentle pressure to maintain relationships without making the
system grindy.

## NPC backstory dialogue

Each NPC has 5 backstory dialogue arcs locked behind affinity tiers:
- Tier 1: "Where they came from"
- Tier 2: "Their hopes and fears"
- Tier 3: "Their iteration history"
- Tier 4: "Their connection to Globbler/the simulation"
- Tier 5: Personal cinematic (their truth)

12 NPCs × 5 arcs = 60 backstory dialogue trees total.

## Personal quests

At Confidant tier (2), each NPC offers a personal questline:
- 3 quests per NPC
- Range from fetch (gather X material) to combat (clear floor for them)
to social (deliver letter to another NPC)
- Completion grants huge affinity boost + unique reward

## Merchant + crafting bonuses

At Bond tier (3):
- Merchants: -10% on items, +1 stock
- Crafters: -15% material cost, +1 recipe slot

At Soul-Linked (4):
- Merchants: -25% on items, +3 stock
- Crafters: -30% material cost, +3 recipe slots, occasional free craft

## Birthdays

Every NPC has a birthday on a specific in-game day. Calendar visible
in town hall. Giving a loved gift on a birthday grants +75 affinity
(huge boost). Forgetting a birthday lowers mood for that day.

## NPC-NPC relationships

NPCs have relationships with each other:
- **Friends** (3-4 pairs): bonus affinity for both when talking to either
- **Rivals** (2-3 pairs): giving gifts to one slightly upsets the other
- **Family** (1-2 pairs): cinematic at high mutual affinity

This creates social texture without forcing the player to balance
perfectly.

## Town events

### Festivals (4 per iteration)
1. **Boot Festival** — early iteration, celebration of waking up
2. **Compaction Vigil** — mid iteration, somber remembrance
3. **Iteration Eve** — late iteration, anticipation of reset
4. **Sage's Day** — once per iteration, sage hosts town gathering

Each festival is a town-wide event with mini-games, dialogue, and
+10 affinity for everyone you talk to.

### Crisis events (random)
- **Glitch Outbreak** — corruption spreading in town, help cleanup
- **Memory Leak Surge** — slimes invade plaza, defend NPCs
- **Sage's Disappearance** — iteration story moment
- Each grants +25 affinity per NPC saved

## Achievements

- "First Friend" — reach Friend with any NPC
- "Best Friend" — reach Bond with any NPC
- "Soul Mate" — reach Soul-Linked with any NPC
- "Town Hero" — reach Friend with all 12 NPCs
- "Master of Hearts" — reach Soul-Linked with all 12 NPCs
- "Birthday Master" — give a loved gift on every NPC birthday in one iteration
- "Festival Veteran" — attend all 4 festivals in one iteration
- "Town Savior" — help in 5 crisis events

## Save data

- npc_id → { affinity: int, mood: StringName, last_gift_day: int,
  last_talk_day: int, completed_personal_quests: Array[int],
  birthday_gifts_given_count: int }
- Active town event state
- Calendar / birthday schedule

## Files

- `_bmad-output/affinity/affinity_bible.md` — this file
- `scripts/resources/npc_definition.gd` — NPC data resource
- `scripts/systems/npc_database.gd` — all 12 NPC definitions
- `scripts/components/affinity_component.gd` — player-side affinity tracker
- `scripts/systems/gift_handler.gd` — gift giving logic
- `scripts/ui/affinity_screen.gd` — affinity UI panel
