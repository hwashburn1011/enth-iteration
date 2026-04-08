---
epic: 46
title: "UI VFX"
phase: 8 — VFX & Particles
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 46: UI VFX

## Overview

Create screen-level visual effects: glitch transitions with digital artifacts, level-up fanfare with full-screen golden burst, loot reveal spotlight, quest complete banner animation, damage vignette with red pulse, low health warning pulse, XP gain floating text, and currency pickup sparkle. UI VFX are the emotional punctuation marks of the game — they celebrate wins and emphasize danger.

## Success Criteria

- Level-up fanfare feels celebratory and exciting
- Screen transitions have the game's digital personality
- Damage feedback communicates urgency without obscuring vision
- Loot reveal creates anticipation and excitement
- Quest complete banner is satisfying and informative
- All UI VFX respect accessibility settings (reducible/disableable)
- Performance impact negligible (UI VFX are brief and infrequent)

---

## Tasks

### Task 46.1: Screen Fade with Glitch Effect
- **Status:** TODO
- **Description:** Create a screen transition effect that combines a fade with digital glitch artifacts. Used for scene transitions, death, and major story moments. The shader splits RGB channels horizontally (chromatic aberration increasing over 0.3s), adds scan line tearing (horizontal sections offset randomly), introduces pixel noise patches, then fades to black/white. The reverse plays on fade-in. Create configurable variants: subtle (light glitch, used for room transitions), moderate (noticeable, used for floor changes), and heavy (dramatic, used for death and boss transitions). Implement as a CanvasLayer shader applied via TransitionManager.
- **Acceptance Criteria:**
  - [ ] Chromatic aberration split during transition
  - [ ] Scan line tearing and pixel noise
  - [ ] 3 intensity variants (subtle/moderate/heavy)
  - [ ] Forward and reverse animations
  - [ ] Integrated with TransitionManager
  - [ ] Digital theme consistently applied

### Task 46.2: Level-Up Fanfare — Full-Screen Effect
- **Status:** TODO
- **Description:** Create a celebratory full-screen effect when the player levels up. Sequence (2 seconds total): bright golden flash expanding from the player's screen position outward (0.2s), golden particle burst (50 particles radiating outward then arcing down like fireworks), a brief time-slow (50% speed for 0.5s) to let the moment breathe, the level number pops up large center-screen in TITLE font ("LEVEL [N]!") with a scale bounce (0 -> 150% -> 100%), and a golden ring of light pulses outward across the screen. The effect should feel like a genuine reward — the game is celebrating the player's achievement.
- **Acceptance Criteria:**
  - [ ] Golden flash from player position
  - [ ] Particle burst like fireworks
  - [ ] Brief time-slow for emphasis
  - [ ] Level number with scale bounce
  - [ ] Golden ring pulse outward
  - [ ] Effect feels genuinely celebratory

### Task 46.3: Level-Up — Stat Point Notification
- **Status:** TODO
- **Description:** After the level-up fanfare, display a notification that the player has stat points to allocate. The notification slides in from the right side: a small panel with the message "Stat Points Available: [N]" in BODY bold with a golden glow, and a hint "Press [key] to open Character Stats". The panel should pulse gently until the player either opens the stat screen or dismisses it. If the player doesn't respond within 10 seconds, the panel slides to a compact form (just a golden badge on the HUD) that persists until stat points are spent. Create LevelUpNotification.gd managing the full sequence.
- **Acceptance Criteria:**
  - [ ] Notification slides in after fanfare
  - [ ] Shows available stat points
  - [ ] Keybind hint for stat screen
  - [ ] Pulses until addressed
  - [ ] Collapses to compact badge after 10s
  - [ ] LevelUpNotification.gd manages sequence

### Task 46.4: Loot Reveal Spotlight
- **Status:** TODO
- **Description:** Create a spotlight reveal effect for when the player opens a loot chest or collects a significant item. When the loot is revealed: a bright white spotlight descends from above the UI (as if a stage light is turning on), the item icon appears in the center of the screen at 128x128 with its rarity border and particles, the item name appears below in rarity-colored SUBTITLE font, item stats appear below the name in BODY font, and a "Collect" button or auto-dismiss timer appears. The background darkens to 50%. For legendary items: add a golden particle shower behind the icon, camera zoom, and dramatic music sting hook.
- **Acceptance Criteria:**
  - [ ] Spotlight from above illuminates loot
  - [ ] Item icon at center with rarity visual
  - [ ] Name and stats displayed below
  - [ ] Background darkens for focus
  - [ ] Legendary gets extra treatment
  - [ ] Collect/dismiss interaction

### Task 46.5: Quest Complete Banner
- **Status:** TODO
- **Description:** Create a banner animation that appears when a quest is completed. The banner slides in from the top-center: a horizontal panel with ornate borders (matching the HUD metallic style) containing "QUEST COMPLETE" in SUBTITLE bold with a golden glow, the quest name below in BODY, and reward summary icons (XP amount, items, currency). The banner holds for 3 seconds then slides back up. Add a brief burst of teal particles from the banner edges on appearance. If multiple quests complete simultaneously, queue them (1 second between each). Create QuestBanner.gd that supports quest type variants (story = gold border, character = teal, discovery = purple).
- **Acceptance Criteria:**
  - [ ] Banner slides from top-center
  - [ ] "QUEST COMPLETE" with golden glow
  - [ ] Quest name and reward summary
  - [ ] 3-second display, then slides away
  - [ ] Particle burst on appearance
  - [ ] Queue support for simultaneous completions

### Task 46.6: Damage Vignette — Red Screen Edge Pulse
- **Status:** TODO
- **Description:** Create the damage vignette effect that pulses when the player takes damage. Implement as a shader on a full-screen CanvasLayer ColorRect. The vignette is a red gradient (#FF0000 at 30% opacity) radiating inward from the screen edges, with intensity proportional to damage dealt (small hit: edges only, big hit: extends toward center). The vignette flashes on (0.05s) then fades out (0.3s). For very low health (under 25%), the vignette becomes persistent and pulses slowly (0.5Hz, from 10% to 30% opacity). The effect should communicate danger without obscuring the center of the screen where gameplay happens.
- **Acceptance Criteria:**
  - [ ] Red gradient from screen edges inward
  - [ ] Intensity proportional to damage amount
  - [ ] Flash on (0.05s), fade out (0.3s)
  - [ ] Persistent pulse at low health
  - [ ] Center of screen always clear
  - [ ] Communicates danger effectively

### Task 46.7: XP Gain Floating Text
- **Status:** TODO
- **Description:** Create floating text that appears when the player gains XP from any source. Small "+[amount] XP" text in purple (#C080FF) using BODY_SMALL font appears near the XP source (enemy death position projected to screen space, or quest complete position). The text floats upward and slightly toward the XP bar position, arcing in a subtle curve, over 1 second before fading out. Multiple XP gains in rapid succession should stack visually (each slightly offset to avoid overlap). If the XP gain causes a level-up, the floating text changes to gold and says "+[amount] XP — LEVEL UP!" before the fanfare plays.
- **Acceptance Criteria:**
  - [ ] "+XP" text appears at source position
  - [ ] Floats toward XP bar position
  - [ ] Purple color, BODY_SMALL font
  - [ ] Multiple gains stack without overlap
  - [ ] Level-up variant in gold
  - [ ] 1 second float duration

### Task 46.8: Currency Pickup Sparkle
- **Status:** TODO
- **Description:** Create a sparkle effect when the player picks up currency/materials/scrap. On pickup: small golden sparkle particles (5-10) burst from the pickup position, arc toward the currency display on the HUD, and disappear on "arrival" with a brief flash on the counter. The counter number increments with a scale bounce (1.0 -> 1.2 -> 1.0). Each sparkle particle should have a different arc trajectory (varied speed and curve) so they arrive in a staggered stream, not all at once. For large currency gains: more particles (15-20) and a "+[amount]" floating text in gold. Create CurrencyPickup.gd managing the effect.
- **Acceptance Criteria:**
  - [ ] Golden sparkle particles burst from pickup
  - [ ] Particles arc toward HUD currency counter
  - [ ] Counter flashes and bounces on increment
  - [ ] Staggered arrival (not simultaneous)
  - [ ] Large gains: more particles + floating text
  - [ ] CurrencyPickup.gd manages effect

### Task 46.9: Item Pickup Notification
- **Status:** TODO
- **Description:** Create a notification toast when the player picks up an item (from the ground or auto-loot). A small panel slides in from the right edge of the screen: item icon (48x48) with rarity border, item name in rarity-colored BODY bold, and a brief stat summary. The panel holds for 2 seconds then slides out. Multiple pickups queue vertically (newest at top, older slide down). Maximum 4 visible notifications. If more arrive, the oldest fades immediately. For rare+ items, add a brief glow pulse on the notification border. Create ItemPickupToast.gd with a queue management system.
- **Acceptance Criteria:**
  - [ ] Toast slides from right with icon + name
  - [ ] Rarity-colored styling
  - [ ] 2-second display, then slides out
  - [ ] Queue stacks vertically (max 4 visible)
  - [ ] Rare+ items have glow pulse
  - [ ] ItemPickupToast.gd manages queue

### Task 46.10: Buff Applied/Removed Notification
- **Status:** TODO
- **Description:** Create brief visual feedback when a buff or debuff is applied or removed. Applied: the buff/debuff icon from Epic 40 briefly appears center-screen at 64x64, scales from 0 to 100% with a pop, name appears briefly below ("OVERCLOCKED!"), then the icon arcs to its position in the HUD buff bar. Removed: the icon in the HUD buff bar flashes, shrinks to 0, and a small "poof" particle plays. For debuff applied: same but with a red flash and a negative tone (screen border pulses red for 0.1s). The notification should be quick (0.5s for the center display, 0.3s for the arc to HUD).
- **Acceptance Criteria:**
  - [ ] Buff icon appears center-screen with pop
  - [ ] Name text briefly shown
  - [ ] Icon arcs to HUD position
  - [ ] Debuff has red flash and border pulse
  - [ ] Removed: poof particle at HUD position
  - [ ] Full sequence under 1 second

### Task 46.11: Screen Shake System
- **Status:** TODO
- **Description:** Create a versatile screen shake system for various game events. Implement ScreenShake.gd that modifies the camera offset with configurable: amplitude (pixels), duration (seconds), frequency (shakes per second), and decay (linear or exponential). Presets: light (2px, 0.1s — hit dealt), medium (5px, 0.15s — hit received), heavy (10px, 0.3s — explosion/boss), rumble (3px, 1.0s, high frequency — environmental shake). The shake should add to the camera's position, not set it (so multiple shakes can combine). Provide a `shake(preset: String)` API and a setting to reduce or disable screen shake for accessibility.
- **Acceptance Criteria:**
  - [ ] Configurable amplitude, duration, frequency, decay
  - [ ] 4 presets (light/medium/heavy/rumble)
  - [ ] Multiple shakes combine (additive)
  - [ ] Setting to reduce/disable for accessibility
  - [ ] shake() API with preset parameter
  - [ ] Smooth decay (not abrupt end)

### Task 46.12: Iteration Transition Visual
- **Status:** TODO
- **Description:** Create a special full-screen visual for iteration transitions (when the player completes a full iteration cycle and the world resets). This is one of the most significant story moments. Sequence (5 seconds): the screen slowly whites out (2s fade to white), digital noise overtakes the white (0.5s), the noise resolves into a brief "ITERATION [N] COMPLETE" text (hold 1s), then the noise dissolves into the new iteration's starting scene (1.5s fade-in with the town). Add a unique color tint per iteration (Iteration 1: warm gold, Iteration 5: deep purple, Iteration 9: blinding white). This effect should feel momentous — a chapter ending.
- **Acceptance Criteria:**
  - [ ] Slow white-out transition
  - [ ] Digital noise intermediary
  - [ ] Iteration number text display
  - [ ] Color tint per iteration
  - [ ] Resolves into new iteration scene
  - [ ] Feels like a major story moment

### Task 46.13: Achievement/Milestone Popup
- **Status:** TODO
- **Description:** Create a popup for game milestones and achievements (first kill, first boss, first iteration, etc.). The popup slides in from the bottom-left: a compact panel with achievement icon (32x32), achievement name in BODY bold, and brief description in BODY_SMALL. A golden underline animation slides across the panel on appearance. The panel holds for 3 seconds then slides out. Sound hook: `achievement_unlocked(id: String)`. Achievements should queue like item pickups (max 2 visible). For major milestones (iteration complete, final boss), use a larger popup with more celebration.
- **Acceptance Criteria:**
  - [ ] Popup slides from bottom-left
  - [ ] Icon, name, and description
  - [ ] Golden underline animation
  - [ ] 3-second display
  - [ ] Queue management (max 2 visible)
  - [ ] Major milestones get larger popup

### Task 46.14: Tutorial Highlight System
- **Status:** TODO
- **Description:** Create a visual highlight system for tutorial elements. When the tutorial needs to draw attention to a HUD element, button, or game object: darken the rest of the screen (50% dark overlay), cut a bright circle/rectangle around the highlighted element (the overlay has a hole), add a pulsing border around the element (teal glow, 1Hz), and display instructional text nearby ("Click here to attack!"). The highlight should follow the element if it moves. Create TutorialHighlight.gd with `highlight(node: Control, text: String)` for UI elements and `highlight_world(position: Vector3, text: String)` for game objects.
- **Acceptance Criteria:**
  - [ ] Dark overlay with bright hole around target
  - [ ] Pulsing border on highlighted element
  - [ ] Instructional text displayed nearby
  - [ ] Follows moving elements
  - [ ] Works for both UI and world objects
  - [ ] TutorialHighlight.gd with clean API

### Task 46.15: Save/Autosave Indicator
- **Status:** TODO
- **Description:** Create a visual indicator that appears when the game is saving. A small spinning circuit icon (16x16) appears in the bottom-right corner during save operations. The icon spins for the duration of the save, then flashes green and fades out. For autosaves: the icon appears automatically with "Autosaving..." text in TINY font next to it. For manual saves: a brief "Game Saved" confirmation panel slides in (similar to item pickup toast but center-bottom). The save indicator should never obscure gameplay. If a save fails (unlikely), the icon flashes red and an error toast appears.
- **Acceptance Criteria:**
  - [ ] Spinning circuit icon during save
  - [ ] "Autosaving..." text for autosaves
  - [ ] "Game Saved" confirmation for manual saves
  - [ ] Green flash on success
  - [ ] Red flash on failure (with error)
  - [ ] Never obscures gameplay

### Task 46.16: Screen Flash Utility
- **Status:** TODO
- **Description:** Create a reusable screen flash utility for various game events. The flash is a brief overlay of color on the full screen. Implement ScreenFlash.gd with: `flash(color: Color, duration: float, intensity: float)`. Common presets: white flash (impact, explosion, 0.05s), gold flash (level up, loot reveal, 0.1s), red flash (damage taken, 0.05s), teal flash (ability ready, heal, 0.08s). The flash should use a CanvasLayer at the highest render order. Multiple flashes should blend (later flash doesn't cancel earlier). The flash intensity parameter controls the peak opacity (1.0 = full opaque flash, 0.3 = subtle tint).
- **Acceptance Criteria:**
  - [ ] Reusable flash with configurable color/duration/intensity
  - [ ] Common presets (white, gold, red, teal)
  - [ ] CanvasLayer at highest render order
  - [ ] Multiple flashes blend
  - [ ] Intensity controls peak opacity
  - [ ] ScreenFlash.gd with clean API

### Task 46.17: UI VFX Accessibility Integration
- **Status:** TODO
- **Description:** Ensure all UI VFX respect accessibility settings. When "Reduce Screen Effects" is enabled: disable screen flash, reduce vignette intensity by 50%, disable screen shake (or reduce to 25%), disable time-slow on critical/level-up, reduce particle counts by 50%. When "Colorblind Mode" is enabled: damage vignette uses pattern (cross-hatch) in addition to color, buff/debuff notifications include text labels not just colors, loot rarity uses shape in addition to color. Verify all UI VFX have a non-color-dependent alternative indicator.
- **Acceptance Criteria:**
  - [ ] "Reduce Screen Effects" disables flash/shake
  - [ ] Vignette reduced, not just disabled
  - [ ] Colorblind mode adds pattern/text indicators
  - [ ] All color-dependent UI has alternative
  - [ ] Settings applied to all UI VFX
  - [ ] Accessibility doesn't remove information

### Task 46.18: UI VFX Event Integration
- **Status:** TODO
- **Description:** Ensure all UI VFX trigger from the correct game events via EventBus. Map: `player_leveled_up` -> level-up fanfare, `player_damaged` -> damage vignette + screen shake, `quest_completed` -> quest banner, `item_picked_up` -> item toast + currency sparkle, `buff_applied/removed` -> buff notification, `loot_chest_opened` -> loot reveal, `save_started/completed` -> save indicator, `boss_phase_changed` -> screen effects per phase, `iteration_complete` -> iteration transition. Verify each connection with a test trigger and visual confirmation.
- **Acceptance Criteria:**
  - [ ] All EventBus connections mapped
  - [ ] Each event triggers correct VFX
  - [ ] Timing is correct (no delay)
  - [ ] No missing event connections
  - [ ] Each connection tested and verified
  - [ ] Event integration documented

### Task 46.19: Performance Verification
- **Status:** TODO
- **Description:** Profile all UI VFX for performance impact. Since UI VFX are typically brief and infrequent, they should have near-zero steady-state cost. Profile peak moments: level-up fanfare (most complex single effect), damage vignette during heavy combat (frequent triggers), quest + loot + pickup notifications all active simultaneously. Verify: peak UI VFX cost under 1ms, no frame drops during any single effect, no frame drops with multiple effects overlapping. The UI VFX CanvasLayer should use minimal draw calls.
- **Acceptance Criteria:**
  - [ ] Peak UI VFX cost under 1ms
  - [ ] No frame drops during level-up fanfare
  - [ ] Multiple overlapping effects tested
  - [ ] Minimal draw calls
  - [ ] No steady-state cost when no effects active
  - [ ] Performance verified at all quality settings

### Task 46.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture screenshots and videos of all UI VFX: level-up fanfare sequence, loot reveal spotlight, quest complete banner, damage vignette, XP floating text, currency sparkle, buff/debuff notifications, screen shake, iteration transition, and tutorial highlight. Record video showing a play session with multiple UI VFX triggering naturally. Save to `_bmad-output/visual-overhaul/screenshots/epic-46/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All UI VFX types captured
  - [ ] Video of natural gameplay with UI VFX
  - [ ] Level-up sequence shown step by step
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 39** (Custom Font) — Font for all UI VFX text
- **Epic 40** (HUD Redesign) — HUD positions for VFX targeting
- **Epic 44** (Combat VFX) — Screen effect systems and quality settings

## Notes

- UI VFX are emotional amplifiers — they make wins feel bigger and losses feel more impactful
- Less is more for each individual effect; the impact comes from the right effect at the right moment
- Screen shake is the most controversial effect — always provide a disable option
- Level-up is the player's most common celebration — it should feel great EVERY time
- Accessibility is non-negotiable — every effect must have a reduced or alternative form
