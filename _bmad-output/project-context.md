---
project_name: 'enth-iteration'
user_name: 'Heath'
date: '2026-04-05'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'code_quality', 'workflow_rules', 'critical_rules']
status: 'complete'
rule_count: 40
optimized_for_llm: true
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

- **Engine:** Godot 4.4 (Forward Plus renderer)
- **Primary Language:** GDScript
- **Secondary Language:** C# (.NET) — assembly name: Enth-Iteration
- **3D Pipeline:** Blender → Godot (via Blender MCP for asset creation)
- **MCP Integrations:** Godot MCP (scene/node management, project runs), Blender MCP (3D modeling)
- **Data:** JSON and Godot Resources (.tres) for items, abilities, and game data
- **Project Management:** BMad v6.2.2 (GDS v0.2.2)

## Critical Implementation Rules

### GDScript & Godot 4.4 Rules

- **Use typed GDScript everywhere** — all variables, parameters, and return types must have explicit type hints (e.g., `var speed: float = 5.0`, `func move(dir: Vector3) -> void:`)
- **Use `@export` annotations** (not old `export` keyword) for inspector-exposed variables
- **Use `@onready`** for node references instead of `_ready()` assignments where possible
- **Signal declarations use `signal` keyword** — connect via code with `.connect()`, not editor when possible (keeps logic traceable)
- **Use `StringName` and `&"name"` syntax** for frequent string comparisons (node paths, animation names) — significant performance benefit in Godot 4
- **Prefer `PackedScene.instantiate()`** over legacy `instance()` — Godot 4 API change
- **Use `await` keyword** (not old `yield`) for coroutines and signal waits
- **Node references:** use `%UniqueNodeName` syntax with scene-unique nodes over fragile `$Path/To/Node` paths
- **Resource preloading:** use `const SCENE := preload("res://path.tscn")` at class level for frequently used scenes/resources
- **Error handling:** use `push_error()` / `push_warning()` for debug messages, never `print()` in production code

### Godot Engine & Architecture Rules

- **Scene composition over inheritance** — build complex entities by composing smaller scenes/nodes, not deep inheritance chains. Player, Enemy, etc. should be composed of reusable component scenes (e.g., HealthComponent, HitboxComponent)
- **Autoloads for global systems only** — InputManager, WorldManager belong as autoloads; per-entity systems (AbilitySystem) do NOT
- **Scene tree structure:** root scenes (Player.tscn, Enemy.tscn, Hub.tscn, Dungeon.tscn) own their node hierarchy; child scenes are instanced, never directly edited in parent
- **State machines for entity behavior** — Player and Enemy AI must use explicit state machine patterns (idle, moving, attacking, etc.), not sprawling if/else chains
- **AbilitySystem is modular** — abilities are data-driven Resources, not hardcoded scripts. The pipeline is: Input → Ability → Modifiers → Execution → Effects (per combat_system.md)
- **Items are Resources** — Chips, Modules, Cores, Protocols defined as custom Resource classes with exported properties, stored as .tres files
- **Hub evolution is data-driven** — Hub upgrades (Memory Nodes, Compute Clusters, Simulation Forks) tracked as progression data, not separate scenes per state
- **Iteration/run system** — game tracks current run number (1-10) which drives narrative state, anomaly levels, and NPC awareness (per story_and_iterations.md)
- **Visual style compliance** — orthographic camera (60° X, 45° Z rotation), chunky rounded assets, muted palette (#6FAF6A, #8A6A4A, #9A9A9A) per visual_style_guide_v2.md
- **Use Godot MCP** for scene creation, node management, and project runs during development
- **Use Blender MCP** for 3D asset creation following the visual style guide

### Testing Rules

- **Use Godot's built-in testing approach** — GDUnit4 or GUT (Godot Unit Test) addon for GDScript unit tests
- **Test naming:** test scripts mirror source scripts — `player.gd` → `test_player.gd`, placed in a `tests/` directory mirroring the source structure
- **Test game systems independently** — AbilitySystem, ItemSystem, and IterationManager should be testable without full scene tree when possible
- **Use Godot MCP `run_project`** to validate scene integration and runtime behavior
- **Resource validation** — item .tres files should be loadable and pass type checks before integration
- **No mocking the scene tree** — prefer lightweight test scenes over complex mocks for integration tests

### Code Quality & Style Rules

- **File naming:** lowercase_snake_case for scripts (`player.gd`, `ability_system.gd`), PascalCase for scenes (`Player.tscn`, `Hub.tscn`)
- **Class naming:** PascalCase for classes and node names (`class_name PlayerController`)
- **Variable/function naming:** snake_case (`var move_speed`, `func take_damage()`)
- **Constants:** UPPER_SNAKE_CASE (`const MAX_HEALTH := 100`)
- **Signals:** past tense snake_case (`signal health_changed`, `signal ability_fired`)
- **Folder structure:** `scenes/`, `scripts/`, `resources/`, `assets/`, `tests/` at project root
- **One script per node type** — avoid monolithic scripts; split logic into component scripts attached to child nodes
- **Keep scripts under ~200 lines** — if longer, decompose into components or utility classes
- **No magic numbers** — use named constants or exported variables for all tuning values
- **Design docs are source of truth** — reference `/prompts/` docs for game mechanics; do not invent systems that contradict them

### Development Workflow Rules

- **Branch from `main`** for all feature work
- **Branch naming:** `feature/system-name` (e.g., `feature/combat-system`, `feature/hub-evolution`)
- **Commit messages:** imperative mood, prefixed with area (e.g., `player: add movement and dodge`, `items: create chip resource class`)
- **MVP scope first** — always implement the minimal version from the design docs before adding complexity (1 combat zone, 1 hub, 10-15 items, 1 reset loop)
- **Iterate in run order** — build systems to support Run 1-2 (normal world) before layering in glitch/awareness mechanics from later runs
- **Use Godot MCP to test** — run the project through MCP after changes to validate; check debug output for errors
- **Asset pipeline:** create 3D assets in Blender via Blender MCP → export to Godot project → import and configure in Godot MCP

### Critical Don't-Miss Rules

**Game Inspiration & Tone:**
- **Primary visual inspiration:** Emberville (upcoming Steam title) — chunky 3D aesthetic, warm cozy palette, orthographic/isometric perspective
- **Gameplay inspirations:** Stardew Valley (life-sim loop, hub progression), Terraria (exploration/crafting), Sea of Stars (narrative polish, visual charm), Hades (meta-progression across runs, narrative through repetition), Diablo/Path of Exile (ARPG loot loop)
- When in doubt about feel or tone, lean toward the cozy-but-mysterious blend — not grimdark, not purely cute
- **Visual approach is Emberville-style 2.5D/3D** — 3D models with orthographic camera creating an isometric look. The exact 2D vs 3D decision is still open; all systems should be built to work with either approach. Do not assume pure 3D or pure 2D — design for the Emberville aesthetic (chunky, rounded, stylized models viewed from a fixed isometric-like angle)

**Anti-Patterns to Avoid:**
- **NEVER use Godot 3.x API** — no `yield()`, `instance()`, `export var`, `onready var` without `@` prefix. Agents frequently regress to Godot 3 syntax
- **NEVER create circular dependencies** between autoloads — use signals or a message bus instead
- **NEVER hardcode run/iteration numbers** in game logic — always read from the IterationManager so narrative progression stays data-driven
- **Do not over-scope** — the design docs describe the full vision; always check MVP section before implementing. If a system isn't needed for MVP, don't build it yet

**Performance Gotchas:**
- **Use object pooling** for enemies and projectiles — don't instantiate/free every frame
- **Physics process vs process** — use `_physics_process()` for movement/collision, `_process()` for UI and visuals only
- **Signal over polling** — never check state in `_process()` when a signal can notify of changes

---

## Usage Guidelines

**For AI Agents:**
- Read this file before implementing any code
- Follow ALL rules exactly as documented
- When in doubt, prefer the more restrictive option
- Reference `/prompts/` design docs for game mechanics details

**For Humans:**
- Keep this file lean and focused on agent needs
- Update when technology stack or patterns change
- Remove rules that become obvious over time

Last Updated: 2026-04-05
