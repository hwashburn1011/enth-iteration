---
name: Open Wilderness Zone Bible
description: The connective wilderness between town and dungeons — biomes, landmarks, encounters, traversal, secrets
date: 2026-04-09
status: design complete; build deferred to Blender
---

# Open Wilderness Zone Bible

## One-line pitch

The wilderness is the **breath** between the comfort of town and the
violence of the dungeon — a single, traversable expanse the player
walks through (not loads into) where every horizon hides a secret and
every visit looks different.

## Why it matters

The current build has town → loading screen → dungeon. That's a
rhythm-killer. The wilderness fixes three problems at once:

1. **It makes the world feel real.** A player who can *walk* from
   the tavern door to the dungeon mouth without a load screen will
   never describe this game as "small" again.
2. **It carries the day-night and weather systems.** Night fog rolling
   off the river. Storm clouds breaking against the cliffs. These
   systems exist already (Epics 26/27) but have nowhere theatrical to
   play.
3. **It is the natural home for optional content.** Fishing, foraging,
   shrines, hidden groves, wandering NPCs, ambient encounters — none
   of these belong in the dungeon and none of them fit inside town.

## Design pillars

1. **Continuous, not chunked.** The wilderness is one streamed scene,
   not a hub-and-spoke of small rooms. Players see distant landmarks
   from the moment they leave town and walk *toward* them.
2. **Atmosphere over clutter.** A handful of perfect set-pieces beat
   fifty mediocre props. Every landmark must read as a silhouette.
3. **Short-loop traversal.** Town gate → nearest dungeon entrance is
   90 seconds at a normal walk, 35 seconds with the dash. Anything
   longer becomes a chore on iteration 6.
4. **Discoverable, not gated.** Almost no locked doors. Curiosity is
   the only key. Iteration-locked content fades in naturally rather
   than appearing as a "??? unlock at iteration 4" slot.
5. **Always show, never tell.** No NPCs explain the wilderness. The
   ruins, the dead Sentinel, the gravestones, the unfinished bridge
   — each tells its own story to the player who looks.

## Footprint and shape

- Roughly **220m × 180m** at the bounds. A player at default speed
  takes about 4 minutes to walk a perimeter loop.
- Bowl-shaped: town sits on the **north plateau** at +6m, the central
  river valley drops to **0m**, and the dungeon mouths line the
  **south cliffs** at -4m. Net descent gives the player a strong
  visual sense of "going down into" the dungeon.
- A single primary path winds south from the town gate. Secondary
  trails fork at the **Three Cairns** waypoint (river crossing,
  forest loop, ruin field).

```
                     N  (Town gate, +6m)
                     |
              .------+------.
              |  river plateau   forest fringe
              |             |
        ruin  |   THREE     |  hidden lake
        field |   CAIRNS    |  (NE corner)
              |             |
   bridge ----+----river----+---- shrine
              |             |
       grove  |             |  campsite
              |             |
              +---cliff line---+
              |  |  |  |  |
              D1 D2 D3 D4   (4 dungeon entrances, -4m)
```

## The 6 sub-regions

Each is a **named pocket** with its own biome dressing, music cue,
ambient SFX, and one signature landmark. Players don't see the names
on screen until they discover them (Epic 28 hook).

### 1. The North Plateau — `wild_plateau`
**Adjacent to:** Town's south gate
**Mood:** Familiar grass, open sky, the last edge of "safe"
**Signature landmark:** A weathered wooden archway marking the town
boundary, the words *"Past here, the loop forgets you"* carved into
the lintel.
**Vegetation:** Tame grass, scattered wildflowers, two old oaks
**Hostile encounters:** None (this is the "safety beach")
**Passive wildlife:** Echo birds, sim-rabbits, the occasional drift
of pollen motes
**Ambient music layer:** `wilderness_plateau` — bright woodwinds,
slow tempo
**Time-of-day cue:** Dawn here is golden; dusk is melancholy
**Hidden:** A loose paver near the archway lifts to reveal a cache
sprite stash

### 2. The River Valley — `wild_river`
**Adjacent to:** Plateau (north), Three Cairns (center)
**Mood:** Wet, alive, the heartbeat of the wilderness
**Signature landmark:** A **half-finished stone bridge** abandoned
mid-construction, scaffolding still in place. (Story hook: built by
the previous Globbler. Iteration 3 reveal.)
**Vegetation:** Reed grass, river willows, lily pads
**Hostile encounters:** Glitch eels (water), Bit beetles (banks)
**Passive wildlife:** Frogs, river otters, dragonflies that scatter
on approach
**Ambient music layer:** `wilderness_river` — running water as a
percussion bed under low strings
**Hidden:** Beneath the bridge scaffolding is a waterproof crate
containing the previous Globbler's journal page

### 3. The Forest Fringe — `wild_forest`
**Adjacent to:** River (west bank), Hidden Grove (interior)
**Mood:** Cool, dappled, a little watchful
**Signature landmark:** **The Listening Tree** — a single oak with
hundreds of small wind chimes hung in its branches, placed by Sage
across iterations. They sing in three different keys depending on
weather.
**Vegetation:** Mature deciduous canopy, fern undergrowth, mushroom
rings, bioluminescent moss patches at night
**Hostile encounters:** Stack overflow spiders, Null pointer wisps
**Passive wildlife:** Owls, foxes, fireflies after dusk
**Ambient music layer:** `wilderness_forest` — solo cello, then a
choir at night
**Hidden:** Following the firefly trails after dark leads to the
Hidden Grove sub-area

### 4. The Ruin Field — `wild_ruins`
**Adjacent to:** River (east bank)
**Mood:** Ancient, melancholic, the past leaking into the present
**Signature landmark:** **The Tilted Spire** — a 30m broken column
leaning at 20 degrees, glyphs along its length still faintly glowing
**Vegetation:** Cracked flagstone with moss, dead trees, climbing
ivy
**Hostile encounters:** Crash daemons (spawn from cracks), Memory
leaks (drift through ruined arches)
**Passive wildlife:** Ravens, lizards basking on warm stone
**Ambient music layer:** `wilderness_ruins` — drone with metallic
clicks, distant choir at night
**Hidden:** Mapping the glyph pattern on the spire opens a hatch in
the ruin floor (Old Ruins sub-area entrance)

### 5. The Cliff Line — `wild_cliffs`
**Adjacent to:** South edge of every other region
**Mood:** Edge of the world, the threshold to descent
**Signature landmark:** **The Four Mouths** — four dungeon entrances
carved into the cliff face, each a different biome's portal. They
glow faintly in their portal color even from the plateau.
**Vegetation:** Hardy scrub grass, wind-bent pines, hanging vines
**Hostile encounters:** None (the portals' presence keeps wildlife
away — the player should feel the silence)
**Passive wildlife:** Cliff swallows, wind itself
**Ambient music layer:** `wilderness_cliffs` — sub-bass drone,
suggesting weight underground
**Hidden:** A narrow ledge on the eastern cliff, accessed by a small
jump from the campsite, leads to the Cliffs sub-area overlook

### 6. The Quiet Pasture — `wild_pasture`
**Adjacent to:** Plateau (east), River (north bank)
**Mood:** Soft, bucolic, the wilderness's gift back to the player
**Signature landmark:** **The Campsite** — a stone fire ring with
two log benches, a sleeping bag, a kettle. A Sentinel patrol stops
here at dusk every day.
**Vegetation:** Long grass, clover, wildflowers, one giant willow
**Hostile encounters:** None
**Passive wildlife:** Sim-deer that appear at dawn and dusk, butterflies
**Ambient music layer:** `wilderness_pasture` — single guitar over
ambient pad
**Hidden:** Sleeping at the campsite advances time to dawn and grants
the *Well-Rested* buff (+10% XP for next dungeon run)

## Landmarks reference (the visual silhouette test)

A player who has seen each of these once can describe them from
memory. That is the bar.

| ID | Name | Region | Silhouette |
|----|------|--------|------------|
| `lm_arch` | Town Gate Archway | Plateau | Wooden trapezoid |
| `lm_bridge` | Half Bridge | River | Broken arch with scaffolding |
| `lm_listening_tree` | Listening Tree | Forest | Wide oak with dangling chimes |
| `lm_spire` | Tilted Spire | Ruins | Diagonal column |
| `lm_four_mouths` | The Four Mouths | Cliffs | Four glowing portals in a row |
| `lm_campsite` | The Campsite | Pasture | Fire ring + benches |
| `lm_three_cairns` | Three Cairns | Center | Three stacked stone piles at trail fork |
| `lm_shrine` | Shrine of the Loop | River | Small stone altar with wind chime |
| `lm_signpost_main` | Main Signpost | Plateau | Carved wood with 4 directions |

Each landmark must be **visible from at least two adjacent regions**
so that the player builds a mental map without ever opening the menu.

## Path network

- **The Old Road** — primary north-south path, town gate → main
  signpost → three cairns → cliff line. Wide enough to ride a Glide
  Hopper companion (Epic 41) two-abreast.
- **The River Walk** — east-west along the north bank, from forest
  fringe to ruin field. Crosses the river at the half-bridge ford.
- **The Forest Loop** — winds through the forest fringe, joins back
  to the old road at three cairns.
- **The Cliff Trail** — runs east along the top of the cliff line,
  past the campsite, ending at the eastern cliff overlook.

All paths are **dirt or stone**, never paved. Paving is reserved for
town. The contrast matters.

## Encounter design

### Passive wildlife (always-on ambience)
| Critter | Region | Behavior |
|---------|--------|----------|
| Echo bird | Plateau, forest | Sings at dawn, scatters on approach |
| Sim-rabbit | Plateau, pasture | Hops away when approached |
| Sim-deer | Pasture | Visible only dawn/dusk, flees |
| River otter | River | Swims, surfaces near player |
| Dragonfly | River | Hovers, no collision |
| Fox | Forest | Crosses path, doesn't engage |
| Owl | Forest (night only) | Calls from canopy |
| Firefly | Forest (night only) | Light source, leads to grove |
| Raven | Ruins | Sits on spire, flies in pairs |
| Lizard | Ruins | Skitters off warm stone |
| Cliff swallow | Cliffs | Wheels in groups of 5–8 |
| Frog | River banks | Croaks at night |
| Butterfly | Pasture, plateau | Day only |

### Hostile encounters (overworld combat)
- **Glitch eels** — river only, ambush from water
- **Bit beetles** — river banks, swarm of 4–6
- **Stack overflow spiders** — forest, drop from canopy
- **Null pointer wisps** — forest at night, float and explode
- **Crash daemons** — ruins, crawl out of floor cracks
- **Memory leaks** — ruins, drift through arches

Encounter spawn rules:
1. **Never within 20m of the player on first entry** to a region —
   the player must have a moment to take in the landmark.
2. **Never within 30m of a fast-travel waypoint** — waypoints are
   safety.
3. **Density scales with iteration**: iteration 1 has 30% spawn
   rate, iteration 9 has 100%. The wilderness gets meaner as the
   loop accelerates.
4. **No respawn during a single visit**. If you cleared the ruin
   field on this visit, it stays clear until you return from town.

### Wandering NPC events (rare, special)
1. **Sentinel patrol** — visible from the plateau, walks the old road
   south to north at dusk. If the player is friendly, hails them and
   may give a daily intel report.
2. **Lost Cache Sprite** — sometimes a cache sprite is stuck in a
   tree or rock; freeing it gives a small loot drop.
3. **Sage's wandering** — once per iteration, Sage walks the full
   loop carrying a lantern. Talking to her here gives unique dialogue.
4. **Glitcher messenger** — late iterations only; a Glitcher NPC
   waits at the half-bridge with a faction quest hook (Epic 39).
5. **Memorial visitor** — Legacy occasionally walks to the ruin field
   alone, kneels by the spire, walks back. Cannot be interrupted.

## Resource gathering

| Node type | Region | Tool | Yield |
|-----------|--------|------|-------|
| Wood log | Forest | Axe | Lumber |
| Wild herb | Plateau, pasture | Hands | Healing herb |
| River fish | River fishing spots | Rod | Fish (3 types) |
| Stone block | Ruins | Pickaxe | Stone |
| Glow moss | Forest (night) | Hands | Light reagent |
| Wild mint | Pasture | Hands | Cooking |
| Echo feather | Cliffs (after Echo bird) | Hands | Crafting |
| Iron vein | Ruins | Pickaxe | Iron ingot |

Nodes respawn on a **24 in-game hour** timer.

## Hidden content

Three discoverable spots that flow into existing systems:

1. **Hidden Grove** (`wilderness_hidden_grove`) — found by following
   fireflies into the forest at night. Sub-area trigger places
   `SubAreaTrigger` with id `hidden_grove`. Contains a unique fishing
   pond with a rare fish.
2. **Hidden Lake** (`wilderness_hidden_lake`) — NE corner past a
   waterfall vine ladder. Holds a sunken cache with the *Drowned*
   outfit set first piece.
3. **Hidden Cave** (`hidden_cave` — already in SubAreaDatabase) —
   found by walking through the river waterfall. Glitcher quest hub.

## Day-night cycle hooks

| Phase | Wilderness change |
|-------|-------------------|
| Dawn | Mist rises off river; deer appear in pasture; echo birds sing |
| Day  | Standard ambience; full enemy spawns |
| Dusk | Sentinel patrol passes through; long shadows; sky turns gold |
| Night | Fireflies in forest; owls call; null pointer wisps spawn |

## Weather hooks

| Weather | Wilderness change |
|---------|-------------------|
| Clear   | Standard |
| Cloudy  | Color desaturates; no other change |
| Rain    | River volume up; ground darkens; passive wildlife hides |
| Storm   | Lightning silhouettes the cliffs; river gains rapids |
| Fog     | Visibility 30m; eerie; ambient music drops to single sustained note |
| Glitch storm | Sky cracks; brief glitch enemy surge in ruins |

## Music layering

Each region has its own music layer that crossfades on entry. The
**base layer** is a soft wind drone that always plays at -18dB,
binding the regions together so transitions never feel jarring.

```
base_wind_layer (always on, -18dB)
  +
region_layer (crossfade on region change, -6dB)
  +
encounter_layer (rises in combat, -3dB)
  +
weather_layer (e.g., rain, storm) (situational, -9dB)
```

## Save data

- `WildernessManager.discovered_landmarks: Array[StringName]` — which
  of the 9 landmarks have been seen
- `WildernessManager.cleared_regions: Dictionary` — region_id →
  in-game hour cleared, used for the no-respawn rule
- `WildernessManager.collected_resources: Dictionary` — node id →
  in-game hour gathered, used for the 24h respawn rule

## Achievements

- **"Out the Gate"** — leave town for the first time
- **"Mapmaker"** — discover all 9 landmarks
- **"Six Faces of the Wild"** — set foot in all 6 sub-regions
- **"The Long Walk"** — complete a full perimeter loop in one visit
- **"Friend of the Wild"** — see a sim-deer up close (within 5m
  without it fleeing — only possible with the *Quiet Step* perk)

## Files

- `_bmad-output/wilderness/wilderness_bible.md` — this file
- `scripts/systems/wilderness_landmark_database.gd` — landmark catalog
- `scripts/autoloads/wilderness_manager.gd` — discovery + clear state
- `scripts/components/wilderness_landmark_trigger.gd` — proximity discovery component

## Build deferred to Blender

Tasks 2–11 (terrain sculpt, river course, cliff walls, vegetation,
clearings, ruin props, path network, signposts) all wait for Blender
MCP. The bible above is the **production target** — when modeling
resumes, it answers every "what goes here?" question without
requiring a return trip to design.
