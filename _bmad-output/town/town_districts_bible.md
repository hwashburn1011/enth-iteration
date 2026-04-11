---
name: Town Districts Bible
description: 5 town districts with identity, NPC residents, music, lighting, quest hubs, fast-travel
date: 2026-04-09
status: design + system complete; layout/blockout/buildings deferred to Blender
---

# Town Districts Bible

## Philosophy

The town is divided into **5 distinct districts**, each with its own
identity, mood, and reason to visit. Walking from one to the next should
feel like crossing a threshold — different music, different ambient SFX,
different NPCs, different daylight quality.

The full town walk (residential → market → commons → workshop → docks)
should take about 2-3 minutes at normal walk speed. Fast travel makes
it instant.

Inspired by:
- Stardew Valley (Pelican Town's recognizable layout)
- Final Fantasy XIV (Limsa Lominsa's tiered districts)
- Genshin Impact (Liyue Harbor's market vs upper city)

## The 5 Districts

### 1. Residential District — "Where We Live"
**Vibe:** Quiet, cozy, homely
**Color palette:** warm browns, soft greens, off-white
**Ambient SFX:** distant bird chirps, occasional wind chime, NPC chatter
**Music:** `district_residential` — gentle acoustic guitar + flute
**Lighting profile:** soft warm sun, golden hour favored
**NPCs in residence:** Pixel, Cache, Bit (child), Legacy (elder), Render
**Quest hub:** small plaque outside the town hall annex
**Hero buildings:** Sage's Sanctum (referenced from Epic 11)
**Connecting districts:** Market (east), Commons (south)
**Lore:** "Where lives are stored. Where iterations rest between."

### 2. Market District — "Where We Trade"
**Vibe:** Bouncy, busy, social
**Color palette:** bright oranges, deep blues, market awnings
**Ambient SFX:** stall vendors calling, footsteps, bag rustle
**Music:** `district_market` — percussion + brass + chimes
**Lighting profile:** bright midday sun, lots of bloom
**NPCs in residence:** Trade (merchant boss), Pixel (shopkeeper rotates here)
**Quest hub:** Trade's stall hub board
**Hero buildings:** Cache Tavern (referenced from Epic 11)
**Connecting districts:** Residential (west), Commons (south), Workshop (east)
**Lore:** "Where things become other things."

### 3. Commons District — "Where We Meet"
**Vibe:** Friendly, social, the heart of town
**Color palette:** rich warm wood, copper, soft amber
**Ambient SFX:** tavern murmur, library page-turning, plaza fountain
**Music:** `district_commons` — piano + light strings
**Lighting profile:** soft mixed light, baked GI heavy
**NPCs in residence:** Cache (barkeep), Index (librarian), Sync (musician in lounge)
**Quest hub:** Town hall main board
**Hero buildings:** Index Archive, Cache Tavern (referenced from Epic 11)
**Connecting districts:** Residential (north), Market (north), Workshop (east), Docks (south)
**Lore:** "Where stories begin and end."

### 4. Workshop District — "Where We Build"
**Vibe:** Rhythmic, industrial, busy with purpose
**Color palette:** charcoal, rust orange, copper, ember light
**Ambient SFX:** forge hammer, lab bubbles, mechanical hum
**Music:** `district_workshop` — hammer percussion + bass synth
**Lighting profile:** harder sunlight + ember glow from forge
**NPCs in residence:** Forge (blacksmith), Lab (scientist), Reflection (respec NPC), Sentinel (guard)
**Quest hub:** Forge's anvil-side board
**Hero buildings:** Forge Foundry, Render Studio (referenced from Epic 11)
**Connecting districts:** Market (west), Commons (west), Wilderness (east)
**Lore:** "Where ideas take form."

### 5. Docks District — "Where We Look Out"
**Vibe:** Breezy, melancholy, full of possibility
**Color palette:** sea blues, sandy beige, weathered wood
**Ambient SFX:** waves, distant gulls, creaking ropes
**Music:** `district_docks` — accordion + strings + wave SFX
**Lighting profile:** bright reflective sun, lots of SSR on water
**NPCs in residence:** Harvest (farmer with riverside plot), occasional NPCs visiting
**Quest hub:** dock master's board
**Hero buildings:** small wooden pier, exotic goods stall
**Connecting districts:** Commons (north), Wilderness river (east)
**Special:** Fishing spots from Epic 35, boat dock interaction
**Lore:** "Where the world reaches us."

## Walk distance + scale

Total town walking time at base move speed (4.5 m/s):
- Residential center to Market center: 30 seconds
- Market to Commons: 25 seconds
- Commons to Workshop: 30 seconds
- Commons to Docks: 35 seconds
- **Total perimeter walk: ~2 minutes 30 seconds**

This is intentional. Far enough to feel like a real place, short enough
that fast travel isn't strictly necessary.

## NPC residence assignment

Each NPC has a "home district" (where they sleep) and a "work district"
(where they work during the day). Their schedule (Epic 26) moves them
between the two.

| NPC | Home | Work |
|---|---|---|
| Pixel | Residential | Market (shop) |
| Forge | Workshop | Workshop (forge) |
| Cache | Commons | Commons (tavern) |
| Index | Commons | Commons (library) |
| Harvest | Residential | Docks (river plot) |
| Bit | Residential | (plays everywhere) |
| Legacy | Residential | Commons (memorial) |
| Trade | Market | Market (stall) |
| Lab | Workshop | Workshop (lab) |
| Render | Residential | Workshop (studio) |
| Sync | Commons | Commons (lounge) |
| Sentinel | Workshop | Workshop (watchtower) |

## District-specific quest hubs

Each district has a small board where the player can pick up daily
quests + side quests offered by the district's NPCs. The quest log
filter (Epic 38) supports filtering by district.

## Fast travel between districts

Once a district is discovered, the player can fast travel between any
discovered districts via the world map (Epic 28). Fast travel within
town is **instant** (no loading screen) since they're all in the same
scene tree under different sub-zones.

## District boundaries

Visual boundaries between districts:
- **Archway markers** at the connecting paths (Epic 11 hero building)
- **Subtle color shift** in lighting profile
- **Music crossfade** as the player crosses
- **Optional district name floating label** that appears for 2 seconds

## Save data

Tracked separately by Epic 28's `WorldMapManager` (which already tracks
discovered regions including the 5 districts).

## Achievements

- "Town Tour" — visit all 5 districts in one in-game day
- "District Resident" — spend 1 in-game day in each district
- "Friend of the Workshop" — reach Friend tier with all Workshop NPCs

## Files

- `_bmad-output/town/town_districts_bible.md` — this file
- `scripts/systems/town_district_database.gd` — 5 district definitions
- `scripts/autoloads/district_manager.gd` — global district state + transitions
