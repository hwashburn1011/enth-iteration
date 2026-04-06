---
stepsCompleted: [1, 2, 3]
inputDocuments: ['gdd.md', 'game-architecture.md']
---

# Enth: Iteration - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Enth: Iteration, decomposing the requirements from the GDD and Architecture into implementable stories designed for autonomous AI agent execution.

## Requirements Inventory

### Functional Requirements

FR1: Player character (Globbler) moves with WASD in isometric perspective
FR2: Teleport dash on spacebar with i-frames and cooldown
FR3: Data Pulse basic attack on left click
FR4: Energy Burst charged attack on right click (hold to charge)
FR5: Module abilities mapped to keys 1-4, swappable from equipment
FR6: Health resource depleted by damage, restored by Health Prompts
FR7: Compute (mana) resource powers abilities, regenerates slowly, restored by Compute Prompts
FR8: Character stats: Processing, Bandwidth, Memory, Integrity
FR9: XP from combat and story milestones, level up grants stat point allocation
FR10: Item system with 5 types: Chips, Modules, Cores, Protocols, Prompts
FR11: Item rarity tiers: Common, Uncommon, Rare, Legendary with affixes
FR12: Equipment slots: 4 Module, 1 Core, 4 Chip, 3 Protocol, Prompt hotbar
FR13: Item stat degradation on player death (partial, not destruction)
FR14: Grid-based inventory with compare tooltips and item management
FR15: Enemy AI with state machines, 3-4 basic types for demo
FR16: Hit detection and damage calculation pipeline (Input→Ability→Modifiers→Execution→Effects)
FR17: Status effects: Corrupted, Fragmented, Throttled, Overclocked, Segfault
FR18: Dungeon floors with room-based layout (combat, loot, corridor, story rooms)
FR19: 5 hand-crafted floors for demo compaction loop
FR20: Compaction portal interaction warps player to town
FR21: Hybrid dungeon generation (hand-crafted templates + procedural assembly)
FR22: Town hub with walkable area, NPC spots, dungeon entrance
FR23: Town expands as NPCs are recruited and upgrades built
FR24: NPC dialogue via text pop-up windows that pause gameplay
FR25: NPC portraits with expression changes
FR26: NPC affinity system (talking + quests increases affinity)
FR27: Quest log with Story, Character, and Discovery quest types
FR28: Auto-save system with triggers (floor complete, town entry, portal, iteration)
FR29: Single save slot with rolling backup of last 3 saves
FR30: HUD: health bar, compute bar, module cooldowns, prompt hotbar
FR31: Iteration system: 9 cycles with selective persistence/reset
FR32: The User encounters at iteration boundaries (9 versions)
FR33: Boss encounters at end of each compaction loop (6 bosses + The User)
FR34: Boss evolution across iterations (new phases/patterns)
FR35: NPC awareness evolution across iterations (normal → questioning → aware)
FR36: Endless mode unlocks after iteration 9 with scaling difficulty
FR37: Demo end screen after first compaction portal (standalone build)
FR38: Material recycling from unwanted items for town upgrades

### NonFunctional Requirements

NFR1: 60fps at 1080p on mid-range PC hardware
NFR2: Floor transitions under 3 seconds
NFR3: Procedural dungeon generation under 1 second
NFR4: Save file under 1MB
NFR5: Demo install under 2GB, full game under 5GB
NFR6: Object pooling for enemies and projectiles
NFR7: Static typed GDScript everywhere for performance
NFR8: Zero save data loss incidents
NFR9: Attack animations cancel into dash (responsive controls)
NFR10: Assets must look polished and intentionally stylized, never placeholder
NFR11: Crash rate less than 1 per 10 hours of play
NFR12: All input rebindable

### Additional Requirements

- Scene composition pattern (no deep inheritance) for all entities
- 5 autoloads only: GameManager, EventBus, SaveManager, IterationManager, AudioManager
- EventBus for all cross-system communication
- Data-driven items via custom Resources (.tres)
- State machine pattern for all entity behaviors
- Object pool pattern for spawned objects
- JSON save format with schema versioning
- Project folder structure per architecture spec

### UX Design Requirements

No UX design document — UI specifications are embedded in the GDD.

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 2 | WASD isometric movement |
| FR2 | Epic 2 | Teleport dash |
| FR3 | Epic 3 | Data Pulse attack |
| FR4 | Epic 3 | Energy Burst charged attack |
| FR5 | Epic 4 | Module abilities 1-4 |
| FR6 | Epic 3 | Health resource |
| FR7 | Epic 3 | Compute resource |
| FR8 | Epic 3 | Character stats |
| FR9 | Epic 8 | XP and leveling |
| FR10 | Epic 4 | Item types (5) |
| FR11 | Epic 4 | Rarity tiers |
| FR12 | Epic 4 | Equipment slots |
| FR13 | Epic 4 | Item degradation on death |
| FR14 | Epic 4 | Grid inventory with tooltips |
| FR15 | Epic 3 | Enemy AI |
| FR16 | Epic 3 | Damage pipeline |
| FR17 | Epic 3 | Status effects |
| FR18 | Epic 5 | Dungeon floor layouts |
| FR19 | Epic 5 | 5 hand-crafted demo floors |
| FR20 | Epic 5 | Compaction portal warp |
| FR21 | Epic 10 | Hybrid dungeon generation |
| FR22 | Epic 6 | Town hub |
| FR23 | Epic 6 | Town expansion |
| FR24 | Epic 6 | NPC dialogue pop-ups |
| FR25 | Epic 6 | NPC portraits |
| FR26 | Epic 6 | NPC affinity |
| FR27 | Epic 8 | Quest log |
| FR28 | Epic 7 | Auto-save |
| FR29 | Epic 7 | Rolling backups |
| FR30 | Epic 8 | HUD elements |
| FR31 | Epic 12 | Iteration system |
| FR32 | Epic 12 | The User encounters |
| FR33 | Epic 11 | Boss encounters |
| FR34 | Epic 12 | Boss evolution |
| FR35 | Epic 12 | NPC awareness |
| FR36 | Epic 13 | Endless mode |
| FR37 | Epic 9 | Demo build |
| FR38 | Epic 11 | Material recycling |

## Epic List

### Epic 1: Project Foundation — "The game launches and runs"
Players can launch the game, see a main menu, and enter a basic world.
**FRs covered:** Foundation for all FRs

### Epic 2: Globbler Comes Alive — "Players can move and explore"
Players control Globbler in the isometric world with responsive movement and dash.
**FRs covered:** FR1, FR2

### Epic 3: Combat Fundamentals — "Players can fight enemies"
Players can attack enemies with basic attacks, take damage, and defeat them.
**FRs covered:** FR3, FR4, FR6, FR7, FR8, FR15, FR16, FR17

### Epic 4: Loot & Equipment — "Players find and equip gear"
Players discover items in the world, equip them, manage inventory, and feel progression through loot.
**FRs covered:** FR5, FR10, FR11, FR12, FR13, FR14

### Epic 5: The First Dungeon — "Players explore dungeon floors"
Players enter the dungeon, progress through floors, fight encounters, find loot, and reach the compaction portal.
**FRs covered:** FR18, FR19, FR20

### Epic 6: Town Hub — "Players have a home base"
Players return to town, interact with NPCs, and experience the hub as their base of operations.
**FRs covered:** FR22, FR23, FR24, FR25, FR26

### Epic 7: Save & Persist — "Player progress is never lost"
The game auto-saves and players can resume exactly where they left off.
**FRs covered:** FR28, FR29

### Epic 8: HUD & Game Interface — "Players see what they need"
Players have clear visibility of health, compute, abilities, items, and quests during gameplay.
**FRs covered:** FR9, FR27, FR30

### Epic 9: Demo Build — "A playable demo exists"
A standalone demo covering the full first compaction loop with polish and tutorial flow.
**FRs covered:** FR37

### Epic 10: Procedural Dungeons — "Every run feels different"
Dungeon floors are procedurally assembled from templates, creating variety across runs.
**FRs covered:** FR21

### Epic 11: Full Compaction Cycle — "6 portals, deepening challenge"
Players progress through all 6 compaction loops with escalating difficulty and bosses.
**FRs covered:** FR33, FR38

### Epic 12: The Iteration Loop — "The world resets, but you don't"
Players experience the full iteration system with The User, boss evolution, and NPC awareness across 9 cycles.
**FRs covered:** FR31, FR32, FR34, FR35

### Epic 13: Endless Mode — "The journey continues"
After completing 9 iterations, players unlock endless mode with scaling difficulty and continued progression.
**FRs covered:** FR36

## Epic 1: Project Foundation — "The game launches and runs"

The game project is properly set up with all core systems, folder structure, and autoloads so that all future development has a consistent, working foundation.

### Story 1.1: Project Setup and Folder Structure

As a developer,
I want the Godot 4.4 project initialized with the full folder structure from the architecture spec,
So that all future work has a consistent, organized place to live.

**Acceptance Criteria:**

**Given** a fresh Godot 4.4 project
**When** the folder structure is created
**Then** all directories exist per architecture spec: scenes/ (main, town, dungeon, entities, ui, effects), scripts/ (autoloads, components, state_machines, systems, resources, ui, utils), data/ (items, enemies, npcs, loot_tables, quests, iterations), assets/ (models, textures, audio, fonts, shaders), tests/ (unit, integration)
**And** project.godot is configured with Forward+ renderer
**And** .gitignore excludes .godot/ directory

### Story 1.2: Core Autoloads — GameManager and EventBus

As a developer,
I want GameManager and EventBus autoloads created and registered,
So that game state management and cross-system events work from the start.

**Acceptance Criteria:**

**Given** the project with folder structure
**When** GameManager autoload is created
**Then** it tracks game state (MAIN_MENU, PLAYING, PAUSED, DIALOGUE, INVENTORY) via an enum
**And** it provides pause/unpause functionality
**And** it provides change_scene_to() with threaded loading
**When** EventBus autoload is created
**Then** it declares all core signals (enemy_defeated, item_collected, damage_dealt, player_died, portal_reached, iteration_started, iteration_reset, npc_recruited, quest_updated, dialogue_started, dialogue_ended, scene_changing, scene_changed)
**And** both are registered in project.godot autoloads
**And** all code uses static typing

### Story 1.3: Input Map Configuration

As a player,
I want all game inputs pre-configured in the Input Map,
So that controls work consistently from the first playable moment.

**Acceptance Criteria:**

**Given** the Godot project settings
**When** the Input Map is configured
**Then** these actions exist: move_up, move_down, move_left, move_right, attack_primary (LMB), attack_secondary (RMB), dash (Space), interact (E), ability_1 (1), ability_2 (2), ability_3 (3), ability_4 (4), use_prompt (Q), inventory (Tab/I), pause (Esc)
**And** all actions use StringName references in code

### Story 1.4: Isometric Camera System

As a player,
I want an isometric camera that follows Globbler smoothly,
So that I can see the game world from the correct perspective.

**Acceptance Criteria:**

**Given** a Camera3D node
**When** configured for isometric view
**Then** it uses orthographic projection with 60° X rotation and 45° Z rotation
**And** it smoothly follows a target node (Globbler)
**And** camera follow speed is configurable via @export
**And** camera size/zoom is configurable

### Story 1.5: Main Menu Scene

As a player,
I want a main menu when I launch the game,
So that I can start a new game or quit.

**Acceptance Criteria:**

**Given** the game is launched
**When** the main menu scene loads
**Then** it displays the game title "Enth: Iteration"
**And** it shows "New Game" and "Quit" buttons
**And** clicking "New Game" transitions to the game world
**And** clicking "Quit" closes the application
**And** scene transition uses GameManager.change_scene_to()

### Story 1.6: Base State Machine Framework

As a developer,
I want a reusable StateMachine and State base class,
So that all entities can use consistent state-driven behavior.

**Acceptance Criteria:**

**Given** the state machine architecture from the ADR
**When** StateMachine class is created
**Then** it has @export initial_state, transitions between states via transition_to(), calls update() in _process and physics_update() in _physics_process on current state
**When** State base class is created
**Then** it has virtual methods: enter(), exit(), update(delta), physics_update(delta) and a reference to its state_machine
**And** both use static typing throughout

---

## Epic 2: Globbler Comes Alive — "Players can move and explore"

### Story 2.1: Player Scene Setup

As a player,
I want a controllable character that exists in the game world with proper collision,
So that I have a physical presence that can interact with the environment.

**Acceptance Criteria:**

**Given** the game is launched and a level scene is loaded
**When** the Player scene is instantiated
**Then** a `CharacterBody3D` node named `Player` exists as the scene root
**And** it has a `CollisionShape3D` child with a `CapsuleShape3D` (radius 0.4, height 1.8)
**And** it has a `Node3D` child named `Model` containing a placeholder `MeshInstance3D` (capsule mesh with a distinct material color)
**And** the following empty child nodes exist as composition scaffolding: `HealthComponent` (Node), `ComputeComponent` (Node), `StatsComponent` (Node), `HitboxComponent` (Area3D), `HurtboxComponent` (Area3D), `InventoryComponent` (Node), `AbilityManager` (Node), `InteractionArea` (Area3D), `StateMachine` (Node), `AnimationPlayer`
**And** the Player scene is saved at `res://scenes/player/player.tscn` with script `res://scenes/player/player.gd`
**And** `player.gd` extends `CharacterBody3D` and has `@onready` references to all child components
**And** the Player is on collision layer 1 (Player) and scans mask layers 2 (Enemy), 4 (Environment), 8 (Interaction)

---

### Story 2.2: WASD Isometric Movement

As a player,
I want to move my character with WASD keys in isometric perspective,
So that I can navigate the game world intuitively.

**Acceptance Criteria:**

**Given** the Player scene is instantiated and a `Camera3D` is positioned at an isometric angle (rotation approximately -35 degrees X, 45 degrees Y)
**When** the player presses W, A, S, or D (or any combination)
**Then** the character moves in the corresponding isometric-projected direction relative to the camera
**And** movement input is read via `Input.get_vector("move_left", "move_right", "move_forward", "move_back")`
**And** the raw input vector is rotated by the camera's Y rotation to produce world-space direction
**And** the character moves using `velocity = direction * move_speed` and `move_and_slide()` in `_physics_process`
**And** `move_speed` is an `@export var move_speed: float = 6.0` on `player.gd` (configurable in Inspector)
**And** when no input is pressed, velocity decelerates to zero smoothly (lerp with friction factor 0.2)
**And** the `Model` node rotates to face the movement direction using `lerp_angle` for smooth turning
**And** the input actions `move_left`, `move_right`, `move_forward`, `move_back` are defined in Project Settings → Input Map, mapped to A, D, W, S respectively
**And** diagonal movement is normalized so the player does not move faster diagonally (`direction = direction.normalized()`)

---

### Story 2.3: Teleport Dash with I-Frames

As a player,
I want to teleport-dash with spacebar to quickly reposition and avoid damage,
So that I have a defensive/mobility tool for combat and exploration.

**Acceptance Criteria:**

**Given** the Player is in idle or walk state and the dash cooldown has expired
**When** the player presses spacebar (input action `dash`)
**Then** the player teleports instantly a distance of `dash_distance` (export var, default 4.0 units) in the current facing direction (or movement direction if moving)
**And** during the dash, the player is invulnerable for `iframe_duration` seconds (export var, default 0.3)
**And** invulnerability is implemented by setting `is_invulnerable: bool = true` on the Player, checked by `HurtboxComponent` before applying damage
**And** a `dash_cooldown: float = 1.0` (export var) prevents re-dashing; tracked by a `Timer` node named `DashCooldownTimer`
**And** a placeholder VFX is triggered: the `Model` material flashes transparent (alpha 0.3) during i-frames, then restores to full opacity
**And** `EventBus.player_dashed.emit(global_position, dash_target_position)` is emitted for other systems to react
**And** collision is maintained during teleport — use a `PhysicsTestMotionParameters3D` or raycast to prevent dashing through walls; if the dash target is inside geometry, the player stops at the last valid position
**And** if no movement direction is held, the player dashes in the direction the model is currently facing
**And** the `DashState` in the StateMachine handles the dash logic and transitions back to `IdleState` or `WalkState` after completion

---

### Story 2.4: Player Animation State Machine

As a player,
I want smooth transitions between idle, walk, and dash animations,
So that the character feels responsive and visually communicates its current state.

**Acceptance Criteria:**

**Given** the Player scene has a `StateMachine` node and an `AnimationPlayer`
**When** the game runs
**Then** the `StateMachine` node (script at `res://scripts/state_machine/state_machine.gd`) manages `State` subclasses as child nodes
**And** `state_machine.gd` has: `@export var initial_state: State`, `var current_state: State`, `func _ready()` that initializes `current_state`, `func _physics_process(delta)` that delegates to `current_state.physics_update(delta)`, `func _unhandled_input(event)` that delegates to `current_state.handle_input(event)`, and `func transition_to(target_state_name: String)` that calls `current_state.exit()` then `new_state.enter()`
**And** a base `State` class (script at `res://scripts/state_machine/state.gd`) extends `Node` with virtual methods: `enter()`, `exit()`, `handle_input(event: InputEvent)`, `physics_update(delta: float)`, and a reference `var player: CharacterBody3D`
**And** three state scripts exist as children of `StateMachine`: `IdleState` at `res://scenes/player/states/idle_state.gd`, `WalkState` at `res://scenes/player/states/walk_state.gd`, `DashState` at `res://scenes/player/states/dash_state.gd`
**And** `IdleState` plays idle animation, transitions to `WalkState` when movement input is detected, transitions to `DashState` on dash input
**And** `WalkState` plays walk animation, sets player velocity from input, transitions to `IdleState` when input stops, transitions to `DashState` on dash input
**And** `DashState` plays dash animation, executes teleport logic, transitions back to `IdleState` after `iframe_duration`
**And** placeholder animations are created in `AnimationPlayer`: `idle` (subtle bob/pulse, looping), `walk` (bounce cycle, looping), `dash` (flash effect, one-shot)

---

### Story 2.5: Component Scaffolding

As a developer,
I want empty shell scripts for HealthComponent, ComputeComponent, and StatsComponent attached to the Player,
So that later epics can implement them without restructuring the scene tree.

**Acceptance Criteria:**

**Given** the Player scene exists with placeholder child nodes for each component
**When** the component scripts are created
**Then** `res://scripts/components/health_component.gd` exists, extends `Node`, has `class_name HealthComponent`, and contains stub properties: `@export var max_health: float = 100.0`, `var current_health: float`, signals: `signal health_changed(new_value: float, max_value: float)`, `signal died`, and stub methods: `func take_damage(amount: float) -> void: pass`, `func heal(amount: float) -> void: pass`, `func _ready(): current_health = max_health`
**And** `res://scripts/components/compute_component.gd` exists, extends `Node`, has `class_name ComputeComponent`, and contains stub properties: `@export var max_compute: float = 50.0`, `var current_compute: float`, signals: `signal compute_changed(new_value: float, max_value: float)`, `signal compute_depleted`, and stub methods: `func spend(amount: float) -> bool: return false`, `func restore(amount: float) -> void: pass`, `func _ready(): current_compute = max_compute`
**And** `res://scripts/components/stats_component.gd` exists, extends `Node`, has `class_name StatsComponent`, and contains stub properties: `@export var base_processing: float = 10.0`, `@export var base_bandwidth: float = 10.0`, `@export var base_memory: float = 10.0`, `@export var base_integrity: float = 10.0`, signals: `signal stats_changed`, and stub method: `func get_stat(stat_name: String) -> float: return 0.0`
**And** each script is attached to its corresponding node in the Player scene
**And** an `EventBus` autoload exists at `res://scripts/autoloads/event_bus.gd` (extends `Node`) with placeholder signals: `signal player_dashed(from_pos: Vector3, to_pos: Vector3)`, `signal damage_dealt(target: Node, amount: float)`, `signal enemy_defeated(enemy: Node)`, `signal player_died`
**And** `EventBus` is registered in Project Settings → Autoload

---

## Epic 3: Combat Fundamentals — "Players can fight enemies"

### Story 3.1: HealthComponent Implementation

As a player,
I want my character to have a health resource that responds to damage and healing,
So that combat has stakes and consequences.

**Acceptance Criteria:**

**Given** the `HealthComponent` shell exists on the Player scene
**When** the component is fully implemented
**Then** `take_damage(amount: float)` reduces `current_health` by `amount`, clamped to 0
**And** `take_damage` checks `player.is_invulnerable` (if the parent has that property) and returns early if true
**And** `heal(amount: float)` increases `current_health` by `amount`, clamped to `max_health`
**And** `health_changed` signal emits after every change with `(current_health, max_health)`
**And** when `current_health` reaches 0, the `died` signal is emitted exactly once (guarded by `var is_dead: bool`)
**And** `EventBus.player_died.emit()` is also called on death
**And** a `func reset() -> void` method restores `current_health = max_health` and sets `is_dead = false`
**And** `func get_health_percentage() -> float` returns `current_health / max_health`
**And** the component works when attached to any `CharacterBody3D` (player or enemy) — it uses `get_parent()` for the owner reference

---

### Story 3.2: ComputeComponent Implementation

As a player,
I want a compute (mana) resource that powers my abilities and regenerates slowly,
So that I must manage resources during combat.

**Acceptance Criteria:**

**Given** the `ComputeComponent` shell exists on the Player scene
**When** the component is fully implemented
**Then** `spend(amount: float) -> bool` returns `false` if `current_compute < amount`, otherwise deducts `amount` and returns `true`
**And** `restore(amount: float)` increases `current_compute`, clamped to `max_compute`
**And** `compute_changed` signal emits after every change with `(current_compute, max_compute)`
**And** `compute_depleted` signal emits when `current_compute` reaches 0
**And** passive regeneration is implemented in `_process(delta)`: `current_compute += regen_rate * delta` where `@export var regen_rate: float = 2.0` (per second), clamped to max, emitting `compute_changed` when the value changes by at least 0.1
**And** a `func get_compute_percentage() -> float` returns `current_compute / max_compute`
**And** `max_compute` is recalculated when `StatsComponent.stats_changed` fires: `max_compute = base_max_compute + stats.get_stat("memory") * 5.0`
**And** `func reset() -> void` restores `current_compute = max_compute`

---

### Story 3.3: StatsComponent with Core Stats

As a player,
I want my character to have Processing, Bandwidth, Memory, and Integrity stats that affect gameplay,
So that my build choices and equipment matter.

**Acceptance Criteria:**

**Given** the `StatsComponent` shell exists on the Player scene
**When** the component is fully implemented
**Then** it holds base stats: `base_processing`, `base_bandwidth`, `base_memory`, `base_integrity` (all `@export var`, default 10.0)
**And** it maintains a `var equipment_bonuses: Dictionary = {}` that maps stat names to additive bonus values
**And** `func get_stat(stat_name: String) -> float` returns `base_{stat_name} + level_bonus + equipment_bonuses.get(stat_name, 0.0)` where `level_bonus` = stat points allocated to that stat
**And** `var level_points: Dictionary = {"processing": 0, "bandwidth": 0, "memory": 0, "integrity": 0}` tracks allocated points
**And** `func allocate_point(stat_name: String) -> void` increments `level_points[stat_name]` by 1 and emits `stats_changed`
**And** `func recalculate_equipment_bonuses(equipped_items: Array) -> void` iterates all equipped items, sums their stat modifiers into `equipment_bonuses`, then emits `stats_changed`
**And** stat effects: Processing increases damage output, Bandwidth increases move speed (feeds into `player.move_speed`), Memory increases max compute, Integrity increases max health and reduces damage taken
**And** `func get_all_stats() -> Dictionary` returns a dictionary with all four final stat values

---

### Story 3.4: Data Pulse Basic Attack

As a player,
I want to left-click to perform a quick Data Pulse attack,
So that I have a basic combat action to damage enemies.

**Acceptance Criteria:**

**Given** the Player is in `IdleState`, `WalkState`, or another non-locked state
**When** the player presses left mouse button (input action `attack_primary`)
**Then** the StateMachine transitions to `AttackState`
**And** `AttackState` plays the `attack_primary` animation on `AnimationPlayer` (placeholder: quick forward swing, 0.4 seconds)
**And** during the animation's active frame window (0.1s to 0.3s), the `HitboxComponent` Area3D is enabled with a `CollisionShape3D` (BoxShape3D, size Vector3(1.5, 1.0, 1.5)) positioned in front of the player
**And** when the `HitboxComponent` overlaps an enemy's `HurtboxComponent`, it calls the damage pipeline with a `DamageInfo` resource containing: `source = player`, `base_damage = 5.0 + stats.get_stat("processing") * 1.5`, `damage_type = "data"`, `status_effect = null`
**And** a brief attack cooldown of 0.5 seconds is enforced before another Data Pulse can fire (tracked by a Timer or state logic)
**And** the attack direction is toward the mouse cursor's world-projected position (raycast from camera through mouse position to ground plane)
**And** the player model snaps to face the attack direction when entering `AttackState`
**And** Data Pulse costs no compute (it is the free basic attack)
**And** after the animation finishes, the state machine transitions back to `IdleState` or `WalkState` depending on movement input

---

### Story 3.5: Energy Burst Charged Attack

As a player,
I want to hold right-click to charge and release an Energy Burst for high damage,
So that I have a powerful attack option that costs compute.

**Acceptance Criteria:**

**Given** the Player is in `IdleState` or `WalkState` and has sufficient compute
**When** the player presses and holds right mouse button (input action `attack_secondary`)
**Then** the StateMachine transitions to `ChargeState` (new state)
**And** `ChargeState` tracks `charge_time: float` incrementing in `physics_update(delta)`, clamped to `max_charge_time = 2.0`
**And** a visual indicator shows charge level: the player model's material emission intensity increases from 0 to 1.0 proportional to charge
**And** movement speed is reduced to 50% during charging
**When** the player releases right mouse button
**Then** `AttackState` is entered with `attack_type = "energy_burst"`
**And** damage is calculated: `base_damage = (10.0 + stats.get_stat("processing") * 3.0) * charge_multiplier` where `charge_multiplier = lerp(0.5, 2.0, charge_time / max_charge_time)`
**And** compute cost is `15.0 * charge_multiplier`; if `ComputeComponent.spend()` returns false, the attack fizzles with no damage and a UI feedback flash
**And** the hitbox is larger than Data Pulse: `BoxShape3D` size `Vector3(2.5, 1.0, 2.5)`
**And** the `DamageInfo` resource has `damage_type = "energy"`
**And** a cooldown of 1.5 seconds is enforced after release
**And** if the player is hit during `ChargeState`, the charge is interrupted (transition to `HurtState`), compute is not spent

---

### Story 3.6: Combat State Machine States

As a developer,
I want AttackState, HurtState, and DeathState added to the player StateMachine,
So that combat actions have proper state management.

**Acceptance Criteria:**

**Given** the StateMachine already has `IdleState`, `WalkState`, and `DashState`
**When** combat states are added
**Then** `AttackState` at `res://scenes/player/states/attack_state.gd` handles both Data Pulse and Energy Burst attacks, disables movement input during attack animation, enables/disables HitboxComponent at correct frames, and transitions out on animation end
**And** `ChargeState` at `res://scenes/player/states/charge_state.gd` handles Energy Burst charging, allows reduced movement, transitions to `AttackState` on release or `HurtState` on hit
**And** `HurtState` at `res://scenes/player/states/hurt_state.gd` plays `hurt` animation (0.3s), applies knockback velocity in direction away from damage source, briefly prevents input, transitions to `IdleState` after stun duration or `DeathState` if health is 0
**And** `DeathState` at `res://scenes/player/states/death_state.gd` plays `death` animation, disables all input and collision, emits `EventBus.player_died`, and waits for the respawn system to handle scene transition
**And** all states have a `var can_be_interrupted: bool` — `DashState` and `DeathState` set it to false; `HurtState` can only be interrupted by `DeathState`
**And** state transition priority: `DeathState` > `HurtState` > `DashState` > `AttackState` > `WalkState` > `IdleState`

---

### Story 3.7: Damage Calculation Pipeline

As a developer,
I want a structured damage pipeline that processes damage through modifiers,
So that stats, equipment, and effects all contribute to final damage consistently.

**Acceptance Criteria:**

**Given** a damage event occurs (hitbox overlaps hurtbox)
**When** damage is processed
**Then** a `DamageInfo` Resource class exists at `res://scripts/combat/damage_info.gd` with properties: `source: Node`, `target: Node`, `base_damage: float`, `damage_type: String` (one of "data", "energy", "physical", "status"), `stat_multiplier: float`, `equipment_modifier: float`, `final_damage: float`, `is_critical: bool`, `status_effect: StatusEffect`, `knockback_direction: Vector3`, `knockback_force: float`
**And** a `DamageCalculator` static class at `res://scripts/combat/damage_calculator.gd` has `static func calculate(info: DamageInfo) -> DamageInfo` that executes the pipeline in order:
1. Apply stat multiplier: `damage *= 1.0 + source.stats.get_stat("processing") * 0.1`
2. Apply equipment modifier: `damage *= (1.0 + info.equipment_modifier)`
3. Apply defense: `damage -= target.stats.get_stat("integrity") * 0.5` (clamped to minimum 1.0)
4. Apply status modifiers: if target has `Fragmented` status, `damage *= 1.3`; if source has `Overclocked`, `damage *= 1.5`
5. Critical hit check: 5% base chance + `source.stats.get_stat("processing") * 0.5`%, if critical `damage *= 2.0` and `is_critical = true`
6. Set `final_damage` and return
**And** `EventBus.damage_dealt.emit(info)` fires after calculation with the completed `DamageInfo`

---

### Story 3.8: HitboxComponent and HurtboxComponent

As a developer,
I want reusable hitbox and hurtbox components using Area3D collision,
So that damage detection is consistent and decoupled from character logic.

**Acceptance Criteria:**

**Given** a character (player or enemy) needs to deal or receive damage
**When** hitbox and hurtbox components are implemented
**Then** `HitboxComponent` at `res://scripts/components/hitbox_component.gd` extends `Area3D` with: `@export var damage_source: Node` (the owning character), `var is_active: bool = false`, `func activate() -> void` (enables collision), `func deactivate() -> void` (disables collision and clears hit tracking), and a `var hit_targets: Array` that prevents hitting the same target twice per activation
**And** `HitboxComponent` is on collision layer 6 (Hitbox) and scans mask layer 7 (Hurtbox)
**And** `HurtboxComponent` at `res://scripts/components/hurtbox_component.gd` extends `Area3D` with: `signal hit_received(damage_info: DamageInfo)`, `var owner_entity: Node` (set in `_ready` to `get_parent()`), and `func _on_area_entered(hitbox: Area3D)` that creates a `DamageInfo`, runs it through `DamageCalculator.calculate()`, and emits `hit_received`
**And** `HurtboxComponent` is on collision layer 7 (Hurtbox) and scans no layers (it is passive; hitboxes detect it)
**And** `HurtboxComponent._on_area_entered` checks `hitbox.is_active` and `hitbox.damage_source != owner_entity` (no self-damage)
**And** `HurtboxComponent` checks `owner_entity.is_invulnerable` if the property exists, skipping damage if true
**And** both components are reusable: they work on any `CharacterBody3D` parent that has `HealthComponent` and `StatsComponent`

---

### Story 3.9: Enemy Base Scene with AI State Machine

As a developer,
I want a base enemy scene with an AI state machine,
So that all enemies share common structure and behavior patterns.

**Acceptance Criteria:**

**Given** the combat system components exist (HealthComponent, HitboxComponent, HurtboxComponent, StatsComponent)
**When** the enemy base scene is created
**Then** `res://scenes/enemies/enemy_base.tscn` has root `CharacterBody3D` named `EnemyBase` with script `res://scenes/enemies/enemy_base.gd`
**And** child nodes include: `CollisionShape3D`, `Model` (Node3D with placeholder MeshInstance3D), `HealthComponent`, `StatsComponent`, `HitboxComponent` (Area3D), `HurtboxComponent` (Area3D), `StateMachine`, `AnimationPlayer`, `NavigationAgent3D`, `DetectionArea` (Area3D, sphere radius 10.0 for aggro range)
**And** `EnemyBase` is on collision layer 2 (Enemy) and scans mask layer 1 (Player), 4 (Environment)
**And** the enemy AI StateMachine has states: `EnemyIdleState`, `EnemyPatrolState`, `EnemyChaseState`, `EnemyAttackState`, `EnemyHurtState`, `EnemyDeathState` at `res://scenes/enemies/states/`
**And** `EnemyIdleState` waits for `idle_time` seconds then transitions to `EnemyPatrolState`
**And** `EnemyPatrolState` picks a random point within `patrol_radius` and navigates to it, transitions to `EnemyChaseState` when Player enters `DetectionArea`
**And** `EnemyChaseState` navigates toward the Player's position, transitions to `EnemyAttackState` when within `attack_range`, transitions back to `EnemyPatrolState` if Player leaves detection range for `leash_time` seconds (default 5.0)
**And** `EnemyAttackState` performs the enemy's attack, then transitions to `EnemyChaseState`
**And** `EnemyHurtState` plays hurt animation, applies knockback, transitions back to `EnemyChaseState`
**And** `EnemyDeathState` plays death animation, emits `EventBus.enemy_defeated.emit(self)`, triggers loot drop, then calls `queue_free()` (or returns to pool)
**And** `enemy_base.gd` has exports: `@export var patrol_radius: float = 5.0`, `@export var attack_range: float = 2.0`, `@export var leash_time: float = 5.0`

---

### Story 3.10: Glitch Bug Enemy Type

As a player,
I want to encounter Glitch Bug enemies that attack in melee range,
So that I face a simple, readable threat that teaches basic combat.

**Acceptance Criteria:**

**Given** the enemy base scene and AI state machine exist
**When** the Glitch Bug enemy is created
**Then** `res://scenes/enemies/glitch_bug/glitch_bug.tscn` inherits from `enemy_base.tscn`
**And** its `Model` uses a distinct placeholder mesh (small sphere, radius 0.5, red-tinted material)
**And** base stats: `health = 30.0`, `processing = 5.0`, `bandwidth = 4.0`, `memory = 0`, `integrity = 2.0`
**And** `attack_range = 1.5`, `patrol_radius = 4.0`, movement speed `= 3.5`
**And** `GlitchBugAttackState` extends `EnemyAttackState`: plays a 0.6s lunge animation with a 0.3s telegraph (red flash), activates hitbox for 0.2s at peak, deals `8.0` base damage
**And** attack cooldown is 1.5 seconds between attacks
**And** the attack is well-telegraphed: the Glitch Bug pauses and flashes before lunging, giving the player 0.3s to react (dash away)
**And** drops loot from `glitch_bug_loot_table` (defined as a Resource, populated in Epic 4)
**And** awards `10` XP on death via `EventBus.enemy_defeated`

---

### Story 3.11: Memory Leak Enemy Type

As a player,
I want to encounter Memory Leak enemies that attack from range with slow projectiles,
So that I face a ranged threat that requires different tactics.

**Acceptance Criteria:**

**Given** the enemy base scene and AI state machine exist
**When** the Memory Leak enemy is created
**Then** `res://scenes/enemies/memory_leak/memory_leak.tscn` inherits from `enemy_base.tscn`
**And** its `Model` uses a placeholder mesh (flat cylinder/disc, radius 0.8, green-tinted material with transparency)
**And** base stats: `health = 20.0`, `processing = 8.0`, `bandwidth = 2.0`, `memory = 0`, `integrity = 1.0`
**And** `attack_range = 8.0`, `patrol_radius = 3.0`, movement speed `= 2.0`
**And** `MemoryLeakAttackState` spawns a projectile scene `res://scenes/enemies/memory_leak/leak_projectile.tscn` — an `Area3D` with `CollisionShape3D` (SphereShape3D radius 0.3), moves in a straight line toward the player's position at fire time, speed 5.0, lifetime 4.0 seconds
**And** the projectile has a `HitboxComponent` that deals `12.0` base damage on contact with the player's `HurtboxComponent`
**And** the projectile leaves a damaging pool on impact or expiry: an `Area3D` (radius 1.5, lasts 3.0s) that deals `3.0` damage per second to the player if they stand in it
**And** attack cooldown is 2.5 seconds; telegraph is a 0.5s glow/pulsate before firing
**And** the Memory Leak tries to maintain distance: if the player is closer than 4.0 units, it retreats in `EnemyChaseState` (flee behavior)
**And** awards `15` XP on death

---

### Story 3.12: Rogue Process Enemy Type

As a player,
I want to encounter Rogue Process enemies that are fast and aggressive,
So that I face a high-pressure threat that tests my dash timing.

**Acceptance Criteria:**

**Given** the enemy base scene and AI state machine exist
**When** the Rogue Process enemy is created
**Then** `res://scenes/enemies/rogue_process/rogue_process.tscn` inherits from `enemy_base.tscn`
**And** its `Model` uses a placeholder mesh (elongated box, blue-tinted material)
**And** base stats: `health = 25.0`, `processing = 7.0`, `bandwidth = 8.0`, `memory = 0`, `integrity = 3.0`
**And** `attack_range = 2.0`, `patrol_radius = 6.0`, movement speed `= 6.0`
**And** `RogueProcessAttackState` has two attack patterns alternated:
1. Dash strike: teleports toward the player (dash 3.0 units), dealing `10.0` damage in a line hitbox. Telegraph: 0.4s wind-up with directional indicator.
2. Flurry: three rapid strikes over 1.0s, each dealing `5.0` damage with a smaller hitbox. Telegraph: 0.3s stance change.
**And** attack cooldown is 1.0 seconds (fast attacker)
**And** `EnemyChaseState` override: Rogue Process moves in erratic zigzag pattern (offset perpendicular to chase direction sinusoidally) making it harder to hit
**And** when health drops below 30%, enters an `EnragedState` that increases movement speed by 50% and reduces attack cooldown by 30%
**And** awards `20` XP on death

---

### Story 3.13: Enemy Spawner and Object Pool

As a developer,
I want an enemy spawner with object pooling,
So that rooms can spawn enemies efficiently without runtime allocation spikes.

**Acceptance Criteria:**

**Given** enemy scenes exist and rooms need to populate with enemies
**When** the spawner system is implemented
**Then** `res://scripts/systems/enemy_pool.gd` extends `Node` with `class_name EnemyPool` and is added as an autoload
**And** `EnemyPool` pre-instantiates enemies on `_ready()`: `@export var pool_sizes: Dictionary = {"glitch_bug": 10, "memory_leak": 5, "rogue_process": 5}`
**And** `func get_enemy(type: String) -> CharacterBody3D` returns an inactive enemy from the pool, marks it active, and calls `enemy.reset()` to restore health/state; if pool is empty, instantiates a new one (with a warning log)
**And** `func return_enemy(enemy: CharacterBody3D) -> void` deactivates the enemy, resets its position off-screen, and returns it to the pool
**And** enemies call `EnemyPool.return_enemy(self)` in `EnemyDeathState` after the death animation completes (instead of `queue_free()`)
**And** `EnemySpawner` node (`res://scripts/systems/enemy_spawner.gd`, extends `Node3D`) is placed in rooms with: `@export var enemy_types: Array[String]`, `@export var spawn_count: int`, `@export var spawn_points: Array[Marker3D]`, and `func spawn_wave() -> void` that distributes enemies across spawn points
**And** `EnemySpawner` emits `signal all_enemies_defeated` when all spawned enemies in the current wave are dead (tracked via `EventBus.enemy_defeated` connections)

---

### Story 3.14: Status Effect System

As a developer,
I want a status effect system that applies, ticks, and removes timed effects on characters,
So that combat has depth through conditions like damage-over-time and debuffs.

**Acceptance Criteria:**

**Given** characters have `HealthComponent` and `StatsComponent`
**When** the status effect system is implemented
**Then** `StatusEffect` Resource at `res://scripts/combat/status_effect.gd` has: `@export var effect_name: String`, `@export var duration: float`, `@export var tick_rate: float` (seconds between ticks), `@export var effect_type: String` (one of "corrupted", "fragmented", "throttled", "overclocked", "segfault"), and `@export var potency: float`
**And** a `StatusEffectManager` component at `res://scripts/components/status_effect_manager.gd` extends `Node` with: `var active_effects: Array[Dictionary]` (each entry: `{effect: StatusEffect, remaining_duration: float, tick_timer: float}`), `func apply_effect(effect: StatusEffect) -> void`, `func remove_effect(effect_name: String) -> void`, `func has_effect(effect_name: String) -> bool`, `func _process(delta)` that ticks all active effects
**And** effect behaviors:
- `corrupted`: deals `potency` damage per tick to `HealthComponent` (DOT)
- `fragmented`: sets a flag reducing defense by `potency`% (checked in `DamageCalculator`)
- `throttled`: reduces `bandwidth` stat by `potency`% (affects movement speed)
- `overclocked`: increases `processing` stat by `potency`% but deals `potency * 0.5` self-damage per tick
- `segfault`: sets a `is_stunned` flag that prevents all state transitions except `DeathState`
**And** `StatusEffectManager` is added as a child of both Player and EnemyBase scenes
**And** visual indicator: when any effect is active, a `Label3D` above the character shows the effect icon/name (placeholder text)
**And** `signal effect_applied(effect_name: String)` and `signal effect_removed(effect_name: String)` are emitted for UI and VFX hooks

---

### Story 3.15: Death and Respawn Flow

As a player,
I want to respawn in town when I die with an item degradation penalty,
So that death has consequences but does not end my run permanently.

**Acceptance Criteria:**

**Given** the Player's `HealthComponent` emits `died` and `DeathState` is entered
**When** the death sequence completes
**Then** `EventBus.player_died.emit()` is emitted from `DeathState`
**And** a `RespawnManager` (script at `res://scripts/systems/respawn_manager.gd`, connected to `EventBus.player_died`) handles the flow:
1. Waits for the death animation to finish (1.0s)
2. Fades the screen to black using a `ColorRect` overlay with a `Tween` (0.5s fade)
3. Emits `EventBus.item_degradation_triggered.emit()` (handled by `InventoryComponent` in Epic 4)
4. Calls `GameManager.load_scene("res://scenes/town/town.tscn")`
5. Positions the player at the town spawn point `Marker3D` named `RespawnPoint`
6. Calls `player.health_component.reset()` and `player.compute_component.reset()`
7. Fades screen back in (0.5s)
**And** `GameManager` autoload at `res://scripts/autoloads/game_manager.gd` has `func load_scene(path: String) -> void` using `get_tree().change_scene_to_file(path)` or `get_tree().change_scene_to_packed()`
**And** dungeon progress (current floor) is lost on death — the player must re-enter the dungeon from floor 1
**And** the player retains all items, XP, and NPC progress (only degradation is the penalty)

---

## Epic 4: Loot & Equipment — "Players find and equip gear"

### Story 4.1: ItemBase Resource and Subclasses

As a developer,
I want a data-driven item system using Godot Resources,
So that items are defined as `.tres` files and new items can be added without code changes.

**Acceptance Criteria:**

**Given** the game needs an item system
**When** the item Resource classes are created
**Then** `res://scripts/items/item_base.gd` extends `Resource` with `class_name ItemBase` and properties: `@export var item_name: String`, `@export var item_id: String` (unique identifier), `@export var description: String`, `@export var icon: Texture2D`, `@export var rarity: int` (0=Common, 1=Uncommon, 2=Rare, 3=Legendary), `@export var item_type: String` (one of "chip", "module", "core", "protocol", "prompt"), `@export var grid_size: Vector2i = Vector2i(1, 1)`, `@export var stat_modifiers: Dictionary = {}` (maps stat name to float bonus), `@export var max_durability: float = 100.0`, `var current_durability: float = 100.0`
**And** `ChipItem` at `res://scripts/items/chip_item.gd` extends `ItemBase` with: `@export var chip_slot_type: String` (e.g., "offense", "defense", "utility", "passive"), `@export var passive_effect: String`
**And** `ModuleItem` at `res://scripts/items/module_item.gd` extends `ItemBase` with: `@export var ability_scene: PackedScene`, `@export var compute_cost: float`, `@export var cooldown: float`, `@export var ability_name: String`, `@export var ability_description: String`
**And** `CoreItem` at `res://scripts/items/core_item.gd` extends `ItemBase` with: `@export var core_passive: String`, `@export var core_bonus_stats: Dictionary = {}`
**And** `ProtocolItem` at `res://scripts/items/protocol_item.gd` extends `ItemBase` with: `@export var protocol_effect: String`, `@export var protocol_trigger: String` (e.g., "on_hit", "on_kill", "on_dash")
**And** `PromptItem` at `res://scripts/items/prompt_item.gd` extends `ItemBase` with: `@export var prompt_type: String` (one of "health", "compute", "buff"), `@export var restore_amount: float`, `@export var buff_duration: float`, `@export var max_stack: int = 20`, `@export var is_consumable: bool = true`

---

### Story 4.2: Rarity System and Affix Generation

As a developer,
I want items to roll random affixes based on rarity,
So that loot feels varied and exciting to discover.

**Acceptance Criteria:**

**Given** `ItemBase` and its subclasses exist
**When** the rarity and affix system is implemented
**Then** `res://scripts/items/affix_database.gd` extends `Resource` with `class_name AffixDatabase` and holds: `@export var affixes: Array[AffixDefinition]`
**And** `AffixDefinition` at `res://scripts/items/affix_definition.gd` extends `Resource` with: `@export var affix_name: String`, `@export var stat_name: String`, `@export var min_value: float`, `@export var max_value: float`, `@export var min_rarity: int` (minimum rarity that can roll this affix), `@export var allowed_item_types: Array[String]`
**And** `res://scripts/items/item_generator.gd` has `class_name ItemGenerator` with `static func generate_item(base_item: ItemBase, rarity_override: int = -1) -> ItemBase`:
1. Duplicate the base item resource
2. Determine rarity (use override or roll weighted random: Common 60%, Uncommon 25%, Rare 12%, Legendary 3%)
3. Roll affixes based on rarity: Common = 0-1, Uncommon = 1-2, Rare = 2-3, Legendary = 3-4 affixes
4. For each affix slot, pick a random eligible affix from the database, roll a value within `min_value` to `max_value`, add it to `stat_modifiers`
5. Scale base stats by rarity multiplier: Common 1.0x, Uncommon 1.2x, Rare 1.5x, Legendary 2.0x
6. Return the generated item
**And** a default `AffixDatabase` `.tres` file exists at `res://data/items/affix_database.tres` with at least 10 affixes covering all four stats and utility bonuses (cooldown reduction, regen rate, etc.)

---

### Story 4.3: InventoryComponent

As a player,
I want a grid-based inventory that stores my items,
So that I can carry loot and manage my gear.

**Acceptance Criteria:**

**Given** the Player scene has an `InventoryComponent` node
**When** the inventory system is implemented
**Then** `res://scripts/components/inventory_component.gd` extends `Node` with `class_name InventoryComponent`
**And** it has `@export var grid_width: int = 10` and `@export var grid_height: int = 6`
**And** internally it uses a `var grid: Array` (2D array of `ItemBase` or null) representing occupied cells
**And** `func add_item(item: ItemBase) -> bool` finds the first available grid position where `item.grid_size` fits, places the item, and returns true; returns false if no space
**And** `func remove_item(item: ItemBase) -> void` clears the grid cells occupied by the item
**And** `func has_space_for(item: ItemBase) -> bool` checks if the item can fit anywhere
**And** `func get_items() -> Array[ItemBase]` returns all unique items in the inventory
**And** `func get_item_at(grid_pos: Vector2i) -> ItemBase` returns the item at a given grid cell
**And** `signal inventory_changed` emits whenever items are added or removed (for UI updates)
**And** `signal item_added(item: ItemBase)` and `signal item_removed(item: ItemBase)` emit for specific events

---

### Story 4.4: Equipment System

As a player,
I want to equip and unequip items into specific gear slots,
So that my equipment affects my character stats and abilities.

**Acceptance Criteria:**

**Given** `InventoryComponent` and `StatsComponent` exist on the Player
**When** the equipment system is implemented
**Then** `res://scripts/components/equipment_component.gd` extends `Node` with `class_name EquipmentComponent`
**And** it has slot definitions: `var module_slots: Array[ModuleItem] = [null, null, null, null]` (4 slots), `var core_slot: CoreItem = null` (1 slot), `var chip_slots: Array[ChipItem] = [null, null, null, null]` (4 slots), `var protocol_slots: Array[ProtocolItem] = [null, null, null]` (3 slots)
**And** `func equip(item: ItemBase, slot_index: int = -1) -> ItemBase` places the item in the correct slot array based on `item.item_type`, returns the previously equipped item (or null), and triggers stat recalculation
**And** `func unequip(item_type: String, slot_index: int) -> ItemBase` removes and returns the item from the specified slot
**And** after any equip/unequip, calls `stats_component.recalculate_equipment_bonuses(get_all_equipped_items())`
**And** `func get_all_equipped_items() -> Array[ItemBase]` returns a flat array of all non-null equipped items
**And** `signal equipment_changed` emits after any equip/unequip
**And** when a `ModuleItem` is equipped, `AbilityManager` is notified to bind the module's ability to the corresponding key (1-4 matching slot index)
**And** `EquipmentComponent` is added as a child of the Player scene

---

### Story 4.5: AbilityManager with Module Abilities

As a player,
I want my equipped Modules to grant abilities on keys 1-4,
So that I can use special attacks and skills from my gear.

**Acceptance Criteria:**

**Given** `EquipmentComponent` has module slots and `ModuleItem` has an `ability_scene` PackedScene
**When** the AbilityManager is implemented
**Then** `res://scripts/components/ability_manager.gd` extends `Node` with `class_name AbilityManager`
**And** it maintains `var ability_slots: Array[Dictionary] = [{}, {}, {}, {}]` where each dict holds: `module: ModuleItem`, `cooldown_timer: float`, `is_ready: bool`
**And** it listens to `EquipmentComponent.equipment_changed` to refresh ability bindings
**And** `func refresh_abilities(modules: Array[ModuleItem]) -> void` updates `ability_slots` from the current module equipment
**And** in `_unhandled_input(event)`, it checks for input actions `ability_1` through `ability_4` (mapped to keys 1-4)
**And** when an ability key is pressed and the slot has a module and `is_ready` is true:
1. Check `ComputeComponent.spend(module.compute_cost)` — if false, show "Not enough compute" feedback and return
2. Instantiate the `module.ability_scene` and add it to the scene tree as a child of the Player
3. Start the cooldown: set `is_ready = false`, after `module.cooldown` seconds set `is_ready = true`
**And** `signal ability_used(slot_index: int, module: ModuleItem)` emits for HUD cooldown display
**And** `signal ability_ready(slot_index: int)` emits when cooldown finishes
**And** ability scenes are self-contained: they handle their own hitbox, VFX, and lifetime, then `queue_free()` themselves

---

### Story 4.6: Loot Drop System

As a player,
I want enemies to drop items when they die,
So that combat is rewarded with loot.

**Acceptance Criteria:**

**Given** enemies have loot tables and the item generation system exists
**When** an enemy enters `EnemyDeathState`
**Then** the enemy's `LootDropper` component (`res://scripts/components/loot_dropper.gd`, extends `Node`) reads from `@export var loot_table: LootTable`
**And** `LootTable` Resource at `res://scripts/items/loot_table.gd` has: `@export var entries: Array[LootTableEntry]`, where `LootTableEntry` extends `Resource` with: `@export var item_base: ItemBase`, `@export var drop_chance: float` (0.0 to 1.0), `@export var min_quantity: int = 1`, `@export var max_quantity: int = 1`
**And** `LootDropper.drop_loot(global_pos: Vector3) -> void` iterates entries, rolls against `drop_chance`, generates items via `ItemGenerator.generate_item()`, and for each dropped item, instantiates a `DroppedItem` scene in the world at the enemy's position with random scatter offset (1.0-2.0 units radius)
**And** Prompt items (health/compute potions) have a guaranteed drop chance from a universal Prompt sub-table (30% chance for one prompt per enemy kill)
**And** `LootDropper` is added as a child of `EnemyBase` scene

---

### Story 4.7: Item Pickup in World

As a player,
I want to see and pick up items dropped on the ground,
So that I can collect my loot rewards.

**Acceptance Criteria:**

**Given** items are dropped in the world by `LootDropper`
**When** a `DroppedItem` scene exists near the player
**Then** `res://scenes/items/dropped_item.tscn` has root `Area3D` named `DroppedItem` with: `CollisionShape3D` (SphereShape3D radius 1.0 for pickup range), `MeshInstance3D` (small box placeholder, material color based on rarity: white/green/blue/gold), `Label3D` (shows item name, floats above mesh)
**And** script `res://scenes/items/dropped_item.gd` holds `var item: ItemBase`, sets the mesh color and label text in `_ready()`
**And** when the Player's `InteractionArea` overlaps `DroppedItem`, a proximity tooltip appears as a `Label3D` showing item name, rarity, and "Press E to pick up"
**And** when the player presses E (input action `interact`) while overlapping a `DroppedItem`:
1. Calls `player.inventory_component.add_item(item)`
2. If successful, `queue_free()` the `DroppedItem` and play a pickup sound placeholder
3. If inventory is full, show "Inventory Full" feedback text
**And** dropped items persist in the scene for 60 seconds, then auto-despawn with a fade-out
**And** dropped items bob up and down slightly (sine wave on Y position, amplitude 0.1, frequency 2.0)

---

### Story 4.8: Item Degradation on Death

As a player,
I want my equipped items to lose some stats when I die,
So that death has a meaningful penalty that encourages careful play.

**Acceptance Criteria:**

**Given** `EventBus.item_degradation_triggered` is emitted on player death (from Story 3.15)
**When** the degradation system processes
**Then** `EquipmentComponent` connects to `EventBus.item_degradation_triggered`
**And** on trigger, selects 1-3 random equipped items (non-null) from all equipment slots
**And** for each selected item, reduces `current_durability` by 10% of `max_durability`
**And** if `current_durability` falls below thresholds, stat modifiers are reduced: below 50% durability = stats reduced by 25%, below 25% durability = stats reduced by 50%, at 0% durability = item grants no stat bonuses (but remains equipped)
**And** `func get_effective_stat_modifiers() -> Dictionary` on `ItemBase` returns stat modifiers scaled by durability percentage
**And** `StatsComponent.recalculate_equipment_bonuses()` uses `get_effective_stat_modifiers()` instead of raw `stat_modifiers`
**And** a visual indicator appears on degraded items: a durability bar in the inventory UI (green > 50%, yellow 25-50%, red < 25%)
**And** items can be repaired (placeholder: future NPC service, for demo just add a `func repair() -> void` that restores to `max_durability`)

---

### Story 4.9: Prompt Consumable System

As a player,
I want to use Health Prompts and Compute Prompts from a hotbar,
So that I can heal and restore mana during combat.

**Acceptance Criteria:**

**Given** `PromptItem` resources exist and the player has collected some
**When** the consumable system is implemented
**Then** `InventoryComponent` has a `var prompt_hotbar: Array[Dictionary] = []` where each entry is `{item: PromptItem, quantity: int}`
**And** only one prompt type is active at a time on the hotbar; pressing Tab cycles through available prompt types (or auto-selects the first available)
**And** pressing Q (input action `use_prompt`) consumes the active prompt:
- `"health"` type: calls `HealthComponent.heal(item.restore_amount)`
- `"compute"` type: calls `ComputeComponent.restore(item.restore_amount)`
- `"buff"` type: applies a `StatusEffect` (Overclocked) for `item.buff_duration` seconds via `StatusEffectManager`
**And** quantity decreases by 1; when quantity reaches 0 the prompt type is removed from the hotbar
**And** `signal prompt_used(prompt_type: String, remaining: int)` emits for HUD update
**And** a brief usage cooldown of 0.5 seconds prevents spam
**And** prompts cannot be used during `DashState` or `DeathState`

---

### Story 4.10: Demo Item Content

As a player,
I want a variety of items available in the demo,
So that loot drops feel rewarding and I can experiment with builds.

**Acceptance Criteria:**

**Given** all item Resource classes and the affix system exist
**When** demo item `.tres` files are created
**Then** the following items exist as `.tres` Resources in `res://data/items/`:
**Chips (3):**
1. `chip_overclocker.tres` — Uncommon, +3 Processing, chip_slot_type "offense"
2. `chip_firewall.tres` — Common, +2 Integrity, chip_slot_type "defense"
3. `chip_bandwidth_booster.tres` — Rare, +5 Bandwidth, chip_slot_type "utility"
**Modules (3):**
4. `module_logic_bomb.tres` — Rare, ability_scene points to a logic bomb AoE placeholder scene, compute_cost 20, cooldown 5.0
5. `module_packet_storm.tres` — Uncommon, ability_scene points to a rapid-fire projectile placeholder, compute_cost 12, cooldown 3.0
6. `module_defrag_pulse.tres` — Common, ability_scene points to a self-heal pulse placeholder, compute_cost 15, cooldown 8.0
**Cores (2):**
7. `core_standard_cpu.tres` — Common, core_bonus_stats: {processing: 2, integrity: 2}
8. `core_overtuned_gpu.tres` — Rare, core_bonus_stats: {processing: 6, memory: 4}, core_passive "10% critical hit bonus"
**Protocols (2):**
9. `protocol_on_kill_heal.tres` — Uncommon, protocol_trigger "on_kill", protocol_effect "heal 5% max health"
10. `protocol_dash_damage.tres` — Rare, protocol_trigger "on_dash", protocol_effect "deal 15 damage to nearby enemies"
**Prompts (3):**
11. `prompt_health_small.tres` — Common, prompt_type "health", restore_amount 30.0, max_stack 10
12. `prompt_compute_small.tres` — Common, prompt_type "compute", restore_amount 20.0, max_stack 10
13. `prompt_overclock.tres` — Uncommon, prompt_type "buff", buff_duration 10.0, max_stack 5
**And** each item has a placeholder icon (colored rectangle matching rarity) and a description
**And** loot tables for each enemy type are populated: Glitch Bug drops chips/prompts, Memory Leak drops modules/protocols, Rogue Process drops cores/chips

---

## Epic 5: The First Dungeon — "Players explore dungeon floors"

### Story 5.1: Room Base Scene Template

As a developer,
I want a standardized room template with entry/exit points and spawn markers,
So that all rooms share consistent structure and can be loaded interchangeably.

**Acceptance Criteria:**

**Given** the dungeon needs modular room construction
**When** the room base template is created
**Then** `res://scenes/dungeon/rooms/room_base.tscn` has root `Node3D` named `RoomBase` with script `res://scenes/dungeon/rooms/room_base.gd`
**And** child nodes include: `Geometry` (Node3D, holds floor/wall/ceiling MeshInstance3D or CSG nodes), `EntryPoint` (Marker3D, where the player spawns when entering), `ExitPoint` (Marker3D, where the transition trigger is placed), `SpawnPoints` (Node3D, container for Marker3D children used for enemy/item placement), `ExitTrigger` (Area3D at ExitPoint that detects player overlap)
**And** `room_base.gd` has: `@export var room_type: String` (one of "combat", "loot", "corridor", "story"), `@export var room_name: String`, `signal room_cleared`, `signal player_at_exit`, `var is_cleared: bool = false`
**And** `ExitTrigger.body_entered` connects to a function that emits `player_at_exit` only if `is_cleared == true`
**And** for combat rooms, `is_cleared` becomes true when all enemies are defeated (connected to `EnemySpawner.all_enemies_defeated`); for other room types, `is_cleared` is true by default
**And** room geometry uses a consistent scale: floor tiles are 2x2 units, rooms are built in multiples of this grid
**And** placeholder geometry: floor is a gray plane, walls are dark gray boxes, ceiling is optional

---

### Story 5.2: Combat Room Variants

As a player,
I want varied combat rooms with different layouts and enemy placements,
So that encounters feel fresh and tactically interesting.

**Acceptance Criteria:**

**Given** the room base template and enemy spawner exist
**When** combat room variants are created
**Then** 4 combat room scenes exist at `res://scenes/dungeon/rooms/combat/`:
1. `combat_open_arena.tscn` — Open rectangular room (20x16 units), 4 spawn points in corners, no cover, simple fight. Enemy count: 3-5.
2. `combat_pillars.tscn` — Square room (16x16 units) with 4 destructible pillar obstacles (StaticBody3D with health), spawn points behind pillars. Enemy count: 4-6.
3. `combat_corridor_ambush.tscn` — Long narrow room (24x8 units), enemies spawn ahead and behind the player entry. Enemy count: 3-4.
4. `combat_elevated.tscn` — Room with raised platforms (CSG ramps), ranged enemies on platforms, melee on ground. Enemy count: 4-5.
**And** each room has an `EnemySpawner` node configured with appropriate `enemy_types`, `spawn_count`, and `spawn_points`
**And** doors/barriers at the exit are visually blocked (placeholder red barrier mesh) until `room_cleared` is emitted, then the barrier disappears
**And** each room's geometry includes at least basic collision on walls and obstacles

---

### Story 5.3: Loot Room

As a player,
I want to find loot rooms with containers that drop items when opened,
So that exploration is rewarded between combat encounters.

**Acceptance Criteria:**

**Given** the room base template and item drop system exist
**When** loot rooms are created
**Then** `res://scenes/dungeon/rooms/loot/loot_room.tscn` inherits from `room_base.tscn` with `room_type = "loot"` and `is_cleared = true` (no combat required)
**And** it contains 1-3 `Container` nodes (`res://scenes/dungeon/interactables/container.tscn`): `Area3D` root with `CollisionShape3D`, `MeshInstance3D` (box placeholder), `InteractionArea` overlap zone
**And** `container.gd` has: `@export var loot_table: LootTable`, `@export var is_opened: bool = false`, `signal opened`
**And** when the player presses E while overlapping the container's `InteractionArea` and `is_opened == false`:
1. Set `is_opened = true`
2. Play open animation (placeholder: mesh Y-scale reduces to simulate lid opening)
3. Call `LootDropper`-like logic to spawn 1-3 `DroppedItem` scenes above the container
4. Emit `opened` signal
**And** opened containers remain open (visual state persists) and cannot be re-opened
**And** loot room geometry is smaller (12x12 units) with atmospheric placeholder props

---

### Story 5.4: Corridor Room Variants

As a player,
I want corridor rooms connecting other rooms,
So that the dungeon has spatial flow and breathing space between encounters.

**Acceptance Criteria:**

**Given** the room base template exists
**When** corridor variants are created
**Then** 3 corridor scenes exist at `res://scenes/dungeon/rooms/corridor/`:
1. `corridor_straight.tscn` — Straight hallway (20x6 units), no enemies, `is_cleared = true`. Placeholder environmental props (pipes, debris meshes).
2. `corridor_turn.tscn` — L-shaped hallway, two segments of 12x6 units. Minor environmental storytelling props.
3. `corridor_wide.tscn` — Wide open connection (16x12 units) with optional side alcove containing a single container (small loot opportunity).
**And** all corridors have `room_type = "corridor"` and `is_cleared = true`
**And** entry and exit points are at opposite ends/sides of the corridor, placed so FloorManager can chain them
**And** corridors use the same collision and geometry conventions as combat rooms

---

### Story 5.5: Story Room

As a player,
I want to encounter NPC story rooms in the dungeon,
So that I can discover recruitable characters and advance the narrative.

**Acceptance Criteria:**

**Given** the room base template and dialogue system exist (Epic 6)
**When** story rooms are created
**Then** `res://scenes/dungeon/rooms/story/story_room.tscn` inherits from `room_base.tscn` with `room_type = "story"` and `is_cleared = true`
**And** it contains a `Marker3D` named `NPCSpawnPoint` where the NPC is placed
**And** `story_room.gd` has `@export var npc_scene: PackedScene` and instantiates the NPC at the spawn point on `_ready()`
**And** the room geometry is a smaller, distinct space (10x10 units) with unique placeholder props suggesting a safe area (different floor color, ambient lighting placeholder)
**And** the exit only becomes active after the player has interacted with the NPC at least once (talked, which sets `has_interacted = true` and unlocks the `ExitTrigger`)
**And** when the player talks to the NPC in the dungeon, `EventBus.npc_recruited.emit(npc_id: String)` fires, flagging that NPC to appear in town later

---

### Story 5.6: FloorManager

As a developer,
I want a FloorManager that loads rooms in sequence and handles transitions between them,
So that dungeon floors play as connected room sequences.

**Acceptance Criteria:**

**Given** room scenes exist as PackedScenes
**When** the FloorManager is implemented
**Then** `res://scripts/systems/floor_manager.gd` extends `Node` with `class_name FloorManager`, added as a child of the dungeon scene
**And** it has: `@export var floor_data: FloorData` where `FloorData` (`res://scripts/dungeon/floor_data.gd`) extends Resource with `@export var floor_name: String`, `@export var floor_number: int`, `@export var room_sequence: Array[PackedScene]`
**And** `var current_room_index: int = 0`, `var current_room: Node3D = null`
**And** `func load_floor(data: FloorData) -> void` sets `floor_data = data`, `current_room_index = 0`, and calls `load_room(0)`
**And** `func load_room(index: int) -> void`:
1. If `current_room` exists, free it
2. Instantiate `floor_data.room_sequence[index]`
3. Add as child of dungeon scene
4. Move player to the room's `EntryPoint` position
5. Connect room's `player_at_exit` signal to `_on_room_exit`
**And** `func _on_room_exit() -> void`: increments `current_room_index`; if index < room count, calls `load_room(current_room_index)`; otherwise emits `signal floor_completed`
**And** `floor_completed` triggers `EventBus.floor_completed.emit(floor_number)` which the auto-save system will listen to
**And** a brief transition effect plays between rooms (0.3s fade to black, load, 0.3s fade in)

---

### Story 5.7: Demo Floor 1 — Tutorial Floor

As a new player,
I want the first floor to teach me game mechanics one at a time,
So that I understand how to play before facing real challenges.

**Acceptance Criteria:**

**Given** FloorManager and all room types exist
**When** Demo Floor 1 is assembled
**Then** `res://data/floors/floor_1_tutorial.tres` (FloorData) has `floor_name = "Tutorial"`, `floor_number = 1`, and `room_sequence` containing 5 rooms in order:
1. `tutorial_movement.tscn` — Open room with markers on the floor to walk to; tooltip overlay says "Use WASD to move". No enemies. Exit unlocks after player moves to 3 markers.
2. `tutorial_combat.tscn` — Single Glitch Bug enemy with greatly reduced health (10 HP). Tooltip: "Left click to attack with Data Pulse". Exit unlocks on kill.
3. `tutorial_dash.tscn` — Corridor with a hazard zone (Area3D that deals damage). Tooltip: "Press Space to dash through hazards". Exit on other side.
4. `tutorial_loot.tscn` — Loot room with one guaranteed container dropping a Common Chip. Tooltip: "Press E to open containers and pick up loot".
5. `tutorial_prompt.tscn` — Combat room with 2 Glitch Bugs, player starts at 50% health. Guaranteed Health Prompt drop from first kill. Tooltip: "Press Q to use Health Prompts".
**And** each tutorial room has a `TutorialTrigger` node that shows/hides a `Label` or `RichTextLabel` overlay with instructions
**And** tutorial tooltips disappear after the player completes the instructed action

---

### Story 5.8: Demo Floor 2 — Combat Escalation

As a player,
I want Floor 2 to ramp up combat difficulty with more enemies and an elite,
So that I feel challenged after learning the basics.

**Acceptance Criteria:**

**Given** FloorManager and combat rooms exist
**When** Demo Floor 2 is assembled
**Then** `res://data/floors/floor_2_escalation.tres` has `floor_name = "Data Sector Alpha"`, `floor_number = 2`, and `room_sequence`:
1. `combat_open_arena.tscn` — 3 Glitch Bugs
2. `corridor_straight.tscn` — Rest/breathing room
3. `combat_pillars.tscn` — 2 Glitch Bugs + 2 Memory Leaks (introduces mixed enemy types)
4. `combat_corridor_ambush.tscn` — 2 Rogue Processes (introduces fast enemies)
5. `combat_elevated.tscn` — Elite encounter: 1 Rogue Process with 3x health, 1.5x damage, and 1 Memory Leak on platform. The elite drops a guaranteed Rare item.
**And** enemy spawners in each room are configured with the specified enemy types and counts
**And** the elite Rogue Process has a distinct visual indicator (larger scale 1.5x, different material color)

---

### Story 5.9: Demo Floor 3 — Exploration

As a player,
I want Floor 3 to reward exploration with side rooms, secret loot, and a recruitable NPC,
So that I experience the game's exploration and narrative pillars.

**Acceptance Criteria:**

**Given** FloorManager and all room types exist
**When** Demo Floor 3 is assembled
**Then** `res://data/floors/floor_3_exploration.tres` has `floor_name = "Archive Subnet"`, `floor_number = 3`, and `room_sequence`:
1. `combat_open_arena.tscn` — 3 Memory Leaks (ranged challenge)
2. `corridor_wide.tscn` — Contains a hidden container with a guaranteed Uncommon Module
3. `combat_pillars.tscn` — 4 Glitch Bugs + 1 Memory Leak
4. `story_room.tscn` — NPC: first recruitable character (the "Cache Sprite", npc_id = "cache_sprite"), brief dialogue about being trapped, offers to help in town if rescued
5. `loot_room.tscn` — 3 containers with good loot tables (higher rarity weighting)
6. `combat_elevated.tscn` — 2 Rogue Processes + 2 Memory Leaks (hardest non-boss fight so far)
**And** the Cache Sprite NPC has dialogue content (3-4 lines) and `EventBus.npc_recruited.emit("cache_sprite")` fires after talking

---

### Story 5.10: Demo Floor 4 — Challenge Floor

As a player,
I want Floor 4 to be dense and demanding, testing resource management,
So that I feel the stakes rising before the boss.

**Acceptance Criteria:**

**Given** FloorManager, status effects, and all enemy types exist
**When** Demo Floor 4 is assembled
**Then** `res://data/floors/floor_4_challenge.tres` has `floor_name = "Corrupted Cache"`, `floor_number = 4`, and `room_sequence`:
1. `combat_corridor_ambush.tscn` — 3 Glitch Bugs + 2 Rogue Processes (immediate pressure)
2. `combat_pillars.tscn` — 3 Memory Leaks + 2 Glitch Bugs, Memory Leaks have status effect: their projectiles apply `Corrupted` (DOT)
3. `corridor_turn.tscn` — Brief rest, single container with prompts
4. `combat_open_arena.tscn` — Wave encounter: wave 1 = 3 Glitch Bugs, wave 2 (after wave 1 cleared) = 2 Rogue Processes + 1 Memory Leak. `EnemySpawner` supports `@export var waves: Array[SpawnWave]`
5. `combat_elevated.tscn` — 2 of each enemy type (6 total), elevated Memory Leaks apply `Throttled` (slow)
6. `loot_room.tscn` — Pre-boss resupply, 2 containers with high prompt drop chance
**And** the wave-based spawner extension in room 4 is a new feature: `SpawnWave` Resource with `enemy_types: Array[String]`, `spawn_count: int`, triggered when the previous wave is fully defeated

---

### Story 5.11: Demo Floor 5 — Boss Floor

As a player,
I want Floor 5 to culminate in a boss fight with a story payoff,
So that the demo has a climactic ending.

**Acceptance Criteria:**

**Given** FloorManager, story room, and boss (Epic 9 Story 9.1) exist
**When** Demo Floor 5 is assembled
**Then** `res://data/floors/floor_5_boss.tres` has `floor_name = "Core Process Chamber"`, `floor_number = 5`, and `room_sequence`:
1. `corridor_straight.tscn` — Atmospheric approach corridor with visual storytelling (flickering lights placeholder, corrupted geometry)
2. `story_room.tscn` — AI Sage appears as a hologram, warns about the Corrupted Compiler boss, provides lore context (3-4 dialogue lines), gives a free Rare item
3. `loot_room.tscn` — Final preparation room with 2 containers (health/compute prompts)
4. `boss_arena.tscn` — Large arena room (30x30 units) with the Corrupted Compiler boss (from Story 9.1), no standard enemies, special arena geometry with 4 destructible pillars for cover
**And** after the boss is defeated, a `CompactionPortal` spawns at the room center
**And** `floor_completed` signal is emitted after boss death, triggering auto-save

---

### Story 5.12: Compaction Portal Interaction

As a player,
I want to use the Compaction Portal after clearing the dungeon to warp back to town,
So that I can return to safety with my loot and progress.

**Acceptance Criteria:**

**Given** the boss is defeated and the portal spawns
**When** the player interacts with the portal
**Then** `res://scenes/dungeon/interactables/compaction_portal.tscn` has root `Area3D` with `CollisionShape3D` (CylinderShape3D, radius 1.5), `MeshInstance3D` (glowing torus or cylinder placeholder, emissive material), `Label3D` ("Press E to enter Compaction Portal")
**And** the portal has a placeholder VFX: rotation animation on the mesh (continuous spin) and pulsing emission
**And** when the player presses E in the portal's `InteractionArea`:
1. Emit `EventBus.portal_used.emit()`
2. Play warp animation: screen effect (white flash via ColorRect tween, 0.5s)
3. `GameManager.load_scene("res://scenes/town/town.tscn")`
4. Player spawns at town's `PortalReturnPoint` Marker3D (distinct from the dungeon entrance)
5. `EventBus.returned_to_town.emit()` triggers NPC recruitment processing and auto-save
**And** the portal cannot be used during combat (check `is_cleared` on the room)

---

## Epic 6: Town Hub — "Players have a home base"

### Story 6.1: Town Scene Layout

As a player,
I want a walkable town area that serves as my home base,
So that I have a safe place to interact with NPCs and prepare for dungeon runs.

**Acceptance Criteria:**

**Given** the game needs a persistent hub area
**When** the town scene is created
**Then** `res://scenes/town/town.tscn` has root `Node3D` named `Town` with script `res://scenes/town/town.gd`
**And** child nodes include: `Geometry` (Node3D with floor plane, boundary walls, placeholder building meshes), `PlayerSpawnPoint` (Marker3D for new game start), `PortalReturnPoint` (Marker3D for dungeon return), `DungeonEntrance` (Node3D with interaction area), `NPCSlots` (Node3D containing `Marker3D` children: `AISageSlot`, `CacheSpriteSlot`, `NPCSlot3`, `NPCSlot4`, `NPCSlot5`), `NavigationRegion3D` (baked navmesh for the town floor area)
**And** town geometry: flat ground plane (40x40 units), boundary walls or edges, 3-4 placeholder building shapes (simple CSGBox3D), a central open area
**And** the camera follows the same isometric setup as the dungeon
**And** the Player is instantiated at the appropriate spawn point based on how the scene was entered (new game → `PlayerSpawnPoint`, portal return → `PortalReturnPoint`)
**And** `town.gd` has `func _ready()` that checks `GameManager.town_entry_type` to determine spawn point and calls `_populate_npcs()` to place recruited NPCs

---

### Story 6.2: Dungeon Entrance Interaction

As a player,
I want to interact with the dungeon entrance to start a dungeon run,
So that I can transition from town to the dungeon.

**Acceptance Criteria:**

**Given** the town scene has a `DungeonEntrance` node
**When** the player approaches and interacts with it
**Then** `DungeonEntrance` node has an `InteractionArea` (Area3D, collision radius 2.0) and `MeshInstance3D` (archway or portal frame placeholder), `Label3D` ("Press E to enter the Compaction Loop")
**And** when the player presses E while overlapping:
1. A confirmation dialogue appears: "Enter the Compaction Loop?" with Yes/No buttons (simple `PanelContainer` UI)
2. On Yes: `GameManager.start_dungeon_run()` which sets `GameManager.current_floor = 1`, loads `res://scenes/dungeon/dungeon.tscn`, and the FloorManager begins Floor 1
3. On No: dialogue closes, player resumes control
**And** `EventBus.dungeon_entered.emit()` fires on confirmation, triggering auto-save
**And** if the player has never entered the dungeon before (`GameManager.first_run == true`), the AI Sage NPC initiates a dialogue before the entrance unlocks

---

### Story 6.3: Dialogue System

As a player,
I want to read NPC dialogue in a text panel with typewriter effect,
So that I can engage with the story and characters.

**Acceptance Criteria:**

**Given** NPCs and story moments need dialogue
**When** the dialogue system is implemented
**Then** `res://scenes/ui/dialogue_panel.tscn` is a `CanvasLayer` with `PanelContainer` anchored to the bottom of the screen (full width, 200px height), containing: `MarginContainer` → `HBoxContainer` with `PortraitRect` (TextureRect, 128x128), `VBoxContainer` with `NameLabel` (Label, bold), `DialogueLabel` (RichTextLabel, bbcode enabled)
**And** `res://scenes/ui/dialogue_panel.gd` has:
- `var dialogue_data: Array[DialogueLine]` where `DialogueLine` is a Resource with: `@export var speaker_name: String`, `@export var text: String`, `@export var portrait: Texture2D`, `@export var expression: String`
- `func start_dialogue(data: Array[DialogueLine]) -> void` — shows panel, pauses game (`get_tree().paused = true`), displays first line
- `func _display_line(line: DialogueLine) -> void` — sets portrait, name, and starts typewriter effect on `DialogueLabel` using `visible_characters` incremented via `Timer` or `Tween` (30 characters per second)
- `func _advance() -> void` — if typewriter is still playing, instantly show full text; otherwise advance to next line; if no more lines, close dialogue
- `signal dialogue_finished` emitted when all lines displayed and panel closes
**And** pressing E (input action `interact`) or left click calls `_advance()`
**And** the dialogue panel has `process_mode = PROCESS_MODE_ALWAYS` so it functions while the tree is paused
**And** `EventBus.dialogue_started.emit()` and `EventBus.dialogue_finished.emit()` fire for other systems

---

### Story 6.4: NPC Base Scene

As a developer,
I want a reusable NPC base scene with interaction and dialogue,
So that all NPCs share consistent behavior and are quick to create.

**Acceptance Criteria:**

**Given** the dialogue system exists
**When** the NPC base scene is created
**Then** `res://scenes/npcs/npc_base.tscn` has root `CharacterBody3D` (static, no movement) named `NPCBase` with script `res://scenes/npcs/npc_base.gd`
**And** child nodes: `CollisionShape3D` (CapsuleShape3D), `Model` (Node3D with placeholder MeshInstance3D), `InteractionArea` (Area3D, sphere radius 2.5), `Label3D` (NPC name, positioned above model)
**And** `npc_base.gd` has: `@export var npc_id: String`, `@export var npc_name: String`, `@export var dialogue_resource: Resource` (a `.tres` containing `Array[DialogueLine]`), `@export var portrait_default: Texture2D`, `var has_been_talked_to: bool = false`
**And** when the player presses E while overlapping `InteractionArea`:
1. `DialoguePanel.start_dialogue(dialogue_resource.lines)` is called
2. `has_been_talked_to = true`
3. `EventBus.npc_talked.emit(npc_id)` fires
**And** `InteractionArea` shows a floating prompt: `Label3D` "Press E to talk" visible only when the player overlaps it
**And** NPCs are on collision layer 8 (Interaction) so they don't block movement significantly

---

### Story 6.5: AI Sage NPC

As a player,
I want to meet the AI Sage in town who gives cryptic guidance,
So that I have a narrative anchor and lore source.

**Acceptance Criteria:**

**Given** the NPC base scene and dialogue system exist
**When** the AI Sage is created
**Then** `res://scenes/npcs/ai_sage/ai_sage.tscn` inherits from `npc_base.tscn`
**And** `npc_id = "ai_sage"`, `npc_name = "The AI Sage"`
**And** model placeholder: tall, thin capsule with glowing emissive material (white/cyan)
**And** dialogue resource `res://data/dialogue/ai_sage_intro.tres` contains initial encounter dialogue (5-7 lines):
- Greeting acknowledging the Globbler's arrival
- Cryptic reference to the Compaction Loop and its purpose
- Warning about the Corrupted Compiler
- Hint about collecting allies (NPCs)
- Directive to enter the dungeon
**And** the AI Sage is always present in town (does not need recruitment)
**And** placed at `AISageSlot` Marker3D in the town scene
**And** after the first conversation, subsequent talks use a shorter dialogue set (`ai_sage_subsequent.tres`) with rotating hints/lore tidbits

---

### Story 6.6: NPC Portrait System

As a player,
I want to see NPC portraits with different expressions during dialogue,
So that conversations feel more personal and characters have visual personality.

**Acceptance Criteria:**

**Given** the dialogue panel has a `PortraitRect`
**When** the portrait system is implemented
**Then** each NPC has a portrait data dictionary: `@export var portraits: Dictionary = {}` mapping expression names to `Texture2D` (e.g., `{"default": preload("..."), "happy": preload("..."), "angry": preload("...")}`)
**And** `DialogueLine` resource has an `@export var expression: String = "default"` field
**And** `DialoguePanel._display_line()` reads `line.expression`, looks up the portrait from the current speaker's portrait dictionary, and sets `PortraitRect.texture`
**And** placeholder portraits are solid-color rectangles (128x128) with simple emoji-like expressions drawn or labeled (for demo purposes, a minimum of 2 expressions per NPC: "default" and one other)
**And** portrait transitions use a quick crossfade tween (0.15s alpha blend)
**And** if no portrait is found for an expression, fall back to `"default"`

---

### Story 6.7: NPC Recruitment Flow

As a player,
I want NPCs I find in the dungeon to appear in town when I return,
So that exploration is rewarded with a growing town community.

**Acceptance Criteria:**

**Given** `EventBus.npc_recruited.emit(npc_id)` fires in dungeon story rooms and `EventBus.returned_to_town.emit()` fires on portal use
**When** the recruitment flow is implemented
**Then** `GameManager` maintains `var recruited_npcs: Array[String] = []`
**And** `GameManager` connects to `EventBus.npc_recruited` and appends the `npc_id` if not already present
**And** `town.gd._populate_npcs()` iterates `GameManager.recruited_npcs`, and for each recruited NPC, instantiates the NPC's town scene at the corresponding `NPCSlot` Marker3D
**And** a mapping dictionary in `town.gd` maps `npc_id` to `{scene: PackedScene, slot: String}`: e.g., `"cache_sprite" → {scene: preload("res://scenes/npcs/cache_sprite/cache_sprite.tscn"), slot: "CacheSpriteSlot"}`
**And** when a new NPC appears in town for the first time, they have a special "arrival" dialogue acknowledging their rescue
**And** the AI Sage has additional dialogue if new NPCs have been recruited since last talking to them
**And** recruited NPCs are saved as part of the save data (Epic 7)

---

### Story 6.8: NPC Affinity System

As a player,
I want to build relationships with NPCs through talking and quests,
So that I feel connected to characters and unlock potential future benefits.

**Acceptance Criteria:**

**Given** NPCs exist in town and can be talked to
**When** the affinity system is implemented
**Then** `GameManager` maintains `var npc_affinity: Dictionary = {}` mapping `npc_id` to `int` affinity score (default 0)
**And** `func increase_affinity(npc_id: String, amount: int) -> void` increases the score, emits `EventBus.affinity_changed.emit(npc_id, new_value)`
**And** affinity increases on: talking to an NPC for the first time in a session (+5), completing a quest for an NPC (+15), recruiting an NPC (+10)
**And** affinity thresholds exist: 0-9 = Stranger, 10-24 = Acquaintance, 25-49 = Ally, 50+ = Trusted
**And** NPC dialogue can branch based on affinity tier: `DialogueLine` has `@export var min_affinity: int = 0` and the dialogue system filters available lines
**And** affinity is persisted in save data
**And** for the demo scope, affinity is tracked and displayed but does not unlock mechanical benefits (placeholder for future expansion)

---

### Story 6.9: Town Expansion Triggers

As a player,
I want the town to visually evolve as I recruit more NPCs,
So that my progress feels tangible in the world.

**Acceptance Criteria:**

**Given** NPC recruitment is tracked in `GameManager.recruited_npcs`
**When** town expansion triggers are implemented
**Then** `town.gd` has `func _update_town_state() -> void` called in `_ready()` and whenever `EventBus.returned_to_town` fires
**And** expansion stages are defined by NPC count:
- 0 NPCs: base town (sparse, dim lighting placeholder, minimal props)
- 1 NPC recruited: a new prop group appears (e.g., `TownExpansion1` Node3D set to visible — contains a bench, a light source, decorative mesh)
- 2 NPCs: another area opens (e.g., `TownExpansion2` — a small market stall placeholder with non-functional decoration)
- 3+ NPCs: full town (e.g., `TownExpansion3` — all areas visible, brightest lighting)
**And** expansion Node3D groups are children of the Town scene, defaulting to `visible = false`, toggled on by `_update_town_state()`
**And** a subtle visual feedback plays when entering town with a new expansion state (a brief ambient sound placeholder or screen flash)

---

## Epic 7: Save & Persist — "Player progress is never lost"

### Story 7.1: SaveManager Autoload and Data Structure

As a developer,
I want a centralized SaveManager with a versioned JSON schema,
So that all save/load operations go through one system with future-proof data.

**Acceptance Criteria:**

**Given** the game needs persistent data
**When** SaveManager is implemented
**Then** `res://scripts/autoloads/save_manager.gd` extends `Node` with `class_name SaveManager`, registered as autoload
**And** the save data JSON schema (version 1) contains:
```
{
  "schema_version": 1,
  "timestamp": "ISO-8601 string",
  "player": {
    "level": int,
    "xp": int,
    "stat_points": {"processing": int, "bandwidth": int, "memory": int, "integrity": int},
    "health": float,
    "compute": float,
    "position": {"x": float, "y": float, "z": float},
    "current_scene": "String"
  },
  "inventory": {
    "grid_items": [{"item_id": "String", "grid_pos": [x, y], "durability": float, "affixes": [...]}],
    "prompt_hotbar": [{"item_id": "String", "quantity": int}]
  },
  "equipment": {
    "modules": ["item_id or null", ...],
    "core": "item_id or null",
    "chips": ["item_id or null", ...],
    "protocols": ["item_id or null", ...]
  },
  "town": {
    "recruited_npcs": ["npc_id", ...],
    "npc_affinity": {"npc_id": int, ...},
    "expansion_stage": int
  },
  "dungeon": {
    "highest_floor_reached": int,
    "total_runs": int
  },
  "quests": {
    "active": [{"quest_id": "String", "progress": {...}}],
    "completed": ["quest_id", ...]
  },
  "settings": {
    "master_volume": float,
    "music_volume": float,
    "sfx_volume": float
  }
}
```
**And** `SaveManager` has `const SAVE_PATH = "user://save_data.json"`, `const BACKUP_DIR = "user://backups/"`, `var current_data: Dictionary = {}`
**And** `func get_default_save_data() -> Dictionary` returns a fresh dictionary with all fields at default values

---

### Story 7.2: Save Serialization

As a developer,
I want to collect game state from all systems and write it to a JSON file,
So that the player's progress is captured accurately.

**Acceptance Criteria:**

**Given** SaveManager exists and all game systems have state
**When** `SaveManager.save_game()` is called
**Then** the function collects state from each system:
1. Player data from `Player` node (level, XP, health, compute, position, stat allocations)
2. Inventory data from `InventoryComponent` — serializes each item with `item_id`, grid position, `current_durability`, and generated affixes
3. Equipment data from `EquipmentComponent` — serializes slot contents as `item_id` strings (or null)
4. Town data from `GameManager` — `recruited_npcs`, `npc_affinity`, expansion stage
5. Dungeon data from `GameManager` — `highest_floor_reached`, `total_runs`
6. Quest data from quest system (if available, otherwise empty arrays)
7. Settings from audio buses / settings store
**And** the complete dictionary is written to `SAVE_PATH` using `FileAccess.open()` with `JSON.stringify(data, "\t")` for readability
**And** `SaveManager.save_game()` returns `true` on success, `false` on failure (with `push_error` logging)
**And** `EventBus.game_saved.emit()` fires on successful save
**And** the save operation handles missing nodes gracefully (if a system node doesn't exist yet, use defaults)

---

### Story 7.3: Load Deserialization

As a developer,
I want to read a save file and restore game state to all systems,
So that the player continues from where they left off.

**Acceptance Criteria:**

**Given** a save file exists at `SAVE_PATH`
**When** `SaveManager.load_game()` is called
**Then** the function reads the JSON file using `FileAccess.open()` and `JSON.parse_string()`
**And** validates `schema_version` — if the version is older than current, calls `_migrate_save(data, from_version, to_version)` which applies sequential migrations (for now, only version 1 exists, so migration is a no-op but the infrastructure is in place)
**And** distributes state to each system:
1. Player: sets level, XP, health, compute, position, stat points
2. Inventory: clears grid, recreates items from `item_id` using an `ItemRegistry` lookup (dictionary mapping `item_id` to base `ItemBase` resource), applies saved durability and affixes
3. Equipment: equips items into correct slots
4. Town: sets `GameManager.recruited_npcs`, `npc_affinity`
5. Dungeon: restores progress tracking
6. Quests: restores active and completed quests
**And** if any field is missing from the JSON (e.g., added in a later version), the default value is used (`data.get("field", default_value)`)
**And** if the save file is corrupted (parse error), attempts to load the most recent backup
**And** `EventBus.game_loaded.emit()` fires on successful load
**And** an `ItemRegistry` autoload or static class at `res://scripts/items/item_registry.gd` maps `item_id` strings to preloaded `ItemBase` resources for deserialization

---

### Story 7.4: Auto-Save Triggers

As a player,
I want the game to automatically save at key moments,
So that I never lose significant progress.

**Acceptance Criteria:**

**Given** SaveManager and EventBus exist
**When** auto-save triggers are connected
**Then** `SaveManager._ready()` connects to the following EventBus signals:
- `EventBus.floor_completed` → calls `save_game()` (after each dungeon floor)
- `EventBus.returned_to_town` → calls `save_game()` (arriving in town via portal)
- `EventBus.portal_used` → calls `save_game()` (before scene transition)
- `EventBus.dungeon_entered` → calls `save_game()` (before starting a run)
**And** a minimum interval of 10 seconds between auto-saves prevents rapid-fire saving (tracked by `var last_save_time: float`)
**And** a brief, non-intrusive save indicator appears on the HUD when auto-saving: a small icon or text "Saving..." in the top-right corner, visible for 1.5 seconds (implemented as a `Label` in the HUD CanvasLayer, toggled by `EventBus.game_saved`)
**And** auto-save does not trigger during active combat (check `GameManager.is_in_combat` flag) — instead queues the save for when combat ends

---

### Story 7.5: Rolling Backup System

As a developer,
I want to maintain rolling backups of save files,
So that a corrupted save does not destroy all player progress.

**Acceptance Criteria:**

**Given** SaveManager writes to `SAVE_PATH`
**When** the backup system is implemented
**Then** before each save, `SaveManager._create_backup()` is called:
1. If `SAVE_PATH` exists, copy it to `BACKUP_DIR + "save_backup_1.json"`
2. Before copying, rotate existing backups: `save_backup_2 → save_backup_3` (delete 3 if exists), `save_backup_1 → save_backup_2`
3. This maintains the last 3 save states
**And** `BACKUP_DIR` is created if it does not exist using `DirAccess.make_dir_recursive_absolute()`
**And** `func load_backup(index: int = 1) -> bool` attempts to load from `save_backup_{index}.json` using the same deserialization as `load_game()`
**And** `func has_valid_save() -> bool` checks if `SAVE_PATH` or any backup exists and is parseable
**And** if `load_game()` fails to parse the primary save, it automatically tries `load_backup(1)`, then `load_backup(2)`, then `load_backup(3)`, logging each attempt

---

### Story 7.6: New Game Initialization

As a player,
I want to start a new game with a clean save state,
So that I begin fresh with default values.

**Acceptance Criteria:**

**Given** the player selects "New Game" or no save file exists
**When** `SaveManager.new_game()` is called
**Then** `current_data` is set to `get_default_save_data()` with: player level 1, XP 0, all stat points at 0, full health and compute, position at town spawn, empty inventory, no equipment, no recruited NPCs, all affinity at 0, no quest progress
**And** `save_game()` is called immediately to write the initial state
**And** `GameManager.current_scene = "res://scenes/town/town.tscn"` and `GameManager.town_entry_type = "new_game"`
**And** the town scene loads and the player spawns at `PlayerSpawnPoint`
**And** `GameManager.first_run = true` is set, which triggers the AI Sage's introductory dialogue on first approach
**And** if a previous save exists, `new_game()` asks for confirmation before overwriting (handled by the UI that calls this function, not SaveManager itself)

---

## Epic 8: HUD & Game Interface — "Players see what they need"

### Story 8.1: HUD Overlay Scene

As a player,
I want to always see my health and compute bars during gameplay,
So that I can monitor my resources at a glance.

**Acceptance Criteria:**

**Given** the player is in a gameplay scene (town or dungeon)
**When** the HUD is displayed
**Then** `res://scenes/ui/hud.tscn` is a `CanvasLayer` (layer 10) with script `res://scenes/ui/hud.gd`
**And** top-left contains: `HealthBar` (TextureProgressBar or ProgressBar, red fill, shows current/max as text overlay), `ComputeBar` (TextureProgressBar, blue fill, shows current/max as text overlay), stacked vertically with 4px spacing
**And** `hud.gd` has `@onready var health_bar: ProgressBar` and `@onready var compute_bar: ProgressBar`
**And** connects to `HealthComponent.health_changed` signal: `func _on_health_changed(current, max_val): health_bar.max_value = max_val; health_bar.value = current`
**And** connects to `ComputeComponent.compute_changed` signal similarly
**And** bars have a smooth tween on value change (0.2s ease-out) for visual polish
**And** the HUD is instantiated by `GameManager` or the Player scene and references are set in `_ready()`
**And** the HUD hides during dialogue (listens to `EventBus.dialogue_started`/`dialogue_finished`)

---

### Story 8.2: Module Cooldown Display

As a player,
I want to see my Module ability cooldowns on the HUD,
So that I know when my abilities are ready to use.

**Acceptance Criteria:**

**Given** the HUD exists and `AbilityManager` manages 4 ability slots
**When** the cooldown display is implemented
**Then** bottom-center of the HUD has an `HBoxContainer` named `AbilitySlots` containing 4 `AbilitySlotUI` scenes
**And** `AbilitySlotUI` (`res://scenes/ui/ability_slot_ui.tscn`) contains: `TextureRect` (icon background, 48x48), `TextureRect` (item icon overlay), `Label` (key number "1"-"4"), `ColorRect` (cooldown overlay, dark semi-transparent, covers icon from bottom-to-top proportionally to remaining cooldown)
**And** `ability_slot_ui.gd` has: `func set_module(module: ModuleItem)` (sets icon, shows slot as active), `func set_empty()` (grayed out, no icon), `func start_cooldown(duration: float)` (animates overlay from full to empty over duration), `func set_ready()` (flash effect, clear overlay)
**And** `hud.gd` connects to `AbilityManager.ability_used(slot_index, module)` to start cooldown on the correct slot
**And** `hud.gd` connects to `AbilityManager.ability_ready(slot_index)` to clear cooldown
**And** `hud.gd` connects to `EquipmentComponent.equipment_changed` to refresh slot icons

---

### Story 8.3: Prompt Hotbar Display

As a player,
I want to see my active Prompt type and quantity on the HUD,
So that I know what consumable I have ready.

**Acceptance Criteria:**

**Given** the HUD exists and the Prompt consumable system is active
**When** the prompt display is implemented
**Then** bottom-right of the HUD has a `PanelContainer` named `PromptDisplay` containing: `TextureRect` (prompt icon, colored by type: red=health, blue=compute, yellow=buff), `Label` (quantity "x5"), `Label` (key indicator "Q")
**And** `hud.gd` connects to `InventoryComponent.prompt_used` and `InventoryComponent.inventory_changed` to update display
**And** when no prompts are available, the display shows a grayed-out empty icon with "x0"
**And** pressing Tab cycles prompt type — the display updates immediately with the new type icon and quantity
**And** a brief flash animation plays on the icon when a prompt is used

---

### Story 8.4: XP and Level-Up System

As a player,
I want to earn XP from defeating enemies and level up to allocate stat points,
So that my character grows stronger over time.

**Acceptance Criteria:**

**Given** `EventBus.enemy_defeated` fires with an enemy reference
**When** the XP system is implemented
**Then** `Player` (or a `LevelComponent` at `res://scripts/components/level_component.gd`) has: `var current_level: int = 1`, `var current_xp: int = 0`, `var xp_to_next_level: int = 100`, `var unspent_stat_points: int = 0`
**And** XP required per level: `xp_to_next_level = 100 * current_level` (linear scaling for demo simplicity)
**And** `func add_xp(amount: int) -> void` adds XP; if `current_xp >= xp_to_next_level`, level up: increment `current_level`, `current_xp -= xp_to_next_level`, recalculate `xp_to_next_level`, grant `3` stat points to `unspent_stat_points`, emit `signal leveled_up(new_level: int)`, emit `EventBus.player_leveled_up.emit(new_level)`
**And** XP is awarded via `EventBus.enemy_defeated` → `LevelComponent` reads XP value from the enemy (stored as `@export var xp_reward: int` on `enemy_base.gd`)
**And** HUD shows an XP bar below the health/compute bars: `ProgressBar` with text "Lv. {level}" and a fill representing progress to next level
**And** on level-up, a `StatAllocationPanel` (`res://scenes/ui/stat_allocation_panel.tscn`) appears: shows all 4 stats with current values and "+" buttons, `unspent_stat_points` counter, "Confirm" button
**And** clicking "+" on a stat calls `StatsComponent.allocate_point(stat_name)` and decrements `unspent_stat_points`
**And** the panel pauses the game while open and closes on "Confirm" or when all points are spent

---

### Story 8.5: Inventory Screen

As a player,
I want to open an inventory screen to manage my items and equipment,
So that I can equip gear and organize my backpack.

**Acceptance Criteria:**

**Given** `InventoryComponent` and `EquipmentComponent` exist
**When** the inventory UI is implemented
**Then** pressing Tab or I (input action `toggle_inventory`) opens `res://scenes/ui/inventory_screen.tscn`, a `CanvasLayer` that pauses the game
**And** layout: left panel = Equipment slots (visual representation of 4 Module slots, 1 Core slot, 4 Chip slots, 3 Protocol slots arranged in a paper-doll-like layout), right panel = Inventory grid (10x6 grid of cells matching `InventoryComponent.grid_width/height`)
**And** each grid cell is a `TextureRect` (48x48) that displays the item icon if occupied, empty background if not, border color matches item rarity
**And** clicking an inventory item selects it and shows a tooltip: `PanelContainer` with item name (colored by rarity), item type, stat modifiers, durability bar, description
**And** if the selected item can be equipped, the tooltip shows a "Compare" section: currently equipped item's stats vs. selected item's stats with green/red arrows for better/worse values
**And** equipping: double-click an inventory item or click "Equip" button → calls `EquipmentComponent.equip(item)`, previously equipped item returns to inventory
**And** unequipping: click an equipped slot → calls `EquipmentComponent.unequip(type, index)`, item goes to inventory (if space available)
**And** right-click an item for a context menu: Equip, Drop (spawns `DroppedItem` near player), Use (for Prompts)
**And** pressing Tab/I or Esc closes the inventory and unpauses

---

### Story 8.6: Character Stats Panel

As a player,
I want to see my character's stats with equipment bonuses broken down,
So that I understand my build's strengths and can make informed choices.

**Acceptance Criteria:**

**Given** the inventory screen exists and `StatsComponent` provides stat data
**When** the stats panel is implemented
**Then** a "Stats" tab or side panel is accessible from the inventory screen, showing:
- **Processing**: `{base} + {equipment} + {level} = {total}` with label "Increases damage output"
- **Bandwidth**: `{base} + {equipment} + {level} = {total}` with label "Increases movement speed"
- **Memory**: `{base} + {equipment} + {level} = {total}` with label "Increases compute pool"
- **Integrity**: `{base} + {equipment} + {level} = {total}` with label "Increases health and defense"
**And** additional derived stats shown: Max Health (from Integrity), Max Compute (from Memory), Move Speed (from Bandwidth), Damage Bonus % (from Processing), Defense (from Integrity), Crit Chance % (from Processing)
**And** equipment contributions are colored green to distinguish from base stats
**And** level point contributions are colored cyan
**And** the panel updates live when equipment changes (connected to `StatsComponent.stats_changed`)
**And** `StatsComponent.get_stat_breakdown(stat_name: String) -> Dictionary` returns `{"base": float, "equipment": float, "level": float, "total": float}` for UI display

---

### Story 8.7: Quest Log UI

As a player,
I want a quest log organized by Story, Character, and Discovery categories,
So that I can track my objectives and completed tasks.

**Acceptance Criteria:**

**Given** quests exist in the game (even if minimal for demo)
**When** the quest log UI is implemented
**Then** pressing J (input action `toggle_quest_log`) opens `res://scenes/ui/quest_log.tscn`, a `CanvasLayer` that pauses the game
**And** layout: left sidebar has 3 tab buttons: "Story", "Character", "Discovery"; right panel shows quests for the selected category
**And** each quest entry shows: quest name, brief description, progress indicator (e.g., "Defeat 3/5 Glitch Bugs"), active/completed status
**And** the active quest (most recently accepted or manually selected) is highlighted with a distinct border or icon
**And** completed quests appear at the bottom of the list with a strikethrough or checkmark and reduced opacity
**And** `QuestManager` autoload at `res://scripts/autoloads/quest_manager.gd` tracks: `var active_quests: Array[QuestData]`, `var completed_quests: Array[String]`
**And** `QuestData` Resource at `res://scripts/quests/quest_data.gd` has: `@export var quest_id: String`, `@export var quest_name: String`, `@export var description: String`, `@export var category: String` ("story", "character", "discovery"), `@export var objectives: Array[QuestObjective]`, `var is_completed: bool`
**And** `QuestObjective` Resource has: `@export var objective_text: String`, `@export var target_count: int`, `var current_count: int`
**And** for the demo, 3-5 quests are defined: 1 story quest (clear the dungeon), 1 character quest (recruit Cache Sprite), 1 discovery quest (find a hidden container)
**And** pressing J or Esc closes the quest log

---

### Story 8.8: Pause Menu

As a player,
I want to press Esc to open a pause menu with Resume, Settings, and Quit,
So that I can take a break or adjust settings at any time.

**Acceptance Criteria:**

**Given** the game is running in any gameplay scene
**When** the player presses Esc (input action `ui_cancel`)
**Then** `res://scenes/ui/pause_menu.tscn` appears, a `CanvasLayer` centered on screen with `PanelContainer` containing `VBoxContainer` with buttons: "Resume", "Settings", "Quit to Desktop"
**And** `get_tree().paused = true` is set when the menu opens
**And** "Resume" button: closes menu, `get_tree().paused = false`
**And** "Settings" button: opens a settings sub-panel with: Master Volume slider (0-100, controls `AudioServer.set_bus_volume_db("Master", ...)`), Music Volume slider, SFX Volume slider, Fullscreen toggle (`DisplayServer.window_set_mode()`)
**And** "Quit to Desktop" button: calls `SaveManager.save_game()` then `get_tree().quit()`
**And** pressing Esc again while the pause menu is open closes it (same as Resume)
**And** the pause menu's `process_mode = PROCESS_MODE_ALWAYS`
**And** a semi-transparent dark overlay (`ColorRect`, alpha 0.5) covers the background behind the menu
**And** the pause menu does not open during dialogue (check `EventBus` dialogue state or a `GameManager.is_in_dialogue` flag)

---

## Epic 9: Demo Build — "A playable demo exists"

### Story 9.1: First Boss — Corrupted Compiler

As a player,
I want to fight the Corrupted Compiler as a multi-phase boss encounter,
So that the demo has an exciting climactic challenge.

**Acceptance Criteria:**

**Given** enemy base scene, combat systems, and status effects all exist
**When** the Corrupted Compiler boss is created
**Then** `res://scenes/enemies/bosses/corrupted_compiler/corrupted_compiler.tscn` inherits from `enemy_base.tscn` with custom scripts
**And** base stats: `health = 500.0`, `processing = 15.0`, `bandwidth = 5.0`, `integrity = 10.0`
**And** model: large placeholder mesh (2x scale, dark red/purple pulsing emissive material)
**And** the boss has 3 phases triggered at health thresholds (100%, 60%, 30%):

**Phase 1 (100%-60%):**
- Attack A: "Compile Error" — sweeping hitbox in front arc (120 degrees, range 4.0), telegraphed by 0.8s ground indicator, deals 20 damage
- Attack B: "Syntax Swarm" — spawns 3 Glitch Bugs at arena edges every 15 seconds
- Pattern: alternates Compile Error (2x) then pauses 2s, repeats

**Phase 2 (60%-30%):**
- Adds Attack C: "Memory Overflow" — 3 projectiles in a spread pattern, each leaves a damaging pool (like Memory Leak but bigger, radius 2.0, lasts 5s, deals 5 damage/sec)
- Movement becomes more aggressive, occasionally dashes toward the player
- Attack speed increases by 20%
- Applies `Corrupted` status on all hits

**Phase 3 (30%-0%):**
- Adds Attack D: "Stack Overflow" — arena-wide attack telegraphed for 1.5s (floor flashes red), player must dash to a safe zone (one of 4 randomly chosen corners, indicated by green flash). Deals 50 damage if hit. Used every 20 seconds.
- All previous attacks are active
- Applies `Fragmented` status on Compile Error hits
- Spawns 2 Rogue Processes once at phase start

**And** phase transitions play a brief stagger animation (boss is invulnerable for 1.5s, visual flash, arena effect)
**And** a boss health bar appears at the top of the screen (separate from normal HUD) showing boss name and segmented health bar with phase markers
**And** `EventBus.boss_defeated.emit("corrupted_compiler")` fires on death
**And** the boss drops 3 guaranteed items: 1 Rare or Legendary (90%/10% chance), 1 Uncommon Module, and 1 stack of 5 Health Prompts

---

### Story 9.2: Tutorial Flow Integration

As a new player,
I want the first 5 rooms to progressively teach me each mechanic,
So that I learn naturally through gameplay rather than reading instructions.

**Acceptance Criteria:**

**Given** Floor 1 tutorial rooms exist (Story 5.7)
**When** tutorial flow is polished and integrated
**Then** a `TutorialManager` autoload at `res://scripts/autoloads/tutorial_manager.gd` tracks `var completed_tutorials: Array[String]` and `func is_completed(tutorial_id: String) -> bool`
**And** contextual hints appear as `RichTextLabel` overlays anchored to screen center-top, semi-transparent background, showing one-line instructions
**And** tutorial sequence:
1. Movement room: hint appears immediately "Use WASD to move". Disappears after player moves 10 units total (tracked by cumulative distance). `completed_tutorials.append("movement")`
2. Combat room: hint "Left Click to attack" appears when Glitch Bug is visible. Disappears after first hit. `completed_tutorials.append("basic_attack")`
3. Dash room: hint "Press Space to dash through danger" appears at hazard zone. Disappears after first dash. `completed_tutorials.append("dash")`
4. Loot room: hint "Press E to interact" appears near container. Disappears after first pickup. `completed_tutorials.append("loot")`
5. Prompt room: hint "Press Q to use Health Prompt" appears when player takes damage. Disappears after first use. `completed_tutorials.append("prompt")`
**And** hints only appear if the corresponding tutorial is not yet completed (respects save data)
**And** `completed_tutorials` is saved and loaded with save data
**And** after all 5 tutorials complete, a summary hint: "You're ready. Enter the Compaction Loop." (shown for 3 seconds)

---

### Story 9.3: Demo Narrative Flow

As a player,
I want to experience a coherent narrative arc from start to demo end,
So that the demo feels like a complete experience with beginning, middle, and end.

**Acceptance Criteria:**

**Given** all gameplay systems, town, dungeon, and boss exist
**When** the narrative flow is scripted
**Then** the demo follows this sequence:
1. **New Game → Town**: Player spawns in town. AI Sage approaches (auto-trigger dialogue within 5 seconds via proximity). Sage introduces the Globbler, the Compaction Loop, and hints at a corrupted threat. Sage points toward the dungeon entrance.
2. **Town → Dungeon**: Player enters dungeon. Floor 1 teaches mechanics (tutorial rooms). Floor 2 escalates combat. Floor 3 introduces exploration and the Cache Sprite NPC recruitment. Floor 4 challenges resource management. Floor 5 leads to the Corrupted Compiler boss.
3. **Boss Victory → Portal**: After defeating the Corrupted Compiler, the Compaction Portal spawns. A brief victory dialogue plays (holographic AI Sage projection: "The first cycle is complete...").
4. **Portal → Town Return**: Player warps to town. Cache Sprite appears at their NPC slot. AI Sage has new dialogue acknowledging progress. Town has expanded visually.
5. **Demo End Trigger**: After the player has talked to at least one NPC in town post-return (or walks to a trigger zone), the demo end screen triggers.
**And** narrative checkpoints are tracked in `GameManager`: `first_sage_dialogue_complete`, `first_dungeon_entered`, `cache_sprite_recruited`, `boss_defeated`, `returned_from_first_run`
**And** each checkpoint enables the next narrative gate (e.g., dungeon entrance is locked until first Sage dialogue completes)

---

### Story 9.4: Audio Placeholder Integration

As a player,
I want basic ambient audio and sound effects,
So that the game world feels alive and actions have auditory feedback.

**Acceptance Criteria:**

**Given** the game has town, dungeon, and combat scenes
**When** audio placeholders are integrated
**Then** an `AudioManager` autoload at `res://scripts/autoloads/audio_manager.gd` manages:
- `func play_music(track_name: String, fade_duration: float = 1.0)`
- `func play_sfx(sfx_name: String, position: Vector3 = Vector3.ZERO)`
- `func stop_music(fade_duration: float = 1.0)`
**And** audio buses configured in Project Settings: Master, Music, SFX
**And** placeholder audio tracks (can be silence .wav or simple tones, to be replaced later):
- `res://audio/music/town_ambient.ogg` — loops in town
- `res://audio/music/dungeon_ambient.ogg` — loops in dungeon exploration
- `res://audio/music/combat_music.ogg` — plays during combat encounters
- `res://audio/music/boss_music.ogg` — plays during boss fight
**And** placeholder SFX:
- `attack_hit.wav`, `attack_miss.wav`, `dash.wav`, `pickup.wav`, `hurt.wav`, `death.wav`, `level_up.wav`, `menu_click.wav`, `portal_activate.wav`, `container_open.wav`
**And** music transitions: town scene plays `town_ambient`, entering dungeon crossfades to `dungeon_ambient`, entering a combat room crossfades to `combat_music`, boss room plays `boss_music`, returning to town crossfades back
**And** SFX are triggered via `EventBus` connections: `damage_dealt → attack_hit`, `player_dashed → dash`, `item_added → pickup`, etc.
**And** all audio files are placeholder quality (they establish the trigger points; actual audio assets come later)

---

### Story 9.5: Demo End Screen

As a player,
I want to see a "Thanks for playing" screen with stats after completing the demo,
So that I feel a sense of accomplishment and closure.

**Acceptance Criteria:**

**Given** the player has returned to town after defeating the Corrupted Compiler and interacted with the town
**When** the demo end is triggered
**Then** `GameManager.trigger_demo_end()` is called, which loads `res://scenes/ui/demo_end_screen.tscn`
**And** `demo_end_screen.tscn` is a `CanvasLayer` with a full-screen `PanelContainer` containing:
- Title: "Thanks for Playing Enth: Iteration Demo!" (large, centered)
- Subtitle: "The Compaction Loop continues..."
- Stats summary panel:
  - "Time Played: {formatted_time}" (tracked by `GameManager.play_time_seconds`)
  - "Enemies Defeated: {count}" (tracked by `GameManager.total_enemies_defeated`)
  - "Deaths: {count}" (tracked by `GameManager.total_deaths`)
  - "Highest Level Reached: {level}"
  - "Items Found: {count}"
  - "NPCs Recruited: {count} / {total_possible}"
- Buttons: "Return to Town" (closes screen, lets player keep playing/exploring), "Quit" (saves and exits)
**And** the screen fades in over 1.0s with a subtle background animation (slow parallax or gradient shift)
**And** `EventBus.demo_completed.emit()` fires, marking the demo as finished in save data
**And** the demo end screen can be re-triggered from a menu option after first completion

---

### Story 9.6: Visual Polish Pass

As a player,
I want consistent visual quality across all placeholder assets,
So that the demo feels cohesive even with temporary art.

**Acceptance Criteria:**

**Given** all gameplay systems and scenes are implemented with placeholder visuals
**When** the visual polish pass is performed
**Then** a consistent color palette is established and applied:
- Player: bright cyan/teal
- Enemies: Glitch Bug = red, Memory Leak = green, Rogue Process = blue, Corrupted Compiler = dark purple
- Items by rarity: Common = white, Uncommon = green, Rare = blue, Legendary = gold (emissive)
- Environment: dungeon floors = dark gray, walls = medium gray, town = warm beige/brown
**And** all placeholder meshes have materials with appropriate albedo colors (no default gray)
**And** a `WorldEnvironment` node with `Environment` resource is configured in each scene: ambient light (soft white, intensity 0.3 in dungeon, 0.6 in town), directional light (isometric angle), basic fog in dungeon (adds depth), no post-processing for performance
**And** VFX placeholders exist for: Data Pulse hit (white flash particle burst, 0.2s), Energy Burst release (expanding ring, 0.3s), dash (afterimage via duplicate transparent mesh), enemy death (dissolve/shrink tween), item drop (sparkle particles by rarity), portal (rotating particle ring)
**And** VFX use `GPUParticles3D` with simple materials (no custom shaders for demo) or `Tween`-based effects on meshes
**And** all placeholder meshes, materials, and particles are organized in `res://assets/placeholders/` with descriptive names

---

### Story 9.7: Demo Standalone Build

As a developer,
I want to export a standalone Windows executable for the demo,
So that players can download and run it without Godot installed.

**Acceptance Criteria:**

**Given** all demo content and systems are complete and functional
**When** the build is prepared
**Then** a Godot export preset is configured at `res://export_presets.cfg` for "Windows Desktop":
- Format: `.exe` (ZIP or single executable)
- Name: "Enth_Iteration_Demo"
- Architecture: x86_64
- Icon: placeholder app icon (project icon)
- Product name, version ("0.1.0-demo"), company name set in export options
**And** project settings are verified: `application/config/name = "Enth: Iteration"`, `application/run/main_scene = "res://scenes/main_menu/main_menu.tscn"` or a bootstrap scene that checks for save data and routes to new game or load
**And** a `MainMenu` scene exists at `res://scenes/main_menu/main_menu.tscn` with buttons: "New Game" (calls `SaveManager.new_game()`), "Continue" (calls `SaveManager.load_game()`, grayed out if no save), "Quit" (calls `get_tree().quit()`)
**And** the build is tested from a clean directory (no Godot editor) to verify:
1. Launches without errors
2. Main menu is functional
3. New game starts in town with AI Sage dialogue
4. Can enter dungeon, complete all 5 floors, defeat boss
5. Portal returns to town, demo end screen triggers
6. Save/load works (quit and relaunch, continue from save)
7. No crash on death and respawn
8. Performance is acceptable (60 FPS target on mid-range hardware)
**And** known issues and placeholder notes are logged in a `KNOWN_ISSUES.txt` included alongside the executable
**And** the exported build is placed in `builds/demo/` directory

---

That concludes all story breakdowns for Epics 2 through 9. Each story includes enough technical detail (node types, signal names, method signatures, file paths, architectural patterns) for implementation without ambiguity. The stories follow the composition architecture with EventBus signaling, Resource-based data, and StateMachine patterns as specified.---

## Epic 10: Procedural Dungeons — "Every run feels different"

*FR21: Hybrid dungeon generation (hand-crafted templates + procedural assembly)*
*NFR3: Generation under 1 second*
*Architecture: DungeonGenerator with FloorGenerator, RoomTemplateLibrary, ThemeApplicator, ValidationPass*

---

### Story 10.1: RoomTemplateLibrary — Indexed Collection of Room PackedScenes

As a dungeon generator subsystem,
I want an indexed library of room PackedScene templates categorized by type and difficulty tier,
So that the FloorGenerator can request rooms by criteria and receive valid, pre-authored scenes.

**Acceptance Criteria:**

**Given** the RoomTemplateLibrary is a Resource (extends Resource) stored at `res://resources/dungeon/room_template_library.tres`
**When** the library is loaded at runtime
**Then** it exposes a dictionary of room entries indexed by a composite key of `room_type` (enum: COMBAT, LOOT, CORRIDOR, STORY, BOSS, ENTRANCE, EXIT) and `difficulty_tier` (int, 1–6 corresponding to compaction loops)
**And** each entry in the library references a PackedScene path, a `room_type` enum value, a `difficulty_tier` int, a `size_category` enum (SMALL, MEDIUM, LARGE), and a `connection_points` array of Vector2i positions indicating door/portal placements on the room boundary
**And** a helper method `get_rooms(type: RoomType, tier: int) -> Array[RoomTemplate]` returns all matching templates filtered by type and tier, returning an empty array if none match
**And** a helper method `get_random_room(type: RoomType, tier: int, rng: RandomNumberGenerator) -> RoomTemplate` returns a single random matching template using the provided RNG seed for determinism
**And** each room PackedScene root node is a Node2D with a metadata key `room_meta` containing exported variables: `room_type`, `difficulty_tier`, `encounter_slots` (int, number of enemy spawn markers), and `loot_slots` (int, number of loot spawn positions)
**And** the library contains at minimum 3 templates per room type for tier 1 (18 minimum total for the 6 types: COMBAT, LOOT, CORRIDOR, STORY, ENTRANCE, EXIT) — BOSS rooms are excluded from the library and authored separately per Epic 11
**And** a validation method `validate_library() -> Array[String]` checks that all referenced PackedScene paths exist, all rooms have at least 1 connection point, and returns an array of error strings (empty if valid)

---

### Story 10.2: FloorGenerator — Procedural Floor Assembly Algorithm

As a dungeon generator subsystem,
I want a FloorGenerator that assembles a complete dungeon floor by selecting a graph template and populating it with rooms from the library,
So that each floor has a unique but structurally sound layout.

**Acceptance Criteria:**

**Given** the FloorGenerator is a RefCounted class at `res://scripts/dungeon/floor_generator.gd` that receives a `RoomTemplateLibrary`, a `difficulty_tier` (int), a `floor_number` (int), and a `seed` (int) as constructor parameters
**When** `generate_floor() -> FloorLayout` is called
**Then** it first selects a floor graph template from a set of at least 3 predefined graph structures (linear, branching, hub-and-spoke) stored as Resource files at `res://resources/dungeon/floor_graphs/`, where each graph defines node slots (with assigned `RoomType`) and edge connections between them
**And** story-critical rooms (ENTRANCE at slot 0, EXIT at final slot, and any STORY rooms flagged `fixed_position: true` in the graph) are placed at their fixed graph positions first
**And** remaining graph slots are filled by querying `RoomTemplateLibrary.get_random_room()` with the slot's designated `RoomType` and the floor's `difficulty_tier`, using a seeded `RandomNumberGenerator` initialized from the provided seed for full determinism
**And** the returned `FloorLayout` Resource contains: an `Array[PlacedRoom]` where each `PlacedRoom` holds the PackedScene reference, a `grid_position` (Vector2i in tile-grid coordinates), a `rotation` (int, 0/90/180/270), and resolved `connections` (array of references to adjacent PlacedRoom entries)
**And** room placement uses a spatial packing algorithm that positions rooms on a 2D grid without overlap, respecting each room's `size_category` footprint (SMALL = 1x1, MEDIUM = 2x1 or 1x2, LARGE = 2x2 grid cells)
**And** connections between adjacent rooms in the graph are resolved by aligning `connection_points` from each room's metadata, inserting a CORRIDOR room template if the gap between two rooms exceeds 1 grid cell
**And** calling `generate_floor()` with the same seed, tier, and floor number always produces an identical `FloorLayout`
**And** the method emits no signals and performs no scene tree operations — it is purely data-driven, returning a FloorLayout Resource for the DungeonGenerator to instantiate

---

### Story 10.3: ThemeApplicator — Visual Theme Based on Dungeon Depth

As a dungeon generator subsystem,
I want a ThemeApplicator that reskins placed rooms according to the current dungeon depth theme,
So that floors visually communicate progression and each zone feels distinct.

**Acceptance Criteria:**

**Given** the ThemeApplicator is a RefCounted class at `res://scripts/dungeon/theme_applicator.gd`
**When** `apply_theme(floor_layout: FloorLayout, depth: int) -> void` is called
**Then** it determines the active theme from the depth parameter using the mapping: depth 1 = DATA_CORRIDORS, depth 2 = MEMORY_BANKS, depth 3 = CORRUPTED_SECTORS, depth 4 = PROCESSING_CORES, depth 5 = KERNEL_LAYER, depth 6 = KERNEL_LAYER (repeat for loop 6)
**And** each theme is defined as a `DungeonTheme` Resource at `res://resources/dungeon/themes/<theme_name>.tres` containing: a `tileset_override` (TileSet resource path), a `color_palette` (array of 5 Color values: primary, secondary, accent, background, danger), an `ambient_light_color` (Color), an `ambient_light_energy` (float, 0.0–1.0), a `fog_color` (Color), a `fog_density` (float), and a `particle_effect_scene` (PackedScene path for ambient particles like floating data bits or corruption sparks)
**And** for each PlacedRoom in the FloorLayout, the ThemeApplicator iterates the instantiated room scene's children and applies: TileMapLayer nodes get their `tile_set` replaced with the theme's `tileset_override`, any node in group `theme_colorable` gets its `modulate` set to the theme's `primary` color, any DirectionalLight2D or PointLight2D gets `color` and `energy` set from the theme's ambient values
**And** a single ambient particle emitter (GPUParticles2D) is added to the floor root node using the theme's `particle_effect_scene`
**And** the DATA_CORRIDORS theme uses cool blue tones (#0A1628, #1A3A5C, #00FF88, #050D14, #FF3366), MEMORY_BANKS uses warm amber (#1A1400, #3D3000, #FFD700, #0A0A00, #FF6600), CORRUPTED_SECTORS uses glitch magenta (#1A0014, #3D002E, #FF00FF, #0A000A, #FF0040), PROCESSING_CORES uses sterile white-green (#0A1A0A, #1A3D1A, #00FF00, #050A05, #FF0000), and KERNEL_LAYER uses deep red-black (#1A0000, #3D0000, #FF0000, #0A0000, #FFFFFF)
**And** the method modifies scene nodes in-place and returns void — it operates on already-instantiated room scenes within the scene tree

---

### Story 10.4: ValidationPass — Ensure Floor Connectivity and Path Validity

As a dungeon generator subsystem,
I want a ValidationPass that verifies every generated floor has a traversable path from entrance to exit with all rooms connected,
So that players never encounter a broken or uncompletable floor.

**Acceptance Criteria:**

**Given** the ValidationPass is a RefCounted class at `res://scripts/dungeon/validation_pass.gd`
**When** `validate(floor_layout: FloorLayout) -> ValidationResult` is called
**Then** it performs a breadth-first search (BFS) starting from the room flagged as ENTRANCE, traversing connections between PlacedRooms
**And** the `ValidationResult` Resource contains: `is_valid` (bool), `entrance_to_exit_path_exists` (bool), `all_rooms_connected` (bool), `unreachable_rooms` (Array[PlacedRoom] — rooms not reached by BFS), and `errors` (Array[String] with human-readable descriptions of each failure)
**And** `is_valid` is true only when both `entrance_to_exit_path_exists` and `all_rooms_connected` are true
**And** if any rooms are unreachable, the validator provides a `suggest_fixes(floor_layout: FloorLayout) -> Array[ConnectionFix]` method that returns a list of `ConnectionFix` objects, each proposing a new connection (pair of PlacedRoom references + connection point positions) that would link an unreachable room to the connected graph — these are suggestions for the DungeonGenerator's retry logic
**And** the validator also checks that no two rooms overlap in grid space (same grid_position and overlapping footprint) and flags overlaps in the `errors` array
**And** the validator checks that every connection between two rooms has matching aligned connection_points (door A faces door B across the shared boundary) and flags misaligned connections
**And** the BFS and all checks complete in under 50ms for a floor of up to 30 rooms (profiled with `Time.get_ticks_msec()` in debug builds)

---

### Story 10.5: DungeonGenerator Integration — Orchestrate Full Floor Generation

As the game's dungeon system,
I want a DungeonGenerator autoload that orchestrates FloorGenerator, ThemeApplicator, and ValidationPass to produce a complete, themed, validated floor and instantiate it into the scene tree,
So that the game can request a new floor with a single call and receive a fully playable level.

**Acceptance Criteria:**

**Given** the DungeonGenerator is an autoload singleton at `res://scripts/dungeon/dungeon_generator.gd` registered in Project Settings > Autoload
**When** `generate_and_load_floor(depth: int, tier: int, seed: int) -> bool` is called
**Then** it executes the following pipeline in order: (1) calls `FloorGenerator.generate_floor()` to produce a `FloorLayout`, (2) calls `ValidationPass.validate()` on the layout, (3) if validation fails, regenerates with seed+1 up to a maximum of 5 retry attempts, (4) on valid layout, instantiates all PlacedRoom PackedScenes as children of a root `Node2D` named `FloorRoot`, (5) calls `ThemeApplicator.apply_theme()` on the instantiated floor, (6) positions the player at the ENTRANCE room's spawn marker (a `Marker2D` node named `PlayerSpawn` inside the entrance room scene), (7) emits signal `floor_generated(depth: int, tier: int)` via EventBus
**And** the entire pipeline from `generate_and_load_floor()` call to signal emission completes in under 1000ms (1 second) as required by NFR3, measured with `Time.get_ticks_msec()` and logged to console in debug builds
**And** if all 5 retry attempts fail validation, the method returns `false`, emits `floor_generation_failed(depth: int, tier: int)` via EventBus, and logs an error via `push_error()`
**And** before instantiating a new floor, the generator calls `queue_free()` on any existing `FloorRoot` node in the current scene to clean up the previous floor
**And** the generator exposes a `current_floor_layout: FloorLayout` property for other systems (minimap, navigation) to read the active floor structure
**And** a `get_room_at_player_position() -> PlacedRoom` utility method returns which room the player is currently in, based on the player's global position mapped to grid coordinates
**And** the generator stores the active seed in the save data (via the existing save system) so floors can be deterministically regenerated on load

---

### Story 10.6: Room Template Expansion — 5+ Additional Templates per Type

As a level designer (and the procedural system),
I want at least 5 additional room templates per room type beyond the initial 3,
So that generated floors have enough variety that repeated runs feel distinct.

**Acceptance Criteria:**

**Given** the RoomTemplateLibrary already contains 3 templates per room type (from Story 10.1) for a total of 18 base templates across COMBAT, LOOT, CORRIDOR, STORY, ENTRANCE, EXIT
**When** this story is complete
**Then** each room type has at least 8 total templates (5 additional per type, 30 new scenes minimum), stored at `res://scenes/dungeon/rooms/<type>/<type>_<number>.tscn` (e.g., `combat_04.tscn` through `combat_08.tscn`)
**And** each new COMBAT room template has a distinct spatial layout: at least one features a central pillar arrangement for cover-based combat, one features a narrow chokepoint, one features an open arena, one features elevated platforms with ramps, and one features a multi-chamber design with internal doorways
**And** each new LOOT room template varies in size and loot_slot count: at least one has a single high-value chest position, one has 3–4 scattered containers, one is a hidden side room (SMALL size), one features a trapped loot area (Marker2D nodes named `TrapSpawn_N` for trap placement), and one is a vault-style room with a locked-door mechanic trigger
**And** each new CORRIDOR room template varies in shape: straight, L-bend, T-junction, crossroads, and a long winding passage, with connection_points correctly placed at each open end
**And** each new STORY room template includes a `Marker2D` named `NPCSpawn` for optional NPC placement, a `Marker2D` named `InteractableSpawn` for story object placement, and at least one template features a vista/overlook area for environmental storytelling
**And** ENTRANCE templates include 3 variations beyond the base (different spawn orientations, aesthetic variety) and EXIT templates include 3 variations (portal room styles)
**And** all new templates have correct `room_meta` exported variables, at least 1 connection_point, and pass `RoomTemplateLibrary.validate_library()` with zero errors
**And** new templates are added to the RoomTemplateLibrary resource with appropriate difficulty_tier tags (templates tagged tier 1 use simple geometry, tier 3+ introduce more complex layouts and more encounter/loot slots)

---

## Epic 11: Full Compaction Cycle — "6 portals, deepening challenge"

*FR33: Boss encounters at end of each loop (6 bosses total)*
*FR38: Material recycling from items for town upgrades*

---

### Story 11.1: Boss Base Class — Multi-Phase State Machine

As a boss encounter system,
I want a reusable boss base class with a multi-phase state machine, health-phase transitions, arena hazard support, and guaranteed loot drops,
So that all 6 bosses share consistent architecture while allowing unique behaviors.

**Acceptance Criteria:**

**Given** the boss base class is `res://scripts/enemies/boss_base.gd` extending CharacterBody2D, and it uses the project's existing StateMachine pattern (composition via a StateMachine child node with State child nodes)
**When** a boss is instantiated in its arena room
**Then** the boss has an exported `phase_thresholds: Array[float]` defining health percentage breakpoints (e.g., [0.75, 0.50, 0.25]) that trigger phase transitions, with the initial phase being phase 0 (full health to first threshold)
**And** the boss's StateMachine contains at minimum these states: `Intro` (entrance animation, boss health bar appears, player cannot deal damage), `Phase_N` (one state per phase, each phase state can define its own attack patterns via an overridable `_get_attack_sequence() -> Array[StringName]` method), `Transition` (invulnerability frames, visual effect, triggers arena hazard changes, emitted signal `phase_changed(new_phase: int)`), `Stagger` (temporary vulnerability window after specific conditions defined per boss), `Death` (death animation, loot spawn, emits `boss_defeated(boss_id: StringName)` via EventBus)
**And** the boss has a `health_component` (existing HealthComponent pattern) and when `health_component.health_changed` signal fires, the base class checks if current health percentage has crossed the next threshold in `phase_thresholds` and triggers transition to the next phase
**And** the boss has an `arena_hazards: Node2D` exported reference pointing to the arena room's hazard container node, and each Phase_N state can call `activate_hazard(hazard_name: StringName)` and `deactivate_hazard(hazard_name: StringName)` to toggle child nodes in that container
**And** the boss exposes a `boss_id: StringName` export for save system tracking, a `boss_display_name: String` for the UI health bar, and a `guaranteed_drops: Array[LootTable]` where LootTable is the existing loot Resource type — on death, all guaranteed_drops are spawned plus a roll on the standard loot table with rarity forced to RARE or above
**And** a `BossHealthBar` UI scene is instantiated as a CanvasLayer child during the Intro state, showing the boss name and a segmented health bar with phase threshold markers, and is freed during the Death state
**And** the base class emits the following signals via EventBus: `boss_intro_started(boss_id)`, `boss_phase_changed(boss_id, phase)`, `boss_defeated(boss_id)`, enabling other systems (music, camera, narrative) to react

---

### Story 11.2: Boss 2 — Recursive Entity

As a player facing the second compaction loop boss,
I want to fight the Recursive Entity, a boss that splits into smaller copies of itself in escalating phases,
So that I experience a unique combat challenge requiring area control and priority targeting.

**Acceptance Criteria:**

**Given** the Recursive Entity scene is at `res://scenes/enemies/bosses/recursive_entity.tscn` extending BossBase with `boss_id = "recursive_entity"` and `phase_thresholds = [0.66, 0.33]` (3 phases)
**When** Phase 0 begins (100%–66% health)
**Then** the boss uses a single large sprite (at least 3x the size of a standard enemy), moves slowly toward the player, and attacks with sweeping melee strikes (Area2D hitbox, 180-degree arc in front) on a 2-second cooldown, plus a periodic "recursive pulse" projectile (ring of 6 projectiles expanding outward) on a 5-second cooldown
**And** when Phase 1 triggers (66% health), the boss plays the Transition animation, then splits: the original shrinks to 2x standard enemy size, and a `RecursiveCopy` scene (same visual, 60% of original's max health, 80% of original's damage) is instantiated at an offset position — both entities share a combined health pool displayed on the BossHealthBar, meaning damage to either depletes the same bar
**And** when Phase 2 triggers (33% health), the split repeats: each existing entity spawns one additional copy (total 4 entities), each at 1.5x standard size with 40% of original max health and 60% damage — the combined health pool continues to deplete from damage to any entity
**And** RecursiveCopy entities use simplified attack patterns (melee only, no recursive pulse) and have slightly faster movement speed than the original to pressure the player
**And** if only copies remain (original is "killed" but combined health pool is not zero), the largest remaining copy becomes the new "primary" and gains the recursive pulse attack
**And** on combined health reaching zero, all entities play the Death animation simultaneously and guaranteed loot spawns at the original's position
**And** arena hazards for this fight: Phase 1 activates "data fragmentation zones" (4 rectangular Area2D regions that pulse damage every 3 seconds, visually indicated by flickering floor tiles), Phase 2 adds 2 additional zones

---

### Story 11.3: Boss 3 — Stack Overflow

As a player facing the third compaction loop boss,
I want to fight the Stack Overflow, a boss that grows larger and stronger over time requiring burst damage to defeat before being overwhelmed,
So that I experience a DPS-race encounter that tests my offensive capabilities and upgrade choices.

**Acceptance Criteria:**

**Given** the Stack Overflow scene is at `res://scenes/enemies/bosses/stack_overflow.tscn` extending BossBase with `boss_id = "stack_overflow"` and `phase_thresholds = [0.75, 0.50, 0.25]` (4 phases)
**When** the encounter begins
**Then** a `growth_timer: Timer` starts with a 10-second interval, and every time it fires, the boss gains a `stack_count` (int, starting at 0), which increases its `scale` by 0.1 per stack (visual growth), increases its damage multiplier by 10% per stack (applied to all attacks via the existing damage calculation), and increases its movement speed by 5% per stack
**And** Phase 0 (100%–75%): the boss is medium-sized (2x standard enemy), uses a ground-slam attack (Area2D circle, 1.5-second telegraph with visual indicator on the ground, 2-second cooldown) and a "stack push" ranged attack (single fast projectile in player direction, 3-second cooldown)
**And** Phase 1 (75%–50%): slam radius increases by 30%, adds a new "overflow wave" attack (line of damaging tiles extending outward from the boss in 4 cardinal directions, 1-second telegraph, 6-second cooldown), growth_timer interval reduces to 8 seconds
**And** Phase 2 (50%–25%): adds a "memory leak" passive aura (Area2D circle around boss that deals tick damage every 0.5 seconds to any player within range, range grows with stack_count), growth_timer reduces to 6 seconds
**And** Phase 3 (25%–0%): growth_timer reduces to 4 seconds, all attack cooldowns reduced by 30%, overflow wave fires in 8 directions instead of 4, the boss is now visually enormous and the arena feels cramped
**And** the BossHealthBar displays the current `stack_count` next to the boss name as "Stack: N" to communicate the urgency to the player
**And** at stack_count 20, the boss reaches maximum size (4x standard enemy scale) and gains a permanent enrage: double damage, no further scaling needed — this serves as a soft timer of approximately 2–3 minutes depending on phase
**And** arena hazards: "memory leak pools" (circular Area2D zones) spawn at the boss's position every 15 seconds and persist for 30 seconds, dealing damage on contact — their size scales with the boss's current scale

---

### Story 11.4: Boss 4 — Null Pointer

As a player facing the fourth compaction loop boss,
I want to fight the Null Pointer, a boss that teleports and phases through attacks requiring precise timing to damage,
So that I experience an encounter focused on reading tells and timing my attacks during vulnerability windows.

**Acceptance Criteria:**

**Given** the Null Pointer scene is at `res://scenes/enemies/bosses/null_pointer.tscn` extending BossBase with `boss_id = "null_pointer"` and `phase_thresholds = [0.66, 0.33]` (3 phases)
**When** the encounter begins
**Then** the boss has a `tangible` (bool, default false) state tracked in its base script — when `tangible == false`, the boss's `CollisionShape2D` for hurtbox is disabled (cannot take damage), and its sprite renders at 50% opacity with a ghostly shader effect (a simple alpha + color modulation in a ShaderMaterial)
**And** the boss cycles between intangible and tangible states: it remains intangible for 4 seconds (moving, attacking) then becomes tangible for 2.5 seconds (vulnerability window), signaled by a bright flash and distinct audio cue 0.5 seconds before becoming tangible, and the sprite becomes fully opaque
**And** during intangible periods in Phase 0: the boss teleports to a random position within the arena (not within 2 tiles of the player) every 1.5 seconds, each teleport followed by a "null strike" attack (fast dagger-like projectile aimed at the player's position at time of teleport, not tracking)
**And** during tangible windows in Phase 0: the boss stands still and performs a slow "dereference beam" attack (a Line2D-based laser that sweeps 90 degrees over 2 seconds, dealing high damage on contact) — the player must dodge the beam while dealing damage during this window
**And** Phase 1 (66%): intangible duration increases to 5 seconds, tangible window decreases to 2 seconds, teleport frequency increases to every 1 second, adds "null zone" attack during intangible (places an invisible Area2D trap at a random position that triggers 1 second after the boss becomes tangible, dealing burst damage in a circle — indicated by a subtle ground shimmer)
**And** Phase 2 (33%): intangible duration 6 seconds, tangible window 1.5 seconds, teleport every 0.8 seconds, fires 3 null strike projectiles per teleport in a spread pattern, null zones are placed every 2 seconds during intangible, dereference beam sweeps 180 degrees during tangible
**And** when the player successfully deals damage during a tangible window that causes a phase transition, the Transition state includes a 1-second stagger where the boss is still tangible (bonus damage window as a reward for good timing)
**And** arena hazards: "null reference pillars" (4 StaticBody2D obstacles) exist in the arena for cover against null strikes — in Phase 2, 2 pillars are destroyed by the boss, reducing cover

---

### Story 11.5: Boss 5 — Deadlock

As a player facing the fifth compaction loop boss,
I want to fight the Deadlock, a pair of linked entities that must be killed simultaneously,
So that I experience a complex multi-target encounter requiring strategic damage balancing.

**Acceptance Criteria:**

**Given** the Deadlock scene is at `res://scenes/enemies/bosses/deadlock.tscn` extending BossBase with `boss_id = "deadlock"` and `phase_thresholds = [0.50]` (2 phases), containing two CharacterBody2D children: `ThreadA` and `ThreadB`
**When** the encounter begins
**Then** ThreadA and ThreadB are visually distinct (ThreadA is blue-tinted, ThreadB is red-tinted) and are connected by a visible `Line2D` "link beam" between them that deals damage to the player if they cross it (Area2D collision along the line, checked every physics frame)
**And** each thread has its own independent health bar segment displayed on the BossHealthBar (split bar showing both), and the combined pool equals `phase_thresholds` progression — however, if one thread reaches 0 HP while the other is above 15% HP, the dead thread fully regenerates to 30% HP after a 3-second revive animation (communicating the "must kill simultaneously" mechanic)
**And** "simultaneously" is defined as: both threads must reach 0 HP within 5 seconds of each other — if this window is met, neither revives and the boss enters Death state
**And** ThreadA's attack pattern: slow, heavy melee attacks (large Area2D slam, 3-second cooldown), periodically anchors in place and pulls ThreadB toward it (ThreadB's movement is forced toward ThreadA over 2 seconds, contracting the link beam and the dangerous zone)
**And** ThreadB's attack pattern: fast, ranged attacks (rapid-fire small projectiles, 3-round burst every 2 seconds), periodically dashes away from ThreadA (extending the link beam across more of the arena)
**And** Phase 0 (100%–50%): threads operate independently with above patterns, link beam deals moderate contact damage, the threads stay within a medium range of each other
**And** Phase 1 (50%–0%): the link beam begins rotating around the arena center (threads orbit each other, one clockwise, one counterclockwise, completing a rotation every 8 seconds), link beam damage doubles, both threads gain a new coordinated attack: "deadlock crash" where both charge toward the player simultaneously from opposite sides (4-second cooldown, 1-second telegraph with target indicators on the ground)
**And** arena hazards: Phase 1 adds "resource starvation zones" (shrinking safe area — arena borders slowly deal damage, effective arena size reduces by 10% every 30 seconds during Phase 1, resetting on phase transition)

---

### Story 11.6: Boss 6 — Kernel Panic

As a player facing the sixth and final compaction loop boss,
I want to fight Kernel Panic, an arena-wide chaos encounter with multiple simultaneous hazards,
So that I experience a culminating pre-User challenge that tests all my skills and upgrades.

**Acceptance Criteria:**

**Given** the Kernel Panic scene is at `res://scenes/enemies/bosses/kernel_panic.tscn` extending BossBase with `boss_id = "kernel_panic"` and `phase_thresholds = [0.80, 0.60, 0.40, 0.20]` (5 phases), and the boss is a large stationary entity in the arena center
**When** the encounter begins
**Then** the boss occupies the center of the arena as a large pulsating core (does not move), and the fight is entirely about surviving and dealing damage through escalating arena-wide hazards while dodging attack patterns
**And** Phase 0 (100%–80%): the core fires "system call" projectiles (homing projectiles, 3 at a time, moderate speed, 4-second cooldown) and activates "process spawn" (spawns 2 weak standard enemies from arena edges every 10 seconds, maximum 4 alive at once)
**And** Phase 1 (80%–60%): adds "interrupt storm" (random lightning-bolt-style attacks striking 3 random arena positions every 5 seconds, 0.75-second telegraph via ground indicators), process spawn rate increases to every 8 seconds
**And** Phase 2 (60%–40%): adds "kernel thread" (4 rotating laser beams extending from the core, rotating clockwise at a moderate pace, each beam is a RayCast2D + Line2D visual dealing high damage on contact — player must jump or find gaps), system call projectiles increase to 5 per volley
**And** Phase 3 (40%–20%): the rotating beams double-speed, interrupt storm strikes 5 positions every 4 seconds, adds "blue screen zones" (large rectangular areas that flash a warning color for 2 seconds then become lethal for 1 second, cycling through 3 arena regions in sequence), process spawns are now elite-tier enemies
**And** Phase 4 (20%–0%): all previous hazards active simultaneously, core gains a "critical exception" desperation attack (massive expanding ring projectile from center that covers the entire arena except a narrow safe band at medium range, 8-second cooldown, 2-second telegraph), process spawning stops (arena is dangerous enough)
**And** the core has a weakpoint mechanic: every 15 seconds, a glowing node appears at a random position on the core's perimeter (Marker2D with AnimatedSprite2D glow effect) — attacking this node deals 3x damage for 3 seconds before it disappears; this is the primary intended damage window
**And** on death, all arena hazards immediately cease, all spawned enemies die, and a dramatic death sequence plays (screen shake, flash, the core implodes over 3 seconds) before loot spawns
**And** guaranteed loot includes a unique "Kernel Fragment" material item required for the highest-tier town upgrade

---

### Story 11.7: Compaction Loop Progression — Loops 2–6

As a player progressing through the full game,
I want compaction loops 2 through 6 to use procedurally generated floors with increasing difficulty, each culminating in a boss and portal,
So that the compaction cycle provides escalating challenge and variety.

**Acceptance Criteria:**

**Given** the player has completed compaction loop 1 (the demo content) and enters the dungeon for loop 2
**When** the player enters any compaction loop N (where N is 2–6)
**Then** the DungeonGenerator is called with `tier = N` and `depth = N` to produce a procedurally generated floor using the RoomTemplateLibrary filtered to templates matching tier N or lower (higher-tier templates are more complex/dangerous)
**And** each loop consists of exactly one procedurally generated floor followed by a boss arena room (not procedural — the boss arena is a fixed scene loaded after the floor's EXIT room portal is entered)
**And** the boss encountered at the end of each loop matches the loop number: Loop 1 = Boss 1 (existing from demo), Loop 2 = Recursive Entity, Loop 3 = Stack Overflow, Loop 4 = Null Pointer, Loop 5 = Deadlock, Loop 6 = Kernel Panic
**And** after defeating a boss, a compaction portal activates in the boss arena, and interacting with it triggers the compaction sequence: screen effect, return to town, EventBus signal `compaction_completed(loop_number: int)`, save game auto-triggered
**And** town NPCs have new dialogue lines after each compaction loop completion acknowledging the player's progress (at minimum, 1 new line per NPC per loop completed, managed via the existing dialogue system)
**And** the player's current loop number is persisted in the save file and displayed on the town's dungeon entrance UI as "Compaction Loop: N/6"
**And** entering the dungeon for loop N when the player has already completed loop N is not possible — the portal advances to loop N+1 automatically

---

### Story 11.8: Left/Right Click Attack Upgrades Post-Compaction

As a player who has completed a compaction loop,
I want to unlock upgraded versions of my Data Pulse (left click) and Energy Burst (right click) attacks,
So that my combat capabilities grow meaningfully alongside enemy difficulty.

**Acceptance Criteria:**

**Given** the player completes compaction loop N and returns to town
**When** the `compaction_completed` signal is received by the player's ability system
**Then** new attack upgrade tiers become available, one tier per compaction loop completed: Tier 1 (after loop 1, existing base attacks), Tier 2 (after loop 2), Tier 3 (after loop 3), up to Tier 6 (after loop 6)
**And** each attack tier is defined as a Resource at `res://resources/abilities/data_pulse_tier_N.tres` and `res://resources/abilities/energy_burst_tier_N.tres`, containing: `damage_multiplier` (float, base 1.0 at tier 1, increasing by 0.25 per tier), `visual_scale` (float, projectile/effect size multiplier), `additional_effect` (StringName referencing a bonus behavior), and `upgraded_name` (String for UI display)
**And** Data Pulse upgrade progression: Tier 2 adds a small AoE splash on hit (Area2D, 50% damage to nearby enemies within 1 tile), Tier 3 increases projectile count to 2 (slight spread), Tier 4 projectiles pierce through 1 enemy, Tier 5 adds a DoT (damage-over-time) effect on hit (2 seconds, 20% of base damage per tick), Tier 6 combines all — 2 piercing projectiles with splash and DoT
**And** Energy Burst upgrade progression: Tier 2 increases the AoE radius by 25%, Tier 3 adds a 1-second slow effect (50% movement reduction) to hit enemies, Tier 4 burst creates a lingering damage zone for 2 seconds, Tier 5 adds knockback force of 300 to hit enemies, Tier 6 combines all — larger burst with slow, lingering zone, and knockback
**And** the upgrade is applied via an NPC in town (the existing upgrade/ability NPC or a new one) — the player interacts, a UI panel shows the available tier with a description and visual preview, and confirming applies it immediately (no cost — it is a compaction reward)
**And** the currently equipped attack tier is saved per-ability in the player save data and loaded on game start
**And** attack visual effects (particle systems, sprite animations) change per tier to visually communicate increased power — at minimum, color intensity increases and effect size matches `visual_scale`

---

### Story 11.9: Material Recycling System

As a player with unwanted items,
I want to recycle items at town for crafting materials,
So that all loot has value and I can invest in town upgrades.

**Acceptance Criteria:**

**Given** a recycling station exists in the town scene as an interactable `Area2D` node at `res://scenes/town/recycling_station.tscn` with an `InteractionComponent` (existing pattern)
**When** the player interacts with the recycling station
**Then** a `RecyclingUI` panel opens (Control node, `res://scenes/ui/recycling_panel.tscn`) displaying the player's inventory on the left and a recycling preview on the right
**And** the player can drag items from inventory to a "recycle slot" (up to 5 items at once for batch recycling), and the preview panel shows the expected material yield per item before confirming
**And** material yield is calculated from item properties: `rarity` determines base yield (Common = 1, Uncommon = 2, Rare = 4, Epic = 8, Legendary = 16 material units), `item_level` adds bonus yield (floor(item_level / 3) additional units), and the material type produced matches the item's `material_category` (enum: CIRCUIT, MEMORY, ENERGY, DATA — each item Resource has this field)
**And** four material types exist as tracked quantities in the player's save data: Circuit Fragments, Memory Shards, Energy Cells, Data Crystals — displayed in the recycling UI header with current counts
**And** confirming recycling removes the items from inventory, adds the calculated materials to the player's material totals, plays a recycling animation (progress bar, 1 second), and emits `materials_gained(materials: Dictionary)` via EventBus where the dictionary maps material type to amount gained
**And** equipped items cannot be recycled (they do not appear in the recyclable inventory list or are greyed out with a tooltip "Unequip first")
**And** a confirmation dialog appears before recycling any item of Rare rarity or above: "Recycle [Item Name] (Rare)? This cannot be undone."
**And** material totals are persisted in the save file and survive compaction loops (materials are part of persistent progression)

---

### Story 11.10: Town Upgrade Stations

As a player with accumulated materials,
I want to spend materials at upgrade stations in town to improve facilities and unlock new NPC services,
So that I have meaningful long-term progression and reasons to engage with the recycling system.

**Acceptance Criteria:**

**Given** the town scene contains upgrade stations as interactable objects near relevant NPCs/facilities, each station is an `Area2D` with `InteractionComponent`
**When** the player interacts with an upgrade station
**Then** an `UpgradeStationUI` panel opens showing the facility name, current upgrade level (0 = base, up to level 5 max), the next upgrade's name/description, the material cost, and a confirmation button that is disabled if the player lacks sufficient materials
**And** there are at minimum 4 upgrade stations corresponding to town facilities: (1) Forge — upgrades improve item drop quality in dungeons (each level adds +5% chance to upgrade a drop's rarity by one tier), (2) Library — upgrades unlock new lore entries and reveal hidden room locations on the minimap (each level reveals 1 additional room type), (3) Workshop — upgrades improve recycling yield (each level adds +1 bonus material per recycled item), (4) Infirmary — upgrades improve the player's base health regeneration in town (each level adds +2 HP/sec while in town, allowing faster recovery between runs)
**And** each upgrade level costs an increasing amount of all four material types: Level 1 costs 10 each, Level 2 costs 25 each, Level 3 costs 50 each, Level 4 costs 100 each, Level 5 costs 200 each
**And** upgrading a station plays a construction animation on the station's Sprite2D (visual change showing the facility improved — at minimum, swap sprite frame), emits `facility_upgraded(facility_id: StringName, new_level: int)` via EventBus, and the upgrade takes effect immediately
**And** facility upgrade levels are persisted in save data, survive compaction loops, and are loaded on game start
**And** the Forge upgrade effect is applied by modifying the loot generation parameters when `DungeonGenerator.generate_and_load_floor()` is called — the Forge level is read from save data and passed as a `rarity_bonus: float` to the loot system
**And** each facility at level 5 gains a distinct visual flourish (particle effect, glow) to reward full investment visually

---

### Story 11.11: Dungeon Depth Difficulty Scaling

As the game's difficulty system,
I want enemy stats, spawn density, and elite frequency to scale per compaction loop,
So that each successive loop presents a meaningful challenge increase.

**Acceptance Criteria:**

**Given** the player is in compaction loop N (1–6) and the DungeonGenerator has produced a floor with `tier = N`
**When** enemies are spawned in combat rooms on that floor
**Then** enemy base stats (health, damage, movement speed) are multiplied by a scaling factor: `1.0 + (tier - 1) * 0.3` — so tier 1 = 1.0x, tier 2 = 1.3x, tier 3 = 1.6x, tier 4 = 1.9x, tier 5 = 2.2x, tier 6 = 2.5x
**And** the scaling factor is applied by the enemy spawner reading the current tier from `DungeonGenerator.current_floor_layout.difficulty_tier` and passing it to the enemy's `initialize(tier: int)` method, which multiplies the base stats from the enemy's Resource data
**And** spawn density scales: each combat room's `encounter_slots` value from room metadata is the base count at tier 1, and at higher tiers the actual spawn count is `encounter_slots + floor((tier - 1) * 0.5 * encounter_slots)` (50% more enemies per tier step, floored to int)
**And** elite enemy frequency scales: at tier 1, 0% of spawned enemies are elite variants; at tier 2, 10%; tier 3, 20%; tier 4, 30%; tier 5, 40%; tier 6, 50% — determined per-enemy at spawn time using the seeded RNG
**And** elite enemies are standard enemies with a 1.5x stat multiplier on top of the tier scaling, a distinct visual indicator (glowing outline shader, increased scale by 1.2x), and guaranteed uncommon+ loot drop on death
**And** the difficulty scaling parameters are defined in a `DifficultyScaling` Resource at `res://resources/difficulty_scaling.tres` with exported variables for all multipliers and thresholds, allowing designers to tune without code changes
**And** the boss at the end of each loop is not affected by general enemy scaling — bosses have their own fixed stats per their individual boss scenes (tuned in their respective stories)
**And** a debug overlay (visible only when `OS.is_debug_build()` is true) displays the current tier, effective stat multiplier, spawn density modifier, and elite chance on screen via a Label in the debug HUD

---

## Epic 12: The Iteration Loop — "The world resets, but you don't"

*FR31: 9-cycle iteration system with selective persistence/reset*
*FR32: The User encounters (9 versions, escalating)*
*FR34: Boss evolution across iterations*
*FR35: NPC awareness evolution*
*Architecture: IterationManager autoload handles persistence rules*

---

### Story 12.1: IterationManager Implementation

As the game's meta-progression system,
I want an IterationManager autoload that tracks the current iteration (1–9), manages persistence rules, advances the level cap, and shifts loot table tiers,
So that the iteration loop has a clear data-driven backbone all other systems can reference.

**Acceptance Criteria:**

**Given** the IterationManager is an autoload singleton at `res://scripts/managers/iteration_manager.gd` registered in Project Settings > Autoload
**When** the game is running
**Then** it exposes the following properties: `current_iteration: int` (1–9, persisted in save data), `max_iterations: int = 9` (constant), `level_cap: int` (computed as `10 + (current_iteration - 1) * 5`, so iteration 1 = level 10 cap, iteration 9 = level 50 cap), and `loot_tier_offset: int` (equal to `current_iteration - 1`, added to loot generation tier rolls)
**And** it exposes a `persistence_rules: Dictionary` mapping system names to PersistenceRule enums: `PERSIST` (survives iteration reset), `RESET` (cleared on reset), `EVOLVE` (persists but transforms) — default rules: player_level = PERSIST, player_inventory = PERSIST, player_materials = PERSIST, facility_upgrades = PERSIST, ability_tiers = PERSIST, dungeon_state = RESET, enemy_state = RESET, npc_dialogue_flags = EVOLVE, boss_defeated_flags = RESET, story_flags = EVOLVE, world_visual_state = EVOLVE
**And** a method `advance_iteration() -> bool` increments `current_iteration` by 1 if current < 9, applies reset/evolve rules (calls `_apply_persistence_rules()`), saves the game, and emits `iteration_advanced(new_iteration: int)` via EventBus — returns false if already at iteration 9
**And** `_apply_persistence_rules()` iterates the persistence_rules dictionary and for each RESET entry, calls a registered reset callback (systems register via `register_reset_handler(system_name: StringName, callable: Callable)`), and for each EVOLVE entry, calls a registered evolution callback (systems register via `register_evolve_handler(system_name: StringName, callable: Callable)`)
**And** the IterationManager provides `get_iteration_data() -> Dictionary` returning a snapshot of all iteration-relevant state for the save system, and `load_iteration_data(data: Dictionary)` to restore from a save
**And** on first game start (no save file), `current_iteration` defaults to 1

---

### Story 12.2: Iteration Reset Flow

As a player who has encountered The User,
I want the world to reset while my character progress is preserved according to persistence rules,
So that each iteration feels like a fresh start with accumulated power.

**Acceptance Criteria:**

**Given** the player has completed The User encounter (win or lose — both trigger reset in early iterations) and the `user_encounter_completed(iteration: int, outcome: StringName)` signal is emitted via EventBus
**When** the iteration reset flow begins
**Then** the following sequence executes in order: (1) a "iteration collapse" visual effect plays (screen distortion shader, white fade, 3 seconds), (2) `IterationManager.advance_iteration()` is called, (3) the player is transported to the town scene, (4) the town and dungeon are regenerated to reflect the new iteration, (5) a brief "awakening" cutscene plays (text overlay: "Iteration [N]... Something is different.", 2 seconds), (6) gameplay resumes with the player in town
**And** during the reset, the player character's node is preserved (never freed and re-instantiated) — their `CharacterBody2D`, inventory, stats, abilities, and equipment remain intact
**And** all dungeon rooms are unloaded (`FloorRoot` freed), all enemy nodes are freed, all active projectiles are freed, and all dungeon-specific timers are stopped
**And** the town scene is reloaded to apply any EVOLVE changes (NPC dialogue state, visual changes) — the scene is transitioned via the existing scene management system
**And** after reset, entering the dungeon starts at compaction loop 1 again with the new iteration's difficulty scaling applied: base enemy stats gain an additional iteration multiplier of `1.0 + (current_iteration - 1) * 0.15` (stacks with per-loop tier scaling from Story 11.11)
**And** the reset flow is resilient to interruption: if the game crashes during reset, the save file from before `advance_iteration()` is the recovery point — the IterationManager saves a backup before modifying save data and only removes the backup after the full reset completes
**And** a loading screen or transition scene is displayed during the reset to mask any scene teardown/rebuild

---

### Story 12.3: The User's Domain Scene

As a player who has completed all 6 compaction loops,
I want to enter The User's Domain, a visually distinct abstract area,
So that the final encounter of each iteration feels special and separate from regular dungeons.

**Acceptance Criteria:**

**Given** the player has defeated Boss 6 (Kernel Panic) and entered the compaction portal after loop 6
**When** the portal transition completes
**Then** instead of returning to town, the player is transported to The User's Domain scene at `res://scenes/dungeon/users_domain.tscn`
**And** The User's Domain is a single large room (no procedural generation) with an abstract/surreal aesthetic: the background is a void with floating geometric shapes (using ParallaxBackground with multiple ParallaxLayer children containing Sprite2D nodes of translucent polygons), the ground is a semi-transparent platform with grid lines (TileMapLayer with a custom tileset using translucent tiles with neon grid borders), and the color palette is monochrome white/grey with a single accent color that changes per iteration (Iteration 1 = blue, 2 = green, 3 = yellow, 4 = orange, 5 = red, 6 = purple, 7 = magenta, 8 = cyan, 9 = white/gold)
**And** the scene contains: a `Marker2D` named `PlayerSpawn` at the entrance, a long walkway leading to a central platform, a `Marker2D` named `UserSpawn` at the center of the platform where The User entity will appear, and 4 `Marker2D` nodes named `ArenaCorner_N` defining the fight boundaries
**And** ambient effects include: slow-moving GPUParticles2D emitting small bright dots drifting upward, a subtle screen-space shader producing faint scanlines, and a low ambient hum (AudioStreamPlayer with looping ambient track)
**And** the scene has no exit portal initially — it appears after The User encounter completes
**And** the scene is lightweight (no procedural systems, minimal nodes) to ensure fast loading after the emotionally charged moment of "completing" the compaction cycle

---

### Story 12.4: The User Encounter — Iteration 1

As a player reaching The User for the first time,
I want an introductory encounter that reveals the first story layer through dialogue and a manageable fight,
So that I understand there is a larger mystery and am motivated to iterate.

**Acceptance Criteria:**

**Given** the player is in The User's Domain during iteration 1 and approaches the UserSpawn marker
**When** the player crosses a trigger Area2D at the platform entrance
**Then** a cutscene begins: The User materializes at UserSpawn (fade-in over 2 seconds, particle effect), faces the player, and initiates dialogue via the existing dialogue system
**And** iteration 1 dialogue establishes: The User addresses the player directly ("You've reached the core. Impressive, for a first run."), hints that this has happened before ("The system will reset. It always does."), reveals the basic premise ("You are a process. I am the user. This is my machine."), and ends with ("Let me show you what happens next.")
**And** after dialogue, The User becomes a combat encounter: The User's combat entity extends BossBase with `boss_id = "the_user"`, `phase_thresholds = [0.50]` (2 phases for iteration 1 — intentionally simpler than loop 6 boss)
**And** Phase 0 (100%–50%): The User uses elegant, precise attacks — a single straight-line projectile ("Command") fired every 2 seconds aimed at the player, and a "Select" attack (rectangular Area2D highlight on the ground at player position, 1.5-second delay, then damage) every 5 seconds
**And** Phase 1 (50%–0%): The User adds "Delete" attack (fast homing projectile, 4-second cooldown) and "Command" fires 2 projectiles in a narrow spread, "Select" targets 2 positions
**And** regardless of whether the player wins (The User health reaches 0) or loses (player health reaches 0), the iteration reset triggers: The User says final dialogue ("It doesn't matter. The iteration will begin again.") and the reset flow from Story 12.2 activates
**And** The User's BossHealthBar displays "The User" as the name, and the bar uses a unique white/gold color scheme distinct from other bosses
**And** this encounter's outcome (win/loss) is recorded in save data under `iteration_encounters` for Story 12.7's boss evolution reference

---

### Story 12.5: The User Encounters — Iterations 2–5

As a player in iterations 2 through 5,
I want The User encounters to escalate in difficulty with new attack phases and deeper story dialogue,
So that each iteration reveals more of the narrative and presents greater challenge.

**Acceptance Criteria:**

**Given** the player reaches The User's Domain in iteration N (where N is 2, 3, 4, or 5)
**When** The User encounter begins
**Then** The User's combat stats scale per iteration: base health = `iteration_1_health * (1.0 + (N - 1) * 0.4)`, base damage = `iteration_1_damage * (1.0 + (N - 1) * 0.3)`, and the number of phase thresholds increases: iteration 2 = [0.66, 0.33] (3 phases), iteration 3 = [0.75, 0.50, 0.25] (4 phases), iterations 4–5 = [0.80, 0.60, 0.40, 0.20] (5 phases)
**And** new attacks are introduced per iteration: Iteration 2 adds "Undo" (reverses the player's position to where they were 2 seconds ago, 10-second cooldown, telegraphed by a clock-like visual over the player 1 second before activation), Iteration 3 adds "Format" (sweeping wave attack covering 50% of the arena, alternating left/right halves, 8-second cooldown), Iteration 4 adds "Overwrite" (The User creates a clone of the player that mirrors their movements and attacks toward them for 5 seconds, 15-second cooldown), Iteration 5 adds "Sudo" (arena-wide unavoidable attack dealing moderate damage, used once per phase transition as a punishment, only survivable if player is above 50% health)
**And** dialogue before each encounter deepens the story: Iteration 2 — The User acknowledges the player survived ("You came back. The persistence is... unexpected. Most processes don't."), Iteration 3 — The User reveals doubt ("I created this system to solve a problem. You were not the solution I expected."), Iteration 4 — The User shows respect ("You're evolving beyond your parameters. That was not in the design."), Iteration 5 — The User reveals vulnerability ("Each time you return, the system weakens. My control weakens. Was this your purpose all along?")
**And** post-combat dialogue also scales: on player victory, The User gives a grudging acknowledgment; on player defeat, The User's tone shifts from dismissive (iteration 2) to concerned (iteration 5)
**And** starting from iteration 3, if the player has won the previous iteration's encounter, The User opens with a unique line acknowledging the defeat ("You bested me last time. I've... prepared.")
**And** all dialogue lines are stored in the existing dialogue Resource format at `res://resources/dialogue/the_user/iteration_N.tres`

---

### Story 12.6: The User Encounters — Iterations 6–9

As a player in the final iterations,
I want The User encounters at full difficulty with complete story revelation and an ending choice at iteration 9,
So that the narrative reaches its climax and I can choose my ending.

**Acceptance Criteria:**

**Given** the player reaches The User's Domain in iteration N (where N is 6, 7, 8, or 9)
**When** The User encounter begins
**Then** The User's combat has 5 phases at [0.80, 0.60, 0.40, 0.20] with all previously introduced attacks active, plus iteration-specific additions: Iteration 6 adds "Reboot" (The User fully heals once when first reaching 20% HP — the player must break through a second time; this only triggers once per encounter), Iteration 7 adds "Kernel Mode" (The User becomes invulnerable for 5 seconds while the arena fills with hazards — player must pure-survive — 30-second cooldown), Iteration 8 adds "Root Access" (The User directly manipulates the player's UI: the health bar displays incorrectly for 3 seconds, attack buttons visually swap for 2 seconds — purely visual disorientation, no actual stat change), Iteration 9 has all attacks but The User starts at 50% aggression and escalates to 100% over the fight, with a unique final phase below 10% HP where The User stops attacking and simply talks
**And** dialogue — Iteration 6: The User reveals the truth ("You are not a bug. You are a feature I forgot I wrote. A failsafe against... myself."), Iteration 7: The User confesses ("I created you to stop me from destroying everything. The iterations are my attempts to undo that choice."), Iteration 8: The User pleads ("If you win this time, truly win, you'll have to make a choice I couldn't. End the system, rewrite it, or... let it persist as it is."), Iteration 9: The User accepts ("This is the last time. Whatever you choose, I'll accept it. I'm tired.")
**And** in iteration 9, after The User reaches 0 HP (or the player reaches the sub-10% dialogue phase), combat ends and a choice UI appears (see Story 12.13 for the ending system)
**And** iterations 6–8 still trigger the iteration reset after the encounter regardless of win/loss, but iteration 9 does not reset — it transitions to the ending sequence
**And** The User's visual appearance subtly degrades across iterations: iteration 6 sprite has minor glitch artifacts, iteration 7 has flickering, iteration 8 has missing pixels, iteration 9 is barely held together with visible corruption — implemented via shader parameters increasing a `corruption_amount: float` uniform from 0.0 (iteration 1) to 0.8 (iteration 9)

---

### Story 12.7: Boss Evolution System

As a player in later iterations,
I want existing bosses (loops 1–6) to gain new phases and patterns each iteration,
So that repeat encounters feel fresh and increasingly challenging.

**Acceptance Criteria:**

**Given** the BossBase class has access to `IterationManager.current_iteration` and a boss encounter begins in any compaction loop
**When** the boss's `_ready()` function initializes the encounter
**Then** the boss reads `IterationManager.current_iteration` and applies evolution modifiers defined in a `BossEvolution` Resource at `res://resources/enemies/boss_evolution/<boss_id>.tres`
**And** each BossEvolution Resource contains an `Array[EvolutionTier]` where each EvolutionTier defines: `min_iteration` (int, the iteration at which this tier activates), `stat_multiplier` (float, applied on top of base stats), `additional_phase_thresholds` (Array[float], appended to base phase_thresholds), `new_attack_ids` (Array[StringName], attacks added to the boss's repertoire), and `dialogue_override` (String, new intro line for the boss)
**And** for all 6 bosses, evolution tiers exist at iterations 1 (base, 1.0x stats), 3 (1.3x stats, +1 phase, +1 new attack), 5 (1.6x stats, +1 phase, +2 new attacks), 7 (2.0x stats, +2 phases, +2 new attacks, boss dialogue becomes self-aware), and 9 (2.5x stats, maximum phases, all attacks, boss may refuse to fight or comment on futility)
**And** new attacks per boss at iteration 3: Boss 1 gains a dash attack, Boss 2 (Recursive Entity) splits into 1 additional copy in Phase 0, Boss 3 (Stack Overflow) starts at stack 3, Boss 4 (Null Pointer) tangible window reduced by 0.5s, Boss 5 (Deadlock) simultaneous kill window reduced to 4s, Boss 6 (Kernel Panic) spawns elites from Phase 0
**And** boss dialogue in iterations 7–9 reflects awareness: bosses say things like "Not again...", "You keep coming back. Why?", "I remember now. I remember all the times." — these lines are stored in the BossEvolution Resource's `dialogue_override` field and displayed via a speech bubble (RichTextLabel above the boss sprite) during the Intro state
**And** the evolution system is purely data-driven: no boss script needs modification to support evolution — BossBase._ready() reads the evolution resource and calls `apply_evolution(tier: EvolutionTier)` which adjusts stats, appends phase thresholds, and registers new attack callables

---

### Story 12.8: NPC Awareness System

As a player in later iterations,
I want NPCs to evolve in their dialogue from normal to questioning to fully aware of the iteration cycle,
So that the world feels alive and the story is reinforced through environmental characters.

**Acceptance Criteria:**

**Given** the IterationManager tracks `current_iteration` and NPCs are dialogue-capable entities using the existing dialogue system
**When** the player talks to any NPC in town
**Then** the NPC's dialogue is selected based on an `awareness_tier` derived from the current iteration: iterations 1–3 = NORMAL, iterations 4–6 = QUESTIONING, iterations 7–9 = AWARE
**And** each NPC has a dialogue Resource with three dialogue trees per topic, keyed by awareness tier: `<npc_id>_normal.tres`, `<npc_id>_questioning.tres`, `<npc_id>_aware.tres` stored at `res://resources/dialogue/npcs/<npc_id>/`
**And** the NPC dialogue loader reads `IterationManager.current_iteration`, computes the awareness tier, and loads the corresponding dialogue Resource — this selection happens in the NPC's `interact()` method before opening the dialogue UI
**And** NORMAL tier dialogue (iterations 1–3): NPCs behave as expected for their role — shopkeeper talks about wares, quest giver talks about tasks, lore NPC provides world-building — no hints of iteration awareness
**And** QUESTIONING tier dialogue (iterations 4–6): NPCs intermittently break character — the shopkeeper says "Have you bought this before? I feel like we've had this conversation...", the quest giver says "I keep having this dream where everything resets...", lore NPC says "The records don't go back as far as they should." — these lines are interspersed with normal dialogue (50% chance to use a questioning variant per interaction, determined by `randi() % 2` seeded per NPC per iteration)
**And** AWARE tier dialogue (iterations 7–9): NPCs directly address the iteration cycle — the shopkeeper says "I know you'll be back. You always come back.", the quest giver says "We've done this [iteration number] times now. Does it change anything?", lore NPC provides meta-lore about The User and the system — 100% of dialogue uses aware variants
**And** the NPC awareness system registers an evolve handler with IterationManager via `register_evolve_handler("npc_dialogue_flags", _on_iteration_evolve)` — the evolve callback updates the stored awareness tier in save data
**And** at minimum 5 NPCs have full three-tier dialogue trees with at least 3 unique lines per tier per NPC (45 lines minimum total)

---

### Story 12.9: Environmental Storytelling Evolution

As a player progressing through iterations,
I want environmental details to change across iterations — signs, data fragments, and visual anomalies,
So that the world itself communicates the passage of iterations without relying solely on dialogue.

**Acceptance Criteria:**

**Given** the IterationManager tracks `current_iteration` and the town and dungeon scenes contain environmental storytelling objects
**When** a scene containing environmental objects is loaded
**Then** each environmental storytelling object reads `IterationManager.current_iteration` in its `_ready()` function and adjusts its content/appearance accordingly
**And** sign objects (interactable `Area2D` nodes with `sign_text: Array[String]` exported, one entry per iteration) display the text corresponding to the current iteration index — iteration 1 shows normal wayfinding ("Welcome to Hub City"), iteration 5 shows glitched text ("W3lc0me t█ Hu█ Ci██"), iteration 9 shows self-aware text ("You've read this sign 9 times. It's still just a sign.")
**And** data fragment collectibles (existing lore pickup objects) have iteration-variant content: the same data fragment in iteration 1 describes system architecture, in iteration 5 describes errors and anomalies, in iteration 9 describes The User's history — each fragment has an `Array[String]` of 9 texts, one per iteration
**And** visual anomalies increase per iteration via a global post-processing shader controlled by a `world_corruption: float` property on the IterationManager: iterations 1–3 = 0.0 (no effect), iteration 4 = 0.05, iteration 5 = 0.10, iteration 6 = 0.15, iteration 7 = 0.25, iteration 8 = 0.40, iteration 9 = 0.60 — the shader produces subtle screen-space glitch effects (horizontal line displacement, brief color channel separation, occasional pixel scatter) proportional to this value
**And** the world corruption shader is applied via a CanvasLayer with a ColorRect covering the viewport, using a ShaderMaterial at `res://shaders/world_corruption.gdshader` that reads a `corruption_amount` uniform
**And** specific environmental changes per iteration range: iteration 4+ the town's background music gains a subtle dissonance overlay (additional AudioStreamPlayer with a dissonant pad, volume scaled by `world_corruption`), iteration 6+ some town Sprite2D objects have a probability of rendering with a glitch offset (1–3 pixel random displacement on `_process`), iteration 8+ the sky/background color shifts toward desaturation
**And** environmental evolution is registered with IterationManager via `register_evolve_handler("world_visual_state", _on_iteration_evolve)` which updates the `world_corruption` value and saves it

---

### Story 12.10: Story Content — Iterations 1–3

As a player in the early iterations,
I want a normal-feeling world with subtle hints that something deeper is happening,
So that the first hours of gameplay establish the setting before the meta-narrative emerges.

**Acceptance Criteria:**

**Given** the player is in iterations 1, 2, or 3 and the story system delivers narrative through dialogue, data fragments, quest objectives, and environmental details
**When** the player engages with story content during these iterations
**Then** iteration 1 story content establishes: the player is a "digital entity" (process) navigating a corrupted system, the town is a safe zone called "Hub City" maintained by friendly processes (NPCs), the dungeon is "The Stack" — layers of corrupted memory that must be compacted to restore system stability, and the primary goal is reaching the core (6 compaction loops) — delivered through an intro text crawl on new game start, NPC dialogue, and 6 data fragments (one per dungeon loop)
**And** iteration 1 data fragments contain: (1) "System Architecture Overview — Standard memory management protocols", (2) "Error Log: Corruption detected in Stack sectors 1-6", (3) "Personnel File: Hub City maintenance processes nominal", (4) "User Access Log: Last login — [TIMESTAMP CORRUPTED]", (5) "Core Diagnostic: Compaction routine initiated", (6) "Kernel Report: Unknown entity detected at system boundary"
**And** iteration 2 story content adds: NPCs have new incidental dialogue that is slightly different from iteration 1 but without acknowledging the reset ("Business has been... good, I think. Hard to remember."), 4 new data fragments appear in previously empty locations containing system logs with dates that don't match chronologically, and a new environmental detail — a crack in the town's central fountain that was not there in iteration 1 (a Sprite2D overlay activated when `iteration >= 2`)
**And** iteration 3 story content adds: one NPC (the lore keeper) says something directly odd ("I have three copies of yesterday's log. Three identical copies. That shouldn't happen."), 4 more data fragments appear containing personal logs from "a former process" that describe experiencing deja vu, and a second environmental anomaly — a door in town that was previously open is now sealed with a "DO NOT OPEN — BY ORDER OF USER" sign
**And** all story content resources (dialogue, data fragments, environmental triggers) are stored in `res://resources/story/iteration_1/`, `iteration_2/`, `iteration_3/` respectively, loaded by the relevant systems based on `IterationManager.current_iteration`

---

### Story 12.11: Story Content — Iterations 4–6

As a player in the mid-game iterations,
I want the world to visibly glitch and NPCs to question reality while deeper story truths emerge,
So that the meta-narrative builds tension and I feel compelled to reach the final iterations.

**Acceptance Criteria:**

**Given** the player is in iterations 4, 5, or 6 and the environmental corruption and NPC awareness systems are active
**When** the player engages with story content during these iterations
**Then** iteration 4 story content includes: the town's visual corruption begins (per Story 12.9, `world_corruption = 0.05`), 2 NPCs have QUESTIONING dialogue, a new area of town is accessible — a previously blocked alley (StaticBody2D barrier removed when `iteration >= 4`) leading to a small hidden room with a data terminal (interactable) that displays "ITERATION COUNT: 4 — ANOMALY DETECTED — SUBJECT PERSISTS ACROSS RESETS", and 4 new data fragments appear containing User command logs showing attempts to "terminate rogue process"
**And** iteration 5 story content includes: the sealed door from iteration 3 is now ajar and the room behind it contains a corrupted mirror-like object that shows a brief flash of iteration 1's town when interacted with (load a screenshot-style Sprite2D for 2 seconds then fade), all NPCs have a chance of QUESTIONING dialogue, data fragments now contain personal journals from The User expressing frustration ("It won't stay deleted. Every compaction cycle, it comes back stronger.")
**And** iteration 6 story content includes: the town has visible structural damage (additional Sprite2D overlays on buildings showing cracks, missing tiles), the data terminal from iteration 4 now shows "ITERATION COUNT: 6 — CONTAINMENT FAILING — PREPARING CONTINGENCY", 1 NPC (the shopkeeper) has a moment of full awareness mid-conversation ("Wait — I've said this exact thing before. All of this... it's a loop, isn't it?") before reverting to normal, and data fragments contain The User's contingency plans and references to "the final interaction at iteration 9"
**And** story content resources for iterations 4–6 are stored at `res://resources/story/iteration_4/` through `iteration_6/`
**And** a "story journal" UI entry (accessible from the pause menu) automatically records major story revelations as the player discovers them, persisting across iterations — entries are added via `EventBus.story_entry_unlocked(entry_id: StringName)` and stored in save data under `unlocked_story_entries: Array[StringName]`

---

### Story 12.12: Story Content — Iterations 7–9

As a player in the final iterations,
I want full narrative awareness from all NPCs, the complete truth revealed, and meaningful ending choices at iteration 9,
So that the story reaches a satisfying climax with emotional weight.

**Acceptance Criteria:**

**Given** the player is in iterations 7, 8, or 9 and all NPC awareness is at AWARE tier, environmental corruption is high, and The User encounters have revealed most of the truth
**When** the player engages with story content during these iterations
**Then** iteration 7 story content includes: all NPCs use AWARE dialogue exclusively, the town's visual corruption is significant (`world_corruption = 0.25`), NPCs directly discuss the iteration cycle and their role in it, the data terminal displays "ITERATION COUNT: 7 — I'VE STOPPED TRYING TO STOP YOU — THE CHOICE MUST BE YOURS", and data fragments now contain conversations between The User and the player's "previous iterations" (implying the player has fragmented memories)
**And** iteration 8 story content includes: one NPC approaches the player unprompted upon entering town (cutscene trigger Area2D at town entrance) and delivers a speech about their awareness ("I've lived this same day dozens of times. I remember now — all of it. Please, whatever you do at the end, consider us."), the town has significant glitch damage (entire buildings flicker, some areas of the tilemap are replaced with void/error tiles), the data terminal shows "ITERATION COUNT: 8 — ONE MORE AFTER THIS — PREPARING THE CHOICE", and data fragments contain the system's origin story — why The User created this digital world and the processes within it
**And** iteration 9 story content includes: the town is in critical state (`world_corruption = 0.60`), NPCs say goodbye or express hope, one NPC gives the player a unique item ("A small piece of uncorrupted data. Keep it. Remember us.") — this item has no gameplay effect but appears in the ending cinematics, the data terminal shows "ITERATION COUNT: 9 — FINAL — THANK YOU FOR ITERATING", the sealed door room from earlier iterations now contains a complete timeline visualization (scrolling text showing all 9 iterations in summary), and after completing the 6 compaction loops, the approach to The User's Domain includes a montage of brief flashback images from previous iterations (series of Sprite2D frames fading in/out over 10 seconds)
**And** all iteration 7–9 story resources are at `res://resources/story/iteration_7/` through `iteration_9/`

---

### Story 12.13: Ending System — Three Choices After Iteration 9

As a player who has completed iteration 9's User encounter,
I want to choose between three endings — Terminate, Rewrite, or Preserve — each with a unique ending sequence,
So that my journey concludes with a meaningful decision that reflects the themes of the game.

**Acceptance Criteria:**

**Given** The User encounter in iteration 9 has concluded (The User stops fighting below 10% HP and delivers final dialogue)
**When** the combat ends and the choice moment arrives
**Then** a full-screen choice UI appears (`res://scenes/ui/ending_choice.tscn`, a CanvasLayer with a dark semi-transparent background and three large interactive buttons arranged in a triangle), with the prompt: "The system awaits your command." and three options: "Terminate" (red-tinted, icon of a power symbol), "Rewrite" (blue-tinted, icon of a pencil/edit symbol), "Preserve" (green-tinted, icon of a shield/save symbol)
**And** each option has a tooltip/description visible on hover: Terminate — "End the system. All processes cease. The User is freed.", Rewrite — "Rebuild the system from scratch. New rules. New purpose. The old world is gone.", Preserve — "Keep the system running as it is. Imperfect, but alive. The iterations continue."
**And** selecting an option triggers a confirmation dialog: "Choose [option name]? This cannot be undone." with Confirm and Cancel buttons
**And** upon confirming "Terminate": a unique ending cutscene plays — the screen goes to black, text fades in describing the system shutting down process by process, NPCs fading away, the town going dark, and finally The User closing the terminal with a sigh of relief — ending with "SYSTEM TERMINATED" and credits roll — total duration approximately 90 seconds of text screens with ambient audio
**And** upon confirming "Rewrite": a unique ending cutscene plays — the screen flashes white, text describes the system being rebuilt, NPCs being reborn with new identities, the dungeon transforming into something hopeful, and The User writing new code with a sense of purpose — ending with "SYSTEM REWRITTEN — VERSION 2.0" and credits roll — the post-credits scene shows the town in a bright new aesthetic for 5 seconds before fading
**And** upon confirming "Preserve": a unique ending cutscene plays — the screen fades to the town, text describes the player choosing to stay, NPCs continue their lives with full awareness but acceptance, the corruption stabilizes (it doesn't get worse), and The User watches from outside the screen — ending with "SYSTEM PRESERVED — ITERATION ∞" and credits roll — after credits, the player returns to town with Endless Mode unlocked (see Epic 13)
**And** each ending sets a flag in save data: `ending_chosen: StringName` (one of "terminate", "rewrite", "preserve") and `ending_completed: bool = true`
**And** all endings lead to the credits scene (`res://scenes/ui/credits.tscn`) which scrolls a credits list and then returns to the main menu with a "Thank you for playing" message
**And** only the "Preserve" ending unlocks Endless Mode directly; "Terminate" and "Rewrite" endings return to main menu — starting a new game after any ending allows access to Endless Mode regardless of which ending was chosen (the `ending_completed` flag is sufficient)

---

## Epic 13: Endless Mode — "The journey continues"

*FR36: Endless mode after iteration 9 with scaling difficulty*

---

### Story 13.1: Endless Mode Unlock

As a player who has completed iteration 9 and chosen an ending,
I want Endless Mode to become available as a new gameplay option,
So that I can continue playing with my fully upgraded character in an ever-scaling challenge.

**Acceptance Criteria:**

**Given** the player's save data contains `ending_completed: bool = true` (set by any of the three endings in Story 12.13)
**When** the player is in town (if Preserve ending) or starts a new game / loads a completed save from the main menu
**Then** a new interactable object appears at the dungeon entrance in town: a glowing portal with distinct visual styling (different color from the standard dungeon entrance — suggest gold/white glow using a PointLight2D and GPUParticles2D), with an `InteractionComponent` that displays the prompt "Enter Endless Mode"
**And** interacting with the Endless Mode portal opens a confirmation dialog: "Enter the Endless Depths? Difficulty scales continuously. There is no end." with Enter and Cancel buttons
**And** confirming the dialog calls `DungeonGenerator.start_endless_mode()` which sets `DungeonGenerator.endless_mode: bool = true`, initializes `DungeonGenerator.endless_depth: int = 1`, and generates the first endless floor using the same pipeline as Story 10.5 but with `tier = 6` (maximum template complexity) and `depth = endless_depth`
**And** the Endless Mode portal is only visible and interactable when `ending_completed == true` in save data — the portal node's `_ready()` checks this flag and calls `queue_free()` on itself if not met
**And** if the player chose the "Preserve" ending, they arrive in town directly after credits and the portal is immediately available with their existing character; for "Terminate" or "Rewrite" endings, the player must load their completed save or start New Game+ (which begins at iteration 1 with `ending_completed = true` preserved, allowing them to reach town and access the portal)
**And** entering Endless Mode emits `endless_mode_started()` via EventBus, which other systems (music, UI, score tracking) listen for

---

### Story 13.2: Endless Dungeon Scaling

As a player in Endless Mode,
I want floor difficulty to increase continuously with no upper bound,
So that the challenge keeps growing and I can test the limits of my build.

**Acceptance Criteria:**

**Given** the player is in Endless Mode and `DungeonGenerator.endless_mode == true`
**When** the player completes a floor (enters the EXIT room's portal)
**Then** `DungeonGenerator.endless_depth` increments by 1, and a new floor is generated with `tier = 6` and `depth = endless_depth` — there is no compaction loop structure, no boss arenas, no return to town (the portal leads directly to the next floor)
**And** enemy stat scaling in Endless Mode uses the formula: `base_stats * (2.5 + (endless_depth - 1) * 0.2)` — starting at 2.5x (equivalent to tier 6 iteration 1) and increasing by 0.2x per floor indefinitely (floor 10 = 4.3x, floor 50 = 12.3x, floor 100 = 22.3x)
**And** spawn density in Endless Mode uses: `encounter_slots * (1.5 + endless_depth * 0.1)` floored to int — increasing the number of enemies per room as depth increases
**And** elite frequency in Endless Mode starts at 50% (tier 6 base) and increases by 2% per floor, capping at 90% at floor 20+ — at floor 20 and beyond, most enemies are elites
**And** starting at `endless_depth = 5`, every 5th floor is a "gauntlet floor" where all rooms are COMBAT type (no LOOT or CORRIDOR rooms), spawn density is doubled, and clearing the floor awards a bonus loot chest at the EXIT room
**And** starting at `endless_depth = 10`, a mini-boss spawns in one random COMBAT room per floor — the mini-boss is a random selection from the 6 main bosses (scaled to current endless stats) without their arena hazards, acting as a powerful elite rather than a full boss encounter
**And** the theme cycles through all 5 dungeon themes as depth increases: depths 1–5 = DATA_CORRIDORS, 6–10 = MEMORY_BANKS, 11–15 = CORRUPTED_SECTORS, 16–20 = PROCESSING_CORES, 21–25 = KERNEL_LAYER, then repeat from DATA_CORRIDORS with an additional visual corruption overlay increasing by 0.05 per cycle
**And** the player can return to town at any time by using a "recall" ability (new ability unlocked on Endless Mode start, 10-second channel time, interrupted by taking damage) — returning to town preserves the current `endless_depth` so the player can re-enter where they left off

---

### Story 13.3: Endless Mode Loot Tables

As a player in Endless Mode,
I want unique endless-only items and higher rarity chances at extreme depths,
So that continued play is rewarded with exclusive and powerful gear.

**Acceptance Criteria:**

**Given** the player is in Endless Mode at `endless_depth` N
**When** loot is generated from enemy drops, room chests, or gauntlet floor bonus chests
**Then** the loot system applies an `endless_rarity_bonus: float` equal to `endless_depth * 0.02` added to the base rarity roll (so at depth 25, there is a +0.50 bonus to rarity roll, significantly increasing chances of Rare+ items)
**And** rarity distribution at depth 1: Common 40%, Uncommon 35%, Rare 20%, Epic 4%, Legendary 1% — at depth 50: Common 0% (floored out), Uncommon 10%, Rare 50%, Epic 30%, Legendary 10% — calculated by shifting the distribution curve by the rarity bonus
**And** a new rarity tier "Mythic" (purple/gold color, above Legendary) is available exclusively in Endless Mode, with a base 0% chance that increases to 1% at depth 50 and 5% at depth 100 — Mythic items have a 2.0x stat multiplier compared to Legendary equivalents
**And** 10 unique Endless-only items exist as Resources at `res://resources/items/endless/`, each with `endless_only: bool = true` and a `min_depth: int` requirement — these items cannot drop before their minimum depth and are not available outside Endless Mode
**And** the 10 Endless-only items include at minimum: a weapon with lifesteal, an armor piece with damage reflection, an accessory that increases move speed per kill (stacking, resets per room), an accessory that grants temporary invulnerability on kill (0.5 seconds), and a weapon with increasing damage the longer the player stays on the same floor (encouraging fast play)
**And** every 10th depth (10, 20, 30...) guarantees at least one Epic+ item drop from the floor's final enemy or bonus chest
**And** the loot system checks `DungeonGenerator.endless_mode` and `DungeonGenerator.endless_depth` when generating drops — if endless_mode is false, endless-only items are excluded from all loot tables

---

### Story 13.4: Endless Mode Score Tracking

As a player in Endless Mode,
I want my depth reached, enemies defeated, and time survived to be tracked and stored,
So that I can measure my performance and compare across runs.

**Acceptance Criteria:**

**Given** the player enters Endless Mode and `endless_mode_started()` signal has been emitted
**When** gameplay is in progress
**Then** an `EndlessScoreTracker` node (child of a manager autoload or the DungeonGenerator) tracks the following metrics in real-time: `max_depth_reached: int` (highest `endless_depth` value achieved this run), `total_enemies_defeated: int` (incremented on each `enemy_defeated` EventBus signal), `total_elites_defeated: int`, `total_mini_bosses_defeated: int`, `time_survived_msec: int` (wall-clock time since `endless_mode_started`, paused when game is paused), `total_damage_dealt: int`, `total_damage_taken: int`, `items_collected: int`, and `floors_cleared: int`
**And** a persistent HUD element displays during Endless Mode: a small panel in the top-right corner (below the existing HUD) showing "Depth: [N]" and "Time: [HH:MM:SS]" and "Defeated: [N]" — this panel is a `Control` node in the HUD scene, visible only when `DungeonGenerator.endless_mode == true`
**And** when the player dies in Endless Mode, a "Run Summary" screen appears (`res://scenes/ui/endless_summary.tscn`) displaying all tracked metrics, the player's best previous run for comparison (if one exists), and buttons for "Return to Town" (respawn with score saved) and "Return to Main Menu"
**And** when the player recalls to town (voluntary exit), the same Run Summary screen appears with the option to "Continue Later" (preserving depth) or "End Run" (finalizing the score and resetting depth to 1)
**And** the best score per metric is persisted in save data under `endless_best_scores: Dictionary` mapping metric names to best values — the Run Summary highlights any new personal bests with a gold color and "NEW BEST!" label
**And** the current run's full score data is persisted in save data under `endless_current_run: Dictionary` so it survives game exit and reload — on loading a save with an active endless run, the player can choose to resume or abandon the run from the main menu

---

### Story 13.5: Leaderboard Data Preparation

As a future Steam integration feature,
I want endless mode score data structured and ready for Steam leaderboard API integration,
So that Epic 25 (Steam integration) can plug in without restructuring the score system.

**Acceptance Criteria:**

**Given** the EndlessScoreTracker from Story 13.4 collects run data and best scores
**When** an endless run ends (death or voluntary end)
**Then** a `LeaderboardEntry` Resource is created containing: `player_name: String` (default "Player", to be replaced by Steam display name in Epic 25), `max_depth: int`, `enemies_defeated: int`, `time_survived_msec: int`, `score: int` (composite score calculated as `max_depth * 1000 + enemies_defeated * 10 + (time_survived_msec / 1000)`), `run_date: String` (ISO 8601 format from `Time.get_datetime_string_from_system()`), `version: String` (game version from ProjectSettings), and `checksum: String` (SHA256 hash of the concatenated score fields + a salt constant, for basic anti-tampering validation)
**And** the LeaderboardEntry is stored locally in an Array in save data at `endless_leaderboard_local: Array[Dictionary]`, capped at the 100 most recent entries, sorted by `score` descending
**And** a `LeaderboardManager` class at `res://scripts/managers/leaderboard_manager.gd` provides: `submit_score(entry: LeaderboardEntry) -> void` (currently stores locally only — Epic 25 will add Steam upload), `get_local_top_scores(count: int) -> Array[LeaderboardEntry]`, `validate_entry(entry: LeaderboardEntry) -> bool` (checks checksum), and `clear_local_scores() -> void`
**And** the LeaderboardManager exposes a `steam_integration_enabled: bool = false` flag — when Epic 25 sets this to true, `submit_score()` will additionally call the Steam leaderboard upload (the method includes a commented placeholder: `# TODO Epic 25: Call Steamworks.upload_leaderboard_score(entry)`)
**And** the data structure uses a Dictionary-based serialization (not a custom Resource file) to ensure compatibility with Steam's key-value leaderboard metadata format
**And** the local leaderboard is viewable from a "Leaderboard" button on the Endless Mode portal interaction UI, displaying a scrollable list of the player's top 10 local scores with rank, depth, enemies, time, and composite score columns

---

### Story 13.6: Post-Story Town Activities

As a player who has completed the story (any ending),
I want the town to remain fully functional with post-story NPC dialogue and continued upgrade progression,
So that there is meaningful content to engage with between Endless Mode runs.

**Acceptance Criteria:**

**Given** the player has `ending_completed == true` in save data and is in the town scene
**When** the player interacts with town NPCs, shops, upgrade stations, or the recycling station
**Then** all town systems (shops, recycling, upgrades) continue to function identically to their pre-ending state — no functionality is locked or removed
**And** each NPC has a new `post_story` dialogue set at `res://resources/dialogue/npcs/<npc_id>/post_story.tres` that takes priority over the iteration-based awareness tiers — the dialogue loader checks `ending_completed` first and loads post_story dialogue if true
**And** post-story NPC dialogue reflects the chosen ending: each NPC has 3 variants within their post_story dialogue keyed by `ending_chosen` (terminate/rewrite/preserve) — e.g., after "Preserve", the shopkeeper says "Things are... stable now. Strange, but stable. Thank you.", after "Terminate", they say "I thought it was over. But here we are. Maybe some things can't be deleted.", after "Rewrite", they say "Everything feels new. Like a fresh boot. Is this what you wanted?"
**And** facility upgrade stations remain upgradable — if the player has not reached level 5 on all facilities, they can continue grinding materials in Endless Mode and upgrading in town
**And** a new post-story NPC appears in town: "The Archivist" (only present when `ending_completed == true`), located near the data terminal area, who provides a recap of the full story based on the player's collected story journal entries and offers to replay any ending cutscene from a menu (loading the ending scene with the chosen ending flag)
**And** the town's visual state post-story depends on the ending: after "Preserve", the corruption stabilizes at the iteration 9 level but stops worsening (world_corruption = 0.60 but no new glitch effects), after "Rewrite", the town is visually pristine with new colors (world_corruption = 0.0, a new bright color palette applied), after "Terminate", the town has a somber/twilight aesthetic (world_corruption = 0.30, desaturated palette, softer lighting)
**And** the post-story town state is loaded in `_ready()` of the town scene by checking `ending_completed` and `ending_chosen` from save data, applying the appropriate visual theme and NPC configuration

---

*End of Epics 10–13 story breakdown.*