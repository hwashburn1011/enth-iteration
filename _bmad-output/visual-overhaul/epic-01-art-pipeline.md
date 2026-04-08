---
epic_id: 01
title: "Epic 01: Art Pipeline Setup"
phase: 1
status: TODO
priority: high
estimated_tasks: 20
---

# Epic 01: Art Pipeline Setup

## Overview
Establish the complete art production pipeline from Blender to Godot 4.4, including project file templates, naming conventions, export presets, and folder organization. This foundational epic ensures every subsequent art asset flows through a consistent, repeatable process that minimizes import errors and maintains visual coherence across the entire game.

## Success Criteria
- A Blender template .blend file exists with correct scale, units, and collection hierarchy ready for immediate use
- All asset types (props, characters, buildings, VFX meshes) export cleanly to Godot with correct orientation, scale, and materials
- Folder structure is documented and populated with placeholder directories so artists never have to guess where files go
- Texture resolution standards are enforced via naming convention and documented reference

## Tasks

### Task 01.01: Configure Blender Project Template File
**Status:** DONE
**Description:** Create a master Blender 4.x template file (`_art_source/template_enth.blend`) with scene units set to Metric at 1.0 scale factor, grid floor visible at 1m intervals, and the 3D cursor at world origin. Add a reference cube scaled to 1m x 1m x 1m (Godot unit reference) and a character-height guide cylinder at 1.5m tall. Set the viewport shading to Material Preview with the studio HDRI for consistent lighting during modeling.
**Acceptance Criteria:**
- Opening the template shows a 1m reference cube and 1.5m character guide at origin
- Scene units are Metric with scale factor 1.0
- File saves to `_art_source/template_enth.blend` in the project repository

### Task 01.02: Define Collection Hierarchy in Template
**Status:** DONE
**Description:** Inside the Blender template, create a standard collection hierarchy: `Export` (meshes that will be exported), `Reference` (guide objects, greybox shapes, not exported), `Armature` (skeleton/rig for characters), `Collision` (simplified collision meshes prefixed with `-col`), and `LOD` (level-of-detail meshes suffixed with `_lod1`, `_lod2`). Mark the `Reference` collection as non-exportable by disabling its render visibility.
**Acceptance Criteria:**
- Five named collections exist in the template with correct nesting
- Reference collection has render visibility disabled
- Collision meshes in the Collision collection use the `-col` suffix recognized by Godot's importer

### Task 01.03: Establish Asset Naming Convention Document
**Status:** DONE
**Description:** Write a naming convention reference in `_bmad-output/visual-overhaul/naming-conventions.md` covering all asset types. Meshes follow `category_name_variant` (e.g., `prop_barrel_rusty`, `char_globbler_body`, `bldg_house_stone_01`). Textures follow `assetname_maptype` (e.g., `globbler_albedo.png`, `globbler_normal.png`, `globbler_emission.png`). Animations follow `charname_actionname` (e.g., `globbler_idle`, `globbler_walk`). Materials in Godot use `mat_assetname` prefix.
**Acceptance Criteria:**
- Document covers mesh, texture, animation, and material naming with examples for each
- Naming rules are consistent with Godot's snake_case convention
- Document includes a table of map type suffixes: `_albedo`, `_normal`, `_roughness`, `_emission`, `_ao`

### Task 01.04: Create Godot Export Preset for Props
**Status:** DONE
**Description:** In Blender, configure and save a glTF 2.0 export preset named `EnthProp` that exports selected objects only, applies modifiers, uses +Y Up / +Z Forward (matching Godot's coordinate system), embeds textures as `.glb` binary, and sets animation export to off. Save this preset so it appears in the export dialog dropdown. Document the exact settings in the naming conventions file.
**Acceptance Criteria:**
- Export preset `EnthProp` is accessible from Blender's File > Export > glTF menu
- Exported .glb files import into Godot with correct orientation (no 90-degree rotation needed)
- Props exported with this preset have no animation data bloating the file

### Task 01.05: Create Godot Export Preset for Characters
**Status:** DONE
**Description:** Configure a second glTF 2.0 export preset named `EnthCharacter` that includes armature export, exports all actions as separate animations, applies modifiers, uses the same coordinate system as props, and embeds textures. Enable skinning/bone export and set the bone influence limit to 4 (Godot's default). Add shape key export if the character uses blend shapes for facial expressions.
**Acceptance Criteria:**
- Export preset `EnthCharacter` includes armature and animation data
- Bone influences are capped at 4 per vertex
- Exported .glb contains named animation clips accessible in Godot's AnimationPlayer

### Task 01.06: Create Godot Export Preset for Buildings
**Status:** DONE
**Description:** Configure a third glTF 2.0 export preset named `EnthBuilding` similar to props but with lightmap UV generation enabled (UV2). Buildings are larger assets that benefit from lightmap baking, so ensure the export includes a second UV channel. Set texture compression to lossy at quality 0.85 to reduce file size for the larger textures buildings use.
**Acceptance Criteria:**
- Export preset `EnthBuilding` generates UV2 for lightmapping
- Exported .glb files contain two UV channels visible in Godot's mesh inspector
- Texture quality setting balances file size and visual fidelity

### Task 01.07: Set Up Godot Import Folder Structure
**Status:** DONE
**Description:** Create the following directory tree under `res://` in the Godot project: `assets/models/characters/`, `assets/models/props/`, `assets/models/buildings/`, `assets/models/enemies/`, `assets/textures/characters/`, `assets/textures/props/`, `assets/textures/buildings/`, `assets/textures/enemies/`, `assets/textures/ui/`, `assets/textures/vfx/`, `assets/materials/`, `assets/shaders/`. Add a `.gdignore` file to any temp/working directories that should not be imported.
**Acceptance Criteria:**
- All listed directories exist in the Godot project filesystem
- Godot's FileSystem dock shows the complete hierarchy without errors
- No `.gdignore` files accidentally exclude production asset folders

### Task 01.08: Set Up Blender Source Folder Structure
**Status:** DONE
**Description:** Create `_art_source/` at the project root (outside `res://`) with subdirectories: `characters/`, `props/`, `buildings/`, `enemies/`, `vfx/`, `reference/`, `textures_source/`. This folder holds all .blend files and high-resolution texture source files (PSD/Krita). Add `_art_source/` to `.gitignore` if binary art files should not be versioned, or configure Git LFS tracking for `.blend`, `.psd`, `.kra`, and `.png` files over 1MB.
**Acceptance Criteria:**
- `_art_source/` directory tree exists with all subdirectories
- Git LFS or `.gitignore` is configured appropriately for large binary files
- A README inside `_art_source/` explains the folder purpose and points to the naming conventions doc

### Task 01.09: Define Texture Resolution Standards
**Status:** DONE
**Description:** Document and enforce texture resolution tiers: props use 512x512, characters use 1024x1024, buildings and large environment pieces use 2048x2048, VFX textures use 256x256 or 512x512, UI elements use power-of-two sizes appropriate to their screen coverage. All textures must be power-of-two dimensions for GPU compression compatibility. Add these rules to the naming conventions document with a quick-reference table.
**Acceptance Criteria:**
- Resolution table is documented with asset type, resolution, and format (PNG for source, Godot handles compression)
- At least one example texture at each resolution tier exists as a reference/placeholder
- Document explains why power-of-two matters (GPU mipmap generation, VRAM efficiency)

### Task 01.10: Create Color Palette Reference Sheet
**Status:** DONE
**Description:** Build a color palette reference image (`_art_source/reference/color_palette.png`) and a corresponding data file listing hex values. Include: grass green #6FAF6A, dirt brown #8A6A4A, stone grey #9A9A9A, wood brown #7A5A3A, water blue #4A8ABA, sky blue #87CEEB, accent neon cyan #00FFDD, accent neon magenta #FF00AA, accent neon yellow #FFE500, shadow purple #3A2A4A, highlight warm #FFF4E0, UI panel dark #1A1A2E, UI text light #E0E0E0. Create swatches in Blender's color palette system and save them in the template file.
**Acceptance Criteria:**
- Color palette image exists with labeled swatches and hex codes
- Blender template contains a vertex paint palette with all listed colors
- Colors are consistent with the warm-base, neon-accent art direction described in the style guide

### Task 01.11: Configure Godot Import Defaults for 3D Models
**Status:** TODO
**Description:** Create `.import` override files or configure Godot's Advanced Import Settings for the `assets/models/` directory tree. Set default mesh compression to on, generate tangents for normal mapping, enable mesh optimization, and set shadow mesh generation to on. For character models specifically, ensure skeleton import is enabled and animation loop detection is active. Document these settings so re-imports preserve them.
**Acceptance Criteria:**
- Importing a .glb into `assets/models/props/` automatically applies prop import defaults
- Character .glb imports include skeleton data and detect looping animations
- Settings survive re-import when the source .glb is updated

### Task 01.12: Configure Godot Import Defaults for Textures
**Status:** TODO
**Description:** Set up Godot import presets for textures: albedo/diffuse maps import as `VRAM Compressed` (S3TC/BPTC), normal maps import as `VRAM Compressed` with the "Normal Map" flag checked (ensures correct channel handling), emission maps import as `VRAM Compressed`, roughness maps import as `VRAM Compressed` in single-channel mode where possible. Disable "Filter" (use nearest-neighbor) only for pixel-art UI elements if any exist; all 3D textures should use linear filtering with mipmaps enabled.
**Acceptance Criteria:**
- Normal maps imported into Godot show the correct blue-purple tint in the inspector (not inverted)
- Mipmaps are generated for all 3D textures, preventing aliasing at distance
- Texture memory usage is reasonable (check with Godot's Debugger > Monitors > Video Memory)

### Task 01.13: Define LOD Strategy and Distance Thresholds
**Status:** TODO
**Description:** Document the LOD (Level of Detail) strategy for Enth: Iteration. LOD0 is the full-detail mesh used within 10m of the camera. LOD1 is 50% triangle count, used from 10-25m. LOD2 is 25% triangle count, used from 25-50m. Beyond 50m, objects use impostor billboards or are culled entirely. Define these thresholds in a reference document and create a test scene in Godot (`scenes/test/LODTest.tscn`) with a sample prop at all LOD levels to verify transitions are not visually jarring.
**Acceptance Criteria:**
- LOD distance thresholds are documented with triangle count targets per tier
- A test scene demonstrates smooth LOD transitions for at least one prop
- LOD meshes use Godot's built-in LOD system (GeometryInstance3D LOD properties) rather than custom scripts

### Task 01.14: Create Material Library Base Materials
**Status:** DONE
**Description:** Build a set of reusable base materials in Godot saved as `.tres` resources in `assets/materials/`: `mat_stylized_opaque.tres` (StandardMaterial3D with roughness 0.8, no metallic, vertex color enabled), `mat_stylized_emissive.tres` (same but with emission enabled and emission energy at 1.5), `mat_stylized_transparent.tres` (alpha scissor at 0.5 for foliage/VFX), `mat_stylized_water.tres` (transparency with blue tint, subtle refraction). Each material should have sensible defaults matching the chunky hand-painted art style.
**Acceptance Criteria:**
- Four base materials exist as .tres files in `assets/materials/`
- Materials can be duplicated and customized per-asset by overriding textures
- Default roughness values (0.7-0.9) match the style guide's matte, non-reflective look

### Task 01.15: Set Up Texture Atlas Strategy
**Status:** TODO
**Description:** Define which asset categories share texture atlases versus having individual textures. Small props (barrels, crates, pots, tools) should share a 2048x2048 atlas to reduce draw calls. Characters and bosses get individual texture sets. Buildings can share a 2048x2048 trim sheet for common architectural details (edges, panels, windows). Document the atlas layout strategy and create empty atlas templates in `_art_source/textures_source/` with grid guides at 512x512 cells.
**Acceptance Criteria:**
- Atlas strategy document exists explaining which assets share textures
- At least one empty atlas template PSD/Krita file exists with grid guides
- Strategy accounts for UV island packing within atlas cells

### Task 01.16: Create Blender-to-Godot Scale Verification Scene
**Status:** TODO
**Description:** Build a Godot test scene (`scenes/test/ScaleVerification.tscn`) containing a 1m reference cube, a 1.5m character-height cylinder, and a 3m doorway-height box. Export the same reference objects from the Blender template and import them into this scene to verify that 1 Blender unit = 1 Godot unit = 1 meter. If there is any scale discrepancy, adjust the Blender template or export preset until perfect 1:1 scale is achieved.
**Acceptance Criteria:**
- Blender-exported reference cube exactly overlaps Godot's built-in 1m cube
- Character height guide matches the expected 1.5m in Godot's grid
- No manual scale adjustment is needed after import

### Task 01.17: Document Shader Compatibility Requirements
**Status:** TODO
**Description:** Write a technical note in the visual overhaul folder documenting which Godot shader features are used and which to avoid. The game targets mid-range PCs and potentially Steam Deck, so document: use StandardMaterial3D for most assets (Forward+ renderer), avoid real-time GI (use baked LightmapGI or VoxelGI sparingly), limit shader complexity to avoid mobile/Deck performance issues, prefer vertex colors over additional texture samples where possible, document the custom shader needs (outline shader, dissolve shader for death VFX, water shader).
**Acceptance Criteria:**
- Shader compatibility document exists with do/don't guidelines
- Performance target (60fps on GTX 1060 / Steam Deck) is stated
- Custom shader list identifies each needed shader with a brief description of its purpose

### Task 01.18: Set Up Version Control for Art Assets
**Status:** TODO
**Description:** Configure Git LFS to track large binary art files. Add LFS tracking rules for `*.blend`, `*.glb`, `*.png` (in `_art_source/` only, not Godot's imported versions), `*.psd`, `*.kra`, `*.wav`, `*.ogg`. Verify LFS is working by adding a test file and confirming it is stored as an LFS pointer in the repository. If LFS is not feasible, document the alternative strategy (external storage, Google Drive sync, etc.) and ensure `.gitignore` excludes binary source files.
**Acceptance Criteria:**
- `.gitattributes` file contains LFS tracking rules for art file extensions
- A test push/pull cycle confirms LFS is storing and retrieving binary files correctly
- Team members (or future contributors) can clone the repo and get art assets via LFS

### Task 01.19: Create Asset Checklist Template
**Status:** TODO
**Description:** Build a reusable checklist template (`_bmad-output/visual-overhaul/asset-checklist.md`) that artists follow for every new asset. The checklist includes: modeling complete, UV unwrapped with no overlaps, textures painted at correct resolution, LOD meshes created, collision mesh created (if needed), exported via correct preset, imported into Godot, material assigned and verified, placed in a test scene to check scale/lighting, screenshot taken for asset catalog. This ensures no asset ships incomplete.
**Acceptance Criteria:**
- Checklist template covers all pipeline steps from modeling to in-engine verification
- Each checklist item has a brief description of what "done" looks like
- Template is copy-pasteable into issue trackers or task managers

### Task 01.20: Build Asset Pipeline Smoke Test
**Status:** TODO
**Description:** Perform a full end-to-end pipeline test by creating a simple prop (a wooden crate) from scratch. Model it in Blender using the template, UV unwrap it, paint a 512x512 hand-painted texture, export it via the `EnthProp` preset, import it into Godot in the correct folder, assign the base opaque material with the painted texture, place it in the scale verification scene, and confirm it looks correct at the right size with proper lighting. Document any issues found and fix them in the pipeline settings.
**Acceptance Criteria:**
- A finished wooden crate prop exists in Godot at correct scale with hand-painted texture
- The entire process from Blender to Godot took no more than 30 minutes (proving pipeline efficiency)
- Any pipeline issues discovered during the test are resolved and documented

## Dependencies
- None (this is the foundational epic)

## Notes
- All Blender work targets Blender 4.x (4.0+) for compatibility with current glTF export improvements
- The Godot project uses the Forward+ renderer, not Compatibility or Mobile
- Steam Deck compatibility is a secondary target, so keep shader complexity in mind
- The `_art_source/` folder is intentionally outside `res://` to prevent Godot from trying to import raw .blend files
