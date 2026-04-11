# Enth: Iteration — Visual Style Guide v3

## Art Direction
**Target:** Emberville / A Short Hike / Ooblets — chunky, rounded, stylized 3D with hand-painted textures and warm inviting palette.

**Core Principles:**
1. **Chunky & Rounded** — No sharp edges anywhere. Everything beveled.
2. **Hand-Painted Look** — Textures show visible brush strokes, not photorealism.
3. **Warm Base, Neon Accents** — Environment is warm/cozy, tech elements glow with neon.
4. **Readable Silhouettes** — Every character recognizable in black outline at game distance.
5. **Less is More** — Medium-low detail. No micro-detail. Readable at distance.

---

## Character Proportions

### Player (Globbler)
- **Height:** 3 heads tall (1.5m total)
- **Head:** 40% of body width, large round shape
- **Eyes:** 30% of head height, big and expressive
- **Arms:** Stubby, reach to mid-thigh, oversized hands (60% of head width)
- **Legs:** 1 head-length long, thick and sturdy
- **Body:** Rounded sphere/egg shape, wider than tall

### NPCs
- **Height:** 3.5-4 heads tall (1.6-1.8m)
- **Proportions:** Slightly more realistic but still chunky
- **Unique Feature:** Each NPC has one distinguishing visual element (sage's staff, sprite's antenna)

### Enemies (Small)
- **Height:** 2-2.5 heads tall (0.7-1.0m)
- **Shape Language:** Spiky = aggressive, Blob = swarm, Angular = elite
- **Readability:** Must be distinguishable from player at all times

### Enemies (Boss)
- **Height:** Up to 6 heads tall (3m+)
- **Scale:** 2-3x player size minimum
- **Phases:** Visual state changes (cracks, color shifts, new parts revealed)

---

## Edge Treatment

| Object Type | Bevel Width | Segments | Smooth Angle |
|-------------|-------------|----------|--------------|
| Characters (organic) | 0.03-0.05m | 3 | 60° auto-smooth |
| Props (small) | 0.01-0.02m | 2 | 45° auto-smooth |
| Buildings (architectural) | 0.02-0.04m | 2 | 45° with edge loops |
| Weapons/Tech | 0.01-0.02m | 2 | 30° for sharper creases |
| VFX meshes | None | 0 | Flat shading OK |

**Rule: NEVER sharp 90° edges.** Even "hard" surfaces get a small bevel.

---

## Color Palette

### Environment Base Colors
| Name | Hex | RGB | Use |
|------|-----|-----|-----|
| Grass Green | #6FAF6A | (111, 175, 106) | Town ground, meadows |
| Dirt Path | #8A6A4A | (138, 106, 74) | Walkways, cleared ground |
| Stone Grey | #9A9A9A | (154, 154, 154) | Walls, boundaries, rocks |
| Dark Stone | #5A5A5A | (90, 90, 90) | Dungeon walls, deep areas |
| Wood Brown | #7A5A3A | (122, 90, 58) | Props, fences, furniture |
| Dark Wood | #5A3A2A | (90, 58, 42) | Doors, aged wood |
| Roof Red | #A64832 | (166, 72, 50) | Building rooftops |
| Water Surface | #4A8ABA | (74, 138, 186) | Lakes, wells, streams |
| Water Deep | #2A5A7A | (42, 90, 122) | Deep water areas |

### Character Colors
| Name | Hex | RGB | Use |
|------|-----|-----|-----|
| Player Cyan | #40D9D2 | (64, 217, 210) | Globbler body |
| Sage Purple | #593E8C | (89, 62, 140) | AI Sage robe |
| Sprite Teal | #33B88A | (51, 184, 138) | Cache Sprite body |
| Enemy Red | #D92619 | (217, 38, 25) | GlitchBug |
| Enemy Green | #33CC4D | (51, 204, 77) | MemoryLeak |
| Enemy Blue | #2640D9 | (38, 64, 217) | RogueProcess |
| Boss DarkRed | #801A26 | (128, 26, 38) | Corrupted Compiler |

### Tech/Accent Colors (Neon)
| Name | Hex | RGB | Use |
|------|-----|-----|-----|
| Neon Cyan | #00FFDD | (0, 255, 221) | Player tech, data effects |
| Neon Magenta | #FF00AA | (255, 0, 170) | Corruption, danger |
| Neon Yellow | #FFE500 | (255, 229, 0) | Loot, rewards, level-up |
| Neon Green | #00FF66 | (0, 255, 102) | Heal, safety, clear |
| Neon Red | #FF3333 | (255, 51, 51) | Damage, combat, barriers |

### UI Colors
| Name | Hex | RGB | Use |
|------|-----|-----|-----|
| Panel Dark | #1A1A2E | (26, 26, 46) | UI background panels |
| Panel Border | #264050 | (38, 64, 80) | UI borders |
| Text Light | #E0E0E0 | (224, 224, 224) | Primary text |
| Text Accent | #4DD9CC | (77, 217, 204) | Titles, highlights |
| Shadow | #3A2A4A | (58, 42, 74) | Shadow areas |
| Highlight | #FFF4E0 | (255, 244, 224) | Light areas |

---

## Lighting Standards

### Town (Outdoor)
- **Key Light:** Directional, warm (#FFF0D9), intensity 1.0-1.2, angle -50° from top-left
- **Fill Light:** Directional, cool (#B3CCE6), intensity 0.3-0.4, opposite side
- **Ambient:** Warm (#CCC8B4), energy 0.5-0.7
- **Shadows:** Soft, 4-split cascade
- **Sky:** Gradient blue (#87CEEB) to white at horizon

### Dungeon (Indoor)
- **Key Light:** Weak directional, cool (#C8D0E6), intensity 0.3-0.5
- **Point Lights:** Warm at fixtures, cool from tech, colored per room type
- **Ambient:** Very low (#373D4D), energy 0.3-0.5
- **Fog:** Enabled, density 0.015, cool tint
- **Post-Processing:** SSAO, bloom (0.3-0.5), volumetric fog

### Combat Room Accents
| Room Type | Accent Color | Light Temp |
|-----------|-------------|-----------|
| Tutorial/Corridor | Cyan | Cool neutral |
| Combat | Red | Warm aggressive |
| Loot | Gold | Warm inviting |
| Story | Blue | Cool mysterious |
| Boss | Deep Red | Hot dramatic |

---

## Material Standards

### Base Settings (all materials)
- **Roughness:** 0.7-0.9 (matte, non-reflective)
- **Metallic:** 0.0 for organics/wood, 0.3-0.6 for metal props
- **Emission:** Only on tech elements, energy 0.5-2.0 for subtle glow
- **Vertex Colors:** Enabled for color variation without extra texture samples

### Texture Maps Per Asset
| Asset Type | Albedo | Normal | Roughness | Emission | AO |
|------------|--------|--------|-----------|----------|-----|
| Characters | Yes | Yes | Optional | Eyes/tech only | Yes |
| Props | Yes | Optional | Optional | Tech glow | Optional |
| Buildings | Yes | Yes | Yes | Windows | Yes |
| Enemies | Yes | Yes | Optional | Glow areas | Optional |

---

## Silhouette Readability Test
Every character/enemy must pass this test:
1. Fill the model completely black
2. View from the isometric game camera angle
3. The silhouette must be instantly recognizable
4. Player, each enemy type, and each NPC must be distinguishable from each other

---

## Animation Principles
- **Snappy Timing:** Quick anticipation (2-3 frames), fast action, settle
- **Squash & Stretch:** Subtle on jumps/impacts (10-20% deformation)
- **Follow-Through:** Hair/cloth/loose parts delay 2-3 frames
- **Exaggeration:** Bigger motions than real life (arm swings wider, jumps higher)
- **12 Principles:** Apply Disney's 12 principles adapted for game animation

---

## DO / DON'T

### DO
- Keep assets simple and chunky
- Use consistent warm lighting
- Bevel ALL edges
- Use limited color palette
- Make silhouettes distinct
- Hand-paint texture details
- Use emission for tech/magic elements

### DON'T
- Use photorealistic textures
- Leave sharp edges on any model
- Over-detail small props
- Mix realistic and stylized elements
- Use more than 5 colors per asset
- Make everything the same size/shape
- Forget the isometric camera perspective
