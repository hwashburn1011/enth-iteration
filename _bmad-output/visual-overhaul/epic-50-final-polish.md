---
epic: 50
title: "Final Polish Pass"
phase: 10 — Final Polish
status: TODO
priority: critical
estimated_tasks: 20
---

# Epic 50: Final Polish Pass

## Overview

The comprehensive final quality pass across the entire game: screenshot composition check for every area, frame rate optimization, texture memory audit, animation smoothness pass, audio mix balancing, UI readability at different resolutions, colorblind accessibility check, first-5-minutes experience review, demo build packaging, and trailer-ready moments identification. This epic ensures everything created in Epics 1-49 comes together as a cohesive, polished experience.

## Success Criteria

- Every area passes the "screenshot test" (any screenshot looks like a finished game)
- Consistent 60fps at 1080p on mid-range hardware in all scenarios
- Total asset memory within budget (textures, audio, meshes combined)
- All animations smooth and well-timed (no hitches, no T-poses)
- Audio mix balanced across all contexts (no sudden volume jumps)
- UI readable and functional at 720p through 4K
- Colorblind players can use all game systems effectively
- First 5 minutes create a strong positive impression
- Demo build runs standalone without issues
- 5+ moments identified that would look great in a trailer

---

## Tasks

### Task 50.1: Full Game Visual Walkthrough
- **Status:** TODO
- **Description:** Walk through the entire game from main menu to boss defeat, taking screenshots at every distinct location and game state. Capture: main menu, town entrance, each town area (market, residential, garden, dungeon approach), each NPC interaction, dungeon entry, each dungeon floor (corridors, combat rooms, loot rooms, story rooms), each arena type, boss approach, boss fight (all 3 phases), victory, and return to town. Review every screenshot on a separate monitor (fresh eyes) and mark any that don't meet the "finished game" quality bar: visual glitches, placeholder art, inconsistent style, bad composition, or ugly moments. Create a fix list.
- **Acceptance Criteria:**
  - [ ] 50+ screenshots captured across all areas
  - [ ] Each screenshot reviewed for quality
  - [ ] Fix list created for all issues found
  - [ ] No placeholder art remains anywhere
  - [ ] Visual style is consistent throughout
  - [ ] Every screenshot looks like a finished game

### Task 50.2: Frame Rate Optimization Pass
- **Status:** TODO
- **Description:** Profile frame rate in every area of the game using Godot's built-in profiler and external tools. Test at 1080p on the target mid-range hardware specification. Identify ALL locations where frame rate drops below 60fps. Common culprits: too many shadow-casting lights in one room, excessive particle systems, unoptimized shaders, too many draw calls from non-batched geometry, large uncompressed textures. For each drop: identify the root cause, apply the most appropriate optimization (reduce quality, batch geometry, pool objects, LOD, culling), and re-profile to confirm the fix. Document all optimizations in a performance log.
- **Acceptance Criteria:**
  - [ ] Every area profiled for frame rate
  - [ ] All sub-60fps locations identified
  - [ ] Root cause determined per drop
  - [ ] Optimization applied per drop
  - [ ] Re-profiled to confirm fix
  - [ ] Performance log documenting all changes

### Task 50.3: Texture Memory Audit
- **Status:** TODO
- **Description:** Audit the total texture memory usage of the entire game. In Godot, check the import settings for every texture file. Calculate total VRAM usage at peak (all assets loaded for the worst-case area). Budget: total texture VRAM under 256MB at peak. Check: are all textures using VRAM compression? Are normal maps using the correct format (Linear, not sRGB)? Are any textures oversized for their screen-space coverage? Are there duplicate textures that could be shared? Are mipmaps enabled on all 3D textures? Create a report: top 20 largest textures, total per category (characters, town, dungeon, UI), and recommendations for any reductions needed.
- **Acceptance Criteria:**
  - [ ] Total VRAM usage calculated
  - [ ] Peak under 256MB budget
  - [ ] All textures VRAM compressed
  - [ ] No unnecessary oversized textures
  - [ ] Mipmaps enabled on all 3D textures
  - [ ] Top 20 textures documented

### Task 50.4: Animation Smoothness Pass
- **Status:** TODO
- **Description:** Review every animation in the game for smoothness and timing. Check: player walk/idle/attack/dash animations blend smoothly with no pops or T-pose frames, enemy animations transition correctly between states (idle->attack->idle), NPC idle animations loop seamlessly, door and chest open/close animations have appropriate easing (no linear robot movement), particle effects don't stutter or pop, UI animations are smooth (no frame skips on panel open/close), and damage numbers arc naturally. For each issue found: identify the cause (missing keyframe, wrong blend time, improper easing curve) and fix. Test at both 60fps and 30fps (in case of frame drops).
- **Acceptance Criteria:**
  - [ ] All character animations reviewed
  - [ ] All object animations reviewed
  - [ ] All UI animations reviewed
  - [ ] No T-poses, pops, or stutters
  - [ ] Blend transitions smooth
  - [ ] All issues fixed

### Task 50.5: Audio Mix Final Balance
- **Status:** TODO
- **Description:** Conduct the final audio mix balancing pass across the entire game. Play through: menu (music + UI sounds), town (music + ambient + footsteps + NPC interaction), dungeon exploration (ambient + footsteps + environmental sounds), combat (music layers + attack sounds + enemy sounds + UI feedback), boss fight (boss music + intense combat audio), dialogue (music ducking + character blips + text sounds), and level up / quest complete moments (stings over gameplay audio). Adjust individual sound levels to ensure nothing is too loud, too quiet, or masked by other sounds. Test on both speakers and headphones.
- **Acceptance Criteria:**
  - [ ] Full game audio played through speakers and headphones
  - [ ] No sound overpowers others inappropriately
  - [ ] Dialogue always audible over music
  - [ ] Combat SFX clear during intense encounters
  - [ ] Volume transitions between areas are smooth
  - [ ] No sudden volume spikes

### Task 50.6: UI Readability at Multiple Resolutions
- **Status:** TODO
- **Description:** Test all UI screens at: 1280x720, 1920x1080, 2560x1440, and 3840x2160. At each resolution verify: text is readable (not too small at 720p, not blurry at 4K), HUD elements are appropriately sized, no UI elements overlap or get clipped by screen edges, inventory grid cells are clickable (not too tiny at 720p), dialogue box is readable, damage numbers are visible, and minimap is usable. For any resolution-specific issues: adjust the UI scaling system (from Epics 39-43), add breakpoint-specific overrides, or enforce minimum element sizes. The game should look polished at all target resolutions.
- **Acceptance Criteria:**
  - [ ] All UI tested at 720p, 1080p, 1440p, 4K
  - [ ] Text readable at all resolutions
  - [ ] No overlap or clipping at any resolution
  - [ ] Interactive elements large enough at 720p
  - [ ] Sharp rendering at 4K
  - [ ] Issues fixed with scaling adjustments

### Task 50.7: Colorblind Accessibility Check
- **Status:** TODO
- **Description:** Test the game with colorblind simulation filters for the three major types: Protanopia (red-blind), Deuteranopia (green-blind), and Tritanopia (blue-blind). Check: enemy health vs. player health readability (red vs. green), item rarity borders (gray/green/blue/gold), status effect icons and colors, hazard zone colors (red/green/blue/purple), dungeon floor themes, and damage number colors (white/gold/red/green). For any color-dependent information that fails readability: add a secondary indicator (shape, pattern, text label, icon) that conveys the same information without color. Implement a "Colorblind Mode" setting that activates these secondary indicators.
- **Acceptance Criteria:**
  - [ ] Game tested with Protanopia filter
  - [ ] Game tested with Deuteranopia filter
  - [ ] Game tested with Tritanopia filter
  - [ ] All color-dependent info has non-color alternative
  - [ ] Colorblind Mode setting implemented
  - [ ] Game fully playable for colorblind players

### Task 50.8: First Five Minutes Experience Review
- **Status:** TODO
- **Description:** Play the first 5 minutes of the game as if you've never seen it before and evaluate the new player experience. Assess: is the main menu inviting? Does the intro sequence set the mood? Is the first view of the town impressive? Can you figure out where to go without explicit instructions? Is the first NPC interaction engaging? Are the controls intuitive (or is a tutorial needed)? Is the first dungeon entry exciting? Is the first combat encounter satisfying? Note every moment of confusion, frustration, delight, or boredom. Create a list of improvements that would make the first 5 minutes as strong as possible. This is the demo's make-or-break window.
- **Acceptance Criteria:**
  - [ ] Full 5-minute playthrough documented
  - [ ] Moments of confusion identified
  - [ ] Moments of delight identified
  - [ ] Navigation clarity assessed
  - [ ] Combat satisfaction assessed
  - [ ] Improvement list created with priorities

### Task 50.9: Fix First-Five-Minutes Issues
- **Status:** TODO
- **Description:** Address all issues identified in the first-five-minutes review. Priority fixes: add visual guidance if players get lost (subtle path lighting, beacon effects), add a brief controls tutorial if needed (unobtrusive tooltip overlay on first actions), adjust town entrance composition for maximum first impression, ensure the first NPC encounter is polished and welcoming, make the dungeon entrance visually compelling from the town, and ensure the first combat encounter is winnable and satisfying. Each fix should be minimal and targeted — don't redesign major systems, just polish the critical path through the opening.
- **Acceptance Criteria:**
  - [ ] Navigation issues fixed
  - [ ] Controls communicated clearly
  - [ ] Town first impression maximized
  - [ ] First NPC interaction polished
  - [ ] First combat encounter satisfying
  - [ ] Re-tested and confirmed improved

### Task 50.10: Consistency Check — Art Style
- **Status:** TODO
- **Description:** Review the entire game for art style consistency. Check: do all characters use the same level of detail and color saturation? Do town and dungeon environments use their respective palettes consistently? Are there any assets that look like they came from a different game (too realistic, too cartoony, wrong color temperature)? Are prop details consistent (same level of paint quality across all props)? Is the emission glow consistent (same intensity rules for all glowing objects)? Are textures the same resolution relative to their screen coverage? Mark any inconsistent assets and either rework them or adjust surrounding assets to match.
- **Acceptance Criteria:**
  - [ ] All characters consistent in style
  - [ ] Town environment internally consistent
  - [ ] Dungeon environment internally consistent
  - [ ] No assets look out of place
  - [ ] Emission glow consistent
  - [ ] All inconsistencies fixed

### Task 50.11: Consistency Check — UI
- **Status:** TODO
- **Description:** Review all UI screens for visual consistency. Check: same font used everywhere (no default Godot font anywhere), same button style across all screens, same panel background color and opacity, same border style on all frames, same spacing and margins, same color for interactive vs. non-interactive elements, same hover/focus states. Compare every screen side by side. Ensure the HUD, inventory, dialogue, menus, and in-game notifications all look like they belong to the same game. Fix any inconsistencies.
- **Acceptance Criteria:**
  - [ ] All screens use custom font only
  - [ ] Button styles consistent
  - [ ] Panel backgrounds consistent
  - [ ] Border styles consistent
  - [ ] Spacing and margins consistent
  - [ ] All UI feels cohesive

### Task 50.12: Bug Hunt — Visual Glitches
- **Status:** TODO
- **Description:** Conduct a dedicated visual bug hunt. Walk through every area looking specifically for: z-fighting (two surfaces competing for the same depth), texture seams visible from the gameplay camera, light leaks through walls, shadow acne or peter-panning, transparency sorting issues, particle effects rendering behind objects they should be in front of, UI elements overlapping incorrectly, animation glitches (T-poses, limb stretching, wrong state), and missing collision (walking through props). For each bug: document location and reproduction steps, assess severity (visual-only vs. gameplay-affecting), and fix in priority order.
- **Acceptance Criteria:**
  - [ ] Full game searched for visual bugs
  - [ ] All bugs documented with location/repro
  - [ ] Severity assessed per bug
  - [ ] Critical/high bugs fixed
  - [ ] Medium/low bugs documented for future
  - [ ] No game-breaking visual issues remain

### Task 50.13: Loading Time Optimization
- **Status:** TODO
- **Description:** Measure and optimize all loading times in the game. Measure: initial game startup, main menu to gameplay, town to dungeon transition, room-to-room transitions, floor changes, and death/respawn. NFR2 requires floor transitions under 3 seconds. For any transition exceeding 1.5 seconds: investigate causes (large scene, uncompressed resources, synchronous loading). Apply optimizations: use ResourceLoader.load_threaded for async loading, compress resources, pre-load adjacent rooms, use scene inheritance to reduce per-room asset loading. Ensure loading screens appear instantly for any load exceeding 0.5 seconds.
- **Acceptance Criteria:**
  - [ ] All loading times measured
  - [ ] Floor transitions under 3 seconds (NFR2)
  - [ ] Room transitions under 1.5 seconds
  - [ ] Async loading implemented where needed
  - [ ] Loading screens appear for loads over 0.5s
  - [ ] Startup time reasonable (under 5 seconds)

### Task 50.14: Save System Verification
- **Status:** TODO
- **Description:** Verify the save system works correctly with all visual overhaul changes. Test: save in town (visual state preserved on load?), save in dungeon (room state, lighting, props preserved?), save during combat (positions, effects preserved?), save with full inventory (all item icons, rarities correct on load?), and save at various game progression points. Verify save file size stays under 1MB (NFR4). Test the 3-slot rolling backup system. Intentionally corrupt a save file and verify the backup recovery works. This ensures the visual overhaul hasn't broken the save system.
- **Acceptance Criteria:**
  - [ ] Town save/load verified
  - [ ] Dungeon save/load verified
  - [ ] Inventory persistence verified
  - [ ] Save file under 1MB
  - [ ] Rolling backup system works
  - [ ] Corrupted save recovery tested

### Task 50.15: Settings Verification
- **Status:** TODO
- **Description:** Verify all settings from the Settings screen work correctly. For each graphics setting (shadow quality, SSAO, bloom, fog, AA, HUD scale): change the setting, verify the visual change occurs, verify it persists after closing and reopening settings, and verify it persists after restarting the game. For audio settings: verify each volume slider affects the correct bus, verify persistence. For gameplay settings: verify text speed affects dialogue, verify transition speed setting works. For accessibility settings: verify colorblind mode, reduced screen effects, font size override. Document any settings that don't work as expected.
- **Acceptance Criteria:**
  - [ ] All graphics settings verified
  - [ ] All audio settings verified
  - [ ] All gameplay settings verified
  - [ ] All accessibility settings verified
  - [ ] Settings persist between sessions
  - [ ] All non-working settings fixed

### Task 50.16: Demo Build Packaging
- **Status:** TODO
- **Description:** Package a standalone demo build for distribution. The demo should include: main menu, town hub (full), dungeon Floors 1-5, the boss fight, and the compaction portal return. End the demo after the first compaction (show demo end screen with "Thanks for playing" and "Wishlist on [platform]" call to action). Configure Godot export settings: Windows x86_64, include all required resources, strip debug symbols, compress PCK file. Verify the demo runs on a clean Windows installation (no Godot editor required). Test the demo executable on a different machine than the development machine. Verify install size is under 2GB (NFR5).
- **Acceptance Criteria:**
  - [ ] Standalone Windows demo exported
  - [ ] Demo includes menu through boss fight
  - [ ] Demo end screen after compaction portal
  - [ ] Runs on clean Windows (no Godot needed)
  - [ ] Tested on non-development machine
  - [ ] Install size under 2GB

### Task 50.17: Demo Playtest
- **Status:** TODO
- **Description:** Conduct a full playtest of the demo build (not the editor — the actual exported build). Play from launch to demo end without stopping. Note every issue: visual, audio, gameplay, performance, UI, and UX. Pay special attention to: first-time experience (does it hook?), combat feel (satisfying?), loot excitement (rewarding?), boss fight drama (climactic?), and demo ending (leaves wanting more?). Time the total demo: target 30-45 minutes for a thorough first playthrough. Fix any critical issues found. This is the final quality gate before the game is seen by anyone outside the team.
- **Acceptance Criteria:**
  - [ ] Full demo played in exported build
  - [ ] All issues documented
  - [ ] Critical issues fixed
  - [ ] Demo length is 30-45 minutes
  - [ ] Experience is engaging throughout
  - [ ] Demo ending creates desire for more

### Task 50.18: Trailer-Ready Moments Identification
- **Status:** TODO
- **Description:** Play through the game and identify 5-10 moments that would look great in a marketing trailer. These are the "money shots" — visually impressive moments that showcase the game at its best. Candidates: town vista at sunset with atmosphere effects, first dungeon entry with dramatic lighting transition, intense combat with multiple enemies and VFX, legendary loot reveal with golden spotlight, boss fight Phase 3 with arena destruction, victory portal activation, a beautiful dialogue portrait moment, the level-up fanfare, and the town with all atmosphere effects. For each moment: note the exact game state and camera angle, take a high-quality screenshot (4K if possible), and record a 5-10 second video clip.
- **Acceptance Criteria:**
  - [ ] 5-10 trailer-worthy moments identified
  - [ ] High-quality screenshot per moment
  - [ ] 5-10 second video clip per moment
  - [ ] Moments showcase visual variety
  - [ ] Combat, exploration, and story represented
  - [ ] Clips are genuinely impressive

### Task 50.19: Final Screenshot Gallery
- **Status:** TODO
- **Description:** Create a definitive screenshot gallery showing the final state of the game after all 50 epics. Capture 20-30 high-quality screenshots at maximum resolution covering: main menu, town (multiple areas, multiple lighting conditions), dungeon (each floor theme), combat (with VFX), boss fight (each phase), UI screens (HUD, inventory, dialogue), atmospheric effects (god rays, fireflies, water, smoke), and VFX highlights (critical hit, level-up, portal). Save the gallery to `_bmad-output/visual-overhaul/screenshots/final-gallery/`. These screenshots serve as the visual record of the overhaul and as marketing assets.
- **Acceptance Criteria:**
  - [ ] 20-30 high-quality screenshots
  - [ ] All major areas represented
  - [ ] All visual features showcased
  - [ ] Maximum resolution
  - [ ] Gallery organized and named
  - [ ] Screenshots serve as marketing assets

### Task 50.20: Visual Overhaul Completion Report
- **Status:** TODO
- **Description:** Create the final completion report for the entire visual overhaul project. Document: total epics completed (50), total tasks completed (1000), before/after visual quality score assessment (target: from ~35/100 to 80+/100), key technical achievements (shader library, VFX system, dynamic music), remaining known issues (if any, with severity), performance benchmarks (minimum/average/maximum FPS across all areas), total asset sizes (textures, audio, meshes), and recommendations for future visual work beyond the overhaul. Update MASTER-PLAN.md with final status for all 50 epics. This report closes the visual overhaul project.
- **Acceptance Criteria:**
  - [ ] Completion report covers all 50 epics
  - [ ] Before/after quality assessment documented
  - [ ] Performance benchmarks included
  - [ ] Asset size totals documented
  - [ ] Known issues listed with severity
  - [ ] MASTER-PLAN.md fully updated

---

## Dependencies

- **Epics 1-49** (All previous epics) — Everything must be complete before final polish

## Notes

- This is the most important epic — it's where everything comes together or falls apart
- The first-five-minutes review is worth more than any other task — it determines the game's first impression
- Frame rate issues found here are the most expensive to fix — they should have been caught earlier, but this is the safety net
- The demo build is the game's public face — it must be flawless
- Trailer moments are marketing gold — identify them carefully, they'll be seen more than any other content
- This epic should NOT introduce new features — it only polishes and fixes existing work
