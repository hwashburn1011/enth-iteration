---
epic: 30
title: "Town Layout Polish"
phase: 5 — Town Environment
status: TODO
priority: medium
estimated_tasks: 20
---

# Epic 30: Town Layout Polish

## Overview

Hand-place every prop for intentional visual composition, create visual sightlines to key locations, add foreground framing elements, ensure the camera reveals the town gradually as the player moves, route paths to guide the player naturally to important areas, use area lighting to create distinct mood zones, and establish visual hierarchy where important interactive elements are the brightest and most visually prominent. This epic transforms the town from a functional space into a carefully designed experience.

## Success Criteria

- Every prop placed with compositional intent (no randomly scattered objects)
- Clear sightlines from the town entrance to the dungeon gate, shops, and NPCs
- Foreground elements (fences, planters, overhangs) frame key views
- Camera reveals areas progressively as the player walks (not everything visible at once)
- Path routing intuitively guides players to key locations without signage
- Lighting creates 3-4 distinct mood zones (market, residential, garden, dungeon approach)
- Interactive objects are visually brightest/most prominent in their area
- Town feels cohesive, cozy, and intentionally designed

---

## Tasks

### Task 30.1: Top-Down Layout Analysis and Planning
- **Status:** TODO
- **Description:** Take an overhead screenshot of the current Town.tscn layout and analyze the composition on paper or in an image editor. Mark: the player spawn/entry point, all key interactive locations (NPC positions, dungeon entrance, shop, well), the current path network, areas that feel empty, areas that feel cluttered, and the camera's visible frustum at key positions. Identify the critical player journey: spawn -> first NPC -> shop -> well -> dungeon entrance. Sketch a revised layout plan that creates a clear path for this journey with visual interest along the way. Reference Stardew Valley's Pelican Town layout for inspiration (central path with branching areas).
- **Acceptance Criteria:**
  - [ ] Current layout documented with overhead screenshot
  - [ ] All key locations marked and labeled
  - [ ] Critical player journey path identified
  - [ ] Empty and cluttered areas noted
  - [ ] Revised layout plan sketched with improvements
  - [ ] Reference images from similar games collected

### Task 30.2: Define Path Network and Routing
- **Status:** TODO
- **Description:** Design the path network that guides players through the town. Define a main path (widest, most visible) from the town entrance to the central area, with secondary paths branching to each key location. Paths should follow the principle of "reveal and reward" — the player sees a hint of what's ahead (a lantern, a building corner, a colorful prop) that draws them forward. Use path width to communicate importance: main path 3-4m wide, secondary paths 2m wide, optional exploration paths 1-1.5m wide. In the editor, adjust terrain textures and prop placement to create these path widths. Avoid dead-end paths unless they lead to a reward.
- **Acceptance Criteria:**
  - [ ] Main path clearly defined (widest, most visible)
  - [ ] Secondary paths branch to all key locations
  - [ ] Path widths communicate importance hierarchy
  - [ ] No unintentional dead ends
  - [ ] Each path has a visual draw element ahead
  - [ ] Paths feel natural (following terrain, not grid-aligned)

### Task 30.3: Sightline to Dungeon Entrance
- **Status:** TODO
- **Description:** Create a clear visual sightline from the main town area to the dungeon entrance so players always know where the action is. Position the dungeon entrance at the end of a visible corridor or opening between buildings. Clear any props or vegetation that block the view. Add a strong visual accent at the dungeon entrance: a cool-toned light (purple/blue), a distinctive archway or gate structure, and subtle particle effects (faint digital glitch, dark energy). The dungeon entrance should be visible from the town center but feel "distant" — requiring the player to walk past other interesting locations to reach it.
- **Acceptance Criteria:**
  - [ ] Dungeon entrance visible from main town area
  - [ ] No props blocking the sightline
  - [ ] Cool-toned accent light distinguishes it from warm town
  - [ ] Distinctive archway or structure marks the entrance
  - [ ] Entrance visible but requires walking through town to reach
  - [ ] Visual contrast with surrounding warm environment

### Task 30.4: Sightline to Shop and NPC Locations
- **Status:** TODO
- **Description:** Create visual sightlines from the main path to each NPC location and shop. Each NPC location should have a visual "beacon" — something bright or distinctive that catches the eye and draws the player off the main path: a colorful awning for the shop, a glowing forge for the blacksmith, a garden with flowers for nature NPCs, a bookshelf or glowing terminal for the AI Sage. Position these beacons so they are partially visible from the main path, creating curiosity. Ensure no two NPC locations compete visually — each should be visible from a different section of the main path.
- **Acceptance Criteria:**
  - [ ] Each NPC location has a distinct visual beacon
  - [ ] Beacons partially visible from the main path
  - [ ] No two beacons compete from the same viewpoint
  - [ ] Visual beacons match NPC character/function
  - [ ] Players are naturally drawn to explore toward beacons
  - [ ] Shop is the most prominent beacon (first interaction)

### Task 30.5: Foreground Framing Elements
- **Status:** TODO
- **Description:** Add foreground framing elements that create depth and frame key views. Place fence sections, planters, overhanging tree branches, and building eaves along the edges of the isometric camera's view at key composition points. These elements should partially overlap the camera view from the nearest edge, creating a "looking through" effect that adds depth. At the town entrance, frame the first view of the town with fence posts and an overhanging tree. At the dungeon approach, frame with industrial props. Keep framing elements on the near sides only (left/bottom in isometric) to avoid obscuring gameplay.
- **Acceptance Criteria:**
  - [ ] Foreground framing at town entrance (first impression)
  - [ ] Foreground framing at dungeon approach
  - [ ] At least 3 key viewpoints have framing elements
  - [ ] Framing creates depth without obscuring gameplay
  - [ ] Elements appropriate to each area's theme
  - [ ] Near-side placement only (no gameplay obstruction)

### Task 30.6: Progressive Reveal — Town Entrance Sequence
- **Status:** TODO
- **Description:** Design the player's first moments entering the town as a progressive reveal. When the player spawns or enters from outside, they should see: first, a narrow view between fences or walls (constrained, focused), then the path opens up to reveal the town center (expansive, rewarding), then individual areas become visible as the player advances. Place props and terrain features to create this "narrow to wide" feeling. Use building placement and vegetation to block the full town from being visible at the spawn point. The reveal should happen naturally through movement, not cutscenes — the level geometry guides the eye.
- **Acceptance Criteria:**
  - [ ] Town is NOT fully visible from spawn point
  - [ ] Initial view is constrained (narrow entry)
  - [ ] Main town center is revealed as player moves forward
  - [ ] Individual areas reveal progressively with movement
  - [ ] Reveal feels natural (geometry guides it, not artificial walls)
  - [ ] First impression is "I want to explore this"

### Task 30.7: Prop Clustering for Visual Storytelling
- **Status:** TODO
- **Description:** Group props into intentional clusters that tell micro-stories about life in the town. Create 5-7 prop clusters: a market stall (crates, barrels, a signpost, lantern), a resting spot (bench, flower pot, lantern), a work area (tools, barrel, crate), a garden corner (planters, fence, water bucket), a notice board area (signpost, bench, lantern). Each cluster should have 3-5 props arranged in a natural grouping, not lined up in a grid. Vary the rotation, height, and spacing of props within each cluster. Position clusters at path intersections and resting points to give players visual landmarks for navigation.
- **Acceptance Criteria:**
  - [ ] 5-7 distinct prop clusters created
  - [ ] Each cluster tells a visual story about town life
  - [ ] Props within clusters have varied rotation/spacing
  - [ ] No grid-aligned or perfectly symmetrical arrangements
  - [ ] Clusters placed at path intersections as landmarks
  - [ ] Clusters are navigational reference points

### Task 30.8: Visual Hierarchy — Interactive Object Prominence
- **Status:** TODO
- **Description:** Ensure all interactive objects (NPCs, shop interfaces, dungeon entrance, quest givers, save points) are the most visually prominent elements in their area. Increase prominence through: brighter local lighting (add an OmniLight3D near each interactive element), more saturated colors compared to background props, clear ground space around the object (no clutter obscuring it), and emissive or glowing accents. Non-interactive background props should be slightly desaturated and receive less direct light. The visual hierarchy should guide the player's eye: interactive things pop, decorative things recede.
- **Acceptance Criteria:**
  - [ ] All interactive objects have dedicated local lighting
  - [ ] Interactive objects more saturated than background props
  - [ ] Clear ground space around each interactive element
  - [ ] Emissive accents on interactive objects
  - [ ] Background props slightly desaturated
  - [ ] Player's eye naturally drawn to interactive elements first

### Task 30.9: Ground Texture Variation for Path Definition
- **Status:** TODO
- **Description:** Enhance ground texture painting (from Epic 23) to clearly define paths, gathering areas, and boundaries. Main paths should have a smooth packed-dirt or cobblestone texture that is visually distinct from the grassy areas on either side. Path edges should have a soft blend (not a hard line) between path and grass. Gathering areas (in front of shops, around the well, town center) should have a wider stone/cobble area suggesting high traffic. Garden areas should have richer, darker soil texture. The dungeon approach path should transition from warm earth to cooler stone/metal to foreshadow the dungeon aesthetic.
- **Acceptance Criteria:**
  - [ ] Main paths visually distinct from surrounding grass
  - [ ] Path edges blend softly into grass (no hard lines)
  - [ ] Gathering areas have wider paved/packed texture
  - [ ] Garden areas have distinct soil texture
  - [ ] Dungeon approach transitions to cooler ground texture
  - [ ] Ground texture reinforces path routing from Task 30.2

### Task 30.10: Vertical Variation and Elevation Interest
- **Status:** TODO
- **Description:** Add subtle elevation changes and vertical props to break up the flat town plane and create visual interest. Possibilities: a low stone wall creating a garden terrace (0.3-0.5m step), stairs connecting two slightly different levels, a raised building foundation (buildings sit 0.1-0.2m above ground), a sunken area around the well, a gentle slope leading down to a stream or pond. Add vertical props: a town clock or bell tower visible from everywhere, tall signposts, stacked crates at the market, tall trees at key landmarks. The goal is variety in the silhouette when viewed from any angle.
- **Acceptance Criteria:**
  - [ ] At least 2 subtle elevation changes in the town
  - [ ] Stairs or ramps connect level changes naturally
  - [ ] Buildings sit on slightly raised foundations
  - [ ] Vertical landmark (tower/tall tree) visible from most areas
  - [ ] Town silhouette is varied (not flat) from all angles
  - [ ] Elevation changes feel natural, not artificial

### Task 30.11: Boundary Design — Preventing "Edge of the World"
- **Status:** TODO
- **Description:** Design the town boundaries so players never see the edge of the playable area as a hard wall or void. Use natural boundary elements: dense tree lines, rocky outcroppings, building walls, fences that connect to vegetation, and cliffs or drops. Each boundary should look like the world continues beyond it — suggest roads leading to other places (blocked by a gate or fallen tree "for now"), forest continuing into the distance, or mountains in the background. Ensure the collision boundaries match the visual boundaries (no invisible walls in open-looking areas). Add distant background elements (painted skybox or low-LOD distant props) beyond the boundaries.
- **Acceptance Criteria:**
  - [ ] No visible "edge of the world" from any gameplay position
  - [ ] Natural boundary elements (trees, rocks, buildings, fences)
  - [ ] World appears to continue beyond boundaries
  - [ ] At least one blocked road suggesting future expansion
  - [ ] Collision boundaries match visual boundaries exactly
  - [ ] Distant background elements beyond play area

### Task 30.12: Mood Zone — Market Area
- **Status:** TODO
- **Description:** Design the market area as the busiest, brightest, most colorful zone in the town. Place market stalls with colorful awnings (bright red, blue, yellow fabric), display crates with colorful goods visible on top, multiple lanterns for bright warm lighting, a signpost directing to the stall. Add ground clutter: a few scattered items on the ground (fallen fruit, loose coins) to suggest busy commerce. Position the market on the main path so the player passes through it naturally. The market should feel bustling and warm — the most "alive" area of the town.
- **Acceptance Criteria:**
  - [ ] Market area is the brightest zone in town
  - [ ] Colorful awnings and displayed goods add vibrancy
  - [ ] Multiple light sources create a well-lit area
  - [ ] Ground clutter suggests busy activity
  - [ ] Market is on the main path (players pass through naturally)
  - [ ] Zone feels bustling and commercially alive

### Task 30.13: Mood Zone — Residential Area
- **Status:** TODO
- **Description:** Design the residential area as a cozy, quiet retreat. Warmer lighting from windows and lanterns but dimmer overall than the market. Place personal props: benches, flower pots on windowsills, a clothesline between buildings, a door mat, firewood stacked against a wall. Fewer and warmer lanterns create intimate pools of light with darker gaps. Trees and fences provide enclosure, creating a sheltered feeling. Sounds (prepared in zones) should be quieter here. The residential area should feel like coming home — safe, warm, and peaceful.
- **Acceptance Criteria:**
  - [ ] Residential zone is warmer but dimmer than market
  - [ ] Personal props suggest daily life (clothesline, firewood, etc.)
  - [ ] Intimate light pools with darker gaps between
  - [ ] Trees and fences create sheltered, enclosed feeling
  - [ ] Zone feels cozy, safe, and homelike
  - [ ] Visually distinct from the busy market area

### Task 30.14: Mood Zone — Garden / Park Area
- **Status:** TODO
- **Description:** Design a garden or park area as a peaceful, natural space with lush vegetation and dappled light. Plant dense flower patches with multiple colors, place a bench under a large tree, add a small pond or fountain, use hedge rows or low stone walls to define garden beds. Lighting should be the dappled tree light from Epic 27 plus natural sky light — no artificial lanterns, letting the natural light dominate. Butterflies and fireflies (from Epic 29) should concentrate here. This area should feel like a moment of serenity — the player wants to pause and enjoy it.
- **Acceptance Criteria:**
  - [ ] Dense flower patches with varied colors
  - [ ] Bench under a large tree (rest point)
  - [ ] Pond, fountain, or water feature present
  - [ ] Dappled natural light dominates (few/no lanterns)
  - [ ] Atmosphere particles concentrate here (butterflies)
  - [ ] Zone feels peaceful and inviting to linger

### Task 30.15: Mood Zone — Dungeon Approach
- **Status:** TODO
- **Description:** Design the dungeon approach area as a transition zone from warm town to foreboding dungeon. Gradually shift the visual palette: vegetation thins out, ground texture becomes rocky/metallic, lighting transitions from warm to cool (blue-purple accent lights), props shift from rustic to tech (pipes, conduits, circuit-etched stone). The dungeon gate itself should be imposing — larger than the surrounding props, with a distinct silhouette. Add subtle particle effects near the gate: faint glitch/data stream particles, dim pulsing light. The approach should create anticipation — exciting but slightly ominous.
- **Acceptance Criteria:**
  - [ ] Gradual visual transition from town to dungeon aesthetic
  - [ ] Vegetation thins approaching the dungeon
  - [ ] Lighting shifts from warm to cool at the approach
  - [ ] Tech props introduce dungeon visual language
  - [ ] Dungeon gate is imposing and visually prominent
  - [ ] Subtle particle effects create anticipation

### Task 30.16: Camera Testing at All Key Positions
- **Status:** TODO
- **Description:** Walk through the entire town with the isometric camera and systematically check every viewpoint. At each key position (entrance, market, each NPC, well, dungeon approach, garden, residential), verify: the composition looks intentional (not random), sightlines work as designed, foreground framing is present where planned, no important elements are hidden behind props or buildings, the visual hierarchy is correct (interactive things most prominent), and there are no visual holes (areas where the player sees under the terrain or behind buildings). Document any issues found and fix them immediately.
- **Acceptance Criteria:**
  - [ ] Every key position tested with isometric camera
  - [ ] Composition verified at each viewpoint
  - [ ] No important elements hidden by other objects
  - [ ] No visual holes or terrain gaps visible
  - [ ] Sightlines work as designed
  - [ ] All issues found are documented and fixed

### Task 30.17: Collision and Navigation Polish
- **Status:** TODO
- **Description:** Update all collision shapes and navigation meshes to match the polished layout. Ensure: no invisible collision barriers left from old prop positions, new prop positions have correct collision (player can't walk through props), the navigation mesh allows pathfinding along all designed paths, narrow passages have enough clearance for the player character, and interactive objects can be reached from all intended approach angles. Re-bake the navigation mesh after all props are in final positions. Test by walking the player through every path and to every interactive element.
- **Acceptance Criteria:**
  - [ ] No phantom collision from old prop positions
  - [ ] All props have appropriate collision shapes
  - [ ] Navigation mesh baked and covers all walkable areas
  - [ ] Narrow passages have sufficient clearance
  - [ ] All interactive elements reachable from intended angles
  - [ ] Player can walk smoothly along all designed paths

### Task 30.18: Night Variation Preview
- **Status:** TODO
- **Description:** Preview the town layout with the evening lighting preset (from Epic 27) to verify the composition works at night. During evening/night: lanterns should become the dominant light sources (key visual landmarks), lit windows should guide the player between buildings, the path should remain navigable (not too dark to see), mood zones should shift appropriately (market may dim, residential glows warmer, dungeon entrance becomes more ominous). Adjust any lighting or prop placement that doesn't work in the evening preset. The town should feel equally beautiful and navigable at evening as during the day, just with a different mood.
- **Acceptance Criteria:**
  - [ ] Town navigable in evening lighting preset
  - [ ] Lanterns serve as wayfinding landmarks at night
  - [ ] Lit windows guide between buildings
  - [ ] Paths remain visible (not pitch black)
  - [ ] Mood zones shift appropriately for evening
  - [ ] Town is beautiful in both day and evening lighting

### Task 30.19: Player Journey Playtest
- **Status:** TODO
- **Description:** Conduct a complete playtest of the player's journey through the town. Start at the spawn point and follow the "first-time player" path: enter town, explore toward the first NPC, visit the shop, find the well, locate the dungeon entrance. Time each segment. Note moments of confusion (where to go?), delight (beautiful!), or frustration (stuck on collision, can't find X). Verify the journey takes 2-5 minutes for a first-time player (not rushing) before reaching the dungeon. Adjust any layout elements that cause confusion or break the flow. This is the final "does it feel good?" test.
- **Acceptance Criteria:**
  - [ ] Complete player journey tested from spawn to dungeon
  - [ ] Journey time is 2-5 minutes at exploration pace
  - [ ] No moments of confusion about direction
  - [ ] At least 2-3 moments of visual delight noted
  - [ ] No collision or navigation frustrations
  - [ ] Layout adjustments made for any issues found

### Task 30.20: Before/After Documentation and Final Review
- **Status:** TODO
- **Description:** Capture comprehensive before/after screenshots of the town layout polish. Take matching camera shots from before (old layout) and after (polished layout) showing: overhead layout comparison, town entrance reveal, market area composition, residential area mood, garden serenity, dungeon approach atmosphere, and night variation. Create annotated versions marking sightlines, mood zones, and visual hierarchy. Save all media to `_bmad-output/visual-overhaul/screenshots/epic-30/`. Update MASTER-PLAN.md with completion status.
- **Acceptance Criteria:**
  - [ ] Before/after pairs from at least 8 viewpoints
  - [ ] Annotated versions showing design intent
  - [ ] Night variation screenshots
  - [ ] Overhead layout comparison
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated with Epic 30 completion status

---

## Dependencies

- **Epic 23-29** (All previous town epics) — All props, textures, lighting, water, and atmosphere must be in place
- **Epic 02** (Style Guide) — Color palette and style reference

## Notes

- This epic is the "art director pass" — it's about composition, not asset creation
- Reference Stardew Valley's Pelican Town and Emberville's village for layout inspiration
- The isometric camera constrains framing — test EVERYTHING from the actual game camera, not the free editor camera
- "Progressive reveal" is the single most impactful technique — don't show everything at once
- If in doubt, less is more — a few well-placed props beat a cluttered scene every time
