---
epic: 31
title: "Dungeon Tile Set"
phase: 6 — Dungeon Environment
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 31: Dungeon Tile Set

## Overview

Model modular dungeon wall pieces (straight, corner, T-junction, door frame), floor tiles (plain, damaged, grated, tech panel), and ceiling pieces (plain, pipe run, vent, light panel). UV unwrap all pieces and paint tech-themed textures with circuit traces, panel lines, and industrial wear. All pieces must snap together seamlessly on a grid to enable rapid room construction. The dungeon aesthetic is sci-fi industrial: clean metal panels with embedded circuitry, punctuated by damage and decay.

## Success Criteria

- 4 wall types snap together seamlessly on a 2m grid with no visible gaps
- 4 floor types tile perfectly with no seam lines at junctions
- 4 ceiling types connect cleanly overhead
- All pieces UV unwrapped with consistent texel density
- Hand-painted textures with circuit traces, panel lines, and wear at 1024x1024 per tile type
- Normal maps capture panel depth, rivet detail, and circuit line relief
- Emission maps for active circuit traces, light panels, and status indicators
- All tiles exported as .glb and verified in Godot
- A test room can be assembled from tiles in under 5 minutes

---

## Tasks

### Task 31.1: Define Grid System and Module Specifications
- **Status:** TODO
- **Description:** Establish the exact grid specifications for the modular dungeon tile system. Define: base grid unit size (recommended 2m x 2m x 3m — width x depth x wall height), wall thickness (0.2-0.3m), floor thickness (0.1m), connection points (where pieces meet at grid edges). Document the origin point convention — each piece should have its origin at the center-bottom of its grid cell so snapping is straightforward. Define the naming convention: `wall_straight`, `wall_corner_inner`, `wall_corner_outer`, `wall_tjunction`, `wall_doorframe`, `floor_plain`, etc. Create a reference diagram showing how pieces connect on the grid.
- **Acceptance Criteria:**
  - [ ] Grid unit size defined (e.g., 2m x 2m x 3m)
  - [ ] Wall, floor, and ceiling thickness standards set
  - [ ] Connection point specifications documented
  - [ ] Origin point convention established for all pieces
  - [ ] Naming convention defined for all tile types
  - [ ] Reference grid connection diagram created

### Task 31.2: Model Wall — Straight Section
- **Status:** TODO
- **Description:** Model the straight wall section in Blender. The wall fills one grid edge (2m wide, 3m tall, 0.2-0.3m thick). Add geometric surface detail: horizontal panel lines dividing the wall into 3-4 sections, inset panel borders (0.02m recess), rivet points at panel corners, a baseboard strip at the bottom (0.1m tall), and a conduit channel running horizontally at 2m height. The geometry should be efficient — use insets and edge loops rather than boolean operations. Keep the poly count under 200 tris. Ensure the left and right edges are perfectly flat and aligned to the grid for seamless connection with adjacent pieces.
- **Acceptance Criteria:**
  - [ ] Wall is exactly 2m wide, 3m tall
  - [ ] Panel lines divide the surface into sections
  - [ ] Rivets, baseboard, and conduit modeled as geometry
  - [ ] Left/right edges perfectly flat for grid snapping
  - [ ] Poly count under 200 tris
  - [ ] Origin at center-bottom of the grid cell

### Task 31.3: Model Wall — Corner Piece (Inner and Outer)
- **Status:** TODO
- **Description:** Model inner and outer corner wall pieces. The inner corner is an L-shaped piece that fills the grid cell where two walls meet at a 90-degree inside angle. The outer corner fills the outside angle. Both pieces should have the same panel line style as the straight wall, with the corner joint having a vertical pipe or conduit running floor to ceiling to cover the seam. The corner pipe adds visual interest and justifies the geometry join. Ensure both pieces align perfectly with straight wall sections on both connecting edges. Inner corner should have slightly more ambient occlusion/darkness in the crease.
- **Acceptance Criteria:**
  - [ ] Inner corner piece fills 90-degree inside angle
  - [ ] Outer corner piece fills 90-degree outside angle
  - [ ] Both connect seamlessly with straight walls
  - [ ] Corner pipe/conduit covers the seam joint
  - [ ] Panel style matches straight wall sections
  - [ ] Both pieces properly grid-aligned

### Task 31.4: Model Wall — T-Junction Piece
- **Status:** TODO
- **Description:** Model a T-junction wall piece for where a wall intersects another wall perpendicularly. This piece has three connecting edges. Include a structural column or pillar at the T-junction point to cover the three-way seam and provide a visual anchor. The column should have panel detail matching the walls. Add a small junction box or control panel on the pillar face that faces into the open room (this will later be a potential interaction point or just decoration). Ensure all three connecting edges align with straight wall geometry.
- **Acceptance Criteria:**
  - [ ] T-junction connects three wall segments properly
  - [ ] Structural column at the junction point
  - [ ] Junction box/panel on the room-facing side
  - [ ] All three edges align with straight wall pieces
  - [ ] Panel style consistent with other wall types
  - [ ] No gaps visible at any connection

### Task 31.5: Model Wall — Door Frame
- **Status:** TODO
- **Description:** Model a door frame wall piece — same dimensions as a straight wall but with a doorway cut out. The doorway should be 1.2m wide and 2.5m tall (centered in the wall width). Add a door frame border (0.05m wide protruding trim) around the opening. Include a lintel beam across the top with detail (warning stripes, status lights geometry, a small sign plate). Add guide rails on the floor at the doorway edges where a sliding door would travel (the actual door is a separate piece for animation). The door frame should be the most detailed wall piece as players focus on it during transitions.
- **Acceptance Criteria:**
  - [ ] Doorway is 1.2m wide, 2.5m tall, centered
  - [ ] Door frame trim around the opening
  - [ ] Lintel detail with warning stripe geometry
  - [ ] Floor guide rails for sliding door
  - [ ] Most detailed wall piece (player focal point)
  - [ ] Connects with straight walls on both sides

### Task 31.6: Model Floor Tiles — Plain and Damaged
- **Status:** TODO
- **Description:** Model two floor tile variants: plain and damaged. Each floor tile is 2m x 2m x 0.1m thick. The plain floor tile has subtle panel grid lines (4x4 subdivisions) with slightly raised edges between panels and small bolt heads at panel corners. The damaged floor tile is the same base but with: one panel depressed/caved in, cracks radiating from the damage, exposed underlayer/pipes visible through the largest crack, and bent/raised panel edges near the damage. Both tiles should connect seamlessly on all four edges — the damage detail is in the center, edges remain at standard height.
- **Acceptance Criteria:**
  - [ ] Both tiles are exactly 2m x 2m
  - [ ] Plain tile has panel grid with bolt detail
  - [ ] Damaged tile has caved panel, cracks, exposed underlayer
  - [ ] Damage is in the center, edges are standard for tiling
  - [ ] Both tiles connect seamlessly on all edges
  - [ ] Damaged tile tells a story of structural decay

### Task 31.7: Model Floor Tiles — Grated and Tech Panel
- **Status:** TODO
- **Description:** Model two more floor variants: grated and tech panel. The grated floor tile has a metal grating mesh pattern (parallel bars with perpendicular supports) over a recessed space below — light from below could shine up through the grate. Model the grate as geometry (not just a texture) for proper shadow casting. The tech panel floor has a smooth surface with an inset circuit board pattern — raised trace lines forming a geometric circuit pattern, a central processor-like square element, and status indicator dots. This tile suggests the dungeon floor IS the computer.
- **Acceptance Criteria:**
  - [ ] Grated tile has geometric metal grating (not just texture)
  - [ ] Grate allows light to pass through from below
  - [ ] Tech panel has circuit board trace geometry
  - [ ] Central processor element and status indicators modeled
  - [ ] Both tiles connect seamlessly with plain/damaged tiles
  - [ ] Tech panel reinforces "inside a computer" theme

### Task 31.8: Model Ceiling Pieces — Plain and Pipe Run
- **Status:** TODO
- **Description:** Model two ceiling piece variants. The plain ceiling is 2m x 2m with panel line grid (matching the floor for visual consistency) and recessed panel borders. The pipe run ceiling has the same base but with 2-3 pipes running across it in one direction (diameter 0.1-0.15m), secured with pipe brackets every 0.5m. Pipes should be different sizes to suggest different functions (large = ventilation, medium = coolant, small = data/wiring). Both ceiling pieces should connect seamlessly. The ceiling height should position them at exactly 3m above the floor.
- **Acceptance Criteria:**
  - [ ] Both pieces are 2m x 2m at 3m height
  - [ ] Plain ceiling has panel grid matching floor style
  - [ ] Pipe run has 2-3 pipes with brackets
  - [ ] Pipes are different sizes for visual variety
  - [ ] Both pieces connect seamlessly
  - [ ] Ceiling is visible from the isometric camera angle

### Task 31.9: Model Ceiling Pieces — Vent and Light Panel
- **Status:** TODO
- **Description:** Model two more ceiling variants. The vent ceiling has a recessed ventilation grate (0.8m x 0.5m) with angled louvers that suggest air flow direction, surrounded by the standard panel grid. The light panel ceiling has a recessed rectangular light fixture (1.5m x 0.5m) covered by a translucent diffuser panel — this will be the primary light source for illuminated rooms. Add a thin frame around the light panel and small mounting screws at the corners. The light panel geometry should be set up for an emissive material so it glows as a ceiling light.
- **Acceptance Criteria:**
  - [ ] Vent has recessed grate with angled louvers
  - [ ] Light panel has recessed fixture with diffuser geometry
  - [ ] Light panel ready for emissive material
  - [ ] Frame and mounting detail on light fixture
  - [ ] Both pieces connect seamlessly with other ceiling types
  - [ ] Light panel will serve as room illumination source

### Task 31.10: UV Unwrap All Wall Pieces
- **Status:** TODO
- **Description:** UV unwrap all wall piece variants with consistent texel density. Place seams along panel edges and behind pipes/conduits where they will be hidden by shadow. Use a single 1024x1024 texture atlas for all wall variants — arrange UV islands efficiently so straight, corner, T-junction, and door frame walls share one texture sheet. This ensures consistent material appearance and reduces draw calls. Maintain consistent texel density across all wall pieces (same pixel-per-meter ratio). Pack UV islands with 4px padding for mipmap safety. Verify with a checker texture that texel density is uniform.
- **Acceptance Criteria:**
  - [ ] All wall variants UV unwrapped on one 1024x1024 atlas
  - [ ] Seams hidden along panel edges and behind geometry
  - [ ] Consistent texel density across all wall pieces
  - [ ] 4px padding between UV islands
  - [ ] Checker texture shows uniform density
  - [ ] UV layout exported as reference for painting

### Task 31.11: UV Unwrap All Floor and Ceiling Pieces
- **Status:** TODO
- **Description:** UV unwrap all floor and ceiling pieces. Use a separate 1024x1024 atlas for floors and another for ceilings (or combine if space allows). Floor UV layout should keep the panel grid lines aligned across tiles so when two tiles are placed next to each other, the grid pattern continues seamlessly — this means the UV layout must be consistent and the texture pattern must tile at the UV boundaries. Same requirement for ceiling pieces. Place seams on bottom faces and edges that face away from the camera. Verify tiling by placing 4 tiles in a 2x2 grid and checking for seam visibility.
- **Acceptance Criteria:**
  - [ ] Floor pieces share one atlas with tileable layout
  - [ ] Ceiling pieces share one atlas with tileable layout
  - [ ] Panel grid continues seamlessly across tile junctions
  - [ ] Seams on hidden faces only
  - [ ] 2x2 grid test shows no visible seams
  - [ ] Texel density matches wall piece density

### Task 31.12: Hand-Paint Wall Textures
- **Status:** TODO
- **Description:** Paint the wall texture atlas at 1024x1024. Use a cool gray metal base (#6A7A8A) with subtle color variation per panel (slightly different gray tones to avoid monotony). Paint panel border lines as darker recessed channels (#4A5A6A). Add circuit trace lines in a tech pattern using a bright teal/cyan (#40C0C0) at low opacity — these are decorative circuitry embedded in the wall surface. Paint rivet heads as small dark circles with a specular highlight dot. Add wear and scuff marks concentrated at waist height and near the floor (where characters and equipment would contact the wall). Paint rust stains running down from pipe brackets. The door frame should have yellow/black warning stripe paint on the lintel.
- **Acceptance Criteria:**
  - [ ] Cool gray metal base with per-panel color variation
  - [ ] Panel border lines painted as dark recessed channels
  - [ ] Circuit trace pattern in teal/cyan
  - [ ] Rivet heads with specular highlight
  - [ ] Wear marks at waist height and near floor
  - [ ] Door frame lintel has warning stripes

### Task 31.13: Hand-Paint Floor and Ceiling Textures
- **Status:** TODO
- **Description:** Paint the floor texture atlas at 1024x1024. Plain floor: slightly lighter gray than walls (#7A8A9A) with darker panel grid lines, scuff marks from foot traffic concentrated along predicted walking paths, and bolt heads at panel corners. Damaged floor: same base with cracked areas painted as dark gashes with exposed orange-copper underlayer (#C08040) visible through cracks. Grated floor: dark metal bars (#4A4A4A) with lighter gaps showing depth below. Tech panel floor: smooth dark surface (#3A4A5A) with bright circuit traces (#40C0C0 matching walls) and a central green processor element (#40C040). Paint ceiling textures with matching style but slightly darker overall (less direct light reaches ceilings).
- **Acceptance Criteria:**
  - [ ] Floor textures painted with consistent style
  - [ ] Damaged floor shows exposed underlayer through cracks
  - [ ] Grated floor has depth impression
  - [ ] Tech panel has matching circuit trace style
  - [ ] Ceiling textures slightly darker than floors
  - [ ] All textures tile seamlessly at piece boundaries

### Task 31.14: Bake Normal Maps for All Tile Pieces
- **Status:** TODO
- **Description:** Create high-poly versions of representative tile pieces with fine surface detail and bake normal maps. High-poly should add: panel seam depth (beveled recesses between panels), rivet protrusion, pipe surface roundness, bolt head protrusion, circuit trace relief (slightly raised lines), grate bar roundness, and surface roughness variation (subtle bumpy noise). Bake normal maps from high-poly to low-poly using Blender's bake system with appropriate cage distance. The normal maps add the tactile detail that makes flat panels feel like real metal surfaces. Export at matching atlas resolution.
- **Acceptance Criteria:**
  - [ ] High-poly detail sculpted for all distinctive features
  - [ ] Normal maps baked without artifacts
  - [ ] Panel seam depth visible in normal map
  - [ ] Circuit trace relief captured
  - [ ] Surface roughness variation present
  - [ ] Normal maps at matching resolution per atlas

### Task 31.15: Create Emission Maps for Active Elements
- **Status:** TODO
- **Description:** Paint emission maps for all glowing/active elements in the tile set. On the wall atlas: circuit traces emit a dim teal glow, door frame status lights emit green (unlocked) or red (locked) — paint both variants. On the floor atlas: tech panel circuit traces glow, tech panel processor element pulses (create two frames: bright and dim for animation). On the ceiling atlas: light panel diffuser emits bright white (#FFFFFF), vent louvers have a faint glow suggesting internal lighting. All non-glowing areas should be pure black in the emission map. Export emission maps at matching atlas resolution.
- **Acceptance Criteria:**
  - [ ] Wall circuit traces have teal emission
  - [ ] Door frame status lights have green/red variants
  - [ ] Tech panel floor traces and processor glow
  - [ ] Ceiling light panel emits bright white
  - [ ] Non-glowing areas are pure black
  - [ ] Emission maps at correct resolution per atlas

### Task 31.16: Material Setup and .glb Export
- **Status:** TODO
- **Description:** Set up Principled BSDF materials in Blender for all tile pieces. Connect diffuse, normal, and emission textures to the correct channels. Set roughness to 0.3-0.5 for metal surfaces (slightly shiny), 0.7 for exposed/damaged areas (rough). Set metallic to 0.8-1.0 for the metal panels, 0.0 for exposed underlayer/damage areas. Ensure emission maps connect to the Emission channel with energy 1.0 (actual brightness controlled in Godot). Export each tile piece as an individual .glb file with embedded textures to `res://assets/models/dungeon/tiles/`. Verify round-trip import.
- **Acceptance Criteria:**
  - [ ] All materials have correct PBR channel connections
  - [ ] Roughness and metallic values appropriate per surface
  - [ ] Emission maps connected and working
  - [ ] All pieces exported as individual .glb files
  - [ ] Textures embedded in .glb
  - [ ] Round-trip import matches Blender appearance

### Task 31.17: Import into Godot and Create Tile Scenes
- **Status:** TODO
- **Description:** Import all tile .glb files into Godot. For each tile piece, create a .tscn scene file that wraps the mesh with: correct collision shape (StaticBody3D + CollisionShape3D matching the tile geometry), a NavigationRegion3D (for floor tiles, defining walkable area), and an OmniLight3D for the ceiling light panel tile. Configure Godot import settings: sRGB for diffuse, Linear for normal maps, enable mipmaps, VRAM compress. Set up the scene hierarchy so each tile can be instanced into rooms as a prefab. Place tiles on the correct grid alignment with the origin system defined in Task 31.1.
- **Acceptance Criteria:**
  - [ ] All tiles imported and appearing correctly in Godot
  - [ ] Each tile has a .tscn scene wrapper
  - [ ] Collision shapes match tile geometry
  - [ ] Floor tiles have NavigationRegion3D
  - [ ] Light panel ceiling tile has OmniLight3D
  - [ ] Tiles snap to grid correctly when placed

### Task 31.18: Assemble Test Room
- **Status:** TODO
- **Description:** Build a test room in Godot using the tile set to verify everything works together. Create a 6m x 8m room (3x4 floor tiles) with: straight walls on all sides, corner pieces at each corner, one door frame on one wall, mixed floor tiles (2 plain, 2 damaged, 1 grated, 1 tech panel), and varied ceiling tiles. Add a directional light and test the normal maps, emission glow, and shadow casting. Verify: no visible gaps between tiles, textures seamlessly match at junctions, the circuit trace pattern continues logically across tiles, the light panel ceiling tile actually illuminates the room, and the grated floor allows light from below.
- **Acceptance Criteria:**
  - [ ] Test room assembled from tile pieces
  - [ ] No gaps between any tile junctions
  - [ ] Textures seamless across tile boundaries
  - [ ] Normal maps add visible surface detail
  - [ ] Emission glows visible (circuit traces, light panels)
  - [ ] Room assembled in under 5 minutes

### Task 31.19: Performance Testing with Full Room
- **Status:** TODO
- **Description:** Profile the rendering performance of a room built entirely from tiles. Create a larger test: a dungeon floor with 5 connected rooms (approximately 100 floor tiles, 60 wall pieces, 100 ceiling pieces). Measure: draw call count (should benefit from shared materials/atlases), total triangle count, texture memory, and frame time. If performance is an issue: investigate Godot's MultiMesh for repeated tile instances, consider merging static room geometry after level design is finalized, and verify texture compression is working. Target: 60fps with 5 rooms visible at 1080p.
- **Acceptance Criteria:**
  - [ ] 5-room dungeon floor assembled for testing
  - [ ] Draw call count documented and optimized
  - [ ] Triangle count within budget
  - [ ] Texture memory reasonable (shared atlases help)
  - [ ] 60fps at 1080p with all rooms visible
  - [ ] Optimization strategies documented if needed

### Task 31.20: Before/After Documentation and Tile Catalog
- **Status:** TODO
- **Description:** Create documentation for the completed tile set. Capture: before/after screenshots (old untextured dungeon vs. new tiled dungeon), a catalog image showing all tile pieces individually labeled, a grid assembly reference showing how pieces connect, and in-engine screenshots of the test rooms with full lighting. Save media to `_bmad-output/visual-overhaul/screenshots/epic-31/`. Update MASTER-PLAN.md. Create a brief tile usage guide for future room construction explaining the grid system, naming, and assembly rules.
- **Acceptance Criteria:**
  - [ ] Before/after screenshots of dungeon environment
  - [ ] Tile catalog with all pieces labeled
  - [ ] Grid assembly reference diagram
  - [ ] In-engine test room screenshots
  - [ ] Tile usage guide created
  - [ ] MASTER-PLAN.md updated with Epic 31 completion status

---

## Dependencies

- **Epic 02** (Style Guide v3) — Color palette for dungeon environment
- **Epic 03** (Texture Workflow) — UV and texture resolution standards
- **Epic 05** (Combat Fixes) — Dungeon room dimensions for gameplay

## Notes

- The grid system is the most critical decision — get it right in Task 31.1 because everything builds on it
- Shared texture atlases per tile category (walls, floors, ceilings) reduce draw calls dramatically
- Circuit trace patterns should have a consistent visual language: teal = data, green = operational, red = damaged/warning
- Keep poly counts low per tile — these will be repeated hundreds of times in a dungeon
- Test tiling EARLY and OFTEN — fix seam issues as soon as they appear, not after painting 6 textures
