---
epic: 20
title: "Cache Sprite Full Rebuild"
phase: 4
status: TODO
priority: high
estimated_hours: 55
dependencies: [1, 2, 3, 4]
---

# Epic 20: Cache Sprite Full Rebuild

## Overview

Complete visual rebuild of the Cache Sprite -- a small energetic data fairy NPC that serves as the player's companion and inventory/shop assistant in Enth: Iteration. The Cache Sprite is a tiny, cute, hyperactive creature that hovers near the player, reacts to events, and provides moment-to-moment personality in the game world. This epic covers the full pipeline: sculpt of the compact fairy body, wing-like data fins, antenna, hand-painted teal iridescent textures, wing-flap rig, and a full animation set emphasizing personality and energy.

**Visual Identity:** A small (0.25m tall) compact humanoid body with oversized round eyes, tiny limbs, and two wing-like data fins that flutter rapidly (like a hummingbird). A single curling antenna on the head senses data streams. The body glows with teal iridescent patterns, and glowing data streams trail behind during movement. The Cache Sprite should evoke the same warm feelings as Navi (Zelda), Clank (Ratchet and Clank), or similar companion characters -- cute, helpful, and full of personality.

**Quality Target:** Emberville/Stardew Valley stylized 3D. Despite the small size, the Cache Sprite needs to be expressive and readable. Large eyes and exaggerated proportions (head is 40% of total height) ensure readability at camera distance.

## Success Criteria

- [ ] Cache Sprite model is a properly sculpted cute fairy (not stacked primitives)
- [ ] Hand-painted teal iridescent texture with glowing data stream patterns
- [ ] Wing-flap bone rig with rapid flutter animation
- [ ] Full animation set: hover idle, excited bounce, data burst, follow behavior
- [ ] Exported as .glb and integrated in Godot replacing placeholder
- [ ] Character reads as "cute energetic fairy" at camera distance
- [ ] Polycount under 1,500 tris; single 256x256 texture atlas
- [ ] Wing flutter and data trail particles enhance the character's presence

---

## Tasks

### Task 20.1: Reference Sheet and Cute Design Language
**Status:** TODO
**Description:** Create a concept reference sheet focused on maximizing cuteness and readability at small scale. Gather references from companion characters (Navi, Clank, Carbuncle from FF, fairy companions). Design the Cache Sprite proportions: total height 0.25m, head occupies 40% (0.1m diameter round head), body occupies 35% (0.09m compact torso), legs 25% (0.06m short stubby legs). Eyes are oversized (~40% of face area), simple oval shape with large reflective highlights. Wing-data-fins: two translucent fin shapes extending from the upper back (0.15m wingspan), shaped like elongated data packets with soft edges. Antenna: single curling tendril from the top of the head (0.08m, coiled at tip). Mark teal color palette: body teal (#22AAAA), iridescent highlight (#66FFEE), data glow (#00FFCC), eye white (#FFFFFF), pupil dark (#1A3A3A).
**Acceptance Criteria:**
- Proportions designed for maximum cuteness (40% head ratio)
- 4+ view reference sheet with measurements
- Wing-data-fin design documented
- Antenna curl design specified
- Color palette with hex values
- Size comparison with player character (Globbler) illustrated
- Design reads as "cute" not "creepy" at small scale

### Task 20.2: High-Poly Sculpt -- Head and Face
**Status:** TODO
**Description:** Sculpt the Cache Sprite's head in Blender. Start with a sphere and shape into a slightly elongated round head (wider than tall, front slightly flattened for face area). Sculpt the face: two large eye sockets (shallow concave areas that will hold the painted eyes -- not protruding eyeballs), a tiny button nose (barely a bump), and a small curved line for a mouth (smiling expression). The top of the head should have a smooth dome with a small raised bump where the antenna attaches. Back of the head: smooth round, with two subtle dimples where the wing-fins attach to the body. Cheeks: slightly puffy for extra cuteness. Use Smooth brush extensively -- the head should feel like a polished toy. Target 100K-200K polys for the whole sculpt.
**Acceptance Criteria:**
- Round head shape, wider than tall, front slightly flat
- Large eye socket areas (40% of face)
- Tiny button nose and smiling mouth line
- Antenna attachment bump on top
- Puffy cheeks for cuteness
- Smooth polished-toy surface quality
- Proportions match reference sheet

### Task 20.3: High-Poly Sculpt -- Body, Limbs, and Fins
**Status:** TODO
**Description:** Sculpt the body and appendages. Torso: compact teardrop shape, wider at the top (connecting to the large head) and tapering toward the waist. Add a subtle belly roundness (cute pot-belly). Arms: short stubby arms extending from the upper body sides, ending in simple mitten-like hands (no individual fingers -- just a round paddle shape). Pose arms slightly away from the body (A-pose) for rigging. Legs: short stubby legs (shorter than arms), ending in round feet (no toes -- simple rounded nubs). Wing-data-fins: sculpt two flat fin shapes extending from the upper back. Each fin is a tapered elongated oval, thin at the edges (0.005m thick) and slightly thicker at the body attachment. The fins should have subtle ribbed texture (3-4 gentle ridges running lengthwise) suggesting data channels. Antenna: a curling tendril starting thick at the head and tapering to a thin coil at the tip.
**Acceptance Criteria:**
- Compact teardrop body with subtle pot-belly
- Stubby arms in A-pose with mitten hands
- Short stubby legs with rounded feet
- Two wing-data-fins with ribbed data-channel texture
- Antenna with thick-to-thin curl taper
- All proportions match the 40/35/25 head/body/leg ratio
- Overall silhouette reads as "tiny fairy creature"

### Task 20.4: Retopology -- Small Character Optimization
**Status:** TODO
**Description:** Retopologize to an extremely low poly count: 1,000-1,500 triangles total. At 0.25m tall, this character does not need high poly density. Allocation: head 300-400 tris (must preserve round shape), body 200-300 tris, arms 60-80 tris each (120-160 total), legs 50-70 tris each (100-140 total), wing-fins 100-150 tris each (200-300 total), antenna 50-80 tris. The head needs the most density to maintain roundness at small scale (even a few facets are visible on a sphere this small under game lighting). Wing-fins need edge loops along their length for flap deformation (3-4 loops). Eyes are painted on (no separate geometry) so the face area is flat quad topology. Keep the mesh very clean -- at this scale, every wasted triangle is visible.
**Acceptance Criteria:**
- Total tris: 1,000-1,500
- Head preserves roundness (enough polys for smooth sphere at 0.1m)
- Wing-fins have 3-4 lengthwise loops for flap deformation
- Eyes are painted (flat face topology)
- No wasted geometry (every triangle contributes to silhouette)
- Clean topology for UV unwrap
- Mesh origin at body center of mass

### Task 20.5: UV Unwrap
**Status:** TODO
**Description:** UV unwrap onto a 256x256 atlas (smaller than other characters due to small screen size). UV allocation: head/face 40% (eyes need painting detail despite small size), body 20%, wing-fins 20% (both fins share same UV space by stacking), arms 8%, legs 7%, antenna 5%. Place seams on the back of the head (hidden from typical camera angle), under the body, and along the inner edge of each fin. The face should be unwrapped as a single continuous island with minimal distortion for clean eye painting. Fins unwrap flat (they are essentially flat surfaces). At 256x256, every texel matters -- minimize wasted space aggressively. Pack with 2px padding (smaller atlas, less padding needed).
**Acceptance Criteria:**
- 256x256 atlas (appropriately small for character size)
- Face area gets 40% of UV space
- Wing-fin UVs stacked (shared texture)
- Seams hidden from camera
- Face as continuous island for eye painting
- 2px padding, minimal wasted space
- No distortion on face or visible body areas

### Task 20.6: Bake Normal Map
**Status:** TODO
**Description:** Bake a 256x256 normal map. At this character's small size and resolution, the normal map captures: (1) The subtle puffy cheek roundness, (2) The wing-fin ribbed data-channel texture, (3) The antenna's cylindrical form, (4) Any surface detail on the body (minimal at this scale). The normal map is less critical for the Cache Sprite than for larger characters, but it still helps the head and fins read correctly under dynamic lighting. Set bake ray distance carefully -- the small scale means even tiny ray overshoot creates artifacts. Apply 2px bleed. Save as `cache_sprite_normal.png`. Test under the game's isometric lighting to verify the normal map adds visible quality improvement over flat shading.
**Acceptance Criteria:**
- 256x256 normal map with key detail captured
- Cheek roundness and fin ribbing visible
- No bake artifacts from small-scale geometry
- 2px bleed applied
- Normal map provides visible improvement under game lighting
- Saved as `cache_sprite_normal.png`

### Task 20.7: Hand-Paint Diffuse -- Teal Body and Face
**Status:** TODO
**Description:** Paint the Cache Sprite's diffuse texture. Start with the body: medium teal (#22AAAA) base fill. Paint lighter teal (#44CCCC) on the belly, chest, and inner arms (lighter areas typical of cute creature design). Darker teal (#117777) on the back and outer surfaces. For the face: paint the large eyes with white (#FFFFFF) fill, then dark teal irises (#1A4A4A) with a lighter teal highlight ring, large reflective highlight spots (2 per eye -- one large, one small for the classic cute-eye look), and a thin dark outline. Paint the mouth as a simple curved dark line. Nose: tiny lighter spot. Cheeks: faint pink-teal blush (#CC8888 at 10% blend). The face is the most important painting area -- it must read as adorable.
**Acceptance Criteria:**
- Teal body with lighter underbelly and darker back
- Large expressive eyes with classic cute-eye highlights
- Smiling mouth and tiny nose details
- Cheek blush for extra cuteness
- Eyes must read clearly at 0.25m character scale
- Face painting is the quality centerpiece

### Task 20.8: Hand-Paint Diffuse -- Iridescent Patterns and Data Streams
**Status:** TODO
**Description:** Layer the iridescent and data-themed detail over the base colors. Paint iridescent color shift: along the head dome and upper body, add a subtle gradient that shifts from teal to aqua (#66FFEE) to suggest light playing across a reflective surface (painted, not shader-driven). Paint data stream lines: thin flowing lines (#00FFCC, 1-2px wide) that trace paths across the body surface like circuit traces, but with organic curves (not straight lines). Lines originate from the chest center and flow outward toward the limbs and head. Paint 3-4 small data-glyph symbols along the stream paths (tiny hex fragments or geometric icons). Wing-fins: paint with a gradient from opaque teal at the body connection to semi-transparent teal at the edges (lighter/brighter at edges to suggest translucency). Save as `cache_sprite_diffuse.png`.
**Acceptance Criteria:**
- Iridescent color shift painted on dome and upper body
- Data stream lines flowing from chest outward
- Lines are organic curves (not rigid circuit traces)
- 3-4 data-glyph symbols along stream paths
- Wing-fins have body-to-edge translucency gradient
- Iridescent and data elements enhance digital-fairy theme
- Saved as `cache_sprite_diffuse.png` at 256x256

### Task 20.9: Emission Map and Glow Configuration
**Status:** TODO
**Description:** Create the 256x256 emission map. The Cache Sprite should be a glowing presence. Emission zones: (1) Eyes: full intensity white (#FFFFFF) -- eyes are the brightest feature. (2) Data stream lines: 80% intensity teal (#00FFCC). (3) Wing-fin edges: 60% intensity aqua (#66FFEE) along the outer edge. (4) Antenna tip: 70% intensity teal. (5) Data-glyph symbols: 50% intensity. (6) General body surface: very faint 3% emission (subtle overall glow suggesting internal energy). Save as `cache_sprite_emission.png`. Set up material: roughness 0.5 (smooth but not mirror), metallic 0.0, emission energy 2.0 (Cache Sprite should be a visible light source). Add a teal OmniLight3D (0.5m range, energy 0.3) attached to the character for ambient glow casting.
**Acceptance Criteria:**
- Eyes brightest emission, data lines secondary, fins tertiary
- Subtle overall body glow at 3%
- Emission energy 2.0 makes sprite a visible light source
- OmniLight3D for ambient glow on surroundings
- Material roughness 0.5, metallic 0.0
- Saved as `cache_sprite_emission.png` at 256x256

### Task 20.10: Skeletal Rig
**Status:** TODO
**Description:** Create a small but expressive armature. Bone hierarchy: `root` (at character center), `hover` (vertical bob), `body` (main body rotation/tilt), `head` (head tilt/turn -- important for expression), `arm_L/R` (simple single-bone arms), `leg_L/R` (simple single-bone legs), `wing_L/R_root` and `wing_L/R_tip` (2 bones per wing for flap + flex), `antenna_01`, `antenna_02`, `antenna_03` (3-bone chain for antenna curl/wave), `eye_L/R` (for pupil direction if using bone-driven eye movement). Total: ~18-20 bones. The wing bones are the most important for animation quality -- position them so that rotating the root bone creates a flap motion and rotating the tip bone creates a flex/curl during the flap. Set the neutral wing pose as slightly raised (mid-flap position) for clean flap cycles.
**Acceptance Criteria:**
- ~18-20 bones covering all animatable parts
- Wing bones positioned for clean flap rotation
- Antenna 3-bone chain for wave/curl
- Single-bone arms and legs (simple, appropriate for size)
- Head bone for tilt/turn expression
- Eye bones for optional pupil direction
- Neutral pose has wings slightly raised (mid-flap)

### Task 20.11: Weight Painting
**Status:** TODO
**Description:** Weight paint the mesh. Most joints are simple rigid binding due to the small scale: body mesh to body bone (100%), head to head (100% with soft neck falloff), each arm to its bone (100%), each leg to its bone (100%). Wing-fins need careful painting: root 50% of fin near body, tip 50% at outer edge, with smooth gradient between (the wing needs to flex during flap, not just rotate rigidly). Antenna: gradient weights along the 3-bone chain (base at 100% antenna_01, middle blending, tip at 100% antenna_03). Eye areas: if using eye bones, paint very localized weights on just the eye surface vertices. Test wing flap by rotating root bone 30 degrees up/down -- the fin should flex naturally. Test antenna by rotating each bone -- should create a natural wave/curl.
**Acceptance Criteria:**
- Body, head, limbs: rigid binding (simple joints)
- Wing-fins: gradient weights for flap-flex deformation
- Antenna: smooth gradient along 3-bone chain
- Wing flap test shows natural flex (not rigid rotation)
- Antenna wave test shows smooth curve
- No unweighted vertices
- Deformation clean at expected animation ranges

### Task 20.12: Animation -- Hover Idle
**Status:** TODO
**Description:** Create a 2-second looping hover idle (48 frames at 24fps). The Cache Sprite should feel energetic even when idle. Primary motion: rapid wing flutter (wing root bones oscillate +/- 25 degrees at 12Hz -- wings flap 24 times during the 2-second cycle, fast like a hummingbird). Wing flex: tip bones oscillate opposite to root (when root flaps up, tip curls down slightly) for natural aerodynamic flex. Body bob: very gentle vertical hover (0.01m amplitude, 2-second cycle). Body tilt: slight random-feeling micro-tilts (2-3 degrees, changing direction every 0.5-1s) suggesting restless energy. Head: occasional quick look-around (head turns 15 degrees left, pauses 0.3s, turns right, pauses, returns center -- one look cycle per 2s). Antenna: constant gentle wave (sinusoidal, 0.5-second period).
**Acceptance Criteria:**
- Rapid hummingbird-style wing flutter (12Hz)
- Wing flex on tips during flap
- Gentle vertical hover bob
- Restless body micro-tilts
- Head look-around cycle
- Antenna wave
- Overall reads as "energetic hovering fairy"

### Task 20.13: Animation -- Excited Bounce
**Status:** TODO
**Description:** Create an excited bounce animation (1.5 seconds, 36 frames, one-shot or short loop). This plays when something good happens (player picks up loot, completes quest, finds secret). The Cache Sprite bounces vertically with increasing enthusiasm: bounce 1 (frames 1-12) -- hover bone rises 0.05m then drops back, wings flap extra hard (40-degree amplitude). Bounce 2 (frames 13-24) -- rises 0.08m, body tilts with excitement, arms wave outward. Bounce 3 (frames 25-36) -- rises 0.1m (highest), full body spin (360 degrees on body bone), arms spread wide, antenna coils tight with energy. Each bounce should feel springier than the last. Wing flutter speed increases with each bounce (12Hz, 14Hz, 16Hz). Return to idle hover at end.
**Acceptance Criteria:**
- 3 escalating bounces with increasing height and energy
- Body spin on the biggest bounce
- Arms wave and spread expressively
- Wing flutter speed increases per bounce
- Antenna coils with energy
- Transitions cleanly back to idle
- Communicates joy and excitement unambiguously

### Task 20.14: Animation -- Data Burst
**Status:** TODO
**Description:** Create a data burst animation (1 second, 24 frames, one-shot). This plays when the Cache Sprite performs its companion function (opening cache, sorting inventory, processing data). Sequence: frames 1-8: Cache Sprite pulls inward (body compresses 10%, arms draw to chest, wings tuck to 50% amplitude flutter, antenna straightens forward -- a "gathering energy" pose). Frames 9-12: burst -- body snaps to 115% scale, arms thrust outward, wings fully extend to maximum span, antenna snaps outward in a spiral. This is the frame where the game spawns data particle effects. Frames 13-24: slow return to normal (115% -> 100% scale with overshoot to 97% -> 100%, arms float back to sides, wings resume normal flutter, antenna relaxes to curl). The burst should feel impactful despite the small character size.
**Acceptance Criteria:**
- Gather phase compresses and focuses energy
- Burst frame is sharp and impactful (frame 9)
- Scale snap from compressed to expanded is fast (1-2 frames)
- Particle spawn frame clearly defined (frame 9)
- Recovery has overshoot for springy feel
- Wings and antenna participate in the burst
- Small character still feels impactful during burst

### Task 20.15: Animation -- Follow Behavior (Movement)
**Status:** TODO
**Description:** Create a movement/follow animation (1 second, 24 frames, looping). This plays when the Cache Sprite follows the player through the world. The sprite tilts forward 15-20 degrees in the movement direction (leaning into flight). Wings increase flutter to 16Hz (faster than idle) with increased amplitude (30 degrees). The body bobs more actively during flight (0.02m amplitude vs 0.01m idle). Arms stream backward slightly (wind resistance). Antenna trails behind, extended rearward. Root motion is not needed (the follow behavior is handled by game code) -- this animation just provides the visual of "flying somewhere with purpose." Add a slight lateral wobble (2-3 degrees yaw oscillation) to prevent perfectly straight flight. The overall impression should be a tiny creature zooming after the player.
**Acceptance Criteria:**
- 15-20 degree forward lean in flight direction
- Increased wing flutter speed and amplitude
- More active body bob during movement
- Arms and antenna trail backward from air resistance
- Lateral wobble prevents robotic straight-line flight
- No root motion (position handled by game code)
- Reads as "zooming fairy in pursuit"

### Task 20.16: Animation -- Idle Personality Variants
**Status:** TODO
**Description:** Create 3 short personality animations that occasionally interrupt the standard idle (triggered randomly by game code every 10-20 seconds). (1) **Yawn/Stretch** (1s, 24f): arms stretch overhead, mouth opens wide (if visible at this scale -- or just head tilts back), wings slow to half flutter speed, then snap back to alert. (2) **Curious Look** (1.5s, 36f): antenna perks up rigidly, head snaps to one direction, body follows with a slow turn, holds the "what was that?" pose for 0.5s, then dismisses (head shake) and returns to idle. (3) **Data Hiccup** (0.5s, 12f): a tiny glitch -- the whole body jitters rapidly for 6 frames (rapid random position offset), then freezes for 3 frames, then resumes normal idle with a small shake-off. These add personality and prevent idle from feeling static.
**Acceptance Criteria:**
- 3 personality variants: yawn, curious, hiccup
- Each is distinct and communicates a clear emotion/action
- Triggered randomly during idle (game code integration point)
- All blend cleanly from/to standard idle
- Data hiccup reinforces the "digital being" theme
- Animations add life and personality to companion presence

### Task 20.17: Data Trail Particle System
**Status:** TODO
**Description:** Create the data trail particle system that follows the Cache Sprite during movement. When the sprite is moving (follow behavior animation playing), emit a trail of small glowing data particles from behind the wing tips. Particle properties: tiny (0.01m), teal/aqua (#00FFCC with emission), lifetime 0.8 seconds, spawn at wing tip positions, initial velocity matches opposite of movement direction (trail behind), slight random spread (0.02m), fade from full brightness to transparent over lifetime. Emit 10-15 particles per second per wing (20-30 total). When the sprite stops moving, trail emission stops but existing particles complete their lifecycle (trail fades over 0.8s). Additionally, create a "data burst" particle effect for the data burst animation: 30 particles spawning at frame 9 in a spherical burst pattern.
**Acceptance Criteria:**
- Trail particles emit from wing tips during movement
- Teal/aqua color with emission (self-lit)
- Trail fades over 0.8 seconds after stopping
- 20-30 particles per second during movement
- Data burst spawns 30 particles in spherical pattern
- Particles are visible at camera distance despite small size
- Performance acceptable (total particle count stays manageable)

### Task 20.18: Export and Animation Verification
**Status:** TODO
**Description:** Export the Cache Sprite as `cache_sprite.glb` with all animations: `idle`, `excited_bounce`, `data_burst`, `follow`, `yawn`, `curious_look`, `data_hiccup` (7 total). Verify NLA editor names. Export with embedded textures at 256x256 (diffuse, normal, emission). Verify file size is very small (under 500KB -- this is a tiny character). Import into Godot and verify: all 7 animations in AnimationPlayer, mesh displays correctly at 0.25m scale, all 3 textures present, emission glow visible, material properties correct. Set `idle` and `follow` to loop. Set personality variants and data_burst to one-shot. Test wing flutter framerate -- at 12Hz the animation must be smooth at game framerate.
**Acceptance Criteria:**
- 7 animations exported and named correctly
- File size under 500KB
- All textures present at 256x256 in Godot
- Emission glow visible at small scale
- Wing flutter smooth at game framerate (no aliasing at 12Hz)
- Loop/one-shot modes correctly set
- No bone/track mismatches

### Task 20.19: Godot Scene Setup and Follow Behavior
**Status:** TODO
**Description:** Set up the Cache Sprite companion scene in Godot. Create the scene with: model mesh, AnimationPlayer (with AnimationTree for blending), OmniLight3D (teal, 0.5m range), GPUParticles3D (data trail -- initially disabled), GPUParticles3D (data burst -- one-shot). Implement the companion follow script: the sprite follows the player with a 1m offset (slightly above and behind), using smooth interpolation (lerp at 0.1 weight) for floaty follow behavior. When the player stops, the sprite circles lazily to a rest position. When the player runs, the sprite's follow speed increases and the follow animation plays. Integrate AnimationTree states: idle (default), follow (when player moves), excited_bounce (triggered by EventBus loot/quest signals), data_burst (triggered by inventory open), personality variants (random timer in idle state).
**Acceptance Criteria:**
- Companion scene with all visual components
- Smooth follow behavior with 1m offset
- Lazy circle to rest when player stops
- Follow speed scales with player movement speed
- AnimationTree states respond to gameplay events
- Data trail particles activate during follow
- OmniLight3D casts teal glow on environment

### Task 20.20: In-Game Companion Testing
**Status:** TODO
**Description:** Full in-game test of the Cache Sprite companion. Walk through the complete companion experience: (1) Enter town -- Cache Sprite hovers near player in idle, wisdom particles and glow visible. (2) Walk around -- sprite follows with smooth trailing behavior, data trail particles active. (3) Stop -- sprite circles to rest position, idle animation with personality variants triggering. (4) Pick up an item -- excited bounce triggers. (5) Open inventory -- data burst animation and particle effect. (6) Enter dungeon -- sprite follows through rooms, glow provides ambient teal light. (7) Combat -- sprite retreats slightly (offset increases) and plays a worried idle variant. (8) Return to town -- sprite resumes close follow. Verify the sprite never clips into geometry, the follow behavior handles doorways and tight spaces, and the glow is visible in both bright (town) and dark (dungeon) environments. Before/after screenshots.
**Acceptance Criteria:**
- Companion follows player smoothly across all environments
- All animation states trigger correctly in gameplay context
- Data trail and burst particles function
- Glow visible in both bright and dark environments
- No clipping with environment geometry
- Personality variants add life during idle periods
- Companion feels like a helpful, charming presence
- Before/after screenshots captured

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Export settings
- **Epic 2** (Visual Style Guide): Character proportions and color palette
- **Epic 3** (Texture Workflow): UV and texture standards
- **Epic 4** (Animation Pipeline): Rig and bone naming
- **Epic 21** (NPC Expressions): Expression system can extend the sprite's face
- **Epic 22** (NPC Interaction Polish): Additional interaction animations

## Notes

- The Cache Sprite is the player's constant companion -- its quality directly impacts the entire game experience
- At 0.25m, readability requires exaggerated proportions and bright emission
- The hummingbird wing flutter (12Hz) must not alias or strobe at 60fps -- test carefully
- Data trail particles are the sprite's most visible dynamic element during gameplay
- Consider adding a "sleep" idle for when the player is AFK for 30+ seconds
- The companion follow behavior should use a spring/damper system for natural-feeling lag
- 256x256 textures are appropriate -- this character is never seen close-up
