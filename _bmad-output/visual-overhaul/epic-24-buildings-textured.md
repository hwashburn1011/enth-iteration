---
epic: 24
title: "Buildings Textured"
phase: 5
status: TODO
priority: high
estimated_hours: 60
dependencies: [1, 2, 3, 23]
---

# Epic 24: Buildings Textured

## Overview

UV unwrap and hand-paint textures for all 3 town buildings in Enth: Iteration. The current buildings are untextured primitive compositions with flat color materials. This epic transforms them into hand-painted, stylized structures with visible wood planks, roof tiles, window glass, door grain, weathering details, chimney brick, and baked ambient occlusion. Each building gets a full texture treatment that makes it feel like a lived-in structure in a cozy digital village.

**Buildings:** (1) General Store -- the town shop where the player buys/sells items, (2) Workshop -- where crafting and upgrades happen, (3) NPC Home -- where recruited NPCs live. Each building has walls, a roof, windows, a door, and a chimney.

**Design Philosophy:** Hand-painted textures should make each building feel unique and full of character. Wood planks should look warm and weathered. Roof tiles should have slight color variation. Windows should hint at interior life. The overall aesthetic is Stardew Valley meets Animal Crossing -- cozy, inviting, chunky.

**Quality Target:** Each building should look like it belongs in a premium indie game. Hand-painted texture quality comparable to Emberville, Cozy Grove, or similar stylized life-sim titles.

## Success Criteria

- [ ] All 3 buildings UV unwrapped with efficient atlas layouts
- [ ] Wood plank wall texture with grain detail and color variation
- [ ] Roof tile patterns with slight randomness
- [ ] Window glass with reflection hint and interior suggestion
- [ ] Door wood grain with hardware details
- [ ] Weathering/wear at edges and high-contact areas
- [ ] Chimney brick pattern with mortar
- [ ] Ambient occlusion baked for depth
- [ ] Each building has distinct color identity while sharing material quality

---

## Tasks

### Task 24.1: Building Geometry Audit and Cleanup
**Status:** TODO
**Description:** Before texturing, audit all 3 building meshes for texture-readiness. Check each building for: (1) Clean topology with no overlapping faces, no internal geometry, no n-gons. (2) Sufficient polygon density in detailed areas (around windows, doors, roof edges) for clean UV edges. (3) Proper normals (all faces pointing outward). (4) Sharp edges marked with Edge Split or Auto Smooth where needed (roof peak, wall corners, window frame edges). (5) Separate mesh objects for major components (walls, roof, door, windows, chimney) to allow per-component UV unwrapping. If any building mesh needs cleanup, fix it now before UV work. Document each building's component list and triangle count.
**Acceptance Criteria:**
- All 3 buildings audited for clean topology
- No overlapping faces, internal geometry, or n-gons
- Normals all pointing outward
- Sharp edges properly marked
- Components separated (walls, roof, door, windows, chimney)
- Triangle count documented per building per component
- All issues fixed before proceeding to UV

### Task 24.2: UV Unwrap -- General Store
**Status:** TODO
**Description:** UV unwrap the General Store onto a single 512x512 atlas. The General Store is the largest building. Component unwrapping strategy: (1) Front wall: largest single island (most visible from gameplay camera). Place seam along the top edge (hidden under roof overhang) and side edges. (2) Side walls: two islands, can share mirrored UV space if walls are symmetric. Place seams on back corners. (3) Back wall: smallest island (rarely seen). (4) Roof: unwrap each face as a separate island (front roof face, back roof face). Seam along peak ridge. (5) Door: own island, unwrap flat. (6) Windows (2-3): own island each or stacked if identical. (7) Chimney: cylindrical unwrap, seam on back. (8) Trim/overhang details: small islands. UV space allocation: front wall 25%, side walls 20%, roof 20%, windows/door 15%, chimney 5%, misc 15%.
**Acceptance Criteria:**
- All General Store components unwrapped
- Single 512x512 atlas with 4px padding
- Front wall gets largest UV allocation
- Seams placed at hidden/occluded locations
- Identical windows share UV space (stacked)
- No significant stretching on visible surfaces
- UV layout documented for painting reference

### Task 24.3: UV Unwrap -- Workshop
**Status:** TODO
**Description:** UV unwrap the Workshop onto a single 512x512 atlas. The Workshop should have a distinct silhouette (perhaps slightly squatter, wider, with a larger door or open front for the crafting area). Apply the same unwrapping strategy as the General Store but adjust for the Workshop's unique features: (1) If the Workshop has a large open front or garage-style opening, that area gets extra UV space. (2) Work surfaces visible through openings get their own UV islands. (3) The chimney may be larger/more industrial (wider = more UV space). (4) The roof may have a different pitch/shape. Match the same quality standards: seams hidden, front-facing surfaces prioritized, identical elements stacked.
**Acceptance Criteria:**
- All Workshop components unwrapped
- Single 512x512 atlas with 4px padding
- Workshop-specific features (large door, work area) get extra UV space
- Front-facing surfaces prioritized
- Same quality standards as General Store UV
- Seams hidden at occluded locations
- UV layout documented

### Task 24.4: UV Unwrap -- NPC Home
**Status:** TODO
**Description:** UV unwrap the NPC Home onto a single 512x512 atlas. The NPC Home should feel more residential/cozy (perhaps taller, with more windows, a balcony, or flower boxes). Apply the same unwrapping principles: (1) Extra windows mean more UV allocation for window islands. (2) Flower box or balcony detail gets dedicated UV space. (3) The front face still gets priority for UV density. (4) If the home has a porch, the porch floor and railing get their own islands. Match quality standards: hidden seams, prioritized visible surfaces, stacked identical elements.
**Acceptance Criteria:**
- All NPC Home components unwrapped
- Single 512x512 atlas with 4px padding
- Residential features (extra windows, balcony/flower box) accommodated
- Front-facing surfaces prioritized
- Same quality standards as other buildings
- Seams hidden at occluded locations
- UV layout documented

### Task 24.5: Hand-Paint -- Wood Plank Wall Base (General Store)
**Status:** TODO
**Description:** Paint the General Store's wall texture in Blender Texture Paint or Krita. Start with horizontal wood plank pattern: (1) Base warm wood color: light oak (#BB8844). (2) Paint individual planks with visible horizontal lines (plank boundaries as slightly darker lines #996633, 1-2px wide). Planks should be 0.3-0.4m tall in world space. (3) Within each plank, paint subtle horizontal wood grain lines (thin, slightly wavy, darker than base by 10-15%). (4) Vary plank colors slightly: some planks 5% warmer (more orange), some 5% cooler (more grey-brown). This variation prevents the wall from looking like a flat fill. (5) Paint knot details: 2-3 darker circular knot marks per wall face (dark brown #664422, 3-5px). (6) Edge planks (at corners) should be slightly darker (weathering from exposure).
**Acceptance Criteria:**
- Horizontal plank pattern with visible boundaries
- Wood grain detail within each plank
- Per-plank color variation (warm/cool shifts)
- 2-3 knot details per wall face
- Edge planks darker (weathering)
- Reads as "wood plank wall" from isometric distance
- Warm, inviting color palette

### Task 24.6: Hand-Paint -- Roof Tile Pattern (General Store)
**Status:** TODO
**Description:** Paint the General Store's roof texture. Roof style: overlapping shingle/tile rows. (1) Base: warm red-brown (#AA5533). (2) Paint overlapping shingle rows (each row offsets by half a shingle width). Individual shingles are roughly 0.15m x 0.1m in world space. (3) Each shingle has: a slightly darker lower edge (shadow from the shingle above, #884422), a slightly lighter center (catching light, #BB6644), and a thin dark outline on sides (0.5px separation). (4) Vary individual shingle colors: some slightly more red, some more brown, one or two significantly darker (repaired/replaced shingles). (5) Paint a row of highlight along the roof ridge (where the two roof faces meet -- lighter color suggesting a cap piece). (6) Add subtle moss/lichen patches on 2-3 shingles near the bottom edge (small green-grey #778866 spots).
**Acceptance Criteria:**
- Overlapping shingle pattern with offset rows
- Per-shingle shadow/highlight consistent with top-left light
- Individual shingle color variation
- 1-2 darker "repaired" shingles for character
- Ridge highlight cap piece
- Moss/lichen patches near bottom edge
- Reads as "tiled roof" from isometric camera

### Task 24.7: Hand-Paint -- Window Glass and Frames (General Store)
**Status:** TODO
**Description:** Paint the window textures. Windows are key personality features. For each window: (1) Window frame: paint with a slightly different wood color than walls -- lighter, more finished (#CCAA66), with visible frame edge (1px dark outline). (2) Glass: base with deep blue-grey (#334455) for a "dark interior" look. (3) Reflection hint: paint a diagonal light streak across the glass (white #FFFFFF at 15-20% opacity, thin diagonal line from upper-left to lower-right). This is the most important detail -- it sells the "glass" illusion. (4) Interior suggestion: behind the glass, paint very faint warm-toned shapes (extremely subtle, 5-10% opacity) suggesting shelves or goods inside the General Store. (5) Window sill: slightly lighter color with a painted shadow underneath. (6) Cross-frame dividers (if the window has panes): dark wood lines creating a 2x2 or 2x3 pane grid.
**Acceptance Criteria:**
- Window frame distinct from wall wood (lighter, finished)
- Glass reads as reflective surface (diagonal light streak)
- Dark interior base with faint warm interior suggestion
- Window sill with shadow detail
- Cross-frame dividers (if applicable)
- Each window has personality (curtain hint, item display)
- Glass illusion convincing from isometric distance

### Task 24.8: Hand-Paint -- Door (General Store)
**Status:** TODO
**Description:** Paint the General Store's front door. The door is the building's most-interacted element and needs extra detail. (1) Base: rich dark wood (#664422), darker than the walls to stand out. (2) Paint vertical wood grain (the door has vertical plank construction). (3) Add visible plank boundaries (2-3 vertical planks making up the door). (4) Paint metal hardware: door handle/knob (metallic grey #AAAAAA with bright highlight #DDDDDD), hinges on one side (dark iron #444444, 2 hinges visible). (5) Add a small sign or icon above the door suggesting "General Store" (painted directly on the wood or on a small hanging sign -- a simple coin or package icon). (6) Paint wear marks: the area around the handle should be slightly lighter/worn (from hands). The bottom of the door should be slightly scuffed/darker (from feet). (7) Frame the door with a slightly different colored trim (same as window frame color #CCAA66).
**Acceptance Criteria:**
- Rich dark wood base distinguishes door from walls
- Vertical wood grain and plank construction visible
- Metal hardware (handle, hinges) painted
- Store sign or icon above door
- Wear marks around handle and at bottom
- Trim frames the door distinctly
- Door is clearly the entry point and interaction target

### Task 24.9: Hand-Paint -- Weathering and Edge Wear (General Store)
**Status:** TODO
**Description:** Add weathering details across the entire General Store texture to make it look lived-in. (1) Corner edges: paint slightly lighter/worn wood at all vertical corners where traffic or weather would cause wear (#CCAA77 over the base). (2) Base of walls: paint a subtle dirt splash (dark brown #775533 gradient from ground up, affecting bottom 0.1m of walls). (3) Under eaves/overhangs: paint darker shadow (rain hasn't reached here, but it is in shadow). (4) Near gutters/drainage: paint darker water stain streaks (vertical lines #776655 below roof edge, 2-3 per wall). (5) Window sills: paint slight discoloration underneath (water drip staining). (6) General: add 3-4 random wear spots (lighter patches where paint/stain has worn away, or darker patches suggesting repaired areas). Weathering should be subtle -- it adds character, not damage.
**Acceptance Criteria:**
- Corner edge wear visible (lighter wood)
- Base dirt splash at wall bottoms
- Shadow under eaves/overhangs
- Water stain streaks below roof edges
- Window sill discoloration
- Random character wear spots (3-4)
- Weathering is subtle, adding charm not decay

### Task 24.10: Hand-Paint -- Chimney Brick (General Store)
**Status:** TODO
**Description:** Paint the General Store's chimney with a brick pattern. (1) Base: warm red-brown (#994433). (2) Paint individual bricks in a standard running bond pattern (offset rows). Each brick approximately 0.06m x 0.03m in world space. (3) Mortar lines between bricks: lighter tan (#CCBB99, 1px wide). (4) Per-brick color variation: some slightly darker (#883322), some slightly lighter (#AA5544), one or two fire-blackened bricks near the top (#443322). (5) Paint soot darkening gradient near the chimney top (dark grey #444444 blending into the brick from the top down, affecting top 20% of chimney). (6) Add a cap piece at the very top (slightly different material -- stone grey #888888). The chimney should feel like hand-laid brickwork, warm and rustic.
**Acceptance Criteria:**
- Running bond brick pattern with mortar lines
- Per-brick color variation for natural look
- Fire-blackened bricks near top
- Soot gradient at chimney top
- Stone cap piece at very top
- Reads as "brick chimney" from isometric distance
- Warm rustic feel matching building style

### Task 24.11: Ambient Occlusion Bake -- General Store
**Status:** TODO
**Description:** Bake ambient occlusion for the General Store to add depth and grounding. In Blender, set up an AO bake: (1) Create a new 512x512 image for AO (or bake onto the existing texture using Multiply blend). (2) Bake type: Ambient Occlusion with appropriate ray distance (0.5m for building scale). (3) Key areas that need AO: wall-to-roof junction (shadow where roof overhang meets wall), wall-to-ground junction (shadow at building base), window-to-wall recesses, door frame recesses, chimney-to-roof junction, any interior corners. (4) After baking, composite the AO onto the diffuse texture using Multiply blend mode at 40-60% opacity (subtle darkening, not heavy black shadows). The AO should enhance the 3D depth illusion of the hand-painted texture without making it look CG-rendered.
**Acceptance Criteria:**
- AO baked at 512x512 matching UV layout
- All junction/recess areas show proper occlusion
- AO composited onto diffuse at 40-60% opacity
- Darkening is subtle (enhances depth, not heavy shadows)
- Hand-painted style preserved (AO does not look CG)
- Roof overhangs create natural shadow on walls
- Ground junction AO grounds the building

### Task 24.12: General Store -- Material Export and Godot Test
**Status:** TODO
**Description:** Export the completed General Store texture and test in Godot. Save the final diffuse as `general_store_diffuse.png` (512x512). If a normal map was created (for plank/brick depth), save as `general_store_normal.png`. Export the building mesh with embedded textures. In Godot, set up the material: Base Color = diffuse, Normal = normal map (if present), Roughness = 0.8 (wood is matte), Metallic = 0.0. Verify the building looks correct in the town scene under game lighting. Check: (1) Texture resolution is sufficient (no blurriness). (2) UV seams not visible. (3) Colors match Blender preview. (4) AO adds visible depth. (5) Building reads as "General Store" from isometric camera. Take a screenshot for comparison.
**Acceptance Criteria:**
- Diffuse texture saved at 512x512
- Material configured: roughness 0.8, metallic 0.0
- Building displays correctly in Godot town scene
- No visible UV seams
- Colors match Blender painting
- AO depth visible in game lighting
- Screenshot captured for documentation

### Task 24.13: Hand-Paint -- Workshop (Full Texture Pass)
**Status:** TODO
**Description:** Complete the full texture painting pass for the Workshop building. The Workshop should have a distinct identity from the General Store: (1) Wall base color: slightly darker, more weathered wood (#AA7744) suggesting heavier use. (2) Metal accents: the Workshop should have more metal elements -- painted tool racks or a forge-like metallic panel area (dark iron #555555 with warm orange heat glow #FF8844 accent). (3) Larger door with industrial feel (heavier planks, larger metal hinges and handle). (4) Windows may have darker glass or soot staining. (5) Roof color variation: perhaps grey-blue shingles (#667788) to distinguish from the General Store's red-brown. (6) Extra weathering: more soot, more wear, more character -- this is a working building. (7) A hanging sign with a hammer/anvil icon. Apply the same techniques: wood grain, shingle pattern, glass reflection, hardware detail, weathering, AO bake.
**Acceptance Criteria:**
- Workshop has distinct color identity from General Store
- More industrial elements (metal, forge hints, heavy hardware)
- Darker, more weathered wood base
- Different roof color (grey-blue shingles)
- Extra weathering appropriate for a working building
- Hanging sign with workshop icon
- Same technique quality as General Store painting

### Task 24.14: Hand-Paint -- NPC Home (Full Texture Pass)
**Status:** TODO
**Description:** Complete the full texture painting pass for the NPC Home. The Home should feel the most residential and inviting: (1) Wall base: warm lighter wood (#CC9955) suggesting well-maintained timber. (2) Painted trim sections: portions of the wall may be painted (not bare wood) in a warm color (#77AA77 soft green or #8888BB soft blue) for residential charm. (3) More windows than other buildings, each with curtain hints painted inside the glass (warm fabric colors, 10% opacity). (4) Flower box under at least one window (painted as a small wooden box with colorful painted flower dots). (5) Door: warm welcoming color, maybe painted (#886644 wood with a painted panel in a bright color). (6) Roof: warm terracotta (#CC8855) or soft green (#88AA77). (7) Porch area if applicable (lighter wood flooring, railing detail). (8) Chimney with cozy smoke suggestion (not modeled, but soot pattern suggests recent use).
**Acceptance Criteria:**
- NPC Home feels residential and inviting
- Lighter, warmer wood base color
- Painted trim sections add residential charm
- Curtain hints visible in windows
- Flower box detail under at least one window
- Warm welcoming door with painted panel
- Cozy, homey feeling distinct from commercial buildings

### Task 24.15: Workshop and NPC Home -- AO Bake and Export
**Status:** TODO
**Description:** Complete the AO bake and Godot export for the Workshop and NPC Home. Apply the same AO baking process as the General Store (Task 24.11): bake at 512x512, composite at 40-60% onto diffuse. Export both buildings with embedded textures. Import into Godot and set up materials (roughness 0.8, metallic 0.0 for both, with possible metallic variation for Workshop forge elements at 0.3). Test both buildings in the town scene alongside the completed General Store. Verify: (1) All 3 buildings have distinct visual identities. (2) Colors harmonize (different but not clashing). (3) Consistent quality level across all buildings. (4) AO depth consistent. (5) Buildings integrate with terrain texture (Task 23) at their footprints.
**Acceptance Criteria:**
- AO baked and composited for Workshop and NPC Home
- Both buildings exported and imported into Godot
- Materials configured correctly
- All 3 buildings visually distinct but harmonious
- Consistent quality level across buildings
- Buildings integrate with terrain at footprints
- Screenshots of all 3 buildings in scene

### Task 24.16: Window Glow -- Interior Lighting Suggestion
**Status:** TODO
**Description:** Add a warm interior glow to building windows that suggests life inside. For each window on each building: (1) Add a faint warm-colored plane behind the window glass (a simple quad positioned 0.02m behind the window surface). (2) Apply an emissive material to this plane: warm yellow-orange (#FFDD88), emission energy 0.5 (subtle glow, not blinding). (3) The glow plane creates the impression that warm light is coming from inside the building. (4) Optionally, add a very low-energy OmniLight3D (warm color, 0.5m range, energy 0.1) behind each window to cast faint warm light onto the ground in front of the building. (5) Consider making window glow intensity time-of-day dependent (brighter at "evening," dimmer during "day") if the time system supports it.
**Acceptance Criteria:**
- Warm glow planes behind all windows on all 3 buildings
- Emission material at appropriate intensity (subtle, not blinding)
- Glow suggests warm, occupied interior
- Optional point lights cast faint warm pools on ground
- Effect is visible from isometric camera
- Enhances cozy, inhabited feeling
- Performance impact minimal (simple emissive planes)

### Task 24.17: Building Signage and Icons
**Status:** TODO
**Description:** Finalize all building signage to help players identify each building's function. (1) General Store: hanging wooden sign with a coin/package icon and "STORE" text (painted on the building texture or as a separate small mesh). Sign should swing slightly (simple bone animation or shader). (2) Workshop: hanging sign with hammer/anvil icon and "WORKSHOP" text. More industrial-looking sign (metal frame). (3) NPC Home: a nameplate next to the door (smaller, more personal -- "HOME" or the NPC's name). Additionally, add a subtle interaction prompt visual: when the player is near a building door, a small "Enter" icon or door highlight appears (this connects to the interaction system). Style all text in the game's sci-fi font.
**Acceptance Criteria:**
- Each building has clear signage identifying its function
- Signs match each building's personality (commercial, industrial, residential)
- Text uses game font
- Signs are readable from isometric camera distance
- Interaction prompt visual near doors
- Signs add to the cozy village atmosphere
- Consistent quality across all 3 buildings

### Task 24.18: Building Detail Props
**Status:** TODO
**Description:** Add small detail props around each building that enhance character. (1) General Store: a barrel beside the door, a small crate, a "OPEN" sign in the window. (2) Workshop: tool rack beside the door (simple geometry with painted tool silhouettes), a stack of materials (planks or ingot shapes), a workbench visible if there is an open front. (3) NPC Home: a potted plant by the door, a welcome mat (flat textured quad), a small garden bed along one wall (raised earth with painted flower/vegetable dots). Each prop is very low poly (under 30 tris) with simple painted textures matching the building's style. Props should be integrated with the terrain (sitting on the ground naturally, not floating).
**Acceptance Criteria:**
- 3-4 detail props per building
- Props match each building's function and personality
- Under 30 tris per prop
- Simple painted textures matching building style
- Props sit naturally on terrain (not floating)
- Add character and life to building surroundings
- Do not block player navigation

### Task 24.19: Building Shadow and Grounding
**Status:** TODO
**Description:** Ensure all buildings are properly grounded in the scene with appropriate shadow treatment. (1) Verify each building sits on its terrain pad (from Epic 23) with no visible gap between building base and terrain. Adjust building Y position if needed. (2) Check that Godot's directional light casts proper shadows from buildings onto the terrain. (3) If real-time shadows are too expensive, add painted shadow decals: flat dark quad meshes (0.05m above terrain) with soft-edged shadow textures projected beneath building overhangs and edges. (4) Add a subtle shadow gradient at the building base where the wall meets the ground (can be part of the terrain's vertex painting -- darken the terrain directly against building walls). (5) Verify shadow direction matches the main light direction.
**Acceptance Criteria:**
- No gaps between buildings and terrain
- Shadows cast correctly (real-time or baked decals)
- Shadow direction matches main light
- Base shadow gradient at wall-ground junction
- Buildings feel grounded and connected to terrain
- Shadow performance acceptable
- Visual quality consistent across all 3 buildings

### Task 24.20: Full Building Set Visual Review
**Status:** TODO
**Description:** Comprehensive visual review of all 3 textured buildings in the town scene together. Review from the isometric gameplay camera: (1) All 3 buildings are visually distinct but harmonious. (2) Hand-painted quality is consistent across all buildings. (3) Wood, roof, window, door, chimney textures all read correctly at camera distance. (4) Weathering and AO add convincing depth. (5) Window glow creates a warm atmosphere. (6) Signage identifies each building clearly. (7) Detail props enhance character without clutter. (8) Buildings integrate naturally with terrain (footprints, shadow, detail objects). (9) The overall town scene reads as "cozy digital village" from first impression. Compare against reference images (Stardew Valley buildings, Emberville buildings) for quality benchmarking. Take final comparison screenshots. Note and fix any issues found.
**Acceptance Criteria:**
- All 3 buildings display correctly in town scene
- Consistent hand-painted quality across all buildings
- Visually distinct identities (commercial, industrial, residential)
- Warm, inviting atmosphere from the building set
- Integration with terrain is seamless
- Quality benchmarks favorably against references
- Final screenshots captured for documentation
- All issues found during review addressed

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings and naming conventions
- **Epic 2** (Visual Style Guide): Color palette and building style direction
- **Epic 3** (Texture Workflow): UV unwrap standards and texture resolution
- **Epic 23** (Town Terrain): Building footprints must match terrain sculpting

## Notes

- The front wall of each building is the most important surface -- it is what the player sees from the isometric camera
- Hand-painted textures should look warm and intentional, not procedural or tiled
- AO baking adds significant depth but must be subtle to preserve the hand-painted style
- Window glow is a high-impact, low-effort detail that makes buildings feel alive
- Each building should tell a story through its texture (the Workshop is more weathered, the Home is well-maintained)
- Building textures will be revisited when the iteration system changes the town (different textures per iteration)
- Consider creating "damaged" texture variants for later iterations
