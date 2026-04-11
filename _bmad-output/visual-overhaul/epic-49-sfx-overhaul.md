---
epic: 49
title: "SFX Overhaul"
phase: 9 — Audio Overhaul
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 49: SFX Overhaul

## Overview

Source or create layered attack sounds (whoosh + impact), implement a footstep system (surface-dependent: grass, stone, metal), create UI sounds (click, hover, open, close), build ambient soundscapes (birds, wind, machinery hum), design enemy sounds (unique per type), create pickup jingles (rarity-scaled), and implement dialogue blip voices. Sound effects are the tactile feedback layer that makes every interaction feel real.

## Success Criteria

- Every player action has audio feedback (no silent interactions)
- Attack sounds layer whoosh + impact for satisfying hit feel
- Footsteps change by surface (grass, stone, metal, water)
- UI sounds provide confirmation for every interaction
- Ambient soundscapes immerse the player in each location
- Each enemy type has a distinct audio identity
- Pickup sounds scale with item rarity (legendary sounds special)
- All SFX use spatial audio where appropriate
- Total SFX file size under 30MB

---

## Tasks

### Task 49.1: SFX Asset Planning and Sourcing
- **Status:** TODO
- **Description:** Create a comprehensive SFX needs list and plan sourcing. Categorize all needed sounds: Combat (attack whoosh, hit impact, enemy hit, ability sounds, projectile, shield), Movement (footsteps x4 surfaces, dash, land), Environment (water splash, door open/close, machine hum, sparks, steam, fire), UI (button hover, click, open panel, close panel, scroll, error, notification), Pickup (common/uncommon/rare/legendary, currency, XP, health orb), Creature (per enemy type: idle, attack, hurt, death, spawn), Dialogue (character blips x4 characters). Total estimated: 80-100 distinct sound effects. Plan: create original (using DAW or Audacity), source from free libraries (Freesound.org), or purchase an asset pack. Document the source plan per sound.
- **Acceptance Criteria:**
  - [ ] Complete SFX needs list (80-100 sounds)
  - [ ] Categorized by type
  - [ ] Source plan per sound (create/source/purchase)
  - [ ] License verification for sourced sounds
  - [ ] Budget for any purchased assets
  - [ ] Priority order established

### Task 49.2: Combat SFX — Attack Layers
- **Status:** TODO
- **Description:** Create/source layered attack sounds. Each attack sound is composed of 2-3 layers mixed together: Layer 1 (whoosh): a fast air movement sound (short, 0.1-0.15s) with slightly different pitch for each attack type. Layer 2 (impact): a solid thud/crack on hit (0.1s) with variations per surface (metal, flesh, shield). Layer 3 (energy): a digital/sci-fi sweetener (short synth buzz, data crunch) for the game's tech theme. Mix 3-4 variations of each layer to prevent repetitive sound. The final attack sound should play whoosh on swing start and impact+energy on hit. Export all layers as WAV at 44.1kHz, 16-bit.
- **Acceptance Criteria:**
  - [ ] Whoosh layer (3-4 variations)
  - [ ] Impact layer (3-4 variations per surface)
  - [ ] Energy/sci-fi sweetener layer
  - [ ] Layers combine for satisfying attack sound
  - [ ] Data Pulse and Energy Burst have distinct sounds
  - [ ] All exported as WAV 44.1kHz

### Task 49.3: Footstep System — Surface Detection
- **Status:** TODO
- **Description:** Implement a surface-dependent footstep system. Create a FootstepManager.gd that detects what surface the player is walking on using raycasts downward from the player's feet, checking the material or physics layer of the surface below. Define surface types: grass (soft, rustling), stone/cobble (hard, clicking), metal (resonant, clanking), water (splashing), dirt (muffled thuds), wood (hollow, creaking). The manager should emit footstep sounds at the correct walking rhythm (synced to animation or at fixed intervals based on movement speed). Use AudioStreamPlayer3D for spatial footsteps. Randomize pitch slightly (±5%) per step.
- **Acceptance Criteria:**
  - [ ] Surface detection via raycast
  - [ ] 6 surface types with distinct sounds
  - [ ] Footsteps synced to walking rhythm
  - [ ] Spatial audio (3D positioning)
  - [ ] Pitch randomization per step
  - [ ] Dash has distinct (faster, lighter) footstep

### Task 49.4: Footstep Sound Assets
- **Status:** TODO
- **Description:** Create/source footstep sounds for each surface type. Each surface needs 4-6 variations to prevent repetitive sound. Grass: soft rustling with dirt undertone. Stone: sharp clicks with slight reverb. Metal: resonant clank with metallic ring. Water: splashy with underwater component. Dirt: muffled thuds. Wood: hollow knocks with slight creak. Each variation should be short (0.1-0.2s) and clean. Record or source at high quality then normalize volume across all footstep sounds. Export as WAV, organized in `res://assets/audio/sfx/footsteps/[surface]/`. Total footstep audio: 24-36 files.
- **Acceptance Criteria:**
  - [ ] 4-6 variations per surface (6 surfaces)
  - [ ] Each surface clearly distinct by ear
  - [ ] Consistent volume across all footsteps
  - [ ] Short, clean audio (0.1-0.2s)
  - [ ] 24-36 total footstep files
  - [ ] Organized in surface subdirectories

### Task 49.5: UI Sound Effects
- **Status:** TODO
- **Description:** Create/source UI sounds for all interface interactions. Design a cohesive UI sound palette that matches the sci-fi theme: Button Hover (soft, short tick or electronic chirp, 0.05s), Button Click (satisfying electronic click with subtle bass, 0.1s), Panel Open (whoosh/slide with digital chime, 0.2s), Panel Close (reverse whoosh, quieter, 0.15s), Error/Invalid (buzzer, low, brief, 0.15s), Notification (pleasant ascending two-tone, 0.2s), Scroll Tick (tiny click per scroll step, 0.03s), Confirm (positive resolution tone, 0.15s), Cancel (soft descending tone, 0.1s). All UI sounds should be subtle — present but not annoying with repetition. Export as WAV.
- **Acceptance Criteria:**
  - [ ] 9+ distinct UI sound types
  - [ ] Cohesive sci-fi sound palette
  - [ ] Subtle (not annoying on repetition)
  - [ ] Each interaction has distinct feedback
  - [ ] Error/invalid clearly different from success
  - [ ] All exported as WAV

### Task 49.6: Ambient Soundscapes — Town
- **Status:** TODO
- **Description:** Create the town ambient soundscape as a layered audio environment. Base layer: gentle wind with subtle warmth (continuous, 2-3 min loop). Overlay layers (triggered by proximity zones from Epic 29): bird song (near trees, intermittent chirps with variety), distant hammering (near forge), water trickle (near well), crowd murmur (near market, very low volume), insect buzz (near garden), and wind chime (near certain buildings). Each overlay is an AudioStreamPlayer3D positioned in the world, with volume falloff based on distance. The combined ambience should create the feeling of a living village without any single element dominating.
- **Acceptance Criteria:**
  - [ ] Base wind layer (continuous loop)
  - [ ] 6+ overlay layers positioned in world
  - [ ] Layers triggered by proximity zones
  - [ ] 3D spatial audio with distance falloff
  - [ ] No single element dominates
  - [ ] Combined effect: living village ambience

### Task 49.7: Ambient Soundscapes — Dungeon
- **Status:** TODO
- **Description:** Create the dungeon ambient soundscape. Base layer: low mechanical hum (server room ambience, continuous loop). Overlay layers per room type: air circulation (ventilation whoosh, corridors), distant machinery (clanks and whirs, all rooms at low volume), dripping water (Floor 3+), electrical buzz (near active panels/wires), and data processing (soft digital chirps and pulses, near terminals). Use AudioStreamPlayer3D for spatial positioning. The dungeon ambient should feel oppressive and industrial — like being inside a vast machine. Floor-specific overlays: Floor 3 adds more water/creaks, Floor 5 replaces machine sounds with organic rumbles.
- **Acceptance Criteria:**
  - [ ] Base mechanical hum layer
  - [ ] Room-type overlay layers
  - [ ] Spatial audio positioning
  - [ ] Floor-specific variations
  - [ ] Oppressive industrial atmosphere
  - [ ] Data processing sounds near terminals

### Task 49.8: Enemy Sound Design — Per Type
- **Status:** TODO
- **Description:** Create unique sound sets for each enemy type. GlitchBug: chittering digital clicks (idle), static burst (attack), error beep (hurt), crash sound + glass shatter (death), digital buzz (spawn). MemoryLeak: slow dripping/oozing sound (idle), splat (attack), squelch (hurt), dissolve bubble (death), gurgle (spawn). RogueProcess: mechanical whir (idle), precision strike sound (attack), metal clang (hurt), system shutdown tone (death), boot sequence (spawn). Corrupted Compiler Boss: deep reverberant voice-like tones (idle), massive impact (attack), structural crack (hurt), catastrophic failure sequence (death). Each enemy should be identifiable by sound alone.
- **Acceptance Criteria:**
  - [ ] Complete sound set per enemy (idle, attack, hurt, death, spawn)
  - [ ] Each enemy identifiable by sound alone
  - [ ] Boss has the most dramatic/complex sounds
  - [ ] Sounds match enemy visual personality
  - [ ] 3-4 variations per sound to prevent repetition
  - [ ] All spatial audio (3D positioned)

### Task 49.9: Pickup and Collect Sounds
- **Status:** TODO
- **Description:** Create pickup sounds that scale with item rarity for satisfying collection feedback. Common pickup: simple click with small chime (0.2s, understated). Uncommon: brighter chime with a subtle shimmer (0.25s). Rare: melodic two-note ascension with sparkle (0.3s, clearly nicer). Legendary: dramatic ascending chord with resonant glow and digital fanfare (0.5s, unmistakable). Currency pickup: coin clink with digital echo (0.15s). Health Prompt use: liquid/energy sound with positive resolution (0.2s). Compute Prompt use: electrical charging sound (0.2s). XP gain: soft ascending ping (0.1s, plays frequently so must be very unobtrusive).
- **Acceptance Criteria:**
  - [ ] 4 rarity-scaled pickup sounds
  - [ ] Legendary clearly special and exciting
  - [ ] Common is pleasant but understated
  - [ ] Currency, health, compute use sounds
  - [ ] XP gain sound is unobtrusive
  - [ ] Rarity progression is audibly clear

### Task 49.10: Dialogue Blip Voices
- **Status:** TODO
- **Description:** Create character-specific dialogue blip sounds that play during text reveal (from Epic 42). AI Sage: deep, resonant tone with slight reverb (like speaking in a cathedral), pitch range 100-150Hz. Cache Sprite: high-pitched, cheerful chirp (like Navi but digital), pitch range 400-600Hz. System/Narrator: cold, synthetic click (typewriter with digital filter), pitch range 200-300Hz. Player/Globbler: mid-range warm tone (neutral protagonist), pitch range 200-400Hz. Each character needs 1 base blip sound, played with ±5% pitch randomization per character reveal for natural variation. Blips trigger every 2-3 characters (not every character).
- **Acceptance Criteria:**
  - [ ] 4 character blip sounds (Sage, Sprite, System, Player)
  - [ ] Each character has distinct pitch range and character
  - [ ] Pitch randomization (±5%) per play
  - [ ] Trigger every 2-3 characters
  - [ ] Not annoying on extended dialogue
  - [ ] Identifiable who's speaking by sound alone

### Task 49.11: Door and Transition Sounds
- **Status:** TODO
- **Description:** Create sounds for all door and transition types. Standard door open: pneumatic hiss + mechanical slide (0.5s). Standard door close: reverse slide + solid clunk (0.5s). Locked door attempt: error buzz + metallic thud (0.3s). Boss door open: heavy grinding + warning alarm + steam burst (3s, dramatic). Portal enter: digital whoosh with ascending tone (0.5s). Portal exit: reverse with descending resolution (0.5s). Elevator descent: mechanical hum with periodic floor ding (2-3s). Death transition: digital corruption sound + flatline (1s). These sounds sync with the visual transitions from Epic 38.
- **Acceptance Criteria:**
  - [ ] Standard door open/close sounds
  - [ ] Locked door rejection sound
  - [ ] Boss door dramatic opening sequence
  - [ ] Portal enter/exit sounds
  - [ ] Elevator descent ambient
  - [ ] All synced with visual transitions

### Task 49.12: Environmental Interaction Sounds
- **Status:** TODO
- **Description:** Create sounds for environmental interactions. Water splash (player enters water): splash impact + ripple (0.3s). Chest open: creak + mechanical latch release + digital chime (0.5s). Crystal collect: resonant crystalline tone + energy absorption (0.3s). Destructible break: crash + debris scatter + settling (0.5s). Hazard activation: alarm + hazard-specific sound (laser hum, acid bubble, spark crackle, blade whir, fire whoosh). Lever/button press: click + mechanism activation (0.2s). NPC interaction start: greeting tone (0.1s). All interaction sounds should feel satisfying and confirm the player's action.
- **Acceptance Criteria:**
  - [ ] Water splash on entry
  - [ ] Chest open with mechanical + digital layers
  - [ ] Crystal collect sound
  - [ ] Destructible break with debris
  - [ ] Hazard activation sounds per type
  - [ ] All interactions confirmed by sound

### Task 49.13: Spatial Audio Configuration
- **Status:** TODO
- **Description:** Configure Godot's spatial audio system for all 3D sounds. Set the AudioStreamPlayer3D properties consistently: unit_size based on sound importance (important sounds: 2m, ambient sounds: 1m), max_distance per category (combat: 20m, footsteps: 10m, ambient: 15m, UI: non-spatial), attenuation_model to Inverse Distance for realistic falloff, and doppler_tracking for fast-moving projectiles. Set the AudioListener3D on the isometric camera. Configure panning for the isometric perspective (sounds should pan left-right based on screen position, not world position). Test that sounds are clearly directional for gameplay-relevant audio (enemy approaching from the left should sound from the left).
- **Acceptance Criteria:**
  - [ ] Spatial audio configured for 3D sounds
  - [ ] Distance-based attenuation per category
  - [ ] Panning works for isometric camera
  - [ ] Gameplay-relevant sounds clearly directional
  - [ ] Ambient sounds have appropriate range
  - [ ] Doppler on projectiles (if applicable)

### Task 49.14: Sound Variation and Randomization
- **Status:** TODO
- **Description:** Implement sound variation to prevent repetitive audio. Create a SoundVariant.gd component that: holds 3-6 audio clips per sound type, randomly selects one per play, applies random pitch variation (±5-10%), applies random volume variation (±5%), and ensures the same clip doesn't play twice in a row (no-repeat rule). Apply to all frequently occurring sounds: footsteps, attack hits, UI clicks, enemy idle sounds, and pickup sounds. For less frequent sounds (door open, boss attacks), 2-3 variations are sufficient. The variation should be subtle enough to feel natural, not jarring.
- **Acceptance Criteria:**
  - [ ] SoundVariant.gd manages clip selection
  - [ ] 3-6 variations for frequent sounds
  - [ ] Random pitch and volume variation
  - [ ] No-repeat consecutive play rule
  - [ ] Variation feels natural
  - [ ] Applied to all frequently heard sounds

### Task 49.15: Sound Priority and Polyphony
- **Status:** TODO
- **Description:** Configure sound priority and polyphony limits to prevent audio overload during intense gameplay. Define priority levels: Critical (player damage, boss attacks, death — always play), High (player attacks, enemy damage, pickups), Medium (footsteps, ambient, UI), Low (distant effects, minor particles). Set max_polyphony per AudioStreamPlayer3D: Critical unlimited, High limit 8, Medium limit 4, Low limit 2. When the polyphony limit is reached: lower priority sounds are culled, not just queued. Use Godot's max_polyphony and bus effect to manage. Test during maximum combat (8 enemies, all attacking, player using AoE) and verify no audio glitching.
- **Acceptance Criteria:**
  - [ ] Priority levels defined (Critical/High/Medium/Low)
  - [ ] Polyphony limits per priority
  - [ ] Lower priority sounds culled when limit reached
  - [ ] No audio glitching during max combat
  - [ ] Critical sounds always play
  - [ ] System tested with 8+ simultaneous enemies

### Task 49.16: Connect SFX to EventBus Signals
- **Status:** TODO
- **Description:** Create a SFXManager.gd (or extend AudioManager) that connects to all EventBus signals and plays appropriate sounds. Map: `player_attacked(type)` -> attack whoosh, `enemy_hit(position, type)` -> impact at position, `player_damaged(amount)` -> player hurt sound, `door_opened/closed` -> door sounds, `item_picked_up(rarity)` -> rarity pickup sound, `menu_hover/select` -> UI sounds, `dialogue_char_revealed(char)` -> dialogue blip, `water_entered` -> splash, `combat_started` -> alert sting, `boss_phase_changed` -> dramatic impact. Verify every EventBus signal that should have audio is connected.
- **Acceptance Criteria:**
  - [ ] SFXManager connects to all relevant signals
  - [ ] Correct sounds play for each signal
  - [ ] 3D positioning for world sounds
  - [ ] UI sounds not spatialized
  - [ ] All connections tested
  - [ ] No silent interactions remain

### Task 49.17: Audio File Import and Optimization
- **Status:** TODO
- **Description:** Import all SFX files into Godot with correct settings. For short SFX (under 1 second): import as WAV (immediate playback, no decoding lag). For longer ambient sounds (over 3 seconds): import as OGG Vorbis (smaller file size). Set all audio files to the correct bus routing via import settings or at runtime. Verify: total SFX file size under 30MB, no clipping on any sound (normalize peaks to -3dB), no silence at the start of any sound (trim pre-roll), and sample rate is consistent (44.1kHz or 22.05kHz for lower-quality ambient). Organize in `res://assets/audio/sfx/` with category subdirectories.
- **Acceptance Criteria:**
  - [ ] Short SFX as WAV, long ambient as OGG
  - [ ] Total file size under 30MB
  - [ ] No clipping (peaks at -3dB)
  - [ ] No silence pre-roll (trimmed)
  - [ ] Consistent sample rates
  - [ ] Organized in category subdirectories

### Task 49.18: Audio Mix Balancing
- **Status:** TODO
- **Description:** Conduct a full audio mix balancing pass. Set reference levels: dialogue at 0dB (loudest, always clearly audible), combat SFX at -3dB, music at -6dB (background, not competing with SFX), ambient at -12dB (barely noticeable consciously), UI sounds at -6dB (clear but not startling). Play through all game contexts and adjust individual sound volumes to sit correctly in the mix. Problem scenarios to test: combat with music and 8 enemies (combat SFX must remain clear), dialogue over music (dialogue must be easily readable), and quiet ambient moments (ambient should be present but not uncomfortably loud in contrast to previous combat).
- **Acceptance Criteria:**
  - [ ] Reference levels set per category
  - [ ] Dialogue always clearly audible
  - [ ] Combat SFX not drowned by music
  - [ ] Ambient present but subtle
  - [ ] No volume spikes or drops between contexts
  - [ ] Full game loop mix-tested

### Task 49.19: Audio Accessibility
- **Status:** TODO
- **Description:** Implement audio accessibility features. Settings: master volume with fine control (0-100% in 5% steps), per-bus volume controls, mono audio option (combines stereo to mono for single-ear listeners), sound effect volume separate from music (already done via buses), visual sound indicators (optional flashing HUD icon when important sounds play off-screen, e.g., enemy approaching from behind), and closed captions for key audio (dialogue text already covered, but add descriptions for significant sounds like "[alarm blaring]" or "[glass breaking]"). Test with audio fully muted — the game should still be playable via visual feedback alone.
- **Acceptance Criteria:**
  - [ ] Fine-grained volume controls
  - [ ] Mono audio option
  - [ ] Visual sound indicators (optional)
  - [ ] Closed caption support for key sounds
  - [ ] Game playable with audio muted
  - [ ] Accessibility settings in settings screen

### Task 49.20: Before/After Documentation
- **Status:** TODO
- **Description:** Record audio demonstrations: combat encounter (attack sounds, hits, enemy sounds), footstep surface transitions (walk across grass to stone to metal), town ambient soundscape, dungeon ambient soundscape, all pickup sounds (rarity comparison), dialogue blips per character, door/transition sounds, and the full audio mix during a dungeon boss fight. Compare before (placeholder/no audio) with after. Save recordings to `_bmad-output/visual-overhaul/screenshots/epic-49/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Combat audio demonstrated
  - [ ] Footstep surfaces compared
  - [ ] Town and dungeon ambience recorded
  - [ ] Pickup rarity comparison
  - [ ] All recordings saved
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 48** (Music Production) — Audio bus system and mixing
- **Epic 28-29** (Water/Atmosphere) — Audio zone triggers
- **Epic 38** (Transitions) — Audio hook signals

## Notes

- Sound is 50% of game feel — a silent game feels broken no matter how good it looks
- Layered attack sounds (whoosh + impact + sweetener) is the standard for satisfying combat audio
- Surface-dependent footsteps are one of the most immersive audio features possible
- Dialogue blips are surprisingly characterful — they give NPCs a "voice" without voice acting
- Always test at both high and low volume — sounds that are fine at 50% might clip at 100%
