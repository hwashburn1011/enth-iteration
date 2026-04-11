---
epic: 23
title: "Town Terrain"
phase: 5
status: TODO
priority: high
estimated_hours: 55
dependencies: [1, 2, 3]
---

# Epic 23: Town Terrain

## Overview

Create the sculpted terrain system for Enth: Iteration's town hub. The current town ground is a flat plane with solid color material. This epic transforms it into a sculpted terrain mesh with gentle rolling hills, hand-painted vertex color blending between grass, dirt, and stone surfaces, a natural-looking path system with worn edges, terrain edge treatment fading to the digital void, sculpted integration with building footprints, and water features (puddles, stream geometry). The terrain is the visual foundation of the town -- everything else sits on top of it.

**Design Philosophy:** The town terrain should feel like a cozy pocket of nature inside a digital simulation. Rolling hills suggest natural landscape, but subtle geometric patterns or pixel artifacts at the edges remind the player this is a computer-generated world. The Emberville/Stardew Valley aesthetic means hand-painted, warm, inviting -- not photorealistic.

**Quality Target:** The terrain should look hand-crafted and charming from the isometric camera. Vertex color blending should be smooth and natural. Paths should look worn and well-traveled. The overall impression: "a cozy digital village green."

## Success Criteria

- [ ] Terrain mesh with gentle rolling hills (not flat)
- [ ] Vertex color blending for grass/dirt/stone transitions
- [ ] Path system with worn edges connecting key locations
- [ ] Terrain edge fades to digital void convincingly
- [ ] Building footprint areas sculpted for natural integration
- [ ] Puddle/stream geometry adds visual interest
- [ ] Hand-painted material quality matching stylized aesthetic
- [ ] Terrain works with navigation mesh for player movement

---

## Tasks

### Task 23.1: Terrain Layout Planning
**Status:** TODO
**Description:** Plan the terrain layout by mapping the town's functional areas onto a terrain grid. Create a top-down layout sketch showing: (1) Building footprints (3 buildings -- general store, workshop, NPC home), (2) Dungeon entrance location, (3) Main path connecting all locations, (4) NPC standing spots, (5) Open gathering area (town center), (6) Terrain boundary (where the terrain meets the digital void edge), (7) Elevation changes (which areas are raised, lowered, or flat). The town should be approximately 30m x 30m. Mark path widths (1.5m main path, 0.8m side paths). Define elevation targets: town center flat, gentle hills at the perimeter (0.5-1m rise), building areas slightly raised (0.2m) for drainage visual. Export layout as reference for sculpting.
**Acceptance Criteria:**
- Top-down layout sketch with all functional areas marked
- 30m x 30m approximate town boundary defined
- Path network connecting all key locations
- Elevation targets annotated (center flat, perimeter hills)
- Building footprints positioned with appropriate spacing
- Dungeon entrance location marked
- Layout reference ready for Blender sculpting

### Task 23.2: Base Terrain Mesh Creation
**Status:** TODO
**Description:** Create the base terrain mesh in Blender. Start with a subdivided plane (30m x 30m) with sufficient vertex density for sculpting: approximately 1 vertex per 0.25m (120x120 grid = 14,400 vertices). Apply a Subdivision Surface modifier at level 1 for additional smoothing if needed, but keep the final mesh density reasonable for game performance (target under 30,000 triangles after export). Apply smooth shading. Set the mesh origin at the terrain center. Name the object `Town_Terrain`. Enable vertex color layer (required for material blending in Task 23.5). The grid resolution must be fine enough for gentle sculpting but coarse enough for game performance.
**Acceptance Criteria:**
- 30m x 30m subdivided plane with ~0.25m vertex spacing
- Under 30,000 triangles for game performance
- Smooth shading applied
- Vertex color layer created and active
- Mesh origin at terrain center
- Named `Town_Terrain`
- Resolution suitable for gentle terrain sculpting

### Task 23.3: Terrain Sculpting -- Rolling Hills
**Status:** TODO
**Description:** Sculpt the terrain to create gentle rolling hills. Using Blender's sculpt mode with Proportional Editing or the Sculpt brushes on the mesh: (1) Main town center area: keep mostly flat with very gentle undulation (0.05m variation -- just enough to catch light differently). (2) North perimeter: create a gentle hill rising to 0.8m, curving organically. (3) East perimeter: a lower rise (0.5m) with a shallow valley between it and the center. (4) West perimeter: two small mounds (0.4m, 0.3m) with a dip between them. (5) South perimeter: gradual slope down to where the dungeon entrance will be (0.3m below center level). (6) Building sites: sculpt flat pads at each building location (1m wider than building footprint on each side), slightly raised (0.15-0.2m) above surrounding terrain. Use the Smooth brush extensively after shaping to ensure all transitions are gentle and natural -- no sharp edges or abrupt height changes.
**Acceptance Criteria:**
- Town center mostly flat with subtle undulation
- Perimeter hills at varying heights (0.3-0.8m)
- Organic, asymmetric hill shapes (not geometric mounds)
- Building pads sculpted flat and slightly raised
- Dungeon entrance area slopes downward
- All transitions smooth and gentle (no sharp edges)
- Terrain feels like natural rolling landscape

### Task 23.4: Path System -- Geometry
**Status:** TODO
**Description:** Create the path network by sculpting path channels into the terrain. Paths should be slightly depressed (0.02-0.04m below surrounding terrain) to create natural drainage/wear channels. Main path: 1.5m wide, connecting the 3 buildings, dungeon entrance, and town center. Side paths: 0.8m wide, branching from the main path to secondary points (NPC spots, scenic overlook on the north hill). Path edges: not sharp cutoffs -- use Smooth brush to create gradual edge transitions (0.3m transition zone from path level to grass level). At path intersections, widen slightly (2m) to create natural gathering points. The main path should gently curve (no perfectly straight sections) following the natural terrain contour, going around hills rather than over them. Sculpt subtle wheel-rut indentations along the main path center (two parallel lines 0.01m deep, 0.6m apart).
**Acceptance Criteria:**
- Main path 1.5m wide connecting all key locations
- Side paths 0.8m wide to secondary locations
- Paths slightly depressed (0.02-0.04m) with gradual edges
- Curved paths following terrain contour (no straight lines)
- Widened intersections at gathering points
- Wheel-rut indentations on main path
- Path network looks well-traveled and natural

### Task 23.5: Vertex Color Painting -- Material Zones
**Status:** TODO
**Description:** Paint vertex colors on the terrain mesh to define material blending zones. The vertex color will drive a shader that blends between grass, dirt, and stone textures. Color mapping: Green channel = grass coverage, Red channel = dirt coverage, Blue channel = stone coverage. Paint the following zones: (1) Paths: primarily Red (dirt) with slight Green (grass) at edges for overgrowth. (2) Building pads: mix of Red (dirt, near buildings) and Blue (stone, directly under/around buildings). (3) Hilltops: primarily Green (grass) with slight Blue (stone) where rock outcrops through. (4) Hill slopes: Green fading to Red at the bottom (grass to dirt in low areas). (5) Town center: blend of Green and Red (well-worn grass). (6) Stream/puddle areas: Blue (stone/gravel bed). Use Blender's vertex paint mode with a soft brush for smooth transitions.
**Acceptance Criteria:**
- RGB vertex color channels mapped to grass/dirt/stone
- Paths painted as dirt with grass edge overgrowth
- Building surrounds have stone/dirt blend
- Hilltops are grassy with stone outcrop accents
- Smooth vertex color transitions (no hard edges)
- Material zones match functional terrain areas logically
- Vertex colors exported correctly in .glb

### Task 23.6: Terrain Shader -- Tri-Planar Texture Blending
**Status:** TODO
**Description:** Create a Godot shader (`terrain_blend.gdshader`) that uses vertex color channels to blend between three tiling textures. The shader reads the vertex color RGB: R = dirt weight, G = grass weight, B = stone weight. Each texture is a hand-painted tileable texture (created in Tasks 23.7-23.9). The shader samples all three textures and blends based on vertex weights. Add tri-planar projection (sample textures based on world position, not UV) to avoid UV stretching on slopes. Include a normal map blend (each texture has a matching normal map for surface detail). Add a subtle vertex displacement based on the normal map to enhance surface detail at close range. The shader should be efficient: 3 texture samples + 3 normal samples + blend = 6 texture lookups per fragment.
**Acceptance Criteria:**
- Shader blends 3 textures based on vertex color RGB channels
- Tri-planar projection prevents UV stretching on slopes
- Normal maps blend alongside diffuse textures
- Smooth blending between material zones
- Efficient (6 texture lookups per fragment)
- Works with Godot's StandardMaterial3D pipeline
- Looks correct from isometric camera angle

### Task 23.7: Hand-Paint Texture -- Grass Tile
**Status:** TODO
**Description:** Create a hand-painted tileable grass texture at 256x256 (will tile across terrain). Style: stylized cartoon grass matching Emberville aesthetic -- not photorealistic, not flat color. Paint using Krita or Blender texture paint: (1) Base: warm green (#44AA44). (2) Paint individual grass blade clusters (5-8 pixels tall, lighter green #66CC66 tips) scattered across the tile. (3) Add darker green (#338833) between blade clusters for depth. (4) Scatter tiny yellow (#DDDD44) flower dots (2-3 per tile). (5) Add subtle brown (#886644) dirt-peek-through at the base of some blade clusters. (6) Ensure tileable: copy edge pixels and verify seamless repeat. Create a matching normal map by converting the height detail to normals (grass blade tips should create subtle normal variation). Save as `terrain_grass_diffuse.png` and `terrain_grass_normal.png`.
**Acceptance Criteria:**
- 256x256 tileable grass texture (seamless repeat verified)
- Hand-painted stylized grass blades (not photorealistic)
- Color variation: base green, lighter tips, darker depth
- Tiny flower dots for detail
- Dirt peek-through at blade bases
- Matching normal map for surface detail
- Emberville/Stardew aesthetic quality

### Task 23.8: Hand-Paint Texture -- Dirt Path Tile
**Status:** TODO
**Description:** Create a hand-painted tileable dirt texture at 256x256. Style: warm brown packed earth with subtle pebble detail. Paint: (1) Base: warm brown (#AA7744). (2) Darker brown (#886633) patches for compaction variation. (3) Lighter tan (#CCAA77) highlights where light would catch raised areas. (4) Scattered small pebble details (2-4 pixels each, lighter brown/grey, 6-8 per tile). (5) Fine line cracks (dark brown #664422) in 2-3 locations suggesting dry packed earth. (6) Subtle footprint impression areas (very faint darkened patches, 1-2 per tile). Create matching normal map: pebbles and cracks should have visible normal detail. Ensure seamless tiling. Save as `terrain_dirt_diffuse.png` and `terrain_dirt_normal.png`.
**Acceptance Criteria:**
- 256x256 tileable dirt texture (seamless)
- Hand-painted warm brown earth with variation
- Pebble details scattered naturally
- Fine crack lines for dry earth character
- Subtle footprint impressions
- Matching normal map with pebble/crack depth
- Warm, inviting brown (not cold or muddy)

### Task 23.9: Hand-Paint Texture -- Stone Tile
**Status:** TODO
**Description:** Create a hand-painted tileable stone texture at 256x256. Style: grey cobblestone or flagstone with visible mortar lines. Paint: (1) Base: warm grey (#888888). (2) Individual stone shapes (irregular rectangles/polygons, 30-50px each) outlined with darker mortar lines (#555555, 2px wide). (3) Each stone has subtle color variation (some warmer #8A8878, some cooler #808898). (4) Painted highlight on the upper-left edge of each stone (lighter grey #AAAAAA) for directional light consistency. (5) Shadow on the lower-right edge of each stone (darker grey #666666). (6) Occasional moss/lichen accent on 1-2 stones (subtle green #668866 patches). Create matching normal map: stone edges should have clear beveled normals, mortar lines should be recessed. Save as `terrain_stone_diffuse.png` and `terrain_stone_normal.png`.
**Acceptance Criteria:**
- 256x256 tileable stone texture (seamless)
- Individual stone shapes with mortar lines
- Per-stone color variation (warm/cool)
- Hand-painted directional light (highlight/shadow per stone)
- Moss/lichen accents on 1-2 stones
- Matching normal map with beveled stone edges
- Cobblestone/flagstone feel matching stylized aesthetic

### Task 23.10: Path Edge Treatment -- Worn Grass/Dirt Transition
**Status:** TODO
**Description:** Refine the vertex color painting at path edges to create convincing "worn edges." In reality, heavily-traveled paths have a gradual transition: well-worn dirt center > patchy grass/dirt mix > slightly worn grass > full grass. Achieve this by painting vertex color gradients at each path edge: the transition zone should be 0.3-0.5m wide with a gradient from full dirt (Red=1, Green=0) to full grass (Red=0, Green=1). Add irregularity to the edge: use a smaller brush to create scalloped edges (grass intrusions into the dirt path, dirt patches extending into the grass) rather than a perfectly parallel edge. At high-traffic areas (near buildings, intersections), widen the dirt zone (more wear). At less-traveled side paths, narrow the dirt zone (less wear). These details sell the "lived-in" feeling.
**Acceptance Criteria:**
- 0.3-0.5m transition zone at all path edges
- Scalloped/irregular edge (not straight lines)
- High-traffic areas have wider worn zones
- Low-traffic paths have narrower worn zones
- Grass intrusions into dirt and dirt patches into grass
- Transition sells "natural wear" from foot traffic
- Vertex color gradient is smooth (no visible stepping)

### Task 23.11: Terrain Edge -- Digital Void Transition
**Status:** TODO
**Description:** Create the visual treatment for where the town terrain meets the digital void (the edge of the simulated world). The terrain should not just stop abruptly -- it should transition through stages suggesting digital degradation. Create a 2m-wide edge zone: (1) Inner edge (1m): terrain geometry begins to fragment -- vertices displace slightly downward and outward, creating broken-edge geometry. Vertex color shifts to an unnatural blue-grey (#6688AA). (2) Outer edge (1m): geometry becomes more fragmented, with some faces becoming transparent (via vertex alpha or shader discard). Digital noise pattern appears (painted or shader-driven). (3) Beyond the edge: no geometry, revealing the void below (dark background or void shader). Add a subtle particle effect along the edge: small pixel/data fragments falling from the broken terrain edge into the void below.
**Acceptance Criteria:**
- 2m transition zone from solid terrain to void
- Progressive geometry fragmentation at edges
- Color shift to unnatural blue-grey
- Some faces become transparent in outer zone
- Digital noise pattern at the boundary
- Particle fragments falling from edges
- Reinforces "crumbling simulation" narrative theme

### Task 23.12: Terrain Edge -- Boundary Collision
**Status:** TODO
**Description:** Ensure the player cannot walk off the terrain edge into the void, while making the boundary feel natural. Place invisible collision walls (StaticBody3D with CollisionShape3D) along the terrain edge, positioned at the inner edge (1m before the visual fragmentation begins). The collision wall should be tall enough to prevent jumping over (3m). However, the wall itself should not be the primary deterrent -- add a visual "instability warning" system: when the player is within 1m of the boundary collision, apply a subtle screen-space effect (slight chromatic aberration increase, very faint static noise overlay) that communicates "you are near the simulation boundary." Additionally, NPC dialogue can reference the boundary as "where the data ends." The boundary should feel like a natural edge of the world.
**Acceptance Criteria:**
- Invisible collision walls at terrain inner edge
- Walls 3m tall (prevent jumping over)
- Visual instability effect when player is near boundary
- Chromatic aberration + static noise increase near edge
- Effect fades smoothly based on distance
- Boundary feels like a natural world edge, not a game wall
- Player is gently discouraged from approaching too close

### Task 23.13: Building Integration -- Sculpted Footprints
**Status:** TODO
**Description:** Sculpt the terrain around each building footprint to create natural integration. For each of the 3 buildings: (1) Flatten the immediate footprint area (+0.5m padding on each side) as a level building pad. (2) The pad should be 0.15-0.2m above surrounding terrain (buildings sit on slightly raised ground). (3) Sculpt a gentle slope from pad edge to surrounding terrain (0.3m transition). (4) On the front (door-facing) side, sculpt a smooth entry ramp or step. (5) On back/sides, allow the terrain to rise slightly against the building base (earth banking up). (6) Around the building, vertex paint a mix of stone (Blue channel) and dirt (Red channel) for a courtyard/foundation feel. (7) Add subtle drainage channels sculpted into the terrain leading away from each building pad (0.01m deep, 0.1m wide grooves).
**Acceptance Criteria:**
- Flat building pads with 0.5m padding
- Pads raised 0.15-0.2m above surrounding terrain
- Smooth slope transitions from pad to ground
- Entry ramp/step on door-facing side
- Earth banking on back/sides
- Stone/dirt vertex color around buildings
- Drainage channel detail adds realism

### Task 23.14: Puddle Geometry
**Status:** TODO
**Description:** Add puddle geometry in natural low points of the terrain. Create 3-4 small puddles: flat circular/oval mesh discs (0.3-0.8m diameter, 0.005m above terrain surface) placed in terrain depressions. Each puddle uses a separate material: a subtle reflective shader with a tinted dark blue-brown base color (#445566), low roughness (0.1 for reflective surface), and a slight distortion normal map (very gentle ripple pattern). The ripple normal map should animate slowly (UV scroll or noise-driven displacement) to suggest still water with occasional tiny ripples. Vertex paint the terrain around puddles as dirt/stone (puddles collect in low areas, grass dies from waterlogging). Place puddles at: path intersection, building drainage outlet, and hill depression.
**Acceptance Criteria:**
- 3-4 puddle disc meshes in natural terrain depressions
- Subtle reflective material with dark blue-brown tint
- Animated gentle ripple pattern (UV scroll or noise)
- Surrounding terrain vertex-painted as dirt/stone (no grass near water)
- Puddles placed at logically wet locations
- Reflections approximate (not real-time reflection probes)
- Puddles add visual interest and environmental storytelling

### Task 23.15: Stream Geometry
**Status:** TODO
**Description:** Create a small stream that flows through part of the town (from the north hill, winding through to the east side). Model the stream as a narrow channel sculpted into the terrain (0.3m wide, 0.05m deep) with a flat water surface mesh inside. The stream path should wind organically with gentle S-curves, approximately 15m long. Stream bed: sculpt rounded pebble bumps at the bottom of the channel (visible through shallow water). Stream banks: sculpt soft edges with slight overhang. Water surface: a flat strip mesh following the stream path, 0.01m above the stream bed, using a water shader (similar to puddle material but with directional flow -- UV scroll along the stream direction at 0.1m/s). Add 2-3 small stepping stones (simple rounded cube meshes) crossing the stream for the player to walk over.
**Acceptance Criteria:**
- 15m stream winding through town with S-curves
- 0.3m wide x 0.05m deep sculpted channel
- Rounded pebble details on stream bed
- Soft bank edges with slight overhang
- Water surface with directional flow shader (0.1m/s)
- 2-3 stepping stones for player crossing
- Stream adds life and visual interest to the town

### Task 23.16: Terrain Navigation Mesh
**Status:** TODO
**Description:** Generate and validate the navigation mesh for the terrain. The NavMesh must accurately represent walkable areas on the sculpted terrain, including: (1) All flat and gently sloped areas (main traversal), (2) Paths (well-connected walkable routes), (3) Building pad areas (walkable right up to building doors), (4) Stepping stones (small walkable areas crossing the stream). The NavMesh must exclude: (1) Steep slopes (hills above 30 degrees), (2) The stream channel (except stepping stones), (3) Terrain edge void zone. Configure the NavigationRegion3D: agent radius 0.3m (Globbler width), agent height 1.0m, max slope 30 degrees, cell size 0.1m. Bake the NavMesh and verify by testing player pathfinding to all key locations. Verify enemies can also navigate correctly.
**Acceptance Criteria:**
- NavMesh covers all walkable terrain areas
- Paths are well-connected in the NavMesh
- Stream excluded (except stepping stones)
- Void edge excluded from NavMesh
- Agent parameters match player size
- Player can pathfind to all buildings, NPCs, and dungeon entrance
- Enemies (if present in town) navigate correctly

### Task 23.17: Terrain Material Export and Godot Setup
**Status:** TODO
**Description:** Export the terrain and set up materials in Godot. Export the terrain mesh as `town_terrain.glb` with vertex colors embedded. In Godot, create the terrain shader material: assign the 3 texture pairs (grass diffuse+normal, dirt diffuse+normal, stone diffuse+normal) as shader parameters, configure the vertex color blend shader (Task 23.6), set texture tiling scale (each texture should tile approximately 4 times across the full terrain for appropriate detail level). Import puddle and stream meshes separately. Set up puddle/stream water materials with the reflective/ripple shader. Place all terrain elements in the Town scene. Verify: vertex color blending looks correct, textures tile without visible repetition patterns, water shader animates, puddles and stream are positioned correctly.
**Acceptance Criteria:**
- Terrain mesh exported with vertex colors intact
- Shader material configured with all 6 textures
- Texture tiling appropriate (no visible repetition)
- Vertex color blending matches Blender painting
- Water shaders animate correctly in Godot
- All terrain elements placed in Town scene
- Visual quality matches Blender preview

### Task 23.18: Terrain Detail Objects
**Status:** TODO
**Description:** Add small detail objects scattered across the terrain to break up flat areas and add life. Create or place: (1) Small rock props (4-6 rocks, 0.1-0.3m, simple rounded shapes with stone texture) scattered on the hills and path edges. (2) Mushroom clusters (2-3 locations, simple cap-on-stem models, 0.05m tall) near tree bases and damp areas. (3) Fallen leaves (billboard quads with leaf texture) scattered sparsely on grass areas. (4) A small signpost at the main path intersection (simple post with directional arrows). These are low-poly static meshes (under 50 tris each) placed manually for composition. Total detail object count: 20-30 instances. Place them following natural distribution rules: rocks near stone areas, mushrooms near damp areas, leaves near where trees will be.
**Acceptance Criteria:**
- 20-30 detail objects scattered naturally
- Rocks, mushrooms, leaves, signpost types
- Each type under 50 tris
- Placement follows logical environmental rules
- Detail objects enhance terrain without cluttering
- Objects do not interfere with navigation or gameplay
- Consistent with hand-painted stylized aesthetic

### Task 23.19: Terrain Ambient Particle Effects
**Status:** TODO
**Description:** Add ambient particle effects to the terrain that bring it to life. Create and place: (1) Grass particle system: very subtle grass blade billboards that sway gently on flat grass areas (GPUParticles3D with grass blade billboard texture, low density -- 1 particle per 0.5m, 0.1m tall, gentle wind sway via turbulence). (2) Dust motes in sunbeams: small warm-colored particles (#FFFFDD at 20% opacity) drifting slowly in the air above the terrain (10-15 particles, 0.01m, lifetime 3 seconds). (3) Dandelion/data seeds: occasional tiny bright particles (#FFFFFF) floating upward from grass areas (2-3 per second across the whole terrain, very sparse). (4) Edge void particles: the falling pixel fragments from Task 23.11. All particles should be very subtle -- they add atmosphere, not visual noise.
**Acceptance Criteria:**
- Grass blade particles sway on grass areas
- Dust motes drift in the air above terrain
- Occasional dandelion/data seeds float upward
- Void edge particles at terrain boundary
- All particles are subtle and atmospheric
- No performance impact from particle systems
- Combined effect creates a living, breathing terrain

### Task 23.20: Terrain Visual Quality Test
**Status:** TODO
**Description:** Complete visual quality test of the finished terrain from all relevant camera angles and lighting conditions. Test: (1) Isometric gameplay camera: terrain looks natural with smooth material blending, paths are clearly readable, building integration is seamless. (2) Player movement test: walk all paths and verify no Z-fighting, no terrain holes, no floating detail objects. (3) Stream and puddle test: water shaders look correct, stepping stones are walkable, no swimming/clipping. (4) Terrain edge test: void transition looks convincing, boundary collision prevents player passage, instability effect triggers. (5) Material blend test: zoom in on each blend zone (grass-to-dirt, dirt-to-stone) and verify smooth transitions. (6) Lighting test: verify terrain looks good under different time-of-day lighting (if applicable) or at least under the primary game lighting. Take screenshots from multiple angles for documentation. Adjust vertex colors, texture tiling, or sculpt details as needed.
**Acceptance Criteria:**
- Terrain looks natural from gameplay camera
- No Z-fighting, holes, or floating objects
- Water features work correctly
- Terrain edge transition is convincing
- Material blending smooth at all transitions
- Terrain quality maintained under game lighting
- Screenshots captured for documentation
- All issues found during testing fixed

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings and naming conventions
- **Epic 2** (Visual Style Guide): Color palette and stylization rules
- **Epic 3** (Texture Workflow): Texture resolution and tiling standards
- **Epic 24** (Buildings): Building footprints must match terrain integration
- **Epic 25** (Vegetation): Vegetation will be placed relative to terrain

## Notes

- The terrain shader with vertex color blending is a common technique for stylized games -- well-documented approach
- Vertex density (~0.25m spacing) is a balance between sculpt quality and performance
- 30,000 triangles for terrain is reasonable for a small town area
- Tri-planar projection in the shader prevents UV stretching on slopes
- The stream is optional but adds significant visual quality
- The digital void edge is a unique feature that ties into the game's narrative theme
- Navigation mesh must be rebaked whenever terrain geometry changes
