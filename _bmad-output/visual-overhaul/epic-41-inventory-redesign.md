---
epic: 41
title: "Inventory Screen Redesign"
phase: 7 — UI/UX Overhaul
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 41: Inventory Screen Redesign

## Overview

Create item icon artwork for all item types (chips, modules, cores, protocols, prompts), design an inventory grid with rarity border colors, build an equipment paper doll silhouette, implement stat comparison tooltips, add drag-and-drop visual feedback, and create item rarity particle effects. The inventory is where players engage with the loot system and must feel satisfying to interact with.

## Success Criteria

- Unique icon artwork for each item type at 64x64
- Rarity border colors instantly communicate item tier
- Equipment paper doll shows equipped items visually
- Stat comparison tooltip shows green/red stat differences
- Drag-and-drop has smooth visual feedback (ghost icon follows cursor)
- Rarity particle effects make legendary items feel special
- Inventory screen is navigable and information-dense without feeling cluttered
- All interactions are responsive (under 50ms feedback)

---

## Tasks

### Task 41.1: Inventory Screen Layout Design
- **Status:** TODO
- **Description:** Design the complete inventory screen layout. Left panel (40% width): equipment paper doll showing Globbler's silhouette with equipment slots positioned on the body (4 module slots around the core, 1 core slot at center, 4 chip slots along the edge, 3 protocol slots on the side). Right panel (60% width): inventory grid (6 columns x variable rows, scrollable), with filter tabs above (All/Chips/Modules/Cores/Protocols/Prompts). Bottom: stat summary bar showing key stats. The overall frame should use the sci-fi theme with dark panel background, metallic borders, and circuit-trace accent lines. Create the wireframe at 1920x1080.
- **Acceptance Criteria:**
  - [ ] Complete layout wireframe at 1920x1080
  - [ ] Equipment panel with slot positions on silhouette
  - [ ] Inventory grid with filter tabs
  - [ ] Stat summary bar at bottom
  - [ ] Sci-fi frame design consistent with HUD
  - [ ] Layout tested for information density vs. clarity

### Task 41.2: Item Icon Artwork — Chips
- **Status:** TODO
- **Description:** Design icons for Chip items at 64x64. Chips are passive stat-boosting components that plug into Globbler. Design 4-6 chip variant icons: Processing Chip (CPU die with pins, warm orange), Bandwidth Chip (arrow/wave pattern, blue), Memory Chip (grid/matrix pattern, green), Integrity Chip (shield/armor plate, gray), and combo/special chips. Each icon should have: a dark background, the chip shape/symbol in the center, a subtle glow matching the chip's stat color, and space for a rarity border. Icons should be distinct at a glance — the player should identify chip type from the icon shape alone, not just color.
- **Acceptance Criteria:**
  - [ ] 4-6 chip icons at 64x64
  - [ ] Each chip type has unique shape/symbol
  - [ ] Color matches stat association
  - [ ] Icons distinct at a glance
  - [ ] Space left for rarity border overlay
  - [ ] Consistent style across all chip icons

### Task 41.3: Item Icon Artwork — Modules
- **Status:** TODO
- **Description:** Design icons for Module items at 64x64. Modules are active ability components. Design icons for each module type from the GDD: offensive modules (weapon shapes — blade, cannon, blast), defensive modules (shield shapes — barrier, absorb), utility modules (movement shapes — dash trail, teleport rings), and support modules (heal shapes — pulse cross, regeneration spiral). Each icon should suggest the ability's effect through shape and color. Offensive = red/orange tones, Defensive = blue, Utility = yellow/white, Support = green. Icons must communicate what the module DOES.
- **Acceptance Criteria:**
  - [ ] Icons for all module types from the GDD
  - [ ] Shape suggests the ability's effect
  - [ ] Color-coded by module category
  - [ ] Distinct from chip icons in visual language
  - [ ] Readable at 64x64
  - [ ] Consistent style across all module icons

### Task 41.4: Item Icon Artwork — Cores, Protocols, Prompts
- **Status:** TODO
- **Description:** Design icons for the remaining item types at 64x64. Cores (equipped for global bonuses): geometric core shapes (hexagon, octagon, sphere) with internal energy pattern, varying by core type. Protocols (passive set bonuses): scroll/document shapes with encoded symbols, tech-manuscript aesthetic. Prompts (consumables): health prompt = red potion/capsule with + symbol, compute prompt = blue vial/battery with circuit symbol, other prompts = appropriate symbols. Each item category should be immediately distinguishable by silhouette shape even without color.
- **Acceptance Criteria:**
  - [ ] Core icons with geometric shapes
  - [ ] Protocol icons with document/scroll shapes
  - [ ] Prompt icons with consumable shapes
  - [ ] Categories distinguishable by silhouette
  - [ ] All icons at 64x64
  - [ ] Complete icon set covers all items in the GDD

### Task 41.5: Rarity Border System
- **Status:** TODO
- **Description:** Implement a rarity border overlay system for item icons. Create 4 border frame sprites at 72x72 (slightly larger than the 64x64 icon, providing an 4px border on each side): Common = thin gray (#808080) simple line, Uncommon = green (#40C040) line with slight glow, Rare = blue (#4080FF) line with corner accents and glow, Legendary = gold (#FFD040) ornate frame with animated shimmer. The borders should overlay on top of any item icon. Create a reusable ItemIcon.tscn scene that takes an icon texture and rarity enum and composites the correct border. Rarity should be identifiable at inventory grid distance.
- **Acceptance Criteria:**
  - [ ] 4 border sprites (Common/Uncommon/Rare/Legendary)
  - [ ] Visual hierarchy clear (Legendary most ornate)
  - [ ] Borders overlay correctly on any 64x64 icon
  - [ ] Legendary border has animated shimmer
  - [ ] ItemIcon.tscn composites icon + border
  - [ ] Rarity identifiable at inventory grid zoom

### Task 41.6: Equipment Paper Doll Silhouette
- **Status:** TODO
- **Description:** Create the equipment paper doll display for the left panel. Design a front-facing Globbler silhouette (dark outline on the panel background) at approximately 256x384. Position equipment slot markers on the silhouette: 4 module slots arranged around the core area (top, bottom, left, right), 1 core slot at the center chest, 4 chip slots along the outer edge (shoulders, hips), 3 protocol slots on the right side (stacked vertically). Each slot shows the equipped item's icon (scaled to 48x48) or an empty slot marker (dashed outline showing the slot shape). Connected lines from slot to the body position show where the item "installs."
- **Acceptance Criteria:**
  - [ ] Globbler silhouette designed
  - [ ] All equipment slots positioned on the body
  - [ ] Equipped items show their icons in slots
  - [ ] Empty slots show dashed outlines
  - [ ] Connection lines from slot to body position
  - [ ] Paper doll fits in left 40% of screen

### Task 41.7: Stat Comparison Tooltip
- **Status:** TODO
- **Description:** Implement a stat comparison tooltip that appears when hovering over an item while a similar item is equipped. The tooltip shows: item name (colored by rarity), item type and slot, item stats listed with current values, and for each stat — a comparison arrow showing green upward arrow and positive delta if the new item is better, red downward arrow and negative delta if worse, or gray dash if equal. Format: "Processing: 15 (+3 ^)" in green or "Bandwidth: 8 (-2 v)" in red. Include the item's description text and any special effects. The tooltip should appear next to the cursor and never go off-screen (flip direction at screen edges).
- **Acceptance Criteria:**
  - [ ] Tooltip shows item name colored by rarity
  - [ ] Stats listed with green/red comparison deltas
  - [ ] Up/down arrows indicate improvement/downgrade
  - [ ] Item description and special effects shown
  - [ ] Tooltip follows cursor, flips at screen edges
  - [ ] Tabular figures align stat numbers

### Task 41.8: Inventory Grid Implementation
- **Status:** TODO
- **Description:** Implement the inventory grid as a scrollable GridContainer. Each cell is a 72x72 area (64x64 icon + 4px rarity border). The grid shows 6 columns with rows auto-generated based on item count. Items are displayed using the ItemIcon.tscn from Task 41.5. Filter tabs above the grid: "All" shows everything, category tabs show only that item type. Implement sorting: by rarity (highest first), by type, by name (alphabetical), by recently acquired. A "sort" button cycles through sort modes. Empty cells show a faint grid outline. The grid should scroll smoothly with a scroll bar matching the UI theme.
- **Acceptance Criteria:**
  - [ ] 6-column scrollable grid
  - [ ] Items shown with icon + rarity border
  - [ ] Filter tabs work for all item categories
  - [ ] Sort modes: rarity, type, name, recent
  - [ ] Empty cells show faint grid outline
  - [ ] Smooth scrolling with themed scrollbar

### Task 41.9: Drag-and-Drop Visual Feedback
- **Status:** TODO
- **Description:** Implement drag-and-drop for equipping items with polished visual feedback. When the player clicks and holds an item: the item icon "lifts" from the grid (scale up to 110%, add drop shadow), a ghost copy follows the cursor with slight transparency (80% opacity), the original grid slot shows a dimmed placeholder. When dragging over a valid equipment slot: the slot highlights with a green glow border. When dragging over an invalid slot: the slot shows a red flash. On drop: the item slides into the slot position with a brief scale bounce (1.0 -> 1.2 -> 1.0 over 0.2s). On drop in an occupied slot: the items swap with a cross-slide animation. On drop outside valid areas: item returns to original position with a snap-back animation.
- **Acceptance Criteria:**
  - [ ] Item lifts with scale and shadow on grab
  - [ ] Ghost copy follows cursor
  - [ ] Valid slots glow green on hover
  - [ ] Invalid slots flash red on hover
  - [ ] Drop animation with scale bounce
  - [ ] Swap animation for occupied slots

### Task 41.10: Item Rarity Particle Effects
- **Status:** TODO
- **Description:** Add subtle particle effects to items in the inventory based on rarity. Common items: no particles (static icon). Uncommon: occasional faint green sparkle (1 particle per 2 seconds, tiny). Rare: blue shimmer particles at the icon border (2-3 particles per second, small stars). Legendary: continuous gold particle swirl around the icon (5-6 particles, orbiting, bright, sparkle trail). The particles should be subtle enough to not make the inventory grid chaotic when full of varied rarity items. Legendary particles should make those items immediately eye-catching. Use CanvasItem particles (CPUParticles2D) at low counts for efficiency.
- **Acceptance Criteria:**
  - [ ] No particles on Common items
  - [ ] Faint sparkle on Uncommon
  - [ ] Blue shimmer on Rare
  - [ ] Gold swirl on Legendary
  - [ ] Particles don't make the grid chaotic
  - [ ] Legendary items are immediately eye-catching

### Task 41.11: Quick-Equip and Quick-Sell Actions
- **Status:** TODO
- **Description:** Add visual feedback for quick-equip (double-click or shortcut key) and quick-sell (shift-click or shortcut key) actions. Quick-equip: item icon slides from inventory grid to the appropriate equipment slot on the paper doll, the slot flashes on receive, and the previously equipped item (if any) slides back to the inventory grid. Quick-sell: item icon shrinks with a coin/scrap particle burst, a small "+[value]" text floats up in gold, and the grid slot empties. For bulk sell: selected items highlight with a sell border, pressing confirm triggers sequential sell animations (0.1s stagger per item).
- **Acceptance Criteria:**
  - [ ] Quick-equip slides item to equipment slot
  - [ ] Slot flashes on receive
  - [ ] Swapped items slide back to grid
  - [ ] Quick-sell shrinks with coin particles
  - [ ] "+value" text floats on sell
  - [ ] Bulk sell has staggered animation

### Task 41.12: Item Detail Panel
- **Status:** TODO
- **Description:** Create a detailed item information panel that expands when an item is selected (clicked once). The panel appears between the paper doll and the grid (or overlays one of them) showing: large icon (128x128), item name in rarity-colored SUBTITLE font, item type and slot, flavor text in BODY_SMALL italic, all stats in a formatted list, comparison with currently equipped item (if applicable), special effects/affixes listed with descriptions, and action buttons (Equip, Sell, Lock). The panel should slide in from the side with a smooth animation and have a close button or dismiss on clicking elsewhere.
- **Acceptance Criteria:**
  - [ ] Large icon display (128x128)
  - [ ] Full stat list with formatting
  - [ ] Flavor text in italic
  - [ ] Comparison with equipped item
  - [ ] Action buttons (Equip, Sell, Lock)
  - [ ] Slide-in animation

### Task 41.13: New Item Notification Badge
- **Status:** TODO
- **Description:** Add a "NEW" badge to recently acquired items that the player hasn't viewed yet. The badge is a small (20x12) bright yellow tab with "NEW" text in the corner of the item icon. The badge pulses subtly (opacity 0.8 to 1.0, 0.5Hz) to draw attention. When the player hovers over or selects the item, the "NEW" badge fades out (0.3s). If multiple new items are acquired (after a dungeon run), the inventory icon in the HUD also shows a notification badge with a count. Items are marked as "viewed" when the tooltip or detail panel has been opened for that item.
- **Acceptance Criteria:**
  - [ ] "NEW" badge on unviewed items
  - [ ] Badge pulses subtly
  - [ ] Badge fades on item hover/selection
  - [ ] HUD inventory icon shows new item count
  - [ ] Items marked viewed on tooltip/detail open
  - [ ] Badge is visible but not distracting

### Task 41.14: Inventory Background and Frame Art
- **Status:** TODO
- **Description:** Create the inventory screen background and frame art. The background should be a dark semi-transparent panel (#1A2030 at 90% opacity) that overlays the game world (the game is still visible behind the inventory but darkened). The frame should have: metallic border matching the HUD bar style, circuit-trace accent lines running along the panel edges, a header bar with the screen title "INVENTORY" in SUBTITLE font, and subtle corner accents (small decorative elements at each corner). The paper doll panel should have a slightly different background tint (marginally lighter) to differentiate from the grid panel.
- **Acceptance Criteria:**
  - [ ] Dark semi-transparent background
  - [ ] Game visible behind (darkened)
  - [ ] Metallic frame border matching HUD
  - [ ] Circuit-trace accent lines
  - [ ] Header bar with title
  - [ ] Paper doll panel subtly differentiated

### Task 41.15: Inventory Open/Close Animation
- **Status:** TODO
- **Description:** Create smooth open and close animations for the inventory screen. Open: the dark overlay fades in (0.2s), the inventory panel scales in from center (0 to 100% scale, 0.3s ease-out), followed by a brief flash on the border (metallic gleam). Close: panel scales down to 80% while fading (0.2s), overlay fades out. While the inventory is open, the game world should blur slightly (apply a gaussian blur to the viewport behind the UI) and game time should slow to 10% (not paused — ambient animations still play slowly). Opening should feel snappy; closing should feel seamless.
- **Acceptance Criteria:**
  - [ ] Scale-in animation on open
  - [ ] Metallic gleam flash on complete
  - [ ] Scale-and-fade on close
  - [ ] Background game world blurs
  - [ ] Game time slows (not paused)
  - [ ] Animations feel snappy and responsive

### Task 41.16: Empty Inventory State
- **Status:** TODO
- **Description:** Design the empty inventory state for when the player has no items (game start, before first loot). Instead of a blank grid, show: a centered message "No items in inventory" in BODY font, a hint "Explore the dungeon to find loot" in BODY_SMALL, and a subtle animation (circuit-trace pattern drawing itself across the empty grid area, like the system is waiting). The paper doll should show all slots empty with dashed outlines and small "?" icons. This state should feel expectant, not empty — like the inventory is ready and waiting to be filled.
- **Acceptance Criteria:**
  - [ ] Centered message for empty inventory
  - [ ] Hint text suggesting where to find items
  - [ ] Animated circuit pattern in empty grid
  - [ ] Paper doll shows empty slots with "?" icons
  - [ ] State feels expectant, not broken
  - [ ] Transition to filled state is seamless

### Task 41.17: Item Lock and Favorites
- **Status:** TODO
- **Description:** Implement visual indicators for locked and favorited items. Locked items (can't be sold or recycled): show a small padlock icon (16x16) in the top-left corner of the item icon. The lock icon should be clearly visible but not obscure the item icon. Favorited items: show a small star icon (16x16) in the top-right corner, in gold. When locking: the padlock icon slides in with a click animation. When favoriting: the star icon pops in with a sparkle. The grid sort should support sorting favorites to the top. Locked and favorited states persist in save data.
- **Acceptance Criteria:**
  - [ ] Lock icon in top-left corner
  - [ ] Favorite star in top-right corner
  - [ ] Animation for lock/unlock toggle
  - [ ] Animation for favorite/unfavorite toggle
  - [ ] Sort by favorites supported
  - [ ] States persist in save data

### Task 41.18: Keyboard/Controller Navigation
- **Status:** TODO
- **Description:** Implement full keyboard and controller navigation for the inventory. Arrow keys/D-pad move selection between grid cells and equipment slots. A highlight border (bright white, 2px) shows the currently selected cell. Tab/bumper switches between filter tabs. Enter/A-button opens item detail. Shift+Enter/Y-button quick-equips. The selection should wrap at grid edges. Moving from the grid to the paper doll (left) should snap to the nearest equipment slot. All interactions available via mouse should also be available via keyboard/controller with equivalent visual feedback.
- **Acceptance Criteria:**
  - [ ] Arrow/D-pad navigation between cells
  - [ ] Selection highlight clearly visible
  - [ ] Tab/bumper switches filters
  - [ ] Enter/A opens detail, Shift/Y quick-equips
  - [ ] Grid wrapping at edges
  - [ ] All mouse actions available via keyboard

### Task 41.19: Performance with Full Inventory
- **Status:** TODO
- **Description:** Profile inventory screen performance with a full inventory (100+ items). Measure: grid render time with all icons + rarity borders + particles, tooltip render time, drag-and-drop frame rate, and scroll performance. The inventory must maintain 60fps even with 100 items rendered with rarity particles. If performance is an issue: virtualize the grid (only render visible rows + 1 buffer row), reduce particle counts, batch icon rendering, or disable particles on off-screen items.
- **Acceptance Criteria:**
  - [ ] 100+ items profiled in grid
  - [ ] 60fps maintained with full inventory
  - [ ] Scroll performance is smooth
  - [ ] Tooltip appears without lag
  - [ ] Drag-and-drop doesn't drop frames
  - [ ] Optimizations documented if applied

### Task 41.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture before/after screenshots: empty state, grid with mixed rarity items, equipment paper doll with items equipped, stat comparison tooltip, drag-and-drop in progress, item detail panel, legendary item with particles. Save to `_bmad-output/visual-overhaul/screenshots/epic-41/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All inventory states captured
  - [ ] Rarity visual hierarchy clear in screenshots
  - [ ] Tooltip and detail panel shown
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 39** (Custom Font) — Font for all inventory text
- **Epic 40** (HUD Redesign) — Visual language for frames and borders

## Notes

- The inventory is where the loot system pays off emotionally — it must feel satisfying
- Legendary items should make the player excited when they see them in the grid
- Stat comparison is the #1 QoL feature for loot games — invest time in making it clear
- Drag-and-drop responsiveness matters more than flashy animations — 50ms or less
- Test with 100+ items including mixed rarities to ensure the grid doesn't become overwhelming
