---
epic: 38
title: "Room Transition Visuals"
phase: 6 — Dungeon Environment
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 38: Room Transition Visuals

## Overview

Polish the visual experience of moving between dungeon rooms: door open/close animations, portal shimmer between rooms, loading screen with floor map, transition wipe effects, elevator/descend animation between floors, boss door dramatic opening, and completion portal activation sequence. Transitions are the connective tissue between gameplay moments — they should maintain immersion and pacing.

## Success Criteria

- All doors have smooth open/close animations with audio hooks
- Room transitions are seamless (no visible loading stutter)
- Floor transitions have a distinct elevator/descent visual
- Loading screens show useful information (floor map, tips)
- Boss door opening is the most dramatic transition in the game
- Completion portal has a satisfying activation and entry sequence
- All transitions are under 3 seconds (NFR2)
- Transitions maintain 60fps during animation

---

## Tasks

### Task 38.1: Standard Door Open/Close Animation
- **Status:** TODO
- **Description:** Create the standard dungeon door animation. The sliding door panel splits at the center vertical seam and each half slides into the wall. Animation in AnimationPlayer: door starts closed (panels together), status light on door frame changes from red to green (0.2s), panels begin sliding apart (0.5s ease-in-out), panels fully open revealing the room beyond, hold open while player passes through, then after player exits the door trigger zone, panels slide closed (0.5s ease-in-out), status light returns to red. Add particle effects: small steam puff from the door seam when opening (compressed air release), and a subtle thud camera nudge when the door contacts its open position.
- **Acceptance Criteria:**
  - [ ] Two-panel sliding door animation
  - [ ] Status light changes red -> green -> red
  - [ ] Steam puff particle on opening
  - [ ] 0.5s open, 0.5s close timing
  - [ ] Door auto-closes after player passes through
  - [ ] Subtle physical feedback (camera nudge, sound hook)

### Task 38.2: Door Trigger Zone and State Machine
- **Status:** TODO
- **Description:** Create a DungeonDoor.gd script with a state machine: CLOSED, OPENING, OPEN, CLOSING. Add an Area3D trigger zone in front of the door (2m x 3m x 2m) that detects the player. When the player enters the trigger zone and the door is CLOSED, transition to OPENING. When OPENING completes, transition to OPEN. When the player exits the zone and is on the far side, transition to CLOSING. Handle edge cases: player changes direction during animation (door stays open), multiple players (not applicable in single-player but future-proof), locked doors (interaction required to unlock first). Emit EventBus signals: `door_opened(room_from, room_to)`, `door_closed`.
- **Acceptance Criteria:**
  - [ ] State machine: CLOSED, OPENING, OPEN, CLOSING
  - [ ] Trigger zone detects player proximity
  - [ ] Edge cases handled (direction change, etc.)
  - [ ] Locked door support via interaction
  - [ ] EventBus signals on open/close
  - [ ] Script follows project standards

### Task 38.3: Room Transition Cross-Fade
- **Status:** TODO
- **Description:** Implement a smooth visual cross-fade when transitioning between rooms that need loading. If the next room is not yet loaded: fade the screen to black (0.3s), load the room, fade back in (0.3s). If the room is already loaded (preloaded from adjacent rooms): no fade needed, the open door reveals the room directly. Use a CanvasLayer with a ColorRect for the fade. The fade color should match the dungeon ambient: dark blue-gray (#1A2030) not pure black. During the fade-out, the door's opening animation plays. During fade-in, the player is repositioned in the new room at the door entrance. Total transition under 1.5 seconds including load time.
- **Acceptance Criteria:**
  - [ ] Cross-fade for rooms requiring loading
  - [ ] No fade for pre-loaded adjacent rooms
  - [ ] Fade color is dungeon-appropriate dark blue
  - [ ] Total transition under 1.5 seconds
  - [ ] Player repositioned correctly in new room
  - [ ] Fade is smooth (no stutter or frame skip)

### Task 38.4: Floor Transition — Elevator Descent Visual
- **Status:** TODO
- **Description:** Create a dedicated visual for descending between dungeon floors (Floor 1 -> Floor 2, etc.). When the player activates the floor exit: the screen fades to the elevator transition scene. The elevator scene shows: metal walls scrolling downward (parallax, 3 layers at different speeds for depth), flickering overhead light, floor counter display changing (current floor number ticking down), and the new floor's theme color gradually tinting the walls (Floor 2 walls get green tint, Floor 3 gets blue-gray, etc.). Duration: 2-2.5 seconds. End with doors opening to reveal the new floor's first room. This is the "going deeper" moment.
- **Acceptance Criteria:**
  - [ ] Metal walls scrolling downward with parallax
  - [ ] Flickering overhead light in elevator
  - [ ] Floor counter display changing numbers
  - [ ] New floor's theme color tints elevator walls
  - [ ] Duration 2-2.5 seconds
  - [ ] Ends with door opening to new floor

### Task 38.5: Floor Transition — Floor Title Card
- **Status:** TODO
- **Description:** During the elevator descent, display a floor title card that introduces the new floor. The title card appears centered on screen during the descent: "FLOOR [N]" in large custom game font with the floor's theme styling (Floor 1: clean white, Floor 2: green with data, Floor 3: gray with flicker, Floor 4: purple with glitch, Floor 5: red with pulse). Below the floor number, show a brief subtitle: "Tutorial Level", "Data Processing Center", "Abandoned Infrastructure", "Corrupted Sector", "The Core". The title fades in at the midpoint of the descent and fades out before the doors open. Add a subtle animation (text slides in, or letters assemble).
- **Acceptance Criteria:**
  - [ ] Floor number in large custom font
  - [ ] Theme-appropriate text styling per floor
  - [ ] Descriptive subtitle per floor
  - [ ] Text fades in/out during descent
  - [ ] Text animation (slide or assemble)
  - [ ] Readable and dramatic

### Task 38.6: Loading Screen with Floor Map
- **Status:** TODO
- **Description:** Create a loading screen that shows useful information during longer transitions (floor changes, initial dungeon entry). Display: a simplified floor map showing room shapes and connections (rooms the player has visited are filled, unexplored rooms are outlined), the player's current position marker, the floor number and progress (rooms cleared / total rooms), and a rotating gameplay tip at the bottom. The map should use the floor's theme colors. The loading bar is a subtle progress indicator at the bottom (not a traditional loading bar — a circuit trace that fills from left to right). Loading screen appears only when actual loading exceeds 0.5 seconds.
- **Acceptance Criteria:**
  - [ ] Floor map showing room layout
  - [ ] Visited rooms filled, unexplored outlined
  - [ ] Player position marker
  - [ ] Progress counter (rooms cleared / total)
  - [ ] Gameplay tip rotation
  - [ ] Circuit trace loading indicator

### Task 38.7: Screen Wipe Transitions
- **Status:** TODO
- **Description:** Create several screen wipe transition effects for different transition types. Implement as shaders applied to a CanvasLayer: (1) Horizontal scan line wipe (a scan line sweeps from left to right, revealing the new scene behind it — fits the digital theme), (2) Pixel dissolve (random pixels transition from old to new scene, like data being rewritten), (3) Diagonal circuit wipe (circuit trace pattern grows from corner, filling screen with new scene), (4) Circular iris (circle shrinks to center then expands from center with new scene). Create a TransitionManager.gd singleton that provides `transition(type: String, duration: float)` for any system to call.
- **Acceptance Criteria:**
  - [ ] 4 wipe transition shaders implemented
  - [ ] Each wipe fits the digital/sci-fi theme
  - [ ] TransitionManager.gd provides easy API
  - [ ] Configurable duration per transition
  - [ ] Transitions are smooth (no frame skip)
  - [ ] Each transition type used for appropriate context

### Task 38.8: Portal Shimmer Effect Between Rooms
- **Status:** TODO
- **Description:** For rooms connected by portals rather than doors (story rooms, special connections), create a portal shimmer visual. Model a portal frame (2m tall, 1.2m wide arch) with tech-styled trim. Inside the arch, apply a portal shader: the surface shows a shimmering view of the destination room (use a SubViewport rendering the destination and applying it as the portal texture), with a wavy distortion effect (animated UV offset), edge glow (fresnel rim in portal color), and floating data mote particles being drawn into the portal. The portal should pulse gently (brightness oscillation at 0.5Hz).
- **Acceptance Criteria:**
  - [ ] Portal frame model with tech trim
  - [ ] Destination visible through portal (SubViewport or fake)
  - [ ] Wavy distortion on portal surface
  - [ ] Fresnel rim glow at edges
  - [ ] Data mote particles drawn toward portal
  - [ ] Gentle pulse animation

### Task 38.9: Portal Entry Animation
- **Status:** TODO
- **Description:** Create the animation for the player entering a portal. When the player walks into the portal: the player character begins a dissolve effect (digital dissolution from the edges inward — pixel blocks scatter from the character), the portal's glow intensifies briefly, a whoosh particle effect plays (radial particles converging on the portal center), and the screen transitions using the pixel dissolve wipe (from Task 38.7). On the other side: the player materializes with the reverse dissolve (pixels assembling from scattered to solid), the destination portal's glow fades back to normal. Total entry+exit: 1.5-2 seconds.
- **Acceptance Criteria:**
  - [ ] Player dissolves digitally on portal entry
  - [ ] Portal glow intensifies during entry
  - [ ] Whoosh particle effect at entry moment
  - [ ] Pixel dissolve screen transition
  - [ ] Player materializes at destination portal
  - [ ] Total transition 1.5-2 seconds

### Task 38.10: Boss Door Dramatic Opening
- **Status:** TODO
- **Description:** The boss door opening (from Epic 37 Task 37.5) should be integrated into the transition system. When the player approaches the boss door: the standard door trigger is replaced with an interaction prompt ("Press E to enter"), on interaction the boss approach music intensifies (audio hook), the dramatic door opening animation plays (3 seconds with steam, lights, mechanical effort), the camera may push in slightly toward the door during opening (subtle zoom, 5% over 3 seconds), then the player walks through into the boss arena. This is the most significant door transition in the game and should feel like crossing a point of no return.
- **Acceptance Criteria:**
  - [ ] Interaction prompt instead of auto-open
  - [ ] Audio hook for music intensification
  - [ ] Full 3-second dramatic opening animation
  - [ ] Subtle camera push-in during opening
  - [ ] Player walks through voluntarily
  - [ ] Feels like a point of no return

### Task 38.11: Completion Portal Activation Sequence
- **Status:** TODO
- **Description:** Create the visual sequence for the compaction portal activating after boss defeat. Sequence (5 seconds): a point of white light appears at the center of the arena floor (0.5s), the point expands into a ring shape (0.5s), the ring rises to vertical and fills with energy (1s), the portal shader activates showing a view of the town (1s), the portal stabilizes with pulsing glow (1s), and a clear visual indicator appears ("Return to Town" text floats above the portal). The portal should feel like a reward — safe, inviting, warm. Blue-white color (#80C0FF) contrasts with the red battle lighting.
- **Acceptance Criteria:**
  - [ ] 5-second activation sequence
  - [ ] Point -> ring -> fill -> stabilize stages
  - [ ] Town visible through the portal surface
  - [ ] "Return to Town" text indicator
  - [ ] Blue-white inviting color scheme
  - [ ] Feels like a safe, rewarding exit

### Task 38.12: Portal Exit Animation — Return to Town
- **Status:** TODO
- **Description:** Create the visual for the player entering the compaction portal to return to town. When the player enters: white-out effect (screen fades to bright white instead of black — symbolizing emergence from the dark dungeon), the player dissolves into data particles that spiral into the portal, hold on white for 0.5 seconds, then fade into the town scene with a warm golden tint that gradually normalizes. The town should appear as a relief — warm, bright, safe after the cold dark dungeon. Play a brief triumphant musical sting (audio hook). The transition should feel like coming home.
- **Acceptance Criteria:**
  - [ ] White-out transition (not black — emergence)
  - [ ] Player dissolves into spiral data particles
  - [ ] 0.5s hold on white
  - [ ] Fade into town with warm golden tint
  - [ ] Musical sting audio hook
  - [ ] Feels like relief and homecoming

### Task 38.13: Dungeon Entry Transition — Town to Dungeon
- **Status:** TODO
- **Description:** Create the reverse transition: entering the dungeon from town. When the player interacts with the dungeon entrance in town: the dungeon portal activates (cool blue shimmer), the player steps in and dissolves, the screen transitions using a scan line wipe from warm (town colors) to cool (dungeon colors), the loading screen appears briefly with Floor 1 map, then fades into the dungeon entry room. The transition should feel like crossing a threshold from safety into danger — warm to cool, bright to dim, pastoral to industrial. Total transition: 2-3 seconds.
- **Acceptance Criteria:**
  - [ ] Dungeon portal activation in town
  - [ ] Scan line wipe from warm to cool palette
  - [ ] Loading screen with Floor 1 map
  - [ ] Fade into dungeon entry room
  - [ ] 2-3 second total transition
  - [ ] Feels like crossing into danger

### Task 38.14: Death and Respawn Transition
- **Status:** TODO
- **Description:** Create the visual transition for when the player dies and respawns. On death: screen desaturates rapidly (0.3s), the player character shatters into pixel fragments that scatter and dissolve, red vignette pulses once, screen fades to static noise (digital death), hold static for 1 second, then the static resolves into the respawn location (town or dungeon checkpoint depending on game state). Display "SYSTEM REBOOT" text during the static. The transition should feel impactful (you died) but not frustrating (quick, not drawn out). Total: 3 seconds.
- **Acceptance Criteria:**
  - [ ] Rapid desaturation on death
  - [ ] Player shatters into pixel fragments
  - [ ] Screen fades to static noise
  - [ ] "SYSTEM REBOOT" text during static
  - [ ] Static resolves into respawn location
  - [ ] Total 3 seconds, impactful but quick

### Task 38.15: Room-to-Room Preloading System
- **Status:** TODO
- **Description:** Implement a room preloading system that loads adjacent rooms in the background so transitions can be instant. Create a RoomPreloader.gd script that: identifies all rooms connected to the current room via doors, loads them asynchronously using ResourceLoader.load_threaded_request(), tracks loading progress, and marks rooms as ready when loaded. When the player approaches a door, the connected room should already be loaded (or nearly loaded). If loading is still in progress when the player reaches the door, show the loading screen. Unload rooms that are 2+ doors away to manage memory.
- **Acceptance Criteria:**
  - [ ] Adjacent rooms preloaded asynchronously
  - [ ] Loading uses ResourceLoader threaded loading
  - [ ] Rooms 2+ doors away are unloaded
  - [ ] Instant transitions when preloading succeeds
  - [ ] Graceful fallback to loading screen if still loading
  - [ ] Memory usage stays within budget

### Task 38.16: Transition Audio Hooks
- **Status:** TODO
- **Description:** Add audio hook signals for all transition types so the audio system (Epic 48-49) can play appropriate sounds. Define EventBus signals: `transition_door_open(door_type: String)`, `transition_door_close`, `transition_floor_descent(from_floor: int, to_floor: int)`, `transition_portal_enter(portal_type: String)`, `transition_portal_exit`, `transition_death`, `transition_respawn`. The door_type differentiates standard/boss/locked doors. The portal_type differentiates room/completion/dungeon_entry portals. Emit these signals at the correct moment in each transition animation (e.g., door_open when the physical opening begins, not when the trigger is activated).
- **Acceptance Criteria:**
  - [ ] EventBus signals defined for all transition types
  - [ ] Signals emitted at correct animation moments
  - [ ] Door type parameter differentiates door types
  - [ ] Portal type parameter differentiates portal types
  - [ ] Floor descent includes from/to floor numbers
  - [ ] All transition scripts emit their signals

### Task 38.17: Transition Settings and Accessibility
- **Status:** TODO
- **Description:** Add player-configurable settings for transitions. Options: transition_speed (Normal/Fast/Instant — Normal plays full animations, Fast halves duration, Instant cuts immediately), reduce_screen_effects (reduces or disables wipe effects, flashes, and camera shakes for motion-sensitive players), show_loading_tips (on/off). Apply these settings in TransitionManager.gd so all transitions respect the player's preferences. Fast mode should still feel polished (just quicker), and Instant mode should be functional (hard cuts between rooms). Ensure no gameplay advantage from faster transitions.
- **Acceptance Criteria:**
  - [ ] Speed setting: Normal/Fast/Instant
  - [ ] Reduce screen effects option
  - [ ] Show loading tips toggle
  - [ ] All transitions respect settings
  - [ ] Fast mode still looks polished
  - [ ] Instant mode is functional without glitches

### Task 38.18: Transition Edge Cases and Polish
- **Status:** TODO
- **Description:** Test and fix edge cases in all transitions. Test: player walking into a door while already in a transition (should be blocked), rapid door triggering (open-close-open quickly), dying during a transition (should complete death transition instead), interacting with a portal during combat (should be blocked), floor transition interrupted by game pause, and loading screen timeout (if loading takes more than 3 seconds, show a more detailed loading screen). For each edge case, implement graceful handling — no crashes, no soft-locks, no visual glitches.
- **Acceptance Criteria:**
  - [ ] Double-transition prevented (state locked during transition)
  - [ ] Rapid door triggering handled gracefully
  - [ ] Death during transition handled
  - [ ] Portal blocked during combat
  - [ ] Pause during transition handled
  - [ ] Loading timeout handled with extended screen

### Task 38.19: Performance Profiling of Transitions
- **Status:** TODO
- **Description:** Profile every transition type for frame time stability. Transitions must maintain 60fps during the animation — no frame drops that cause visible stutter. Profile: door open/close (with particles), floor descent (with parallax scrolling), portal entry/exit (with dissolution shader), screen wipes (shader cost), and cross-fade. The most expensive transition (portal with SubViewport) should be optimized: reduce SubViewport resolution if needed, or replace with a pre-captured static image. Document per-transition costs.
- **Acceptance Criteria:**
  - [ ] All transition types profiled for frame stability
  - [ ] No frame drops during any transition
  - [ ] Portal SubViewport optimized if needed
  - [ ] Screen wipe shader costs documented
  - [ ] 60fps maintained during all transitions
  - [ ] Performance documented per transition type

### Task 38.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture video recordings of every transition type: standard door, locked door, boss door, floor descent with title card, portal entry/exit, dungeon entry from town, return to town via compaction portal, death/respawn, and loading screen. Record with Normal and Fast speed settings. Save to `_bmad-output/visual-overhaul/screenshots/epic-38/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] All transition types captured in video
  - [ ] Normal and Fast speed settings shown
  - [ ] Loading screen captured with map
  - [ ] Boss door dramatic opening captured
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 33** (Dungeon Lighting) — Lighting for room reveals
- **Epic 34** (Floor Themes) — Floor-specific visuals for title cards and tinting
- **Epic 37** (Boss Arena) — Boss door and completion portal

## Notes

- Transitions happen hundreds of times per play session — they must be smooth and not annoying
- The Fast/Instant speed settings are important for experienced players who don't want to wait
- Preloading is the highest-impact technical task — seamless transitions depend on it
- The emotional arc of transitions matters: town->dungeon (anticipation), room->room (flow), floor->floor (deeper), boss door (dread), victory portal (relief), death (impact), respawn (determination)
- Keep all transitions under 3 seconds as per NFR2
