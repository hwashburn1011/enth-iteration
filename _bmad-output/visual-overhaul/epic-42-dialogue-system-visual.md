---
epic: 42
title: "Dialogue System Visual"
phase: 7 — UI/UX Overhaul
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 42: Dialogue System Visual

## Overview

Paint character portrait art (AI Sage, Cache Sprite, and expressions), design a dialogue box with sci-fi frame, implement text reveal animation with character-by-character sound, add speaker name with colored glow, create choice buttons with hover animation, and implement a dialogue history scroll. The dialogue system is how players connect with NPCs and the story — it must be characterful and polished.

## Success Criteria

- Character portraits are expressive and match the game's art style
- Each character has 4+ expression variants (neutral, happy, sad, surprised)
- Dialogue box frame matches the HUD/inventory sci-fi aesthetic
- Text reveals character-by-character at configurable speed
- Speaker names have character-specific colors and glow
- Choice buttons have clear hover/select feedback
- Dialogue history allows scrolling back through conversation
- System supports both NPC dialogue and system/narrative text

---

## Tasks

### Task 42.1: Portrait Art Style Definition
- **Status:** TODO
- **Description:** Define the portrait art style before painting any characters. Choose between: hand-painted semi-realistic (Hades-like), stylized anime-adjacent (Fire Emblem), pixel art (Stardew Valley), or painted abstract (unique to this game's digital theme). Given Enth: Iteration's digital/simulation setting, consider a style that blends traditional portrait with digital artifacts — painted faces with subtle scan lines, pixel fragments at edges, or holographic shimmer. Create a style test by painting one character (AI Sage) at rough quality in 2-3 different styles. Select the style that best balances character expressiveness with the game's digital aesthetic.
- **Acceptance Criteria:**
  - [ ] 2-3 portrait style options explored
  - [ ] Style test painted for AI Sage
  - [ ] Selected style balances expression and digital aesthetic
  - [ ] Style guide rules documented (line weight, color palette, detail level)
  - [ ] Style works at the display size (256x256 or 192x256)
  - [ ] Style is feasible to reproduce for all characters

### Task 42.2: AI Sage Portrait — Full Expression Set
- **Status:** TODO
- **Description:** Paint the AI Sage's portrait set at 256x256 (or chosen standard size). AI Sage is a wise, ancient AI entity — their portrait should convey digital wisdom: geometric/angular features, calm eyes with data-stream pupils, a hood or mantle suggesting scholarly authority, and a color palette of deep blues and teals. Paint 6 expressions: Neutral (default calm), Happy (slight smile, eyes soften), Sad (downcast gaze, dimmer glow), Surprised (wide eyes, brighter data streams), Angry (sharp features, red-tinted glow), Mysterious (half-shadowed, one eye glowing). Each expression should change 30-40% of the face while the base portrait remains consistent.
- **Acceptance Criteria:**
  - [ ] 6 expression variants painted at 256x256
  - [ ] Each expression clearly distinct at display size
  - [ ] Base portrait consistent across expressions
  - [ ] Digital aesthetic elements (data streams, geometric)
  - [ ] Color palette: deep blue/teal
  - [ ] Character feels wise and ancient

### Task 42.3: Cache Sprite Portrait — Full Expression Set
- **Status:** TODO
- **Description:** Paint Cache Sprite's portrait set. Cache Sprite is a small, energetic digital fairy/sprite companion — their portrait should convey playfulness and energy: round features, large expressive eyes, glowing translucent wings, a color palette of bright greens and cyans. Paint 6 expressions: Neutral (curious tilt), Happy (wide grin, sparkling eyes), Sad (drooping wings, teary), Surprised (O-mouth, wings spread), Concerned (furrowed brow, wings drawn in), Mischievous (sly grin, one eye squinting). Cache Sprite's expressions should be more exaggerated than AI Sage's (they're the emotional counterpart).
- **Acceptance Criteria:**
  - [ ] 6 expression variants painted at 256x256
  - [ ] Expressions more exaggerated than AI Sage
  - [ ] Bright green/cyan color palette
  - [ ] Glowing wings change with expressions
  - [ ] Character feels energetic and playful
  - [ ] Clearly distinct from AI Sage's visual identity

### Task 42.4: Additional NPC Portraits
- **Status:** TODO
- **Description:** Paint portraits for any additional NPCs that appear in dialogue. At minimum: the system/narrator voice (a geometric abstract portrait representing "The Computer" — circuit patterns forming a face shape, cool gray and teal, minimal expressions: Normal, Warning, Error), and any other NPCs defined in the GDD. Each NPC needs at least 3 expressions (Neutral, Positive, Negative). Follow the style guide from Task 42.1. Each character should have a unique color palette and silhouette so they're instantly identifiable even as a small thumbnail.
- **Acceptance Criteria:**
  - [ ] System/narrator portrait created (3 expressions)
  - [ ] Additional NPC portraits as needed (3+ expressions each)
  - [ ] Each NPC has unique color palette
  - [ ] Each NPC identifiable by silhouette
  - [ ] All follow the established portrait style
  - [ ] Style consistency across all characters

### Task 42.5: Dialogue Box Frame Design
- **Status:** TODO
- **Description:** Design the dialogue box frame sprite. The box should span the bottom 25% of the screen (full width minus margins, approximately 1800x250 at 1080p). Design elements: metallic border matching the HUD/inventory style, portrait frame on the left (256x256 inset with beveled border), text area to the right of the portrait, speaker name plate above the text area (angled tab shape), choice area below the text (appears when choices are available). The frame should have: circuit-trace accent lines, subtle animated corner elements (small pulsing dots), and a glass/overlay texture for subtle visual interest. The text area background should be dark (#1A2030 at 95% opacity) for readability.
- **Acceptance Criteria:**
  - [ ] Dialogue box spans bottom 25% of screen
  - [ ] Portrait frame on left with beveled border
  - [ ] Text area with dark readable background
  - [ ] Speaker name plate above text
  - [ ] Choice area below text
  - [ ] Metallic frame consistent with HUD style

### Task 42.6: Speaker Name with Colored Glow
- **Status:** TODO
- **Description:** Implement the speaker name display with character-specific styling. The name appears on the angled tab above the text area. Each character has a signature color: AI Sage = teal (#40C0C0), Cache Sprite = bright green (#40FF80), System/Narrator = cool gray (#8090A0), player character = warm gold (#FFD040). The name text uses SUBTITLE bold font in the character's color. Behind the text, add a soft glow effect (gaussian blur of the text color, 50% opacity, spreading 4px beyond the text) creating a colored light effect. When the speaker changes, the name and glow should cross-fade (0.3s) to the new character's name and color.
- **Acceptance Criteria:**
  - [ ] Character-specific name colors defined
  - [ ] Colored glow behind name text
  - [ ] Cross-fade between speakers (0.3s)
  - [ ] SUBTITLE bold font for names
  - [ ] Glow effect visible but not overpowering
  - [ ] Name plate tab shape frames the name

### Task 42.7: Text Reveal Animation
- **Status:** TODO
- **Description:** Implement character-by-character text reveal for dialogue. Each character of the text string appears one at a time from left to right, creating a typewriter effect. Configure speed: normal (30 characters/second), slow (15 chars/s for dramatic moments), and fast (60 chars/s for casual dialogue). Speed can be overridden per dialogue line via a tag. When a character appears, it should have a tiny visual pop (scale from 120% to 100% over 2 frames) for a subtle bounce effect. The player can press a key to instantly complete the text reveal (skip to full text). Punctuation marks (period, comma, exclamation) should add a brief pause (period: 0.15s, comma: 0.08s) for natural reading rhythm.
- **Acceptance Criteria:**
  - [ ] Character-by-character reveal at configurable speed
  - [ ] Punctuation pauses for natural rhythm
  - [ ] Subtle character pop on reveal
  - [ ] Skip button instantly completes text
  - [ ] 3 speed settings (slow/normal/fast)
  - [ ] Per-line speed override via dialogue tag

### Task 42.8: Text Reveal Sound Effect Hook
- **Status:** TODO
- **Description:** Add audio hooks for the text reveal (actual sound in Epic 49). Each character type should have a distinct blip sound: AI Sage gets a deep resonant tone, Cache Sprite gets a high cheerful chirp, System/Narrator gets a cold synthetic click, player gets a neutral mid-tone. Emit the sound on each character reveal (or every 2-3 characters to avoid machine-gun sound). The sound should vary slightly in pitch per character (random +-5% pitch variation) to avoid monotony. Provide EventBus signal `dialogue_char_revealed(character_name: String, char_index: int)` for the audio system to hook into.
- **Acceptance Criteria:**
  - [ ] Audio hook signal emitted per character reveal
  - [ ] Character name included for voice differentiation
  - [ ] Sound triggers every 2-3 characters (not every one)
  - [ ] Pitch variation specified in the signal
  - [ ] Different blip per speaking character
  - [ ] Signal timing synced with visual reveal

### Task 42.9: Portrait Expression Transitions
- **Status:** TODO
- **Description:** Implement smooth expression changes on character portraits during dialogue. When a dialogue line specifies an expression change (via tag like `[expression:happy]`), the portrait should transition: brief cross-fade (0.2s) between current and new expression. For more dramatic changes (neutral to angry): add a quick shake animation on the portrait (3px horizontal, 0.1s). For surprise: add a brief zoom (105% scale, 0.15s, bounce back). The portrait should also have a subtle idle animation: very slow breathing motion (1% scale pulse at 0.2Hz) and occasional blink (eyes close for 0.15s, every 3-5 seconds random). These subtle animations make the portrait feel alive.
- **Acceptance Criteria:**
  - [ ] Cross-fade between expressions
  - [ ] Dramatic expression changes have shake/zoom
  - [ ] Idle breathing animation (subtle)
  - [ ] Random blinking animation
  - [ ] Expression change specified via dialogue tags
  - [ ] Portraits feel alive, not static

### Task 42.10: Choice Button Design and Hover Animation
- **Status:** TODO
- **Description:** Design dialogue choice buttons that appear when the player must make a decision. Each choice is a wide button in the choice area below the text. Button design: dark background (#2A3040) with metallic border, choice text in BODY font, a small numbered indicator on the left (1, 2, 3 for keyboard shortcut). Hover state: border brightens and glows in teal (#40C0C0), background lightens 10%, text shifts right 4px (slide-in feel), and a small cursor arrow appears on the left. Selected/pressed state: brief flash (white overlay, 0.1s), then the dialogue advances. Choices should stack vertically with 4px gap between them. Maximum 4 choices visible.
- **Acceptance Criteria:**
  - [ ] Choice buttons with consistent sci-fi styling
  - [ ] Numbered indicators for keyboard shortcuts
  - [ ] Hover: glow border, lighten, text slide
  - [ ] Pressed: brief white flash
  - [ ] Maximum 4 choices displayed
  - [ ] Keyboard numbers 1-4 select choices

### Task 42.11: Dialogue History Scroll
- **Status:** TODO
- **Description:** Implement a scrollable dialogue history so players can review past conversation. Add a small "history" button (scroll icon) in the dialogue frame corner. When pressed: the dialogue box expands upward (or a separate panel slides in) showing all previous dialogue lines in this conversation, scrollable with mouse wheel or arrow keys. Each line shows: the speaker's colored name, the dialogue text, and the player's chosen response (if any, highlighted in a different tint). The history should hold the last 50 lines. When scrolling history, the current dialogue remains visible at the bottom. Close history with ESC or the history button again.
- **Acceptance Criteria:**
  - [ ] History button in dialogue frame
  - [ ] Scrollable list of previous dialogue lines
  - [ ] Speaker names colored per character
  - [ ] Player responses highlighted differently
  - [ ] Last 50 lines retained
  - [ ] Current dialogue visible while viewing history

### Task 42.12: Dialogue Box Show/Hide Animations
- **Status:** TODO
- **Description:** Implement show and hide animations for the dialogue box. Show: the box slides up from the bottom of the screen (0.3s ease-out), portrait fades in slightly after (0.1s delay), then text begins revealing. Hide: text completes, box slides down (0.3s ease-in). When dialogue auto-advances (no player input needed): the box stays visible with a brief "..." indicator, then new text reveals. When transitioning between speakers: the box stays, portrait cross-fades, name plate cross-fades, then new text reveals. Provide a brief "conversation ended" indicator: the box border dims and a small "END" badge appears before sliding away.
- **Acceptance Criteria:**
  - [ ] Slide-up animation on dialogue start
  - [ ] Slide-down animation on dialogue end
  - [ ] Box stays during speaker transitions
  - [ ] "..." indicator for auto-advance
  - [ ] "END" badge before final slide-away
  - [ ] All animations are smooth and non-jarring

### Task 42.13: System/Narrator Text Style
- **Status:** TODO
- **Description:** Create a distinct visual style for system messages and narration that differs from character dialogue. System text (tutorial prompts, item descriptions, status messages): no portrait, text centered in the box, italicized BODY font, cool gray color, thin border glow instead of character color. Narration (story text, environmental descriptions): no portrait, text left-aligned with wider margins, BODY italic, warm gold color, the dialogue box frame shifts to a more ornate "storybook" variant. Both types should be clearly distinguishable from character dialogue at a glance.
- **Acceptance Criteria:**
  - [ ] System text: centered, italic, gray
  - [ ] Narration: left-aligned, italic, gold
  - [ ] Both display without character portrait
  - [ ] Clearly distinct from character dialogue
  - [ ] Frame variant for narration (optional)
  - [ ] Both types use text reveal animation

### Task 42.14: Dialogue Continue Indicator
- **Status:** TODO
- **Description:** Create a "continue" indicator that tells the player more text is waiting after the current line is fully revealed. Design a small animated indicator in the bottom-right corner of the text area: a downward-pointing triangle that bobs up and down (3px amplitude, 2Hz). The triangle should be in the speaker's color and appear only after the full line has been revealed. Additionally, show a subtle "Press [key] to continue" hint that fades in 2 seconds after the text completes (for first-time players). The indicator should feel like a natural part of the dialogue flow, not an intrusive prompt.
- **Acceptance Criteria:**
  - [ ] Bobbing triangle indicator for "more text"
  - [ ] Indicator in speaker's color
  - [ ] Appears only after text fully revealed
  - [ ] "Press [key]" hint fades in after 2 seconds
  - [ ] Indicator feels natural and non-intrusive
  - [ ] Hidden during choice selection

### Task 42.15: Dialogue with Gameplay Pausing
- **Status:** TODO
- **Description:** Configure the dialogue system's interaction with game state. When dialogue opens: the game world pauses (or slows to 5% for ambient animation), the HUD fades to 30% opacity, and the camera may zoom slightly toward the NPC (5% zoom, smooth). When dialogue closes: the game resumes at full speed (0.5s ramp-up for smooth feel), the HUD returns to full opacity, and the camera zooms back. During dialogue, the player character should turn to face the NPC and play an idle/listening animation. The NPC should play a talking animation (if available) or a subtle gesture.
- **Acceptance Criteria:**
  - [ ] Game pauses/slows during dialogue
  - [ ] HUD fades to background opacity
  - [ ] Camera zooms slightly toward NPC
  - [ ] Player turns to face NPC
  - [ ] Game resumes smoothly after dialogue
  - [ ] NPC has talking/gesture animation during dialogue

### Task 42.16: Rich Text Support
- **Status:** TODO
- **Description:** Implement rich text formatting in dialogue using Godot's RichTextLabel BBCode. Support: `[b]bold[/b]` for emphasis, `[color=#hex]colored text[/color]` for highlighting key words, `[item]item_name[/item]` custom tag that displays the item icon inline with text, `[stat]stat_name[/stat]` that displays the stat icon inline, `[shake]text[/shake]` for dramatic shaking text, and `[wave]text[/wave]` for wavy text (digital instability). Create custom BBCode effects for shake and wave using RichTextEffect. The text reveal animation should work correctly with all BBCode formatting.
- **Acceptance Criteria:**
  - [ ] Bold and color BBCode work in dialogue
  - [ ] Item and stat icons renderable inline
  - [ ] Shake text effect for dramatic moments
  - [ ] Wave text effect for digital instability
  - [ ] Text reveal animation respects BBCode
  - [ ] RichTextEffects implemented for custom tags

### Task 42.17: Accessibility Features
- **Status:** TODO
- **Description:** Add accessibility features to the dialogue system. Options: text_speed setting (Slow/Normal/Fast/Instant), font_size_override (increase dialogue text by 2/4/6px), high_contrast_mode (increase text-background contrast, add stronger borders), and auto_advance (dialogue auto-advances after a configurable delay instead of requiring input, for accessibility). Also ensure all dialogue content is accessible to screen readers (set appropriate Godot accessibility properties on RichTextLabel nodes). Provide a "text log" that can be accessed outside of active dialogue for players who need to re-read.
- **Acceptance Criteria:**
  - [ ] Text speed setting (Slow/Normal/Fast/Instant)
  - [ ] Font size override for larger text
  - [ ] High contrast mode
  - [ ] Auto-advance option with delay
  - [ ] Accessibility properties set for screen readers
  - [ ] Text log accessible outside dialogue

### Task 42.18: Dialogue Transition Between NPCs
- **Status:** TODO
- **Description:** Handle smooth transitions when dialogue involves multiple NPCs (e.g., AI Sage and Cache Sprite talking to each other). When the speaker changes within the same conversation: the portrait cross-fades (0.2s), the name plate cross-fades with color change, a subtle directional indicator shows which NPC is speaking (if both are on-screen, a small arrow or highlight on the speaking NPC). If more than 2 characters are in conversation: show both portraits (smaller, 192x192) on opposite sides of the dialogue box, with the current speaker's portrait bright and the listener's dimmed. Implement a DialogueManager that handles multi-character conversation flow.
- **Acceptance Criteria:**
  - [ ] Single-speaker transitions smooth (cross-fade)
  - [ ] Multi-speaker shows both portraits
  - [ ] Active speaker bright, listener dimmed
  - [ ] Directional indicator for speaker location
  - [ ] DialogueManager handles multi-character flow
  - [ ] Transitions don't break immersion

### Task 42.19: Performance Testing
- **Status:** TODO
- **Description:** Profile the dialogue system performance: portrait loading time, text reveal rendering, rich text BBCode parsing, history scroll with 50 entries, and expression transition effects. The dialogue box should appear within 0.1 seconds of trigger (portrait must pre-cache). Text reveal should not cause frame drops even with rich text effects active. History scroll should be smooth with 50+ entries. Test with the longest dialogue in the game (most text, most expression changes, most choices). Target: zero frame drops during any dialogue interaction.
- **Acceptance Criteria:**
  - [ ] Portrait loads within 0.1s (pre-cached)
  - [ ] Text reveal causes no frame drops
  - [ ] Rich text effects render smoothly
  - [ ] History scroll smooth with 50+ entries
  - [ ] Longest dialogue tested without issues
  - [ ] Zero frame drops during dialogue

### Task 42.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture screenshots of: each character's portrait expressions, dialogue box with AI Sage speaking, dialogue with choices visible, text reveal mid-animation, dialogue history view, system/narrator text, and multi-character conversation. Save to `_bmad-output/visual-overhaul/screenshots/epic-42/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All character portraits shown with expressions
  - [ ] Dialogue box in various states captured
  - [ ] Choice buttons with hover state
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 39** (Custom Font) — Font for all dialogue text
- **Epic 40** (HUD Redesign) — Visual language for frames
- **Epic 19-22** (NPC Epics) — Character designs for portraits

## Notes

- Character portraits are the most emotionally important art in the game — players bond with faces
- The text reveal speed is contentious; always default to Normal but make it easy to change
- Rich text effects should be used sparingly in dialogue — too many and they lose impact
- Test with actual dialogue content, not Lorem Ipsum — the text length and pacing matters
- Dialogue is where the game's story lives; the visual polish here directly impacts story engagement
