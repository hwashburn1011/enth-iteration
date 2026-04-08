---
epic: 21
title: "NPC Expression System"
phase: 4
status: TODO
priority: medium
estimated_hours: 50
dependencies: [1, 2, 3, 19, 20]
---

# Epic 21: NPC Expression System

## Overview

Create a comprehensive expression system for all NPCs in Enth: Iteration using Blender shape keys (blend shapes) and complementary particle/icon systems. This epic adds emotional range to the AI Sage, Cache Sprite, and future NPCs through facial shape keys (happy, sad, surprised, thinking), an automatic eye blink system, mouth shape synchronization for dialogue, emotion particles, reaction icons (!, ?, ...), and a portrait system with expression variants for the dialogue UI.

**Design Philosophy:** NPCs in stylized games communicate emotion through exaggerated, readable facial changes. Since our characters have simplified faces (the AI Sage has only glowing eyes, the Cache Sprite has large cartoon eyes), the expression system leans heavily on eye shape, head tilt, particle effects, and UI icons rather than complex facial muscle simulation. The system must work for characters with varying face designs.

**Quality Target:** Expressions should be readable at isometric camera distance and in dialogue portraits. Each emotion should be instantly identifiable. The system should feel polished and responsive to dialogue and gameplay events.

## Success Criteria

- [ ] Shape keys for happy/sad/surprised/thinking on all NPCs
- [ ] Automatic eye blink system with natural timing
- [ ] Mouth shape keys synchronized to dialogue text display
- [ ] Emotion particles complement facial expressions
- [ ] Reaction icons (!, ?, ...) appear contextually
- [ ] Portrait system shows expression variants in dialogue UI
- [ ] All expressions readable at camera distance
- [ ] System is extensible for future NPCs

---

## Tasks

### Task 21.1: Expression System Architecture
**Status:** TODO
**Description:** Design the technical architecture for the NPC expression system. Create a base script `npc_expression_controller.gd` that manages all expression-related systems for any NPC. The controller manages: (1) Shape key blending (drives MeshInstance3D blend shape weights), (2) Eye blink timing, (3) Mouth shape selection during dialogue, (4) Emotion particle triggering, (5) Reaction icon display, (6) Portrait expression state for the UI. The controller exposes a public API: `set_expression(expression_name: StringName)`, `trigger_reaction(reaction_type: StringName)`, `set_talking(is_talking: bool)`, `get_portrait_expression() -> StringName`. Expressions are defined as resources (`ExpressionData.tres`) containing shape key target values, particle effect references, and portrait texture paths. Design for extensibility -- adding a new NPC requires only creating its expression data resources.
**Acceptance Criteria:**
- `npc_expression_controller.gd` with public API
- `ExpressionData` resource definition
- Shape key, blink, mouth, particle, icon, portrait systems integrated
- Data-driven: new NPCs configured via .tres files
- Extensible without code changes for new expressions
- Static typed GDScript following project conventions

### Task 21.2: Shape Keys -- AI Sage Expressions
**Status:** TODO
**Description:** Add shape keys to the AI Sage mesh in Blender. Since the AI Sage has only glowing eye points visible under a hood, expressions are communicated through eye shape/size and hood tilt. Create the following shape keys from the Basis (neutral) pose: (1) **Happy**: eye glow points widen vertically (stretch taller by 20%), hood tilts up 3 degrees (opening up). (2) **Sad**: eye glow points narrow vertically (squish by 20%), hood tilts down 5 degrees (drooping). (3) **Surprised**: eye glow points expand significantly (30% larger in all directions), hood tilts back 5 degrees. (4) **Thinking**: one eye glow narrows slightly (asymmetric), hood tilts to one side 3 degrees. (5) **Angry**: eye glow points angle inward (inner corners drop -- achieved by moving top-inner vertices down), hood tilts forward 3 degrees. Apply each shape key and verify it reads clearly from the isometric camera angle.
**Acceptance Criteria:**
- 5 shape keys: happy, sad, surprised, thinking, angry
- Eye glow point deformation is primary expression driver
- Hood tilt supplements eye expression
- Each expression readable at isometric camera distance
- Shape keys blend smoothly with each other
- Basis pose is a neutral/default state
- Shape keys export correctly in .glb format

### Task 21.3: Shape Keys -- Cache Sprite Expressions
**Status:** TODO
**Description:** Add shape keys to the Cache Sprite mesh. The sprite has large cartoon eyes, making expressions more dramatic and readable than the AI Sage. Create shape keys: (1) **Happy**: eyes curve into upward arcs (happy squint -- move bottom eyelid vertices up to create anime-style happy eyes), mouth curves up wider. (2) **Sad**: eyes angle downward at outer corners, pupils shrink slightly (vertex scale inward), mouth curves down. (3) **Surprised**: eyes go perfectly round and enlarge 30% (classic cartoon surprise), mouth opens into small O shape. (4) **Thinking**: one eye squints while the other stays open (asymmetric), mouth shifts to one side. (5) **Excited**: eyes become star-shaped (or extra sparkly -- push highlight vertices outward), mouth wide open smile. (6) **Worried**: eyebrows (upper eye vertices) angle inward-up, eyes widen slightly, mouth tightens. These should be dramatic and fun.
**Acceptance Criteria:**
- 6 shape keys: happy, sad, surprised, thinking, excited, worried
- Large eye deformations are dramatic and cartoon-style
- Mouth shape changes complement eye expressions
- Excited expression unique to Cache Sprite (extra personality)
- Worried expression for combat/danger situations
- All expressions visually distinct at small character scale
- Shape keys blend correctly for combination expressions

### Task 21.4: Eye Blink System
**Status:** TODO
**Description:** Implement an automatic eye blink system that adds lifelike involuntary blinking to all NPCs. Create a `blink_controller.gd` script (component of the expression controller). The blink uses a dedicated shape key: `blink` (both eyes close -- upper eyelid vertices move down to meet lower eyelid). Blink timing: random interval between 2-6 seconds (normally distributed around 4 seconds), with each blink lasting 0.15 seconds (4 frames at 60fps: 2 frames closing, 2 frames opening). Edge cases: (1) During the "surprised" expression, suppress blinking for 1 second (surprise holds eyes open). (2) During "sad," increase blink frequency (every 1-3 seconds -- more frequent blinking suggests emotional state). (3) During talking, blink at standard rate. (4) Blinking blends additively with the current expression shape keys.
**Acceptance Criteria:**
- Automatic blinks at random 2-6 second intervals
- Blink duration 0.15 seconds (fast, natural)
- Blink shape key blends additively with expressions
- Blink suppressed during surprise expression
- Blink frequency increased during sad expression
- Blink continues during talking
- System works for both AI Sage and Cache Sprite

### Task 21.5: Mouth Shape Keys for Dialogue
**Status:** TODO
**Description:** Create mouth shape keys that synchronize with dialogue text display. Since full lip-sync is not needed for a text-based dialogue system, create a simplified mouth animation that suggests talking. Shape keys: (1) `mouth_open`: mouth opens to 50% (used for vowel sounds), (2) `mouth_wide`: mouth stretches horizontally (used for consonants like "ee"), (3) `mouth_closed`: mouth fully closed (used for pauses, "m/b/p" sounds). Create a `mouth_animator.gd` script that drives mouth shape keys based on the current dialogue text character rate. When dialogue text is displaying (characters appearing one at a time), cycle the mouth shapes in a pattern: open -> wide -> closed -> open at the text display rate. When dialogue pauses (punctuation, player choice), mouth returns to closed. This creates the illusion of speech without actual phoneme mapping.
**Acceptance Criteria:**
- 3 mouth shape keys: open, wide, closed
- Mouth cycles through shapes at text display rate
- Returns to closed at punctuation and pauses
- Cycling pattern creates convincing speech illusion
- Synchronizes with dialogue system text display speed
- Works for Cache Sprite (AI Sage has no visible mouth)
- Script is reusable for any NPC with mouth geometry

### Task 21.6: Emotion Particles -- Joy/Success
**Status:** TODO
**Description:** Create emotion particle effects that complement facial expressions. For joy/success emotions: (1) **Sparkle burst**: when the happy expression triggers, emit a burst of 8-12 small golden star particles (#FFDD44 with emission) from the NPC's head area. Stars expand outward in a dome pattern (hemisphere), rise 0.2m, then fade over 0.5 seconds. Each star uses a simple 4-pointed star billboard texture. (2) **Heart particle** (optional for affinity increases): a single pink heart (#FF88AA) floats upward from the NPC, bobbing gently, over 1 second. These particle effects trigger once when the expression changes (not continuously) to punctuate the emotional shift.
**Acceptance Criteria:**
- Golden star sparkle burst on happy expression trigger
- 8-12 particles in dome pattern with 0.5s lifetime
- 4-pointed star billboard texture
- Optional heart particle for affinity events
- Triggers once per expression change (not continuous)
- Visible at camera distance against various backgrounds
- Particles auto-free after lifetime

### Task 21.7: Emotion Particles -- Distress/Confusion
**Status:** TODO
**Description:** Create emotion particles for negative/confused emotional states. (1) **Sweat drop**: when worried or nervous expression triggers, spawn a single stylized sweat drop (blue-white teardrop shape) at the NPC's temple area, which slides down 0.1m over 0.5s then fades. Classic anime visual language. (2) **Question marks**: for thinking/confused state, spawn 2-3 small "?" text particles (using a "?" billboard texture in light blue #88AAFF) that float upward from the head, wobbling left-right, over 1 second. (3) **Storm cloud**: for angry expression, spawn a tiny dark cloud (small dark grey sprite) above the head with 1-2 tiny lightning bolt sprites that flash. The storm cloud persists as long as the angry expression is active, then fades over 0.3s.
**Acceptance Criteria:**
- Sweat drop for worried/nervous (anime style)
- Question marks for thinking/confused (float upward wobbling)
- Storm cloud with lightning for angry (persists during expression)
- Each effect uses distinct visual language
- Sweat drop and question marks are single-trigger, storm cloud persists
- All visible at camera distance
- Fades cleanly when expression changes

### Task 21.8: Emotion Particles -- Special States
**Status:** TODO
**Description:** Create emotion particles for less common emotional states. (1) **Shock/Surprise**: when surprised expression triggers, spawn a stylized "!!" double exclamation billboard sprite that pops in (scale 0% to 130% to 100% over 0.2s) above the head and holds for 0.5s before fading. Different from the aggro "!" indicator (which is red and combat-related) -- this is yellow/white (#FFFFAA) and friendly/comedic. (2) **Sleep Zzz**: if an NPC enters a sleep/idle-too-long state, spawn floating "Z" text particles in blue (#8888DD) that drift upward slowly (one "Z" every 1.5s). (3) **Sparkle eyes**: for extremely positive reactions (rare), add tiny sparkle particles directly at the eye positions (gold, flickering, 4-6 particles, persistent during expression).
**Acceptance Criteria:**
- "!!" surprise indicator distinct from combat aggro "!"
- Yellow/white color and friendly/comedic feel
- Sleep "Z" particles for idle/sleep state
- Sparkle eyes for extremely positive reactions
- Each state has unique visual language
- All visible at camera distance
- No confusion with combat VFX indicators

### Task 21.9: Reaction Icons -- System Implementation
**Status:** TODO
**Description:** Implement the reaction icon system separate from emotion particles. Reaction icons are larger, more prominent billboards that appear above NPCs in response to game events (not just dialogue). Create a `ReactionIconSystem` that manages icon display: (1) **"!" Alert**: when NPC has new quest available -- yellow "!" icon, pulsing scale 100-110%, persistent until player interacts. (2) **"?" Question**: when NPC has dialogue but no quest -- white "?" icon, static. (3) **"..." Thinking**: when NPC is processing/loading -- grey "..." that animates (dots appear one at a time in a loop). (4) **Checkmark**: when quest complete -- green checkmark, appears briefly (2s) then fades. (5) **Arrow**: directional arrow when NPC wants to lead the player somewhere. Icons are billboard sprites positioned 0.3m above NPC mesh bounds. Only one icon displays at a time (priority: alert > quest > thinking > checkmark).
**Acceptance Criteria:**
- 5 reaction icon types: !, ?, ..., checkmark, arrow
- Billboard rendering always facing camera
- Priority system ensures only one icon shows
- "!" persistent with pulse for quest availability
- "..." animated dot sequence for processing
- Checkmark with brief display and fade
- Icons position above mesh bounds automatically

### Task 21.10: Reaction Icons -- Visual Design
**Status:** TODO
**Description:** Design and create the icon textures/sprites for the reaction system. Each icon should match the game's stylized aesthetic. Create billboard textures at 64x64 resolution (small, efficient): (1) "!" exclamation: bold yellow (#FFDD00) with dark outline (#333300), stylized font matching the game. (2) "?" question mark: white (#FFFFFF) with grey outline (#666666), same stylized font. (3) "..." ellipsis: grey (#888888) dots, each dot on a separate layer for animation. (4) Checkmark: bright green (#44DD44) with gold outline (#CCAA44), chunky/rounded shape. (5) Arrow: teal (#22AAAA) matching Cache Sprite color, with subtle data-stream pattern inside. All icons should have a subtle circular background (dark, semi-transparent) to ensure readability against any game environment background. Add a gentle glow/emission to each icon.
**Acceptance Criteria:**
- 5 icon textures at 64x64 with consistent style
- Dark semi-transparent circular background for readability
- Colors match game palette (yellow, white, grey, green, teal)
- Stylized font matching game aesthetic
- Subtle glow/emission on all icons
- Readable against bright (town) and dark (dungeon) backgrounds
- "..." has separate dot layers for animation

### Task 21.11: Portrait System -- Expression Variants Architecture
**Status:** TODO
**Description:** Design and implement the portrait expression system for the dialogue UI. When NPCs speak in dialogue, their portrait appears in the dialogue box showing the current expression. Create a `PortraitManager` that works with the dialogue system. For each NPC, portraits are pre-rendered or pre-painted images (256x256) showing the character's face/upper body with a specific expression. The portrait manager maintains a dictionary mapping NPC ID + expression name to texture paths. When the dialogue system sets an NPC's expression via text tags (e.g., `[expression=happy]`), the portrait manager updates the displayed portrait. Create a smooth crossfade between portrait changes (0.2s blend). Support at least 6 expression variants per NPC.
**Acceptance Criteria:**
- Portrait manager integrates with dialogue system
- Dictionary mapping: NPC ID + expression -> texture path
- Portrait textures at 256x256 resolution
- Smooth crossfade between expression changes (0.2s)
- Dialogue text tags trigger expression changes
- Support for 6+ expressions per NPC
- Extensible for future NPCs

### Task 21.12: Portrait System -- AI Sage Portraits
**Status:** TODO
**Description:** Create portrait images for the AI Sage showing each expression variant. Render or paint 6 portraits at 256x256: (1) **Neutral**: sage upper body from front, hood shadows the face, two golden eye glows visible, staff crystal visible to the side, serene posture. (2) **Happy**: eye glows brightened and widened, hood angled slightly up, subtle golden sparkle accents. (3) **Sad**: eye glows dimmed and narrowed, hood angled down, darker color tone. (4) **Surprised**: eye glows expanded and bright, hood tilted back, subtle "!!" accent marks. (5) **Thinking**: one eye slightly narrowed, hood tilted to side, "..." near the head. (6) **Concerned**: eye glows narrow and angled downward, hood forward, darker mood. Each portrait should have a consistent composition, background (dark gradient or transparent), and artistic style matching the hand-painted game aesthetic.
**Acceptance Criteria:**
- 6 AI Sage portraits at 256x256
- Consistent composition across all variants
- Expression changes visible despite minimal face features
- Golden eye glow variation is primary differentiator
- Dark gradient background for dialogue UI compatibility
- Hand-painted style matching game aesthetic
- Each expression instantly identifiable

### Task 21.13: Portrait System -- Cache Sprite Portraits
**Status:** TODO
**Description:** Create portrait images for the Cache Sprite. The sprite's large expressive face makes portraits more readable and fun. Render or paint 7 portraits at 256x256: (1) **Neutral**: sprite head and upper body, large eyes with standard expression, antenna visible, teal glow. (2) **Happy**: eyes curved into happy arcs, wide smile, sparkle accents near eyes. (3) **Sad**: eyes drooping, mouth downturned, single teardrop accent. (4) **Surprised**: huge round eyes, tiny open mouth, "!!" accent. (5) **Excited**: star-sparkle eyes, enormous smile, energy lines radiating. (6) **Worried**: raised eyebrow angles, wobbly mouth, sweat drop accent. (7) **Thinking**: one eye squinted, mouth to side, "?" accent. Portraits should be extra cute and expressive -- the Cache Sprite's portraits are a key source of charm.
**Acceptance Criteria:**
- 7 Cache Sprite portraits at 256x256
- Large expressive eyes are the primary focus
- Accent marks (sparkles, teardrops, "!!", "?") enhance readability
- Extra cute and charming presentation
- Consistent composition and background across variants
- Each expression dramatically different (exaggerated cartoon style)
- Teal glow visible in all portraits

### Task 21.14: Dialogue System Integration -- Expression Tags
**Status:** TODO
**Description:** Integrate the expression system with the game's dialogue system. Define dialogue text tags that trigger expression changes: `[expression=happy]`, `[expression=sad]`, `[expression=surprised]`, etc. When the dialogue system encounters these tags during text display, it: (1) Calls `npc_expression_controller.set_expression()` on the speaking NPC (for in-world expression change), (2) Updates the portrait manager for the dialogue UI portrait change, (3) Triggers the appropriate emotion particles. Tags can appear at any point in the dialogue text and take effect immediately. Multiple expressions can be used in a single dialogue block. Add a `[reaction=!]` tag family for reaction icons. Document all available tags for use in dialogue scripts.
**Acceptance Criteria:**
- Expression tags parsed correctly from dialogue text
- Tags trigger in-world expression, portrait, and particles simultaneously
- Tags can appear at any position in dialogue text
- Multiple expression changes per dialogue block supported
- Reaction icon tags (!, ?, ...) also supported
- All available tags documented for dialogue writers
- No visible delay between tag parsing and visual change

### Task 21.15: Expression Blending and Transitions
**Status:** TODO
**Description:** Implement smooth expression transitions so that changing from one expression to another does not create jarring pops. When `set_expression()` is called, tween all shape key values from their current state to the target expression's values over 0.3 seconds using ease-in-out interpolation. Handle edge cases: (1) If a new expression is set while a transition is in progress, the new transition starts from the current interpolated values (not the previous target). (2) Returning to neutral smoothly resets all shape keys to 0. (3) The blink system continues to operate during transitions (blending additively). (4) Mouth shapes operate independently of expression shapes (talking + any expression should work). Test all expression-to-expression transitions for visual quality.
**Acceptance Criteria:**
- 0.3-second smooth transitions between all expression pairs
- Ease-in-out interpolation for natural feel
- Mid-transition interrupts handled gracefully
- Blink continues during transitions
- Mouth shapes independent of expression shapes
- All expression pairs tested (n*n matrix)
- No pops, glitches, or unnatural intermediate poses

### Task 21.16: Expression Priority and Context System
**Status:** TODO
**Description:** Create a priority system that manages which expressions take precedence in different contexts. Priority levels: (1) **Gameplay override** (highest): combat danger, critical narrative moment. (2) **Dialogue driven**: expression tags in dialogue text. (3) **Ambient reaction**: NPC responds to nearby events (player returns from dungeon, item crafted). (4) **Idle default** (lowest): neutral expression with occasional random personality expressions. The system should handle conflicts: if the dialogue sets "happy" but the gameplay context says "danger," the danger expression wins. Create a context stack where expressions are pushed/popped: when a dialogue ends, its expression pops and the NPC returns to the previous context's expression. Document the priority levels and context stack behavior.
**Acceptance Criteria:**
- 4 priority levels from gameplay override to idle default
- Context stack for push/pop expression management
- Dialogue expressions pop when dialogue ends
- Gameplay overrides take precedence over dialogue
- Ambient reactions layer between dialogue and idle
- Priority conflicts resolved cleanly
- Behavior documented with examples

### Task 21.17: NPC Expression Response to Player Actions
**Status:** TODO
**Description:** Connect NPC expressions to player gameplay actions via EventBus. Define expression responses: (1) **Player returns from dungeon**: nearby NPCs show "happy" (welcoming back). (2) **Player takes damage nearby**: nearby NPCs show "worried" (concern). (3) **Player levels up**: nearby NPCs show "excited" or "surprised." (4) **Player gives gift**: recipient NPC shows "happy" + heart particle. (5) **Player fails quest**: quest-giver NPC shows "sad." (6) **Iteration resets**: NPCs show "confused" briefly then return to normal (narrative element). (7) **Player idles for 30+ seconds near NPC**: NPC shows "thinking" (waiting). Each response triggers the appropriate expression, emotion particles, and portrait change. Responses use the ambient reaction priority level.
**Acceptance Criteria:**
- 7+ player action responses defined and connected via EventBus
- Each response maps to appropriate expression + particles
- Responses use ambient reaction priority level
- NPC distance check (only nearby NPCs react)
- Responses are contextually appropriate
- Iteration reset response ties into narrative theme
- System is extensible for new player actions

### Task 21.18: Expression Testing Tool
**Status:** TODO
**Description:** Create a debug/testing tool for the expression system. Implement a debug panel (toggled via debug keybind) that: (1) Lists all NPCs in the current scene with their current expression state. (2) Provides dropdown menus to force any expression on any NPC. (3) Shows the current shape key values for the selected NPC (real-time slider view). (4) Triggers emotion particles on demand. (5) Displays reaction icons on demand. (6) Shows the current portrait for the selected NPC. (7) Plays a test dialogue line with expression tags to verify the full pipeline. This tool is invaluable for tuning expressions and testing new NPCs. It should be completely disabled in release builds.
**Acceptance Criteria:**
- Debug panel lists all NPCs with current expression
- Expression forcing via dropdown for any NPC
- Real-time shape key value display
- Particle and icon triggering on demand
- Portrait preview
- Test dialogue playback with expression tags
- Disabled in release builds (debug-only)

### Task 21.19: Performance Optimization
**Status:** TODO
**Description:** Optimize the expression system for performance. Key areas: (1) Shape key evaluation: only process shape keys on NPCs currently visible to the camera (use VisibilityNotifier3D or distance check). NPCs offscreen should freeze their expression state. (2) Blink timer: use a shared timer for all NPCs rather than individual timers (reduce timer overhead). (3) Particle pooling: emotion particles should use an object pool (pre-instantiate 10 particles, recycle). (4) Portrait textures: lazy-load portraits only when a dialogue is opened with that NPC (do not preload all portraits for all NPCs). (5) Expression transitions: cap the tween count (max 2 expression transitions updating simultaneously per NPC to prevent excessive lerp calculations). Profile with 5+ NPCs on screen to verify.
**Acceptance Criteria:**
- Shape keys freeze for offscreen NPCs
- Shared blink timer reduces overhead
- Particle object pool eliminates runtime instantiation
- Portraits lazy-loaded per dialogue, not preloaded
- Max 2 simultaneous expression tweens per NPC
- 5+ NPCs on screen with expressions at < 0.5ms CPU overhead
- No visual quality degradation from optimizations

### Task 21.20: Full Expression System Integration Test
**Status:** TODO
**Description:** Comprehensive test of the entire expression system. Test scenarios: (1) Approach AI Sage in town -- neutral expression with blink. (2) Start dialogue -- portrait appears, speaking animation + mouth shapes. (3) Dialogue with expression tags -- portrait and in-world expression change simultaneously. (4) Receive quest -- "!" icon appears, sage shows "determined" pose. (5) Approach Cache Sprite -- neutral with personality idle variants. (6) Complete quest -- sprite shows "excited" + sparkle particles, sage shows "happy" + star burst. (7) Player takes damage near NPCs -- nearby NPCs show "worried." (8) Multiple NPCs expressing simultaneously -- verify no conflicts or performance issues. (9) Rapid expression changes during dialogue -- transitions blend smoothly. (10) Edge case: expression change during blink -- blink completes then expression transitions. Document any issues and adjust timing/priority values.
**Acceptance Criteria:**
- All 10 test scenarios pass without visual issues
- In-world and portrait expressions synchronize
- Emotion particles trigger appropriately
- Reaction icons display at correct times
- Multiple NPCs express simultaneously without conflicts
- Rapid expression changes blend smoothly
- Edge cases handled gracefully
- System feels polished and responsive

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings for shape keys
- **Epic 2** (Visual Style Guide): Expression style direction
- **Epic 3** (Texture Workflow): Portrait texture standards
- **Epic 19** (AI Sage): Base model and mesh for shape keys
- **Epic 20** (Cache Sprite): Base model and mesh for shape keys
- **Epic 42** (Dialogue System Visual): Portrait display in dialogue UI

## Notes

- Shape keys must be created in Blender before exporting to .glb (they export as blend shapes)
- The AI Sage's limited face (only eye glows) means its expressions rely more on hood tilt and particles
- The Cache Sprite's large cartoon eyes allow for dramatic, fun expressions
- Mouth shapes are simplified (3 keys) since this is a text-based dialogue system, not voice-acted
- The expression priority/context system prevents conflicting emotional states
- Portraits are the highest-fidelity expression delivery -- they appear large in the dialogue UI
- Future NPCs will follow the same pattern: create shape keys + portrait set + configure expression data resources
