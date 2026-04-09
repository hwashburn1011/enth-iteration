# Globbler — Character Art Bible v2.0

## Reference Inspirations

### Primary References
1. **Astro Bot (PS5)** — Compact robot with expressive LED eyes, reflective head plate, chunky proportions. Key takeaway: emotion through simple eye shapes, high-quality surface materials (brushed metal, glossy plastic)
2. **Clank (Ratchet & Clank)** — Small robot with distinct silhouette, antenna, large expressive eyes. Key: how to make a tiny robot feel heroic
3. **Zagreus (Hades)** — ARPG protagonist with strong silhouette, color hierarchy (red/black/gold), readability at gameplay distance. Key: how to make a character read in isometric combat
4. **Emberville Hero** — Pixel art but the proportions translate: chunky, rounded, warm, approachable
5. **Ori (Ori and the Blind Forest)** — Glowing digital creature, emissive accents as personality

### Secondary References
6. **Mega Man X** — Robot hero with armor plates, visor, clean geometric shapes
7. **Wall-E** — Expressive robot with minimal features, personality through movement and eye shape
8. **Baymax (Big Hero 6)** — Soft, rounded robot that feels warm despite being mechanical
9. **The Iron Giant** — Scale of emotion in a machine
10. **Transistor (Red)** — How to make a protagonist glow with inner light

### Style Keywords
Digital, warm, chunky, rounded, emissive, layered, readable, iconic, expressive

---

## Identity Statement

**"What makes Globbler iconic in 1 frame?"**

Globbler is a small, chunky AI agent with a large round head, a single prominent optical sensor (eye visor), circuit-line accents that glow teal-green, and a compact but heroic body. He looks like a digital being made of layered materials: soft matte "skin" panels over a harder chassis frame, with glowing data-lines running through seams. He should feel **warm and curious** — not cold and robotic. Think "digital puppy that grew up to be a warrior."

---

## Silhouette Rules

- **Head is 40% of total height** — oversized for expressiveness and readability
- **Body is compact and sturdy** — not lanky, not bulky. Athletic-cute
- **Arms end in 3-fingered hands** with articulated joints (not sphere stubs)
- **Legs are short but dynamic** — built for running and dashing
- **Antenna/ear on right side** — asymmetric detail for instant recognition
- **Back has a small "data pack"** — like a backpack, contains glowing core visible through translucent panel
- Total height: ~1.5 Blender units (human scale reference)

---

## Color Hierarchy

### Primary (60%): Warm Teal
- Base skin panels: `#4DB8A8` (warm teal, not cold cyan)
- Slightly warmer on chest, slightly cooler on limbs
- Matte finish, slight roughness variation (0.55-0.75)

### Secondary (25%): Dark Charcoal Frame
- Chassis/frame visible at joints and seams: `#2A2D35`
- Metallic: 0.7, Roughness: 0.35
- Brushed metal feel with subtle directional scratches

### Accent (10%): Emissive Circuit Green
- Data lines, eye glow, seam highlights: `#00FFC8`
- Emissive strength: 2.0-4.0
- Pulses subtly with "heartbeat" in idle

### Highlight (5%): Warm Gold
- Special accents, belt buckle, antenna tip, core housing ring: `#D4A843`
- Metallic: 0.9, Roughness: 0.2

---

## Material Zones (8 material slots)

1. **mat_skin_primary** — Warm teal matte panels with subtle noise, SSS for warmth
2. **mat_skin_secondary** — Slightly darker teal for limbs/back
3. **mat_chassis** — Dark brushed metal frame, visible at joints/seams
4. **mat_eye_visor** — Glossy black with emissive pupil/iris behind glass
5. **mat_emissive_circuits** — Glowing teal lines, animated pulse
6. **mat_gold_accent** — Polished gold for special trim
7. **mat_data_core** — Translucent panel on back showing glowing core
8. **mat_antenna** — Gradient from chassis to emissive tip

---

## Face Design

- **Single visor-style eye** — wide horizontal band across face (like a VR headset or Astro Bot)
- Inside visor: **two glowing pupils** that change shape for expression
  - Happy: curved up (^_^)
  - Surprised: wide circles (O_O)
  - Angry: angled down (>_<)
  - Sad: drooped (;_;)
  - Determined: flat bottom, angled top
- Visor surface: glossy black with subtle reflection
- Below visor: subtle "mouth" line that can glow for expressions
- Cheek panels: slightly raised, can blush (emissive pink pulse)

---

## Body Structure

### Head
- Large sphere, slightly flattened vertically
- Visor band wraps 180 degrees
- Top has subtle panel lines (like Astro Bot's head plates)
- Right side: articulated antenna with 3 segments, glowing tip
- Back of head: small data port (circular detail)

### Torso
- Compact, slightly tapered (wider at shoulders)
- Clear panel lines dividing chest, sides, back
- Center chest: circular "core window" — translucent, shows inner glow
- Seams between panels have circuit-line emissive traces
- Belt area: gold accent ring with 2 module mount points

### Arms
- Ball-joint shoulders (visible chassis joint)
- Upper arm: single panel with circuit line
- Elbow: exposed chassis joint
- Forearm: slightly wider (houses ability projector on inner wrist)
- Hands: 3 fingers + thumb, articulated with visible joints
- Inner wrist: small circular port (ability emitter)

### Legs
- Short but proportioned for action
- Thigh: single panel
- Knee: chassis joint
- Shin: panel with vertical circuit line
- Feet: rounded "boot" shape, slightly oversized for stability
- Sole: emissive circle (hover/dash effect source)

### Back
- Data pack: rectangular backpack shape, ~30% of torso width
- Top edge has 2 small exhaust vents
- Center: translucent panel showing glowing data core
- Core pulses with activity (idle: slow, combat: fast, charging: building)

---

## Detail Hierarchy

### Large Forms (readable at 50m game distance)
- Head shape, body proportions, antenna silhouette

### Medium Details (readable at 20m)
- Panel lines, visor, chest core window, backpack

### Small Details (readable at close-up / trailer / menu)
- Circuit traces, joint mechanisms, surface texture noise, scratches, rivet details

---

## Surface Quality Requirements

- **Normal map:** Baked from high-poly with panel edges, rivets, subtle surface imperfections
- **Roughness map:** Variation within each panel (center smoother, edges rougher from wear)
- **Metallic map:** Binary — skin panels are 0, chassis is 1, gold is 1
- **Emissive map:** Circuit lines, eye, core, antenna tip, foot soles
- **AO map:** Baked ambient occlusion in panel seams and joint crevices
- **Curvature map:** Used to drive edge wear in roughness

---

## Technical Specs

- **High-poly target:** 25,000-35,000 tris (for baking)
- **Game-ready target:** 5,000-7,000 tris (after retopo)
- **Texture resolution:** Head 1024x1024, Body 2048x2048
- **Bone count target:** 38 minimum (body 19 + face 12 + extras 7)
- **Shape keys:** 12 minimum for facial expressions
- **LOD0:** Full detail (5-7K tris)
- **LOD1:** Reduced (2.5K tris)
- **LOD2:** Silhouette only (800 tris)
