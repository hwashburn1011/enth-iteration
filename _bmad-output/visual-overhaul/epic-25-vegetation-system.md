---
epic: 25
title: "Vegetation System"
phase: 5
status: TODO
priority: high
estimated_hours: 55
dependencies: [1, 2, 3, 23]
---

# Epic 25: Vegetation System

## Overview

Create the complete vegetation system for Enth: Iteration's town environment. The current town has no vegetation -- this epic adds grass billboards, properly modeled trees with branch detail, bushes, flowers, and a wind animation system that brings all vegetation to life. Each vegetation type gets hand-painted textures matching the Emberville/Stardew Valley aesthetic. The vegetation system transforms the town from a barren digital landscape into a lush, cozy garden village.

**Design Philosophy:** Vegetation is the single biggest factor in making an environment feel alive and inviting. Even with perfect buildings and terrain, a town without plants feels sterile. The vegetation should feel hand-planted and tended (garden aesthetic, not wild forest). Trees are chunky and rounded (not realistic), grass is stylized, flowers are bright and cheerful. Subtle digital artifacts in the vegetation (pixel patterns in leaves, data-stream bark texture) tie it back to the simulation theme.

**Quality Target:** Comparable to the vegetation in Stardew Valley's outdoor areas, Cozy Grove, or A Short Hike -- chunky, colorful, hand-painted, full of charm.

## Success Criteria

- [ ] Grass billboard mesh with painted texture covers appropriate terrain areas
- [ ] Tree model with proper branch structure and leaf canopy
- [ ] Hand-painted tree bark and leaf textures
- [ ] Flower models with painted petal details
- [ ] Bush models with leaf detail
- [ ] Wind sway animation/shader on all vegetation
- [ ] Seasonal color support for future iteration cycles
- [ ] Vegetation integrates naturally with terrain and buildings
- [ ] Performance maintains 60fps with full vegetation density

---

## Tasks

### Task 25.1: Vegetation Layout Plan
**Status:** TODO
**Description:** Plan the placement of all vegetation in the town. Create an annotated top-down map showing: (1) Tree positions: 5-7 trees total. Place 2-3 larger trees in the town perimeter (framing the edges), 1 centerpiece tree near the gathering area, 1-2 smaller trees near buildings. Trees should create visual framing for key sightlines (from town entrance to buildings). (2) Bush positions: 8-12 bushes used as natural barriers, path borders, and building foundation cover. (3) Flower beds: 3-4 clusters near buildings and along paths. (4) Grass density zones: mark areas for dense grass (hills, open fields), medium grass (near paths), no grass (paths, building pads, stone areas). The layout should follow garden design principles: odd numbers, varied spacing, framing focal points.
**Acceptance Criteria:**
- Top-down vegetation map with all placements annotated
- 5-7 tree positions with size categories
- 8-12 bush positions as barriers/borders
- 3-4 flower bed clusters
- Grass density zones mapped to terrain materials
- Layout follows garden design (odd groupings, focal framing)
- No vegetation blocking key navigation paths

### Task 25.2: Grass Billboard Mesh -- Model and UV
**Status:** TODO
**Description:** Create the grass billboard mesh system. Model a grass clump: 3 intersecting quads (6 triangles total) arranged in a star pattern when viewed from above (each quad rotated 60 degrees from the others). Each quad is 0.15m wide x 0.12m tall. This cross-billboard technique ensures grass looks full from any camera angle. UV unwrap all 3 quads onto a shared space (they use the same texture). The mesh will be instanced many times via MultiMeshInstance3D for performance. Create a single grass clump mesh exported as a separate .glb. Also create a variant: a taller grass mesh (0.2m tall) with 4 quads for denser patches. Both variants share the same UV layout and texture.
**Acceptance Criteria:**
- 3-quad cross-billboard grass clump (6 tris)
- 0.15m wide x 0.12m tall per quad
- Star pattern arrangement for all-angle visibility
- UV unwrapped for shared texture
- Variant: taller 4-quad version for dense patches
- Both exported as .glb meshes
- Designed for MultiMeshInstance3D instancing

### Task 25.3: Grass Billboard -- Hand-Painted Texture
**Status:** TODO
**Description:** Paint the grass billboard texture at 64x64 (small, will be instanced thousands of times). The texture must have an alpha channel for the grass blade shape. Paint: (1) 4-6 grass blades emerging from a shared base point, fanning outward. Blades are tapered (wider at base, pointed at tip). (2) Base color: warm green (#55AA44). (3) Blade tips: lighter green (#88CC66) for sun-catching highlights. (4) Some blades darker (#338833) for depth variation. (5) One blade should have a tiny yellow tip (flower bud) for color accent. (6) Alpha channel: sharp cutout around blade silhouettes (1-bit alpha at the edges for clean cutoff, not soft transparency). (7) The bottom edge of the texture should have a soft alpha fade (blends into terrain). Create a second variant texture with slightly different blade arrangement and color (more yellow-green) for visual variety when instanced.
**Acceptance Criteria:**
- 64x64 grass texture with alpha cutout
- 4-6 tapered grass blades with color variation
- Tips lighter than base (light gradient)
- Tiny yellow flower bud accent on one blade
- Alpha is sharp at blade edges, soft at base
- Second variant texture for variety
- Both textures look hand-painted and stylized

### Task 25.4: Grass Distribution -- MultiMeshInstance3D Setup
**Status:** TODO
**Description:** Implement grass distribution across the terrain using Godot's MultiMeshInstance3D for performance. Create a grass placement script that: (1) Reads the terrain's vertex color data to determine grass density (Green channel > 0.5 = grass zone). (2) Distributes grass clump instances within grass zones at 1 clump per 0.3m (approximate -- with random jitter of +/- 0.1m for natural distribution). (3) Raycasts from above to place each clump exactly on the terrain surface with correct Y height. (4) Rotates each instance randomly around the Y axis (0-360 degrees). (5) Scales randomly between 0.8x and 1.2x for size variation. (6) Alternates between the two texture variants randomly (50/50). Target approximately 500-1,500 grass instances depending on grass zone area. Create the MultiMeshInstance3D with visibility range (fade out beyond 20m) for performance.
**Acceptance Criteria:**
- Grass distributed based on terrain vertex color (green zones)
- ~0.3m spacing with random jitter
- Placed on terrain surface via raycast
- Random rotation and scale variation
- Two texture variants alternated
- 500-1,500 instances (performance-appropriate)
- Visibility range fadeout at 20m

### Task 25.5: Tree Model -- Trunk and Branches
**Status:** TODO
**Description:** Model a stylized tree in Blender. The tree should have chunky, rounded proportions (not realistic). Trunk: a tapered cylinder (0.2m base diameter, tapering to 0.08m) with a slight bend/lean (not perfectly straight). Height to first branch: ~1m. Two main branches diverge from the trunk top, each subdividing into 2 secondary branches. Total tree height: ~3m. Branch proportions: chunky (0.06m diameter at the base, tapering). All branches should have visible thickness (not thin wireframes). Add 2-3 visible root ridges at the trunk base (blending into the ground). The trunk surface should have subtle bark groove detail (3-4 vertical lines). Total tree frame: ~200-300 tris. Model the trunk and branches as a single connected mesh for clean bark texturing.
**Acceptance Criteria:**
- Chunky stylized tree proportions (not realistic)
- Tapered trunk with slight bend/lean
- 2 main branches subdividing to 4 secondary branches
- ~3m total height
- Visible root ridges at base
- Bark groove detail on trunk surface
- 200-300 tris for trunk and branch framework

### Task 25.6: Tree Model -- Leaf Canopy
**Status:** TODO
**Description:** Model the leaf canopy as a separate mesh from the trunk. The canopy uses a combination approach: (1) 3-4 large "leaf cluster" shapes -- each is a rounded blob (modified sphere) with lumpy surface, placed at the ends of branches and overlapping to form a full canopy. Each cluster is ~0.8-1.2m diameter. (2) The clusters overlap to create a full, dense canopy silhouette (~2.5m diameter, 2m tall). (3) The bottom of the canopy should have visible gaps where branches are visible (not a solid hemisphere -- some irregularity). (4) Add 2-3 small gap holes in the canopy for visual interest (light peeks through). The canopy mesh uses alpha-test material (painted leaves with alpha cutoff) for the outer surface. Total canopy: ~300-500 tris. The canopy silhouette should look lush and rounded from the isometric camera.
**Acceptance Criteria:**
- 3-4 overlapping leaf cluster blobs forming full canopy
- ~2.5m diameter, 2m tall canopy
- Gaps and irregularity for natural look
- 2-3 small holes for light penetration
- Bottom of canopy shows branch gaps
- 300-500 tris for full canopy
- Lush, rounded silhouette from isometric camera

### Task 25.7: Hand-Paint -- Tree Bark Texture
**Status:** TODO
**Description:** Paint the tree bark texture at 256x256 (shared by trunk and branches). (1) Base: warm brown (#776644). (2) Paint vertical bark ridge lines (darker brown #554433, slightly wavy, running the length of the trunk). Ridges should be 3-5px wide with 8-12px spacing. (3) Between ridges, paint subtle inner bark color (slightly more orange/warm #887755). (4) Add horizontal crack marks at branch junction points (darker lines suggesting growth stress). (5) Moss/lichen patches: 2-3 small green-grey (#778866) patches on the north-facing side of the trunk. (6) Root area: slightly darker and more weathered. (7) Branch tips: slightly lighter bark (younger wood). (8) Digital accent: paint 1-2 very subtle hex-number fragments (#665544 barely visible) on the bark, tying the tree to the simulation theme.
**Acceptance Criteria:**
- 256x256 tileable bark texture
- Vertical bark ridges with natural waviness
- Inner bark warm color between ridges
- Moss/lichen patches on one side
- Branch tip lighter bark (young wood)
- Subtle digital hex fragment Easter egg
- Hand-painted quality matching game aesthetic

### Task 25.8: Hand-Paint -- Leaf Canopy Texture
**Status:** TODO
**Description:** Paint the leaf canopy texture at 256x256 with alpha channel. The texture paints onto the canopy cluster meshes. (1) Base: medium green (#55AA44). (2) Paint individual leaf clusters: groups of 3-5 small oval leaf shapes (5-8px each) painted in slightly varying greens (#44AA33 to #66BB55). (3) Shadow leaves: underneath/overlapping leaves painted darker (#338833) for depth. (4) Highlight leaves: top-facing leaves painted brighter (#77CC66) for light-catching. (5) Accent leaves: 2-3 leaves in each cluster slightly yellow-green (#88BB44) for color variation. (6) Alpha channel: solid where leaves are painted, transparent between leaf clusters (creating a dappled edge effect on the canopy boundary). (7) Occasional tiny bright spots (#FFFFFF at 10% opacity) between leaves suggesting light filtering through the canopy.
**Acceptance Criteria:**
- 256x256 leaf texture with alpha cutout
- Individual leaf cluster shapes visible
- Color variation: dark shadow, bright highlight, accent yellow-green
- Alpha creates dappled edge effect on canopy boundary
- Light filtering bright spots between leaves
- Reads as lush foliage from isometric distance
- Hand-painted, not photorealistic

### Task 25.9: Tree Variants -- Size and Shape Variation
**Status:** TODO
**Description:** Create 2 additional tree variants from the base tree model for visual variety. (1) **Small tree** (scaled 0.6x of base): same structure but more compact. Shorten the trunk, reduce branch count to 1 main branch, smaller canopy (1.5m diameter). Used near buildings and paths. Adjust UV to maintain texture density. (2) **Large tree** (scaled 1.3x): taller trunk (1.5m to first branch), 3 main branches, wider canopy (3m diameter), more prominent root ridges. Used as landmark/focal point trees. (3) Adjust each variant's canopy shape for silhouette variety: small tree is round, base tree is oval, large tree is spreading/flat-topped. All variants share the same bark and leaf textures. Export each as a separate .glb.
**Acceptance Criteria:**
- 3 tree size variants: small (0.6x), medium (base), large (1.3x)
- Each has distinct silhouette (round, oval, spreading)
- Small tree: compact, fewer branches
- Large tree: taller, wider, more prominent roots
- All share bark and leaf textures
- Each exported as separate .glb
- Variety prevents "cookie-cutter tree" appearance

### Task 25.10: Flower Models -- 3 Varieties
**Status:** TODO
**Description:** Model 3 flower varieties for garden beds and scattered placement. (1) **Daisy-type**: simple flower with 6-8 petal quads arranged in a ring around a center disc, 0.08m diameter, on a thin stem (0.1m tall). Total: ~20 tris. (2) **Tulip-type**: 3 overlapping petal quads forming a cup shape, 0.06m diameter, on a curved stem (0.12m tall). Total: ~12 tris. (3) **Small wildflower**: a tiny cluster of 3-4 dot-on-stem shapes (even simpler, 0.05m tall, 6-8 tris). UV unwrap all three onto a shared 64x64 texture atlas (they are tiny, low resolution is fine). Paint each flower with bright, cheerful colors: daisy white (#FFFFFF) with yellow center (#FFDD44), tulip red (#DD4444), wildflower purple (#8844AA). Stems are thin green (#448844).
**Acceptance Criteria:**
- 3 flower varieties: daisy, tulip, wildflower
- Each under 20 tris
- Shared 64x64 texture atlas
- Bright cheerful colors (white, red, purple)
- Appropriate stem heights (0.05-0.12m)
- Simple but recognizable shapes from camera distance
- Ready for placement in flower bed clusters

### Task 25.11: Flower Beds -- Cluster Placement
**Status:** TODO
**Description:** Create flower bed arrangements for the planned locations (3-4 beds per the layout plan). Each flower bed is a grouped collection of flower instances. Arrangement approach: (1) Create a base flower bed mesh: a slightly raised earth rectangle (0.02m above terrain, rounded edges, 0.5m x 0.3m) with dirt vertex color. (2) Place 8-15 flower instances per bed, mixing all 3 varieties. Arrange with randomized rotation and slight scale variation (0.8-1.2x). Denser at center, sparser at edges. (3) Add 2-3 grass clumps within the bed (flowers and grass intermixed). (4) For each flower bed location, slightly adjust the composition to prevent identical beds. (5) Create 2-3 "bed template" scenes that can be instantiated at different locations with rotation. Consider using MultiMeshInstance3D within each bed for flowers if performance requires.
**Acceptance Criteria:**
- 3-4 flower beds placed at planned locations
- 8-15 mixed flower instances per bed
- Raised earth base for each bed
- Randomized rotation and scale for natural look
- 2-3 template variations prevent identical beds
- Grass clumps intermixed with flowers
- Beds look tended and intentional (garden, not wild)

### Task 25.12: Bush Model and Texture
**Status:** TODO
**Description:** Model a bush for use as natural barriers and path borders. The bush is a squat, rounded shape (0.5m tall x 0.6m wide). Model approach: similar to the tree canopy technique but at smaller scale -- 2-3 overlapping rounded blob shapes forming a full bush silhouette. The bush should look trimmed/maintained (slightly rounded top, not wild). Total: ~150-200 tris. UV unwrap onto 128x128 texture. Paint the bush texture: (1) Base: deep green (#337733). (2) Leaf clusters: varied greens (#338833 to #55AA55) painted as small leaf groups. (3) Light-catching highlights on top surface (#66BB66). (4) Dark shadow underneath (#225522). (5) Subtle flower buds: 3-4 tiny colored dots (pink #DD88AA or white #DDDDDD) suggesting flowering bushes. Create 2 shape variants (one rounder, one more angular) sharing the same texture.
**Acceptance Criteria:**
- Squat rounded bush shape (0.5m x 0.6m)
- 150-200 tris with blob-overlap construction
- 128x128 hand-painted leaf texture
- Light/shadow painting for 3D depth illusion
- Subtle flower bud details
- 2 shape variants sharing one texture
- Trimmed/maintained look (garden aesthetic)

### Task 25.13: Wind Sway Shader -- Grass
**Status:** TODO
**Description:** Create a wind sway shader for grass billboards. The shader (`grass_wind.gdshader`) creates gentle swaying motion driven by vertex position and time. Implementation: (1) Use a sine wave function with vertex world position as seed (so adjacent grass clumps sway at slightly different phases). (2) Displacement is horizontal only (X and Z axes), scaled by vertex height (blade tips move more than base -- base vertices are anchored). (3) Maximum displacement: 0.03m at blade tips. (4) Wind speed: adjustable uniform, default ~1.0 (one full sway cycle per 2 seconds). (5) Add a secondary higher-frequency rustle (smaller amplitude, 3x the primary frequency) for natural double-motion. (6) Include a wind direction uniform (Vector2) that biases the sway in a consistent direction. (7) Apply alpha_scissor at 0.5 threshold for clean grass blade cutouts.
**Acceptance Criteria:**
- Vertex-based wind sway (no bone animation needed)
- Blade tips sway more than bases (height-weighted)
- Phase variation based on world position (not synchronized)
- Primary sway + secondary rustle (two frequencies)
- Wind direction uniform for consistent bias
- Maximum 0.03m displacement (subtle, not violent)
- Alpha scissor for clean blade cutouts

### Task 25.14: Wind Sway Shader -- Trees
**Status:** TODO
**Description:** Create a wind sway shader for trees (`tree_wind.gdshader`). Trees have two layers of wind response: (1) **Trunk sway**: very slow, low-amplitude (0.02m at the top, 0 at the base). Uses vertex height to scale displacement. Frequency: 0.3 Hz (one sway every 3+ seconds). (2) **Canopy rustle**: faster, medium-amplitude leaf movement. The canopy vertices get additional displacement on top of the trunk sway. Use a noise texture (Simplex noise, scrolling with time) to drive per-vertex canopy displacement. Maximum canopy displacement: 0.05m. The noise creates a natural rustling effect where different parts of the canopy move independently. (3) Both layers combine additively. (4) The shader reads the same wind_direction uniform as the grass shader for consistency. Apply to the canopy mesh only (trunk uses a simpler version or the same shader with appropriate parameters).
**Acceptance Criteria:**
- Two-layer wind: slow trunk sway + faster canopy rustle
- Trunk sway height-weighted (none at base, max at top)
- Canopy rustle driven by scrolling noise texture
- Maximum canopy displacement 0.05m
- Shared wind_direction uniform with grass shader
- Different canopy sections move independently (noise-driven)
- Natural, organic-looking tree movement

### Task 25.15: Wind Sway Shader -- Bushes and Flowers
**Status:** TODO
**Description:** Apply wind animation to bushes and flowers. Bushes: use a simplified version of the tree canopy shader -- noise-driven displacement but at lower amplitude (0.02m max) and lower frequency (bushes are stiffer than tree canopies). The bush should sway gently as a whole with subtle internal leaf movement. Flowers: use a stem-sway approach -- the flower head should bob and tilt on a pendulum-like motion. Create a flower_wind.gdshader that bends the stem using vertex height as a pivot weight (base anchored, tip maximum displacement). Maximum flower tip displacement: 0.02m. Add a unique per-instance random phase (using instance transform hash or vertex color) so adjacent flowers sway at different times. Flower sway should feel delicate and springy.
**Acceptance Criteria:**
- Bush sway: gentle, low-amplitude, noise-driven
- Flower sway: stem-bend with pendulum head bob
- Per-instance random phase (no synchronized swaying)
- Flower motion feels delicate and springy
- Bush motion feels stiffer than tree canopy
- Maximum displacements appropriate per vegetation type
- All vegetation moves in response to shared wind direction

### Task 25.16: Seasonal Color Support -- Architecture
**Status:** TODO
**Description:** Design a system that allows vegetation colors to change based on the game's iteration/season cycle. Create a `VegetationSeasonManager` script that: (1) Defines color palettes for 4 seasons: Spring (bright green + pink flower buds), Summer (deep green + full flowers), Autumn (orange/red/gold leaves), Winter (bare branches + snow). (2) Stores per-vegetation-type season data as a dictionary of tint colors. (3) On season change (triggered by IterationManager), tweens all vegetation material tint colors over 3 seconds. (4) For trees: spring = new bright leaves, summer = full canopy, autumn = warm-toned canopy, winter = canopy hidden (or very sparse) showing branches. (5) The system modifies shader uniforms: `season_tint` (Color multiplied onto the texture) and `canopy_density` (alpha threshold for leaf coverage). Document the color values for all 4 seasons.
**Acceptance Criteria:**
- 4 seasonal color palettes defined
- Per-vegetation-type season tint data
- Smooth 3-second color transition on season change
- Trees show seasonal canopy changes (green -> warm -> sparse)
- Shader uniforms: season_tint and canopy_density
- System integrates with IterationManager
- Color values documented for all seasons

### Task 25.17: Vegetation Placement in Town Scene
**Status:** TODO
**Description:** Place all vegetation instances in the Godot town scene according to the layout plan (Task 25.1). Place: (1) 5-7 trees at planned positions, selecting appropriate size variants for each location. Rotate each tree for unique silhouette. (2) 8-12 bushes along paths, around buildings, and as natural barriers. (3) 3-4 flower beds at planned locations using the template scenes. (4) Configure the grass MultiMeshInstance3D to populate grass zones. Verify each placement: (A) vegetation sits on terrain surface (no floating, no intersection), (B) vegetation does not block door access or key navigation paths, (C) vegetation creates pleasing compositions from the isometric camera (framing, layering, focal points), (D) tree canopies do not obscure important gameplay areas. Adjust positions as needed for visual composition.
**Acceptance Criteria:**
- All planned vegetation placed in scene
- Trees at correct positions with size variants assigned
- Bushes border paths and buildings naturally
- Flower beds at planned locations
- Grass populates appropriate zones
- No floating or terrain-intersecting vegetation
- Navigation paths unblocked
- Visual composition pleasing from gameplay camera

### Task 25.18: Vegetation Collision and Interaction
**Status:** TODO
**Description:** Set up collision for vegetation that should block player movement and configure any interaction behavior. Trees: add StaticBody3D + CylinderShape3D collision at the trunk (0.2m radius, 1m height -- player walks around trunks but can walk under canopy). Bushes: add StaticBody3D + BoxShape3D collision matching bush bounds (player cannot walk through bushes). Flowers and grass: no collision (player walks through them). For visual interaction: when the player walks through grass, slightly increase the wind sway amplitude on nearby grass instances (creating a "pushing through grass" effect -- driven by player proximity and velocity). For flowers: player proximity causes slight lean-away (flower shader adds a displacement toward the player direction). These micro-interactions add life.
**Acceptance Criteria:**
- Tree trunk collision (cylindrical, walkable under canopy)
- Bush collision blocks player
- Flowers and grass have no collision
- Player proximity increases grass sway (push effect)
- Flowers lean away from nearby player
- Collision shapes match visual bounds
- Interactions add life without gameplay impact

### Task 25.19: Vegetation Performance Optimization
**Status:** TODO
**Description:** Profile and optimize vegetation performance for 60fps target. Key performance areas: (1) Grass instancing: verify MultiMeshInstance3D is batching draw calls efficiently. Total grass instances should result in 1-3 draw calls, not one per instance. (2) Tree overdraw: leaf canopy alpha testing can cause overdraw. Verify canopy triangles are sorted and alpha testing threshold is efficient. (3) Wind shaders: profile shader cost. The noise texture lookup in tree wind shader is the most expensive -- verify it is not sampled per-frame per-vertex unnecessarily (cache in varying). (4) Total vegetation draw call budget: target under 50 draw calls for all vegetation. (5) LOD: for distant trees (if the town has long sightlines), reduce canopy poly count or switch to billboard impostor. Test with full vegetation density at 1080p.
**Acceptance Criteria:**
- Grass instances batched into 1-3 draw calls via MultiMesh
- No excessive overdraw from canopy alpha testing
- Wind shader noise texture sampling optimized
- Total vegetation under 50 draw calls
- LOD or billboard impostors for distant trees if needed
- Stable 60fps at 1080p with full vegetation density
- No visual quality loss from optimizations

### Task 25.20: Full Vegetation Visual Review
**Status:** TODO
**Description:** Complete visual review of the vegetation system in the town scene. Review from isometric gameplay camera: (1) Grass coverage creates a lush base layer. (2) Trees frame the town with pleasing silhouettes. (3) Bushes provide natural borders and structure. (4) Flower beds add color accents at key locations. (5) Wind animation is subtle and natural on all vegetation types. (6) Vegetation integrates with terrain (no floating, correct density zones). (7) Vegetation integrates with buildings (bushes against foundations, no clipping). (8) The overall town impression is "cozy garden village." (9) Test seasonal color change if implemented. (10) Walk the player through the entire town verifying no visual issues from any angle. Compare against reference images (Stardew Valley, Animal Crossing outdoors). Take final screenshots showing the complete vegetated town.
**Acceptance Criteria:**
- Lush grass coverage on appropriate terrain
- Trees create effective visual framing
- Bushes provide natural structure
- Flower beds add color at focal points
- Wind animation visible and natural
- Vegetation integrates with terrain and buildings
- Overall impression is cozy and inviting
- Seasonal color change functional (if implemented)
- Final screenshots captured for documentation
- Quality comparable to reference titles

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings and material conventions
- **Epic 2** (Visual Style Guide): Color palette and vegetation style
- **Epic 3** (Texture Workflow): Texture resolution and alpha handling
- **Epic 23** (Town Terrain): Terrain mesh and vertex colors for grass placement
- **Epic 24** (Buildings): Building positions for vegetation integration

## Notes

- Grass billboard cross-pattern is a proven technique for stylized games (Genshin Impact, BOTW use similar)
- MultiMeshInstance3D is essential for grass performance -- do not use individual MeshInstance3D per clump
- Tree canopy blob approach is simpler than individual leaf cards and fits the chunky stylized aesthetic
- Wind shader should be subtle -- violent wind is distracting, gentle sway is atmospheric
- Seasonal color is a stretch feature but the architecture should support it from the start
- The grass "push" effect from player proximity is a high-impact polish detail
- Consider adding a single "special tree" with unique shape/color as a town landmark
