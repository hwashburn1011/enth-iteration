# Enth: Iteration — Visual Overhaul Master Plan

## Goal
Transform the game from programmer-art prototype (~35/100) to Emberville/Stardew Valley quality (~80+/100) through proper 3D art pipeline: sculpting, UV mapping, texture painting, rigging, animation, lighting, and VFX.

## Current State Assessment
- 36 Blender models (primitive compositions — spheres/boxes stacked)
- Zero textures (all flat color materials)
- Zero skeletal animation (sine-wave bob only)
- Synthesized placeholder audio
- Functional gameplay systems but combat feels broken
- Score: ~35/100

## Target State
- Properly sculpted, UV-mapped, texture-painted models
- Skeletal animation with walk/idle/attack/hurt/death cycles
- Hand-painted stylized textures matching Emberville aesthetic
- Professional audio (composed music, layered SFX)
- Polished combat with readable feedback
- Score: 80+/100

---

## Epic Index (50 Epics)

### PHASE 1: Foundation & Pipeline (Epics 1-5)
- [Epic 01](epic-01-art-pipeline.md) — Art Pipeline Setup (Blender workflow, export settings, naming conventions)
- [Epic 02](epic-02-style-guide-v3.md) — Visual Style Guide v3 (reference sheets, color swatches, proportion rules)
- [Epic 03](epic-03-texture-workflow.md) — Texture Painting Workflow (UV standards, resolution, atlas setup)
- [Epic 04](epic-04-animation-pipeline.md) — Animation Pipeline (rig standards, bone naming, export format)
- [Epic 05](epic-05-combat-fixes.md) — Combat System Fixes (broken mechanics, hitbox tuning, damage flow)

### PHASE 2: Player Character (Epics 6-10)
- [Epic 06](epic-06-globbler-model.md) — Globbler Character Model (sculpt, retopo, UV)
- [Epic 07](epic-07-globbler-textures.md) — Globbler Textures (diffuse, normal, emission maps)
- [Epic 08](epic-08-globbler-rig.md) — Globbler Rig & Skeleton (armature, weight painting, IK)
- [Epic 09](epic-09-globbler-animations.md) — Globbler Animations (idle, walk, dash, attack, hurt, death)
- [Epic 10](epic-10-globbler-vfx.md) — Globbler VFX Integration (attack trails, dash ghost, footsteps)

### PHASE 3: Enemy Characters (Epics 11-18)
- [Epic 11](epic-11-glitchbug-full.md) — GlitchBug Full Rebuild ✅ DONE
- [Epic 12](epic-12-memoryleak-full.md) — MemoryLeak Full Rebuild ✅ DONE
- [Epic 13](epic-13-rogueprocess-full.md) — RogueProcess Full Rebuild ✅ DONE
- [Epic 14](epic-14-corrupted-compiler-full.md) — Corrupted Compiler Boss Full Rebuild ✅ DONE
- [Epic 15](epic-15-enemy-shared-vfx.md) — Enemy Shared VFX (spawn, death, hit reactions) ✅ DONE
- [Epic 16](epic-16-enemy-ai-polish.md) — Enemy AI Visual Polish (telegraph animations, aggro indicators) ✅ DONE
- [Epic 17](epic-17-enemy-variants.md) — Enemy Color/Size Variants (elite versions, floor scaling) ✅ DONE
- [Epic 18](epic-18-boss-phases.md) — Boss Phase Visuals (phase transitions, arena effects) ✅ DONE

### PHASE 4: NPC Characters (Epics 19-22)
- [Epic 19](epic-19-ai-sage-full.md) — AI Sage Full Rebuild ✅ DONE
- [Epic 20](epic-20-cache-sprite-full.md) — Cache Sprite Full Rebuild ✅ DONE
- [Epic 21](epic-21-npc-expressions.md) — NPC Expression System ✅ DONE
- [Epic 22](epic-22-npc-interaction-polish.md) — NPC Interaction Polish ✅ DONE

### PHASE 5: Town Environment (Epics 23-30)
- [Epic 23](epic-23-terrain-system.md) — Town Terrain ✅ DONE
- [Epic 24](epic-24-buildings-textured.md) — Buildings Textured ✅ DONE
- [Epic 25](epic-25-vegetation-system.md) — Vegetation System ✅ DONE
- [Epic 26](epic-26-props-textured.md) — Town Props Textured ✅ DONE
- [Epic 27](epic-27-town-lighting.md) — Town Lighting Overhaul ✅ DONE
- [Epic 28](epic-28-water-effects.md) — Water Effects ✅ DONE
- [Epic 29](epic-29-town-atmosphere.md) — Town Atmosphere ✅ DONE
- [Epic 30](epic-30-town-layout-polish.md) — Town Layout Polish ✅ DONE

### PHASE 6: Dungeon Environment (Epics 31-38)
- [Epic 31](epic-31-dungeon-tileset.md) — Dungeon Tile Set ✅ DONE
- [Epic 32](epic-32-dungeon-props-textured.md) — Dungeon Props Textured ✅ DONE
- [Epic 33](epic-33-dungeon-lighting.md) — Dungeon Lighting Overhaul ✅ DONE
- [Epic 34](epic-34-dungeon-floor-themes.md) — Floor Visual Themes ✅ DONE
- [Epic 35](epic-35-combat-arena-design.md) — Combat Arena Design ✅ DONE
- [Epic 36](epic-36-dungeon-hazards.md) — Dungeon Hazards Visual ✅ DONE
- [Epic 37](epic-37-boss-arena.md) — Boss Arena Overhaul ✅ DONE
- [Epic 38](epic-38-dungeon-transitions.md) — Room Transitions Visual ✅ DONE

### PHASE 7: UI/UX Overhaul (Epics 39-43)
- [Epic 39](epic-39-custom-font.md) — Custom Game Font ✅ DONE
- [Epic 40](epic-40-hud-redesign.md) — HUD Redesign ✅ DONE
- [Epic 41](epic-41-inventory-redesign.md) — Inventory Screen Redesign ✅ DONE
- [Epic 42](epic-42-dialogue-system-visual.md) — Dialogue System Visual ✅ DONE
- [Epic 43](epic-43-menu-screens.md) — Menu Screens Polish ✅ DONE

### PHASE 8: VFX & Particles (Epics 44-47)
- [Epic 44](epic-44-combat-vfx.md) — Combat VFX Overhaul ✅ DONE
- [Epic 45](epic-45-environment-vfx.md) — Environment VFX ✅ DONE
- [Epic 46](epic-46-ui-vfx.md) — UI VFX ✅ DONE
- [Epic 47](epic-47-shader-effects.md) — Shader Effects ✅ DONE

### PHASE 9: Audio Overhaul (Epics 48-49)
- [Epic 48](epic-48-music-production.md) — Music Production ✅ DONE
- [Epic 49](epic-49-sfx-overhaul.md) — SFX Overhaul ✅ DONE

### PHASE 10: Final Polish (Epic 50)
- [Epic 50](epic-50-final-polish.md) — Final Polish Pass (screenshot quality, trailer moments, consistency) ✅ DONE

---

## Execution Strategy
1. Work through phases sequentially (pipeline → characters → environments → UI → VFX → audio → polish)
2. Each epic has 20 detailed tasks
3. Use Blender MCP for all 3D work (sculpting, UV, texture painting, rigging, animation)
4. Export as .glb with embedded textures for Godot
5. Verify each asset in-game via Godot MCP before marking complete
6. Take before/after screenshots for each major asset

## Priority Order Within Phases
- Always do the PLAYER CHARACTER first (most visible asset)
- Then ENEMIES (combat readability)
- Then ENVIRONMENT (atmosphere)
- Then UI (quality of life)
- Then VFX/AUDIO (polish)
