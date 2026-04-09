---
name: Original Soundtrack Bible
description: 33 music tracks across town/wilderness/dungeon/combat/boss/UI categories with mood, instrumentation, length specs
date: 2026-04-09
status: design + manager complete; audio production pending
---

# Original Soundtrack Bible

## Philosophy

Music in Enth is **mood-driven and place-based**. Every zone has its own
identity. The town themes are warm and lo-fi. Dungeon themes are tense
synth. Boss themes escalate to digital distortion. The simulation theme
runs underneath everything as a quiet harmonic anchor — a single repeating
chord progression that mutates between zones.

Inspired by:
- Sea of Stars (place-based instrumentation)
- Hades (combat/boss layered intensity)
- Hollow Knight (ambient + sudden combat shift)
- Stardew Valley (cozy town themes)

## Audio production approach

For the prototype, music will be produced via:
- **AI music generation** (Suno, Udio, or similar) for first-pass tracks
- **Royalty-free libraries** (Pixabay, freemusicarchive) for placeholder
- **Original composition** post-prototype (contracted composer or solo)

Each track is referenced by ID in the MusicManager autoload. Swapping the
underlying audio file is a config change, no code change needed.

## Track list (33 tracks)

### Town themes (8)
| ID | Title | Length | Mood | Instrumentation |
|---|---|---|---|---|
| `town_main` | "Globbler's Town" | 2:30 | warm, cozy | lo-fi synth + harp + soft drums |
| `town_night` | "Town at Night" | 2:30 | peaceful, contemplative | piano + pads + soft bass |
| `district_residential` | "Home" | 1:30 | gentle | acoustic guitar + flute |
| `district_market` | "Market Day" | 1:30 | bouncy, social | percussion + brass + chimes |
| `district_commons` | "The Commons" | 1:30 | friendly chatter | piano + light strings |
| `district_workshop` | "The Workshop" | 1:30 | rhythmic, industrial | hammer percussion + bass synth |
| `district_docks` | "Down by the Docks" | 1:30 | breezy | accordion + strings + wave SFX |
| `tavern_music` | "Cache's Tavern" | 2:00 | warm, jazzy | upright bass + brushed drums + sax |

### Wilderness (3)
| ID | Title | Length | Mood | Instrumentation |
|---|---|---|---|---|
| `wilderness_day` | "Open Sky" | 2:30 | adventurous | acoustic + synth pad + light strings |
| `wilderness_night` | "Stars Above" | 2:30 | mysterious | ambient pad + soft chimes |
| `wilderness_storm` | "The Glitch Storm" | 2:00 | tense | distorted synth + thunder |

### Dungeon biomes (4)
| ID | Title | Length | Mood | Instrumentation |
|---|---|---|---|---|
| `biome_server_room` | "The Server" | 3:00 | cold, mechanical | dark synth + pulsing bass + click |
| `biome_memory_vaults` | "Memory Vault" | 3:00 | echoing, ancient | choral pads + bell + low strings |
| `biome_corrupted_wilds` | "Wilds of Corruption" | 3:00 | organic, threatening | tribal drums + distorted strings |
| `biome_final_vault` | "The Final Vault" | 3:30 | epic, somber | full orchestra + choir |

### Combat layers (3)
Combat themes use a layered system. Layer 1 plays at low intensity, layer 2
crossfades in at mid intensity, layer 3 at high. Each layer is the same
song with progressively more instruments.

| ID | Title | Length | Mood | Instrumentation |
|---|---|---|---|---|
| `combat_l1` | "Combat (light)" | 1:30 | tense | percussion + bass |
| `combat_l2` | "Combat (mid)" | 1:30 | escalating | + lead synth + strings |
| `combat_l3` | "Combat (intense)" | 1:30 | full | + brass + choir |

### Boss themes (7)
| ID | Title | Length | Mood | Instrumentation |
|---|---|---|---|---|
| `boss_intro_sting` | "Boss Approaches" | 0:08 | impact | brass hit + drum |
| `boss_compiler` | "The Corrupted Compiler" | 4:00 | tense climax | orchestral + glitch synth |
| `boss_memory_warden` | "The Warden Awakens" | 4:00 | imposing | choir + heavy drums |
| `boss_root_heart` | "Heart of Corruption" | 4:00 | organic horror | strings + tribal |
| `boss_sentinel_prime` | "Sentinel Override" | 4:00 | high-tech | synth + breakbeat |
| `boss_iteration_phantom` | "Phantom Self" | 4:00 | mirror eerie | warped player theme |
| `boss_compiler_reborn` | "End of Iteration" | 6:00 | final epic | full orchestra + choir |

### Stings & jingles (4)
| ID | Title | Length | Use |
|---|---|---|---|
| `victory_fanfare` | "Victory" | 0:05 | post-combat win |
| `defeat_sting` | "System Failure" | 0:08 | player death |
| `level_up_sting` | "Level Up" | 0:04 | level gained |
| `iteration_reset` | "Iteration Reset" | 0:30 | iteration transition cinematic |

### UI / Menu (4)
| ID | Title | Length | Mood |
|---|---|---|---|
| `main_menu` | "Boot" | 2:30 | mysterious + welcoming |
| `credits` | "End of Cycle" | 4:00 | reflective, hopeful |
| `dialogue_ambient` | "Conversation" | 1:30 | soft underbed for dialogue |
| `forge_workshop` | "The Forge" | 1:30 | rhythmic ambient under crafting |
| `archive_library` | "The Archive" | 1:30 | quiet, scholarly |

## Layered combat system

Combat tracks crossfade based on player threat level:
- **Out of combat:** zone music plays
- **Combat starts:** zone music fades 75% volume, `combat_l1` fades in
- **Mid combat (3+ enemies):** `combat_l2` adds
- **Intense (boss / 5+ enemies):** `combat_l3` adds
- **Combat ends:** all combat layers fade out, zone music returns to 100%

Crossfade duration: 1.5 seconds default, configurable.

## Boss music override

Boss fights completely override the zone music. Sequence:
1. Trigger boss intro cinematic
2. Fade out current music over 1.0s
3. Play `boss_intro_sting` (one-shot)
4. Fade in boss-specific theme
5. On boss defeat: fade out boss theme, play `victory_fanfare`, return to zone

## Audio configuration

All music files referenced via `assets/audio/music/<track_id>.ogg`. The
MusicManager autoload loads them lazily to keep RAM usage low.

Volumes are controlled by `AccessibilitySettings.music_volume` (0-100%) and
the master `AccessibilitySettings.master_volume`. Per-track volume offsets
allow balancing without re-editing audio files.

## Save data

- last_played_track_id: StringName (for resume on save load)
- combat_intensity_state: int (0-3)

## Files

- `_bmad-output/audio/music_bible.md` — this file
- `scripts/autoloads/music_manager.gd` — global music controller
- `scripts/systems/music_track_database.gd` — all 33 track metadata
