---
name: Cinematics & Cutscenes Bible
description: 11 main cinematics + utility cutscenes, in-engine camera system, timeline + storyboards
date: 2026-04-09
status: design + system complete; per-cinematic scenes pending
---

# Cinematics Bible

## Philosophy

All cinematics are **in-engine** for budget reasons (no rendered video).
The cinematic system uses Godot's existing scene tree with a special
"cutscene" Camera3D that takes over from the player camera, plus a
timeline tool that orchestrates camera moves, model animations, dialogue,
music, and SFX.

The result reads more like Hades' god scenes (in-engine, scripted) than
Persona 5's anime cuts (prerendered). It's cheaper, more flexible, and
matches the project's solo-dev scope.

## In-engine vs prerendered decision

**In-engine wins** because:
- 0 video file size in build
- Re-uses existing models/animations
- Player can skip cleanly
- Easy to localize (no re-rendering)
- Easy to iterate on

The only prerendered asset is the Steam trailer (out of scope here).

## Cinematic architecture

```
CutsceneController (autoload)
├── current_cinematic_id: StringName
├── playback_state: {ready, playing, paused, complete}
├── timeline: Array of TimelineEvent
├── cutscene_camera: Camera3D (takes over render)
├── letterbox_top: ColorRect
├── letterbox_bottom: ColorRect
└── subtitle_overlay: Label
```

A `TimelineEvent` is one of:
- `wait` — pause N seconds
- `camera_move` — tween camera to position over duration
- `camera_shake` — shake intensity + duration
- `play_animation` — fire AnimationTree state on entity
- `play_dialogue` — show subtitle + play voice grunt
- `play_music` — switch music track
- `play_sfx` — fire one-shot SFX
- `set_letterbox` — show/hide cinematic bars
- `fade` — fade in/out from black/white
- `signal` — emit named EventBus signal

Cinematics are defined as **scripts** (one .gd file per cinematic) that
push events into the controller's timeline. Easier to author than .tres
resources because the logic can be conditional (different for different
class/faction choices).

## Cinematic list (11 main + utility)

### Opening cinematic — "Awakening" (90 seconds)
**Trigger:** New game start
**Storyboard:**
1. Black screen, "Booting..." text + boot sound
2. White flash, scrolling code text
3. Camera rises through digital fog, revealing town silhouette
4. Globbler appears in foreground, slowly powers on (eye visor lights up)
5. Camera pulls back to wide shot
6. Sage approaches from background, dialogue begins
7. Letterbox in, dialogue scene
8. Letterbox out, control returned to player

### Iteration transitions (8 cinematics, ~30s each)
**Triggers:** Boss death + iteration advance flag
**Storyboard pattern:**
1. Player frozen in place
2. Camera zooms to Globbler
3. White flash + glitch shader sweep
4. World fades, "ITERATION X COMPLETE" text
5. Brief story reveal (varies per iteration)
6. Reset to town with iteration counter visible
7. Sage waiting with new dialogue

#### Iteration 1 → 2 — "First Echo"
- Sage reveals: "You've done this before."

#### Iteration 2 → 3 — "Choice"
- Reflection NPC appears, respec unlocked

#### Iteration 3 → 4 — "Glitch"
- First glitch creature visible in background

#### Iteration 4 → 5 — "Memory"
- Iteration Memorial unveiled

#### Iteration 5 → 6 — "The User's Mark"
- User's seal revealed

#### Iteration 6 → 7 — "The Faction Choice"
- Faction representative confronts player

#### Iteration 7 → 8 — "The Truth"
- Sage reveals their connection to Globbler

#### Iteration 8 → 9 — "The Final Loop"
- Begins the endgame countdown

### Final ending — "End of Cycle" (4 minutes)
**Trigger:** Defeating Compiler Reborn
**Storyboard:**
1. Black screen, narrator: "And so the loop completes..."
2. Camera pans across all 12 NPCs in town, each waving farewell
3. Sage final dialogue
4. Globbler walks toward sunrise
5. White flash
6. Credits scroll
7. Post-credits scene (mystery hook for sequel)

## Utility cinematics

### "First Compaction" (15 seconds)
First time the player reaches a compaction portal. Brief celebration
moment + Sage dialogue cue.

### "First Boss Kill" (8 seconds)
First boss dies. Hitstop + slow zoom + "BOSS DEFEATED" banner + victory
fanfare.

### "Town Arrival" (10 seconds)
First time the player enters town. Camera pan reveals key NPCs.

### NPC Recruit cinematics (6, ~10 seconds each)
Each named recruitable NPC's introduction scene.

### Affinity max cinematics (12, ~20 seconds each)
One per NPC at Soul-Linked tier. Reveals their truth.

### Death cinematic (5 seconds)
Globbler death dramatization with "SYSTEM FAILURE" overlay.

### Secret discovery cinematics (15, ~5 seconds each)
Brief 5-second reveals when player discovers a secret.

## Skip + save behavior

- All cinematics can be skipped with **ESC** key (skip confirmation popup)
- Cinematic playback saves to a "seen" list — already-seen cinematics
  default to skip
- Story flags advance on cinematic complete, not on cinematic start
  (so skipping doesn't break progress)
- Save/load: skipping preserves the same end state as playing

## Cinematic camera system

The CutsceneCamera is a Camera3D that's enabled when a cinematic plays
and disabled when control returns to the player. Features:
- Smooth lerp between positions (3D interpolation)
- Look-at target (locks rotation toward a Node3D)
- Dolly tracks (Bezier path interpolation)
- Shake (random offset + decay)
- Depth of field control (focus distance + aperture)

## Letterbox bars

Two ColorRect overlays at top and bottom of screen, animated in/out via
Tween. Default height: 12% of viewport on each side. Skip animation
controlled by `set_letterbox(true/false, duration)`.

## Subtitle overlay

Bottom-of-screen Label with typewriter effect (separate from in-game
DialoguePanel — cinematic subtitles are styled differently). Pauses for
voice grunt duration before advancing.

## Aspect ratio support

Cinematic frames defined relative to a virtual 16:9 viewport. The
controller crops or letterboxes for other aspect ratios:
- 16:9: native
- 16:10: subtle horizontal letterbox
- 21:9: cropping safe zone
- 4:3: top/bottom letterbox

## Save data

- seen_cinematics: Array[StringName]
- last_played_cinematic: StringName

## Achievements

- "First Awakening" — see opening cinematic
- "Cycle Complete" — see all 8 iteration transitions
- "End of Cycle" — see final ending
- "Heart of the Town" — see all 12 affinity max cinematics
- "Secret Keeper" — see all 15 discovery cinematics

## Files

- `_bmad-output/cinematics/cinematic_bible.md` — this file
- `scripts/autoloads/cutscene_controller.gd` — global cinematic playback
- `scripts/systems/cinematic_database.gd` — cinematic registry + metadata
- `scripts/cinematics/cinematic_opening.gd` — opening cinematic script
- `scripts/cinematics/cinematic_iteration_transition.gd` — generic iteration transition
- `scripts/cinematics/cinematic_final_ending.gd` — final ending script
