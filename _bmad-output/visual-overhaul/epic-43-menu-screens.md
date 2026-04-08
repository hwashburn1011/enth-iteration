---
epic: 43
title: "Menu Screens Polish"
phase: 7 — UI/UX Overhaul
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 43: Menu Screens Polish

## Overview

Polish all menu screens: main menu with 3D background scene (town vista or digital void), animated title with glitch effect, settings screen with visual previews, credits scroll with team art, save slot screen with preview thumbnails, and loading screen tips with concept art. The main menu is the player's first impression and the settings screen enables them to tailor their experience.

## Success Criteria

- Main menu has an atmospheric 3D background (not a flat image)
- Game title has a memorable animated treatment (glitch/digital effect)
- Settings screen provides visual previews for graphics options
- Save slot screen shows meaningful save information with thumbnails
- Credits screen is polished and respectful
- Loading screens provide useful tips with engaging visuals
- All menu transitions are smooth
- Menu navigation works with keyboard, mouse, and controller

---

## Tasks

### Task 43.1: Main Menu Background — 3D Scene
- **Status:** TODO
- **Description:** Create an atmospheric 3D background scene for the main menu. Two options: (A) Town Vista — a stylized view of the town from an elevated angle, with gentle camera drift, atmospheric effects active (god rays, fireflies, chimney smoke), and warm lighting suggesting a peaceful evening. (B) Digital Void — an abstract digital space with floating geometric shapes, data streams, circuit patterns, and cool blue-teal lighting representing the digital simulation before it's entered. Choose the option that best communicates the game's identity. The scene should be lightweight (simple geometry, baked lighting) and run smoothly behind the menu UI.
- **Acceptance Criteria:**
  - [ ] 3D scene chosen and implemented
  - [ ] Gentle camera drift animation
  - [ ] Atmospheric effects active (particles, lighting)
  - [ ] Scene communicates the game's identity
  - [ ] Lightweight enough to run smoothly behind UI
  - [ ] Scene loops seamlessly

### Task 43.2: Animated Game Title
- **Status:** TODO
- **Description:** Create the "Enth: Iteration" title treatment with a digital glitch animation. The title should use the accent font (from Epic 39) at a large display size. Animation sequence on menu load: (1) Title starts as scrambled digital noise (random characters in the font), (2) Characters resolve one by one from left to right (each settling into the correct letter with a brief flicker), (3) Once resolved, the title holds steady with occasional subtle glitch (1-2 random characters briefly scramble every 5-10 seconds, then correct themselves). Add a subtle colored glow behind the title (teal #40C0C0). The "Iteration" subtitle should have a smaller, cleaner treatment below the main title.
- **Acceptance Criteria:**
  - [ ] Title resolves from scrambled noise to correct text
  - [ ] Character-by-character resolution animation
  - [ ] Occasional idle glitch after resolution
  - [ ] Teal glow behind title
  - [ ] "Iteration" subtitle clean and readable
  - [ ] Title animation plays on every menu visit

### Task 43.3: Main Menu Button Layout
- **Status:** TODO
- **Description:** Design and implement the main menu button layout. Buttons: "Continue" (only if save exists), "New Game", "Settings", "Credits", "Quit". Position buttons in a vertical stack on the left or center-bottom of the screen, not obscuring the 3D background. Button style: same sci-fi design as dialogue choice buttons (dark background, metallic border, hover glow). "Continue" should be highlighted by default (pre-selected) if a save exists. Add a version number in the bottom-right corner (TINY font). Add a subtle ambient sound/music prompt (audio hook for menu theme from Epic 48). Button navigation works with keyboard arrows, mouse hover/click, and controller D-pad/A.
- **Acceptance Criteria:**
  - [ ] 5 menu buttons in clean vertical stack
  - [ ] "Continue" highlighted if save exists
  - [ ] Sci-fi button styling matching dialogue choices
  - [ ] Version number in corner
  - [ ] Keyboard, mouse, and controller navigation
  - [ ] Buttons don't obscure 3D background

### Task 43.4: Settings Screen — Layout Design
- **Status:** TODO
- **Description:** Design the settings screen with tabbed sections: Video, Audio, Gameplay, Accessibility, Controls. Each tab shows its settings in a scrollable list with: setting label on the left (BODY font), control widget on the right (slider, dropdown, toggle, or key binding). Video settings include: resolution, fullscreen mode, vsync, shadow quality, SSAO, bloom, volumetric fog, anti-aliasing, HUD scale, transition speed. Audio: master volume, music volume, SFX volume, dialogue volume. Gameplay: text speed, auto-save frequency, camera sensitivity. Accessibility: HUD opacity, reduced screen effects, colorblind mode, font size override. Controls: keybinding list.
- **Acceptance Criteria:**
  - [ ] 5 tabbed sections
  - [ ] All settings from GDD included
  - [ ] Clean layout with label/widget alignment
  - [ ] Scrollable within each tab
  - [ ] Consistent widget styling
  - [ ] Tab navigation with keyboard/controller

### Task 43.5: Settings — Visual Preview System
- **Status:** TODO
- **Description:** Add visual previews for graphics settings so players can see the effect before applying. In the Video tab, add a small preview window (320x180) showing a representative game scene. When the player hovers over a graphics setting: the preview updates in real-time to show the effect of changing that setting. For SSAO: show a corner scene with/without AO. For bloom: show a lantern scene with/without glow. For shadow quality: show a building with different shadow resolution. For volumetric fog: show a dungeon scene with/without fog. The preview should update within 0.5 seconds of the setting change.
- **Acceptance Criteria:**
  - [ ] Preview window shows representative scene
  - [ ] Preview updates on setting hover/change
  - [ ] SSAO, bloom, shadow, fog all previewable
  - [ ] Preview updates within 0.5 seconds
  - [ ] Preview is small enough to not dominate the screen
  - [ ] Works for all visual settings

### Task 43.6: Settings — Audio Sliders with Live Preview
- **Status:** TODO
- **Description:** Implement audio sliders in the Audio tab with live preview. Each slider (Master, Music, SFX, Dialogue) should: display as a horizontal bar (similar to health bar style but simpler), show the current value as a percentage, and play a sample sound when adjusted. Music slider: adjusts the menu music volume in real-time. SFX slider: plays a sample SFX (click sound) at the new volume. Dialogue slider: plays a sample dialogue blip at the new volume. Master slider: adjusts all other sliders' effective output. Sliders should have tick marks at 0%, 25%, 50%, 75%, 100% with the value snapping near these points (±3%).
- **Acceptance Criteria:**
  - [ ] 4 audio sliders with percentage display
  - [ ] Music adjusts in real-time
  - [ ] SFX plays sample on adjust
  - [ ] Dialogue plays sample on adjust
  - [ ] Master affects all others
  - [ ] Tick marks with snap behavior

### Task 43.7: Settings — Key Binding Interface
- **Status:** TODO
- **Description:** Create a key binding interface in the Controls tab. Display all game actions in a list: movement (WASD), dash, attack, charged attack, abilities 1-4, prompts, interact, inventory, pause, minimap toggle. Each action shows: the action name (BODY), current binding (STAT_VALUE in a key-shaped frame), and a "Rebind" button. When rebinding: the key frame flashes "Press any key...", captures the next key press, checks for conflicts (highlight the conflicting action in red with "Conflict!" label), and confirms the new binding. Support both primary and secondary bindings per action. Show controller bindings in a separate column if a controller is connected.
- **Acceptance Criteria:**
  - [ ] All actions listed with current bindings
  - [ ] "Press any key" capture mode for rebinding
  - [ ] Conflict detection and warning
  - [ ] Primary and secondary bindings supported
  - [ ] Controller bindings shown when controller connected
  - [ ] Reset to defaults button

### Task 43.8: Save Slot Screen Design
- **Status:** TODO
- **Description:** Design the save/load screen with 3 save slots (matching the game's 3-slot rolling save system). Each slot shows: a preview thumbnail (320x180 screenshot taken at last save), character name and level, play time, current location (town or dungeon floor), last save timestamp, and iteration number. Empty slots show "Empty Slot" with a "New Game" option. The selected slot expands slightly with more detail. Add a "Delete Save" option with a confirmation dialog. The slot frame should match the inventory panel style. Save thumbnails should be captured automatically during the auto-save trigger.
- **Acceptance Criteria:**
  - [ ] 3 save slots displayed
  - [ ] Preview thumbnail per slot
  - [ ] Character info (name, level, time, location)
  - [ ] Empty slots show "New Game" option
  - [ ] Delete with confirmation dialog
  - [ ] Auto-captured save thumbnails

### Task 43.9: Credits Screen
- **Status:** TODO
- **Description:** Create a polished credits scroll. The credits should scroll upward at a comfortable reading speed (configurable with up/down arrows for speed control). Display: game title at the top with a smaller version of the glitch animation, team roles and names in formatted sections (Role in SUBTITLE, Name in BODY bold), special thanks section, open source license attributions (font, libraries), and "Made with Godot Engine" logo at the end. The background should show a slow pan across concept art or key game screenshots. Add the ability to skip credits with a button press (show "Skip" prompt in corner). Credits should be data-driven (loaded from a credits.json or credits.txt file).
- **Acceptance Criteria:**
  - [ ] Scrolling credits at comfortable speed
  - [ ] Speed adjustable with arrow keys
  - [ ] Formatted sections (roles, names, thanks)
  - [ ] License attributions included
  - [ ] Godot Engine attribution
  - [ ] Skip option available

### Task 43.10: Loading Screen Design
- **Status:** TODO
- **Description:** Design the loading screen that appears during initial game load and long transitions. Display: a background (concept art, key game screenshot, or the abstract digital void), a loading indicator (the circuit-trace fill bar from Epic 38), a gameplay tip (rotated randomly from a pool of 20+ tips, displayed in BODY font), the game logo (small, in corner), and a brief descriptor of what's loading ("Entering Dungeon Floor 3..." or "Loading Town..."). The loading screen should feel premium — not just a progress bar on black. Cycle tips every 5 seconds if loading takes longer. Pre-render the loading screen assets so they display instantly.
- **Acceptance Criteria:**
  - [ ] Atmospheric background (art or screenshot)
  - [ ] Circuit-trace loading indicator
  - [ ] Rotating gameplay tips (20+ pool)
  - [ ] Context-aware loading text
  - [ ] Game logo in corner
  - [ ] Tips cycle every 5 seconds for long loads

### Task 43.11: Loading Tips Content
- **Status:** TODO
- **Description:** Write 25+ loading screen tips that are genuinely useful for players. Categories: combat tips ("Dash grants invincibility frames — use it to dodge through enemy attacks"), exploration tips ("Look for energy crystals in dark corners for free resources"), loot tips ("Higher dungeon floors drop better rarity items"), system tips ("Your items degrade slightly on death, but are never destroyed"), NPC tips ("Talking to NPCs regularly increases affinity and unlocks quests"), and meta tips ("The dungeon layout changes with each iteration"). Each tip should be 1-2 sentences, actionable, and not spoil late-game content. Store tips in a JSON or Resource file.
- **Acceptance Criteria:**
  - [ ] 25+ tips written across all categories
  - [ ] Tips are actionable and useful
  - [ ] No late-game spoilers
  - [ ] 1-2 sentences per tip
  - [ ] Tips stored in data file (JSON or Resource)
  - [ ] Tips cover combat, exploration, loot, and systems

### Task 43.12: Pause Menu Design
- **Status:** TODO
- **Description:** Design the pause menu that appears when the player presses ESC during gameplay. The pause menu should: darken and blur the game background (same treatment as inventory screen), display "PAUSED" in TITLE font at center-top, show menu options: Resume, Settings, Save (if in town), Inventory, Quest Log, Quit to Menu. Buttons use the same style as the main menu. The pause should happen instantly — no animation delay for the pause itself (the overlay can animate in, but gameplay must freeze immediately). Add a quick-stats display showing current health, compute, floor, and play time.
- **Acceptance Criteria:**
  - [ ] Dark blur overlay on game
  - [ ] "PAUSED" title display
  - [ ] Menu options: Resume, Settings, Save, Inventory, Quest Log, Quit
  - [ ] Instant game freeze (overlay animates)
  - [ ] Quick stats visible
  - [ ] Same button style as main menu

### Task 43.13: Menu Transitions Between Screens
- **Status:** TODO
- **Description:** Implement smooth transitions between menu screens (main menu -> settings, settings -> key bindings, etc.). Use a consistent transition: current screen slides out to the left (0.2s), new screen slides in from the right (0.2s). Back navigation: screen slides right. The 3D background (if applicable) should remain visible behind all menu screens — only the UI panel changes. Add a breadcrumb or back button in the top-left corner showing navigation path (Main Menu > Settings > Controls). The ESC key always goes back one level. All transitions should be interruptible (pressing a button during transition should queue the action, not get lost).
- **Acceptance Criteria:**
  - [ ] Consistent slide transition between screens
  - [ ] Forward slides left, back slides right
  - [ ] 3D background stays visible
  - [ ] Breadcrumb navigation path shown
  - [ ] ESC goes back one level
  - [ ] Transitions are interruptible

### Task 43.14: Confirmation Dialogs
- **Status:** TODO
- **Description:** Create a reusable confirmation dialog component for destructive actions: "Delete Save?", "Quit to Menu?", "Quit Game?". The dialog should: appear centered with a dark overlay behind it (separate from the menu overlay), show the warning message in BODY bold, show "Confirm" and "Cancel" buttons with the destructive action in red and the safe action pre-selected. Add a brief animation: dialog scales in from 0 to 100% (0.15s). For particularly destructive actions (Delete Save), add a delay: the Confirm button is grayed out for 2 seconds and shows a countdown, preventing accidental confirmation.
- **Acceptance Criteria:**
  - [ ] Reusable dialog component
  - [ ] Centered with dark overlay
  - [ ] Destructive action in red
  - [ ] Safe action pre-selected
  - [ ] Scale-in animation
  - [ ] Countdown delay for destructive actions

### Task 43.15: First-Time Player Experience
- **Status:** TODO
- **Description:** Create a polished first-time experience for new players launching the game. On first launch: show a brief splash screen with the studio/developer logo (2 seconds), then transition to the main menu with a slightly more dramatic title animation (full glitch resolve instead of quick version). The "New Game" button should pulse gently to draw attention (since "Continue" doesn't exist yet). After clicking New Game: show a brief intro sequence — the game title with a "Chapter 1: Awakening" subtitle, a short flavor text paragraph about Globbler awakening in the simulation, then fade into the game. This sets the narrative context before gameplay begins.
- **Acceptance Criteria:**
  - [ ] Developer splash screen on first launch
  - [ ] Extended title animation for first visit
  - [ ] "New Game" pulses when no save exists
  - [ ] Intro sequence with chapter title
  - [ ] Flavor text establishes narrative context
  - [ ] Fade into gameplay from intro

### Task 43.16: Menu Sound Design Hooks
- **Status:** TODO
- **Description:** Add audio hooks for all menu interactions (actual sounds in Epic 48-49). Emit EventBus signals: `menu_hover(button_name: String)` on button hover, `menu_select(button_name: String)` on button press, `menu_back()` on back navigation, `menu_open(screen_name: String)` on screen transition, `menu_setting_change(setting: String, value)` on any setting adjustment, `menu_confirm_dialog()` on dialog appearance, `menu_confirm_accept()` / `menu_confirm_cancel()` on dialog resolution. Each signal should include enough context for the audio system to play appropriate sounds (hover vs. select vs. back have different sound types).
- **Acceptance Criteria:**
  - [ ] Signals for hover, select, back, open
  - [ ] Setting change signals with context
  - [ ] Dialog signals for appear/accept/cancel
  - [ ] Signals include enough context for audio
  - [ ] All menu interactions have audio hooks
  - [ ] Signal naming follows project conventions

### Task 43.17: Controller Support and Navigation
- **Status:** TODO
- **Description:** Ensure all menu screens are fully navigable with a gamepad controller. D-pad/left stick moves between buttons and settings. A-button selects. B-button goes back. Start button pauses/unpauses. Bumpers switch tabs (in settings). Triggers adjust sliders. Show the correct button prompts: if the last input was keyboard, show keyboard keys; if controller, show controller buttons. Button prompts should swap dynamically when the input method changes. Test navigation through every screen and interaction with a controller. Ensure focus never gets "lost" (always some element is focused).
- **Acceptance Criteria:**
  - [ ] Full controller navigation on all screens
  - [ ] Dynamic button prompt swapping (keyboard/controller)
  - [ ] Bumpers switch tabs, triggers adjust sliders
  - [ ] B-button always goes back
  - [ ] Focus never lost (always an element selected)
  - [ ] All interactions testable with controller only

### Task 43.18: Menu Performance
- **Status:** TODO
- **Description:** Profile menu screen performance. The 3D main menu background must maintain 60fps while menus are rendering on top. Transitions must be smooth (no frame drops during slide animations). Settings visual preview must not cause stutter when changing graphics options. Save slot thumbnail loading must be asynchronous (don't freeze the menu while loading screenshots). Credit scroll must be smooth at all speeds. Target: 60fps on all menu screens at all times. If the 3D background is too expensive, fall back to a pre-rendered video or a simple animated 2D background.
- **Acceptance Criteria:**
  - [ ] 3D background maintains 60fps with UI overlay
  - [ ] Transitions are smooth (no frame drops)
  - [ ] Settings preview updates without stutter
  - [ ] Save thumbnails load asynchronously
  - [ ] Credits scroll smoothly
  - [ ] 60fps on all menu screens

### Task 43.19: Menu Visual Polish Pass
- **Status:** TODO
- **Description:** Final visual polish pass on all menu screens. Check: consistent spacing and alignment across all screens (grid-align text and widgets), consistent button sizes and styles, correct font presets used everywhere, hover/focus states visible on all interactive elements, no elements clipped by screen edges at any resolution (test 720p through 4K), loading states have feedback (no "frozen" screens), and the overall aesthetic feels cohesive and professional. Fix any visual inconsistencies found. The menus should feel like they belong to a commercial game, not a prototype.
- **Acceptance Criteria:**
  - [ ] Consistent spacing and alignment
  - [ ] All buttons same style and size
  - [ ] Correct font presets verified
  - [ ] Hover/focus states on all interactables
  - [ ] No clipping at 720p through 4K
  - [ ] Menus feel commercially polished

### Task 43.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture screenshots of all menu screens: main menu with 3D background, title animation sequence (3-4 frames), settings tabs, key binding screen, save slot screen, credits scroll, loading screen with tip, pause menu, and confirmation dialog. Save to `_bmad-output/visual-overhaul/screenshots/epic-43/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All menu screens captured
  - [ ] Title animation sequence shown
  - [ ] Settings with preview visible
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 39** (Custom Font) — Font for all menu text
- **Epic 40** (HUD Redesign) — Visual language for frames and buttons

## Notes

- The main menu is the first thing every player sees — it sets expectations for the entire game
- The title animation is the game's visual signature — make it memorable
- Settings screen is a quality signal — players judge game polish by settings options
- Save thumbnails are surprisingly impactful — they make save slots feel meaningful
- Loading screens are wasted time unless they teach the player something useful
