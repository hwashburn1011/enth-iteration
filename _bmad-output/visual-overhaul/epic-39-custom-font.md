---
epic: 39
title: "Custom Game Font"
phase: 7 — UI/UX Overhaul
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 39: Custom Game Font

## Overview

Source or create a sci-fi themed font family for the game, implement as Godot FontFile resources, apply to all 11 UI screens, create bold/light/italic variants, ensure readability at all sizes, configure number font with tabular figures for consistent stat display, and create custom glyphs for game-specific symbols (compute icon, health icon, XP icon). The font is the foundation of the entire UI visual identity.

## Success Criteria

- Primary font selected/created that reads as sci-fi/digital without sacrificing legibility
- Regular, Bold, Light, and Italic weights available
- Font renders crisply at sizes 12px through 48px
- Numbers use tabular (monospaced) figures for aligned stat columns
- Custom game symbols integrated as font glyphs or icon font
- Font applied consistently across all 11 UI screens
- Font supports all needed characters (Latin, numbers, punctuation, special)
- Loading and rendering performance unaffected by custom font

---

## Tasks

### Task 39.1: Font Research and Selection
- **Status:** TODO
- **Description:** Research sci-fi themed fonts that balance the digital/tech aesthetic with strong readability. Evaluate candidates across criteria: (1) Readability at small sizes (12-14px for stat numbers, tooltips), (2) Distinctive character at large sizes (32-48px for titles), (3) Geometric/tech feel without being "gimmicky", (4) Available weights (regular, bold, light minimum), (5) License compatibility (OFL/Apache/similar for game distribution), (6) Unicode coverage (Latin, numbers, basic punctuation). Top candidates to evaluate: Rajdhani, Exo 2, Orbitron, Share Tech, Jura, Quantico, Michroma. Select one primary font and one accent font (for titles/headers if the primary is too plain at large sizes). Document the selection with rationale.
- **Acceptance Criteria:**
  - [ ] 5+ font candidates evaluated
  - [ ] Readability tested at 12px, 24px, and 48px
  - [ ] License verified as game-distribution compatible
  - [ ] Primary font selected with rationale
  - [ ] Optional accent font selected for titles
  - [ ] Weight availability confirmed (regular, bold, light, italic)

### Task 39.2: Acquire Font Files and Organize
- **Status:** TODO
- **Description:** Download the selected font family files (.ttf or .otf). Organize into the project directory: `res://assets/fonts/` with subdirectories per weight: `primary_regular.ttf`, `primary_bold.ttf`, `primary_light.ttf`, `primary_italic.ttf`, `primary_bold_italic.ttf`. If an accent font was selected, add those as well: `accent_regular.ttf`, `accent_bold.ttf`. Include the license file in the fonts directory. Verify all font files open correctly in a font viewer and contain the expected character set.
- **Acceptance Criteria:**
  - [ ] All font weight files downloaded
  - [ ] Files organized in res://assets/fonts/
  - [ ] License file included
  - [ ] All files open correctly in font viewer
  - [ ] Character set coverage verified
  - [ ] File naming convention followed

### Task 39.3: Create Godot FontFile Resources
- **Status:** TODO
- **Description:** Import each font file into Godot as a FontFile resource. For each weight, create a .tres FontFile resource with appropriate settings: set hinting to Light (best for screen rendering), set antialiasing to Grayscale (or LCD for sharper text on known display types), configure MSDF rendering for fonts that will be used at multiple sizes (creates resolution-independent rendering), and set subpixel_positioning for small text sizes. Create named resources: `font_primary_regular.tres`, `font_primary_bold.tres`, etc. Test each resource in a Label node to verify rendering quality.
- **Acceptance Criteria:**
  - [ ] FontFile .tres created for each weight
  - [ ] Hinting set to Light for screen clarity
  - [ ] MSDF enabled for scalable rendering
  - [ ] Subpixel positioning configured for small sizes
  - [ ] Each resource tested in a Label node
  - [ ] Rendering is crisp at all target sizes

### Task 39.4: Configure Tabular (Monospaced) Figures
- **Status:** TODO
- **Description:** Configure the font to use tabular (monospaced) figures for numbers so that stat columns, health values, and damage numbers align properly. If the selected font supports OpenType features, enable the `tnum` (tabular numbers) feature in Godot's FontFile settings. If the font doesn't support tabular figures natively, create a separate number-only font resource with fixed-width overrides. Test by displaying numbers in a column: verify "111" and "999" take the same width, decimal points align, and negative numbers don't shift the column. This is critical for the inventory stat comparison tooltip and the character stat screen.
- **Acceptance Criteria:**
  - [ ] Tabular figures enabled (all digits same width)
  - [ ] "111" and "999" take identical horizontal space
  - [ ] Decimal points align in number columns
  - [ ] Negative numbers don't shift alignment
  - [ ] Tested in stat display and inventory contexts
  - [ ] Separate number font resource if needed

### Task 39.5: Design Custom Game Symbol Glyphs
- **Status:** TODO
- **Description:** Design custom glyphs/icons for game-specific symbols that will appear inline with text: Health icon (heart or shield shape in the game's style), Compute icon (circuit/chip shape), XP icon (star or level-up arrow), currency/material icons (scrap, core, module), stat icons (Processing = CPU, Bandwidth = arrow, Memory = chip, Integrity = shield). Design each at 64x64 pixel canvas with clean vector-like outlines that match the font's style weight. These will be used inline in UI text (e.g., "Health: [heart] 150/200") and in tooltips and descriptions.
- **Acceptance Criteria:**
  - [ ] Health, Compute, XP icons designed
  - [ ] Currency/material icons designed
  - [ ] 4 stat icons designed (Processing, Bandwidth, Memory, Integrity)
  - [ ] All icons match the font's visual style
  - [ ] Icons readable at 16px display size
  - [ ] Clean vector-like outlines

### Task 39.6: Implement Icon Font or Texture Atlas for Symbols
- **Status:** TODO
- **Description:** Implement the custom game symbols so they can be used inline with text. Option A: Create an icon font (add glyphs to a custom font file using FontForge or similar, mapped to Unicode Private Use Area) so icons render as font characters. Option B: Create a small texture atlas of icon sprites and use Godot's RichTextLabel BBCode `[img]` tag to insert them inline. Evaluate both approaches: icon font is cleaner for simple icons, texture atlas is better for colored/detailed icons. Implement the chosen approach and create a helper function `get_icon_bbcode(icon_name: String) -> String` that returns the correct BBCode for any game icon.
- **Acceptance Criteria:**
  - [ ] Icon rendering approach chosen and implemented
  - [ ] All game symbols renderable inline with text
  - [ ] Icons align correctly with text baseline
  - [ ] Icons scale with font size
  - [ ] Helper function provides easy access
  - [ ] Icons look good at all UI text sizes

### Task 39.7: Create Font Size Presets
- **Status:** TODO
- **Description:** Define standardized font size presets for the entire game UI. Create a FontSizes autoload or resource that defines: `TITLE` (42px bold, for screen headers), `SUBTITLE` (28px regular, for section headers), `BODY` (18px regular, for descriptions and dialogue), `BODY_SMALL` (14px regular, for tooltips and secondary info), `STAT_VALUE` (20px bold tabular, for stat numbers), `STAT_LABEL` (14px light, for stat labels), `DAMAGE_NUMBER` (24px bold, for floating damage), `BUTTON` (18px bold, for button labels), `HUD` (16px bold, for HUD elements), `TINY` (12px light, for fine print). Document each preset with its intended use.
- **Acceptance Criteria:**
  - [ ] 10+ font size presets defined
  - [ ] Each preset specifies size, weight, and use case
  - [ ] Presets accessible from a centralized resource/autoload
  - [ ] All sizes tested for readability
  - [ ] Presets documented with intended use
  - [ ] No UI text should use an ad-hoc size (always use a preset)

### Task 39.8: Create Game Theme Resource with Font Settings
- **Status:** TODO
- **Description:** Create a Godot Theme resource (`res://assets/themes/game_theme.tres`) that defines the font for all Control node types. Set: Label default_font to primary_regular, Button default_font to primary_bold, LineEdit/TextEdit to primary_regular, RichTextLabel to primary_regular with bold/italic variants, TabContainer headers to primary_bold, tooltip text to primary_regular at BODY_SMALL size. Configure the theme's default_font_size, bold_font, italic_font, and bold_italic_font. Apply this theme at the root viewport level so all UI automatically inherits it.
- **Acceptance Criteria:**
  - [ ] Theme resource created with all font assignments
  - [ ] All Control types have appropriate font weights
  - [ ] Bold and italic variants assigned for RichTextLabel
  - [ ] Theme applied at root viewport level
  - [ ] All existing UI inherits the new font
  - [ ] No Control node uses the default Godot font

### Task 39.9: Apply Font to HUD Screen
- **Status:** TODO
- **Description:** Apply the custom font to the HUD (health bar, compute bar, XP bar, module cooldowns, prompt hotbar). Set health/compute values to STAT_VALUE preset (bold tabular). Set bar labels to STAT_LABEL. Set damage numbers to DAMAGE_NUMBER preset. Set cooldown timers to HUD preset. Verify: numbers don't shift when values change (tabular figures), text is readable against all background conditions (dark dungeon, bright town, combat red), and text doesn't overlap bar graphics. Add a subtle text outline or shadow (1px dark outline) for readability on variable backgrounds.
- **Acceptance Criteria:**
  - [ ] HUD text uses correct font presets
  - [ ] Numbers don't shift on value change (tabular)
  - [ ] Text readable on all backgrounds
  - [ ] Text outline/shadow for readability
  - [ ] No text-graphic overlap
  - [ ] HUD feels cohesive with new font

### Task 39.10: Apply Font to Inventory Screen
- **Status:** TODO
- **Description:** Apply the custom font to the inventory screen: item names (BODY bold), item descriptions (BODY), stat values (STAT_VALUE tabular), stat labels (STAT_LABEL), rarity text (BODY bold, colored by rarity), quantity numbers (STAT_VALUE), and tooltip text (BODY_SMALL). Verify stat comparison columns align properly with tabular figures. Test with the longest item name and description to ensure no overflow. Adjust text container sizes if the new font has different metrics than the placeholder font.
- **Acceptance Criteria:**
  - [ ] All inventory text uses correct presets
  - [ ] Stat columns align with tabular figures
  - [ ] Longest item name/description doesn't overflow
  - [ ] Rarity text colored appropriately
  - [ ] Tooltip text readable at BODY_SMALL size
  - [ ] Container sizes adjusted for new font metrics

### Task 39.11: Apply Font to Dialogue System
- **Status:** TODO
- **Description:** Apply the custom font to the dialogue system: speaker name (SUBTITLE bold, colored by character), dialogue text (BODY regular), choice options (BODY bold), system text / narration (BODY_SMALL italic). Verify the text reveal animation (character-by-character) works with the new font metrics. Test line wrapping with the new font at various dialogue box widths. Ensure the font supports any special characters used in dialogue (em dashes, ellipsis, quotation marks). Adjust the dialogue box size if the new font is wider or taller than the placeholder.
- **Acceptance Criteria:**
  - [ ] Speaker name in SUBTITLE bold
  - [ ] Dialogue text in BODY regular
  - [ ] Choice options in BODY bold
  - [ ] Text reveal animation works correctly
  - [ ] Line wrapping tested at dialogue box width
  - [ ] Special characters render correctly

### Task 39.12: Apply Font to Menu Screens
- **Status:** TODO
- **Description:** Apply the custom font to all menu screens: Main Menu (game title in TITLE using accent font if available, menu options in BUTTON), Settings (section headers in SUBTITLE, option labels in BODY, value display in STAT_VALUE), Save/Load (slot name in BODY bold, metadata in BODY_SMALL), Credits (names in BODY, roles in BODY_SMALL italic), Pause Menu (options in BUTTON). Verify text alignment and spacing on each screen. The accent font (if selected) should be used only for the game title and major screen headers — not for body text.
- **Acceptance Criteria:**
  - [ ] Main Menu uses accent font for title
  - [ ] All menu options use BUTTON preset
  - [ ] Settings screen formatted with correct presets
  - [ ] Save/Load screen formatted correctly
  - [ ] Credits screen formatted correctly
  - [ ] Text alignment correct on all screens

### Task 39.13: Apply Font to Remaining UI Screens
- **Status:** TODO
- **Description:** Apply the custom font to all remaining UI screens not covered above: Character Stats screen (stat names in STAT_LABEL, stat values in STAT_VALUE, stat point allocation buttons in BUTTON), Quest Log (quest titles in BODY bold, descriptions in BODY, objectives in BODY_SMALL), NPC Affinity display (NPC names in BODY bold, affinity values in STAT_VALUE), and any notification/toast messages (BODY_SMALL bold). Verify every single UI screen in the game uses the custom font — no screen should show the default Godot font.
- **Acceptance Criteria:**
  - [ ] Character Stats screen formatted
  - [ ] Quest Log formatted
  - [ ] NPC Affinity display formatted
  - [ ] Notification messages formatted
  - [ ] ZERO instances of default Godot font remain
  - [ ] Every UI screen verified

### Task 39.14: Readability Testing at All Sizes
- **Status:** TODO
- **Description:** Conduct a comprehensive readability test of the custom font at every size used in the game. Test at target resolution (1080p) and at lower resolutions (720p). For each font size preset: verify individual characters are distinguishable (especially 1/l/I, 0/O, 5/S at small sizes), text blocks are comfortable to read (not too tight, not too loose in line spacing), numbers are clearly distinct, and the font doesn't become blurry or aliased at any size. If any size fails readability: adjust the size (±2px), switch to a different weight, or increase line spacing. Document passing sizes.
- **Acceptance Criteria:**
  - [ ] All size presets tested at 1080p
  - [ ] All size presets tested at 720p
  - [ ] Confusable characters distinguishable (1/l/I, 0/O)
  - [ ] Text blocks comfortable to read
  - [ ] Numbers clearly distinct at all sizes
  - [ ] Problematic sizes adjusted or weight-swapped

### Task 39.15: Color and Contrast Compliance
- **Status:** TODO
- **Description:** Verify all text meets WCAG AA contrast ratio (4.5:1 for body text, 3:1 for large text) against their backgrounds. Check: white text on dark HUD bars, text on semi-transparent tooltip backgrounds, dialogue text on dialogue box background, stat text on inventory panel, menu text on menu background, damage numbers floating over dungeon environment, buff/debuff text on the HUD. For any failing combinations: darken the background, add text shadow/outline, or adjust text color. Create a contrast ratio report for each text context.
- **Acceptance Criteria:**
  - [ ] All text meets WCAG AA contrast ratio
  - [ ] Body text: 4.5:1 or higher
  - [ ] Large text: 3:1 or higher
  - [ ] Text shadows/outlines added where needed
  - [ ] Contrast report created for each text context
  - [ ] No text is hard to read on its background

### Task 39.16: Localization Character Set Verification
- **Status:** TODO
- **Description:** Verify the font supports characters needed for potential future localization. Test rendering of: accented Latin characters (e, u, o, a, etc. for French, Spanish, German, Portuguese), em dashes, curly quotes, ellipsis character, copyright symbol, degree symbol, multiplication sign, and any game-specific special characters. If any needed characters are missing: find a compatible fallback font for those characters and configure Godot's font fallback chain. This future-proofs the font choice for localization.
- **Acceptance Criteria:**
  - [ ] Accented Latin characters render correctly
  - [ ] Special punctuation renders correctly
  - [ ] Missing characters identified
  - [ ] Fallback font configured for missing characters
  - [ ] Font fallback chain tested
  - [ ] Localization readiness documented

### Task 39.17: Dynamic Text Sizing for Variable Content
- **Status:** TODO
- **Description:** Implement dynamic text sizing for UI elements that may contain variable-length content. Create a utility function or node script that: auto-sizes text to fit within a container (shrinks font size if text overflows, with a minimum readable size), truncates with ellipsis if even minimum size overflows, and adjusts container size to fit text for flexible-width elements. Apply to: item names in inventory (variable length), damage numbers (1 to 5 digits), quest objective text (variable length), and NPC dialogue choices (variable length). Ensure no text is ever cut off or overlapping in the final UI.
- **Acceptance Criteria:**
  - [ ] Auto-sizing for variable content containers
  - [ ] Minimum readable size enforced
  - [ ] Ellipsis truncation for extreme cases
  - [ ] Applied to all variable-length UI text
  - [ ] No text cut off or overlapping
  - [ ] System tested with edge cases (very long/short text)

### Task 39.18: Font Performance Verification
- **Status:** TODO
- **Description:** Profile the performance impact of the custom font. Measure: font loading time at game startup, text rendering time for the most text-heavy screen (inventory with all items), frame time when damage numbers are spawning rapidly (10+ per frame in busy combat), and memory usage of all font resources. Compare against the default Godot font baseline. MSDF fonts should render faster at varied sizes than rasterized fonts. If any performance regression: reduce MSDF texture size, pre-cache common sizes, or limit dynamic font features. Target: zero perceptible performance impact from custom fonts.
- **Acceptance Criteria:**
  - [ ] Font loading time measured
  - [ ] Text-heavy screen rendering profiled
  - [ ] Rapid damage number spawning tested
  - [ ] Font resource memory usage documented
  - [ ] No perceptible performance impact
  - [ ] Optimizations applied if needed

### Task 39.19: Font Style Guide Documentation
- **Status:** TODO
- **Description:** Create an internal reference documenting the complete font usage guide for the project. Document: font family name and license, all weight files and their locations, all size presets with intended use cases, custom icon glyph references, the theme resource path, tabular figure configuration, text shadow/outline settings per context, and the contrast ratio requirements. Include visual examples of each preset in use. This guide ensures consistency as new UI screens are created in the future.
- **Acceptance Criteria:**
  - [ ] Font family and license documented
  - [ ] All presets listed with visual examples
  - [ ] Custom icon references included
  - [ ] Theme resource path documented
  - [ ] Contrast requirements listed
  - [ ] Guide is clear enough for any developer to follow

### Task 39.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture before/after screenshots of every UI screen showing the font change. Show: HUD, inventory, dialogue, all menu screens, character stats, quest log, and damage numbers in combat. Create a font specimen showing all characters, sizes, and weights. Save to `_bmad-output/visual-overhaul/screenshots/epic-39/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Before/after for every UI screen
  - [ ] Font specimen image created
  - [ ] All sizes and weights shown
  - [ ] Custom icons shown in context
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- None (font is foundational — should be done first in the UI phase)

## Notes

- Font is the single most impactful UI change — it affects EVERY screen and EVERY text element
- Prioritize readability over style — a readable font with tech flavor beats a cool font you can't read
- Test at ACTUAL game resolution on a monitor, not in a zoomed-in editor view
- Tabular figures are non-negotiable for stat displays — numbers that shift when values change look broken
- The accent font for titles is optional — only use it if it dramatically improves the title screen
