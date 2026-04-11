---
name: Town Sub-Areas Bible
description: 8 hidden/optional areas tied to town with discovery rewards, story hooks, lore tablets
date: 2026-04-09
status: design + system complete; visual blockouts deferred to Blender
---

# Town Sub-Areas Bible

## Philosophy

Sub-areas are **the 20% of content the 80% of players never find**. They
exist to reward exploration, gate optional NPCs/lore, and give players a
reason to wander outside the main paths.

Each sub-area:
- Is connected to a main district or wilderness zone
- Hidden behind a small puzzle, NPC unlock, or off-the-beaten-path discovery
- Grants a **unique reward** when found (module, recipe, lore, NPC unlock)
- Has its own ambient music and lighting
- Persists across iterations once discovered

Inspired by:
- Hollow Knight (hidden rooms)
- Outer Wilds (atmospheric tucked-away places)
- Hades' chamber side rooms

## The 8 Sub-Areas

### 1. Outskirts — Transition to Wilderness
**Connects from:** Workshop District → east edge
**Hidden behind:** None (always visible, just easy to miss as a "side path")
**Discovery reward:** Recipe scroll for "Hunter's Mark" daemon module
**Lore:** "The line between town and wild was once clearer."
**NPCs found here:** Sentinel on patrol (high affinity gate)
**Ambient SFX:** wind, distant wilderness creature calls
**Music:** `wilderness_day` (slowly fading from town)

### 2. Cliffs — Overlook
**Connects from:** Outskirts → north climb
**Hidden behind:** Path requires noticing a vine-covered ladder
**Discovery reward:** Cosmetic title "Cliffwalker" + free Echo Bird egg
**Lore:** "From here, you can see the seams of the world."
**NPCs found here:** Legacy occasionally meditates here at dawn
**Ambient SFX:** strong wind, distant birdsong
**Music:** `wilderness_night` (atmospheric, contemplative)

### 3. Hidden Cave — Glitcher Quest Hub
**Connects from:** Cliffs → behind a waterfall
**Hidden behind:** Walk through the waterfall
**Discovery reward:** Unlock Glitcher faction NPC contact + first faction quest
**Lore:** "Where the broken gather."
**NPCs found here:** Null (Glitcher rep) — Epic 39
**Ambient SFX:** dripping water, distant glitch crackle
**Music:** custom dark variant

### 4. Sage's Garden — Private
**Connects from:** Sage's Sanctum → back door (Confidant tier with Sage)
**Hidden behind:** NPC affinity gate (Confidant tier with Sage)
**Discovery reward:** Sage's Mint seeds (rare crop) + lore tablet "Sage's Origin"
**Lore:** "Where memories are gardened."
**NPCs found here:** Sage occasionally tends flowers
**Ambient SFX:** wind chimes, soft choir hum
**Music:** ambient soft pad track

### 5. Iteration Memorial — Somber
**Connects from:** Residential District → south path
**Hidden behind:** Discoverable from iteration 4 onward (story-locked)
**Discovery reward:** "The Architect" outfit set first piece
**Lore:** "Names that fade. Names that remain."
**NPCs found here:** Legacy at memorial
**Ambient SFX:** low choral hum, occasional bell toll
**Music:** somber piano variant

### 6. Underground Lounge — Hidden Speakeasy
**Connects from:** Cache Tavern → back stairs
**Hidden behind:** Affinity Friend tier with Cache
**Discovery reward:** "Cozy" outfit set first piece + jukebox unlock
**Lore:** "Where the off-duty AIs go to be off-duty."
**NPCs found here:** Sync (musician) plays here at night
**Ambient SFX:** low jazz murmur, bottle clinks
**Music:** `tavern_music` variant with smoky reverb

### 7. Tower Top — Rooftop View
**Connects from:** Sage's Sanctum → top floor stairs
**Hidden behind:** Story-locked at iteration 5
**Discovery reward:** Telescope decoration + daily lore unlock
**Lore:** "From here, the simulation is small."
**NPCs found here:** Sage at iteration 7 cinematic
**Ambient SFX:** wind, distant city sounds
**Music:** ambient skybound track

### 8. Old Ruins — Pre-Game Lore
**Connects from:** Wilderness clearings → west edge
**Hidden behind:** Discoverable but easy to walk past
**Discovery reward:** 5 lore tablets revealing pre-iteration history
**Lore:** "Older than memory. Older than the loop."
**NPCs found here:** None — just lore objects
**Ambient SFX:** wind through stones, distant chime
**Music:** ambient ancient track

## Discovery flow

When the player enters a sub-area for the first time:
1. **Discovery cinematic** plays (5-second camera pan + name reveal)
2. **Achievement unlocked** + map marker added
3. **Reward granted** to inventory or as NPC interaction unlock
4. **Lore tablet** appears in the journal (if applicable)

## Save data

Tracked by `WorldMapManager.discovered_regions` (Epic 28). Sub-area
specific state (puzzle solved, reward claimed) lives in
`SubAreaManager.discovered_subareas` and `claimed_rewards`.

## Achievements

- "Wanderer" — discover 4 sub-areas
- "Lost Places" — discover all 8 sub-areas
- "Old Souls" — read all lore tablets in Old Ruins
- "Off-Duty" — find the Underground Lounge

## Files

- `_bmad-output/town/sub_areas_bible.md` — this file
- `scripts/systems/sub_area_database.gd` — 8 sub-area definitions
- `scripts/autoloads/sub_area_manager.gd` — discovery + reward state
- `scripts/components/sub_area_trigger.gd` — entry trigger scene component
