# Enth: Iteration — Texture Painting Workflow

## UV Unwrapping Standards

### Seam Placement
- Place seams along **hidden edges** (back of legs, underside of objects, architectural corners)
- Seams should never cross the front face visible to the isometric camera
- Character UVs are symmetrical for mirrored painting

### Quality Checks
1. Mark seams along hidden edges
2. Smart UV Project as starting point
3. Minimize Stretch tool to reduce distortion
4. Check stretch overlay (blue = good, red = bad)
5. Pack islands with margin: 8px at 1024, 4px at 512, 2px at 256
6. Straighten rectangular UV islands
7. Apply checker texture to verify no distortion

### Packing
- Minimum 80% island fill density
- Maximum 10% stretch on any island
- Power-of-two texture sizes only

---

## Hand-Painted Texture Process (4 Phases)

### Phase 1: Base Color Layer
1. Flood-fill entire UV with palette mid-tone
2. Large soft brush (50% hardness), block in value zones
3. Lighter on top-facing surfaces (catching light)
4. Darker on bottom/crease areas
5. Only 2-3 value shifts — keep it simple

### Phase 2: Shadow Layer
1. Multiply blend mode at 30-40% opacity
2. Warm purple-brown shadow color (#3A2A4A)
3. Paint shadows in crevices, under overhangs, between planks
4. Follow the style guide's top-left light direction
5. Soft edges — no hard shadow lines

### Phase 3: Highlight Layer
1. Screen or Overlay blend mode at 20-30% opacity
2. Warm cream highlight (#FFF4E0)
3. Paint highlights on top edges, protruding surfaces
4. Add rim light suggestion on edges facing the fill light
5. Keep highlights broader than shadows

### Phase 4: Detail Layer
1. Normal blend mode, small brush
2. Paint individual details: wood grain, stone cracks, rivets
3. Add color variation: warm/cool shifts within the same surface
4. Subtle edge wear: lighter at physical edges (chamfer highlight)
5. Final: tiny bright dots at corners for sparkle (very subtle)

---

## Texture Map Stack

### Albedo (Base Color)
- Contains ALL color and hand-painted light/shadow
- No real lighting — stylized painted lighting baked into the texture
- Resolution per asset type (see naming conventions)

### Normal Map (Surface Detail)
- Created from sculpted high-poly → baked to low-poly
- OR painted manually using nDo-style technique
- Subtle — just enough for surface texture feel, not dramatic bumps
- For stylized: less is more

### Roughness Map
- White = rough, Black = smooth
- Most surfaces: 70-90% rough (0.7-0.9 in shader)
- Wet/polished areas: 20-40%
- Paint variation: worn edges slightly smoother

### Emission Map
- Black everywhere except glowing elements
- Tech circuits: cyan/green glow
- Windows: warm yellow glow
- Eyes: white/blue glow
- Energy 1.0-3.0 depending on intensity

### Ambient Occlusion
- Baked from mesh geometry (Blender AO bake)
- Darkens crevices and contact areas
- Multiply with albedo in shader or bake directly into albedo

---

## Atlas Strategy

### Small Props Atlas (2048x2048)
- 4x4 grid of 512x512 cells
- Barrels, crates, pots, bottles, tools, crystals
- 16 props per atlas

### Architecture Trim Sheet (2048x2048)
- 4 horizontal bands of 2048x512
- Row 1: Wood planks
- Row 2: Stone blocks
- Row 3: Metal/tech panels
- Row 4: Ground/floor surfaces

### Individual Textures
- Characters: 1024x1024 per character
- Bosses: 2048x2048
- Buildings: 2048x2048 per building

---

## Blender Texture Painting Settings
- Brush: Draw, 50% hardness, 100% opacity for base
- Blend modes: Normal (base/detail), Multiply (shadows), Screen (highlights)
- Symmetry: Enable X-axis mirror for character painting
- Texture resolution: Set before unwrapping
- Color source: Always from the color palette reference
