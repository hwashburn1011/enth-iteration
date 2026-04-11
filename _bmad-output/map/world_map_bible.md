---
name: World Map & Fast Travel Bible
description: Pan/zoom world map UI, fast travel network, mini-map HUD, waypoints, fog of war
date: 2026-04-09
status: design + system complete; map background art deferred to Blender
---

# World Map Bible

## Philosophy

The world map is the **player's mental model of the world**, surfaced
visually. It tracks where they've been, what they've found, and what's
left to discover. Fast travel is the convenience layer on top — once
you've earned a place, you can return.

Inspired by:
- Hollow Knight (hand-drawn style + reveal-by-discovery)
- Stardew Valley (clean, readable, marker-based)
- Tunic (mysterious, fold-out, unfolds with progress)

## Map structure

The world has **18 regions** organized into 3 layers:
- **Town (5 districts)** — always visible from start
- **Wilderness (8 sub-areas)** — discovered through exploration
- **Dungeons (5 biomes + final vault)** — unlocked through main story

Each region has:
- Position on the map
- Name + description
- Discovery state (hidden / visible / explored)
- Fast travel waypoint flag
- Connected regions (for path drawing)
- Marker pool (NPCs, quests, lore tablets, hidden rooms)

## Discovery / fog of war

States per region:
- **Hidden:** invisible on the map (you don't know it exists)
- **Heard about:** silhouette visible, name "???"
- **Discovered:** marker visible, name shown, but interior unexplored
- **Explored:** marker + interior layout visible + completion %

Discovery triggers:
- Heard about: NPC mentions it in dialogue
- Discovered: player visits the region for the first time
- Explored: player has visited every room/marker in the region

## Fast travel waypoints

Once a region is "discovered," it becomes a fast travel destination.
Player opens map → clicks waypoint → confirms → cinematic transition.

**Restrictions:**
- Cannot fast travel during combat
- Cannot fast travel from inside a dungeon (must reach the entrance)
- Some story moments lock fast travel temporarily

**Cost:** none — fast travel is free in Enth (no resource cost like
Stardew Valley's energy).

## Map markers

Each region has its own marker pool:
- **NPC markers** — show where each NPC currently is (driven by NPC schedule)
- **Quest markers** — yellow exclamation points for available quests
- **Quest objective markers** — bright pulsing for active quests
- **Lore markers** — book icons for lore tablets
- **Hidden room markers** — appear when discovered
- **Daily quest markers** — refresh each day

Markers fade in/out smoothly when state changes.

## Mini-map HUD overlay

Top-right of HUD: small mini-map showing the player's local area.
- Player at center, north up
- Current region highlighted
- Visible markers within ~50m radius
- Enemy radar (red dots for hostile mobs in range)
- Interactable highlights (yellow for objects you can use)

Player can toggle mini-map size/opacity via accessibility settings.

## Waypoint system

Player can place a custom waypoint on the map by right-clicking. The
waypoint shows as:
- A dot on the world map
- A floating arrow on the HUD pointing toward it
- A line drawn on the mini-map

Only one waypoint at a time. Can be cleared by right-clicking again.

## Map filtering

Filter dropdown in the map UI:
- All markers
- NPCs only
- Quests only (active + available)
- Lore only
- Hidden rooms only
- Achievements only

Search bar filters markers by name.

## Per-iteration evolution

The map subtly changes between iterations:
- Iteration 1: clean lines, default colors
- Iteration 3: subtle wear, vines on edges
- Iteration 5: visible age, glitch artifacts in corners
- Iteration 7: corruption mixed in, "lost" regions appear
- Iteration 9: full corruption, but with hopeful markers added

## Region completion %

Each region tracks:
- NPCs talked to / total NPCs in region
- Quests completed / total quests in region
- Lore tablets read / total tablets
- Secret rooms found / total

The overall % shows in the region tooltip and on the marker.

## Map music sting

When the player opens the map, a soft sting plays. Different per zone:
- Town: warm chime
- Wilderness: distant flute
- Dungeon: tense pulse
- Boss arena: dramatic hit

## Save data

- discovered_regions: Array[StringName]
- explored_regions: Array[StringName]
- fast_travel_unlocked: Array[StringName]
- waypoint_position: Vector2
- waypoint_active: bool
- player_notes: Dictionary[Vector2 → String]
- last_viewed_region_id: StringName

## Files

- `_bmad-output/map/world_map_bible.md` — this file
- `scripts/systems/region_database.gd` — 18 region definitions
- `scripts/autoloads/world_map_manager.gd` — global map state
- `scripts/ui/world_map_ui.gd` — pan/zoom map UI
- `scripts/ui/mini_map_hud.gd` — top-right mini-map widget
- `scripts/systems/fast_travel.gd` — fast travel transition handler
