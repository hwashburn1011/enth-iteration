---
epic: 48
title: "Music Production"
phase: 9 — Audio Overhaul
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 48: Music Production

## Overview

Source or compose game music: town theme (warm, pastoral, 2-3 minute loop), dungeon ambient (tense, low, atmospheric), combat theme (driving rhythm, layered intensity), boss theme (dramatic, escalating), menu theme (mysterious, inviting), victory jingle, death sting, and level-up fanfare. Music is the emotional backbone of the game and must reinforce each gameplay context.

## Success Criteria

- Each theme matches its context emotionally (town = warm, dungeon = tense, combat = intense)
- All looping tracks loop seamlessly (no audible gap or pop)
- Combat music layers dynamically with combat intensity
- Boss music escalates through phases
- Jingles and stings are punchy and memorable (under 5 seconds)
- Audio format and quality suitable for Godot (OGG Vorbis for music, WAV for short stings)
- Total music file size under 50MB
- Music integrates with the game's audio bus system

---

## Tasks

### Task 48.1: Music Direction and Reference
- **Status:** TODO
- **Description:** Define the musical direction for the entire game. Collect 3-5 reference tracks per context (town, dungeon, combat, boss, menu) from games with similar aesthetic targets: Stardew Valley (town warmth), Hyper Light Drifter (dungeon atmosphere), Hades (combat energy), Celeste (emotional stings). Define the instrument palette: for the sci-fi digital theme, blend organic instruments (piano, strings, acoustic guitar for town) with electronic elements (synth pads, arpeggiated synths, digital glitches for dungeon/combat). Define BPM ranges: town 80-100, dungeon ambient 60-80, combat 120-140, boss 130-150. Document all decisions in a music brief.
- **Acceptance Criteria:**
  - [ ] 3-5 reference tracks per game context
  - [ ] Instrument palette defined (organic + electronic blend)
  - [ ] BPM ranges per context
  - [ ] Musical direction document created
  - [ ] Emotional target per track clearly stated
  - [ ] Brief reviewed before production

### Task 48.2: Source or Compose Town Theme
- **Status:** TODO
- **Description:** Create/source the town theme: a warm, pastoral melody that communicates home, safety, and community. Duration: 2-3 minutes with seamless loop. Instrumentation: acoustic guitar or piano lead melody, gentle pad accompaniment, subtle percussion (soft hi-hat or shaker), and a hint of digital synth (reminder that this is a simulation). The melody should be memorable enough to hum — this is the game's "home" theme that players will hear most often. Structure: intro (8 bars), A section (melody, 16 bars), B section (variation, 16 bars), bridge (subtle key change or instrument swap, 8 bars), return to A (8 bars), loop point. Render at 44.1kHz, export as OGG Vorbis at quality 6-8.
- **Acceptance Criteria:**
  - [ ] 2-3 minute warm, pastoral theme
  - [ ] Seamless loop (no audible gap)
  - [ ] Memorable melody
  - [ ] Organic instruments with subtle digital hints
  - [ ] Exported as OGG Vorbis
  - [ ] Emotionally communicates safety and home

### Task 48.3: Source or Compose Dungeon Ambient
- **Status:** TODO
- **Description:** Create/source the dungeon ambient track: tense, low, atmospheric soundscape for exploration between combat. Duration: 3-4 minutes with seamless loop (longer to prevent noticeable repetition). This is NOT a melody — it's a mood. Instrumentation: deep sub-bass drone, reverberant metallic pings (like sonar in an empty server room), distant digital glitches, subtle rhythmic element (slow heartbeat-like pulse), and whispered data sounds (soft synth arpeggios at very low volume). The track should create unease without being oppressive — the player should feel alert but not stressed during exploration. Multiple layers for intensity scaling (see Task 48.8).
- **Acceptance Criteria:**
  - [ ] 3-4 minute atmospheric loop
  - [ ] Tense mood without melody
  - [ ] Sub-bass drone with metallic elements
  - [ ] Digital glitch textures
  - [ ] Seamless loop
  - [ ] Creates alertness, not oppression

### Task 48.4: Source or Compose Combat Theme
- **Status:** TODO
- **Description:** Create/source the combat theme: driving, energetic music that makes fights feel exciting. Duration: 2-3 minutes with seamless loop. Instrumentation: driving electronic beat (four-on-the-floor or breakbeat at 130 BPM), aggressive synth bassline, rhythmic arpeggiated synth melody, impact sound design elements (hits, crashes timed to the beat), and distorted digital textures. The theme should layer: base layer (drums + bass, always playing during combat), intensity layer (synth melody + fills, added when combat intensifies), and climax layer (full arrangement, added during tough encounters). Export each layer as a separate stem for dynamic mixing.
- **Acceptance Criteria:**
  - [ ] Driving 130 BPM electronic combat music
  - [ ] 3 layers exportable as separate stems
  - [ ] Base: drums + bass
  - [ ] Intensity: melody + fills
  - [ ] Climax: full arrangement
  - [ ] Feels exciting and empowering

### Task 48.5: Source or Compose Boss Theme
- **Status:** TODO
- **Description:** Create/source the boss theme: dramatic, escalating music for the game's climactic encounters. Duration: 3-4 minutes covering all 3 boss phases. Phase 1 (0:00-1:20): controlled tension, marching beat, ominous melody building slowly. Phase 2 (1:20-2:40): intensity rises, tempo increases slightly, new instrument layers add (choir/synth pad swell, more aggressive percussion), melody becomes more urgent. Phase 3 (2:40-end): full climax, maximum intensity, fastest tempo, all instruments at peak, the music screams "this is the final push." Export as 3 separate loop-able phase tracks (each phases' section should also loop independently for variable fight lengths).
- **Acceptance Criteria:**
  - [ ] 3 phase sections with escalating intensity
  - [ ] Phase 1: controlled tension
  - [ ] Phase 2: rising urgency
  - [ ] Phase 3: full climax
  - [ ] Each phase loops independently
  - [ ] Most dramatic music in the game

### Task 48.6: Source or Compose Menu Theme
- **Status:** TODO
- **Description:** Create/source the menu theme: mysterious and inviting music that draws the player into the game world. Duration: 1-2 minutes with seamless loop (shorter since players spend less time on menus). Instrumentation: ambient synth pad (warm but with digital edge), gentle piano or bell melody (simple, not busy), subtle digital textures (quiet data sounds, soft glitches), and optional soft strings. The menu theme should establish the game's identity: digital mystery with warmth. It should make the player want to press "Start" and explore. The theme should also work as background for the settings and credit screens.
- **Acceptance Criteria:**
  - [ ] 1-2 minute mysterious, inviting loop
  - [ ] Establishes game identity
  - [ ] Digital mystery with warmth
  - [ ] Not distracting for menu navigation
  - [ ] Seamless loop
  - [ ] Works for all menu screens

### Task 48.7: Compose Short Stings and Jingles
- **Status:** TODO
- **Description:** Create short musical pieces for key game moments. Victory jingle (3-5 seconds): triumphant fanfare, upward melody resolution, bright and celebratory — plays after boss defeat. Death sting (2-3 seconds): descending minor melody, digital corruption sound, abrupt end — plays on player death. Level-up fanfare (2-4 seconds): ascending bright melody with sparkle sounds, triumphant resolution — plays during level-up effect. Quest complete chime (1-2 seconds): pleasant ascending three-note arpeggio — plays with quest banner. Loot reveal sting (1-2 seconds): mysterious ascending tones with sparkle — plays during loot spotlight. Each sting must be exported as WAV (low latency, no decoding delay).
- **Acceptance Criteria:**
  - [ ] Victory jingle: 3-5s, triumphant
  - [ ] Death sting: 2-3s, descending, abrupt
  - [ ] Level-up fanfare: 2-4s, ascending, bright
  - [ ] Quest complete chime: 1-2s, pleasant
  - [ ] Loot reveal sting: 1-2s, mysterious sparkle
  - [ ] All exported as WAV

### Task 48.8: Dynamic Music System Design
- **Status:** TODO
- **Description:** Design the dynamic music system that transitions between tracks and layers based on game state. Define the state machine: Town (town theme), DungeonExplore (dungeon ambient, base layer), DungeonCombat (combat theme, layers scale with enemy count/intensity), BossFight (boss theme, phases sync with boss HP), Menu (menu theme), Silence (between tracks during transitions). Define transition rules: town -> dungeon = cross-fade over 3 seconds, explore -> combat = quick cross-fade (1s) with combat drums starting immediately, combat -> explore = slow fade-out of combat (2s) with ambient fade-in. Create a MusicManager.gd design document with the complete state machine.
- **Acceptance Criteria:**
  - [ ] State machine with all music states
  - [ ] Transition rules per state change
  - [ ] Layer scaling rules for combat intensity
  - [ ] Phase sync rules for boss fight
  - [ ] Cross-fade durations per transition
  - [ ] MusicManager design document complete

### Task 48.9: Implement MusicManager Autoload
- **Status:** TODO
- **Description:** Implement MusicManager.gd as the central music controller (or integrate into AudioManager autoload). The manager holds AudioStreamPlayer nodes for each music layer. Implement: `set_state(state: String)` to transition between music states, `set_combat_intensity(intensity: float)` to scale combat layers (0.0 = base only, 0.5 = +intensity layer, 1.0 = +climax layer), `set_boss_phase(phase: int)` to switch boss music phases, and `play_sting(sting_name: String)` for jingles (which duck the main music briefly). Use Godot's AudioServer bus system: route all music through a "Music" bus for volume control. Implement smooth cross-fading using tweens.
- **Acceptance Criteria:**
  - [ ] MusicManager with state machine
  - [ ] set_state() transitions with cross-fade
  - [ ] set_combat_intensity() scales layers
  - [ ] set_boss_phase() switches boss phases
  - [ ] play_sting() ducks main music
  - [ ] All music through "Music" audio bus

### Task 48.10: Combat Music Layering Implementation
- **Status:** TODO
- **Description:** Implement the dynamic combat music layering. Load all 3 combat stems (base, intensity, climax) as separate AudioStreamPlayer nodes, all starting simultaneously but with intensity and climax at 0 volume. When combat starts: cross-fade from ambient to combat base (1s). As enemies are engaged: fade intensity layer in proportionally (1-3 enemies: 30%, 4-6: 60%, 7+: 100%). During critical moments (player low health, many enemies, boss presence): fade climax layer in. All stems must stay synchronized — use Godot's AudioServer sync capabilities. When combat ends: layers fade out in reverse order (climax -> intensity -> base), then cross-fade to ambient.
- **Acceptance Criteria:**
  - [ ] 3 stems loaded and synchronized
  - [ ] Layers fade in/out with combat intensity
  - [ ] Stems stay perfectly synchronized
  - [ ] Smooth transitions on combat start/end
  - [ ] Intensity scales with enemy count/danger
  - [ ] No audible pops or clicks during transitions

### Task 48.11: Boss Music Phase Transitions
- **Status:** TODO
- **Description:** Implement boss music phase transitions. Load all 3 boss phase tracks. Phase 1 starts on boss intro. When boss reaches 66% HP (Phase 2): wait for the current music bar to end (quantized transition), then cross-fade to Phase 2 track over 2 beats. Same for Phase 3 at 33% HP. The quantized transition prevents the music from cutting mid-phrase, which sounds jarring. Implement a simple beat tracker: based on the BPM and track start time, calculate when the next bar boundary occurs and schedule the transition. On boss defeat: fade music out over 1 second, then play victory jingle.
- **Acceptance Criteria:**
  - [ ] Phase transitions quantized to bar boundaries
  - [ ] Cross-fade between phases over 2 beats
  - [ ] Phase 2 at 66% HP, Phase 3 at 33%
  - [ ] Beat tracker calculates bar boundaries
  - [ ] Victory jingle on defeat, music fades
  - [ ] Transitions feel musical (not abrupt)

### Task 48.12: Town Music Variations
- **Status:** TODO
- **Description:** Create subtle variations of the town theme for different times of day and game states (if time-of-day is implemented). Morning variant: slightly brighter, add bird sounds, more acoustic. Noon variant: base theme at standard warmth. Evening variant: slower tempo (or pitch-shifted slightly lower), add soft bells or chimes, more reverb for a dreamy quality. If full variants are too expensive: use the same base track but apply real-time audio effects (pitch shift, reverb, EQ) to modify the feel. Also create a "town upgraded" variant (additional instrument layers that add as the player builds the town) for progression reward.
- **Acceptance Criteria:**
  - [ ] Morning/noon/evening variants (or real-time modifications)
  - [ ] Evening feels dreamier and slower
  - [ ] Morning feels brighter
  - [ ] Town upgrade layers add with progression
  - [ ] Smooth transitions between variants
  - [ ] Variants don't require excessive file size

### Task 48.13: Floor-Specific Dungeon Ambient Variations
- **Status:** TODO
- **Description:** Create dungeon ambient variations per floor to reinforce floor themes. Floor 1 (clean): lighter ambient with more digital tones, less tension. Floor 2 (data): add server hum undertone, more rhythmic digital elements. Floor 3 (abandoned): add dripping water samples, metallic creaks, more reverb. Floor 4 (corrupted): add distorted, glitchy audio fragments, dissonant tones, unstable rhythms. Floor 5 (boss core): deep, oppressive drone, heartbeat-like pulse, minimal melody. These can be separate tracks or layer modifications to the base ambient. Integrate with FloorThemeManager to switch on floor change.
- **Acceptance Criteria:**
  - [ ] Each floor has distinct ambient variation
  - [ ] Floor 1: lighter, Floor 5: oppressive
  - [ ] Variations reinforce floor visual themes
  - [ ] Smooth transitions on floor change
  - [ ] Integrated with floor theme system
  - [ ] Progressive tension from Floor 1 to 5

### Task 48.14: Audio Bus Configuration
- **Status:** TODO
- **Description:** Configure Godot's audio bus layout for proper music mixing. Create buses: Master (final output), Music (all music tracks, under Master), SFX (all sound effects, under Master), Ambient (ambient sounds, under Master), UI (UI sounds, under Master), Dialogue (dialogue voices, under Master). Add a Compressor effect on Master to prevent clipping. Add a LowPass filter on Music bus that activates during combat (slightly muffles music so SFX are clearer). Each bus should have its own volume control exposed in the Settings screen. Save the bus layout as `res://default_bus_layout.tres`.
- **Acceptance Criteria:**
  - [ ] 6 audio buses configured
  - [ ] Compressor on Master prevents clipping
  - [ ] LowPass on Music activatable during combat
  - [ ] Each bus has volume control in settings
  - [ ] Bus layout saved as default_bus_layout.tres
  - [ ] Buses route correctly (no orphan audio)

### Task 48.15: Music File Import and Optimization
- **Status:** TODO
- **Description:** Import all music files into Godot with correct settings. For looping tracks (OGG): set loop_mode to Loop in the import settings, set loop_begin and loop_end to the exact sample positions for seamless looping (test each loop point for audible clicks). For stings (WAV): no loop, set to Play Once. Verify: total music file size under 50MB, OGG quality setting provides good quality without excessive file size (test quality 5-8), all tracks play correctly with no decoding artifacts, and stereo mix sounds correct on both speakers and headphones. Organize files in `res://assets/audio/music/`.
- **Acceptance Criteria:**
  - [ ] All music files imported with correct settings
  - [ ] Loop points set precisely (no clicks)
  - [ ] Total file size under 50MB
  - [ ] OGG quality balanced (size vs. quality)
  - [ ] No decoding artifacts
  - [ ] Files organized in correct directory

### Task 48.16: Music Volume Ducking for Dialogue
- **Status:** TODO
- **Description:** Implement automatic music volume ducking when dialogue plays. When dialogue starts: the Music bus volume fades to 30% (over 0.5s) so the player can hear dialogue clearly. When dialogue ends: music returns to 100% (over 1.0s, slower to avoid abrupt return). The ducking should be smooth and not noticeable as a separate action — it should feel natural, like the music "stepping back" for the conversation. Also duck music briefly during stings (level-up fanfare, victory jingle): reduce to 50% for the sting duration, then restore. Implement in MusicManager.gd.
- **Acceptance Criteria:**
  - [ ] Music ducks to 30% during dialogue
  - [ ] Smooth fade down (0.5s) and up (1.0s)
  - [ ] Ducking during stings (50%)
  - [ ] Feels natural, not noticeable
  - [ ] Implemented in MusicManager
  - [ ] Works with all dialogue and sting types

### Task 48.17: Connect Music to Game Events
- **Status:** TODO
- **Description:** Connect MusicManager to all game EventBus signals. Map: `scene_changed(scene: String)` -> set appropriate music state (town, dungeon, menu), `combat_started` -> set_state("combat"), `combat_ended` -> set_state("dungeon_explore"), `boss_fight_started` -> set_state("boss"), `boss_phase_changed(phase)` -> set_boss_phase(), `player_died` -> play death sting + fade music, `level_up` -> play level-up fanfare, `quest_completed` -> play quest chime, `loot_opened` -> play loot sting, `iteration_complete` -> special transition music. Test each connection to verify correct music plays at the right moment.
- **Acceptance Criteria:**
  - [ ] All EventBus signals connected
  - [ ] Correct music for each game state
  - [ ] Combat start/end transitions work
  - [ ] Boss phase changes sync correctly
  - [ ] Stings play at correct moments
  - [ ] All connections tested and verified

### Task 48.18: Music Volume Persistence
- **Status:** TODO
- **Description:** Ensure music volume settings persist across sessions and are applied correctly. Save volume settings (master, music, SFX, ambient, UI, dialogue) in the game's settings save file. On game load: apply saved volumes to all audio buses before any audio plays. Ensure the Music bus volume is applied BEFORE the menu theme starts (no brief blast at full volume before settings load). Handle the case where settings don't exist yet (first launch): use defaults (Master 80%, Music 70%, SFX 80%, Ambient 60%, UI 70%, Dialogue 90%).
- **Acceptance Criteria:**
  - [ ] Volume settings saved and loaded
  - [ ] Volumes applied before first audio plays
  - [ ] No volume blast on game start
  - [ ] Default values for first launch
  - [ ] All 6 bus volumes persistent
  - [ ] Settings survive between sessions

### Task 48.19: Music Listening Test
- **Status:** TODO
- **Description:** Conduct a comprehensive listening test of all music in context. Play through the full game loop: menu -> town -> dungeon Floor 1-5 -> combat encounters -> boss fight -> victory -> return to town. At each stage verify: the correct music plays, transitions are smooth, dynamic layers respond to gameplay, stings don't clash with background music, music volume relative to SFX is balanced (music should not overpower combat sounds), and the emotional impact matches the gameplay moment. Fix any timing, volume, or transition issues found.
- **Acceptance Criteria:**
  - [ ] Full game loop listening test completed
  - [ ] All transitions smooth
  - [ ] Dynamic layers respond correctly
  - [ ] Stings don't clash with background
  - [ ] Music/SFX balance correct
  - [ ] Emotional impact matches gameplay

### Task 48.20: Before/After Documentation
- **Status:** TODO
- **Description:** Record audio samples of each music track and game moment. Capture: town theme (30s sample), dungeon ambient (30s), combat with layer transitions (60s showing intensity scaling), boss fight with phase transitions (90s), all stings individually, and a full dungeon run showcasing all music transitions. Export as high-quality audio files or screen recordings with audio. Save to `_bmad-output/visual-overhaul/screenshots/epic-48/` (audio subfolder). Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All tracks sampled
  - [ ] Dynamic layer transitions demonstrated
  - [ ] Boss phase transitions captured
  - [ ] All stings recorded
  - [ ] Full dungeon run audio recorded
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 33** (Dungeon Lighting) — Combat state signals for music transitions
- **Epic 37** (Boss Arena) — Boss phase signals for music sync

## Notes

- Music is 50% of the emotional experience — don't underestimate its impact
- Seamless loops are non-negotiable — a audible loop point breaks immersion every time
- Dynamic layering is what separates "good game music" from "great game music"
- Boss music phase sync is the most technically challenging — test quantized transitions extensively
- Budget for audio asset licensing if not composing original — quality stock music is better than bad original music
