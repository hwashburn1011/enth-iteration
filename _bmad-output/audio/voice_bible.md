---
name: Voice Treatment Bible
description: Per-NPC voice grunt system, typewriter dialogue, reactive grunts, narrator
date: 2026-04-09
status: design + manager complete; audio production pending
---

# Voice Treatment Bible

## Philosophy

Enth doesn't ship with full voice acting (the cost is too high for an
indie scope). Instead, every named NPC has a small **library of voice
grunts** that play during dialogue — a Sea of Stars / Animal Crossing
approach where each character has a unique vocal "color" without literal
spoken lines.

This gives the game audio personality without the production cost of
recording every line. If we get a budget bump later, we swap the grunts
for real spoken VO and the system keeps working.

## Voice approach decision

After evaluating real VAs / AI TTS / text-only, we landed on:

**Per-NPC grunt libraries** (6 grunts each, pitch-tuned per character)
- Pros: charming, unique per NPC, cheap to produce, low memory
- Cons: not literal speech, can't hear lore exposition
- Mitigation: typewriter SFX + clear text + portrait expressions carry meaning

For cinematics that need narration (iteration intros, opening, ending),
we use **AI TTS** with a curated narrator voice.

## Per-NPC grunt library

Each NPC has 6 emotion-tagged grunts:
1. **neutral** — default talk grunt (most lines)
2. **happy** — for friendly/excited lines
3. **sad** — for melancholy/serious lines
4. **surprised** — for revelations
5. **angry** — for confrontations
6. **questioning** — for inquiry lines

Each NPC's grunts are pitched and tuned to their character:

| NPC | Pitch | Speed | Reverb | Notes |
|---|---|---|---|---|
| Globbler | 1.05 | 1.0 | dry | warm, slightly youthful |
| Sage | 0.85 | 0.85 | hall | warm, low, slow |
| Pixel | 1.10 | 1.1 | dry | bright, eager shopkeeper |
| Forge | 0.90 | 0.9 | room | gruff, deliberate |
| Cache | 1.0 | 1.0 | dry | warm, jazz-bartender |
| Index | 0.95 | 0.95 | hall | quiet scholar |
| Harvest | 1.0 | 0.95 | dry | hearty farmer |
| Bit | 1.30 | 1.2 | dry | child pitch, fast |
| Legacy | 0.80 | 0.8 | hall | elder, slow + warm |
| Trade | 1.05 | 1.05 | dry | smooth merchant |
| Lab | 1.10 | 1.1 | room | nervous, precise |
| Render | 1.05 | 1.05 | dry | dreamy artist |
| Sync | 1.0 | 1.0 | hall | musical, sing-song |
| Sentinel | 0.85 | 0.9 | room | military, clipped |

## Dialogue playback flow

When a dialogue line begins:
1. Pick a grunt for the line's emotion tag (default: neutral)
2. Cycle through the NPC's variant pool to avoid repetition
3. Play grunt at line start
4. Play typewriter SFX per character
5. End grunt before next line

## Typewriter SFX

A subtle "tick" sound plays every Nth character (default every 2). Each
character has its own typewriter sound file for variety:
- `typewriter_default` — basic click
- `typewriter_low` — for elder NPCs
- `typewriter_high` — for child NPCs
- `typewriter_glitch` — for corrupted/glitch dialogue

## Per-character text speed

Each NPC's dialogue text speed is tuned to their personality:
- Bit (child): 40 cps
- Pixel: 35 cps
- Sage: 20 cps (slow, contemplative)
- Legacy: 18 cps
- Default: 30 cps

## Per-character font

Most NPCs share the default font. Special cases:
- Sage: serif font (gravitas)
- Bit: rounded font (childlike)
- Glitch enemies: glitched/distorted font

## Narrator (AI TTS)

For story cinematics, an AI-generated narrator voice handles:
- Opening cinematic (~2 minutes)
- Iteration 2 reveal (~30 seconds)
- Iteration 5 reveal (~30 seconds)
- Iteration 9 ending (~3 minutes)

Voice profile: warm, neutral gender, slow cadence. Fits the
"computer awakening" tone.

## Reverb / environmental processing

Voice grunts get environmental reverb based on the dialogue location:
- Town outdoors: dry (no reverb)
- Town interiors (tavern, library): room reverb
- Sage's tower: hall reverb
- Dungeon: small_cave reverb
- Final vault: cathedral reverb

The VoiceManager auto-applies based on `current_environment` setting.

## Reactive grunts

NPCs and Globbler emit reactive grunts on certain gameplay events:
- Hit by enemy: damage grunt (light/medium/heavy)
- Death: death grunt
- Level up: triumphant grunt
- Quest accept: surprised grunt
- Boss spawn: warning grunt

These are short (< 0.5s) and don't interrupt music.

## Combat callouts

Active companion (Epic 40) can shout combat callouts:
- "Behind you!"
- "Look out!"
- "I'll hold them!"
- "On your six!"
- "Got him!"

These are essentially text-with-grunt overlays that pop up briefly during
combat. Not literal speech.

## Volume + mixing

Voice volume is controlled by:
- `AccessibilitySettings.voice_volume` (0-100%)
- `AccessibilitySettings.master_volume`
- Per-NPC volume offset (in voice config)

A separate `Voice` audio bus allows the player to mute voices entirely
without affecting music or SFX.

## Save data

- voice_volume (in AccessibilitySettings)
- last_played_grunt_per_npc (for variation tracking)

## Files

- `_bmad-output/audio/voice_bible.md` — this file
- `scripts/systems/voice_database.gd` — per-NPC voice configs + grunt pools
- `scripts/autoloads/voice_manager.gd` — global voice controller
