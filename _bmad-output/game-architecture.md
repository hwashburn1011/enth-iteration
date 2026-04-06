---
title: 'Game Architecture'
project: 'enth-iteration'
date: '2026-04-05'
author: 'Heath'
version: '1.0'
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: 'complete'

# Source Documents
gdd: 'gdd.md'
epics: null
brief: 'game-brief.md'
---

# Game Architecture

## Document Status

This architecture document is being created through the GDS Architecture Workflow.

**Steps Completed:** 2 of 9

---

## Project Context

### Game Overview

**Enth: Iteration** — ARPG life-sim where Globbler, an AI agent, delves through techno-dungeons and builds a digital community across 9 escalating iterations inside a crumbling computer simulation.

### Technical Scope

**Platform:** PC (Steam) — Windows primary
**Genre:** Action RPG with life-sim elements
**Project Complexity:** High

### Core Systems

| System | Complexity | Notes |
|--------|-----------|-------|
| Player Character & Stats | Medium | 4 stats, leveling, stat allocation |
| Real-time Combat | High | Attack pipeline, modules, status effects, i-frames |
| Hybrid Dungeon Generation | High | Hand-crafted templates assembled procedurally |
| Item/Loot System | High | 5 item types, 4 rarity tiers, affixes, degradation |
| Iteration Manager | High | 9-cycle system with selective persistence/reset |
| Save System | Medium | Complex state, auto-save, rolling backups |
| NPC & Dialogue | Medium | Portraits, iteration-aware dialogue, affinity |
| Town Hub | Medium | Expanding area, NPC placement, upgrade stations |
| Quest System | Medium | Story/character/discovery quest types |
| UI/HUD | Medium | Health, compute, modules, inventory, quest log |
| Scene Management | Medium | Floor transitions, town/dungeon, portals |

### Technical Requirements

- 60fps at 1080p on mid-range PC
- Floor transitions under 3 seconds
- Procedural generation under 1 second
- Save file under 1MB
- Under 2GB install (demo), under 5GB (full)
- Object pooling for enemies and projectiles

### Complexity Drivers

1. **Iteration reset system** — Selective persistence across 9 cycles (what stays, what refreshes, what evolves) is novel and touches every system
2. **Hybrid dungeon generation** — Combining hand-crafted story rooms with procedural assembly requires a robust room template system
3. **Item degradation on death** — Stat reduction without item loss requires tracking per-item degradation state
4. **Boss evolution** — Same bosses with different phases/patterns across iterations
5. **NPC awareness** — Dialogue trees that branch based on iteration number and story flags

### Technical Risks

- Iteration system complexity may create hard-to-debug state issues
- Procedural dungeon validation (ensuring all floors are completable)
- Save system must handle schema evolution as features are added
- Visual quality consistency between hand-crafted and procedural content

## Engine Selection

### Decision: Godot 4.4

**Rationale:**
- Free, open-source, MIT license — no royalties, no revenue share
- GDScript for rapid development with AI-assisted workflow
- Scene tree architecture maps perfectly to component-based game design
- Resource system ideal for data-driven items, abilities, and enemies
- Forward+ renderer handles Emberville-style 2.5D/3D at high performance
- Active community with extensive plugin ecosystem
- Godot MCP integration for AI-assisted development

### Language: GDScript (Primary)

- Static typing enforced everywhere for performance and error catching
- C# available as fallback for computation-heavy systems if needed
- No mixing for MVP — GDScript only to avoid build complexity

### Renderer: Forward+

- Best option for 3D games on PC
- Handles the stylized low-poly aesthetic easily at 60fps
- Supports all needed lighting/shadow features for the visual style

### Key Plugins (Planned)

| Plugin | Purpose | Priority |
|--------|---------|----------|
| GUT | Unit testing framework | MVP |
| GodotSteam | Steam SDK integration | Phase 4 |
| Dialogic 2 | Dialogue/timeline system | Evaluate for NPC system |

### MCP Integrations

- **Godot MCP** — Scene creation, node management, project testing, debug output
- **Blender MCP** — 3D asset creation, modeling, texture generation

### Decisions Provided by Engine

Godot 4.4 provides these architectural decisions out of the box:
- Scene tree architecture (composition via node hierarchy)
- Signal system for decoupled communication
- Resource system for data-driven design
- Built-in physics (or Jolt plugin for 3D)
- Animation system (AnimationPlayer, AnimationTree)
- UI system (Control nodes, themes)
- Audio buses and playback
- Input mapping system

## Decision Summary

| Category | Decision | Rationale |
|----------|----------|-----------|
| Engine | Godot 4.4 (Forward+) | Free, open-source, ideal for stylized 3D |
| Language | GDScript (static typed) | Rapid dev, AI-assisted workflow, native integration |
| Physics | Godot built-in 3D physics | Sufficient for ARPG, no plugin overhead |
| Scene Management | SceneManager autoload | Centralized transitions with loading screens |
| State Machines | Node-based StateMachine pattern | Clean separation of entity states |
| Data Architecture | Custom Resources (.tres) | Data-driven design, Inspector-editable |
| Save Format | JSON serialization | Human-readable, debuggable, schema-flexible |
| Event System | EventBus autoload | Decoupled cross-system communication |
| Dungeon Generation | Room-based procedural assembly | PackedScene templates + floor generator |

## Autoloads (Singletons)

Only these 5 systems are autoloads — everything else lives in the scene tree:

| Autoload | Responsibility |
|----------|---------------|
| `GameManager` | Game state (menu, playing, paused, dialogue, inventory), scene flow, pause handling |
| `EventBus` | Global signal hub — all cross-system events route through here |
| `SaveManager` | Auto-save triggers, serialization, file I/O, rolling backups |
| `IterationManager` | Current iteration number, persistence rules (what stays/resets), level cap, loot table tier |
| `AudioManager` | Music playback, SFX pooling, crossfade between zones |

## Core Architectural Decisions

### ADR-001: Scene Composition over Inheritance

All game entities (Player, Enemy, NPC) are built by composing reusable component nodes, not through deep class hierarchies.

**Example — Player scene:**
```
Player (CharacterBody3D)
├── StateMachine
│   ├── IdleState
│   ├── WalkState
│   ├── DashState
│   ├── AttackState
│   ├── HurtState
│   └── DeathState
├── HealthComponent
├── ComputeComponent (mana)
├── HitboxComponent (deals damage)
├── HurtboxComponent (receives damage)
├── InventoryComponent
├── StatsComponent (Processing, Bandwidth, Memory, Integrity)
├── AbilityManager (manages Module slots 1-4 + innate attacks)
├── Sprite3D / Model
├── AnimationPlayer
└── InteractionArea (Area3D — detects interactables)
```

**Rationale:** Components are reusable across entity types. HealthComponent works on Player, Enemy, and destructible props. StateMachine pattern works for Player and Enemy AI with different state sets.

### ADR-002: Data-Driven Items via Resources

All items are defined as custom Resource subclasses:

```
ItemBase (Resource)
├── ChipItem — stat boosts (Processing +12%, etc.)
├── ModuleItem — ability definition (damage, cooldown, compute cost, VFX)
├── CoreItem — build-defining effect (unique passive)
├── ProtocolItem — conditional trigger (on_kill, on_hit, on_dash)
└── PromptItem — consumable (heal amount, compute restore, buff type)
```

Each item instance tracks: base stats, rarity, affixes, current degradation level. Stored as .tres files for editor creation, generated at runtime for loot drops.

### ADR-003: EventBus Signal Architecture

Cross-system communication uses the EventBus autoload. Systems emit and listen to events without direct references to each other.

**Key events:**
- `enemy_defeated(enemy_type, position, loot_table)`
- `item_collected(item: ItemBase)`
- `damage_dealt(amount, source, target, damage_type)`
- `player_died(position)`
- `portal_reached(portal_id)`
- `iteration_started(iteration_number)`
- `iteration_reset()`
- `npc_recruited(npc_id)`
- `quest_updated(quest_id, status)`
- `dialogue_started(npc_id)` / `dialogue_ended()`

**Rule:** Direct method calls for parent→child. Signals for sibling→sibling and child→parent. EventBus for cross-system.

### ADR-004: Iteration Persistence Model

The IterationManager defines what persists across each boundary:

**Persists through death (within iteration):**
- Character level, XP, stats
- All inventory (with degradation applied to some items)
- Town state, recruited NPCs, affinity levels
- Quest progress, story flags
- Current iteration and compaction loop progress

**Persists through iteration reset:**
- Character level (cap increases)
- Core progression unlocks
- Town state and NPCs
- Story knowledge (all flags cumulative)
- Key items/unlocks

**Resets on iteration:**
- Dungeon floor progress (start fresh)
- Dungeon layouts regenerated
- Boss forms evolve (new phases/patterns)
- Enemy stat scaling increases
- Loot tables upgrade (higher rarity available)
- Environmental storytelling updates

### ADR-005: Hybrid Dungeon Generation

**Architecture:**
```
DungeonGenerator (Node)
├── FloorGenerator — assembles rooms into a floor layout
├── RoomTemplateLibrary — indexed collection of PackedScenes
│   ├── combat_rooms/ (by difficulty tier)
│   ├── loot_rooms/
│   ├── corridor_rooms/
│   ├── story_rooms/ (hand-crafted, fixed placement)
│   └── boss_arenas/ (hand-crafted)
├── ThemeApplicator — applies visual theme based on depth
└── ValidationPass — ensures floor is completable
```

**Generation flow:**
1. Select floor template (linear-branching graph)
2. Place story rooms at fixed positions (if any for this floor)
3. Fill remaining slots from RoomTemplateLibrary by type and difficulty
4. Apply theme visuals based on dungeon depth
5. Spawn enemies and loot based on floor difficulty and iteration
6. Validate: ensure path from entrance to exit exists
7. Instance the floor scene

### ADR-006: Save System Architecture

**Save data structure (JSON):**
```json
{
  "version": 1,
  "timestamp": "2026-04-05T12:00:00",
  "player": { "level": 0, "xp": 0, "stats": {}, "stat_points": 0 },
  "inventory": { "equipped": {}, "backpack": [], "degradation_states": {} },
  "iteration": { "current": 1, "compaction_loop": 0, "story_flags": [] },
  "town": { "npcs_recruited": [], "upgrades_built": [], "npc_affinity": {} },
  "quests": { "active": [], "completed": [], "discovery_flags": [] },
  "settings": { "audio_levels": {}, "keybinds": {} }
}
```

**Auto-save triggers:** Floor complete, town entry, portal use, iteration transition. Rolling backup of last 3 saves. Schema version field enables migration when save format evolves.

## Cross-cutting Concerns

### Error Handling

- Use `push_error()` for critical errors that indicate bugs
- Use `push_warning()` for recoverable issues
- Never use `print()` in production — use Godot's logging levels
- Assert preconditions in debug builds: `assert(item != null, "Item cannot be null")`
- Graceful degradation: if a resource fails to load, use a fallback rather than crashing

### Logging Strategy

- Debug builds: verbose logging via `push_warning()` and custom debug overlay
- Release builds: errors only, written to user log file
- Save system logs all save/load operations for debugging corruption issues
- Dungeon generator logs seed and room selections for reproducibility

### Performance Strategy

- **Object pooling** for enemies, projectiles, and VFX particles
- **`_physics_process`** for movement and collision only
- **`_process`** for UI updates and visual effects only
- **Visibility culling:** disable processing on off-screen entities via VisibleOnScreenNotifier3D
- **Threaded loading:** use ResourceLoader.load_threaded_request for floor transitions
- **Static typing everywhere** — typed GDScript runs significantly faster

### Input Handling

- All input mapped through Godot's Input Map (Project Settings)
- InputManager reads Input Map — no hardcoded key checks in game code
- All actions referenced by StringName: `&"move_left"`, `&"attack_primary"`, etc.
- Rebindable keys supported through Input Map modification at runtime

---

## Project Structure

```
enth-iteration/
├── project.godot
├── addons/                      # Third-party plugins (GUT, etc.)
├── assets/                      # Raw art, audio, fonts
│   ├── models/                  # .glb/.gltf from Blender
│   ├── textures/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   └── shaders/
├── scenes/                      # .tscn scene files
│   ├── main/                    # Main menu, loading screen
│   ├── town/                    # Town hub scene and sub-scenes
│   ├── dungeon/                 # Dungeon scenes
│   │   ├── rooms/               # Room templates (combat, loot, corridor, story)
│   │   ├── floors/              # Hand-crafted demo floors
│   │   └── bosses/              # Boss arena scenes
│   ├── entities/                # Player, enemies, NPCs
│   │   ├── player/
│   │   ├── enemies/
│   │   └── npcs/
│   ├── ui/                      # All UI scenes
│   │   ├── hud/
│   │   ├── menus/
│   │   ├── inventory/
│   │   └── dialogue/
│   └── effects/                 # VFX scenes
├── scripts/                     # .gd script files
│   ├── autoloads/               # GameManager, EventBus, SaveManager, etc.
│   ├── components/              # Reusable components (HealthComponent, etc.)
│   ├── state_machines/          # StateMachine, State base, specific states
│   ├── systems/                 # Combat, loot generation, dungeon generation
│   ├── resources/               # Custom Resource class definitions
│   ├── ui/                      # UI controller scripts
│   └── utils/                   # Helpers, constants, enums
├── data/                        # .tres resource files, JSON configs
│   ├── items/                   # Item definitions by type
│   │   ├── chips/
│   │   ├── modules/
│   │   ├── cores/
│   │   ├── protocols/
│   │   └── prompts/
│   ├── enemies/                 # Enemy stat definitions
│   ├── npcs/                    # NPC data (dialogue, quests, affinity)
│   ├── loot_tables/             # Drop tables by floor/difficulty
│   ├── quests/                  # Quest definitions
│   └── iterations/              # Per-iteration config (boss phases, story flags, etc.)
├── tests/                       # GUT test files
│   ├── unit/
│   └── integration/
└── docs/                        # Project documentation
```

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Scripts | snake_case.gd | `health_component.gd` |
| Scenes | PascalCase.tscn | `Player.tscn`, `DataCorridor.tscn` |
| Resources | snake_case.tres | `turing_kernel.tres` |
| Classes | PascalCase | `class_name HealthComponent` |
| Variables/Functions | snake_case | `var move_speed`, `func take_damage()` |
| Constants | UPPER_SNAKE_CASE | `const MAX_HEALTH := 100` |
| Signals | past_tense_snake_case | `signal health_changed` |
| Enums | PascalCase.UPPER_CASE | `enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }` |
| Autoloads | PascalCase | `GameManager`, `EventBus` |
| Folders | snake_case | `combat_rooms/`, `loot_tables/` |

---

## Implementation Patterns

These patterns ensure consistent implementation across all AI agents:

### Pattern 1: Component Node

Every reusable behavior is a component node with signals:

```gdscript
class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health = maxi(0, current_health - amount)
    health_changed.emit(current_health, max_health)
    if current_health <= 0:
        died.emit()

func heal(amount: int) -> void:
    current_health = mini(max_health, current_health + amount)
    health_changed.emit(current_health, max_health)
```

### Pattern 2: State Machine

Every entity with multiple behaviors uses this pattern:

```gdscript
class_name StateMachine
extends Node

@export var initial_state: State
var current_state: State

func _ready() -> void:
    for child in get_children():
        if child is State:
            child.state_machine = self
    current_state = initial_state
    current_state.enter()

func _process(delta: float) -> void:
    current_state.update(delta)

func _physics_process(delta: float) -> void:
    current_state.physics_update(delta)

func transition_to(target_state: State) -> void:
    current_state.exit()
    current_state = target_state
    current_state.enter()
```

### Pattern 3: Resource-Based Data Definition

All game data (items, enemies, abilities) follows this pattern:

```gdscript
class_name ItemBase
extends Resource

@export var item_name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: Rarity

enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }
```

### Pattern 4: Object Pool

Frequently spawned objects use pooling:

```gdscript
class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var pool_size: int = 20
var _pool: Array[Node] = []

func _ready() -> void:
    for i in pool_size:
        var obj := scene.instantiate()
        obj.visible = false
        obj.set_process(false)
        add_child(obj)
        _pool.append(obj)

func get_object() -> Node:
    for obj in _pool:
        if not obj.visible:
            obj.visible = true
            obj.set_process(true)
            return obj
    return null

func return_object(obj: Node) -> void:
    obj.visible = false
    obj.set_process(false)
```

### Pattern 5: Scene Transition

All scene changes go through GameManager:

```gdscript
func change_scene_to(path: String) -> void:
    EventBus.scene_changing.emit()
    ResourceLoader.load_threaded_request(path)
    while ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
        await get_tree().process_frame
    var scene := ResourceLoader.load_threaded_get(path)
    get_tree().change_scene_to_packed(scene)
    EventBus.scene_changed.emit(path)
```

---

## Epic to Architecture Mapping

| Epic | Key Architectural Components |
|------|------------------------------|
| 1: Foundation | Autoloads, project structure, input map, camera |
| 2: Player | CharacterBody3D, StateMachine, components, AbilityManager |
| 3: Combat | HitboxComponent, damage pipeline, enemy base class, object pools |
| 4: Dungeon (Demo) | Room scenes, FloorManager, hand-crafted floors |
| 5: Items | ItemBase resources, rarity system, loot generation, InventoryComponent |
| 6: Town | Town scene, NPC placement, interaction areas |
| 7: NPC/Dialogue | Dialogue UI, NPC data resources, InteractionArea |
| 8: Save | SaveManager autoload, JSON serialization, auto-save triggers |
| 9: UI/HUD | Control nodes, HUD overlay, inventory screen, quest log |
| 10: Demo Polish | Integration testing, audio placeholders, demo build |
| 11: Procedural | DungeonGenerator, RoomTemplateLibrary, ValidationPass |
| 17: Iteration | IterationManager autoload, persistence model, reset logic |

---

## Development Environment

### Prerequisites

- Godot 4.4 (stable)
- Blender 4.x (for 3D asset creation)
- Git (version control)
- GUT addon (testing)

### AI Tooling (MCP Servers)

- **Godot MCP** — Scene creation, node management, project runs, debug output
- **Blender MCP** — 3D modeling, texture creation, asset export

### Setup Commands

```bash
# Clone project
git clone <repo-url> enth-iteration
cd enth-iteration

# Open in Godot
# Launch Godot 4.4 and open project.godot

# Install GUT testing addon
# Download from AssetLib or clone into addons/gut/
```

---

## Architecture Validation Checklist

- [x] Engine selected and validated (Godot 4.4)
- [x] All core systems identified with complexity assessment
- [x] Autoloads limited to 5 truly global services
- [x] Component composition pattern defined (no deep inheritance)
- [x] Data-driven design via Resources for all game data
- [x] EventBus pattern for cross-system communication
- [x] State machine pattern for entity behaviors
- [x] Object pooling strategy for performance
- [x] Save system architecture with schema versioning
- [x] Iteration persistence model fully specified
- [x] Hybrid dungeon generation architecture defined
- [x] Project folder structure established
- [x] Naming conventions documented
- [x] Implementation patterns with code examples provided
- [x] Epic-to-architecture mapping complete

---

_Generated by GDS Architecture Workflow v1.0_
_Date: 2026-04-05_
_For: Heath_
