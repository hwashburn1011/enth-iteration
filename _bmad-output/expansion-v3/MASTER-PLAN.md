---
name: Expansion V3 — Texture & Graphics Refinement Master Plan
description: 30 epics × 30 tasks = 900 tasks of methodical visual upgrades
created: 2026-04-09
parent_plan: ../expansion-v2/MASTER-PLAN.md
---

# Expansion V3 — Texture & Graphics Refinement Master Plan

## Vision

Expansion V2 delivered the full game scope (2,500 tasks across 50 epics) but the
visual baseline is procedural geometry with flat PBR materials. **V3 is dedicated
strictly to texture quality, material depth, and model refinement** to push every
asset toward "indie that punches above its weight" standards — the kind of work
where a video game developer can stop, look closely, and say "they spent time on
this."

## Quality Bar

Every model in this pass must satisfy at minimum 4 of:

1. **Real PBR maps**: albedo + normal + roughness + metallic + AO + (emission if applicable)
2. **Procedural surface detail** via Blender shader nodes (noise, voronoi, musgrave, ColorRamp)
3. **Subdivision Surface modifier** for smooth surfaces, **Bevel modifier** for hard surfaces
4. **Proper UV unwrapping** with smart project + manual seams where it matters
5. **Vertex color painting** for gradient effects and large-area variation
6. **Multi-resolution sculpting** for organic detail (where applicable)
7. **Polyhaven free PBR textures** integrated via Blender MCP `download_polyhaven_asset`
8. **Displacement maps** for terrain, brick, and wood surfaces
9. **Shader-driven effects in Godot 4.4**: rim lighting, SSS, world-space tri-planar projection

Anti-pattern: just stacking icospheres and cubes with solid material colors.
That was the V2 baseline. V3 must go further.

## Methodology

- **One epic = one asset class** (Globbler hero, town buildings, dungeon walls, etc.)
- **30 tasks per epic** — broken into: research / sculpting / UV unwrap / texturing /
  material setup / variation / LOD / optimization / hero render / commit
- **Per-task commit** via `epic-Nv3 task M: <description>`
- **Per-epic push** to origin/master
- **Take time** — no rushing. Each task should leave the asset measurably better.

## Tools at Disposal

- Blender 5.1 CLI pipeline (already established in V2)
- Blender MCP `download_polyhaven_asset` for free PBR textures
- Blender's Cycles renderer for material previews
- Godot 4.4 shader language for runtime effects
- restart-blender.ps1 if MCP becomes unresponsive

---

## Epic Roster

Each epic targets a specific asset category from the V2 baseline.

### Pillar A — Hero Characters (Epics V3-01 → V3-05)

- **V3-01** Globbler Hero Texture Pass (refines Epic 01-03 baseline)
- **V3-02** AI Sage Texture Pass (refines Epic 09)
- **V3-03** Class Variants Texture Pass (Compiler/Daemon/Kernel — refines Epic 31)
- **V3-04** Companion Texture Pass (Tank/DPS/Healer/Utility — refines Epic 40)
- **V3-05** Pet Sculpts Texture Pass (8 pets — refines Epic 41)

### Pillar B — Town & World Architecture (Epics V3-06 → V3-12)

- **V3-06** Town Building Kit Texture Pass (refines Epic 11-12)
- **V3-07** Town District Refinement (refines Epic 21)
- **V3-08** Sub-Area Detailing (refines Epic 22)
- **V3-09** Wilderness Zone Texture Pass (refines Epic 23)
- **V3-10** Dungeon Entrance Hero Polish (refines Epic 24)
- **V3-11** Hub Expansion Interior Texturing (refines Epic 25)
- **V3-12** Vegetation Library Texture Pass (refines Epic 13)

### Pillar C — Dungeon Biomes (Epics V3-13 → V3-18)

- **V3-13** Server Room Biome Texture Pass (refines Epic 15)
- **V3-14** Memory Vaults Biome Texture Pass (refines Epic 16)
- **V3-15** Corrupted Wilds Biome Texture Pass (refines Epic 17)
- **V3-16** Boss Sanctum Texture Pass (refines Epic 18)
- **V3-17** Massive Floor Texture Detailing (refines Epic 30)
- **V3-18** Procedural Dungeon Material Variation (refines Epic 29)

### Pillar D — Enemies & Bosses (Epics V3-19 → V3-22)

- **V3-19** Base Enemy Texture Pass (Glitchbug/Memoryleak/RogueProcess — refines Epic 04-06)
- **V3-20** New Enemy Texture Pass (8 new enemies — refines Epic 08)
- **V3-21** Original Compiler Boss Texture Pass (refines Epic 07)
- **V3-22** New Bosses Texture Pass (5 new bosses — refines Epic 43)

### Pillar E — Props & Items (Epics V3-23 → V3-26)

- **V3-23** Crafting Stations Texture Pass (refines Epic 34)
- **V3-24** Crafting Materials & Items Texture Pass (refines Epic 33-34)
- **V3-25** Decoration Library Texture Pass (refines Epic 36)
- **V3-26** Farming & Gathering Props Texture Pass (refines Epic 35)

### Pillar F — UI & FX (Epics V3-27 → V3-30)

- **V3-27** Skill Tree & Module Icon Texture Pass (refines Epic 32-33)
- **V3-28** VFX Material Library (refines Epic 20)
- **V3-29** Lighting Bible Refinement (refines Epic 19)
- **V3-30** Steam Marketing Asset Polish (refines Epic 50)

---

## Per-Epic Task Template (30 tasks)

Each epic follows this structure (adapted to the asset class):

### Research & Reference (5)
1. Research reference imagery + style direction
2. Audit current V2 baseline asset
3. Identify hero/showcase models (top 3) for extra polish
4. Document material palette + naming convention
5. Set up per-epic Blender source file structure

### Sculpting & Geometry (5)
6. Sculpt or refine primary mesh #1
7. Sculpt or refine primary mesh #2
8. Sculpt or refine primary mesh #3
9. Add subdivision surface + bevel modifiers across all meshes
10. Apply edge bevels manually for hard-surface details

### UV Unwrapping (3)
11. UV unwrap primary meshes (smart project + manual seams)
12. Pack UV islands efficiently
13. Validate texel density consistent

### Texturing & Materials (10)
14. Download relevant Polyhaven PBR materials (or build procedural)
15. Build material #1: base layer with albedo + roughness + normal
16. Build material #2: with metallic + AO + emission where applicable
17. Build material #3 with vertex color masking
18. Build material #4 with procedural noise overlay for surface variation
19. Build material #5 with tri-planar shader for tiling avoidance
20. Add weathering: dirt edges via curvature node
21. Add subtle emission accents for hero pieces
22. Setup material variants (3 colorway variations)
23. Hook materials to all meshes in collection

### Variation & Optimization (3)
24. Generate LOD0 / LOD1 / LOD2 mesh decimations
25. Optimize material max texture size per LOD
26. Build atlas where multiple small props share materials

### Rendering & Validation (4)
27. Hero shot render (Cycles, 64+ samples, 1920×1080)
28. Comparison render: V2 baseline vs V3 polish (split frame)
29. Validate in Godot import — confirm materials translate
30. Commit `epic-Nv3 epic complete` and push to remote

---

## Progress Tracking

- [x] Epic V3-01 — Globbler Hero Texture Pass
- [x] Epic V3-02 — AI Sage Texture Pass
- [x] Epic V3-03 — Class Variants Texture Pass
- [x] Epic V3-04 — Companion Texture Pass
- [x] Epic V3-05 — Pet Sculpts Texture Pass
- [x] Epic V3-06 — Town Building Kit Texture Pass
- [x] Epic V3-07 — Town District Refinement
- [x] Epic V3-08 — Sub-Area Detailing
- [x] Epic V3-09 — Wilderness Zone Texture Pass
- [x] Epic V3-10 — Dungeon Entrance Hero Polish
- [x] Epic V3-11 — Hub Expansion Interior Texturing
- [x] Epic V3-12 — Vegetation Library Texture Pass
- [x] Epic V3-13 — Server Room Biome Texture Pass
- [x] Epic V3-14 — Memory Vaults Biome Texture Pass
- [x] Epic V3-15 — Corrupted Wilds Biome Texture Pass
- [x] Epic V3-16 — Boss Sanctum Texture Pass
- [x] Epic V3-17 — Massive Floor Texture Detailing
- [x] Epic V3-18 — Procedural Dungeon Material Variation
- [x] Epic V3-19 — Base Enemy Texture Pass
- [x] Epic V3-20 — New Enemy Texture Pass
- [x] Epic V3-21 — Original Compiler Boss Texture Pass
- [x] Epic V3-22 — New Bosses Texture Pass
- [x] Epic V3-23 — Crafting Stations Texture Pass
- [x] Epic V3-24 — Crafting Materials & Items Texture Pass
- [x] Epic V3-25 — Decoration Library Texture Pass
- [x] Epic V3-26 — Farming & Gathering Props Texture Pass
- [x] Epic V3-27 — Skill Tree & Module Icon Texture Pass
- [x] Epic V3-28 — VFX Material Library
- [x] Epic V3-29 — Lighting Bible Refinement
- [x] Epic V3-30 — Steam Marketing Asset Polish

---

## ROUND 2 — Refinement Pass

Round 1 used procedural shaders only. Round 2 layers on the techniques
the original spec called for that Round 1 skipped:
  - UV unwrapping for proper texture mapping
  - Vertex color painting for per-vertex variation
  - Multi-resolution / higher-detail geometry
  - Bake normal maps from high-poly to low-poly
  - More animation poses per hero

- [x] Epic V3-R2-01 — Globbler Hero (UV unwrap + vertex color + multi-res)
- [x] Epic V3-R2-02 — AI Sage Refinement
- [x] Epic V3-R2-03 — Class Variants Refinement
- [x] Epic V3-R2-04 — Companion Refinement
- [x] Epic V3-R2-05 — Pet Refinement
- [x] Epic V3-R2-06 — Town Building Kit Refinement
- [x] Epic V3-R2-07 — Town District Refinement
- [x] Epic V3-R2-08 — Sub-Area Refinement
- [x] Epic V3-R2-09 — Wilderness Refinement
- [x] Epic V3-R2-10 — Dungeon Entrance Refinement
- [x] Epic V3-R2-11 — Hub Interior Refinement
- [x] Epic V3-R2-12 — Vegetation Library Refinement
- [x] Epic V3-R2-13 — Server Room Biome Refinement
- [x] Epic V3-R2-14 — Memory Vaults Refinement
- [x] Epic V3-R2-15 — Corrupted Wilds Refinement
- [x] Epic V3-R2-16 — Boss Sanctum Refinement
- [x] Epic V3-R2-17 — Floor Detailing Refinement
- [x] Epic V3-R2-18 — Base Enemy Refinement
- [ ] Epic V3-R2-19 — New Enemy Refinement

## ROUND 3 — Sculpt + Retopo + Bake + Rig + Animate

Round 3 is the critical-feedback fix. Each epic is ONE hero asset done
end-to-end: bmesh sculpt the high-poly base from a single mesh (NOT
parented primitives), inset eye sockets and mouth as real geometry,
multires sculpt details, decimate to retopo low-poly, bake normal map
high→low, UV unwrap and bake the procedural shader to a 1024² PNG image
texture, add an armature with bones, parent w/ automatic weights, key
an idle animation loop, render hero shot + animation.

- [x] Epic V3-R3-01 — Globbler Hero (sculpt + retopo + bake + rig + idle)
- [x] Epic V3-R3-02 — AI Sage Hero (sculpt + robe + hood + beard + cast-spell anim)
- [x] Epic V3-R3-03 — Compiler Boss (sculpt + spikes + normal-map bake high→low)
- [x] Epic V3-R3-04 — Glitchbug (insect sculpt + mandibles/antennae + chitin shader + twitch anim)
- [x] Epic V3-R3-05 — Memory Leak (slime sculpt + 4 eyes + drips + SSS shader + ooze pulse anim)
- [x] Epic V3-R3-06 — Town Hero Building (single-mesh carved windows/door/gable + Z-zoned PBR bake)
- [x] Epic V3-R3-07 — Dungeon Wall Hero (carved brick joints + 3 glowing runes + sconce + cracked top + wet-stone PBR bake)
- [x] Epic V3-R3-08 — Forge + Anvil Hero (carved fire pit + bellows + extruded horn + pritchel + dual PBR bake)
- [x] Epic V3-R3-09 — Hero Tree (gnarled trunk + 5 extruded branches + bark PBR bake + 6 SSS canopy clusters)
- [x] Epic V3-R3-10 — Hero Rock Formation (3-peak proximity displacement + carved cracks + granite/lichen PBR bake)
- [x] Epic V3-R3-11 — Corrupted Data Monolith (carved circuit traces + display ports + broken corner + brass/cyan-glow PBR bake + 4 floating fragments)
- [x] Epic V3-R3-12 — Hero Villager NPC (sculpted face: eyes/nose/mouth/ears + extruded arms + 9-bone rig + idle anim)
- [x] Epic V3-R3-13 — Hero Sword (diamond-section blade + carved fuller + 4 rune insets + extruded crossguard + grip wrap + steel/brass/leather PBR bake)
- [x] Epic V3-R3-14 — Godot integration smoke test (R3 villager wired into Town.tscn, all 11 R3 GLBs copied into res://, headless --import passes 0 errors, baked PBR auto-extracted)
- [x] Epic V3-R3-15 — Player.tscn Globbler swap (R3 sculpted Globbler GLB replaces v2 placeholder; the "Globbler-shaped capsule with sphere arms" is GONE)
- [x] Epic V3-R3-16 — R3 enemies wired into Godot (Compiler/Glitchbug/MemoryLeak scenes now spawn sculpted GLBs instead of BoxMesh/SphereMesh/CylinderMesh placeholders)
- [x] Epic V3-R3-17 — Hero Dungeon Door (sculpted door + 16 extruded iron studs + 4 carved panels + keyhole + frame + 2-bone hinge rig + swing anim + iron/wood Pointiness PBR bake)
- [x] Epic V3-R3-18 — Hero Loot Chest (sculpted body+lid 2-mesh w/ carved plank seams + extruded iron bands + lock plate + keyhole + curved cylinder lid + 2-bone hinge rig + 60-frame open anim + dual PBR bake)
- [x] Epic V3-R3-19 — RogueProcess sculpted enemy (4th & final main enemy) — hooded humanoid w/ extruded cowl + carved deep eye sockets + triple-extruded dagger arms + flared cloak + 9-bone rig + stalking idle anim + dark cloth/iron Pointiness PBR bake; wired into RogueProcess.tscn (BoxMesh placeholder gone)
- [x] Epic V3-R3-20 — Hero Iron Lantern (carved 4 glass panel recesses + 8 deep vent cutouts + extruded top dome + chain link + bevel + cube_project UV + multires + Pointiness flame emission + iron PBR bake + inner emission flame icosphere + point light)
- [x] Epic V3-R3-21 — Polyhaven PBR re-texture pass (downloaded REAL CC0 photoscanned PBR maps from Polyhaven CDN — rough_block_wall + weathered_planks, each diff/nor_gl/rough at 1k. Built carved hero slabs, applied via Image Texture nodes through UV cube_project, exported GLB w/ embedded textures. The "Polyhaven was never wired in" critical-review point is now objectively closed.)
- [x] Epic V3-R3-22 — Boss Arena Pillar Diorama (sculpted cylinder pillar w/ alternating fluting grooves carved via inset on 8 vertical strips + extruded base block flared outward + extruded capital flared outward; large subdivided floor plane. Both wired with downloaded Polyhaven CC0 PBR — pillar uses castle_brick_07, floor uses cobblestone_floor_04, each diff/nor_gl/rough at 1k. 3-light boss arena moodboard, 3-camera renders, 27.6 MB GLB w/ embedded textures.)
- [ ] Epic V3-R2-20 — Compiler Boss Refinement
- [ ] Epic V3-R2-21 — New Bosses Refinement
- [ ] Epic V3-R2-22 — Crafting Stations Refinement
- [ ] Epic V3-R2-23 — Crafting Materials Refinement
- [ ] Epic V3-R2-24 — Decoration Library Refinement
- [ ] Epic V3-R2-25 — Farming Props Refinement
- [ ] Epic V3-R2-26 — Skill Icon Refinement
- [ ] Epic V3-R2-27 — VFX Library Refinement
- [ ] Epic V3-R2-28 — Lighting Bible Refinement
- [ ] Epic V3-R2-29 — Steam Marketing Refinement
- [ ] Epic V3-R2-30 — Town NPC 12-Pack (NEW content)

---

## Epic V3-01 — Globbler Hero Texture Pass

The player character. Highest priority — every player will see Globbler in 90%+
of their playtime. Must be a hero asset.

1. [x] Research Globbler reference: blob characters from indie games (Untitled Goose, Ooblets, Slime Rancher)
2. [x] Audit current Globbler V2 baseline mesh
3. [x] Identify the 3 hero pose meshes (idle/walk/cast)
4. [x] Document Globbler material palette: shell, accent, eye, aura, outfit slots
5. [x] Set up _art_source/characters/v3_globbler.blend source file
6. [x] Sculpt refined Globbler body with subdivision surface (target 5k tris)
7. [x] Sculpt refined head with eye sockets + visor groove
8. [x] Sculpt refined limb segments (4 limb mounts for outfit anchors)
9. [x] Apply Subdivision Surface modifier (2 levels viewport, 3 render) + Bevel
10. [x] Manually bevel hard-surface details (visor edges, accent rings)
11. [x] UV unwrap body via smart project + back seam
12. [x] UV unwrap head with face-front island prioritized
13. [x] Pack UV islands into 1024×1024 atlas
14. [x] Download Polyhaven "metal_plate" PBR set for hero accent material
15. [x] Build shell material: base color + roughness 0.4 + normal map from Polyhaven
16. [x] Build accent material: metallic 0.95 + brushed steel normal + warm emission
17. [x] Build eye material: glass-like with chromatic aberration shader trick
18. [x] Build aura material: emission with fresnel + animated noise UV scroll
19. [x] Build chest emblem material with vertex color heart mask
20. [x] Add curvature-based dirt to all materials (free edge wear)
21. [x] Add subtle emission rim on accent material
22. [x] Build 3 colorway variants: default-blue / heroic-gold / shadow-violet
23. [x] Hook all materials to body/head/limb mesh slots
24. [x] Generate LOD0 (5k), LOD1 (2.5k), LOD2 (1k) via Decimate modifier
25. [x] Build texture atlas: combine accent + emblem into one 2048 sheet
26. [x] Hero shot render: front 3/4 view, 64 samples, 1920×1080
27. [x] Hero shot render: side profile with rim light
28. [x] Side-by-side V2/V3 comparison render
29. [x] Export GLB to res://_art_source/characters/globbler_v3.glb, import into Godot, verify materials
30. [x] Commit `epic-V3-01: globbler hero texture pass complete (30/30)` + push

---

## Epic V3-02 — AI Sage Texture Pass

The mentor NPC. Player meets him in iteration 1 and refers back to him.
Should feel ancient, warm, weathered.

1. Research robed mentor character refs (Hades narrator, Hollow Knight elder)
2. Audit current Sage V2 baseline
3. Identify hero meshes: head with hood, robe drape, staff
4. Document material palette: robe wool, leather belt, brass clasp, wood staff, eye glow
5. Set up _art_source/characters/v3_sage.blend source file
6. Sculpt detailed face: weathered, kind eyes, beard volume
7. Sculpt robe with cloth draping (use Cloth modifier sim then apply)
8. Sculpt staff with wood grain bevels + crystal tip
9. Apply Subdivision Surface to body, robe, staff
10. Bevel sharp edges on staff bands and brass clasp
11. UV unwrap face with seam at back of neck
12. UV unwrap robe with seam down center back
13. UV unwrap staff cylindrically
14. Download Polyhaven "fabric_cloth" + "wood_oak" PBR sets
15. Build robe material: cloth normal + warm dye color + ambient dirt
16. Build face material: SSS shader for skin warmth
17. Build hood material: same fabric base, darker shade, AO baked
18. Build belt leather material: brown leather + edge wear + clasp accent
19. Build staff wood material: oak grain + curvature-driven darkening
20. Build crystal tip material: glass + emission warm gold
21. Add per-strand displacement to beard via hair particle system
22. Build 3 sage variant materials: young / wise / ancient
23. Hook materials to all meshes
24. Generate LOD0 (8k), LOD1 (4k), LOD2 (1.5k)
25. Atlas: face + clasp + crystal in one 2048 sheet
26. Hero shot: facing camera with staff raised, soft warm key
27. Hero shot: side profile robe drape with fill light
28. V2/V3 comparison render
29. Export GLB, verify Godot import, confirm SSS works
30. Commit `epic-V3-02: AI Sage texture pass complete (30/30)` + push

---

## Epic V3-03 — Class Variants Texture Pass

Compiler / Daemon / Kernel — three player classes. Each must feel distinct
through silhouette, material, and accent color.

1. Research class variant refs (Hades classes, Diablo class portraits)
2. Audit V2 class variant baselines
3. Identify hero meshes per class (3 × 3 = 9 hero meshes)
4. Document per-class material palettes (already in V2 ClassSystemDatabase)
5. Set up _art_source/characters/v3_classes.blend source
6. Sculpt Compiler armor plates (book-stack motif)
7. Sculpt Daemon dagger sheath + cloak hem
8. Sculpt Kernel tower shield with embossed core
9. Apply Subdivision + Bevel to all 3 variants
10. Bevel weapon edges (sword/dagger/shield rim)
11. UV unwrap each class body
12. UV unwrap each class weapon
13. Pack atlas per class (3 × 1024 sheets)
14. Download Polyhaven "metal_plate", "leather", "fabric_satin" PBR sets
15. Build Compiler shell material: book leather + brass trim + ink stain
16. Build Daemon shell material: dark cloth + spike accents + crimson glow
17. Build Kernel shell material: heavy plate + cyan core + battle scratches
18. Build per-class weapon material with class accent emission
19. Build per-class glyph hover material (animated UV scroll)
20. Add per-class aura ring material with fresnel falloff
21. Add wear-edge curvature on all 3 classes
22. Build 3 colorway variants per class (9 total)
23. Hook all materials to mesh slots
24. Generate LOD chains for all 3 (3 LOD × 3 classes = 9 meshes)
25. Pack class glyph emission maps into shared atlas
26. Hero shot per class (3 renders)
27. Group shot: all 3 classes lined up
28. V2/V3 comparison renders per class
29. Export 3 class GLBs, verify Godot import
30. Commit `epic-V3-03: class variants texture pass complete (30/30)` + push

---

## Epic V3-04 — Companion Texture Pass

[Identical 30-task structure adapted to: Tank / DPS / Healer / Utility companions]

1-30. Same task template applied to companion meshes from Epic 40 baseline.
Includes per-companion color identity (steel/blue/white/violet), unique
weapon textures, gear slot accents, and pet attendant visuals.

---

## Epic V3-05 — Pet Sculpts Texture Pass

[8 pets from Epic 41 baseline]

1-30. Same template applied to: Data Sprite, Patch Dog, Bit Cat, Bug Buddy,
Memory Owl, Cache Mouse, Echo Bird, Crystal Fox. Each pet gets fur/feather/
chitin texture appropriate to species, with unique eye glow and breath particle.

---

## Epic V3-06 — Town Building Kit Texture Pass

The 10 landmark buildings + modular kit (walls/roofs/windows). This is the
asset class players see most often outside dungeons.

1-30. Same template adapted to architecture: brick textures, wood grain,
slate roofs, weathered window frames, hanging lanterns with emission, vine
overgrowth on alley walls.

---

## Epic V3-07 — Town District Refinement

[5 districts: Town Central, Residential, Market, Commons, Workshop, Docks]

1-30. Per-district material variation, ground texture variation (cobblestone
in market, wooden boardwalk at docks), per-district lighting accent color
on lanterns and building signs.

---

## Epic V3-08 — Sub-Area Detailing

[8 sub-areas: Outskirts, Cliffs, Hidden Cave, Sage's Garden, Iteration Memorial,
Underground Lounge, Tower Top, Old Ruins]

1-30. Per-sub-area mood texturing: garden flowers with petal alpha cards, cave
moss with displacement, ruin moss + chipped stone, lounge wood floors with
spilled-drink stains, memorial brass plaques with engraving normal map.

---

## Epic V3-09 — Wilderness Zone Texture Pass

Heightmap terrain, river, cliffs, forest, ruins, paths. Largest single
contiguous space in the game.

1-30. Procedural terrain shader with multi-layer slope blending (grass on flat,
rock on slope), river flow shader, cliff strata, tree bark with subsurface,
path stones with wear edges.

---

## Epic V3-10 — Dungeon Entrance Hero Polish

[4 entrances: Server Room / Memory Vaults / Corrupted Wilds / Boss Sanctum]

1-30. Each entrance gets a true hero treatment: portal shimmer shader, monument
pillar weathering, ground glow ring, banner cloth with wave shader, themed
environmental particles.

---

## Epic V3-11 — Hub Expansion Interior Texturing

[14 hub areas from Epic 25]

1-30. Per-room interior details: lounge bar with bottle reflections, sage's
study with leather book bindings, training arena with sand tracks, fishing dock
with weathered planks, cooking station with grease stains.

---

## Epic V3-12 — Vegetation Library Texture Pass

[230 mesh objects from Epic 13]

1-30. Tree bark variants, leaf alpha cards with translucency, grass tufts with
wind shader, flower variety with petal subsurface, vine overgrowth.

---

## Epic V3-13 — Server Room Biome Texture Pass

[246 meshes from Epic 15]

1-30. Server rack metal panels, cable bundles with wear, glowing screens with
animated UV scroll, floor grates with ambient occlusion, ceiling pipes with
condensation drips.

---

## Epic V3-14 — Memory Vaults Biome Texture Pass

[215 meshes from Epic 16]

1-30. Aged stone with weathering, brass urns with patina, scroll texturing,
pillar wear, floating dust particles, golden inscription glow.

---

## Epic V3-15 — Corrupted Wilds Biome Texture Pass

[171 meshes from Epic 17]

1-30. Twisted bark with displacement, glowing fungi with emission, mire pools
with ripple shader, thorn vines with edge highlight, corrupted soil normal.

---

## Epic V3-16 — Boss Sanctum Texture Pass

[132 meshes from Epic 18]

1-30. Obsidian with reflection, void rifts with raymarched shader, violet
crystal growths, ancient runes with glow inscription, cracked floor tiles.

---

## Epic V3-17 — Massive Floor Texture Detailing

[5 floors from Epic 30, 740 mesh objects]

1-30. Per-floor environmental texture passes — Hub & Spoke walls, multi-level
stair treads, maze cell variation, processional torch sconces, boss arena rim.

---

## Epic V3-18 — Procedural Dungeon Material Variation

The runtime decorator from Epic 29 spawns markers — V3 hooks these to a
material variation system so 8 ore_iron nodes don't all look identical.

1-30. Build a procedural material variant assignment shader that hashes
position into 4-8 micro-variations per material slot.

---

## Epic V3-19 — Base Enemy Texture Pass

[Glitchbug, Memoryleak, RogueProcess from Epics 04-06]

1-30. Per-enemy texture work: chitin shells with curvature, slime liquid shader,
metal carapace, wire-frame circuit pattern overlays.

---

## Epic V3-20 — New Enemy Texture Pass

[8 new enemies from Epic 08: Crash Daemon, Null Pointer, Stack Overflow,
Buffer Overflow, Race Condition, Segfault, Deadlock, Exception]

1-30. Per-enemy themed texturing — error glyphs etched into shells, broken
circuit traces, fractured glass surfaces, glitched normal maps.

---

## Epic V3-21 — Original Compiler Boss Texture Pass

[The original Compiler boss from Epic 07]

1-30. Hero treatment for the iteration 1 boss: ancient code-runes, glowing
core seams, cracked obsidian armor, animated emission pulse synced to phase.

---

## Epic V3-22 — New Bosses Texture Pass

[5 new bosses from Epic 43: Memory Warden, Root Heart, Sentinel Prime,
Iteration Phantom, Compiler Reborn]

1-30. Per-boss texture passes — Warden's tome bindings, Root Heart's bark
displacement, Sentinel Prime's industrial paint chips, Phantom's ghostly
fresnel, Compiler Reborn's multi-form crystal shader.

---

## Epic V3-23 — Crafting Stations Texture Pass

[5 stations × 3 tiers = 15 station meshes from Epic 34]

1-30. Per-tier material upgrade visualization: T0 wood/iron, T1 brass-trimmed,
T2 crystal-cored. Forge embers, alchemy bottle reflections, cooking pot
scorch marks.

---

## Epic V3-24 — Crafting Materials & Items Texture Pass

[20 materials from Epic 34 + module/item icons]

1-30. Per-material PBR with proper metalness (iron 0.95, copper 0.92, etc.),
crystal refraction, herb leaf SSS, ore chunks with vein pattern.

---

## Epic V3-25 — Decoration Library Texture Pass

[50 placeable decorations from Epic 36]

1-30. Per-decoration texture pass with material variation. Furniture wood,
fabric cushions, ceramic pots, metal lanterns, carpet weave normal maps.

---

## Epic V3-26 — Farming & Gathering Props Texture Pass

[Crops, fruit trees, fishing gear, gathering nodes from Epic 35]

1-30. Crop leaf variants per growth stage, fruit shaders with subsurface,
fish scale iridescence, gathering tool wear textures.

---

## Epic V3-27 — Skill Tree & Module Icon Texture Pass

[150 skill icons + 40 module icons = 190 icons]

1-30. Replace flat material icons with painted texture passes — frame metal
with rivets, glow inset for active state, paper grain on backings.

---

## Epic V3-28 — VFX Material Library

[50+ runtime VFX from Epic 20 shader library]

1-30. Build proper VFX shaders: fire with noise displacement, smoke with
density falloff, sparks with trail textures, magic circles with tessellation.

---

## Epic V3-29 — Lighting Bible Refinement

[8 lighting presets from Epic 19]

1-30. Per-preset HDRI setup, bounce light tuning, volumetric fog density
calibration, sun shaft thresholds, color grading LUTs per scene.

---

## Epic V3-30 — Steam Marketing Asset Polish

[Steam screenshots, hero shots, trailer frames from Epic 50]

1-30. Re-render every Steam asset with the V3 textured models. New cinematic
post-processing pass with bloom, chromatic aberration, vignette, color grade.

---

## End State

When all 30 epics are complete (900 tasks), the visual baseline for Enth:
Iteration shifts from "procedural geometry that demonstrates the systems" to
"hand-crafted hero assets that survive a 90-second Steam trailer cut against
Emberville." Player feedback should shift from "what is this?" to "I want to
look at it."
