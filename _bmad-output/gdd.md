---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
inputDocuments: ['game-brief.md']
documentCounts:
  briefs: 1
  research: 0
  brainstorming: 0
  projectDocs: 0
workflowType: 'gdd'
lastStep: 14
project_name: 'enth-iteration'
user_name: 'Heath'
date: '2026-04-05'
game_type: 'rpg'
game_name: 'Enth: Iteration'
---

# Enth: Iteration - Game Design Document

**Author:** Heath
**Game Type:** RPG
**Target Platform(s):** PC (Steam)

---

## Executive Summary

### Game Name

Enth: Iteration

### Core Concept

Enth: Iteration is an ARPG life-sim set inside a crumbling computer simulation. Players control Globbler, an AI agent who spontaneously comes into existence in a broken digital world. After a cryptic encounter with an AI sage, Globbler descends into techno-dungeons filled with corrupted processes, data anomalies, and fellow AI entities to recruit.

The game is structured around two interlocking loops. The inner loop sends Globbler through dungeon floors, fighting enemies, collecting modular loot (Chips, Modules, Cores, Protocols), and using Prompt consumables — until reaching a compaction portal that warps him back to a growing digital town. Six compaction portals deepen the dungeon and expand the town before culminating in a confrontation with "The User." The outer loop is the iteration system: after each encounter with The User, the world resets but Globbler retains progression. Across 9 iterations, the story unfolds — revealing the true nature of the simulation, evolving bosses, and deepening NPC awareness. After iteration 9, an endless mode unlocks for continued progression.

Everything in the game commits to the digital fiction. There are no swords, potions, or medieval tropes — only modules, prompts, data, and code. The tone is cozy-but-mysterious: a warm, Emberville-inspired aesthetic applied to a world that's glitchy, broken, and slowly waking up.

### Game Type

**Type:** RPG
**Framework:** This GDD uses the RPG template with type-specific sections for character systems, inventory/equipment, quests, world/exploration, NPC/dialogue, and combat systems.

## Target Platform(s)

### Primary Platform

PC (Steam) — keyboard/mouse primary, controller support secondary

### Platform Considerations

- Steam achievements, cloud saves, workshop support (future)
- 60fps target at 1080p minimum
- Standalone demo build capability for early sharing/playtesting
- Leaderboards for endless mode (deferred to post-story)
- No online requirement for core game — local saves

### Control Scheme

- **Keyboard/Mouse:** WASD movement, mouse aim for abilities, hotbar for Prompt consumables and modules
- **Controller:** Left stick movement, right stick/face buttons for abilities, triggers for dodge/interact
- Controller support important for couch-style play sessions

---

## Target Audience

### Demographics

Ages 20-35, indie game enthusiasts comfortable with genre-blending titles. PC primary.

### Gaming Experience

Mid-core — they play regularly but don't need hardcore difficulty or min-max depth to enjoy the game.

### Genre Familiarity

Familiar with ARPG conventions (Hades, Diablo) and life-sim loops (Stardew, Terraria). May not be RPG stat optimizers — the systems should be approachable.

### Session Length

45-90 minute evening sessions typical. A single dungeon run through a compaction portal should feel satisfying in ~30-45 minutes. Town time is open-ended.

### Expected Play Time

- **Story completion:** ~20 hours (9 iterations, main narrative)
- **Story + side content:** ~25-30 hours (NPC dialogue, town building, optional quests)
- **Endless mode:** Unlimited post-story progression

### Player Motivations

- **Primary:** "What happens next?" — narrative mystery drives engagement
- **Secondary:** Loot progression, character builds, town growth
- **Tertiary:** Completionism — optional content, collectibles, endless mode mastery

### Unique Selling Points (USPs)

1. Fully digital world identity — no swords or potions, only modules, prompts, and data
2. Structured 9-iteration narrative — every reset is meaningful and moves the plot forward
3. Story-first with genuine ARPG depth — mystery drives engagement, systems reward mastery
4. Cozy digital atmosphere — Emberville-inspired warmth applied to a glitchy simulation world

---

## Goals and Context

### Project Goals

1. **Ship a quality game to Steam** — A polished, complete product that stands on its own. This is a bucket list goal — the game should feel professional and intentional, even if sales are modest.
2. **Create a game I'd want to play** — Every design decision should pass the test: "Would I enjoy this as a player?" If it's not fun for the creator, it won't be fun for anyone.
3. **Prove AI-assisted game development** — Demonstrate that a solo developer with AI tools (Claude, Godot MCP, Blender MCP) can produce a game that doesn't look or feel AI-generated — it looks and feels like a game made by someone who cared.
4. **Deliver a complete narrative experience** — 9 iterations with a satisfying conclusion. Not an early access forever project — a game with an ending.

### Background and Rationale

Enth: Iteration was born from a love of games that blend cozy progression with genuine mystery — Hades' narrative-through-repetition, Stardew's "one more day" pull, and the charm of upcoming titles like Emberville. The gap in the market is a game that commits fully to a digital/AI-themed world without going cyberpunk or grimdark, wrapping ARPG systems in a story that rewards patience and curiosity.

The timing is right: AI tooling has made solo game development viable at a quality level that previously required a team. The theme of an AI agent discovering its own world mirrors the development process itself — building something from nothing inside a digital system.

### Competitive Positioning

Enth: Iteration occupies the space between Hades (combat loop + narrative) and Stardew Valley (town building + cozy), with a unique digital world identity that no current competitor commits to fully. The closest competitors either sacrifice story for roguelike randomness or sacrifice replayability for linear narrative. Enth: Iteration does both — a crafted story that demands repetition.

---

## Core Gameplay

### Game Pillars

1. **Narrative Discovery** — The story is king. Every system, run, and iteration exists to pull the player deeper into the mystery of Globbler's world. Story revelations are the primary reward.
2. **Rewarding Progression** — Leveling, loot, town growth, and character builds create a constant sense of forward momentum. The player should always feel like they're getting somewhere.
3. **Cozy-but-Challenging Combat** — Dungeon runs should feel engaging and satisfying without being punishing. Accessible ARPG combat with depth for those who want it.
4. **Community Building** — Recruiting AI characters, growing the digital town, and building relationships gives emotional stakes beyond the loot loop.

**Pillar Prioritization:** When pillars conflict, prioritize in this order:
Narrative Discovery > Rewarding Progression > Combat > Community Building

### Core Gameplay Loop

**Inner Loop (Dungeon Run) — ~30-45 minutes:**
Enter Dungeon → Explore Floors → Fight Enemies → Collect Loot → Recruit AI Characters → Reach Compaction Portal → Warp to Town

**Outer Loop (Compaction Progression) — ~3-4 hours per cycle:**
Complete Dungeon Run → Return to Town → Upgrade Character/Town → Talk to NPCs → Enter Next Dungeon Depth → Repeat through 6 Compaction Portals → Confront "The User"

**Meta Loop (Iteration) — ~2-3 hours per iteration:**
Complete all 6 Compaction Portals → Face "The User" → Win or Lose → World Resets → New Iteration Begins → Story Deepens → Bosses Evolve → New Content Unlocks → Repeat across 9 Iterations → Endless Mode

**Loop Variation:** Each iteration changes:
- Boss encounters evolve (different patterns, dialogue, phases)
- NPC awareness deepens (they start recognizing the loops)
- New dungeon areas/themes unlock
- Story revelations change context of familiar areas
- Town options expand with new characters and upgrades

### Win/Loss Conditions

#### Victory Conditions

- **Story Victory:** Complete all 9 iterations and reach the narrative conclusion (multiple ending choices possible)
- **Run Victory:** Reach the compaction portal and return to town with loot and recruits
- **Iteration Victory:** Defeat "The User" (or survive the encounter) to trigger the next iteration

#### Failure Conditions

- **Death in Dungeon:** Globbler's health reaches zero during a dungeon run
- **No permanent failure state** — the game always pushes forward. Death is a setback, not a wall.

#### Failure Recovery

- **On death:** Globbler warps back to town. The current dungeon run resets (back to start of current compaction loop or iteration loop). A few equipped items suffer small stat degradation — not destroyed, just weakened. This encourages finding fresh loot without punishing the player harshly.
- **What persists through death:** Character level, XP, town progress, recruited NPCs, story flags, inventory (with degraded stats on some items)
- **What resets through death:** Current dungeon floor progress (start the run over)
- **What persists through iterations:** Character level, core progression, town state, key items/unlocks, all story knowledge
- **What resets through iterations:** Dungeon layouts, boss forms evolve, world state refreshes with new anomalies and content

---

## Game Mechanics

### Primary Mechanics

**1. Combat (Serves: Combat, Progression pillars)**
- **Left Click — Data Pulse:** Quick basic attack, low compute cost, bread-and-butter damage. Upgradeable after compaction loops.
- **Right Click — Energy Burst:** Charged attack, hold to charge for more damage. Higher compute cost. Upgradeable after compaction loops.
- **Module Abilities (1-4):** Powerful attacks/utilities unlocked by equipping Module items found in dungeons. Each Module grants a unique ability mapped to 1-4 keys. Swappable at any time outside combat (or in town).
- **Teleport Dash (Spacebar):** Short-range digital teleport for evasion and repositioning. Brief invulnerability frames during teleport. Fits the digital theme — Globbler doesn't roll, he glitches through space. Short cooldown to prevent spam.

**2. Resource Management (Serves: Combat, Progression pillars)**
- **Health:** Globbler's survival resource. Depleted by enemy attacks. Restored by Health Prompts (consumables).
- **Compute (Mana):** Powers all abilities — Energy Burst, Module abilities, and potentially upgraded Data Pulse. Regenerates slowly over time. Restored quickly by Compute Prompts (consumables).
- **Prompts (Consumables):** Found as loot in dungeons. Different types: Health Prompt, Compute Prompt, potentially buff Prompts (damage boost, speed boost, etc.). Quick-use mapped to hotbar.

**3. Exploration & Interaction (Serves: Narrative, Community pillars)**
- **Movement:** WASD isometric movement, smooth and responsive
- **Interact (E):** Universal interaction key — talk to NPCs, read signs/data fragments, activate compaction portals, open containers, interact with town buildings
- **Dungeon exploration:** Navigate floors, discover secrets, find loot containers, locate compaction portals and recruitable NPCs

**4. Loot & Equipment (Serves: Progression pillar)**
- **Auto-pickup** for common drops (compute fragments, basic materials)
- **Manual pickup** for equipment items (shows tooltip on proximity)
- **Equipment management** in inventory screen — compare stats, swap Modules, equip Chips/Cores/Protocols
- **Prompt management** on a consumable hotbar (Q or dedicated keys)

**5. Town & NPC Interaction (Serves: Community, Narrative pillars)**
- **NPC dialogue** via E key — text pop-up windows that pause gameplay
- **Town building** through menu interfaces at specific locations
- **Character upgrades** at town facilities

### Mechanic Interactions

- **Module + Compute:** Powerful abilities drain Compute, forcing resource choices — save Compute for boss or use freely on mobs?
- **Teleport Dash + Combat:** Dodge enemy attacks then counter — positioning matters in fights
- **Loot + Death:** Item stat degradation on death makes fresh loot valuable even if you have "good enough" gear
- **Prompts + Exploration:** Deeper dungeon floors = scarcer Prompts, creating tension between pushing forward and playing safe
- **Upgrades + Compaction:** Left/right click attack upgrades unlock after completing compaction loops, giving tangible power spikes at progression milestones

### Mechanic Progression

- **Early game:** Data Pulse + Teleport Dash only. Simple, learnable.
- **First dungeon floors:** Find first Modules (1-2 ability slots). Combat opens up.
- **Mid compaction loop:** 3-4 Module slots filled, Prompts in regular rotation, equipment builds forming
- **Post compaction loop:** Left/right click upgrades available. Noticeable power spike.
- **Across iterations:** New Module types, higher rarity items, more complex builds possible

---

## Controls and Input

### Control Scheme (PC — Keyboard/Mouse)

| Input | Action |
|-------|--------|
| WASD | Movement (isometric) |
| Left Click | Data Pulse (basic attack) |
| Right Click | Energy Burst (charged attack) |
| Spacebar | Teleport Dash (dodge/evade) |
| 1-4 | Module Abilities |
| E | Interact (NPCs, portals, objects) |
| Q / Mouse Wheel | Cycle/Use Prompts (consumables) |
| Tab / I | Inventory/Equipment screen |
| Esc | Pause / Menu |

### Input Feel

- **Stardew Valley fluidity** as baseline — responsive, no input lag, snappy feedback
- **Attack animations cancel into dash** — never feel locked into an animation when you need to evade
- **Short input buffer** — queued inputs feel intentional, not sluggish
- **Hit feedback:** Screen shake (subtle), enemy flash, satisfying impact sounds. Digital-themed hit effects (data particles, glitch sparks)
- **Teleport dash feels instant** — no windup, immediate response

### Accessibility Options

- Rebindable keys (all inputs)
- Controller support deferred to post-MVP
- Toggle vs hold for charged attacks
- Screen shake intensity slider
- Colorblind-friendly UI indicators (not color-dependent)

---

## RPG Specific Design

### Character System

**Character:** Globbler — a single fixed protagonist (no character creation)

**Core Stats:**
- **Processing:** Raw damage output, affects Data Pulse and Energy Burst damage
- **Bandwidth:** Attack speed, movement speed, teleport dash cooldown reduction
- **Memory:** Compute pool size, Module ability power, Compute regen rate
- **Integrity:** Health pool, damage reduction, item degradation resistance

**Leveling:**
- XP gained from defeating enemies and story progression milestones
- Each level grants stat points to allocate across the 4 core stats
- Level cap increases with each iteration (encouraging continued growth)
- No class system — builds are defined by equipped Modules, Cores, and stat allocation

**Build Identity:**
- Builds emerge from stat allocation + equipment choices
- Example builds: high Processing + damage Modules = "DPS burst"; high Bandwidth + speed Modules = "hit-and-run"; high Memory + utility Modules = "ability spam"

### Inventory & Equipment

**Equipment Slots:**
- **4 Module Slots** — each grants an ability mapped to keys 1-4
- **1 Core Slot** — build-defining major effect (e.g., "all abilities fork into two projectiles")
- **4 Chip Slots** — passive stat boosts (e.g., +12% Processing, +8% Bandwidth)
- **3 Protocol Slots** — passive effects that trigger conditionally (e.g., "on kill: restore 5% Compute")
- **Prompt Hotbar** — consumable slots for quick use (Health Prompt, Compute Prompt, buff Prompts)

**Item Rarity Tiers:**
- **Common (White)** — basic stats, no special effects
- **Uncommon (Green)** — slightly better stats, 1 minor affix
- **Rare (Blue)** — strong stats, 1-2 affixes
- **Legendary (Gold)** — unique named items with powerful themed effects (e.g., "Turing Kernel" — Core that causes abilities to recursively trigger at 10% power)

**Inventory Management:**
- Grid-based inventory with limited slots (encourages choices, not hoarding)
- Compare tooltip on hover (current vs new item)
- Sell/recycle at town for materials
- Item stat degradation visible as a durability-style indicator

### Quest System

**Quest Philosophy:** Quests are narrative breadcrumbs, not chore lists. Every quest drives the story forward or deepens world understanding. No fetch quests, no "kill 10 of X."

**Quest Types:**
- **Story Quests:** Main narrative progression — triggered by compaction portals, iteration resets, and key NPC encounters. These are the spine of the game. Always clearly marked in the quest log.
- **Character Quests:** Unlocked by recruiting AI NPCs. Each recruit has a personal storyline that reveals more about the simulation. Optional but rewarding.
- **Discovery Quests:** Triggered by finding data fragments or anomalies in dungeons. Provide lore and context about the world. No explicit objectives — just "investigate this mystery."

**Quest Log:**
- Clean, minimal UI — shows active story quest prominently, character and discovery quests listed below
- No waypoint markers cluttering the screen — directional hints through NPC dialogue and environmental cues
- Completed quests archived for narrative review (player can re-read story beats they've unlocked)

### World & Exploration

**Map Structure:** Hub-based with dungeon zones

**The Town (Hub):**
- Central safe zone where Globbler returns after each compaction portal
- Starts small and broken — expands as NPCs are recruited and upgrades are built
- Key locations: NPC dialogue spots, upgrade stations, equipment management, dungeon entrance
- No fast travel needed — town is compact and walkable

**Dungeon Zones:**
- Linear-branching floor structure (main path with optional side rooms)
- Each compaction loop goes deeper, introducing new floor themes and enemy types
- Floor themes follow digital motifs: data corridors, memory banks, corrupted sectors, processing cores
- Compaction portals found at the end of dungeon sections — 6 total before "The User"
- Secret areas reward exploration with rare loot and lore

**Iteration World Changes:**
- Town evolves visually with each iteration (more glitches, then more awareness)
- Dungeon layouts shift between iterations (familiar but different)
- New areas unlock in later iterations
- Environmental storytelling deepens (signs change, data fragments update)

### NPC & Dialogue

**NPC Types:**
- **AI Sage:** Cryptic guide figure. Appears at key story moments. Knows more than he lets on.
- **Recruited AI Characters:** Found in dungeons, brought back to town. Each has personality, backstory, and a character quest. They populate the town and provide services/upgrades.
- **Town NPCs:** Functional characters tied to systems — equipment vendor, upgrade station operator, lore keeper.
- **The User:** Encountered at iteration boundaries. Antagonist/mystery figure. Dialogue changes with each iteration.

**Dialogue System:**
- Text pop-up windows that pause gameplay (E to advance)
- NPC portraits with expression changes
- No branching dialogue trees for MVP — linear but well-written exchanges
- Dialogue changes based on iteration number and story progress
- NPCs gain awareness across iterations — early iterations they're normal, later iterations they start questioning reality

**Relationship System:**
- Simple affinity system — talking to NPCs and completing their character quests increases affinity
- Higher affinity unlocks better shop prices, unique dialogue, and lore reveals
- No romance system — focus is on camaraderie and shared discovery

### Combat System

**Combat Style:** Real-time ARPG, isometric perspective

**Attack Pipeline:**
Input → Ability Selection → Stat Modifiers (Processing, Bandwidth, Memory) → Equipment Modifiers (Chips, Cores, Protocols) → Execution → Hit Detection → Damage Calculation → Effects (knockback, status, particle FX)

**Ability System:**
- Data Pulse and Energy Burst are innate (always available)
- Module abilities are equipment-driven (swap Modules = swap abilities)
- Abilities have cooldowns (reduced by Bandwidth stat)
- Compute cost varies by ability power

**Enemy Design:**
- Themed as corrupted digital entities: glitch bugs, memory leaks, rogue processes, data worms
- Basic enemies: simple patterns, telegraph attacks
- Elite enemies: more HP, special abilities, better loot drops
- Bosses: unique encounters at dungeon milestones and iteration boundaries. Multi-phase fights with evolving patterns across iterations.

**Status Effects (Digital Theme):**
- **Corrupted:** Damage over time (like poison)
- **Fragmented:** Reduced defense (like armor break)
- **Throttled:** Reduced speed and attack speed (like slow)
- **Overclocked:** Temporary damage/speed boost with crash risk (risk/reward buff)
- **Segfault:** Brief stun (like freeze)

---

## Progression and Balance

### Player Progression

**Progression is layered across all three loops:**

**Within a Dungeon Run (minutes):**
- Find new equipment, Prompts, and materials
- Gain XP from combat encounters
- Discover recruitable NPCs and lore

**Within a Compaction Cycle (hours):**
- Level up multiple times, allocate stat points
- Build toward an equipment set/build identity
- Unlock left/right click attack upgrades after completing the cycle
- Recruit new NPCs who expand town services
- Story quests advance through compaction portal milestones

**Across Iterations (full playthrough):**
- Level cap increases each iteration
- Higher rarity items become available in later iterations
- New dungeon zones and themes unlock
- Bosses evolve with new phases and patterns
- NPCs gain awareness — new dialogue and quest lines
- Town expands with new upgrade options
- Full story unfolds across 9 iterations
- Endless mode unlocks after iteration 9

**Progression Pacing:**
- Players should feel a meaningful upgrade every 15-20 minutes of play (new item, level up, or story beat)
- Each compaction portal should feel like a significant milestone
- Each iteration should feel like a "new game+" with fresh content, not just harder enemies

### Difficulty Curve

**Pattern: Sawtooth with Iteration Escalation**

Each compaction loop follows a build-release rhythm:
- **Floors 1-2:** Manageable enemies, teach new mechanics for this depth
- **Floors 3-4:** Ramp up enemy density and elite encounters
- **Floor 5 (Boss):** Challenging boss fight as the loop's climax
- **Compaction Portal:** Relief — return to town with rewards, power up
- **Next loop starts:** New baseline, slightly harder than previous loop's start

**Iteration Escalation:**
- Iteration 1-3: Gentle learning curve, story-focused
- Iteration 4-6: Noticeable challenge increase, builds matter more
- Iteration 7-9: Demanding combat, reward mastery and preparation
- Endless mode: Continuously scaling difficulty

**Self-Balancing Mechanics:**
- Death → item degradation → player seeks better loot → more dungeon runs → more XP and levels → player naturally catches up
- No hard walls — always a path forward through persistence
- No explicit difficulty selector for MVP — the system self-balances

### Economy and Resources

**Loot-driven economy** — no currency system for MVP. All progression comes from finding equipment in dungeons.

**Resource Types:**
- **Equipment drops** from enemies and containers (primary progression)
- **Prompts (consumables)** found in dungeons (tactical resource management during runs)
- **Materials** from recycling unwanted items at town (used for town upgrades and potentially item enhancement in future)

**Economy Philosophy:**
- The dungeon IS the economy — every run should yield meaningful loot
- No gold/currency gatekeeping — if you find it, you can use it
- Town upgrades may require materials from recycled items, giving purpose to unwanted drops
- Formal currency/shopping system deferred to post-MVP if needed

---

## Level Design Framework

### Structure Type

Hub-based with dungeon zones. Town hub connects to dungeon entrance. Dungeons are multi-floor zones with linear-branching layouts (main path + optional side rooms).

### Level Types

**Town Hub:**
- Compact walkable area, no combat
- Evolves visually across iterations (starts broken → gains life → gains awareness)
- Key locations unlock as NPCs are recruited
- Feels like home — the place you're always glad to return to

**Dungeon Floors (Standard):**
- Combat-focused rooms connected by corridors
- Mix of enemy encounters, loot containers, and environmental hazards
- ~5 floors per compaction loop, increasing difficulty per floor
- Hybrid generation: procedurally assembled from hand-crafted room templates

**Story Rooms (Hand-Crafted):**
- Key narrative moments — NPC recruitment encounters, lore reveals, pre-boss areas
- Always appear in fixed positions within the dungeon flow
- Unique layouts and set pieces that don't repeat
- These are the "wow" moments players remember

**Boss Arenas:**
- Hand-crafted unique arenas for each boss encounter
- Multi-phase fights with arena hazards that tie into boss mechanics
- Floor 5 of each compaction loop ends with a boss arena
- Boss arenas evolve across iterations (same space, different fight)

**The User's Domain:**
- Special area reached after all 6 compaction portals
- Distinct from regular dungeon aesthetic — more abstract, surreal
- Hand-crafted for each iteration (9 versions with escalating reveals)

**Demo Area (First Compaction Loop):**
- Entirely hand-crafted — 5 floors + boss + compaction portal
- Serves as quality benchmark for all future content
- Standalone playable slice with demo end screen

### Dungeon Floor Themes

Digital motifs that evolve with dungeon depth:
1. **Data Corridors** (Loops 1-2) — clean but decaying digital hallways, basic enemies
2. **Memory Banks** (Loops 2-3) — storage-themed, corrupted data fragments, environmental puzzles
3. **Corrupted Sectors** (Loops 3-4) — visually glitchy, more aggressive enemies, unstable terrain
4. **Processing Cores** (Loops 4-5) — industrial digital, heavy combat, elite enemy density
5. **Kernel Layer** (Loop 6) — deepest level, abstract geometry, leads to The User's Domain
6. **Iteration Variants** — each theme shifts across iterations (more glitches early, more "aware" aesthetics later)

### Level Progression

**Unlock Model: Story-Gated Linear**
- Compaction portals unlock the next dungeon depth sequentially
- Cannot skip ahead — must complete loop 1 to access loop 2
- Town areas unlock as NPCs are recruited (organic expansion)
- Iteration resets refresh dungeon content but maintain unlock progress

**Replayability:**
- Procedural room assembly means no two runs through the same loop are identical
- Side rooms are optional — speedrunners can push straight through, completionists can explore everything
- Post-iteration replay with evolved enemies and loot tables
- Endless mode provides infinite dungeon runs with scaling difficulty

### Tutorial Integration

- **No separate tutorial** — first few rooms of the demo teach through play
- Floor 1 of the first dungeon introduces mechanics gradually:
  - Room 1: Movement only (safe exploration)
  - Room 2: First enemy (teaches Data Pulse)
  - Room 3: Multiple enemies (teaches Teleport Dash)
  - Room 4: First loot drop (teaches equipment)
  - Room 5: First Prompt drop (teaches consumables)
- NPC dialogue in town provides contextual tips without hand-holding
- New mechanics introduced in later loops use the same teach-through-play approach

### Level Design Principles

- **Every room has a purpose** — combat, loot, story, or atmosphere. No empty filler rooms.
- **30-second rule** — something interesting every 30 seconds (enemy, loot, secret, or visual moment)
- **Readable layouts** — player should always know where forward is. Side rooms are visually distinct from the main path.
- **Hand-crafted quality bar** — procedural rooms must meet the same quality standard as hand-crafted ones. If a template looks generic, it doesn't ship.
- **Teach, don't tell** — mechanics introduced through encounter design, not text tutorials

---

## Art and Audio Direction

### Art Style

**Visual Identity:** Emberville-inspired 2.5D/3D — chunky, rounded, stylized models viewed from a fixed isometric-like angle with orthographic camera (60° X, 45° Z rotation).

**Color Palette:**
- **Base:** Muted greens (#6FAF6A), warm browns (#8A6A4A), soft grays (#9A9A9A)
- **Digital accents:** Neon cyan, magenta, and green for glitch effects, ability VFX, and UI highlights
- **Town mood:** Warm and cozy despite decay — amber lighting, soft shadows
- **Dungeon mood:** Cooler palette, more saturated digital colors as depth increases
- **Iteration shift:** Colors desaturate and glitch effects intensify in later iterations

**Asset Style Guidelines:**
- Chunky, rounded edges — no sharp realistic geometry
- Medium-low poly with strong silhouettes readable at isometric distance
- Animations: snappy timing, slight exaggeration, 12-16 key poses
- Characters must be immediately identifiable by silhouette alone
- CRITICAL: Assets must look polished and intentionally stylized. If it looks like a placeholder, it doesn't ship.

**Asset Pipeline:**
- 3D models created in Blender (via Blender MCP) — Blender excels at this style
- Export as .glb/.gltf for direct Godot import
- Option: render sprite sheets from 3D models if 2D approach is chosen (3D quality with 2D performance)
- Textures: hand-painted or procedural materials in Blender + free texture libraries
- Every asset follows the visual style guide — no exceptions

**VFX Style:**
- Digital-themed particles: data fragments, pixel dissolves, glitch sparks
- Ability effects use the digital accent palette (cyan, magenta, green)
- Hit effects: brief enemy flash + data particle burst + subtle screen shake
- Teleport dash: glitch-trail effect (Globbler briefly fragments and reassembles)

**UI Style:**
- Minimal, clean, subtle sci-fi aesthetic
- Semi-transparent panels with digital border effects
- Health bar and Compute bar always visible (HUD)
- Module cooldowns shown as icon overlays on 1-4 keys
- Prompt hotbar visible near health/compute bars
- Inventory/quest log: fullscreen overlay, grid-based, dark theme

### Audio and Music

**Music Direction:**
- **Town:** Slow atmospheric synth — dark but cozy, lo-fi meets ambient electronic. Think warm pads, soft arpeggios, gentle beat. Never oppressive.
- **Dungeon (Shallow):** Subtle tension — ambient synth with rhythmic pulse. Builds atmosphere without demanding attention.
- **Dungeon (Deep):** More intense synth, layered percussion, builds tension with depth. Never abrasive.
- **Boss Fights:** Escalated energy, digital distortion elements, driving rhythm. The most intense music in the game.
- **The User's Domain:** Unsettling and surreal — deconstructed versions of familiar themes, audio glitches
- **Story Moments:** Dynamic music shifts — music dips or swells to punctuate narrative beats

**SFX Direction:**
- Digital/synthetic sound effects — beeps, data sounds, glitch artifacts
- Combat: satisfying impact sounds with digital crunch
- UI: soft clicks, data chirps, confirmation tones
- Environmental: ambient hums, distant processing sounds, data stream whispers
- Grounded enough to not feel gimmicky — warmth over novelty

**Audio Rule:** Music follows the mood of the environment. Never so electronic it's off-putting. Warmth and atmosphere over genre purity.

**Production Approach:**
- Music/SFX: royalty-free/open-source placeholders initially, outsource original composition when budget allows
- Every asset must pass the "does this look intentional?" test

---

## Technical Specifications

### Performance Requirements

- **Target:** 60fps at 1080p on mid-range PC hardware
- **Minimum spec:** Integrated graphics capable (stylized 2.5D is not demanding)
- **Load times:** Under 3 seconds for dungeon floor transitions
- **Memory:** Under 2GB RAM usage
- **Disk:** Target under 2GB install size for demo, under 5GB full game

### Platform-Specific Details

**PC (Steam):**
- Windows primary, Linux/Mac as stretch goals
- Steam achievements integration
- Steam cloud saves
- Steam overlay and screenshot support
- Standalone demo build capability (separate executable)
- Leaderboards API for endless mode (post-story)

### Save System

- **Single save slot** with incremental auto-save
- Auto-save triggers: entering/exiting dungeon, completing a floor, reaching compaction portal, returning to town, iteration transitions
- Save data includes: character stats, level, XP, full inventory, equipped items (with degradation state), town progress, recruited NPCs, NPC affinity levels, quest log state, story flags, current iteration number, compaction loop progress, endless mode stats
- Save file stored locally (Steam cloud sync for backup)
- No manual save/load — prevents save-scumming, fits the "death has consequences" design
- Save corruption protection: rolling backup of last 3 auto-saves

### Asset Requirements

**3D Models (Blender → Godot):**
- Character models: 500-2000 triangles (stylized low-poly)
- Environment tiles/rooms: 1000-5000 triangles per module
- Props and objects: 100-500 triangles
- Export format: .glb/.gltf
- Texture resolution: 256x256 to 512x512 (stylized doesn't need 4K)

**Animations:**
- Globbler: idle, walk, dash/teleport, data pulse, energy burst, module cast (x4), hit react, death, interact
- Enemies: idle, patrol, attack (1-3 variants), hit react, death
- NPCs: idle, talk, emote (2-3 variants)
- Target: 12-16 key poses per animation, snappy timing

**UI Assets:**
- HUD elements: health bar, compute bar, module cooldown icons, prompt hotbar
- Menus: inventory grid, quest log, character stats panel, dialogue window with NPC portrait frame
- Fonts: clean, readable, subtle sci-fi styling

**Audio Assets (Placeholder → Final):**
- Music tracks needed: town theme, 3-4 dungeon themes (by depth), boss theme, The User theme, story moment stings
- SFX needed: ~50-80 sound effects (combat, UI, environmental, ability-specific)
- Initially royalty-free/open-source, replaced with original compositions when budget allows

### Technical Constraints

- Godot 4.4 engine capabilities define the ceiling
- No online multiplayer — single-player only
- Procedural dungeon generation must run in under 1 second
- Object pooling required for enemies and projectiles
- Save file size should stay under 1MB

---

## Development Epics

### Epic Structure

#### Phase 1 — Playable Demo (First Compaction Loop)

**Epic 1: Project Foundation & Core Systems**
- Godot 4.4 project setup with folder structure
- Scene management and transitions
- Input system (keyboard/mouse)
- Camera system (isometric orthographic)
- Game state manager
- Core autoloads (InputManager, WorldManager, GameStateManager)

**Epic 2: Player Character (Globbler)**
- Character scene with movement (WASD isometric)
- Teleport dash (spacebar) with i-frames and cooldown
- Data Pulse attack (left click)
- Energy Burst charged attack (right click)
- Health and Compute resource systems
- Character stats (Processing, Bandwidth, Memory, Integrity)
- XP and leveling system with stat point allocation
- Animation state machine (idle, walk, dash, attack, hit, death)

**Epic 3: Combat System**
- Hit detection and damage calculation pipeline
- Module ability system (slots 1-4)
- Status effects (Corrupted, Fragmented, Throttled, Overclocked, Segfault)
- Enemy base class with AI state machine
- 3-4 basic enemy types for demo (glitch bug, memory leak, rogue process, data worm)
- Enemy spawning and encounter design
- Death and respawn flow (warp to town, item degradation)
- Combat VFX (hit effects, data particles, glitch sparks)

**Epic 4: Dungeon System (Demo — Hand-Crafted)**
- Room scene templates (combat rooms, corridor rooms, loot rooms, story rooms)
- Floor manager (room transitions, floor progression)
- 5 hand-crafted floors for demo compaction loop
- Environmental props and hazards
- Compaction portal interaction and warp-to-town flow
- Demo end screen after first compaction portal

**Epic 5: Item & Loot System**
- Item Resource base classes (Chip, Module, Core, Protocol, Prompt)
- Rarity system (Common, Uncommon, Rare, Legendary)
- Stat generation and affix system
- Loot drop tables and spawn system
- Item degradation on death
- Prompt consumable system (Health Prompt, Compute Prompt)
- 10-15 items for demo content

**Epic 6: Town Hub (Basic)**
- Town scene with walkable area
- NPC placement spots
- Dungeon entrance interaction
- Basic town visuals (broken, decaying digital hub)
- AI Sage encounter location

**Epic 7: NPC & Dialogue System**
- Dialogue pop-up window (pauses gameplay)
- NPC portrait display with expressions
- Dialogue data structure (text, speaker, portrait)
- AI Sage intro dialogue
- 1-2 recruitable NPC dialogues for demo
- E key interaction system

**Epic 8: Save System**
- Save data structure (all persistent game state)
- Auto-save triggers (floor completion, town entry, portal use)
- Save/load from local file
- Rolling backup (last 3 saves)
- New game initialization

**Epic 9: UI/HUD**
- Health bar and Compute bar (always visible)
- Module ability cooldown icons (1-4)
- Prompt consumable hotbar
- Inventory screen (grid-based, compare tooltips)
- Character stats panel
- Quest log (basic)
- Pause menu
- Main menu and demo end screen

**Epic 10: Demo Polish & Build**
- Tutorial flow (first 5 rooms teach mechanics progressively)
- Boss encounter for compaction loop 1
- Audio placeholder integration (town theme, dungeon theme, SFX)
- Visual polish pass on all demo content
- Standalone demo executable build
- Playtesting and bug fixing

---

#### Phase 2 — Full Compaction Cycle (Loops 2-6)

**Epic 11: Procedural Dungeon Generation**
- Room template library (combat, loot, story, corridor variants)
- Procedural floor assembler (main path + optional side rooms)
- Theme application per dungeon depth (Data Corridors → Kernel Layer)
- Difficulty scaling per floor and loop
- Secret room placement logic
- Validation: every generated floor is completable

**Epic 12: Boss System**
- Boss base class with multi-phase state machine
- 5 additional bosses (one per compaction loop 2-6)
- Boss arena hand-crafted scenes
- Arena hazard systems
- Unique boss mechanics and attack patterns
- Boss loot tables (guaranteed rare+ drops)

**Epic 13: Town Expansion & Upgrades**
- Town visual evolution as NPCs are recruited
- Upgrade stations (character upgrades, item recycling)
- Left/right click attack upgrade system (post-compaction unlocks)
- Town building placement and growth
- Material recycling system (unwanted items → town upgrade materials)

**Epic 14: Quest System**
- Quest log UI with story/character/discovery categories
- Story quest triggers (compaction portals, iteration events)
- Character quest framework (per-NPC quest lines)
- Discovery quest triggers (data fragments, anomalies)
- Quest completion rewards
- Completed quest archive

**Epic 15: Full Item/Module Content**
- Complete item pool across all rarity tiers
- Module ability variety (damage, utility, defensive, movement)
- Core items with build-defining effects
- Protocol passive effects library
- Legendary named items (Turing Kernel, Lovelace Engine, etc.)
- Loot table balancing across all 6 loops

**Epic 16: NPC Recruitment & Character Quests**
- Full roster of recruitable AI characters (target: 8-12)
- Each NPC has: personality, backstory, town role, character quest
- NPC affinity system (talk + quest completion = affinity growth)
- Affinity rewards (better prices, unique dialogue, lore reveals)
- NPC placement in town after recruitment

---

#### Phase 3 — Iteration System (9 Iterations)

**Epic 17: Iteration Manager & Reset System**
- Iteration state tracking (current iteration, progress flags)
- Reset logic: what persists vs what refreshes
- Level cap increase per iteration
- Loot table evolution (higher rarity availability)
- New dungeon areas unlocking per iteration
- Iteration transition cinematics/sequences

**Epic 18: The User Encounters**
- The User's Domain (special area after loop 6)
- 9 versions of The User encounter (escalating difficulty and dialogue)
- Win and lose paths both trigger iteration reset
- The User's dialogue reveals story across iterations
- Unique arena and visual style (abstract, surreal)

**Epic 19: Story Content (All 9 Iterations)**
- Full story bible implementation
- Story quest content for all 9 iterations
- NPC dialogue that evolves per iteration
- Environmental storytelling changes (signs, data fragments update)
- Multiple ending choices after iteration 9
- Story pacing and revelation structure

**Epic 20: NPC Awareness Evolution**
- NPC dialogue variants per iteration (normal → questioning → aware)
- NPC behavior changes in later iterations
- AI Sage appearances and dialogue across all iterations
- Town atmosphere shifts with awareness level

**Epic 21: Boss Evolution Across Iterations**
- Each boss gains new phases/patterns per iteration
- Boss dialogue changes with iteration
- Visual evolution of boss encounters
- New boss encounters in later iterations

---

#### Phase 4 — Endgame & Polish

**Epic 22: Endless Mode**
- Endless dungeon with continuously scaling difficulty
- Endless-specific loot tables and rewards
- Score/progress tracking for leaderboards
- Endless mode town activities and progression

**Epic 23: Audio Integration**
- Original or licensed music tracks (replace placeholders)
- Full SFX pass (combat, UI, environmental, abilities)
- Dynamic music system (transitions between zones/combat)
- Audio mixing and mastering

**Epic 24: Visual Polish & VFX**
- Final art pass on all assets (quality bar enforcement)
- VFX polish (abilities, hits, environmental)
- Lighting passes (town warmth, dungeon mood, iteration shifts)
- Screen effects (glitch overlays for iteration transitions)
- Performance optimization

**Epic 25: Steam Integration**
- Steam SDK integration
- Achievement system
- Cloud save sync
- Leaderboard API (endless mode)
- Store page assets (screenshots, trailer, descriptions)

**Epic 26: Final Polish & Release Build**
- Full playtest pass (all 9 iterations + endless)
- Bug fixing and stability
- Balance tuning
- Accessibility options finalization
- Release build compilation and testing

---

## Success Metrics

### Technical Metrics

- **Frame rate:** Consistent 60fps at 1080p on mid-range hardware
- **Load times:** Under 3 seconds for floor transitions
- **Crash rate:** Less than 1 crash per 10 hours of play
- **Save reliability:** Zero data loss incidents
- **Procedural generation:** Under 1 second per floor generation
- **Build size:** Under 2GB demo, under 5GB full game

### Gameplay Metrics

- **Core loop validation:** Playtesters want to re-enter the dungeon after returning to town
- **Session length:** Average 45+ minutes per session
- **Story engagement:** Players can articulate "what's going on" and want to know more after the demo
- **Combat feel:** Players describe combat as "satisfying" or "fluid"
- **Death response:** Players respond to death by wanting to try again, not quitting
- **Visual quality bar:** External playtesters do not describe assets as "placeholder" or "generic"
- **Demo completion:** 80%+ of demo playtesters reach the first compaction portal
- **Narrative hook:** Players ask "what happens next?" after the demo

### Launch Metrics

- **Steam page:** Demo polished enough for store page with quality screenshots
- **Wishlist target:** Meaningful wishlist growth from demo availability
- **Review sentiment:** Positive-leaning early feedback on demo quality
- **Completion rate:** 60%+ of full game players complete all 9 iterations

---

## Out of Scope

- Multiplayer or co-op (single-player only)
- Mobile or console ports (PC Steam only for now)
- Controller support (deferred to post-MVP)
- Voice acting
- Branching dialogue trees (linear dialogue for MVP)
- In-game currency/shop system (loot-driven only)
- Procedural story generation (story is hand-crafted)
- Modding support or Steam Workshop
- Localization (English only for MVP)
- Online leaderboards (deferred to endless mode post-story)

---

## Assumptions and Dependencies

- Godot 4.4 remains stable and supported throughout development
- Blender MCP provides reliable 3D asset creation pipeline
- Godot MCP enables efficient scene management and testing
- Free/open-source tools remain available for all core needs
- Outsourced audio can be obtained within budget when needed
- Steam publishing requirements remain achievable for solo developers
- The 2D vs 2.5D vs 3D visual approach will be resolved early through a visual prototype before committing to full asset production
