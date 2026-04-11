---
epic: 40
title: "HUD Redesign"
phase: 7 — UI/UX Overhaul
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 40: HUD Redesign

## Overview

Redesign the heads-up display with custom health/compute/XP bar sprites with sci-fi frames, create ability icon artwork, add a minimap with room layout, design damage number style with font and animation, create a buff/debuff icon set, add a compass/objective indicator, and design a boss health bar with portrait. The HUD is the player's constant companion and must be informative, beautiful, and unobtrusive.

## Success Criteria

- Custom bar sprites replace primitive rectangles for health, compute, and XP
- Sci-fi frame artwork surrounds each bar (consistent visual language)
- Ability icons are distinct and readable at small size (48x48)
- Minimap shows room layout and player position
- Damage numbers pop with personality (font, color, animation)
- Buff/debuff icons clearly communicate status effects
- Compass/objective indicator guides without hand-holding
- Boss health bar is dramatic and informative
- HUD takes less than 15% of screen real estate

---

## Tasks

### Task 40.1: HUD Layout Design and Wireframe
- **Status:** TODO
- **Description:** Design the complete HUD layout on paper/digitally before implementation. Place elements: health/compute bars (top-left, stacked vertically), XP bar (thin bar at screen bottom), ability icons (bottom-center, 4 module slots + prompt hotbar), minimap (top-right corner), buff/debuff icons (below health bars), damage numbers (floating in world space), compass/objective (top-center), boss health bar (top-center, appears only during boss fights, displaces compass). Create the wireframe at 1920x1080 resolution with exact pixel positions. Ensure total HUD coverage is under 15% of screen area. Reference Hades, Diablo, and Stardew Valley HUD layouts.
- **Acceptance Criteria:**
  - [ ] Complete HUD wireframe at 1920x1080
  - [ ] All elements positioned with pixel coordinates
  - [ ] Total HUD area under 15% of screen
  - [ ] Reference layouts from similar games collected
  - [ ] No element overlaps another
  - [ ] Layout tested at 720p and 1440p for scaling

### Task 40.2: Health Bar — Custom Frame Sprite
- **Status:** TODO
- **Description:** Design and paint the custom health bar frame sprite. Create a 256x48px frame image with a sci-fi border: angled ends (not rectangular — left end has a circuit-board angular cutout, right end tapers to a point), thin metallic border line with subtle inner glow, small circuit-trace decorative elements at the corners, a health icon (heart/shield symbol from Epic 39) integrated into the left end. The frame should have: an outer border layer (metallic), a fill area (where the health color fills from left to right), a background layer (dark when empty), and a glass/overlay layer (subtle scan line or noise for texture). Export as separate layers: frame, fill_mask, background, overlay.
- **Acceptance Criteria:**
  - [ ] Frame sprite at 256x48 with sci-fi design
  - [ ] Angled/non-rectangular bar shape
  - [ ] Health icon integrated into frame
  - [ ] Circuit-trace decorative elements
  - [ ] Exported as separate layers for fill masking
  - [ ] Metallic border with subtle glow

### Task 40.3: Compute Bar and XP Bar — Custom Frame Sprites
- **Status:** TODO
- **Description:** Design frame sprites for the compute bar and XP bar matching the health bar's visual language but with distinct identity. Compute bar (256x48): same angular shape as health bar but with compute icon (circuit/chip) on the left, different accent color in the frame trim (teal vs. health bar's red-tinted trim), and a digital readout-style overlay texture. XP bar (full screen width - margins, 16px tall): thin, elegant, minimal frame — a bottom-of-screen progress bar with tiny level indicator on the right end showing current level number, subtle milestone markers at quarter intervals. Both bars use the same metallic border style for visual family consistency.
- **Acceptance Criteria:**
  - [ ] Compute bar matches health bar style family
  - [ ] Compute bar has circuit/chip icon
  - [ ] XP bar spans screen width, thin and elegant
  - [ ] XP bar has level number indicator
  - [ ] XP bar has milestone markers
  - [ ] All bars share consistent metallic border style

### Task 40.4: Implement Bar Fill Shaders
- **Status:** TODO
- **Description:** Create shaders for the bar fill effect that goes beyond simple width scaling. Implement a bar fill shader (`res://shaders/ui_bar_fill.gdshader`) that: fills from left to right based on a `fill_amount` uniform (0.0-1.0), applies a gradient color across the fill (health: dark red at left to bright red at right, compute: dark teal to bright teal, XP: dark gold to bright gold), adds a subtle animated pulse along the fill edge (the leading edge of the bar shimmers), and shows a different color when the value is critically low (health < 25%: fill flashes red, compute < 15%: fill turns yellow). The fill should mask to the bar frame shape (not just a rectangle).
- **Acceptance Criteria:**
  - [ ] Fill shader with configurable fill_amount
  - [ ] Gradient color across the fill
  - [ ] Animated shimmer at fill edge
  - [ ] Critical low state with color flash
  - [ ] Fill masks to the bar's custom shape
  - [ ] Shader applies to all 3 bar types

### Task 40.5: Ability Icon Artwork
- **Status:** TODO
- **Description:** Create icon artwork for all module abilities and prompt items. Design a consistent icon style: 48x48 pixel art or painted icons with a dark background, colored foreground symbol, and thin metallic border. Create icons for: Data Pulse (blue pulse wave), Energy Burst (orange explosion), and all Module abilities (from the GDD — each module type needs a distinct icon). Create the prompt item icons: Health Prompt (red cross/heart), Compute Prompt (blue circuit). Each icon must be readable at 48px and identifiable at a glance during combat. Use a consistent 3-color palette per icon (dark, mid, bright).
- **Acceptance Criteria:**
  - [ ] All ability icons designed at 48x48
  - [ ] Consistent icon style across all abilities
  - [ ] Each icon identifiable at a glance
  - [ ] 3-color palette per icon
  - [ ] Health/Compute prompt icons clear
  - [ ] Icons readable during fast-paced combat

### Task 40.6: Ability Cooldown Visual
- **Status:** TODO
- **Description:** Implement a cooldown overlay for ability icons. When an ability is on cooldown: a dark semi-transparent overlay sweeps clockwise over the icon (like a clock hand revealing the icon as cooldown progresses), the remaining cooldown time displays in seconds (STAT_VALUE font, centered on the icon), and the icon border dims. When the ability becomes available: the overlay clears with a brief flash (bright border pulse for 0.3s), and the icon returns to full brightness. Create an AbilityIcon.gd script that takes `cooldown_max: float` and `cooldown_remaining: float` to drive the visual. The sweep should be smooth (updated every frame, not stepped).
- **Acceptance Criteria:**
  - [ ] Clockwise sweep cooldown overlay
  - [ ] Remaining time displayed in seconds
  - [ ] Icon border dims during cooldown
  - [ ] Flash pulse when ability becomes available
  - [ ] Smooth sweep animation (per-frame update)
  - [ ] AbilityIcon.gd provides clean API

### Task 40.7: Minimap — Base Design and Implementation
- **Status:** TODO
- **Description:** Design and implement a minimap in the top-right corner of the HUD. The minimap shows a simplified floor plan of the current dungeon floor: rooms as rectangles, connections as lines, current room highlighted, visited rooms filled, unvisited rooms outlined, boss room marked with a special icon. The minimap should be contained in a circular or rounded-rectangle frame (128x128 display size) with the same metallic sci-fi border as the health bars. The player's position is a bright dot. The minimap should rotate to match the player's facing direction or remain north-up (configurable). Create MiniMap.gd that receives room data from the dungeon system.
- **Acceptance Criteria:**
  - [ ] Minimap shows room layout and connections
  - [ ] Current room highlighted
  - [ ] Visited/unvisited rooms visually distinct
  - [ ] Boss room has special marker
  - [ ] Contained in sci-fi frame matching bar style
  - [ ] Player position dot visible

### Task 40.8: Minimap — Room Discovery and Animation
- **Status:** TODO
- **Description:** Animate the minimap as the player explores. When the player enters a new room: the room shape draws in on the minimap (lines drawing from edges inward), a brief ping pulse emanates from the new room on the minimap, and connections to adjacent rooms become visible. Rooms the player hasn't visited should show a fog-of-war effect (semi-transparent or question marks). If the player has a map item, all rooms are revealed but unvisited ones are dimmer. Add icons on the minimap for: loot rooms (gold dot), story rooms (blue dot), and the dungeon exit (white dot). The minimap should feel alive, not static.
- **Acceptance Criteria:**
  - [ ] New room draws in with animation
  - [ ] Ping pulse on room discovery
  - [ ] Fog-of-war on unvisited rooms
  - [ ] Map item reveals full layout
  - [ ] Room type icons (loot, story, exit)
  - [ ] Minimap feels dynamic and alive

### Task 40.9: Damage Number Design and Animation
- **Status:** TODO
- **Description:** Redesign damage numbers to be expressive and satisfying. Create a DamageNumber.gd scene that spawns floating text in world space. Normal damage: white DAMAGE_NUMBER font, pops up with slight random horizontal offset, arcs upward then falls with gravity, fades out over 0.8 seconds. Critical damage: larger font (1.5x), gold color, text bounces on spawn (scale from 0 to 1.3 to 1.0), screen shake trigger, "CRIT!" text briefly above the number. Heal numbers: green, float upward gently (no arc). Player damage taken: red, falls downward from the player. XP gain: small purple numbers near the XP bar. All numbers use tabular figures and have a thin dark outline for readability.
- **Acceptance Criteria:**
  - [ ] Normal damage: white, pop-up arc
  - [ ] Critical: gold, bounce, "CRIT!" text, bigger
  - [ ] Heal: green, gentle upward float
  - [ ] Player damage: red, downward
  - [ ] XP gain: purple, near XP bar
  - [ ] All numbers have dark outline for readability

### Task 40.10: Buff/Debuff Icon Set
- **Status:** TODO
- **Description:** Create icons for all status effects in the game (from the GDD): Corrupted (purple spiral), Fragmented (shattered diamond shape), Throttled (orange slow arrows), Overclocked (yellow lightning bolt), Segfault (red crash symbol). Design each at 32x32 with the same icon style as ability icons but with color-coded borders: green border = buff, red border = debuff. Add a duration indicator: a small circular timer on the icon that counts down (similar to ability cooldown sweep but smaller). Display buff/debuff icons in a horizontal row below the health/compute bars. Stack identical effects with a number badge.
- **Acceptance Criteria:**
  - [ ] All 5 status effect icons designed at 32x32
  - [ ] Color-coded borders (green buff, red debuff)
  - [ ] Duration countdown timer on each icon
  - [ ] Icons display below health/compute bars
  - [ ] Identical effects stack with number badge
  - [ ] Each icon instantly identifiable

### Task 40.11: Compass and Objective Indicator
- **Status:** TODO
- **Description:** Create a compass/objective indicator at the top-center of the screen. The compass is a thin horizontal bar (400px wide, 24px tall) showing cardinal directions (N/S/E/W) that scroll as the player rotates. Objective markers appear on the compass as colored diamonds pointing to their world position: gold diamond for main quest objective, blue for side quest, white for dungeon exit, red for boss room. When an objective is close (within 20m), an arrow also appears at screen edge pointing toward it. The compass frame matches the HUD metallic style. The compass only shows in the dungeon — in town it's replaced by a simpler direction hint.
- **Acceptance Criteria:**
  - [ ] Compass bar at top-center with cardinal directions
  - [ ] Direction markers scroll with player rotation
  - [ ] Colored objective diamonds on compass
  - [ ] Screen-edge arrows for nearby objectives
  - [ ] Compass frame matches HUD style
  - [ ] Compass in dungeon, simplified in town

### Task 40.12: Boss Health Bar Design
- **Status:** TODO
- **Description:** Design the boss health bar as a premium, dramatic version of the standard health bar (design from Epic 37 Task 37.12). The bar spans 60% of screen width at the top, with: ornate frame (more detailed than standard bars, with larger circuit-trace patterns and a menacing angular shape), boss name in TITLE font centered above, boss portrait or icon on the left end (64x64), phase divider marks at 66% and 33% with glowing accents, and a health fill that changes color per phase (green->amber->red). The frame should have a subtle animated border (pulsing circuit glow). When the bar first appears (boss intro), it slides in from the top with a dramatic animation.
- **Acceptance Criteria:**
  - [ ] 60% screen width with ornate frame
  - [ ] Boss name above in TITLE font
  - [ ] Boss portrait on left end
  - [ ] Phase divider marks with glow
  - [ ] Color changes per phase
  - [ ] Slide-in animation on appearance

### Task 40.13: HUD Show/Hide Animations
- **Status:** TODO
- **Description:** Add smooth show/hide animations for all HUD elements so they don't just pop in/out. When entering gameplay from a menu: HUD elements slide in from their nearest screen edge (bars from left, minimap from right, abilities from bottom, compass from top) with a staggered 0.1s delay per element. When opening a full-screen UI (inventory, quest log): HUD fades out (0.3s). When transitioning to a cutscene or dialogue: HUD slides out. Boss health bar slides down from top. Implement via a HUDAnimator.gd that provides `show_hud()`, `hide_hud()`, `show_boss_bar()`, `hide_boss_bar()`.
- **Acceptance Criteria:**
  - [ ] HUD elements slide in from screen edges
  - [ ] Staggered reveal timing (0.1s between elements)
  - [ ] HUD fades out for full-screen UI
  - [ ] HUD hides for cutscenes/dialogue
  - [ ] Boss bar slides from top
  - [ ] HUDAnimator.gd provides clean API

### Task 40.14: Low Health Warning Effects
- **Status:** TODO
- **Description:** Create visual warning effects when the player's health is critically low (below 25%). The health bar fill starts flashing red. A red vignette (semi-transparent red gradient at screen edges) pulses slowly (0.5Hz). The screen slightly desaturates (10% desaturation) to create an "in danger" atmosphere. An optional heartbeat visual pulse on the health bar (bar scale pulses slightly at heartbeat rhythm). These effects should be attention-grabbing without being distracting or obscuring gameplay — the player needs to see enemies even more clearly when at low health. Provide a setting to reduce or disable the screen effects.
- **Acceptance Criteria:**
  - [ ] Health bar flashes red below 25%
  - [ ] Red vignette pulses at screen edges
  - [ ] Slight desaturation for danger atmosphere
  - [ ] Heartbeat pulse on health bar
  - [ ] Effects don't obscure gameplay
  - [ ] Setting to reduce/disable screen effects

### Task 40.15: Prompt Hotbar Design
- **Status:** TODO
- **Description:** Redesign the prompt (consumable) hotbar that shows available health and compute prompts. Display as 2-4 slots at the bottom of the screen near the ability icons. Each slot shows: the prompt icon, quantity available (number badge), and the keybind (small text label). When a prompt is used: the icon plays a "use" animation (shrink and fade out, replaced by next item), a brief flash on the slot, and the quantity decrements. When prompts are depleted: the slot dims and shows an empty state with an "X" or "0". The hotbar frame matches the ability icon frames for visual consistency.
- **Acceptance Criteria:**
  - [ ] 2-4 prompt slots near ability icons
  - [ ] Prompt icon, quantity, and keybind visible
  - [ ] Use animation (shrink, fade, replace)
  - [ ] Depleted state clearly shows empty
  - [ ] Frame matches ability icon style
  - [ ] Quantity updates are immediate and smooth

### Task 40.16: HUD Scaling and Resolution Adaptation
- **Status:** TODO
- **Description:** Implement HUD scaling to handle different resolutions and player preferences. The HUD should scale based on a `hud_scale` setting (Small/Medium/Large/Extra Large, corresponding to 80%/100%/120%/150% scale). At each scale, verify: text remains readable, icons remain clear, no elements overlap, and the HUD doesn't exceed 20% of screen at the largest scale. Also implement resolution-based adaptation: at 720p, use the Medium preset minimum (Small would be too tiny); at 4K, use Large minimum. Anchor all HUD elements to screen edges with margin offsets that scale proportionally.
- **Acceptance Criteria:**
  - [ ] 4 scale settings (80%/100%/120%/150%)
  - [ ] Text readable at all scales
  - [ ] No element overlap at any scale
  - [ ] HUD under 20% screen at largest scale
  - [ ] Resolution-based minimum scale enforced
  - [ ] Edge anchoring with proportional margins

### Task 40.17: HUD Opacity and Fade Settings
- **Status:** TODO
- **Description:** Allow players to customize HUD opacity. Add a `hud_opacity` setting (50%-100% in 10% increments). At reduced opacity, HUD elements become semi-transparent, showing more of the game world underneath. When the player is in combat: HUD automatically increases to full opacity for critical information (health/compute bars, ability cooldowns). When the player is idle in a safe area: HUD fades to the user's setting (or lower, 30%, to enjoy the scenery). Minimap should have an independent opacity setting. Implement smooth transitions between opacity states (0.5s fade).
- **Acceptance Criteria:**
  - [ ] Opacity setting 50%-100%
  - [ ] Auto-increase during combat
  - [ ] Auto-decrease when idle in safe areas
  - [ ] Minimap has independent opacity
  - [ ] Smooth transitions between opacity states
  - [ ] HUD elements remain readable at 50%

### Task 40.18: HUD Sound Integration Hooks
- **Status:** TODO
- **Description:** Add audio hook signals for HUD events (actual sounds in Epic 49). Emit EventBus signals for: `hud_bar_low(bar_type: String)` when health/compute drops below threshold, `hud_bar_full(bar_type: String)` when restored to full, `hud_level_up(new_level: int)`, `hud_buff_applied(buff_id: String)`, `hud_buff_removed(buff_id: String)`, `hud_ability_ready(slot: int)`, `hud_item_used(slot: int)`, `hud_boss_bar_appear`, `hud_minimap_discover(room_id: String)`. These enable the audio system to play appropriate UI sounds synchronized with visual HUD changes.
- **Acceptance Criteria:**
  - [ ] EventBus signals for all HUD events
  - [ ] Signals emitted at correct timing
  - [ ] Bar type parameter for health/compute distinction
  - [ ] Level up signal with level number
  - [ ] All HUD interactions have audio hooks
  - [ ] Signals follow project conventions

### Task 40.19: Performance Profiling
- **Status:** TODO
- **Description:** Profile the HUD rendering performance in worst-case scenarios: all bars updating (health changing, compute regenerating, XP gaining), minimap updating with room discovery, 10+ damage numbers active simultaneously, all 4 ability cooldowns running, 5 buff/debuff icons active with countdowns, boss health bar visible and updating, compass updating with player rotation. Measure total HUD rendering cost. Target: under 1ms total. If over: optimize damage number pooling, reduce shader complexity on bars, batch minimap draw calls.
- **Acceptance Criteria:**
  - [ ] Worst-case HUD scenario profiled
  - [ ] Total HUD rendering under 1ms
  - [ ] Damage number pooling verified
  - [ ] No frame drops with maximum HUD elements
  - [ ] Performance documented
  - [ ] Optimizations applied if needed

### Task 40.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture before/after screenshots of the complete HUD in various states: idle exploration (minimal), active combat (all elements), boss fight (boss bar visible), low health warning, level up moment, minimap with explored floor, and buff/debuff display. Save to `_bmad-output/visual-overhaul/screenshots/epic-40/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] HUD shown in all major states
  - [ ] Before/after comparison clear
  - [ ] Boss health bar captured
  - [ ] Low health warning captured
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 39** (Custom Font) — Font for all HUD text

## Notes

- The HUD is seen 100% of the time — every pixel matters
- Less is more: hide elements when they're not needed (XP bar during combat, compass in town)
- Tabular figures from Epic 39 are critical for damage numbers and stat displays
- The health bar is the single most looked-at HUD element — invest the most design time here
- Test the HUD at the actual game's camera distance with actual gameplay, not in a UI editor
