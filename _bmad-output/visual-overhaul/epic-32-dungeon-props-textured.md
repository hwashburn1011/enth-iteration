---
epic: 32
title: "Dungeon Props Textured"
phase: 6 — Dungeon Environment
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 32: Dungeon Props Textured

## Overview

UV unwrap and hand-paint textures for all dungeon prop assets: server racks with screen glow, data terminals with holographic display, energy crystals with refraction material, bioluminescent mushrooms, loot chests with ornate metal, pipes with rust and wear, and tech doors with panel detail. Each prop must reinforce the "inside a crumbling computer" theme while being visually distinct and readable during fast-paced combat gameplay.

## Success Criteria

- All 7 dungeon prop categories have clean UV layouts with no stretching
- Hand-painted diffuse textures at 512x512 or 1024x1024 per prop
- Normal maps for hard-surface detail (metal panels, rivets, crystal facets)
- Emission maps for screens, holographic displays, crystals, and bioluminescent mushrooms
- Consistent tech-industrial color palette (cool grays, teal circuits, green/red status)
- All props exported as .glb and verified in Godot dungeon scenes
- Props readable at combat camera distance (not just zoomed in)
- Total dungeon prop texture memory under 48MB

---

## Tasks

### Task 32.1: Audit Existing Dungeon Props and Plan Textures
- **Status:** TODO
- **Description:** Open all existing dungeon prop models in Blender and assess their state. Document: geometry quality (topology issues), which props need geometry refinement before UV unwrapping, screen-space size at the isometric combat camera distance (determines texture resolution), and which props could share a texture atlas versus needing individual maps. Create a priority list — server racks and data terminals first (most common, most visible), then energy crystals and chests (player interacts with these), then mushrooms, pipes, and doors. Establish the dungeon color palette reference: cool gray base (#5A6A7A), teal circuits (#40C0C0), green status (#40C040), red warning (#C04040), orange rust (#C08040).
- **Acceptance Criteria:**
  - [ ] All dungeon props audited in Blender
  - [ ] Geometry issues documented per prop
  - [ ] Texture resolution assigned per prop based on screen size
  - [ ] Atlas vs individual decision per prop
  - [ ] Priority order established
  - [ ] Color palette reference documented

### Task 32.2: Server Rack — UV Unwrap and Texture Paint
- **Status:** TODO
- **Description:** UV unwrap the server rack model at 1024x1024 (it's one of the largest dungeon props). Paint the diffuse texture: dark metal chassis (#4A5A6A) with visible panel seams, front face has rows of drive bays painted as horizontal rectangular slots with subtle color variation per bay (some green/active, some dark/dead, some blinking amber), side panels have ventilation grid pattern, top has heat exhaust vents, back has cable routing channels. Paint status LEDs as bright green dots on active bays and dim red on dead ones. Add wear: paint scratches on corners, dust accumulation at base, and a serial number sticker on the side panel.
- **Acceptance Criteria:**
  - [ ] UV unwrapped at 1024x1024 with clean layout
  - [ ] Dark metal chassis with panel seam detail
  - [ ] Drive bay rows with varied status colors
  - [ ] Ventilation and exhaust detail painted
  - [ ] Status LEDs visible (green active, red dead, amber blinking)
  - [ ] Wear details: scratches, dust, serial number

### Task 32.3: Server Rack — Emission Map and Screen Glow
- **Status:** TODO
- **Description:** Create the emission map for the server rack. The front face drive bays should glow based on their status: active bays emit dim green (#40C040 at 30% intensity), blinking bays emit amber (#C0A040), the top status panel emits bright teal (#40C0C0). All inactive/dead bays and the chassis body should be black in the emission map. Create a second emission variant where fewer bays are active (for "damaged" server racks on deeper dungeon floors). The emission should be subtle enough to not wash out the diffuse texture detail but bright enough to glow in a dark dungeon room.
- **Acceptance Criteria:**
  - [ ] Emission map isolates all glowing elements
  - [ ] Active bays glow green, blinking amber, status panel teal
  - [ ] Dead/chassis areas are pure black
  - [ ] "Damaged" variant with fewer active elements
  - [ ] Glow intensity visible in dark rooms without washing out detail
  - [ ] Emission map at matching 1024x1024 resolution

### Task 32.4: Data Terminal — UV Unwrap and Texture Paint
- **Status:** TODO
- **Description:** UV unwrap the data terminal (standing computer kiosk) at 512x512. Paint the diffuse: metal pedestal base (#5A6A7A) with floor contact wear, angled screen bezel in darker metal (#3A4A5A), keyboard/input area with individual key squares in a grid, cable port panel on the back. The screen area in the diffuse should be a dark blue-black base (#1A2A3A) — the actual display content will be handled by the emission map. Paint the bezel edge with subtle warning stripe (small section). Add fingerprint smudges on the screen area and wear on the most-used keys.
- **Acceptance Criteria:**
  - [ ] UV layout at 512x512, clean and efficient
  - [ ] Metal surfaces with appropriate industrial paint
  - [ ] Keyboard area with individual key detail
  - [ ] Screen area is dark base for emission overlay
  - [ ] Fingerprint smudges on screen, worn keys
  - [ ] Cable ports and back panel detailed

### Task 32.5: Data Terminal — Holographic Display Effect
- **Status:** TODO
- **Description:** Create the emission map and a holographic display material for the data terminal screen. The emission map should show a sci-fi computer interface: horizontal scan lines, data readout text (painted as pixel-font glyphs, doesn't need to be legible), a radar/map element, and a progress bar. Paint this in bright teal (#40C0C0) on black. For the holographic effect, create a separate shader material for a floating hologram plane above the terminal: the shader should render a semi-transparent projection with scan line overlay, slight vertical wobble (vertex offset), and edge fade. The hologram content is a simple geometric shape (rotating cube, data graph, or map).
- **Acceptance Criteria:**
  - [ ] Terminal screen emission shows sci-fi interface elements
  - [ ] Hologram shader renders semi-transparent projection
  - [ ] Scan line overlay on hologram
  - [ ] Hologram has slight wobble/instability
  - [ ] Hologram fades at edges
  - [ ] Combined effect reads as "active computer terminal"

### Task 32.6: Energy Crystal — Model Refinement and Refraction Material
- **Status:** TODO
- **Description:** Refine the energy crystal model with proper crystalline geometry: sharp faceted faces, irregular cluster of 3-5 crystal shards growing from a rocky base. UV unwrap at 512x512. For the crystal material, create a custom shader that simulates refraction: sample the screen texture behind the crystal with UV offset based on the surface normal to create a distorted see-through effect. Add a fresnel rim glow in the crystal's color (options: blue #4080FF, green #40FF80, or purple #8040FF depending on crystal type). The crystal should appear to glow from within using emission, with the refraction letting you see a distorted version of whatever is behind it.
- **Acceptance Criteria:**
  - [ ] Crystal geometry has sharp faceted faces
  - [ ] Cluster of 3-5 shards on rocky base
  - [ ] Refraction shader distorts the view behind the crystal
  - [ ] Fresnel rim glow in crystal's signature color
  - [ ] Internal glow via emission
  - [ ] 3 color variants for different crystal types

### Task 32.7: Bioluminescent Mushroom — UV Unwrap and Texture
- **Status:** TODO
- **Description:** UV unwrap the mushroom cluster model at 512x512. Paint the diffuse: mushroom caps with a dark, saturated purple-blue (#3A2A5A) on top, transitioning to a lighter lavender underneath where the gills are. Stems should be pale gray-white (#C0C0D0) with a slight translucent quality. Paint small luminescent spots on the cap in bright cyan (#40E0D0) — these are the bioluminescent patches. The rocky base should be painted as dark dungeon stone. Create the emission map with the luminescent spots and the gill undersides glowing softly. The mushrooms should feel alien and beautiful — a contrast to the cold metal dungeon.
- **Acceptance Criteria:**
  - [ ] UV layout at 512x512, clean
  - [ ] Cap colors: dark purple-blue top, lighter lavender gills
  - [ ] Stems pale with translucent quality
  - [ ] Bioluminescent spots on caps in bright cyan
  - [ ] Emission map captures glowing spots and gills
  - [ ] Mushrooms contrast beautifully with metal environment

### Task 32.8: Loot Chest — UV Unwrap and Ornate Texture
- **Status:** TODO
- **Description:** UV unwrap the loot chest at 512x512. Paint an ornate tech-treasure aesthetic: the chest body should be dark metal (#3A4A5A) with decorative circuit-trace filigree patterns in gold (#C0A040) painted along the edges and panels. Paint metal corner brackets and hinges with a brighter metal (#8A9AAA). The lock mechanism on the front should be a circular tech lock with concentric rings. Paint a gradient glow zone on the lid crack where light leaks out when closed (suggesting treasure inside). Create rarity variants by changing the filigree color: gray (common), green (uncommon), blue (rare), gold (legendary). Base texture is the gold/legendary version.
- **Acceptance Criteria:**
  - [ ] Ornate tech-treasure aesthetic combining metal and circuitry
  - [ ] Gold filigree circuit patterns on edges and panels
  - [ ] Metal brackets and hinges detailed
  - [ ] Circular tech lock on front face
  - [ ] Light leak gradient on lid crack
  - [ ] Rarity color variants planned (gray/green/blue/gold)

### Task 32.9: Pipes — UV Unwrap and Rust/Wear Texture
- **Status:** TODO
- **Description:** UV unwrap the pipe prop variants (straight, elbow, T-junction, valve) on a shared 512x512 atlas. Paint the base pipe surface as industrial blue-gray metal (#6A7A8A) with circumferential seam welds at joints (slightly raised, lighter colored). Add heavy rust painting: orange-brown rust (#8B4513 to #C08040 gradient) concentrating at joints, valves, and the bottom of horizontal pipes where moisture collects. Paint drip stains running vertically down from rust spots. Valve wheels should be painted red (#A04040) with chipped paint revealing metal underneath. Add warning labels and flow direction arrows on straight sections.
- **Acceptance Criteria:**
  - [ ] All pipe variants on one 512x512 atlas
  - [ ] Seam welds visible at pipe joints
  - [ ] Heavy rust at joints and moisture collection points
  - [ ] Drip stains running from rust spots
  - [ ] Red valve wheels with chipped paint
  - [ ] Warning labels and flow direction arrows

### Task 32.10: Tech Door — UV Unwrap and Panel Texture
- **Status:** TODO
- **Description:** UV unwrap the tech door (sliding door panel that fits in the wall door frame) at 512x512. Paint the door as a thick metal panel with: horizontal panel divisions (3 sections), a central vertical split where the door opens (painted as a dark seam line), a small window/viewport near the top with reinforced glass (slightly tinted), status indicator light strip along the top edge, and a control panel/lock pad on the adjacent wall. The door should look heavy and industrial. Paint "CAUTION" or hazard markings along the bottom edge. Add scratches and dents suggesting the door has been forced or damaged.
- **Acceptance Criteria:**
  - [ ] Door panel with horizontal divisions and central split
  - [ ] Small viewport window with reinforced glass look
  - [ ] Status indicator strip along top edge
  - [ ] Control panel/lock pad on wall mount
  - [ ] Hazard markings along bottom edge
  - [ ] Damage marks (scratches, dents) for lived-in feel

### Task 32.11: Normal Maps for All Dungeon Props
- **Status:** TODO
- **Description:** Bake normal maps for all dungeon props from high-poly sculpted versions. Priority details to capture: server rack drive bay slot depth and ventilation grid, data terminal key recesses and screen bezel, crystal facet angles and base rock texture, mushroom cap surface bumps and gill ridges, chest filigree relief and metal bracket protrusion, pipe weld seams and valve detail, door panel seam depth and window frame. Use consistent bake settings across all props (cage distance appropriate per prop scale). Export normal maps at matching resolution per prop's diffuse texture.
- **Acceptance Criteria:**
  - [ ] Normal maps baked for all 7 prop categories
  - [ ] Key details captured per prop (slots, seams, facets, gills)
  - [ ] No baking artifacts
  - [ ] Consistent technique across all props
  - [ ] Resolution matches diffuse texture per prop
  - [ ] Normal maps verified under directional light

### Task 32.12: Material Setup and Export All Props
- **Status:** TODO
- **Description:** Configure Principled BSDF materials in Blender for all dungeon props. Metal surfaces: roughness 0.3-0.5, metallic 0.8-1.0. Organic surfaces (mushrooms, crystal base rock): roughness 0.7-0.9, metallic 0.0. Crystal: custom shader (separate from BSDF). Glass (door viewport, terminal screen): roughness 0.1, transmission 0.3. Connect diffuse, normal, and emission maps to correct channels. Export all props as individual .glb files to `res://assets/models/dungeon/props/`. Verify round-trip import for each.
- **Acceptance Criteria:**
  - [ ] All props have correct PBR material values
  - [ ] Metal/organic/glass surfaces differentiated
  - [ ] Emission maps connected for all glowing props
  - [ ] All props exported as .glb with embedded textures
  - [ ] Files in correct project directory
  - [ ] Round-trip import verified for each prop

### Task 32.13: Import into Godot and Verify Materials
- **Status:** TODO
- **Description:** Import all dungeon prop .glb files into Godot and verify material correctness. Check each prop in the 3D viewport with dungeon-appropriate lighting (dim ambient + point lights). Verify: diffuse colors are correct (sRGB color space), normal maps oriented correctly, emission maps produce visible glow in dim lighting, metallic/roughness values look correct (metal is shiny, organic is matte), crystal refraction shader works in Godot (may need to recreate as a Godot .gdshader). Fix any import issues. Configure Godot-specific material features (e.g., rim lighting for prop highlighting).
- **Acceptance Criteria:**
  - [ ] All props appear correctly in Godot 3D viewport
  - [ ] Colors correct (no color space issues)
  - [ ] Normal maps oriented properly
  - [ ] Emission glow visible in dim dungeon lighting
  - [ ] Crystal refraction working in Godot
  - [ ] All import issues resolved

### Task 32.14: Create Prop Scene Prefabs with Interaction
- **Status:** TODO
- **Description:** For each dungeon prop, create a Godot .tscn scene that wraps the mesh with gameplay components. Loot chests: add AnimationPlayer with open/close animation, Area3D for interaction trigger, and a loot spawn point marker. Data terminals: add interaction Area3D and a screen flicker AnimationPlayer. Server racks: add collision and optional destruction state (toppled variant). Energy crystals: add OmniLight3D matching crystal color for local glow. Mushrooms: add dim OmniLight3D for bioluminescent glow. Pipes: add collision only (static decoration). Doors: add AnimationPlayer for slide open/close.
- **Acceptance Criteria:**
  - [ ] Each prop type has a .tscn scene prefab
  - [ ] Interactive props have Area3D triggers
  - [ ] Animated props have AnimationPlayer
  - [ ] Glowing props have matching OmniLight3D
  - [ ] All props have appropriate collision shapes
  - [ ] Prefabs follow project scene composition pattern

### Task 32.15: Place Props in Dungeon Rooms
- **Status:** TODO
- **Description:** Replace primitive/untextured props in all existing dungeon room scenes with the new textured versions. Follow room type guidelines: combat rooms have minimal props (don't obstruct gameplay), loot rooms have prominent chest placement with accent lighting, corridor rooms have pipes and server racks along walls, story rooms have data terminals and crystals as focal points. Place mushroom clusters in darker corners and damaged areas. Ensure prop placement doesn't block navigation or combat movement. Add slight rotation and position variation to repeated props.
- **Acceptance Criteria:**
  - [ ] All primitive props replaced with textured versions
  - [ ] Props placed according to room type guidelines
  - [ ] No navigation or combat movement blocked
  - [ ] Repeated props have placement variation
  - [ ] Loot rooms have accent-lit chest focal points
  - [ ] Corridor rooms have atmospheric pipe/rack placement

### Task 32.16: Prop Lighting Integration
- **Status:** TODO
- **Description:** Tune how dungeon props interact with the room lighting from Epic 33 (or prep lighting). Emissive props (server rack screens, terminal displays, crystals, mushrooms) should contribute meaningfully to room illumination in dark areas. Adjust emission energy values so: server racks provide dim ambient green glow in data rooms, crystals light up small areas around them with colored light, mushrooms create pockets of cool cyan light in dark corners, terminal screens provide localized teal illumination. Non-emissive props (pipes, chests, doors) should receive and shadow light properly. Verify props look good under the combat red emergency lighting as well as normal room lighting.
- **Acceptance Criteria:**
  - [ ] Emissive props contribute visible light to rooms
  - [ ] Crystal colored light creates atmosphere
  - [ ] Mushroom glow creates cyan light pockets
  - [ ] Props look correct under normal and combat lighting
  - [ ] Non-emissive props shadow properly
  - [ ] Overall prop lighting enhances dungeon atmosphere

### Task 32.17: Rarity Variant Materials for Loot Chests
- **Status:** TODO
- **Description:** Create the 4 rarity material variants for loot chests by modifying the filigree and glow colors. Common: gray filigree (#808080), no emission glow, matte finish. Uncommon: green filigree (#40C040), subtle green emission. Rare: blue filigree (#4080FF), brighter blue emission, slightly shinier metal. Legendary: gold filigree (#C0A040), bright gold emission, shiniest metal finish. Save each as a separate ShaderMaterial .tres resource so the chest scene can swap materials at runtime based on loot quality. The player should be able to identify chest rarity from across the room.
- **Acceptance Criteria:**
  - [ ] 4 material variants created (common/uncommon/rare/legendary)
  - [ ] Filigree and emission colors match rarity tier
  - [ ] Shininess increases with rarity
  - [ ] Materials saved as swappable .tres resources
  - [ ] Rarity identifiable at combat camera distance
  - [ ] Visual rarity hierarchy is clear and consistent

### Task 32.18: Destruction/Damage States for Breakable Props
- **Status:** TODO
- **Description:** Create damaged/destroyed mesh variants for props that can be broken during combat: server racks (toppled, sparking), pipes (broken, leaking), and data terminals (smashed screen, smoking). For each, model a damaged version in Blender with: deformed geometry (bent panels, shattered screen), exposed internal components (wires, circuit boards), and debris pieces (fragments that can scatter). Paint the damaged textures with exposed copper underlayer, scorch marks, and shattered edges. Export damaged variants alongside the intact versions. These will be swapped in at runtime when props take damage.
- **Acceptance Criteria:**
  - [ ] Damaged variant for server rack (toppled/sparking)
  - [ ] Damaged variant for pipe (broken/leaking)
  - [ ] Damaged variant for terminal (smashed screen)
  - [ ] Exposed internals visible on damaged versions
  - [ ] Debris fragment meshes for scatter effect
  - [ ] Damaged textures have scorch/shatter detail

### Task 32.19: Texture Memory Audit and Performance
- **Status:** TODO
- **Description:** Audit the total texture memory usage of all dungeon props. Calculate VRAM usage per prop and total. Ensure the total stays under 48MB. In Godot, verify import settings: mipmaps enabled, VRAM compression for diffuse and normal, appropriate format for emission (Lossless if needed for sharp glow edges). Profile frame rate with a room full of props (worst case: loot room with chest, crystals, terminals, mushrooms, pipes). Target 60fps. If over budget, reduce texture resolution on least visible props (pipes from 512 to 256, mushrooms if small).
- **Acceptance Criteria:**
  - [ ] VRAM usage documented per prop
  - [ ] Total under 48MB budget
  - [ ] Compression settings optimized per texture type
  - [ ] Worst-case room profiled at 60fps
  - [ ] Optimizations applied if needed
  - [ ] Performance acceptable on mid-range hardware

### Task 32.20: Before/After Documentation
- **Status:** TODO
- **Description:** Capture comprehensive before/after screenshots. Show: each prop individually (old vs. new), props in context in dungeon rooms, emissive glow in dark rooms, crystal refraction effect, chest rarity variants side by side, and damaged/destroyed states. Save to `_bmad-output/visual-overhaul/screenshots/epic-32/`. Update MASTER-PLAN.md.
- **Acceptance Criteria:**
  - [ ] Before/after for each prop category
  - [ ] Props shown in dungeon room context
  - [ ] Emissive glow demonstrated in dark rooms
  - [ ] Rarity variants comparison shot
  - [ ] All media saved to correct directory
  - [ ] MASTER-PLAN.md updated

---

## Dependencies

- **Epic 31** (Dungeon Tileset) — Tile environment for prop placement context
- **Epic 02** (Style Guide) — Dungeon color palette
- **Epic 03** (Texture Workflow) — UV and texture standards

## Notes

- Emissive props are the dungeon's personality — they create the sci-fi atmosphere in dark rooms
- Crystal refraction is a "wow" effect but may need simplification for performance; start with the full shader and optimize if needed
- Loot chests are the most emotionally important prop — players will stare at them; make them beautiful
- Test all props under COMBAT lighting (red emergency) as well as normal — combat is where readability matters most
