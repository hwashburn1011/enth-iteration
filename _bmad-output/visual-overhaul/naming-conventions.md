# Enth: Iteration — Asset Naming Conventions

## Mesh / Model Names
Format: `category_name_variant`

| Category | Prefix | Example |
|----------|--------|---------|
| Character | `char_` | `char_globbler_body`, `char_sage_robe` |
| Enemy | `enemy_` | `enemy_glitchbug_body`, `enemy_compiler_core` |
| Building | `bldg_` | `bldg_cottage_01`, `bldg_tavern_01` |
| Prop | `prop_` | `prop_barrel_rusty`, `prop_bench_wood` |
| VFX Mesh | `vfx_` | `vfx_slash_arc`, `vfx_burst_ring` |
| UI Element | `ui_` | `ui_icon_health`, `ui_frame_inventory` |

## Texture Names
Format: `assetname_maptype.png`

| Map Type | Suffix | Purpose |
|----------|--------|---------|
| Albedo/Diffuse | `_albedo` | Base color |
| Normal | `_normal` | Surface detail bumps |
| Roughness | `_roughness` | Surface smoothness |
| Emission | `_emission` | Glow/light areas |
| Ambient Occlusion | `_ao` | Cavity shadows |
| Metallic | `_metallic` | Metal vs non-metal |

Examples: `globbler_albedo.png`, `globbler_normal.png`, `cottage_albedo.png`

## Texture Resolution Standards

| Asset Type | Resolution | Notes |
|------------|-----------|-------|
| Props (small) | 256x256 | Barrels, crates, flowers |
| Props (medium) | 512x512 | Benches, lanterns, fences |
| Characters | 1024x1024 | Player, NPCs, enemies |
| Buildings | 2048x2048 | Cottage, workshop, tavern |
| UI Elements | 64-512px | Per-element as needed |
| VFX Textures | 256x256 | Particle sprites, trails |
| Terrain | 2048x2048 | Ground texture atlas |

## Animation Names
Format: `charname_actionname`

| Action | Example | Frames (30fps) |
|--------|---------|----------------|
| Idle | `globbler_idle` | 60 (2s loop) |
| Walk | `globbler_walk` | 20 (0.67s loop) |
| Run | `globbler_run` | 14 (0.47s loop) |
| Dash | `globbler_dash` | 8 (0.27s) |
| Attack Primary | `globbler_attack_01` | 12 (0.4s) |
| Attack Charge | `globbler_charge_start` | 10 |
| Hurt | `globbler_hurt` | 9 (0.3s) |
| Death | `globbler_death` | 30 (1s) |
| Level Up | `globbler_levelup` | 24 (0.8s) |

## Material Names (Godot)
Format: `mat_assetname` or `mat_assetname_variant`

Examples: `mat_globbler`, `mat_cottage_wall`, `mat_glitchbug_body`

## Blender Export Presets

| Preset | Use For | Animation | UV2 |
|--------|---------|-----------|-----|
| `EnthProp` | Props, decorations | Off | Off |
| `EnthCharacter` | Player, NPCs, enemies | On (all actions) | Off |
| `EnthBuilding` | Buildings, large structures | Off | On (lightmap) |

All presets: glTF 2.0 Binary (.glb), +Y Up, Apply Modifiers, Embed Textures

## Bone Naming (Armatures)
Rigify-compatible naming:
- `root` → `spine` → `spine.001` → `spine.002` → `neck` → `head`
- `shoulder.L` → `upper_arm.L` → `forearm.L` → `hand.L`
- `thigh.L` → `shin.L` → `foot.L` → `toe.L`
- Mirror with `.R` suffix for right side

## File Locations

| Type | Path |
|------|------|
| Blender source files | `_art_source/` |
| Blender template | `_art_source/template_enth.blend` |
| Exported models | `assets/models/{category}/` |
| Textures | `assets/textures/{category}/` |
| Materials | `assets/materials/` |
| Shaders | `assets/shaders/` |
