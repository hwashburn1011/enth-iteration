---
epic_id: 05
title: "Epic 05: Combat System Fixes"
phase: 2
status: DONE
priority: high
estimated_tasks: 20
---

# Epic 05: Combat System Fixes

## Overview
Fix the existing combat system's core issues before layering on the visual overhaul's new animations and VFX. The current implementation has broken hitbox timing, inconsistent damage pipelines, missing death transitions, and untuned parameters that make combat feel unresponsive. This epic addresses each issue methodically: first fixing the damage flow architecture, then tuning timing and values, then adding missing feedback systems. Combat must feel reliable and satisfying with placeholder art before investing in polished animations and effects.

## Success Criteria
- Player attacks consistently deal damage to enemies within the attack animation's swing frames
- Damage flows through a single unified pipeline (HurtboxComponent) with no duplicate or bypassed paths
- Enemy death, loot drops, and combat music triggers all function without errors
- Combat parameters (damage, HP, cooldowns, aggro range) are balanced for engaging early-game encounters

## Tasks

### Task 05.01: Audit Current Damage Pipeline Flow
**Status:** DONE
**Description:** Read through all combat-related scripts to map the current damage flow path. Trace from player input (attack action) → attack state in state machine → hitbox activation → collision detection with enemy hurtbox → damage calculation → HP reduction → death check. Document every script involved, every signal emitted, and every function called along this path. Identify where the pipeline breaks: are there multiple competing damage paths? Does damage bypass the HurtboxComponent? Are signals connected but not received? Create a flow diagram documenting the current (broken) state.
**Acceptance Criteria:**
- Written audit document traces the complete damage flow with file paths and function names
- All break points and inconsistencies are identified and cataloged
- Flow diagram shows current signal connections and where they fail

### Task 05.02: Consolidate Damage Through Single HurtboxComponent Path
**Status:** DONE
**Description:** Refactor the damage system so ALL damage flows through a single path: attacker's HitboxComponent detects overlap with target's HurtboxComponent, HurtboxComponent emits `damage_received(amount: int, source: Node3D)` signal, the entity's HealthComponent connects to this signal and applies HP reduction. Remove any direct HP manipulation that bypasses HurtboxComponent (e.g., scripts calling `enemy.take_damage()` directly without going through collision detection). Ensure HitboxComponent and HurtboxComponent are on correct physics layers (hitboxes on layer 2, hurtboxes on layer 3, with appropriate mask settings).
**Acceptance Criteria:**
- All damage in the game routes through HurtboxComponent → HealthComponent signal chain
- No script directly modifies HP without going through the damage pipeline
- Physics layers are correctly configured: hitbox layer 2 masks hurtbox layer 3 and vice versa

### Task 05.03: Fix Hitbox Timing and Positioning
**Status:** DONE
**Description:** The player's attack hitbox is either activating too early/late or positioned incorrectly relative to the attack animation, causing attacks to miss. Fix by: (1) Ensure the hitbox CollisionShape3D is positioned in front of the player character at arm's length (approximately 0.8m forward of character center, 0.4m wide arc), (2) Verify the hitbox only activates during the attack animation's swing frames (frames 3-6 of a 12-frame attack, or 0.1s-0.2s into a 0.4s attack), (3) Use animation method call tracks to call `hitbox.set_active(true)` at swing start and `hitbox.set_active(false)` at swing end instead of relying on timer-based activation.
**Acceptance Criteria:**
- Player attacks connect with enemies standing within melee range (0.5-1.2m away)
- Hitbox is only active during the swing phase, not during wind-up or recovery
- Activation is driven by animation events, not arbitrary timers

### Task 05.04: Fix Hitbox Deactivation and Multi-Hit Prevention
**Status:** DONE
**Description:** Ensure the hitbox properly deactivates after each swing and does not hit the same enemy multiple times per attack. Add a "hit list" Set to the HitboxComponent that tracks which enemies have already been hit during the current attack activation. When the hitbox collides with a HurtboxComponent, check if its owner is already in the hit list before applying damage. Clear the hit list when the hitbox is deactivated (attack ends). Also ensure the hitbox CollisionShape3D is disabled (not just the monitoring flag) when inactive to prevent phantom collisions.
**Acceptance Criteria:**
- A single attack swing hits each enemy exactly once, even if the hitbox overlaps for multiple frames
- The hit list is cleared between attacks, allowing the same enemy to be hit again on the next swing
- CollisionShape3D.disabled is set to true when the hitbox is inactive

### Task 05.05: Fix Attack Cooldown System
**Status:** DONE
**Description:** Tune the attack cooldown to feel responsive but prevent spam. The player should be able to attack again immediately after the follow-through frames end (0.4s total attack duration), with a minimum cooldown of 0.1s between attacks to prevent overlapping hitbox activations. Implement the cooldown in the attack state of the player's state machine: after the attack animation finishes (or at the "can_cancel" frame, ~frame 9 of 12), allow transition back to idle/move. If the player presses attack again during follow-through frames 9-12, queue the next attack to fire immediately after cooldown. This creates a responsive attack chain feel.
**Acceptance Criteria:**
- Player can attack at a rate of approximately 2 attacks per second when mashing
- Attack animation plays fully before the next attack begins (no animation canceling before frame 9)
- Queued attack input during follow-through fires immediately when cooldown ends

### Task 05.06: Fix Enemy Aggro Range and Detection
**Status:** DONE
**Description:** Review and fix the enemy aggro (detection) system. Enemies should detect the player using an Area3D sphere trigger with configurable radius per enemy type (basic enemies: 8m, ranged enemies: 12m, bosses: 20m or room-wide). When the player enters the aggro area, the enemy transitions from `idle` state to `chase` state. When the player exits aggro range + 3m buffer (hysteresis to prevent flickering), the enemy returns to `idle`. Ensure the aggro Area3D is on a detection-only physics layer (layer 4) that doesn't interact with combat hitboxes/hurtboxes.
**Acceptance Criteria:**
- Enemies detect the player at their configured aggro radius and begin chasing
- Enemies de-aggro when the player moves beyond aggro range + 3m hysteresis buffer
- Aggro detection uses a separate physics layer from combat collision

### Task 05.07: Add Attack Telegraph Animations for Enemies
**Status:** DONE
**Description:** Add a brief telegraph (wind-up) animation before each enemy attack so the player has time to react. The telegraph duration depends on enemy type: basic enemies telegraph for 0.3s (short, still somewhat reactive), elite enemies telegraph for 0.5s (readable, allows dodge), bosses telegraph for 0.8-1.0s (very clear, designed to be dodged). During the telegraph phase, the enemy plays a preparatory animation (rearing back, glowing, raising weapon) and cannot be interrupted. The telegraph must be visually distinct from the idle/walk animations so the player immediately recognizes the incoming attack.
**Acceptance Criteria:**
- All enemy attacks have a visible telegraph phase before damage frames activate
- Telegraph duration varies by enemy difficulty tier (basic 0.3s, elite 0.5s, boss 0.8-1.0s)
- Telegraph animation is visually distinct and not confusable with movement animations

### Task 05.08: Fix Knockback Direction and Force
**Status:** DONE
**Description:** Fix the knockback system so entities are pushed away from the damage source. Calculate knockback direction as `(target.global_position - source.global_position).normalized()` on the XZ plane (ignore Y to keep entities grounded). Apply knockback force via `CharacterBody3D.velocity += knockback_direction * knockback_force`. Knockback force values: player attacking enemy = 3.0 (noticeable push), enemy attacking player = 2.0 (slight push, doesn't feel unfair), boss attacking player = 5.0 (strong push for dodging importance). Apply knockback over 0.15s then decay via lerp to zero.
**Acceptance Criteria:**
- Knockback pushes the target directly away from the attacker on the XZ plane
- Force values are tuned per attacker type (player vs. basic enemy vs. boss)
- Knockback decays smoothly over 0.15s, not a jarring instant stop

### Task 05.09: Balance Damage Numbers and HP Pools
**Status:** DONE
**Description:** Set initial balance values for all combat participants. Player base damage: 8 per hit (scales with level/gear to ~15 at mid-game). Enemy HP by tier: basic enemies 15-25 HP (2-3 hits to kill), ranged enemies 10-15 HP (fragile), elite enemies 50-80 HP (sustained fight), mini-boss 150-200 HP, boss 300-500 HP. Player HP: 50 at level 1, scaling to 150 at max level. Enemy damage: basic enemies deal 5 per hit, elite deal 10, bosses deal 15-25 per hit. These values mean the player can take 5-10 hits before dying, and basic enemies die in 2-3 hits, creating a fast-paced combat loop.
**Acceptance Criteria:**
- All damage and HP values are defined in data resources, not hardcoded in scripts
- Basic enemy encounters last 3-8 seconds (a few attack exchanges)
- Player can survive 5+ hits from basic enemies, giving time to learn patterns

### Task 05.10: Fix Death State Transition
**Status:** DONE
**Description:** Fix the death state so entities cleanly transition when HP reaches zero. When HealthComponent emits `health_depleted`, the entity's state machine must immediately call `force_transition_to("death")` to override any other active state (including mid-attack or mid-knockback). The death state plays the death animation, disables all collision (hitbox, hurtbox, and CharacterBody3D collision), emits a `died` signal for loot/XP systems, waits for the death animation to complete, then either queues the node for deletion (enemies) or triggers the game-over screen (player). Fix the current issue where `force_transition_to` is not being called or the death state is not defined in the state machine.
**Acceptance Criteria:**
- Entities transition to death state immediately when HP reaches zero, from any other state
- Death state disables all collision to prevent post-death interactions
- `died` signal is emitted for external systems (loot, XP, quest tracking) before node removal

### Task 05.11: Fix Loot Drop on Enemy Death
**Status:** DONE
**Description:** Ensure the loot system triggers correctly when enemies die. Connect the enemy's `died` signal to the LootComponent (or LootManager autoload). On death, spawn loot items at the enemy's last position with a slight random offset (0.5m radius) and upward velocity impulse for visual "pop" effect. Verify the loot table data resource is correctly configured for each enemy type. Basic enemies drop: health orbs (60% chance), compute orbs (30% chance), nothing (10% chance). Elite enemies always drop at least one item plus a chance for equipment. Fix any null reference errors from the loot spawning system.
**Acceptance Criteria:**
- Enemies drop loot items at their position upon death
- Loot follows the configured drop tables with correct probabilities
- No null reference or orphan node errors in the output log during loot spawning

### Task 05.12: Add Hit-Stop (Freeze Frame) on Impact
**Status:** DONE
**Description:** Implement a brief hit-stop effect when the player lands an attack, pausing both the attacker and target for 2-3 frames (~0.05-0.1s at 60fps). This "hit-stop" or "hit-freeze" is a classic ARPG game feel technique that adds weight and impact to every hit. Implement by setting `Engine.time_scale = 0.05` for the duration (affects everything), or preferably by pausing only the involved AnimationPlayers and physics for the attacker/target. After the freeze, resume normal speed. This must not affect UI animations or input buffering.
**Acceptance Criteria:**
- A brief freeze occurs on every successful hit, adding weight to combat
- Freeze duration is 0.05-0.1 seconds, perceptible but not disruptive to gameplay flow
- Input during freeze is buffered and processed when freeze ends

### Task 05.13: Add Screen Shake on Impact
**Status:** DONE
**Description:** Implement camera screen shake triggered by combat hits. Player hitting enemy: subtle shake (intensity 0.05, duration 0.1s). Player taking damage: medium shake (intensity 0.1, duration 0.15s). Boss attack: strong shake (intensity 0.2, duration 0.2s). Implement shake on the gameplay camera by adding random offset to the camera's position each frame during shake, decaying exponentially. The shake should affect only the camera node's local offset, not the target position, to prevent the camera from drifting. Use a dedicated `CameraShake` component or method on the camera script.
**Acceptance Criteria:**
- Three shake intensity tiers exist for different combat events
- Shake decays smoothly and does not leave the camera offset from its intended position
- Shake is triggereable via EventBus signal so any system can request it

### Task 05.14: Fix Invincibility Frames After Taking Damage
**Status:** DONE
**Description:** Implement i-frames (invincibility frames) for the player after taking damage. When the player's HurtboxComponent receives damage, start a 0.5s invincibility window during which the hurtbox is disabled (collision shape disabled, not just monitoring off). Flash the player model during i-frames using a shader parameter that alternates between normal rendering and a bright white flash (toggle every 0.08s for a rapid blinking effect). After i-frames end, re-enable the hurtbox. Enemies do not get i-frames (allows player to combo them), but do have a brief 0.1s damage cooldown to prevent single attacks hitting twice.
**Acceptance Criteria:**
- Player is immune to damage for 0.5s after being hit
- Visual feedback (flashing) clearly communicates the invincibility state
- Enemy damage cooldown (0.1s) prevents single-frame multi-hits without granting full invincibility

### Task 05.15: Add Damage Number Display
**Status:** DONE
**Description:** Implement floating damage numbers that appear when damage is dealt. When HurtboxComponent processes damage, spawn a 3D label (Label3D or billboard Sprite3D) at the hit position showing the damage value. The number should float upward (Y velocity 2.0), fade out over 0.6s, and have a slight random X offset to prevent stacking. Color code the numbers: white for normal damage, yellow for critical hits, red for player taking damage, green for healing. Use the UI font from the style guide. Numbers should face the camera (billboard mode) and be readable at gameplay distance.
**Acceptance Criteria:**
- Damage numbers appear at the point of impact, not at the entity's center
- Numbers float up, spread slightly, and fade out cleanly over 0.6s
- Color coding distinguishes damage type (normal, critical, player damage, healing)

### Task 05.16: Add Combat Music Trigger System
**Status:** DONE
**Description:** Implement a system that transitions from exploration music to combat music when enemies aggro. When any enemy transitions to `chase` or `attack` state targeting the player, emit an `EventBus.combat_started` signal. The AudioManager listens for this signal and crossfades from exploration music to combat music over 1.0s. When all aggro'd enemies are dead or de-aggro'd, emit `EventBus.combat_ended` and crossfade back to exploration music over 2.0s (slower fade for smoother feel). Use a combat engagement counter: increment on aggro, decrement on death/de-aggro, trigger music change at 0↔1 transitions.
**Acceptance Criteria:**
- Combat music starts when the first enemy aggros and stops when the last enemy dies/de-aggros
- Music crossfades smoothly (1.0s in, 2.0s out) without abrupt cuts
- Re-aggro during the fade-out period cancels the fade and keeps combat music

### Task 05.17: Add Melee Attack Range Indicator (Debug)
**Status:** DONE
**Description:** Create a debug visualization for melee attack range that can be toggled during development. When enabled, draw a translucent arc in front of the player showing the hitbox shape and reach. Use Godot's `draw_arc()` on a MeshInstance3D with an ImmediateMesh, or a simple CSG shape that matches the hitbox dimensions. Color it green when inactive, red when the hitbox is active (during swing frames). This tool helps tune hitbox size and position without guessing. Gate it behind a debug flag (`ProjectSettings` or a debug autoload toggle) so it never appears in release builds.
**Acceptance Criteria:**
- Debug arc visually represents the exact hitbox shape and position
- Color changes from green to red during active swing frames
- Visualization is gated behind a debug toggle and excluded from release builds

### Task 05.18: Test and Fix Multi-Enemy Combat Scenarios
**Status:** DONE
**Description:** Test combat with 3-5 enemies simultaneously and fix any issues. Known potential problems: (1) player hitbox should hit multiple enemies in one swing (not just the first contacted), (2) multiple enemies attacking simultaneously should not stunlock the player (i-frames prevent this), (3) enemy pathfinding should spread enemies around the player rather than all stacking on the same point, (4) performance should remain stable with 5+ active enemies, (5) death of one enemy should not affect others (no shared state bugs). Create a test scene with a ring of enemies and verify all these cases.
**Acceptance Criteria:**
- Player can hit multiple enemies with a single swing when they are clustered
- I-frames prevent damage stacking from simultaneous enemy attacks
- 5 enemies in combat maintain 60fps with no lag spikes from collision detection

### Task 05.19: Add Combat State Debug HUD
**Status:** DONE
**Description:** Create a debug HUD overlay showing real-time combat system state for development and tuning. Display: player HP (current/max), player state machine current state, active hitbox status (on/off + hit list count), nearest enemy HP, nearest enemy state, i-frame timer, attack cooldown timer, combat engagement count, current music state. Use a CanvasLayer with Label nodes updated every frame. Style it as monospace text in the corner, similar to an FPS counter. Gate behind the same debug toggle as the range indicator.
**Acceptance Criteria:**
- Debug HUD shows all listed combat parameters updating in real-time
- HUD is positioned to not obstruct gameplay (top-right corner, small text)
- Gated behind debug toggle, excluded from release builds

### Task 05.20: Conduct Combat System Integration Test
**Status:** DONE
**Description:** Perform a comprehensive combat system integration test using a dedicated test scene with varied enemy compositions. Test scenarios: (1) Single basic enemy encounter — attack, take damage, kill, collect loot, (2) Group of 3 basic enemies — verify multi-hit, i-frames, and loot from each, (3) Elite enemy with telegraph — verify dodge timing and longer fight, (4) Edge cases: kill enemy while player is mid-death animation, damage enemy exactly to 0 HP (not negative), attack with no enemies nearby (no errors), spam attack input rapidly. Document all test results and fix any remaining issues.
**Acceptance Criteria:**
- All 4 test scenarios pass without errors in the output log
- Edge cases do not crash the game or produce unexpected behavior
- Combat feels responsive: attacks connect reliably, damage numbers show, enemies die and drop loot

## Dependencies
- Existing combat scripts (state machines, hitbox/hurtbox components, health system) must be present
- Epic 04 (Animation Pipeline) is needed for final animation-driven hitbox timing but basic timing can use script timers initially

## Notes
- This epic focuses on functionality, not visual polish — placeholder animations and VFX are fine
- Balance numbers are initial values; they will be retuned during playtesting phases
- The combat system must be solid before Epics 06-10 layer polished animations and VFX on top
- All combat signals should route through EventBus for system decoupling
- `push_error()` and `push_warning()` should be used instead of `print()` for all debug output
