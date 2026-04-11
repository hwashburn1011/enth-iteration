---
epic: 19
title: "AI Sage Full Rebuild"
phase: 4
status: TODO
priority: high
estimated_hours: 60
dependencies: [1, 2, 3, 4]
---

# Epic 19: AI Sage Full Rebuild

## Overview

Complete visual rebuild of the AI Sage -- the primary quest-giving NPC and mentor figure in Enth: Iteration's town hub. The AI Sage is a tall, robed wise figure who serves as the player's guide through the game's narrative, dispensing quests, lore, and philosophical observations about the nature of the simulation. This epic covers the full art pipeline from concept through Godot integration: sculpt of the robed body with hood, staff with crystal, floating wisdom particles, hand-painted rich purple fabric textures with gold trim embroidery, cloth-like bone rig for robe dynamics, and a full NPC animation set.

**Visual Identity:** A tall (1.8m), slender figure draped in flowing purple robes with a deep hood that shadows the face. The face is simple and abstracted -- two glowing eye points visible in the hood shadow, no detailed facial features (suggesting a being of data, not flesh). One hand holds a tall staff (2m) topped with a floating crystalline data structure that rotates slowly. Floating particles of golden "wisdom data" orbit the sage's upper body. Gold embroidery trim on robe edges catches light.

**Quality Target:** Emberville/Stardew Valley stylized 3D. The AI Sage should feel wise, ancient, and slightly otherworldly. The robe should have visible fabric folds painted in the texture. The staff crystal should be a visual focal point with its glow.

## Success Criteria

- [ ] AI Sage model is a properly sculpted robed figure (not stacked primitives)
- [ ] Hand-painted diffuse with rich purple fabric folds and gold trim embroidery
- [ ] Staff with floating crystal data structure and glow effect
- [ ] Robe rig with cloth-like bone chain for natural drape movement
- [ ] Full animation set: idle float, speaking gesture, pointing, mystical cast
- [ ] Exported as .glb and integrated in Godot replacing the placeholder
- [ ] Silhouette is instantly readable as "wise robed figure" at camera distance
- [ ] Polycount under 3,000 tris; single 512x512 texture atlas

---

## Tasks

### Task 19.1: Reference Sheet and Character Concept
**Status:** TODO
**Description:** Gather reference images of stylized wizard/sage characters from games (Stardew Valley Wizard, Ori and the Blind Forest's Spirit Tree, robed RPG mentor figures) and flowing fabric reference. Create a concept sketch showing the AI Sage from front, side, back, and isometric views. Define proportions: total height 1.8m with robes touching the ground (feet not visible, creating a floating/gliding impression), broad shoulders tapering to a narrow hem, hood extending forward 0.15m past the face. Staff design: 2m tall wooden shaft with gold bands, topped by a diamond-shaped crystalline structure (0.15m across) that floats 0.02m above the staff tip. Annotate color zones: deep royal purple (#3A1066) for robe body, lighter lavender (#8866AA) for fabric fold highlights, gold (#CCAA44) for trim and staff bands, bright gold (#FFDD66) for crystal glow.
**Acceptance Criteria:**
- 4+ view reference sheet with dimension annotations
- Robe silhouette design with hood and drape defined
- Staff and crystal design documented
- Color palette with hex values for all zones
- Character reads as "wise mentor" from silhouette alone
- Proportions fit the stylized aesthetic (not realistic body proportions)

### Task 19.2: High-Poly Sculpt -- Robe Body and Hood
**Status:** TODO
**Description:** Sculpt the AI Sage's robed body in Blender. Start with a cylinder base for the body, then sculpt the fabric drape. Key sculpt areas: (1) Hood -- deep cowl shape extending forward, open at the front to show a shadowed face void (sculpt the hood interior as a recessed cavity). (2) Shoulder area -- broad, slightly exaggerated shoulder pads where the robe fabric bunches. (3) Chest/torso -- smooth fabric plane with a central fold line running vertically. (4) Waist area -- subtle belt/sash indent where the robe cinches slightly. (5) Lower robe -- flowing fabric with 5-7 deep vertical folds that fan out toward the ground hem. (6) Sleeves -- wide bell sleeves visible at the front (where hands emerge), with 3-4 fabric folds. Use the Crease and Clay Strips brushes to define fold lines, then Smooth to keep the fabric soft. Target 300K-500K polys.
**Acceptance Criteria:**
- Deep cowl hood with forward extension and face void
- Exaggerated shoulder area with fabric bunching
- Central fold line on chest with vertical drape
- Sash/belt indent at waist
- 5-7 deep vertical folds in lower robe
- Wide bell sleeves with fold detail
- Smooth fabric surfaces between folds

### Task 19.3: High-Poly Sculpt -- Hands, Face Void, and Details
**Status:** TODO
**Description:** Sculpt the visible body details. Hands: simple mitten-like hands (4 fingers + thumb, not individually articulated -- stylized) emerging from the bell sleeves. The right hand is positioned for staff grip (curled fingers). The left hand is open, palm forward (gesture pose). Face void: inside the hood, sculpt a smooth concave surface with two shallow raised bumps where the eyes will glow (these are not actual eyes, just raised points for the emission texture). Add robe detail: along the hem, shoulder edges, and sleeve cuffs, sculpt a raised trim border (0.01m wide raised edge) that will receive the gold embroidery paint. Add subtle fabric texture across the robe surface (very fine woven pattern using a texture stamp brush -- this will transfer to the normal map).
**Acceptance Criteria:**
- Mitten-like stylized hands (right gripping, left open)
- Hood interior with eye-glow bump positions
- Raised trim border along hem, shoulders, and sleeve cuffs
- Subtle woven fabric texture across robe surface
- Detail level appropriate for normal map transfer
- Consistent stylized proportions throughout

### Task 19.4: Model -- Staff and Crystal
**Status:** TODO
**Description:** Model the AI Sage's staff separately from the body. The staff shaft: a slightly tapered cylinder (thicker at base, thinner at top) with subtle organic curves (not perfectly straight -- bent slightly like a branch). Add 3 gold band rings at regular intervals along the shaft (separate geometry or marked for painting). At the top, model a forked cradle (two curved prongs) that frame the floating crystal. The crystal itself: a diamond/octahedron shape (dual pyramid) with beveled edges, approximately 0.15m across. The crystal is modeled floating 0.02m above the staff cradle prongs (separate object, will be animated to rotate). Add small decorative detail: carved runes or simple geometric notches on the staff shaft between the gold bands.
**Acceptance Criteria:**
- Staff shaft with organic taper and subtle curves
- 3 gold band positions marked or modeled
- Forked cradle top frames the crystal
- Crystal is diamond/octahedron shape with beveled edges
- Crystal modeled as separate floating object
- Decorative rune/notch details on shaft
- Staff total: ~200-300 tris

### Task 19.5: Retopology -- Cloth-Friendly Topology
**Status:** TODO
**Description:** Retopologize the sculpt into a game-ready mesh targeting 2,500-3,000 triangles. The topology must support cloth-like robe deformation: (1) Lower robe: horizontal edge loops every 0.15m vertically for smooth bending when the hem sways. Fold valleys should align with edge loops. (2) Sleeves: 4-5 loops along length for arm raise/lower. (3) Hood: sufficient loops for subtle tilting (8-10 around the circumference). (4) Torso: relatively low poly (flat surface, less deformation). (5) Hands: 40-50 tris each (simple shapes). The key priority is the lower robe getting enough topology -- this is where the most visible animation deformation occurs. Staff and crystal are separate objects with simple topology.
**Acceptance Criteria:**
- Total tris: 2,500-3,000 (body + hands)
- Lower robe: horizontal loops every 0.15m for cloth deformation
- Fold valleys align with edge loops
- Sleeves: 4-5 loops for arm movement
- Hood: 8-10 circumference loops for tilt
- Hands: 40-50 tris each, simple stylized shape
- Staff + crystal separate: ~200-300 tris additional

### Task 19.6: UV Unwrap and Layout
**Status:** TODO
**Description:** UV unwrap the AI Sage onto a 512x512 atlas. The robe front is the most important visual area (player sees this most in dialogue). UV allocation: robe front 25%, robe back 15%, sleeves 10%, hood 15%, lower robe/hem 15%, hands 5%, face void 5%, trim borders 10%. Place seams along the sides of the robe (hidden from front/back views), under the arms, and at the hood-to-shoulder junction. The trim border should unwrap as a continuous strip for easy embroidery pattern painting. Staff gets a separate UV island (cylindrical unwrap). Crystal gets a simple unwrap (small island, will be mostly emission). Minimize stretching on the robe front surface.
**Acceptance Criteria:**
- 512x512 atlas with robe front prioritized
- UV allocation follows visibility priority
- Seams hidden from front and isometric camera angles
- Trim border as continuous strip for embroidery painting
- Staff and crystal have clean UV islands
- Minimal stretching on robe front
- 4px island padding

### Task 19.7: Bake Normal Map
**Status:** TODO
**Description:** Bake the normal map from high-poly to low-poly. Key details that must transfer: (1) Fabric fold depth -- the deep vertical folds in the lower robe must have strong normal map detail to sell the fabric illusion on the flat low-poly surface. (2) Woven fabric micro-texture -- the stamp texture should appear as subtle surface variation. (3) Trim border height -- the raised gold trim border should be clear in the normal map. (4) Hood interior depth -- the concave face void should have normal map detail showing depth. (5) Sleeve fold detail. Check for artifacts at seams (add 4px bleed). The normal map is particularly important for the AI Sage because fabric material relies heavily on normal-driven light response for visual quality. Save as `ai_sage_normal.png`.
**Acceptance Criteria:**
- Fabric fold depth transfers clearly to normal map
- Woven texture visible as subtle surface variation
- Trim border height distinct in normal map
- Hood interior shows depth via normals
- 4px bleed on all UV borders
- Fabric material reads convincingly under directional light
- Saved as `ai_sage_normal.png` at 512x512

### Task 19.8: Hand-Paint Diffuse -- Robe Fabric Base
**Status:** TODO
**Description:** Paint the base fabric texture. Deep royal purple (#3A1066) as the base fill across the entire robe. Then paint fabric fold shadows and highlights: (1) Fold valleys: darken to deep purple-black (#1A0833) using a soft airbrush, following every fold crease defined in the sculpt/normal map. (2) Fold ridges: brighten to lavender (#8866AA) along the tops of each fold, where light would catch. (3) Upper robe (chest, shoulders): slightly warmer purple tint (lean toward magenta) since it catches more overhead light. (4) Lower robe near hem: slightly cooler/darker (lean toward blue-purple). (5) Sleeve interiors: dark (hidden from light). The painted lighting should be consistent with top-left light direction (matching the game's primary light). This hand-painted light/shadow is what makes stylized fabric look rich.
**Acceptance Criteria:**
- Deep royal purple base with no unpainted areas
- Fold valleys darkened to deep purple-black
- Fold ridges brightened to lavender
- Warm-to-cool gradient from top to bottom of robe
- Sleeve interiors appropriately dark
- Hand-painted lighting consistent with top-left source
- Fabric reads as rich, heavy material

### Task 19.9: Hand-Paint Diffuse -- Gold Trim and Embroidery
**Status:** TODO
**Description:** Paint the gold embroidery trim details. The raised trim borders (hem, shoulders, sleeve cuffs) should be painted with: (1) Base gold (#CCAA44) fill on all trim areas. (2) Darker gold (#886622) in recesses and on the shadow side. (3) Bright gold highlights (#FFDD66) on the light-catching edges. (4) Within the trim, paint a repeating geometric embroidery pattern: simple angular motifs (chevrons, diamond chains, or circuit-board-inspired geometric lines) that suggest both traditional embroidery and digital patterns. Use a fine 2-3px brush for the pattern detail. (5) Add a few gold accent details elsewhere: the sash/belt gets a gold buckle/clasp, and the hand edges get a subtle gold fingertip highlight suggesting enchanted gloves. The gold should pop against the purple without being garish.
**Acceptance Criteria:**
- All trim borders painted in gold with shadow/highlight variation
- Repeating geometric embroidery pattern within trim borders
- Pattern combines traditional and digital design motifs
- Gold sash buckle/clasp detail
- Gold fingertip accents on hands
- Gold pops against purple without being overwhelming
- Pattern is detailed enough to reward close inspection

### Task 19.10: Hand-Paint Diffuse -- Hood, Face, and Staff
**Status:** TODO
**Description:** Paint the remaining detail areas. Hood interior: very dark purple-black (#0A0022) fading to pure black at the deepest point. Eye glow spots: small circles of bright gold (#FFDD66) at the eye positions (these will also be in the emission map). The effect should be two floating golden lights in darkness. Staff shaft: warm brown (#664422) wood base, with darker grain lines (#3A2211) painted lengthwise, and lighter wood highlights (#886644) on the light-catching side. Gold bands: same gold treatment as robe trim (#CCAA44 base, highlight, shadow). Staff cradle prongs: darker metal (#555555) with gold tips. Crystal: bright luminous teal (#44DDBB) base with white (#FFFFFF) facet highlights. Save the complete diffuse as `ai_sage_diffuse.png`.
**Acceptance Criteria:**
- Hood interior deeply dark with smooth gradient to black
- Eye glow spots are two bright gold circles in darkness
- Staff wood painted with grain and directional lighting
- Gold bands match robe trim quality
- Crystal painted bright teal with white facet highlights
- All areas complete -- no unpainted spots
- Saved as `ai_sage_diffuse.png` at 512x512

### Task 19.11: Emission Map and Wisdom Particles Setup
**Status:** TODO
**Description:** Create the emission map and set up the wisdom particle system. Emission map (512x512): eye glow spots emit bright gold (#FFDD66) at full intensity, crystal emits bright teal (#44DDBB) at full intensity, gold trim emits at ~10% intensity (subtle warm glow suggesting enchanted fabric), all else black. Save as `ai_sage_emission.png`. Wisdom particles: create a GPUParticles3D node with 15-20 small particles (billboard quads, 0.02m) in gold (#FFDD66 with emission). Particles orbit the sage's upper body in a slow helix pattern (1m radius, 6-second orbit period), gently rising and falling (0.2m vertical oscillation). Particles have a soft fade-in/fade-out lifecycle (2 second lifetime). These represent floating data/wisdom and should feel serene and mystical.
**Acceptance Criteria:**
- Emission map with eye glow, crystal glow, and subtle trim glow
- 15-20 gold wisdom particles orbiting upper body
- Helical orbit pattern with vertical oscillation
- Gentle, serene particle behavior (not frantic)
- Particles use emission material (self-lit)
- Saved as `ai_sage_emission.png` at 512x512

### Task 19.12: Material Setup and Crystal Glow
**Status:** TODO
**Description:** Configure materials for Godot compatibility. Robe material: diffuse texture as Base Color, normal map (Non-Color), emission map with energy 1.0. Roughness 0.85 (fabric is very matte). Metallic 0.0. For the crystal specifically: create a separate material with transparency enabled (alpha 0.6 for translucent crystal look), emission energy 3.0 (strong glow), roughness 0.1 (crystal is smooth and slightly reflective), and a subtle refraction hint if Godot supports it. Add a point light (OmniLight3D) as a child of the crystal node: teal color (#44DDBB), 1.5m range, energy 0.8, to cast actual light on the sage and surrounding area. Test the complete material setup under town lighting conditions (warmer, brighter than dungeon).
**Acceptance Criteria:**
- Robe material: roughness 0.85, metallic 0.0, emission energy 1.0
- Crystal material: transparent, high emission, low roughness
- Crystal point light casts teal glow on sage and surroundings
- Materials display correctly under town lighting conditions
- All textures transfer to Godot without channel issues
- Crystal glow is the visual focal point

### Task 19.13: Skeletal Rig -- Body and Robe Chains
**Status:** TODO
**Description:** Create the AI Sage's armature. Since the sage floats/glides (feet not visible), the rig focuses on upper body expressiveness and robe cloth motion. Bone hierarchy: `root` (ground level), `hover` (controls float height, 0.05m above ground), `spine_lower`, `spine_upper`, `head` (hood tilt), `shoulder_L/R`, `arm_L/R`, `hand_L/R` (simple -- no individual fingers). Robe cloth chains: 5 bone chains along the lower robe hem, each 3-4 bones long, following the fold lines (these create the cloth sway effect). Staff: `staff_grip` (parented to hand_R), `staff_shaft`, `crystal` (separate bone for independent rotation). Eye glow: `eye_L/R` bones for subtle independent drift. Total: ~35-40 bones.
**Acceptance Criteria:**
- Upper body rig: spine, head, shoulders, arms, hands
- 5 robe cloth chains (3-4 bones each, 15-20 robe bones)
- Staff bone chain parented to right hand
- Crystal bone for independent rotation
- Eye glow bones for drift
- ~35-40 total bones
- Hover bone for floating position control

### Task 19.14: Weight Painting -- Robe Cloth and Body
**Status:** TODO
**Description:** Weight paint the sage mesh. Upper body: standard weight painting (spine/shoulder/arm bones get clean rigid-to-blended weights for upper body posing). Head/hood: hood geometry weighted to head bone with soft falloff at shoulder junction. Robe cloth chains: this is the critical area. Each of the 5 hem chains influences a vertical strip of the lower robe. Weight should be: top of strip at 100% spine_lower, gradient blending through the 3-4 chain bones, with the hem edge at 100% of the last chain bone. Adjacent chain strips should have 15-20% overlap zones to prevent hard seams during sway. Staff: rigid binding to staff_grip bone (100%). Crystal: rigid binding to crystal bone. Test the cloth deformation by rotating each chain end bone 15-20 degrees -- the robe should sway naturally without creasing.
**Acceptance Criteria:**
- Upper body weights clean for arm/torso posing
- Hood weighted to head with soft shoulder falloff
- 5 robe cloth chains with proper vertical gradient
- 15-20% overlap between adjacent cloth chain influence zones
- No creasing when cloth chain bones rotate 15-20 degrees
- Staff and crystal rigidly bound
- Eye bones have tight localized influence on eye glow geometry

### Task 19.15: Animation -- Idle Float
**Status:** TODO
**Description:** Create a 4-second looping idle animation (96 frames at 24fps). The AI Sage should feel serene and slightly otherworldly. Primary motion: gentle vertical hover bob on the hover bone (0.03m amplitude, one full sine cycle over 96 frames). Robe cloth: the 5 hem chains sway gently in a wind-like pattern (each chain has a slight offset timing, creating a wave that travels across the hem from left to right over 4 seconds). Head: very slight tilt oscillation (2-3 degrees, slow) suggesting quiet contemplation. Left hand (gesture hand): subtle finger curl/uncurl on a slow cycle. Right hand: holds staff steady (minimal movement). Crystal: continuous slow rotation (15 degrees per cycle) on the crystal bone. Eye glow: tiny 0.005m drift on each eye, independent timing. The overall effect should be "serene floating presence."
**Acceptance Criteria:**
- 96-frame seamless loop with gentle hover bob
- Robe hem sway with traveling wave pattern
- Head tilt suggesting contemplation
- Left hand subtle finger movement
- Staff held steady, crystal rotating slowly
- Eye glow drift adds organic life
- Overall serene, mystical atmosphere

### Task 19.16: Animation -- Speaking Gesture
**Status:** TODO
**Description:** Create a speaking/dialogue gesture animation (2 seconds, 48 frames, looping). This plays when the player is in dialogue with the AI Sage. The left hand (gesture hand) performs a slow, deliberate gesticulation: raises from rest position, extends outward with open palm (reaching toward the player), holds briefly, then draws back with a slight circular motion (as if weaving wisdom from the air). The right hand tilts the staff slightly forward (welcoming). Head tilts 5-10 degrees toward the player. Robe responds to the arm movement with subtle cloth follow-through on the left side. The crystal glow could pulse slightly brighter during the gesture peak (frame 20-30) via the crystal bone's scale animation. The gesture should feel sage-like: slow, deliberate, graceful.
**Acceptance Criteria:**
- Left hand performs slow, deliberate gesture outward and back
- Right hand tilts staff forward slightly (welcoming)
- Head tilts toward the player
- Robe cloth follows arm movement with natural delay
- Crystal pulses brighter at gesture peak
- Gesture feels wise and deliberate, not hurried
- Seamless loop for extended dialogue sequences

### Task 19.17: Animation -- Pointing (Quest Direction)
**Status:** TODO
**Description:** Create a pointing animation (1.5 seconds, 36 frames, one-shot with hold). This plays when the AI Sage directs the player somewhere (quest direction, pointing toward dungeon entrance, etc.). The left arm raises and extends fully, index finger (or mitten-tip in the stylized design) pointing outward. The head turns in the pointing direction. The staff in the right hand tilts backward slightly (counterbalance). The robe responds to the arm raise with cloth follow-through on the left shoulder and sleeve. The hold phase (frames 24-36) keeps the pointing pose steady with minimal hover bob. This animation should be blend-compatible with idle (transitions smoothly from idle pose to pointing and back).
**Acceptance Criteria:**
- Left arm extends fully in pointing gesture
- Head turns toward pointing direction
- Staff tilts as counterbalance
- Robe cloth follow-through on arm raise
- Hold phase is stable for variable duration
- Blends smoothly from/to idle animation
- Gesture is clear and directive

### Task 19.18: Animation -- Mystical Cast
**Status:** TODO
**Description:** Create a mystical cast animation (3 seconds, 72 frames, one-shot). This plays during narrative moments when the AI Sage demonstrates power or reveals information. Sequence: frames 1-18: sage raises both arms slowly outward (staff transfers to left hand or floats independently via crystal bone), palms face upward, head tilts back. Frames 19-36: hold raised pose while the crystal brightens dramatically (crystal bone scales 120%), wisdom particles should intensify (handled by game code triggering extra particle emission). Frames 37-54: arms slowly lower while "channeling" (hands make subtle finger movements). Frames 55-72: return to idle-adjacent pose, crystal returns to normal brightness. The cast should feel powerful but controlled -- this is wisdom, not combat magic. Robe cloth should billow gently during the raised-arms phase as if affected by energy.
**Acceptance Criteria:**
- Both arms raise in a ceremonial/channeling pose
- Crystal brightens dramatically during peak (scale animation)
- Hold phase for particle/VFX timing
- Arms lower during channeling phase with finger detail
- Return to idle-adjacent pose
- Robe billows during peak energy (cloth chains activated)
- Powerful but controlled aesthetic (wisdom, not combat)

### Task 19.19: Export and Godot Integration
**Status:** TODO
**Description:** Export the AI Sage as `ai_sage.glb` with all animations embedded: `idle`, `speaking`, `pointing`, `cast`. Verify NLA editor has all 4 actions properly named. Export with embedded textures (diffuse, normal, emission). Import into Godot and set up the NPC scene. Configure AnimationPlayer: `idle` loops, `speaking` loops (for dialogue), `pointing` one-shot with hold, `cast` one-shot. Set up the crystal point light as an OmniLight3D child node. Add the wisdom particle GPUParticles3D as a child node. Position the sage in the town scene at the appropriate NPC location. Verify the dialogue system triggers the `speaking` animation when the player initiates conversation. Verify `pointing` triggers for quest direction moments.
**Acceptance Criteria:**
- 4 animations exported and accessible in AnimationPlayer
- Crystal point light active in scene
- Wisdom particles orbiting correctly
- Sage positioned in town at correct NPC location
- Speaking animation triggers during dialogue
- Pointing animation triggers during quest direction
- All materials display correctly in town lighting

### Task 19.20: In-Game Polish and Character Test
**Status:** TODO
**Description:** Full in-game test of the AI Sage NPC. Verify: (1) idle animation plays when the player is not interacting (sage floats serenely, robe sways, crystal rotates), (2) approach the sage -- wisdom particles are visible, crystal glow illuminates surrounding area, (3) initiate dialogue -- speaking animation plays with gesture, head tilts toward player, (4) receive quest direction -- pointing animation triggers with clear directional indication, (5) narrative moment -- cast animation plays with appropriate drama, (6) walk away -- sage returns to idle seamlessly, (7) the sage is visually distinct from all other NPCs (unique silhouette, purple color, floating posture), (8) sage looks appropriate in the town setting (not out of place, but clearly special/important). Adjust particle counts, glow intensity, and animation blend speeds. Take before/after screenshots.
**Acceptance Criteria:**
- All 4 animation states trigger correctly in context
- Crystal glow illuminates surrounding area appropriately
- Wisdom particles visible and serene
- Sage is visually distinct from other NPCs
- Sage fits within town aesthetic while being clearly special
- Animation blends are smooth (no pops or jerks)
- Before/after screenshots captured

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings and naming conventions
- **Epic 2** (Visual Style Guide): Character proportions and color palette
- **Epic 3** (Texture Workflow): UV standards and texture resolution
- **Epic 4** (Animation Pipeline): Rig standards and bone naming
- **Epic 21** (NPC Expressions): Shape keys and expression system (can be added later)
- **Epic 22** (NPC Interaction Polish): Interaction animations may extend this set

## Notes

- The AI Sage is the NPC the player interacts with most -- visual quality here directly impacts narrative engagement
- The floating/gliding movement (no visible feet) reinforces the "digital being" concept
- The crystal glow point light is an important ambient lighting contribution to the town
- Cloth bone chains are a performance-friendly alternative to actual cloth simulation
- The same rig approach (cloth chains) can be reused for any robed/clothed NPC
- Consider adding a subtle halo/aura effect (very faint circular glow behind the head) for additional mystical presence
