---
name: Weather System Bible
description: 6 weather types, transition rules, per-zone defaults, gameplay hooks, reactive elements
date: 2026-04-09
status: design + system complete; particle/shader visual integration pending
---

# Weather System Bible

## Philosophy

Weather in Enth is **mood-changer + light gameplay modifier**. It's not
trying to be Death Stranding's punishing rain — it's there to make the
world feel alive and give certain content a reason to be time-locked
("only catchable in storms," "only spawns during glitch weather").

The weather system layers on top of the day/night cycle. Both run
independently but query each other for visual interpolation (e.g. rain
at night looks different from rain at day).

## 6 Weather types

| ID | Name | Vibe | Frequency | Zones |
|---|---|---|---|---|
| `clear` | Clear | sunny + warm | 60% default | all |
| `cloudy` | Cloudy | overcast + cool | 25% default | all |
| `rain` | Rain | wet + steady | 8% default | town, wilderness |
| `storm` | Storm | rain + wind + lightning | 4% default | wilderness, dungeon openings |
| `fog` | Fog | dense + mysterious | 2% default | wilderness, dungeon |
| `glitch_storm` | Glitch Storm | corrupted + dangerous | 1% default | corrupted wilds, late iterations |

**Late-iteration shift:** as the player advances through iterations,
glitch storms become more common (1% → 8% by iteration 8). The world is
breaking down.

## Weather transition rules

- Each zone has a "default weather" that the system tries to return to
  over time
- Weather changes every 8-16 in-game minutes (4-8 real seconds in town)
- Smooth crossfade over 30 in-game seconds
- Some transitions are forbidden:
  - Clear → glitch storm (must pass through cloudy)
  - Storm → clear (must pass through cloudy)
- Glitch storms can trigger any time as a special event (story flag)

## Per-zone weather defaults

| Zone | Default | Notes |
|---|---|---|
| Town center | clear | always default |
| Town districts | clear | each district can override |
| Wilderness | cloudy | more variable |
| Server Room dungeon | clear | mostly indoor |
| Memory Vaults | fog | atmospheric |
| Corrupted Wilds | glitch_storm | thematic match |
| Final Vault | clear | dramatic backdrop |
| Boss arenas | matches biome | unchanged during fight |

## Gameplay hooks

### Combat modifiers
- **Rain:** -25% fire damage (water dampens)
- **Storm:** +25% lightning damage, +10% chain lightning hop
- **Fog:** enemies harder to see (LoS reduced 30%)
- **Glitch storm:** random buff/debuff every 10 seconds, both player and enemies

### Fishing modifiers
- **Rain:** +20% rare fish chance
- **Storm:** **only time** to catch Voidshark
- **Clear:** +20% Compiled Tuna chance

### Crop modifiers
- **Rain:** crops auto-watered (skip watering for the day)
- **Storm:** 5% chance to flatten unwatered crops
- **Clear:** crops grow at normal rate
- **Glitch storm:** crops have 10% chance to mutate (Silver/Gold quality)

### NPC dialogue
- Each NPC has 3-5 weather-specific dialogue lines
- "Lovely day for it!" / "I hate the rain..." / "Have you seen this storm?"
- NPCs in town head indoors during rain/storm

### Quest gating
- Some quests only unlock during specific weather:
  - "Storm Chaser" — fishing quest, rain only
  - "Foggy Mystery" — exploration quest, fog only
  - "The Glitch in the System" — story-locked, glitch storm only

## Wind direction system

Each weather has an associated wind direction + strength that drives:
- Vegetation shader sway (Epic 20: vertex_wind.gdshader)
- Particle drift (rain falling at angle, etc.)
- Cloth physics on capes/banners

Wind direction tween over 5 seconds during weather transitions.

## Visual effects (deferred to Blender/scene work)

The system fires the right signals; the actual particles, shaders, and
overlay effects are wired up at the scene level:

- Rain: GPUParticles3D rain emitter + rain_wetness shader on terrain
- Storm: rain emitter + lightning flash CanvasItem + wind audio
- Fog: WorldEnvironment fog density override
- Glitch storm: glitch_displacement shader on world objects + glitch SFX
- Clear: sun shafts via godrays + extra bloom
- Cloudy: dimmed sun + cloud shadow texture overlay

## SFX

Per weather, the SFXManager plays:
- `rain_loop` (3D ambient, no spatialization)
- `wind_gust_loop`
- `thunder_random` (one-shot, randomly triggered every 10-30s during storm)
- `glitch_crackle_loop` (during glitch storm)
- `fire_crackle_loop` (suppressed during rain — no campfires)

## UI weather indicator

Top-left near the clock: small icon showing current weather.
- Sun (clear) / cloud (cloudy) / cloud+rain (rain) / cloud+lightning (storm) /
  fog cloud (fog) / glitched icon (glitch storm)
- Hover for forecast: shows next likely weather change

## Save data

- current_weather_id: StringName
- weather_locked: bool (story events lock weather)
- iteration_glitch_chance: float (scales with iteration)
- last_weather_change_minute: int

## Achievements

- "Storm Chaser" — catch a Voidshark
- "Glitch Witness" — survive 5 glitch storms
- "Fair Weather" — play through 10 in-game days of clear weather
- "Foggy Memory" — discover the Foggy Mystery quest

## Files

- `_bmad-output/weather/weather_bible.md` — this file
- `scripts/systems/weather_database.gd` — 6 weather presets
- `scripts/autoloads/weather_controller.gd` — global weather controller
- `scripts/ui/weather_indicator.gd` — HUD weather widget
