---
name: Town Hub Expansion Bible
description: Underground + vertical town additions — 13 new hub spaces ranging from a hidden lounge to a training arena to a memorial gallery
date: 2026-04-09
status: design complete; build deferred to Blender
---

# Town Hub Expansion Bible

## One-line pitch

The town stops being a single street and becomes a **place with rooms
above it and rooms beneath it** — every iteration the player learns
about a new pocket they didn't know existed last loop.

## Why it matters

The current town is a single elongated street with a few buildings the
player visits in a fixed order. Three problems:

1. **It feels small.** A player who has played for two iterations has
   already seen everything the town has to offer. There's no "wait,
   what's *down there*?" moment after the first hour.
2. **The life-sim systems have nowhere to live.** Farming, cooking,
   crafting, pet feeding, and trophy display all exist as gameplay
   systems but don't have first-class *spaces* in the town.
3. **The 9-iteration arc has no architectural progression.** The town
   should *grow* across iterations the way the player does. Hub
   expansion is the visible record of that growth.

## Design pillars

1. **Vertical AND underground.** Half the new spaces go *up* (Sage's
   tower, observation deck, training arena rooftop). Half go *down*
   (underground lounge, hidden treasure room, sub-cellar memorial).
   Town gains a Z-axis.
2. **One space per system.** Every new gameplay system (farming,
   cooking, crafting, fishing, pets, training, wardrobe) gets a real
   physical room. No more menu-only systems in town.
3. **Discovery through iteration.** Each iteration unlocks one or two
   new spaces. The player builds a mental map of the town that grows
   across the 9-iteration loop.
4. **Mood progression up/down.** Underground spaces are warmer,
   smaller, more intimate. Aboveground spaces are cooler, larger, more
   contemplative. The architecture *teaches* the mood.
5. **Every space has a reason to return.** Each room either has a
   recurring activity (cook a daily meal, feed pets, harvest crops),
   a slow drip of new content (memorial plaques unlock per iteration),
   or a friend who's only there at certain times.

## The 13 new spaces

### 1. Underground Lounge — `hub_lounge`
**Connects from:** Cache's Tavern → back stairs (covered already by
the Sub-Areas Bible — this is the playable build of that pocket)
**Mood:** Warm, smoky, low-jazz, the town's best-kept secret
**Iteration unlock:** Iteration 1 (always available, just hidden behind
Cache Friend tier — see Sub-Area Bible)
**Layout:** 8m × 12m room, low ceiling (2.6m), brick walls, 6 booth
seats around the perimeter, central bar, small jazz stage on the far
wall, jukebox in the back corner, stairwell down from the tavern
**Lighting:** Warm tungsten lanterns at booths, single spot on stage,
faint blue cove lighting under the bar
**Furniture props (task 3):**
- 6 leather booth seats (3 left, 3 right)
- 1 bar (4 stools)
- 1 jazz stage with stool + small table
- 1 jukebox
- 1 piano
- 4 small round tables
- 8 hanging lanterns
- bottles, glasses, ashtrays as scatter dressing
**Bar interactive (task 4):** Cache (or her stand-in) serves nightly
specials — a drink that grants a temporary buff for the next dungeon
run. Like the shrine but social and short-duration.
**Stage (task 5):** On nights when Sync (musician NPC) is here, music
plays. Sync only appears between 22:00–02:00.
**NPCs (task 6):**
- Cache (host, evenings only)
- Sync (musician, nights only)
- 2 ambient regulars (rotate from the broader NPC cast)
**Dialogue hook (task 7):** Cache offers special conversations only
available in the lounge — confessions, secrets, lore she'd never share
upstairs.

### 2. Tower Top — `hub_tower_top`
**Connects from:** Sage's Sanctum → top floor stairs
**Mood:** Cool, vast, contemplative, the highest point in town
**Iteration unlock:** Iteration 5 (story-locked, see Sub-Area Bible)
**Layout:** Open circular platform 6m diameter, surrounded by a low
stone railing, an iron telescope on a tripod at the south edge,
panoramic view of the wilderness and the four mouths
**Lighting:** Open sky, no roof — uses the wilderness day-night cycle
**Telescope interaction (task 11):** Aim at:
- The Four Mouths → unlocks lore tablet for the unselected dungeon
  biome of the day
- The Listening Tree → small lore line about Sage's chimes
- The Tilted Spire → lore line about the glyphs
- The Final Vault (after iter 4) → grim numerical countdown of
  remaining seals
- The Pasture deer at dawn → unlocks "Watcher" cosmetic title
- The North Star (night only) → grants the *Starlit* buff for next run
**Spiral staircase (task 9):** 22 steps from the sanctum first floor.
Wooden steps with iron handrail, lit by lanterns at every fifth step.

### 3. Sage's Tower Study Room — `hub_sage_study`
**Connects from:** Sage's Sanctum → side door (Confidant tier with Sage)
**Mood:** Wood-paneled, lived-in, slightly chaotic, smells of old paper
**Iteration unlock:** Iteration 3 (Sage trust gate)
**Layout:** 6m × 5m corner room with one bay window facing east,
a writing desk, three armchairs around a small fireplace, walls
covered floor-to-ceiling in pinned-up scraps and notes
**Furniture props:**
- writing desk with quill, ink, journal
- 3 armchairs
- small fireplace (functional, plays warm light + crackle SFX)
- wall corkboards covered in pinned notes (interactable for lore)
- bay window seat with cushions
**Interaction:** Sage is here every dawn writing in her journal. Sit
in the second armchair to start a long-form dialogue tree that gives
the most lore-dense conversations in the game.

### 4. Sage's Library — `hub_sage_library`
**Connects from:** Sage's Sanctum → main hall door
**Mood:** Tall, quiet, breathing-with-paper, choir-pad ambient
**Iteration unlock:** Iteration 2 (always visible from iter 2)
**Layout:** Two-story room 10m × 8m, 6m ceiling, four bookshelves
floor-to-ceiling, central reading table with five chairs, ladder on
rails for upper shelves, archive crystal pedestal at the back
**Archive crystal interaction (task 15):** A floating crystal at the
back of the library that the player can touch to:
- Read any lore tablet they've collected (unified lore browser)
- Replay any past iteration's cinematic
- View Sage's journal entries unlocked so far
- Browse "the Forgotten Index" — entries from previous Globblers
  (unlock 1 per iteration cleared)

### 5. Training Arena — `hub_training_arena`
**Connects from:** Workshop District → back lot
**Mood:** Open, dusty, sun-bleached, the smell of metal
**Iteration unlock:** Iteration 1 (always available)
**Layout:** 14m × 12m walled enclosure with a packed-dirt floor, six
training dummies on the perimeter, weapon rack, target practice line,
a raised observation balcony along one wall
**Target dummies (task 17):**
- 1 stationary humanoid for melee
- 1 small fast-moving humanoid (scripted patrol) for tracking
- 1 large slow tank for sustained DPS testing
- 1 floating sphere for projectile aim
- 1 multi-target cluster (3 dummies in formation)
- 1 boss-sized tank with stagger meter for ultimate practice
**Reset button (task 18):** A lever on the wall resets all dummies,
clears damage tracking, restarts a 20-second DPS measurement, and
broadcasts the result to a leaderboard plaque on the wall.
**Why it matters:** The first place a new player can *test* their
build before walking it into a dungeon. Reduces the "what does this
ability actually do" friction by 90%.

### 6. Farm Plot Area — `hub_farm`
**Connects from:** Residential District → south fence
**Mood:** Open, golden-hour, the smell of turned earth
**Iteration unlock:** Iteration 1 (always available)
**Layout:** 12m × 16m fenced field with a 4×4 grid of farming plots
(16 plots), a tool shed at the north edge, a watering well at the
center, a compost bin in the corner
**Planting interaction (task 20):** Use existing FarmingComponent +
FarmPlot system from prior epics. Each plot is a `FarmPlot` instance.
**Harvesting (task 21):** Hold interact on a mature plot, get the
crop into inventory.
**Crops:** Wild herb, mint, sunpetal, carrot, glow turnip, time melon
(rare crop with iteration-related lore)

### 7. Fishing Dock — `hub_fishing_dock`
**Connects from:** Town Docks district → east pier
**Mood:** Salt air, soft waves, gulls calling, golden at dusk
**Iteration unlock:** Iteration 1 (always available)
**Layout:** L-shaped wooden pier extending 8m into the water, with a
small bait shed at the base, a bench for sitting, and three fishing
spots at different points along the pier
**Fishing rod prop (task 23):** A real rod animation when the player
casts — line arcs out, bobber lands, ripples spread. Uses the
WildernessFishingSpot component but with `region_id = town_docks`.

### 8. Cooking Station — `hub_cooking`
**Connects from:** Cache's Tavern → kitchen door (after Cache Friend tier)
**Mood:** Warm, busy, smells of broth, copper pans hanging from beams
**Iteration unlock:** Iteration 2 (Cache trust gate)
**Layout:** 6m × 5m kitchen with a central island, a hearth on the
back wall, an ingredient pantry, hanging copper pans, two stools at
the island
**Cooking interaction (task 25):** A simplified crafting UI tied to
the existing recipe system, but specifically for food. Combines
ingredients into meal items that grant timed buffs. Cache gives the
player a recipe book on first interaction.

### 9. Crafting Workshop Area — `hub_workshop`
**Connects from:** Workshop District → main hall
**Mood:** Loud, sparking, smells of hot metal, organized chaos
**Iteration unlock:** Iteration 1 (always available)
**Layout:** 10m × 10m workshop with three stations:
- forge (weapons / armor reforging)
- bench (modules / accessories)
- shaper (cosmetics / dye / transmog)
**Each station** uses the existing crafting recipe system filtered to
its category. The forge is staffed by a smith NPC who upgrades over
iterations.

### 10. Pet Hutch Area — `hub_pet_hutch`
**Connects from:** Residential District → north corner
**Mood:** Soft, warm, smells of straw, gentle animal sounds
**Iteration unlock:** Iteration 2 (after first pet acquisition)
**Layout:** 8m × 6m enclosed yard with 4 small huts along the back
wall, water bowls, food trough, scratch posts, a sunny patch in the
center
**Pet feeding interaction (task 29):** Each pet has a hunger meter
that decays per in-game day. Feeding pumps a happiness tier (the
existing PetComponent already has the four-tier system). Well-fed
pets gain bonus stat contributions in dungeons.

### 11. Memorial Gallery — `hub_memorial_gallery`
**Connects from:** Sage's Sanctum → north corridor (after Iteration 4)
**Mood:** Hushed, candle-lit, choral hum, the smell of incense
**Iteration unlock:** Iteration 4 (story gate)
**Layout:** Long narrow hall 4m × 14m with iteration plaques in
recessed alcoves on both walls — 9 alcoves total, one per iteration.
A central memorial cenotaph at the far end with a single perpetual
candle.
**Plaques (task 31):**
- Each plaque carries: the iteration number, a portrait silhouette of
  that loop's Globbler, a quote from their final journal entry, and
  the date they "ended"
- Plaque for the *current* iteration unlocks at iteration end
- Plaque for the *previous* Globblers (1-9) unlocks one per iteration
  cleared, building the Memorial Gallery slowly across the player's
  whole 9-iteration arc
**Why it matters:** This is the room that hits hardest at iteration 9,
when the player walks in and sees nine plaques and realizes their own
plaque is going to be next.

### 12. Trophy Display Hall — `hub_trophy_hall`
**Connects from:** Workshop District → display annex
**Mood:** Polished, lit by individual spot lights, museum-quiet
**Iteration unlock:** Iteration 1 (starts empty)
**Layout:** 10m × 6m hall with 12 trophy mount points along both walls,
each mount pre-labeled with the trophy it can hold, lit by a small
spotlight
**Trophy mounts (task 33):**
- Boss heads (6 — one per major boss)
- Rare fish (3 — voidshark, dream whale, loop ancient)
- Hidden treasures (3 — special items from rare encounters)
**Each mount** is empty until the player has earned the trophy. On
mount, the spotlight ignites and a small description plaque appears.
**Why it matters:** The visible record of the player's accomplishments,
visited by NPCs who comment on the new mounts ("Cache just stopped by
to see your voidshark — she said it was the largest she'd ever seen.")

### 13. Wardrobe Room — `hub_wardrobe`
**Connects from:** Residential District → player home interior
**Mood:** Soft natural light, full-length mirror on the back wall,
smell of cedar
**Iteration unlock:** Iteration 1 (always available)
**Layout:** 5m × 5m room with a full-length mirror on the back wall,
8 mannequins displaying outfit sets along the side walls, a wardrobe
chest, a dye station
**Wardrobe interaction (task 35):** The existing
EquipmentVisualizer + OutfitItem system already drives this, but the
room is the *physical* place to access it. Standing in front of the
mirror opens the dressing UI; clicking a mannequin equips that whole
outfit set.

### 14. Hidden Treasure Room — `hub_hidden_treasure`
**Connects from:** Sage's Library → behind the second bookshelf on
the right, requires solving a hidden puzzle
**Mood:** Sparse, dusty, gold-tinted, "no one has been here in
iterations"
**Iteration unlock:** Iteration 6 (puzzle gate, see below)
**Layout:** Small 5m × 5m room with a single ornate chest on a stone
pedestal, surrounded by candle stubs, dust on the floor showing your
own footprints
**Hidden door puzzle (task 37):** Five books on the second bookshelf
must be pulled in a specific order. The order is hinted at by reading
five lore tablets scattered across the wilderness ruins (sequence:
spire glyphs → arch inscription → bridge journal → memorial plaque →
shrine offering bowl).
**Treasure room contents (task 38):**
- A unique outfit piece "The Inheritor" (head slot)
- A lore tablet that reveals what the previous Globbler was hiding
- A small key that unlocks one more vault inside the Memorial Gallery

## Discovery flow

When the player enters a new hub space for the first time:
1. Brief no-letterbox camera flourish (1.5–2.5s)
2. Achievement: "Found {space_name}"
3. Map marker added (Hub Expansion fast-travel set)
4. The space's owner NPC (if any) acknowledges first visit on the
   next dialogue

## Save data

- `HubExpansionManager.discovered_spaces: Array[StringName]` — which
  of the 13 spaces have been entered
- `HubExpansionManager.unlocked_iteration: Dictionary` — space_id →
  the iteration the player unlocked it (for memorial display)

## Achievements

- **"Underground"** — Find the Underground Lounge
- **"Above the Clouds"** — Reach Tower Top
- **"Hand of the Sage"** — Be invited into Sage's Study Room
- **"Long Memory"** — Walk every alcove in the Memorial Gallery
- **"Mounted"** — Display 6 trophies in the Trophy Hall
- **"Inheritor"** — Solve the hidden bookshelf puzzle and open the
  treasure chest

## Files

- `_bmad-output/hub_expansion/hub_expansion_bible.md` — this file
- `scripts/systems/hub_space_database.gd` — 13 space definitions
- `scripts/autoloads/hub_expansion_manager.gd` — discovery + unlock state
- `scripts/components/hub_space_trigger.gd` — entry trigger
- `scripts/components/hidden_bookshelf_puzzle.gd` — sequence puzzle
- `scripts/components/cooking_station.gd` — kitchen interaction
- `scripts/components/training_dummy.gd` — DPS measurement target
- `scripts/components/trophy_mount.gd` — display mount

## Build deferred to Blender

Tasks 2, 8–10, 13–14, 16, 19, 22, 24, 26, 28, 30, 32, 34, 36, 38, 41,
42, 43 (the actual scene authoring + prop placement + lighting bake +
hero shots) all wait for Blender MCP. The bible above is the
production target — when modeling resumes, every scene knows exactly
what props, what mood, what NPC schedule, what interactions to wire
up.
