# Enth: Iteration — Project Instructions

## Project Overview

Enth: Iteration is an ARPG life-sim built in Godot 4.4 with GDScript. The player controls Globbler, an AI agent inside a crumbling computer simulation, who delves through techno-dungeons and builds a digital community across 9 iterations.

## Key Documents

- **Project Context:** `_bmad-output/project-context.md` — Critical rules for AI agents
- **Game Brief:** `_bmad-output/game-brief.md` — Game vision and design goals
- **GDD:** `_bmad-output/gdd.md` — Complete game design document
- **Architecture:** `_bmad-output/game-architecture.md` — Technical architecture and patterns
- **Epics & Stories:** `_bmad-output/planning-artifacts/epics.md` — All stories with acceptance criteria
- **Sprint Plan:** `_bmad-output/planning-artifacts/sprint-plan.md` — Execution order and status tracking

## Autonomous Story Execution

When asked to "execute the sprint plan" or "work on the next story":

1. Read `_bmad-output/planning-artifacts/sprint-plan.md` to find the first story with status `TODO`
2. Read the full story details and acceptance criteria from `_bmad-output/planning-artifacts/epics.md`
3. Read `_bmad-output/project-context.md` for coding rules and conventions
4. Read `_bmad-output/game-architecture.md` for architectural patterns
5. Implement the story following ALL acceptance criteria
6. Use Godot MCP to validate scenes and test where applicable
7. Update the sprint plan: change `TODO` to `DONE` and check the box `[x]`
8. Commit changes with message format: `story-N.M: description`
9. Immediately proceed to the next `TODO` story without waiting

## Code Standards (from project-context.md)

- Static typed GDScript everywhere
- Scene composition over inheritance
- 5 autoloads only: GameManager, EventBus, SaveManager, IterationManager, AudioManager
- EventBus for cross-system communication
- State machine pattern for entity behaviors
- Data-driven items via custom Resources (.tres)
- File naming: snake_case.gd for scripts, PascalCase.tscn for scenes
- Never use Godot 3.x API (no yield, instance, export var without @)
- Use %UniqueNodeName over $Path/To/Node
- push_error()/push_warning() not print()
