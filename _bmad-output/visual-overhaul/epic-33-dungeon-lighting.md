---
epic: 33
title: "Dungeon Lighting Overhaul"
phase: 6 — Dungeon Environment
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 33: Dungeon Lighting Overhaul

## Overview

Implement per-room mood lighting setups for the dungeon: flickering damaged lights, emergency red lighting for combat encounters, serene blue for story rooms, warm gold for loot rooms, spotlight on important items, volumetric fog per room, and light through grated floors. Each room type should have a distinct lighting mood that communicates its purpose to the player before they fully enter.

## Success Criteria

- Each room type (combat, loot, corridor, story, boss) has a distinct lighting preset
- Flickering lights create tension in damaged/corrupted areas
- Combat triggers red emergency lighting shift
- Loot rooms feel rewarding with warm gold accent lights
- Story rooms feel calm with cool blue ambient
- Volumetric fog adds depth and atmosphere per room
- Grated floors allow light to pass through from below
- Transitions between room lighting are smooth (no harsh cuts)
- All dungeon lighting maintains 60fps

---

## Tasks

### Task 33.1: Define Room Lighting Presets
- **Status:** TODO
- **Description:** Design and document the lighting preset for each dungeon room type. Corridor: dim ambient with periodic ceiling light panels, cool gray tone (#8090A0), minimal shadows, functional industrial feel. Combat Room: neutral start that shifts to red emergency on encounter trigger, brighter overall for gameplay readability. Loot Room: warm gold accent (#FFD080) spotlighting the center (chest location), darker corners creating focus. Story Room: cool blue ambient (#8090C0) with soft shadows, terminal screens providing teal accent, meditative calm atmosphere. Boss Room: dramatic with strong contrast, defined in Epic 37. Document each preset with color values, light positions, intensities, and shadow settings.
- **Acceptance Criteria:**
  - [ ] Corridor lighting preset defined with values
  - [ ] Combat room preset defined (pre-combat and active combat)
  - [ ] Loot room preset defined with spotlight specs
  - [ ] Story room preset defined with cool ambient values
  - [ ] All presets documented with color values and intensities
  - [ ] Reference mood images collected for each type

### Task 33.2: Create DungeonRoomLighting Resource
- **Status:** TODO
- **Description:** Create a custom Resource class `DungeonRoomLighting` (res://resources/dungeon/) with exported properties for room lighting configuration: ambient_color, ambient_energy, fog_color, fog_density, primary_light_color, primary_light_energy, accent_light_color, accent_light_energy, ceiling_panel_emission_color, ceiling_panel_emission_energy, and combat_override flag with combat-specific values. Create .tres preset files for each room type (corridor.tres, combat.tres, loot.tres, story.tres). The resource should be assignable per room instance so each room applies its lighting when the player enters.
- **Acceptance Criteria:**
  - [ ] DungeonRoomLighting Resource class created
  - [ ] All relevant lighting properties exported
  - [ ] Preset .tres files for corridor, combat, loot, story
  - [ ] Resources loadable and assignable per room
  - [ ] Combat override values included in combat preset
  - [ ] Resource follows project patterns

### Task 33.3: Room Lighting Controller Script
- **Status:** TODO
- **Description:** Create a RoomLightingController.gd script that manages lighting for a dungeon room. Attach to each room's root node. The script holds references to all light nodes in the room (via @export or node groups). On `apply_preset(preset: DungeonRoomLighting)`, it sets all light properties to match the preset. On `transition_to(preset: DungeonRoomLighting, duration: float)`, it smoothly tweens all lights from current to target values. The script should respond to EventBus signals: `combat_started` triggers transition to combat lighting, `combat_ended` transitions back to the room's base preset. Provide `set_flicker(enabled: bool)` for damaged light effect.
- **Acceptance Criteria:**
  - [ ] Script manages all lights in a room
  - [ ] apply_preset() immediately sets lighting
  - [ ] transition_to() smoothly tweens lighting
  - [ ] Responds to combat_started/combat_ended signals
  - [ ] set_flicker() toggles damaged light effect
  - [ ] Static typed, follows project standards

### Task 33.4: Corridor Lighting Setup
- **Status:** TODO
- **Description:** Implement the corridor room lighting. Place ceiling light panel OmniLight3D nodes at regular intervals (every 2 tiles / 4m) with cool white color (#B0C0D0) and moderate energy (0.6-0.8). Set the ceiling light panel tile emission to match. Add very dim ambient fill (#303840 at energy 0.1) so areas between lights aren't pitch black. Create a slight gradient — lights near doors should be brighter, mid-corridor dimmer, creating a subtle rhythm. The corridor should feel functional and industrial — lit well enough to navigate but not warm or inviting. Test with 3-4 connected corridor sections to verify the rhythm.
- **Acceptance Criteria:**
  - [ ] Ceiling lights at regular intervals
  - [ ] Cool white color, not warm
  - [ ] Dim ambient prevents pitch black between lights
  - [ ] Light rhythm: brighter near doors, dimmer mid-corridor
  - [ ] Functional industrial atmosphere achieved
  - [ ] Tested with multiple connected sections

### Task 33.5: Combat Room Lighting — Pre-Combat State
- **Status:** TODO
- **Description:** Set up the combat room's default (pre-combat) lighting. Before enemies activate, the room should have standard industrial lighting similar to corridors but slightly brighter overall (energy 0.8-1.0) for better gameplay readability. Place ceiling lights in a grid pattern appropriate to room size. Add subtle warm accent lights (#FFF0D0) near any loot drop positions. Include a dim ambient fill (#404850 at energy 0.15). The pre-combat lighting should feel normal — nothing alarming — so the shift to combat lighting has maximum impact. Ensure the lighting provides enough visibility for the player to survey the room layout and plan.
- **Acceptance Criteria:**
  - [ ] Brighter than corridor (good gameplay visibility)
  - [ ] Ceiling lights in grid pattern
  - [ ] Subtle warm accents at loot drop positions
  - [ ] Dim ambient fill for consistent baseline
  - [ ] Atmosphere feels normal/industrial
  - [ ] Room layout clearly visible for tactical planning

### Task 33.6: Combat Room Lighting — Emergency Red Shift
- **Status:** TODO
- **Description:** Implement the dramatic lighting shift when combat begins. On `combat_started` signal: tween ceiling light color from white to deep red (#FF3030) over 0.5 seconds, reduce ambient to near-black, add pulsing red accent lights at room corners (slow sine pulse between 0.3 and 0.8 energy), and activate a red-tinted volumetric fog. The red emergency lighting should create urgency and tension while maintaining gameplay readability — enemies must still be clearly visible against the environment. On `combat_ended`: tween back to pre-combat lighting over 1.5 seconds (slower to create a relief feeling), then trigger loot room warm shift if loot drops.
- **Acceptance Criteria:**
  - [ ] Smooth 0.5s transition to red emergency on combat start
  - [ ] Ceiling lights shift to deep red
  - [ ] Corner accent lights pulse at slow rate
  - [ ] Red volumetric fog activates
  - [ ] Enemies remain clearly visible (readability preserved)
  - [ ] 1.5s transition back on combat end (relief feeling)

### Task 33.7: Loot Room Lighting — Warm Gold Spotlight
- **Status:** TODO
- **Description:** Create the loot room's signature warm, rewarding atmosphere. Place a central SpotLight3D aimed downward at the chest/loot position with warm gold color (#FFD080), energy 1.5, and a focused cone angle (15-20 degrees) creating a distinct pool of golden light on the floor. Reduce the room's ambient to be dimmer than corridor (#252830 at energy 0.1) so the spotlight contrast is dramatic. Add rim lights around the room perimeter in dim warm (#FFE0B0 at energy 0.2) to keep wall detail visible. The effect should feel like discovering treasure — the golden light is the reward signal that the player learns to associate with loot.
- **Acceptance Criteria:**
  - [ ] Central spotlight on loot position in warm gold
  - [ ] Dramatic contrast (bright spotlight, dim room)
  - [ ] Focused cone creates distinct pool of light
  - [ ] Dim rim lights keep walls visible
  - [ ] Atmosphere feels rewarding and special
  - [ ] Player instantly recognizes "this is a loot room"

### Task 33.8: Story Room Lighting — Serene Blue Ambient
- **Status:** TODO
- **Description:** Design the story room's calm, contemplative atmosphere. Use a cool blue ambient (#6080C0 at energy 0.3) as the dominant light, creating an underwater/digital serenity feel. Place soft OmniLight3D nodes near the data terminal and any NPC positions with teal accent (#40C0C0 at energy 0.4). Reduce ceiling light intensity to minimal (these rooms feel like the overhead lights have dimmed to standby). Terminal screen emission should be the primary directional light source, casting teal light on nearby surfaces. Optional: add a very subtle blue volumetric fog (density 0.005) for ethereal atmosphere.
- **Acceptance Criteria:**
  - [ ] Cool blue ambient creates calm atmosphere
  - [ ] Teal accent near terminals and NPC positions
  - [ ] Ceiling lights at minimal/standby level
  - [ ] Terminal screens cast teal directional light
  - [ ] Optional blue fog adds ethereal quality
  - [ ] Atmosphere is contemplative, not eerie

### Task 33.9: Flickering Damaged Light Effect
- **Status:** TODO
- **Description:** Implement a flickering light effect for damaged/corrupted dungeon areas. Create a FlickerLight.gd script that modulates a light's energy and/or visibility over time. Use a combination of: rapid on/off flickering (random chance each frame to toggle), slow dimming cycles (sine wave), and occasional complete blackout (1-3 seconds of dark, then snap back on). Add a sparking particle effect (small white-yellow GPU particles, 2-3 at a time) that plays during the blackout phase. The flicker pattern should be randomized per light instance so adjacent lights don't flicker in sync. Apply to 20-30% of ceiling lights in damaged corridor areas.
- **Acceptance Criteria:**
  - [ ] FlickerLight.gd modulates light energy randomly
  - [ ] Rapid flicker, slow dim, and blackout phases
  - [ ] Spark particle effect during blackout
  - [ ] Each light instance has unique flicker pattern
  - [ ] Applied to 20-30% of lights in damaged areas
  - [ ] Flicker creates tension without causing discomfort

### Task 33.10: Volumetric Fog Per Room
- **Status:** TODO
- **Description:** Add room-specific volumetric fog using FogVolume nodes sized to each room's dimensions. Each room type has different fog: Corridors get minimal fog (density 0.005, neutral gray). Combat rooms get thicker fog that shifts to red during combat (density 0.01 neutral, 0.02 red). Loot rooms get warm fog concentrated in the spotlight beam (use a thin FogVolume cylinder aligned with the spotlight). Story rooms get subtle blue fog. The fog should be contained within room boundaries (FogVolume doesn't leak into adjacent rooms). Adjust fog density so it adds atmosphere without obscuring gameplay — the player must always be able to see enemies and obstacles.
- **Acceptance Criteria:**
  - [ ] FogVolume nodes sized to each room
  - [ ] Room-type-specific fog colors and densities
  - [ ] Fog contained within room boundaries
  - [ ] Combat fog shifts to red with lighting
  - [ ] Loot room fog concentrated in spotlight beam
  - [ ] Gameplay visibility maintained (enemies always visible)

### Task 33.11: Light Through Grated Floors
- **Status:** TODO
- **Description:** Implement the visual effect of light passing through grated floor tiles from rooms below. Place OmniLight3D or SpotLight3D nodes below grated floor tiles aimed upward. Set the light color to match the lighting of the "room below" (cool blue for deep levels, warm for upper levels, red for combat areas). The light should cast the grate shadow pattern upward onto characters and nearby walls — this requires the grate mesh to cast shadows (enabled in the MeshInstance3D). Adjust light intensity so the effect is visible but not dominant (energy 0.3-0.5). This effect adds depth and suggests a larger dungeon structure above and below.
- **Acceptance Criteria:**
  - [ ] Upward light through grated floor tiles
  - [ ] Grate shadow pattern cast on characters and walls
  - [ ] Light color suggests the "level below"
  - [ ] Effect adds depth without dominating the room
  - [ ] Grate mesh casts proper shadow pattern
  - [ ] Visible at isometric camera angle

### Task 33.12: Spotlight on Important Items
- **Status:** TODO
- **Description:** Create a reusable ItemSpotlight scene that can be placed over any important interactable in the dungeon: loot drops, quest items, story terminals, crystal pickups. The spotlight is a SpotLight3D aimed downward with: warm white color (#FFF0D0), narrow cone (10-15 degrees), energy 1.0-1.5, and a soft-edged cookie texture creating a clean circular pool. Add a subtle GPUParticles3D sparkle effect (tiny white particles floating upward in the light beam, 5-10 particles, slow drift). The spotlight should activate on a signal (item_spawned) and fade in over 0.3 seconds. It should deactivate when the item is collected.
- **Acceptance Criteria:**
  - [ ] Reusable ItemSpotlight.tscn scene created
  - [ ] Warm white spotlight with narrow cone
  - [ ] Sparkle particles in the light beam
  - [ ] Fade-in animation on item spawn
  - [ ] Fade-out on item collection
  - [ ] Clearly highlights items in any room lighting condition

### Task 33.13: Room Transition Lighting Blend
- **Status:** TODO
- **Description:** Implement smooth lighting transitions as the player moves between rooms. When the player crosses a room boundary (door threshold), both the old and new room's lighting should be active with blended influence. Use a crossfade approach: as the player approaches a door, begin fading the current room's lighting down and the new room's lighting up over 1-2 seconds (or based on position). The corridor between rooms should have its own lighting that bridges the two moods. Prevent abrupt lighting changes that break immersion — the player should never see a sudden brightness/color jump.
- **Acceptance Criteria:**
  - [ ] Lighting transitions smoothly between rooms
  - [ ] No abrupt brightness or color jumps at doorways
  - [ ] Crossfade over 1-2 seconds
  - [ ] Corridor lighting bridges room moods
  - [ ] Transition works for all room type combinations
  - [ ] Player doesn't notice the transition mechanism

### Task 33.14: Emergency Siren Light for Boss Approach
- **Status:** TODO
- **Description:** Create a special lighting effect for the corridor approaching a boss room. Place rotating red warning lights (SpotLight3D with cookie texture rotating via AnimationPlayer) every 4m along the approach corridor. The lights should sweep in a slow circular pattern, casting moving red beams across the walls and floor. Add a pulsing red ambient overlay that increases in intensity as the player gets closer to the boss door. Include flickering overhead lights (mixing the damaged flicker from Task 33.9). This approach corridor should build dread and anticipation through lighting alone.
- **Acceptance Criteria:**
  - [ ] Rotating red warning lights in approach corridor
  - [ ] Lights sweep beams across walls and floor
  - [ ] Pulsing red ambient increases toward boss door
  - [ ] Overhead lights flicker (damaged/unstable)
  - [ ] Effect builds dread and anticipation
  - [ ] Clear signal that "boss is ahead"

### Task 33.15: Crystal and Mushroom Light Contribution
- **Status:** TODO
- **Description:** Configure the OmniLight3D nodes on energy crystal and bioluminescent mushroom props (from Epic 32) to contribute meaningfully to room lighting. Crystals should cast colored light (blue, green, or purple matching the crystal type) in a 2-3m radius with energy 0.4-0.6. Mushrooms should cast cool cyan light in a 1-2m radius with energy 0.2-0.3 (dimmer, more subtle). In rooms that rely on these organic/crystal light sources (no ceiling panels), the combined effect should provide enough visibility for gameplay while maintaining an alien, beautiful atmosphere. Test a room lit ONLY by crystals and mushrooms.
- **Acceptance Criteria:**
  - [ ] Crystal lights cast colored light matching crystal type
  - [ ] Mushroom lights cast cool cyan glow
  - [ ] Combined crystal/mushroom lighting provides gameplay visibility
  - [ ] Atmosphere is alien and beautiful, not just dark
  - [ ] A room lit only by organic sources is playable
  - [ ] Light contributions don't over-brighten when combined with ceiling lights

### Task 33.16: Light Destruction During Combat
- **Status:** TODO
- **Description:** Implement lights that break during combat for dramatic effect. When a combat room is active, script a chance (triggered by specific enemy attacks or reaching a damage threshold) for ceiling light panels to explode: the light flickers rapidly, spark particles emit, then the light snaps off permanently (for that encounter). The room gets progressively darker as lights break, increasing tension. Limit this to 1-2 lights per encounter (don't make the room unplayable). Broken lights stay dark until the room is reset. Add a small glass shard particle burst when a light breaks.
- **Acceptance Criteria:**
  - [ ] Ceiling lights can break during combat
  - [ ] Flicker -> spark -> snap off sequence
  - [ ] Glass shard particle on destruction
  - [ ] Room gets progressively darker (max 1-2 lights)
  - [ ] Room remains playable with reduced lighting
  - [ ] Broken lights stay dark until room reset

### Task 33.17: Ambient Light Variation by Dungeon Depth
- **Status:** TODO
- **Description:** Implement a system where the ambient light level decreases with dungeon floor depth, creating a sense of descending deeper into darkness. Floor 1 (tutorial): ambient energy 0.2, cool white. Floor 2: ambient energy 0.15, slightly blue. Floor 3: ambient energy 0.1, blue-gray. Floor 4: ambient energy 0.05, near-black with purple tint. Floor 5 (boss): ambient energy 0.02, pitch black except for point lights. This gradient makes deeper floors feel more dangerous and claustrophobic. The RoomLightingController should modify its preset values based on the current floor number.
- **Acceptance Criteria:**
  - [ ] Ambient light decreases with floor depth
  - [ ] Floor 1 is brightest, Floor 5 is nearly dark
  - [ ] Color shifts from white to blue to purple with depth
  - [ ] Deeper floors feel more dangerous
  - [ ] RoomLightingController adjusts based on floor number
  - [ ] All floors remain playable despite reduced ambient

### Task 33.18: Light Organization and Hierarchy
- **Status:** TODO
- **Description:** Organize all dungeon light nodes into a clean scene hierarchy for maintainability. In each room scene, create: `Lighting/CeilingPanels`, `Lighting/AccentLights`, `Lighting/PropLights`, `Lighting/FogVolumes`, `Lighting/Spotlights`. Name each light descriptively (e.g., `CeilingPanel_NW`, `Crystal_Blue_01`). Create an editor group `dungeon_lights` for batch operations. Document the lighting hierarchy in a comment at the top of RoomLightingController.gd. This organization is essential because dungeon rooms are cloned and modified frequently.
- **Acceptance Criteria:**
  - [ ] All lights organized into named parent groups
  - [ ] Descriptive light node names
  - [ ] Editor groups for batch operations
  - [ ] Documentation in controller script
  - [ ] Hierarchy consistent across all room types
  - [ ] Easy to iterate on room lighting

### Task 33.19: Performance Profiling
- **Status:** TODO
- **Description:** Profile dungeon lighting performance with the worst-case scenario: a large combat room with all lighting active (ceiling panels, combat red shift, volumetric fog, crystal lights, mushroom lights, flickering damaged lights, item spotlight, and light through grated floor). Measure total frame time, shadow rendering cost, fog rendering cost, and light count. Target: 60fps at 1080p. If over budget: reduce shadow-casting lights (only the 3-4 most important cast shadows), reduce fog quality, reduce flicker update rate, disable fog in corridors (only in rooms). Document all measurements and optimizations.
- **Acceptance Criteria:**
  - [ ] Worst-case room profiled with all effects
  - [ ] Frame time breakdown per lighting feature
  - [ ] 60fps target achieved
  - [ ] Shadow-casting light count optimized
  - [ ] Optimizations documented
  - [ ] Performance acceptable on mid-range hardware

### Task 33.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture before/after screenshots for each room type's lighting. Show: corridor with industrial lighting, combat room pre-combat and during combat (red shift), loot room with gold spotlight, story room with blue ambient, flickering damaged corridor, grated floor with upward light, boss approach with warning lights, and the ambient depth gradient (Floor 1 vs Floor 5 comparison). Record video of the combat lighting transition. Save to `_bmad-output/visual-overhaul/screenshots/epic-33/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Before/after for each room type
  - [ ] Combat lighting transition video
  - [ ] Floor depth comparison (Floor 1 vs 5)
  - [ ] Special effects captured (flicker, grate light, spotlight)
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 31** (Dungeon Tileset) — Room geometry for lighting
- **Epic 32** (Dungeon Props) — Emissive props for light contribution

## Notes

- Room lighting is the primary mood communicator — players should know the room type from the lighting before reading any UI
- Combat readability is non-negotiable — red emergency lighting is dramatic but enemies MUST be clearly visible
- Keep shadow-casting light count low (4-6 per room max) for performance
- Volumetric fog is expensive; use it sparingly and only where it adds significant value
- Test all lighting from the isometric gameplay camera, not the free editor camera
